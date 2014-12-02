#include "PostWindow.h"

namespace vl
{
	using namespace stream;
	using namespace regex;

	namespace nestle
	{

/***********************************************************************
Markdown Parser
***********************************************************************/

		class DocumentWriter : public Object
		{
		protected:
			Ptr<text::DocumentModel>		document;
			Ptr<text::DocumentParagraph>	paragraph;
			Ptr<text::DocumentLine>			line;
			Ptr<text::DocumentTextRun>		run;

		public:
			DocumentWriter()
			{
				document=new text::DocumentModel;
			}

			Ptr<text::DocumentModel> Stop()
			{
				Ptr<text::DocumentModel> result=document;
				document=0;
				paragraph=0;
				line=0;
				run=0;
				return result;
			}

			void EnsureLineExists()
			{
				if(!paragraph)
				{
					paragraph=new text::DocumentParagraph;
					document->paragraphs.Add(paragraph);
				}
				if(!line)
				{
					line=new text::DocumentLine;
					paragraph->lines.Add(line);
				}
			}

			void FinishLine()
			{
				EnsureLineExists();
				line=0;
				run=0;
			}

			void FinishParagraph()
			{
				if(!paragraph || paragraph->lines.Count()==0)
				{
					EnsureLineExists();
				}
				paragraph=0;
				line=0;
				run=0;
			}

			void BeginRun(const FontProperties& fontStyle, Color fontColor=Color(0, 0, 0))
			{
				EnsureLineExists();
				run=new text::DocumentTextRun;
				run->style=fontStyle;
				run->color=fontColor;
				line->runs.Add(run);
			}

			void WriteText(const WString& text)
			{
				EnsureLineExists();
				if(!run)
				{
					BeginRun(GetCurrentController()->ResourceService()->GetDefaultFont());
				}
				run->text+=text;
			}

			Ptr<text::DocumentImageRun> WriteImagePlaceHolder(int& paragraphIndex)
			{
				EnsureLineExists();
				run=0;
				Ptr<text::DocumentImageRun> imageRun=new text::DocumentImageRun;
				line->runs.Add(imageRun);
				paragraphIndex=document->paragraphs.Count()-1;
				return imageRun;
			}
		};

		const wchar_t* EscapeSpaces(const wchar_t* reading)
		{
			while(*reading)
			{
				if(*reading==L' ' || *reading==L'\t')
				{
					reading++;
				}
				else
				{
					break;
				}
			}
			return reading;
		}

		struct ImageRunPlaceHolder
		{
			Ptr<text::DocumentImageRun>		imageRun;
			WString							link;
			int								paragraphIndex;
		};

