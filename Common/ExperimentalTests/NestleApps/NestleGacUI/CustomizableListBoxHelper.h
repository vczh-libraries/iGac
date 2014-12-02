#ifndef VCZH_NESTLECLIENT_CONTROLS_CUSTOMIZABLELISTBOXHELPER
#define VCZH_NESTLECLIENT_CONTROLS_CUSTOMIZABLELISTBOXHELPER

#include "..\..\..\..\Libraries\GacUI\Public\Source\GacUIIncludes.h"

namespace vl
{
	namespace presentation
	{
		namespace controls
		{

/***********************************************************************
Predefined ItemStyle
***********************************************************************/

			namespace list
			{
				class ObjectItemControl : public GuiControl, public Description<ObjectItemControl>
				{
				public:
					class IFactory : public Interface
					{
					public:
						virtual ObjectItemControl*				Create()=0;
					};

					ObjectItemControl(GuiControl::IStyleController* _styleController=0);
					~ObjectItemControl();

					virtual void								Install(Ptr<Object> value)=0;
				};

				class ObjectItemStyleProvider : public Object, public GuiSelectableListControl::IItemStyleProvider, public Description<ObjectItemStyleProvider>
				{
				public:
					class IObjectItemView : public IDescriptable, public Description<IObjectItemView>
					{
					public:
						static const wchar_t* const				Identifier;

						virtual Ptr<Object>						GetObject(int itemIndex)=0;
					};
				protected:
					class ObjectItemStyleController : public ItemStyleControllerBase, public Description<ObjectItemStyleController>
					{
					protected:
						GuiSelectableButton*					backgroundButton;
						ObjectItemStyleProvider*				provider;
						ObjectItemControl*						control;

					public:
						ObjectItemStyleController(ObjectItemStyleProvider* _provider, ObjectItemControl* _control);
						~ObjectItemStyleController();

						void									Install(Ptr<Object> value);
						void									SetSelected(bool value);
					};

					GuiListControl*								listControl;
					IObjectItemView*							objectItemView;
					ObjectItemControl::IFactory*				objectItemControlFactory;
					bool										selectable;
				public:
					ObjectItemStyleProvider(ObjectItemControl::IFactory* _objectItemControlFactory, bool _selectable);
					~ObjectItemStyleProvider();

					void										AttachListControl(GuiListControl* value)override;
					void										DetachListControl()override;
					int											GetItemStyleId(int itemIndex)override;
					GuiListControl::IItemStyleController*		CreateItemStyle(int styleId)override;
					void										DestroyItemStyle(GuiListControl::IItemStyleController* style)override;
					void										Install(GuiListControl::IItemStyleController* style, int itemIndex)override;
					void										SetStyleSelected(GuiListControl::IItemStyleController* style, bool value)override;
				};

				class ObjectItemProvider : public ListProvider<Ptr<Object>>, private ObjectItemStyleProvider::IObjectItemView, public Description<ObjectItemProvider>
				{
				private:
					Ptr<Object>									GetObject(int itemIndex)override;
				public:
					ObjectItemProvider();
					~ObjectItemProvider();

					IDescriptable*								RequestView(const WString& identifier)override;
					void										ReleaseView(IDescriptable* view)override;
				};
			}

			class GuiListControlTemplateBase : public GuiSelectableListControl, public Description<GuiListControlTemplateBase>
			{
			protected:
				list::ObjectItemProvider*						itemProvider;
				list::ObjectItemStyleProvider*					itemStyleProvider;
			public:
				GuiListControlTemplateBase(list::ObjectItemControl::IFactory* objectItemControlFactory, bool selectable);
				~GuiListControlTemplateBase();

				list::ObjectItemProvider&						GetItems();
			};

			template<typename T>
			class GuiListControlTemplate : public GuiListControlTemplateBase
			{
			protected:
				class ItemFactory : public list::ObjectItemControl::IFactory
				{
				public:
					list::ObjectItemControl* Create()override
					{
						return new T;
					}
				};
			public:
				GuiListControlTemplate(bool selectable)
					:GuiListControlTemplateBase(new ItemFactory, selectable)
				{
				}
			};
		}
	}
}

#endif