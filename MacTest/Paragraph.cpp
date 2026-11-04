#include "../Mac/GraphicsElement/CoreGraphics/GuiGraphicsLayoutProviderCoreText.h"
#include "../Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h"

using namespace vl;
using namespace vl::presentation;
using namespace vl::presentation::elements;
using namespace vl::presentation::elements_coregraphics;
using namespace vl::presentation::compositions;

TEST_FILE
{
    TEST_CASE(L"Ellipsized captions fit their requested bounds and restore natural sizing")
    {
        auto label = Ptr(GuiSolidLabelElement::Create());
        FontProperties font;
        font.fontFamily = L"Helvetica";
        font.size = 14;
        label->SetFont(font);
        label->SetText(L"A long window caption that must truncate inside the compact window");
        GuiBoundsComposition composition;
        composition.SetMinSizeLimitation(GuiGraphicsComposition::LimitToElement);
        composition.SetExpectedBounds(Rect(0, 0, 240, 40));
        composition.SetOwnedElement(label);
        composition.ForceCalculateSizeImmediately();
        auto naturalWidth = composition.GetCachedBounds().Width();
        TEST_ASSERT(naturalWidth > 240);
        label->SetEllipse(true);
        composition.ForceCalculateSizeImmediately();
        TEST_ASSERT(composition.GetCachedBounds().Width() == 240);
        TEST_ASSERT(label->GetRenderer()->GetMinSize().y > 0);
        label->SetEllipse(false);
        composition.ForceCalculateSizeImmediately();
        TEST_ASSERT(composition.GetCachedBounds().Width() == naturalWidth);
    });

    TEST_CASE(L"Reapply and reset distinct inline images in one paragraph")
    {
        CoreTextLayoutProvider provider;
        auto paragraph = provider.CreateParagraph(L"A😀[first][second] tail", nullptr, nullptr);
        IGuiGraphicsParagraph::InlineObjectProperties first, second;
        first.backgroundImage = Ptr(GuiSolidBackgroundElement::Create());
        second.backgroundImage = Ptr(GuiSolidBackgroundElement::Create());
        first.size = {20, 20};
        second.size = {30, 30};
        TEST_ASSERT(paragraph->SetInlineObject(2, 7, first));
        TEST_ASSERT(paragraph->SetInlineObject(9, 8, second));
        first.size = {25, 25};
        second.size = {35, 35};
        TEST_ASSERT(paragraph->SetInlineObject(2, 7, first));
        TEST_ASSERT(paragraph->SetInlineObject(9, 8, second));
        TEST_ASSERT(!paragraph->SetInlineObject(17, 2, first));
        TEST_ASSERT(!paragraph->ResetInlineObject(3, 6));
        TEST_ASSERT(paragraph->ResetInlineObject(2, 7));
        TEST_ASSERT(!paragraph->ResetInlineObject(2, 7));
        TEST_ASSERT(paragraph->SetInlineObject(17, 2, first));
        TEST_ASSERT(paragraph->ResetInlineObject(9, 8));
        TEST_ASSERT(paragraph->SetInlineObject(2, 7, second));
        TEST_ASSERT(paragraph->GetSize().y > 0);
    });
}

int testArgc;
char** testArgv;
int testResult;
void GuiMain()
{
    testResult = unittest::UnitTest::RunAndDisposeTests(testArgc, testArgv);
}
int main(int argc, char* argv[])
{
    testArgc = argc;
    testArgv = argv;
    auto result = SetupOSXCoreGraphicsRenderer();
    return result == 0 ? testResult : result;
}
