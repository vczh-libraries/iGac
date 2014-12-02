/***********************************************************************
Vczh Library++ 3.0
Developer: ³Âè÷å«(vczh)
GacStudio::StudioModel

Interfaces:
***********************************************************************/

#ifndef GACSTUDIO_STUDIO_STUDIOMODEL
#define GACSTUDIO_STUDIO_STUDIOMODEL

#include "..\UI\GacStudioUI.h"

using namespace vl::collections;

namespace vm
{
	class FileFactoryModelBase : public Object, public virtual IFileFactoryModel
	{
	protected:
		Ptr<GuiImageData>								image;
		WString											name;
		WString											category;
		WString											description;
		WString											id;

	public:
		FileFactoryModelBase(WString _imageUrl, WString _name, WString _category, WString _description, WString _id);
		~FileFactoryModelBase();

		Ptr<GuiImageData>								GetImage()override;
		WString											GetName()override;
		WString											GetCategory()override;
		WString											GetDescription()override;
		WString											GetId()override;
	};

	class ProjectFactoryModelBase : public Object, public virtual IProjectFactoryModel
	{
	protected:
		Ptr<GuiImageData>								image;
		Ptr<GuiImageData>								smallImage;
		WString											name;
		WString											description;
		WString											id;

	public:
		ProjectFactoryModelBase(WString _imageUrl, WString _smallImageUrl, WString _name, WString _description, WString _id);
		~ProjectFactoryModelBase();

		Ptr<GuiImageData>								GetImage()override;
		Ptr<GuiImageData>								GetSmallImage()override;
		WString											GetName()override;
		WString											GetDescription()override;
		WString											GetId()override;
		LazyList<Ptr<IProjectFactoryModel>>				GetChildren()override;
	};

	class FileFactoryFilterModel : public ProjectFactoryModelBase
	{
	protected:
		List<Ptr<ProjectFactoryModelBase>>				children;

	public:
		FileFactoryFilterModel();
		~FileFactoryFilterModel();

		void											AddChild(Ptr<ProjectFactoryModelBase> child);
		LazyList<Ptr<IProjectFactoryModel>>				GetChildren()override;
	};

	class RootSolutionItemModel : public Object, public virtual ISolutionItemModel
	{
	protected:
		list::ObservableList<Ptr<ISolutionItemModel>>	children;

	public:
		Ptr<GuiImageData>								GetImage()override;
		WString											GetName()override;
		Ptr<description::IValueObservableList>			GetChildren()override;
		
		Ptr<ISolutionItemModel>							GetSolution();
		void											SetSolution(Ptr<ISolutionItemModel> solution);
	};

	class StudioModel : public Object, public virtual IStudioModel
	{
	protected:
		Ptr<FileFactoryFilterModel>						fileFilters;
		List<Ptr<IFileFactoryModel>>					fileFactories;
		WString											fileCategory;
		list::ObservableList<Ptr<IFileFactoryModel>>	filteredFileFactories;
		Ptr<RootSolutionItemModel>						openingSolution;

	public:
		StudioModel();
		~StudioModel();

		LazyList<Ptr<IProjectFactoryModel>>				GetProjectModels()override;
		Ptr<description::IValueObservableList>			GetFileModels()override;
		Ptr<IProjectFactoryModel>						GetFileFilters()override;

		WString											GetFileCategory()override;
		void											SetFileCategory(WString value)override;

		Ptr<ISolutionItemModel>							GetOpeningSolution()override;
		bool											GetHasOpeningSolution()override;

		bool											OpenSolution(WString filePath)override;
		bool											SaveSolution()override;
		bool											NewSolution(WString filePath)override;
		bool											CloseSolution()override;
		bool											AddProject(Ptr<vm::IProjectFactoryModel> projectFactory, WString projectName)override;

		void											OpenBrowser(WString url)override;
	};
}

#endif