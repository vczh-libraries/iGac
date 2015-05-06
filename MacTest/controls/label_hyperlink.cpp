
#ifndef GacOSX_label_hyperlink_h
#define GacOSX_label_hyperlink_h

#include "../shared/gac_include.h"
#include "../shared/osx_shared.h"

class HyperlinkWindow : public GuiWindow
{
private:
    GuiLabel*				labelHyperlink;
    
    void labelHyperlink_OnMouseEnter(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
    {
        FontProperties font=labelHyperlink->GetFont();
        font.underline=true;
        labelHyperlink->SetFont(font);
    }
    
    void labelHyperlink_OnMouseLeave(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
    {
        FontProperties font=labelHyperlink->GetFont();
        font.underline=false;
        labelHyperlink->SetFont(font);
    }
    
    void labelHyperlink_OnLeftButtonDown(GuiGraphicsComposition* sender, GuiMouseEventArgs& arguments)
    {
        osx::LaunchURL(L"http://darkfall.me");
    }
    
public:
    HyperlinkWindow()
    :GuiWindow(GetCurrentTheme()->CreateWindowStyle())
    {
        this->SetText(L"Controls.Label.Hyperlink");
        this->SetClientSize(Size(300, 200));
        this->MoveToScreenCenter();
        
        labelHyperlink=g::NewLabel();
        labelHyperlink->SetText(L"http://darkfall.me");
        labelHyperlink->SetTextColor(Color(0, 0, 255));
        {
            FontProperties font;
            font.fontFamily=L"Segoe UI";
            font.size=18;
            font.antialias=true;
            labelHyperlink->SetFont(font);
        }
        {
            INativeCursor* hand=GetCurrentController()->ResourceService()->GetSystemCursor(INativeCursor::Hand);
            labelHyperlink->GetBoundsComposition()->SetAssociatedCursor(hand);
        }
        labelHyperlink->GetEventReceiver()->mouseEnter.AttachMethod(this, &HyperlinkWindow::labelHyperlink_OnMouseEnter);
        labelHyperlink->GetEventReceiver()->mouseLeave.AttachMethod(this, &HyperlinkWindow::labelHyperlink_OnMouseLeave);
        labelHyperlink->GetEventReceiver()->leftButtonDown.AttachMethod(this, &HyperlinkWindow::labelHyperlink_OnLeftButtonDown);
        this->AddChild(labelHyperlink);
    }
    
    ~HyperlinkWindow()
    {
    }
};

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}

void GuiMain()
{
    RunGacWindow<HyperlinkWindow>();
}
#endif