		Ptr<text::DocumentModel> ParseMarkdown(const WString& markdown, List<Ptr<ImageRunPlaceHolder>>& imageRunPlaceHolders)
		{
			WString processedMarkdown;
			{
				MemoryStream stream;
				{
					StreamWriter writer(stream);
					const wchar_t* reading=markdown.Buffer();
					while(*reading)
					{
						if(wcsncmp(reading, L"&LT;", 4)==0 || wcsncmp(reading, L"&lt;", 4)==0)
						{
							writer.WriteChar(L'<');
							reading+=4;
						}
						else if(wcsncmp(reading, L"&GT;", 4)==0 || wcsncmp(reading, L"&gt;", 4)==0)
						{
							writer.WriteChar(L'>');
							reading+=4;
						}
						else
						{
							writer.WriteChar(*reading);
							reading++;
						}
					}
				}
				{
					stream.SeekFromBegin(0);
					StreamReader reader(stream);
					processedMarkdown=reader.ReadToEnd();
				}
			}
			DocumentWriter writer;

			FontProperties defaultFont=GetCurrentController()->ResourceService()->GetDefaultFont();
			FontProperties headerFonts[6];
			FontProperties referenceFont=defaultFont;
			FontProperties currentFont=defaultFont;
			WString currentText;

			Regex regexDirectLink(L"(<link>(https?://|www.)[a-zA-Z0-9_///-?&=%.()]+)");
			Regex regexIndirectLink(L"/[(<name>[^/]]*)/]/((<link>[^/t )]+)/s*(\"(<tip>[^\"]+)\"/s*)?/)");
			Regex regexReferenceLink(L"/[(<name>[^/]]*)/]/[(<ref>[^/]]+)/]");
			Regex regexReferenceTarget(L"/s*/[(<name>[^/]]+)/]:/s*(<link>[^ \"]+)");
			Regex regexHorizon(L"/s*(/*{3,}|-{3,}|-/s+-/s+-(/s+-)?)/s*");

			for(int i=0;i<sizeof(headerFonts)/sizeof(*headerFonts);i++)
			{
				headerFonts[i]=defaultFont;
				headerFonts[i].size+=(i+1)*3;
				headerFonts[i].bold=true;
			}

			Dictionary<WString, WString> referenceTargest;
			{
				StringReader reader(processedMarkdown);
				while(!reader.IsEnd())
				{
					WString line=reader.ReadLine();
					Ptr<RegexMatch> match=regexReferenceTarget.MatchHead(line);
					if(match && match->Success())
					{
						WString name=match->Groups()[L"name"].Get(0).Value();
						WString link=match->Groups()[L"link"].Get(0).Value();
						referenceTargest.Set(name, link);
					}
				}
			}
			
			bool lastLineIsEmpty=true;
			StringReader reader(processedMarkdown);
			while(!reader.IsEnd())
			{
				WString line=reader.ReadLine();
				{
					Ptr<RegexMatch> match=regexReferenceTarget.MatchHead(line);
					if(match && match->Success())
					{
						continue;
					}
				}
				const wchar_t* reading=line.Buffer();
				bool referenceMode=false;

				{
					// try empty line
					if(*EscapeSpaces(reading)==0)
					{
						if(!lastLineIsEmpty)
						{
							lastLineIsEmpty=true;
							writer.FinishParagraph();
						}
						continue;
					}
					else
					{
						lastLineIsEmpty=false;
					}
				}

				if(wcsncmp(reading, L"\t", 1)==0)
				{
					// test reference
					reading+=1;
					referenceMode=true;
				}
				else if(wcsncmp(reading, L"    ", 4)==0)
				{
					// test reference
					reading+=4;
					referenceMode=true;
				}

				if(referenceMode)
				{
					// write reference text
					writer.BeginRun(referenceFont, Color(14, 73, 32));
					writer.WriteText(L"\t");
					writer.WriteText(reading);
				}
				else
				{
					// try horizon line
					{
						Ptr<RegexMatch> match=regexHorizon.MatchHead(line);
						if(match && match->Success() && match->Result().Value()==line)
						{
							writer.BeginRun(defaultFont, Color(128, 128, 128));
							writer.WriteText(L"---------------------------------------------------------------");
							continue;
						}
					}
#define NO_HEADER (sizeof(headerFonts)/sizeof(*headerFonts))
					// try test header
					int headerLevel=NO_HEADER;
					{
						const wchar_t* temp=reading;
						while(*temp)
						{
							if(*temp==L'#')
							{
								if(headerLevel>0)
								{
									headerLevel--;
								}
								temp++;
							}
							else if((*temp==L' ' || *temp==L'\t') && headerLevel==NO_HEADER)
							{
								temp++;
							}
							else
							{
								break;
							}
						}
						if(headerLevel!=NO_HEADER)
						{
							reading=EscapeSpaces(temp);
						}
					}

					if(headerLevel!=NO_HEADER)
					{
						// header mode
						const wchar_t* end=reading+wcslen(reading);
						while(end[-1]==L'#')
						{
							end--;
						}

						writer.BeginRun(headerFonts[headerLevel]);
						writer.WriteText(WString(reading, end-reading));
						goto END_OF_LINE;
					}

					writer.BeginRun(defaultFont);
					writer.WriteText(L"  ");
					if(wcsncmp(reading, L"* ", 2)==0 || wcsncmp(reading, L"*\t", 2)==0 || wcsncmp(reading, L"- ", 2)==0 || wcsncmp(reading, L"-\t", 2)==0)
					{
						// try test unordered list
						reading=EscapeSpaces(reading+2);

						writer.BeginRun(defaultFont, Color(96, 96, 96));
						writer.WriteText(L"●   ");
					}
					else
					{
						// try test ordered list
						const wchar_t* temp=reading;
						while(*temp)
						{
							if(L'0'<=*temp && *temp<=L'9')
							{
								temp++;
							}
							else
							{
								break;
							}
						}
						if(temp>reading && *temp==L'.')
						{
							writer.BeginRun(defaultFont, Color(96, 96, 96));
							writer.WriteText(WString(reading, temp-reading)+L".   ");
							reading=EscapeSpaces(temp+1);
						}
					}

					bool beganRun=false;
					bool inQuot=false;
					while(*reading)
					{
						if(!inQuot && (wcsncmp(reading, L"**", 2)==0 || wcsncmp(reading, L"__", 2)==0))
						{
							// enable/disable bold
							currentFont.bold=!currentFont.bold;
							writer.BeginRun(currentFont);
							reading+=2;
							beganRun=true;
						}
						else if(!inQuot && (wcsncmp(reading, L"*", 1)==0 || wcsncmp(reading, L"_", 1)==0))
						{
							// enable/disable italic
							currentFont.italic=!currentFont.italic;
							writer.BeginRun(currentFont);
							reading+=1;
							beganRun=true;
						}
						else if(!inQuot && (wcsncmp(reading, L"~~", 2)==0))
						{
							// enable/disable bold
							currentFont.strikeline=!currentFont.strikeline;
							writer.BeginRun(currentFont);
							reading+=2;
							beganRun=true;
						}
						else
						{
							bool imagePrefix=false;
							if(*reading==L'!')
							{
								imagePrefix=true;
								reading++;
							}
							// try direct link
							{
								Ptr<RegexMatch> match=regexDirectLink.MatchHead(reading);
								if(match && match->Success())
								{
									WString link=match->Groups()[L"link"].Get(0).Value();
									reading+=match->Result().Length();

									bool underline=currentFont.underline;
									currentFont.underline=true;
									writer.BeginRun(currentFont, Color(0, 0, 255));
									writer.WriteText(link);
									currentFont.underline=underline;

									writer.BeginRun(currentFont);
									beganRun=true;
									goto END_OF_FRAGMENT;
								}
							}

							// try indirect link
							{
								Ptr<RegexMatch> match=regexIndirectLink.MatchHead(reading);
								if(match && match->Success())
								{
									WString name=match->Groups()[L"name"].Get(0).Value();
									WString link=match->Groups()[L"link"].Get(0).Value();
									if(name==L"")
									{
										name=link;
									}
									reading+=match->Result().Length();

									if(imagePrefix)
									{
										Ptr<ImageRunPlaceHolder> imageRunPlaceHolder=new ImageRunPlaceHolder;
										imageRunPlaceHolder->imageRun=writer.WriteImagePlaceHolder(imageRunPlaceHolder->paragraphIndex);
										imageRunPlaceHolder->link=link;
										imageRunPlaceHolders.Add(imageRunPlaceHolder);
										beganRun=false;
									}
									else
									{
										bool underline=currentFont.underline;
										currentFont.underline=true;
										writer.BeginRun(currentFont, Color(0, 0, 255));
										writer.WriteText(name);
										currentFont.underline=underline;
										writer.BeginRun(currentFont);
										beganRun=true;
									}
									goto END_OF_FRAGMENT;
								}
							}

							// try reference link
							{
								Ptr<RegexMatch> match=regexReferenceLink.MatchHead(reading);
								if(match && match->Success())
								{
									WString name=match->Groups()[L"name"].Get(0).Value();
									WString ref=match->Groups()[L"ref"].Get(0).Value();
									WString link;
									if(referenceTargest.Keys().Contains(ref))
									{
										link=referenceTargest[ref];
										if(name==L"")
										{
											name=link;
										}
									}
									else
									{
										if(name==L"")
										{
											name=ref;
										}
									}
									reading+=match->Result().Length();

									if(imagePrefix)
									{
										Ptr<ImageRunPlaceHolder> imageRunPlaceHolder=new ImageRunPlaceHolder;
										imageRunPlaceHolder->imageRun=writer.WriteImagePlaceHolder(imageRunPlaceHolder->paragraphIndex);
										imageRunPlaceHolder->link=link;
										imageRunPlaceHolders.Add(imageRunPlaceHolder);
										beganRun=false;
									}
									else
									{
										bool underline=currentFont.underline;
										currentFont.underline=true;
										writer.BeginRun(currentFont, Color(0, 0, 255));
										writer.WriteText(name);
										currentFont.underline=underline;
										writer.BeginRun(currentFont);
										beganRun=true;
									}
									beganRun=false;
									goto END_OF_FRAGMENT;
								}
							}

							if(imagePrefix)
							{
								reading--;
							}

							if(!beganRun)
							{
								writer.BeginRun(currentFont);
								beganRun=true;
							}
							if(*reading==L'"')
							{
								inQuot=!inQuot;
							}
							writer.WriteText(*reading);
							reading+=1;
END_OF_FRAGMENT:;
						}
					}
#undef NO_HEADER
				}
END_OF_LINE:;
				writer.FinishLine();
			}
			return writer.Stop();
		}

/***********************************************************************
GifAnimation
***********************************************************************/
		
