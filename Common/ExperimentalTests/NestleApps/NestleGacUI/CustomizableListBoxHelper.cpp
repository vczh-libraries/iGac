#include "CustomizableListBoxHelper.h"

namespace vl
{
	namespace presentation
	{
		namespace controls
		{
			namespace list
			{
				const wchar_t* const ObjectItemStyleProvider::IObjectItemView::Identifier=L"vl::presentation::controls::list::IObjectItemView";

/***********************************************************************
ObjectItemControl
***********************************************************************/

				ObjectItemControl::ObjectItemControl(GuiControl::IStyleController* _styleController)
					:GuiControl(_styleController?_styleController:new GuiControl::EmptyStyleController)
				{
				}

				ObjectItemControl::~ObjectItemControl()
				{
				}

/***********************************************************************
ObjectItemStyleProvider::ObjectItemStyleController
***********************************************************************/

				ObjectItemStyleProvider::ObjectItemStyleController::ObjectItemStyleController(ObjectItemStyleProvider* _provider, ObjectItemControl* _control)
					:ItemStyleControllerBase(_provider, 0)
					,backgroundButton(0)
					,provider(_provider)
					,control(_control)
				{
					if(provider->selectable)
					{
						backgroundButton=new GuiSelectableButton(GetCurrentTheme()->CreateListItemBackgroundStyle());
						control->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
						backgroundButton->AddChild(control);
						Initialize(backgroundButton->GetBoundsComposition(), backgroundButton);
					}
					else
					{
						Initialize(control->GetBoundsComposition(), control);
					}
				}

				ObjectItemStyleProvider::ObjectItemStyleController::~ObjectItemStyleController()
				{
				}

				void ObjectItemStyleProvider::ObjectItemStyleController::Install(Ptr<Object> value)
				{
					control->Install(value);
				}

				void ObjectItemStyleProvider::ObjectItemStyleController::SetSelected(bool value)
				{
					if(backgroundButton)
					{
						backgroundButton->SetSelected(value);
					}
				}

/***********************************************************************
ObjectItemStyleProvider
***********************************************************************/
				
				ObjectItemStyleProvider::ObjectItemStyleProvider(ObjectItemControl::IFactory* _objectItemControlFactory, bool _selectable)
					:listControl(0)
					,objectItemView(0)
					,objectItemControlFactory(_objectItemControlFactory)
					,selectable(_selectable)
				{
				}

				ObjectItemStyleProvider::~ObjectItemStyleProvider()
				{
				}

				void ObjectItemStyleProvider::AttachListControl(GuiListControl* value)
				{
					listControl=value;
					objectItemView=dynamic_cast<IObjectItemView*>(listControl->GetItemProvider()->RequestView(IObjectItemView::Identifier));
				}

				void ObjectItemStyleProvider::DetachListControl()
				{
					if(listControl && objectItemView)
					{
						listControl->GetItemProvider()->ReleaseView(objectItemView);
					}
					listControl=0;
					objectItemView=0;
				}

				int ObjectItemStyleProvider::GetItemStyleId(int itemIndex)
				{
					return 0;
				}

				GuiListControl::IItemStyleController* ObjectItemStyleProvider::CreateItemStyle(int styleId)
				{
					ObjectItemControl* control=objectItemControlFactory->Create();
					return new ObjectItemStyleController(this, control);
				}

				void ObjectItemStyleProvider::DestroyItemStyle(GuiListControl::IItemStyleController* style)
				{
					ObjectItemStyleController* styleController=dynamic_cast<ObjectItemStyleController*>(style);
					delete styleController;
				}

				void ObjectItemStyleProvider::Install(GuiListControl::IItemStyleController* style, int itemIndex)
				{
					ObjectItemStyleController* styleController=dynamic_cast<ObjectItemStyleController*>(style);
					styleController->Install(objectItemView->GetObject(itemIndex));
				}

				void ObjectItemStyleProvider::SetStyleSelected(GuiListControl::IItemStyleController* style, bool value)
				{
				}

/***********************************************************************
ObjectItemProvider
***********************************************************************/

				Ptr<Object> ObjectItemProvider::GetObject(int itemIndex)
				{
					return Get(itemIndex);
				}

				ObjectItemProvider::ObjectItemProvider()
				{
				}

				ObjectItemProvider::~ObjectItemProvider()
				{
				}

				IDescriptable* ObjectItemProvider::RequestView(const WString& identifier)
				{
					if(identifier==ObjectItemStyleProvider::IObjectItemView::Identifier)
					{
						return (ObjectItemStyleProvider::IObjectItemView*)this;
					}
					else
					{
						return 0;
					}
				}

				void ObjectItemProvider::ReleaseView(IDescriptable* view)
				{
				}
			}

/***********************************************************************
GuiListControlTemplateBase
***********************************************************************/

			GuiListControlTemplateBase::GuiListControlTemplateBase(list::ObjectItemControl::IFactory* objectItemControlFactory, bool selectable)
				:GuiSelectableListControl(GetCurrentTheme()->CreateTextListStyle(), new list::ObjectItemProvider)
			{
				itemProvider=dynamic_cast<list::ObjectItemProvider*>(GetItemProvider());
				itemStyleProvider=new list::ObjectItemStyleProvider(objectItemControlFactory, selectable);
				SetStyleProvider(itemStyleProvider);
				SetArranger(new list::FixedHeightItemArranger);
			}

			GuiListControlTemplateBase::~GuiListControlTemplateBase()
			{
			}

			list::ObjectItemProvider& GuiListControlTemplateBase::GetItems()
			{
				return *itemProvider;
			}
		}
	}
}