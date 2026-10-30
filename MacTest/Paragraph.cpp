#include "../Mac/GraphicsElement/CoreGraphics/GuiGraphicsLayoutProviderCoreText.h"
#include "../Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h"

using namespace vl;
using namespace vl::presentation;
using namespace vl::presentation::elements;
using namespace vl::presentation::elements_coregraphics;

TEST_FILE
{
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