		class GifAnimation : public Object, public IGuiGraphicsAnimation
		{
		protected:
			unsigned __int64				startTime;
			Ptr<text::DocumentImageRun>		imageRun;
			int								paragraphIndex;
			GuiDocumentElement*				documentElement;
			bool							stopped;
		public:
			GifAnimation(Ptr<text::DocumentImageRun> _imageRun, int _paragraphIndex, GuiDocumentElement* _documentElement)
				:imageRun(_imageRun)
				,paragraphIndex(_paragraphIndex)
				,documentElement(_documentElement)
				,startTime(DateTime::LocalTime().totalMilliseconds)
				,stopped(false)
			{
			}

			int GetTotalLength()
			{
				return 1;
			}

			int GetCurrentPosition()
			{
				return stopped?1:0;
			}

			void Play(int currentPosition, int totalLength)
			{
				if(!stopped)
				{
					unsigned __int64 ms=DateTime::LocalTime().totalMilliseconds-startTime;
					int frameIndex=(ms/100)%imageRun->image->GetFrameCount();
					imageRun->frameIndex=frameIndex;
					documentElement->NotifyParagraphUpdated(paragraphIndex);
				}
			}

			void Stop()
			{
				stopped=true;
			}
		};

/***********************************************************************
PostItemControl
***********************************************************************/

