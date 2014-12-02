#include "..\..\Public\Source\GacUI.h"

using namespace vl::stream;
using namespace vl::regex;
using namespace vl::collections;
using namespace vl::parsing::xml;
using namespace vl::presentation::elements::text;

namespace document
{
	class GifAnimation : public Object, public IGuiGraphicsAnimation
	{
	protected:
		unsigned __int64				startTime;
		Ptr<DocumentImageRun>			imageRun;
		vint							paragraphIndex;
		GuiDocumentViewer*				documentViewer;
	public:
		GifAnimation(Ptr<DocumentImageRun> _imageRun, vint _paragraphIndex, GuiDocumentViewer* _documentViewer)
			:imageRun(_imageRun)
			,paragraphIndex(_paragraphIndex)
			,documentViewer(_documentViewer)
			,startTime(DateTime::LocalTime().totalMilliseconds)
		{
		}

		vint GetTotalLength()
		{
			return 1;
		}

		vint GetCurrentPosition()
		{
			return 0;
		}

		void Play(vint currentPosition, vint totalLength)
		{
			unsigned __int64 ms=DateTime::LocalTime().totalMilliseconds-startTime;
			vint frameIndex=(ms/100)%imageRun->image->GetFrameCount();
			imageRun->frameIndex=frameIndex;
			documentViewer->NotifyParagraphUpdated(paragraphIndex, 1, 1, false);
		}

		void Stop()
		{
		}
	};
	
	class GifAnimationVisitor : public Object, public DocumentRun::IVisitor
	{
	public:
		GuiControlHost*					controlHost;
		vint							paragraphIndex;
		GuiDocumentViewer*				documentViewer;

		GifAnimationVisitor(GuiControlHost* _controlHost, vint _paragraphIndex, GuiDocumentViewer* _documentViewer)
			:controlHost(_controlHost)
			,paragraphIndex(_paragraphIndex)
			,documentViewer(_documentViewer)
		{
		}

		void VisitContainer(DocumentContainerRun* run)
		{
			FOREACH(Ptr<DocumentRun>, subRun, run->runs)
			{
				subRun->Accept(this);
			}
		}

		void Visit(DocumentTextRun* run)override
		{
		}

		void Visit(DocumentStylePropertiesRun* run)override
		{
			VisitContainer(run);
		}

		void Visit(DocumentStyleApplicationRun* run)override
		{
			VisitContainer(run);
		}

		void Visit(DocumentHyperlinkRun* run)override
		{
			VisitContainer(run);
		}

		void Visit(DocumentImageRun* run)override
		{
			if(run->image->GetFrameCount()>1)
			{
				Ptr<GifAnimation> gifAnimation=new GifAnimation(run, paragraphIndex, documentViewer);
				controlHost->GetGraphicsHost()->GetAnimationManager()->AddAnimation(gifAnimation);
			}
		}

		void Visit(DocumentParagraphRun* run)override
		{
			VisitContainer(run);
		}

		static void CreateGifAnimation(DocumentParagraphRun* run, GuiControlHost* controlHost, vint paragraphIndex, GuiDocumentViewer* documentViewer)
		{
			GifAnimationVisitor visitor(controlHost, paragraphIndex, documentViewer);
			run->Accept(&visitor);
		}
	};
}
using namespace document;

void SetupDocumentElementLayoutWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container, const WString& filename)
{
	container->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	
	GuiDocumentViewer* documentViewer=g::NewDocumentViewer();
	documentViewer->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
	documentViewer->GetBoundsComposition()->SetAssociatedCursor(GetCurrentController()->ResourceService()->GetSystemCursor(INativeCursor::LargeWaiting));
	
	GetApplication()->InvokeAsync([=]()
	{
		Ptr<DocumentModel> document;
		{
			WString text;
			{
				FileStream fileStream(filename, FileStream::ReadOnly);
				BomDecoder decoder;
				DecoderStream decoderStream(fileStream, decoder);
				StreamReader writer(decoderStream);
				text=writer.ReadToEnd();
			}
			auto table=XmlLoadTable();
			List<WString> errors;
			Ptr<XmlDocument> xml=XmlParseDocument(text, table);
			document = DocumentModel::LoadFromXml(xml, L"Resources\\", errors);
		}
		GetApplication()->InvokeInMainThreadAndWait([=]()
		{
			documentViewer->SetDocument(document);
			documentViewer->GetBoundsComposition()->SetAssociatedCursor(GetCurrentController()->ResourceService()->GetDefaultSystemCursor());

			FOREACH_INDEXER(Ptr<DocumentParagraphRun>, p, i, document->paragraphs)
			{
				GifAnimationVisitor::CreateGifAnimation(p.Obj(), controlHost, i, documentViewer);
			}
		});
	});

	container->AddChild(documentViewer->GetBoundsComposition());
}

void SetupDocumentViewerLayoutWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	GuiDocumentViewer* documentControl=g::NewDocumentViewer();
	documentControl->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
	documentControl->ActiveHyperlinkExecuted.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
	{
		GetCurrentController()->DialogService()->ShowMessageBox(
			controlHost->GetNativeWindow(),
			documentControl->GetActiveHyperlinkReference(),
			controlHost->GetText());
	});
	container->AddChild(documentControl->GetBoundsComposition());

	List<WString> errors;
	Ptr<GuiResource> resource = GuiResource::LoadFromXml(L"Resources\\XmlResource.xml", errors);
	Ptr<DocumentModel> document=resource->GetValueByPath(L"XmlDoc.xml").Cast<DocumentModel>();
	documentControl->SetDocument(document);
}

void SetupDocumentLabelLayoutWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	GuiDocumentLabel* documentControl=g::NewDocumentLabel();
	documentControl->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
	documentControl->ActiveHyperlinkExecuted.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
	{
		GetCurrentController()->DialogService()->ShowMessageBox(
			controlHost->GetNativeWindow(),
			documentControl->GetActiveHyperlinkReference(),
			controlHost->GetText());
	});
	container->AddChild(documentControl->GetBoundsComposition());
	
	List<WString> errors;
	Ptr<GuiResource> resource = GuiResource::LoadFromXml(L"Resources\\XmlResource.xml", errors);
	Ptr<DocumentModel> document=resource->GetValueByPath(L"XmlDoc.xml").Cast<DocumentModel>();
	documentControl->SetDocument(document);
}