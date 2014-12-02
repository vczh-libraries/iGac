/***********************************************************************
Vczh Library++ 3.0
Developer: 陈梓瀚(vczh)
GacUI::MainWindow

本文件使用Vczh GacUI Resource Code Generator工具自动生成
***********************************************************************/

#include "GacStudioUI.h"

namespace ui
{
	// #region CLASS_MEMBER_GUIEVENT_HANDLER (DO NOT PUT OTHER CONTENT IN THIS #region.)

	void MainWindow::cellSplitter_leftButtonDown(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiMouseEventArgs& arguments)
	{
		splitterDragging = true;
		splitterPosition = cellSplitter->GetGlobalBounds().Left() + arguments.x;
	}

	void MainWindow::cellSplitter_leftButtonUp(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiMouseEventArgs& arguments)
	{
		splitterDragging = false;
	}

	void MainWindow::cellSplitter_mouseMove(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiMouseEventArgs& arguments)
	{
		if (splitterDragging)
		{
			vint delta = cellSplitter->GetGlobalBounds().Left() + arguments.x - splitterPosition;
			splitterPosition += delta;

			auto option = tableMain->GetColumnOption(0);
			option.absolute += delta;
			tableMain->SetColumnOption(0, option);
			tableMain->ForceCalculateSizeImmediately();
		}
	}

	void MainWindow::commandFileExit_Executed(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiEventArgs& arguments)
	{
		Close();
	}

	void MainWindow::commandFileNewFile_Executed(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiEventArgs& arguments)
	{
		auto window = new NewFileWindow(GetViewModel());
		window->ForceCalculateSizeImmediately();
		window->MoveToScreenCenter();
		window->ShowModalAndDelete(this, []()
		{
		});
	}

	void MainWindow::commandFileNewProject_Executed(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiEventArgs& arguments)
	{
		auto window = new NewProjectWindow(GetViewModel());
		window->ForceCalculateSizeImmediately();
		window->MoveToScreenCenter();
		window->ShowModalAndDelete(this, []()
		{
		});
	}

	void MainWindow::commandFileOpenFile_Executed(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiEventArgs& arguments)
	{
	}

	void MainWindow::commandFileOpenProject_Executed(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiEventArgs& arguments)
	{
	}

	void MainWindow::commandFileSaveAll_Executed(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiEventArgs& arguments)
	{
	}

	void MainWindow::commandFileSave_Executed(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiEventArgs& arguments)
	{
	}

	void MainWindow::commandHelpAbout_Executed(GuiGraphicsComposition* sender, vl::presentation::compositions::GuiEventArgs& arguments)
	{
		auto window = new AboutWindow(GetViewModel());
		window->ForceCalculateSizeImmediately();
		window->MoveToScreenCenter();
		window->ShowModalAndDelete(this, []()
		{
		});
	}

	// #endregion CLASS_MEMBER_GUIEVENT_HANDLER

	MainWindow::MainWindow(Ptr<vm::IStudioModel> ViewModel)
	{
		InitializeComponents(ViewModel);
		cellSplitter->SetAssociatedCursor(GetCurrentController()->ResourceService()->GetSystemCursor(INativeCursor::SizeWE));
	}
}