		void PostItemControl::buttonReply_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			PostWindow* postWindow=dynamic_cast<PostWindow*>(sender->GetRelatedControlHost());
			postWindow->Reply(authorElement->GetText());
		}

		void PostItemControl::buttonEdit_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
		}

		void PostItemControl::buttonDelete_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			PostWindow* postWindow=dynamic_cast<PostWindow*>(sender->GetRelatedControlHost());
			if(postItem->isComment)
			{
				GetApplication()->InvokeAsync([=]()
				{
					bool result=postWindow->GetServer()->DeleteComment(postItem->id);
					GetApplication()->InvokeInMainThreadAndWait([=]()
					{
						if(result)
						{
							postWindow->RefreshPostItems();
						}
						else
						{
							GetCurrentController()->DialogService()->ShowMessageBox(
								GetBoundsComposition()->GetRelatedControlHost()->GetNativeWindow(),
								L"删除回复失败，请检查网络连接是否畅通。"
								);
						}
					});
				});
			}
			else
			{
				GetApplication()->InvokeAsync([=]()
				{
					bool result=postWindow->GetServer()->DeleteTopic(postItem->id);
					GetApplication()->InvokeInMainThreadAndWait([=]()
					{
						if(result)
						{
							postWindow->Close();
						}
						else
						{
							GetCurrentController()->DialogService()->ShowMessageBox(
								GetBoundsComposition()->GetRelatedControlHost()->GetNativeWindow(),
								L"删除帖子失败，请检查网络连接是否畅通。"
								);
						}
					});
				});
			}
		}

		PostItemControl::PostItemControl()
		{
			InitializeComponents();
			downloadVersion=new DownloadVersion;
		}

		PostItemControl::~PostItemControl()
		{
			downloadVersion->version++;
		}

		struct ImageDownloadTask
		{
			Ptr<ImageRunPlaceHolder>		placeHolder;
			Ptr<GifAnimation>				animation;
		};

		struct ImageDownloadTaskContainer
		{
			List<Ptr<ImageDownloadTask>>	tasks;
		};

		void PostItemControl::Install(Ptr<Object> value)
		{
			postItem=value.Cast<PostItem>();
			if(postItem->title==L"")
			{
				titleElement->SetText(L"-----------------回复-----------------");
			}
			else
			{
				titleElement->SetText(L"◇ "+postItem->title);
			}
			authorElement->SetText(postItem->author);
			dateTimeElement->SetText(postItem->createDateTime);

			PostWindow* postWindow=dynamic_cast<PostWindow*>(GetRelatedControlHost());
			buttonEdit->SetVisible(postWindow->IsCurrentUser(postItem->author));

			buttonDelete->SetVisible(postWindow->IsCurrentUser(postItem->author));
			GetApplication()->InvokeAsync([=]()
			{
				List<Ptr<ImageRunPlaceHolder>> placeHolders;
				Ptr<text::DocumentModel> document=ParseMarkdown(postItem->body, placeHolders);

				GetApplication()->InvokeInMainThreadAndWait([=, &placeHolders]()
				{
					Ptr<ImageDownloadTaskContainer> taskContainer=new ImageDownloadTaskContainer;
					for(int i=0;i<placeHolders.Count();i++)
					{
						Ptr<ImageRunPlaceHolder> placeHolder=placeHolders[i];
						Ptr<ImageDownloadTask> task=new ImageDownloadTask;
						task->placeHolder=placeHolder;
						taskContainer->tasks.Add(task);

						if(placeHolder->link==L"")
						{
							placeHolder->imageRun->image=postWindow->GetResources()->imageDownloadFailed;
						}
						else
						{
							placeHolder->imageRun->image=postWindow->GetResources()->imageLoading;
						}
						placeHolder->imageRun->frameIndex=0;
						placeHolder->imageRun->size=placeHolder->imageRun->image->GetFrame(0)->GetSize();
						placeHolder->imageRun->baseline=placeHolder->imageRun->size.y;

						if(placeHolder->imageRun->image->GetFrameCount()>1)
						{
							Ptr<GifAnimation> animation=new GifAnimation(placeHolder->imageRun, placeHolder->paragraphIndex, bodyElement);
							postWindow->GetGraphicsHost()->GetAnimationManager()->AddAnimation(animation);
							task->animation=animation;
						}
					}
					bodyElement->SetDocument(document);

					WString cookie=postWindow->GetServer()->GetCookie();
					Ptr<DownloadVersion> version=downloadVersion;
					int currentVersion=++version->version;

					GetApplication()->InvokeAsync([=]()
					{
						volatile bool needToExit=false;
						for(int i=0;!needToExit&&i<taskContainer->tasks.Count();i++)
						{
							Ptr<ImageDownloadTask> task=taskContainer->tasks[i];
							if(task->placeHolder->link==L"")
							{
								continue;
							}

							HttpRequest request;
							request.acceptTypes.Add(L"image/gif");
							request.acceptTypes.Add(L"image/png");
							request.acceptTypes.Add(L"image/jpeg");
							request.cookie=cookie;
							request.method=L"GET";
							request.SetHost(task->placeHolder->link);

							HttpResponse response;
							void* buffer=0;
							int length=0;
							if(HttpQuery(request, response))
							{
								if(response.body.Count()>0)
								{
									buffer=&response.body[0];
									length=response.body.Count();
								}
							}
							GetApplication()->InvokeInMainThreadAndWait([=, &needToExit]()
							{
								if(version->version!=currentVersion)
								{
									needToExit=true;
								}
								else
								{
									Ptr<INativeImage> resultImage;
									if(buffer)
									{
										resultImage=GetCurrentController()->ImageService()->CreateImageFromMemory(buffer, length);
									}
									if(!resultImage)
									{
										resultImage=postWindow->GetResources()->imageDownloadFailed;
									}
									if(task->animation)
									{
										task->animation->Stop();
									}
									Ptr<ImageRunPlaceHolder> placeHolder=task->placeHolder;
									placeHolder->imageRun->image=resultImage;
									placeHolder->imageRun->frameIndex=0;
									placeHolder->imageRun->size=placeHolder->imageRun->image->GetFrame(0)->GetSize();
									placeHolder->imageRun->baseline=placeHolder->imageRun->size.y;
									bodyElement->NotifyParagraphUpdated(placeHolder->paragraphIndex);
								}
							});
						}
					});
				});
			});
		}

