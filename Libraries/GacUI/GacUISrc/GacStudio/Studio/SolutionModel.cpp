#include "SolutionModel.h"

using namespace vl::reflection::description;

namespace vm
{
	WString GetDisplayNameFromFilePath(WString filePath)
	{
		auto index = INVLOC.FindLast(filePath, L"\\", Locale::None);
		if (index.key == -1)
		{
			return filePath;
		}
		else
		{
			return filePath.Sub(index.key + 1, filePath.Length() - index.key - 1);
		}
	}

/***********************************************************************
ProjectItem
***********************************************************************/

	ProjectItem::ProjectItem(Ptr<IProjectFactoryModel> _projectFactory, WString _filePath)
		:projectFactory(_projectFactory)
		, filePath(_filePath)
	{
	}

	ProjectItem::~ProjectItem()
	{
	}
		
	bool ProjectItem::OpenProject()
	{
		return false;
	}

	bool ProjectItem::SaveProject()
	{
		return false;
	}

	bool ProjectItem::NewProject()
	{
		return false;
	}

	Ptr<GuiImageData> ProjectItem::GetImage()
	{
		return projectFactory->GetSmallImage();
	}

	WString ProjectItem::GetName()
	{
		return GetDisplayNameFromFilePath(filePath);
	}

	Ptr<description::IValueObservableList> ProjectItem::GetChildren()
	{
		return children.GetWrapper();
	}

/***********************************************************************
SolutionItem
***********************************************************************/

	SolutionItem::SolutionItem(Ptr<IProjectFactoryModel> _projectFactory, WString _filePath)
		:projectFactory(_projectFactory)
		, filePath(_filePath)
	{
	}

	SolutionItem::~SolutionItem()
	{
	}
		
	bool SolutionItem::OpenSolution()
	{
		return false;
	}

	bool SolutionItem::SaveSolution()
	{
		return false;
	}

	bool SolutionItem::NewSolution()
	{
		return false;
	}

	Ptr<GuiImageData> SolutionItem::GetImage()
	{
		return projectFactory->GetSmallImage();
	}

	WString SolutionItem::GetName()
	{
		return GetDisplayNameFromFilePath(filePath);
	}

	Ptr<description::IValueObservableList> SolutionItem::GetChildren()
	{
		return projects.GetWrapper();
	}
}