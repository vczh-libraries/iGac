#include "..\..\Public\Source\GacUI.h"

GuiGraphicsComposition* CreateWrapLineText(const WString& text)
{
	GuiSolidLabelElement* textElement=GuiSolidLabelElement::Create();
	textElement->SetWrapLine(true);
	textElement->SetWrapLineHeightCalculation(true);
	textElement->SetText(text);
	textElement->SetFont(GetCurrentController()->ResourceService()->GetDefaultFont());

	GuiBoundsComposition* textComposition=new GuiBoundsComposition;
	textComposition->SetOwnedElement(textElement);
	textComposition->SetAlignmentToParent(Margin(0, 0, 0, 0));
	textComposition->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);

	GuiSolidBorderElement* borderElement=GuiSolidBorderElement::Create();
	borderElement->SetColor(Color(0, 0, 255));

	GuiBoundsComposition* borderComposition=new GuiBoundsComposition;
	borderComposition->SetOwnedElement(borderElement);
	borderComposition->SetAlignmentToParent(Margin(10, 10, 10, 10));
	borderComposition->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	borderComposition->AddChild(textComposition);

	return borderComposition;
}

void SetupSolidLabelElementLayoutWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	container->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);

	const wchar_t* texts[]=
	{
		L"When using ReadFileEx you should check GetLastError even when the function returns \"success\" to check for conditions that are \"successes\" but have some outcome you might want to know about. For example, a buffer overflow when calling ReadFileEx will return TRUE, but GetLastError will report the overflow with ERROR_MORE_DATA. If the function call is successful and there are no warning conditions, GetLastError will return ERROR_SUCCESS.",
		L"The ReadFileEx function may fail if there are too many outstanding asynchronous I/O requests. In the event of such a failure, GetLastError can return ERROR_INVALID_USER_BUFFER or ERROR_NOT_ENOUGH_MEMORY.",
		L"To cancel all pending asynchronous I/O operations, use either: ",
		L"CancelIo¡ªthis function only cancels operations issued by the calling thread for the specified file handle.",
		L"CancelIoEx¡ªthis function cancels all operations issued by the threads for the specified file handle.",
	};
	const int rowCount=sizeof(texts)/sizeof(*texts);

	GuiTableComposition* table=new GuiTableComposition;
	table->SetAlignmentToParent(Margin(0, 0, 0, 0));
	table->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	table->SetRowsAndColumns(1, 2);
	table->SetRowOption(0, GuiCellOption::MinSizeOption());
	table->SetColumnOption(0, GuiCellOption::PercentageOption(0.5));
	table->SetColumnOption(1, GuiCellOption::PercentageOption(0.5));
	{
		GuiStackComposition* sub=new GuiStackComposition;
		sub->SetDirection(GuiStackComposition::Vertical);
		sub->SetAlignmentToParent(Margin(0, 0, 0, 0));
		sub->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
		for(int i=0;i<rowCount;i++)
		{
			GuiStackItemComposition* item=new GuiStackItemComposition;
			item->AddChild(CreateWrapLineText(texts[i]));
			sub->AddChild(item);
		}

		GuiCellComposition* cell=new GuiCellComposition;
		table->AddChild(cell);
		cell->SetSite(0, 0, 1, 1);
		cell->AddChild(sub);
	}
	{
		GuiTableComposition* sub=new GuiTableComposition;
		sub->SetAlignmentToParent(Margin(0, 0, 0, 0));
		sub->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
		sub->SetRowsAndColumns(rowCount, 1);
		sub->SetColumnOption(0, GuiCellOption::PercentageOption(1.0));
		for(int i=0;i<rowCount;i++)
		{
			sub->SetRowOption(i, GuiCellOption::MinSizeOption());
		}
		for(int i=0;i<rowCount;i++)
		{
			GuiCellComposition* cell=new GuiCellComposition;
			sub->AddChild(cell);
			cell->SetSite(i, 0, 1, 1);
			cell->AddChild(CreateWrapLineText(texts[i]));
		}

		GuiCellComposition* cell=new GuiCellComposition;
		table->AddChild(cell);
		cell->SetSite(0, 1, 1, 1);
		cell->AddChild(sub);
	}

	container->AddChild(table);
}