/***********************************************************************
PostItemControl::InitializeComponents
***********************************************************************/

		void PostItemControl::InitializeComponents()
		{
			FontProperties titleFont=GetFont();
			titleFont.size=28;
			titleFont.bold=true;
			FontProperties bodyFont=GetFont();
			bodyFont.size=16;
			FontProperties buttonFont=GetFont();
			titleFont.size=22;

			Color titleColor(0, 0, 0);
			Color frameColor(128, 128, 128);
			Color bodyColor(64, 64, 64);

			GuiTableComposition* table=new GuiTableComposition;
			GetContainerComposition()->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
			GetContainerComposition()->AddChild(table);
			table->SetAlignmentToParent(Margin(10, 4, 10, 4));
			table->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
			table->SetRowsAndColumns(4, 4);
			table->SetCellPadding(4);
			table->SetRowOption(0, GuiCellOption::MinSizeOption());
			table->SetRowOption(1, GuiCellOption::MinSizeOption());
			table->SetRowOption(2, GuiCellOption::MinSizeOption());
			table->SetRowOption(3, GuiCellOption::MinSizeOption());
			table->SetColumnOption(0, GuiCellOption::MinSizeOption());
			table->SetColumnOption(1, GuiCellOption::PercentageOption(0.5));
			table->SetColumnOption(2, GuiCellOption::MinSizeOption());
			table->SetColumnOption(3, GuiCellOption::MinSizeOption());
			{
				GuiSolidLabelElement* element=GuiSolidLabelElement::Create();
				element->SetFont(titleFont);
				element->SetEllipse(true);
				element->SetText(L"Title");
				element->SetColor(titleColor);
				titleElement=element;

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetOwnedElement(element);
				cell->SetSite(0, 0, 1, 4);
			}
			{
				GuiSolidLabelElement* element=GuiSolidLabelElement::Create();
				element->SetFont(bodyFont);
				element->SetText(L"◇ Po主：");
				element->SetColor(frameColor);

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetOwnedElement(element);
				cell->SetSite(1, 0, 1, 1);
			}
			{
				GuiSolidLabelElement* element=GuiSolidLabelElement::Create();
				element->SetFont(bodyFont);
				element->SetText(L"Author");
				element->SetColor(bodyColor);
				authorElement=element;

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetOwnedElement(element);
				cell->SetSite(1, 1, 1, 1);
			}
			{
				GuiSolidLabelElement* element=GuiSolidLabelElement::Create();
				element->SetFont(bodyFont);
				element->SetText(L"◇ 时间：");
				element->SetColor(frameColor);

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetOwnedElement(element);
				cell->SetSite(1, 2, 1, 1);
			}
			{
				GuiSolidLabelElement* element=GuiSolidLabelElement::Create();
				element->SetFont(bodyFont);
				element->SetText(L"DateTime");
				element->SetColor(bodyColor);
				dateTimeElement=element;

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetOwnedElement(element);
				cell->SetSite(1, 3, 1, 1);
			}
			{
				GuiBoundsComposition* descriptionComposition=0;
				{
					GuiDocumentElement* element=GuiDocumentElement::Create();
					bodyElement=element;

					GuiBoundsComposition* composition=new GuiBoundsComposition;
					composition->SetOwnedElement(element);
					composition->SetAlignmentToParent(Margin(3, 3, 3, 3));
					composition->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElement);
					descriptionComposition=composition;
				}

				GuiSolidBorderElement* element=GuiSolidBorderElement::Create();
				element->SetColor(Color(128, 128, 128));

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetOwnedElement(element);
				cell->AddChild(descriptionComposition);
				cell->SetInternalMargin(Margin(3, 3, 3, 3));
				cell->SetSite(2, 0, 1, 4);
			}
			{
				GuiStackComposition* stack=new GuiStackComposition;
				stack->SetAlignmentToParent(Margin(0, 0, 0, 0));
				stack->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
				stack->SetDirection(GuiStackComposition::Horizontal);
				{
					buttonReply=g::NewButton();
					buttonReply->SetFont(buttonFont);
					buttonReply->SetText(L"我要♂一战");
					buttonReply->GetBoundsComposition()->SetAssociatedCursor(GetCurrentController()->ResourceService()->GetSystemCursor(INativeCursor::Hand));
					buttonReply->GetBoundsComposition()->SetAlignmentToParent(Margin(3, 3, 3, 3));
					buttonReply->Clicked.AttachMethod(this, &PostItemControl::buttonReply_Clicked);

					GuiStackItemComposition* item=new GuiStackItemComposition;
					item->AddChild(buttonReply->GetBoundsComposition());
					stack->AddChild(item);
				}
				{
					buttonEdit=g::NewButton();
					buttonEdit->SetFont(buttonFont);
					buttonEdit->SetText(L"    编辑    ");
					buttonEdit->GetBoundsComposition()->SetAssociatedCursor(GetCurrentController()->ResourceService()->GetSystemCursor(INativeCursor::Hand));
					buttonEdit->GetBoundsComposition()->SetAlignmentToParent(Margin(3, 3, 3, 3));
					buttonEdit->Clicked.AttachMethod(this, &PostItemControl::buttonEdit_Clicked);

					GuiStackItemComposition* item=new GuiStackItemComposition;
					item->AddChild(buttonEdit->GetBoundsComposition());
					stack->AddChild(item);
				}
				{
					buttonDelete=g::NewButton();
					buttonDelete->SetFont(buttonFont);
					buttonDelete->SetText(L"    删除    ");
					buttonDelete->GetBoundsComposition()->SetAssociatedCursor(GetCurrentController()->ResourceService()->GetSystemCursor(INativeCursor::Hand));
					buttonDelete->GetBoundsComposition()->SetAlignmentToParent(Margin(3, 3, 3, 3));
					buttonDelete->Clicked.AttachMethod(this, &PostItemControl::buttonDelete_Clicked);

					GuiStackItemComposition* item=new GuiStackItemComposition;
					item->AddChild(buttonDelete->GetBoundsComposition());
					stack->AddChild(item);
				}
				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->AddChild(stack);
				cell->SetSite(3, 0, 1, 4);
			}
		}

