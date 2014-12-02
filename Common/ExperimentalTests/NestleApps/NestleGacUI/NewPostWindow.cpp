#include "NewPostWindow.h"

namespace vl
{
	namespace nestle
	{

/***********************************************************************
NewPostWindow
***********************************************************************/

		void NewPostWindow::buttonPost_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			WString title=textTitle->GetText();
			WString body=textBody->GetText();

			textTitle->SetEnabled(false);
			textBody->SetEnabled(false);
			buttonPost->SetEnabled(false);
			buttonCancel->SetEnabled(false);

			GetApplication()->InvokeAsync([=]()
			{
				Ptr<NestlePost> newPost=server->PostTopic(title, body);

				GetApplication()->InvokeInMainThreadAndWait([=]()
				{
					if(newPost)
					{
						post=newPost;
						Close();
					}
					else
					{
						textTitle->SetEnabled(true);
						textBody->SetEnabled(true);
						buttonPost->SetEnabled(true);
						buttonCancel->SetEnabled(true);

						GetCurrentController()->DialogService()->ShowMessageBox(
							GetBoundsComposition()->GetRelatedControlHost()->GetNativeWindow(),
							L"发帖失败，请检查网络连接是否畅通。"
							);
					}
				});
			});
		}

		void NewPostWindow::buttonCancel_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			Close();
		}

		NewPostWindow::NewPostWindow(Ptr<NestleServer> _server)
			:GuiWindow(GetCurrentTheme()->CreateWindowStyle())
			,server(_server)
		{
			SetText(L"编辑帖子");
			SetMinimizedBox(false);
			SetClientSize(Size(640, 480));
			GetBoundsComposition()->SetPreferredMinSize(Size(400, 300));
			GetContainerComposition()->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
			MoveToScreenCenter();

			InitializeComponents();
		}

		NewPostWindow::~NewPostWindow()
		{
		}

		Ptr<NestlePost> NewPostWindow::GetCommittedPost()
		{
			return post;
		}

/***********************************************************************
NewPostWindow::InitializeComponents
***********************************************************************/
		void NewPostWindow::InitializeComponents()
		{
			GuiTableComposition* table=new GuiTableComposition;
			GetContainerComposition()->AddChild(table);
			table->SetAlignmentToParent(Margin(2, 2, 2, 2));
			table->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
			table->SetCellPadding(4);
			table->SetRowsAndColumns(3, 3);
			table->SetRowOption(0, GuiCellOption::MinSizeOption());
			table->SetRowOption(1, GuiCellOption::PercentageOption(1.0));
			table->SetRowOption(2, GuiCellOption::MinSizeOption());
			table->SetColumnOption(0, GuiCellOption::MinSizeOption());
			table->SetColumnOption(1, GuiCellOption::PercentageOption(1.0));
			table->SetColumnOption(2, GuiCellOption::MinSizeOption());
			{
				textTitle=g::NewTextBox();
				textTitle->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
				textTitle->GetBoundsComposition()->SetPreferredMinSize(Size(0, 30));
				textTitle->SetText(L"<请输入标题>");

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetSite(0, 0, 1, 3);
				cell->AddChild(textTitle->GetBoundsComposition());
			}
			{
				textBody=g::NewMultilineTextBox();
				textBody->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
				textBody->SetText(L"<请输入新帖子的内容>");

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetSite(1, 0, 1, 3);
				cell->AddChild(textBody->GetBoundsComposition());
			}
			{
				buttonPost=g::NewButton();
				buttonPost->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
				buttonPost->SetText(L"发帖");
				buttonPost->GetBoundsComposition()->SetPreferredMinSize(Size(80, 36));
				buttonPost->Clicked.AttachMethod(this, &NewPostWindow::buttonPost_Clicked);

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetSite(2, 0, 1, 1);
				cell->AddChild(buttonPost->GetBoundsComposition());
			}
			{
				buttonCancel=g::NewButton();
				buttonCancel->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
				buttonCancel->SetText(L"取消");
				buttonCancel->GetBoundsComposition()->SetPreferredMinSize(Size(80, 36));
				buttonCancel->Clicked.AttachMethod(this, &NewPostWindow::buttonCancel_Clicked);

				GuiCellComposition* cell=new GuiCellComposition;
				table->AddChild(cell);
				cell->SetSite(2, 2, 1, 1);
				cell->AddChild(buttonCancel->GetBoundsComposition());
			}
		}
	}
}