/***********************************************************************
PostWindow
***********************************************************************/

		void PostWindow::buttonPost_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			WString body=textBody->GetText();
			buttonPost->SetEnabled(false);
			GetApplication()->InvokeAsync([=]()
			{
				Ptr<NestleComment> comment=server->PostComment(post->id, body);
				GetApplication()->InvokeInMainThreadAndWait([=]()
				{
					buttonPost->SetEnabled(true);
					if(comment)
					{
						textBody->SetText(L"");
						textBody->SetFocus();
						RefreshPostItems();
					}
					else
					{
						GetCurrentController()->DialogService()->ShowMessageBox(
							GetBoundsComposition()->GetRelatedControlHost()->GetNativeWindow(),
							L"回帖失败，请检查网络连接是否畅通。"
							);
					}
				});
			});
		}

		void PostWindow::buttonUploadPicture_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			buttonPost->SetEnabled(false);
			buttonUploadPicture->SetEnabled(false);
			List<WString> selectionFileNames;
			int selectionFilterIndex=0;
			if(GetCurrentController()->DialogService()->ShowFileDialog(
				GetNativeWindow(),
				selectionFileNames,
				selectionFilterIndex,
				INativeDialogService::FileDialogOpenPreview,
				L"选择要上传的图片",
				L"",
				L"",
				L"jpg",
				L"图片文件(*.jpg;*.gif;*.png)|*.jpg;*.gif;*.png",
				(INativeDialogService::FileDialogOptions)(INativeDialogService::FileDialogDereferenceLinks | INativeDialogService::FileDialogFileMustExist)
				))
			{
				WString fileName=selectionFileNames[0];
				GetApplication()->InvokeAsync([=]()
				{
					FileStream stream(fileName, FileStream::ReadOnly);
					WString url=server->UploadFile(stream, fileName);
					GetApplication()->InvokeInMainThreadAndWait([=]()
					{
						buttonPost->SetEnabled(true);
						buttonUploadPicture->SetEnabled(true);
						if(url!=L"")
						{
							textBody->SetSelectionText(L"![]("+url+L")");
						}
						else
						{
							GetCurrentController()->DialogService()->ShowMessageBox(
								GetBoundsComposition()->GetRelatedControlHost()->GetNativeWindow(),
								L"上传图片失败，请检查网络连接是否畅通。"
								);
						}
					});
				});
			}
		}

		void PostWindow::buttonCancel_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			Close();
		}

		void PostWindow::this_WindowClosed(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			ClearPostItems();
		}

		void PostWindow::ClearPostItems()
		{
			FOREACH(PostItemControl*, postItemControl, postItemControls)
			{
				GuiStackItemComposition* stackItem=dynamic_cast<GuiStackItemComposition*>(postItemControl->GetBoundsComposition()->GetParent());
				postItemStack->RemoveChild(stackItem);
				stackItem->RemoveChild(postItemControl->GetBoundsComposition());
				delete postItemControl;
				delete stackItem;
			}
			postItemControls.Clear();
		}

		void PostWindow::AddPostItem(Ptr<PostItem> postItem)
		{
			PostItemControl* postItemControl=new PostItemControl;
			postItemControl->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
			postItemControls.Add(postItemControl);

			GuiStackItemComposition* item=new GuiStackItemComposition;
			item->AddChild(postItemControl->GetBoundsComposition());
			postItemStack->AddChild(item);

			postItemControl->Install(postItem);
		}

		PostWindow::PostWindow(Ptr<NestleServer> _server, Ptr<NestlePost> _post, Ptr<PostResources> _resources)
			:GuiWindow(GetCurrentTheme()->CreateWindowStyle())
			,server(_server)
			,post(_post)
			,resources(_resources)
		{
			SetText(L"围观帖子："+post->title);
			SetMinimizedBox(false);
			SetClientSize(Size(640, 480));
			GetBoundsComposition()->SetPreferredMinSize(Size(400, 300));
			GetContainerComposition()->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
			MoveToScreenCenter();

			InitializeComponents();
			RefreshPostItems();
		}

		PostWindow::~PostWindow()
		{
		}

		void PostWindow::RefreshPostItems()
		{
			buttonPost->SetEnabled(false);
			buttonCancel->SetEnabled(false);
			postItemContainers->SetEnabled(false);

			GetApplication()->InvokeAsync([=]()
			{
				Ptr<NestlePost> newPost=server->GetTopic(post->id);

				GetApplication()->InvokeInMainThreadAndWait([=]()
				{
					post=newPost;
					ClearPostItems();
					if(post)
					{
						SetText(L"围观帖子："+post->title);
						{
							Ptr<PostItem> postItem=new PostItem;
							postItem->title=post->title;
							postItem->author=post->author;
							postItem->createDateTime=post->createDateTime;
							postItem->body=post->body;
							postItem->isComment=false;
							postItem->id=newPost->id;
							AddPostItem(postItem);
						}
						FOREACH(Ptr<NestleComment>, comment, post->comments)
						{
							Ptr<PostItem> postItem=new PostItem;
							postItem->author=comment->author;
							postItem->createDateTime=comment->createDateTime;
							postItem->body=comment->body;
							postItem->isComment=true;
							postItem->id=comment->id;
							AddPostItem(postItem);
						}

						buttonPost->SetEnabled(true);
						buttonCancel->SetEnabled(true);
						postItemContainers->SetEnabled(true);
					}
					else
					{
						GetCurrentController()->DialogService()->ShowMessageBox(
							GetBoundsComposition()->GetRelatedControlHost()->GetNativeWindow(),
							L"打开帖子失败，请检查网络连接是否畅通。"
							);
					}
				});
			});
		}

		void PostWindow::Reply(const WString& author)
		{
			textBody->SetText(L"@"+author+L"\r\n"+textBody->GetText());
			textBody->Select(TextPos(), TextPos());
			textBody->SetFocus();
		}

		Ptr<NestleServer> PostWindow::GetServer()
		{
			return server;
		}

		Ptr<PostResources> PostWindow::GetResources()
		{
			return resources;
		}

		bool PostWindow::IsCurrentUser(const WString& author)
		{
			return server->GetUsername()==author;
		}

/***********************************************************************
PostWindow::InitializeComponents
***********************************************************************/

		void PostWindow::InitializeComponents()
		{
			WindowClosed.AttachMethod(this, &PostWindow::this_WindowClosed);

			GuiTableComposition* table=new GuiTableComposition;
			GetContainerComposition()->AddChild(table);
			table->SetAlignmentToParent(Margin(2, 2, 2, 2));
			table->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
			table->SetCellPadding(4);
			table->SetRowsAndColumns(3, 4);
			table->SetRowOption(0, GuiCellOption::PercentageOption(1.0));
			table->SetRowOption(1, GuiCellOption::AbsoluteOption(160));
			table->SetRowOption(2, GuiCellOption::MinSizeOption());
			table->SetColumnOption(0, GuiCellOption::MinSizeOption());
			table->SetColumnOption(1, GuiCellOption::MinSizeOption());
			table->SetColumnOption(2, GuiCellOption::PercentageOption(1.0));
			table->SetColumnOption(3, GuiCellOption::MinSizeOption());
			{
				postItemContainers=new GuiScrollContainer(GetCurrentTheme()->CreateMultilineTextBoxStyle());
				postItemContainers->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
				postItemContainers->SetHorizontalAlwaysVisible(false);
				postItemContainers->SetExtendToFullWidth(true);

				postItemStack=new GuiStackComposition;
				postItemStack->SetAlignmentToParent(Margin(0, 0, 0, 0));
				postItemStack->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
				postItemStack->SetDirection(GuiStackComposition::Vertical);
				postItemContainers->GetContainerComposition()->AddChild(postItemStack);

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetSite(0, 0, 1, 4);
				cell->AddChild(postItemContainers->GetBoundsComposition());
			}
			{
				textBody=g::NewMultilineTextBox();
				textBody->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
				textBody->SetText(L"<请输入回复的内容>");

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetSite(1, 0, 1, 4);
				cell->AddChild(textBody->GetBoundsComposition());
			}
			{
				buttonPost=g::NewButton();
				buttonPost->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
				buttonPost->SetText(L"回帖");
				buttonPost->GetBoundsComposition()->SetPreferredMinSize(Size(120, 36));
				buttonPost->Clicked.AttachMethod(this, &PostWindow::buttonPost_Clicked);

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetSite(2, 0, 1, 1);
				cell->AddChild(buttonPost->GetBoundsComposition());
			}
			{
				buttonUploadPicture=g::NewButton();
				buttonUploadPicture->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
				buttonUploadPicture->SetText(L"上传图片");
				buttonUploadPicture->GetBoundsComposition()->SetPreferredMinSize(Size(120, 36));
				buttonUploadPicture->Clicked.AttachMethod(this, &PostWindow::buttonUploadPicture_Clicked);

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetSite(2, 1, 1, 1);
				cell->AddChild(buttonUploadPicture->GetBoundsComposition());
			}
			{
				buttonCancel=g::NewButton();
				buttonCancel->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
				buttonCancel->SetText(L"关闭");
				buttonCancel->GetBoundsComposition()->SetPreferredMinSize(Size(120, 36));
				buttonCancel->Clicked.AttachMethod(this, &PostWindow::buttonCancel_Clicked);

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetSite(2, 3, 1, 1);
				cell->AddChild(buttonCancel->GetBoundsComposition());
			}
		}
	}
}