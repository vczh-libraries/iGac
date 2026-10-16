#include "../Mac/GraphicsElement/CoreGraphics/GuiCocoaElement.h"
#include "../Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h"
#include "../MacShared/FullControlTestRawElement.h"
#include "../MacShared/FullControlTestRawElementRemote.h"
#include <CoreGraphics/CoreGraphics.h>
#include <cstring>

using namespace vl;
using namespace vl::collections;
using namespace vl::presentation;
using namespace vl::presentation::elements;
using namespace vl::presentation::elements_coregraphics;
using namespace vl::presentation::compositions;
using namespace vl::presentation::remoteprotocol;
using namespace vl::presentation::remote_renderer;

class RawCocoaTarget : public ICoreGraphicsRenderTarget
{
public:
	Array<vuint8_t>		pixels{ 600 * 600 * 4 };
	CGContextRef		context = nullptr;

	CGContextRef GetCGContext() const override { return context; }
	vl::presentation::Size GetCanvasSize() override { return { 300,300 }; }
	void StartRenderingOnNativeWindow() override
	{
		memset(&pixels[0], 0, pixels.Count());
		auto colorSpace = CGColorSpaceCreateDeviceRGB();
		context = CGBitmapContextCreate(&pixels[0], 600, 600, 8, 600 * 4, colorSpace, static_cast<CGBitmapInfo>(kCGImageAlphaPremultipliedLast) | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		TEST_ASSERT(context);
		// Match the top-left logical coordinates used by Cocoa's flipped view.
		CGContextTranslateCTM(context, 0, 600);
		CGContextScaleCTM(context, 1, -1);
	}
	RenderTargetFailure StopRenderingOnNativeWindow() override
	{
		CGContextRelease(context);
		context = nullptr;
		return RenderTargetFailure::None;
	}
	void AfterPushedClipper(vl::presentation::Rect, vl::presentation::Rect area, reflection::DescriptableObject*) override
	{
		CGContextSaveGState(context);
		CGContextClipToRect(context, CGRectMake(area.x1, area.y1, area.Width(), area.Height()));
	}
	void AfterPushedClipperAndBecameInvalid(vl::presentation::Rect, reflection::DescriptableObject*) override {}
	void AfterPoppedClipperAndBecameValid(vl::presentation::Rect, bool, reflection::DescriptableObject*) override {}
	void AfterPoppedClipper(vl::presentation::Rect, bool, reflection::DescriptableObject*) override { CGContextRestoreGState(context); }

	vuint64_t PixelHash()
	{
		vuint64_t hash = 14695981039346656037ULL;
		for (auto value : pixels) hash = (hash ^ value) * 1099511628211ULL;
		return hash;
	}

	Color Pixel(vint x, vint y)
	{
		auto offset = (y * 600 + x) * 4;
		return Color(pixels[offset], pixels[offset + 1], pixels[offset + 2], pixels[offset + 3]);
	}
};

class RawNativeEvents : public Object, public IGuiRemoteProtocolEvents
{
public:
#define EVENT_NOREQ(NAME, REQUEST) void On ## NAME() override {}
#define EVENT_REQ(NAME, REQUEST) void On ## NAME(const REQUEST&) override {}
#define EVENT_HANDLER(NAME, REQUEST, REQTAG, ...) EVENT_ ## REQTAG(NAME, REQUEST)
	GACUI_REMOTEPROTOCOL_EVENTS(EVENT_HANDLER)
#undef EVENT_HANDLER
#undef EVENT_REQ
#undef EVENT_NOREQ
#define MESSAGE_NORES(NAME, RESPONSE)
#define MESSAGE_RES(NAME, RESPONSE) void Respond ## NAME(vint, const RESPONSE&) override {}
#define MESSAGE_HANDLER(NAME, REQUEST, RESPONSE, REQTAG, RESTAG, ...) MESSAGE_ ## RESTAG(NAME, RESPONSE)
	GACUI_REMOTEPROTOCOL_MESSAGES(MESSAGE_HANDLER)
#undef MESSAGE_HANDLER
#undef MESSAGE_RES
#undef MESSAGE_NORES
};

class RawNativeRenderer : public GuiRemoteRendererSingle
{
public:
	RawNativeRenderer(INativeWindow* nativeWindow) : GuiRemoteRendererSingle(true) { window = nativeWindow; }
	using GuiRemoteRendererSingle::AfterClosing;
	using GuiRemoteRendererSingle::DisconnectFromCore;
	using GuiRemoteRendererSingle::UpdateRenderTarget;
	using GuiRemoteRendererSingle::ForceRender;
	using GuiRemoteRendererSingle::needRefresh;
};

TEST_FILE
{
	TEST_CASE(L"Raw factory preserves concrete identity and common state in native and hosted modes")
	{
		auto element = GetGuiGraphicsResourceManager()->CreateRawElement().Cast<GuiCocoaElement>();
		TEST_ASSERT(element);
		TEST_ASSERT(dynamic_cast<GuiRawElementBase*>(element.Obj()));
		TEST_ASSERT(dynamic_cast<GuiCocoaElementRenderer*>(element->GetRenderer()));
		TEST_ASSERT(element->GetId() == L"" && element->GetData() == L"");
		TEST_ASSERT(element->GetRenderer()->GetMinSize() == vl::presentation::Size(0, 0));
		auto direct = vl::Ptr(GuiCocoaElement::Create());
		TEST_ASSERT(direct->GetRenderer()->GetFactory() == element->GetRenderer()->GetFactory());
		GuiBoundsComposition composition;
		composition.SetOwnedElement(element);
		TEST_ASSERT(element->GetOwnerComposition() == &composition);
		element->SetId(L"duplicate");
		direct->SetId(L"duplicate");
		element->SetData(L"12:34:56");
		element->SetData(L"12:34:56");
		TEST_ASSERT(element->GetId() == direct->GetId() && element->GetData() == L"12:34:56");
		element->SetId(L"");
		element->SetData(L"");
		TEST_ASSERT(element->GetId() == L"" && element->GetData() == L"");
		composition.SetOwnedElement(nullptr);
		TEST_ASSERT(!element->GetOwnerComposition());
	});

	TEST_CASE(L"Raw Quartz callback preserves clipping, transform, drawing state, text matrix and path")
	{
		auto element = vl::Ptr(GuiCocoaElement::Create());
		auto renderer = element->GetRenderer();
		RawCocoaTarget target;
		renderer->SetRenderTarget(&target);
		vint paints = 0;
		auto handler = element->Rendering.AttachLambda([&](GuiGraphicsComposition*, GuiCocoaElementEventArgs& args)
		{
			paints++;
			TEST_ASSERT(args.element == element.Obj() && args.context == target.GetCGContext());
			TEST_ASSERT(args.bounds == vl::presentation::Rect(10, 10, 110, 110));
			CGContextSetRGBFillColor(args.context, 1, 0, 0, 1);
			CGContextFillRect(args.context, CGRectMake(0, 0, 300, 300));
			CGContextTranslateCTM(args.context, 77, 88);
			CGContextScaleCTM(args.context, 3, 4);
			CGContextSetLineWidth(args.context, 23);
			CGContextSetTextMatrix(args.context, CGAffineTransformMakeScale(2, 3));
			CGContextClipToRect(args.context, CGRectMake(0, 0, 1, 1));
			CGContextMoveToPoint(args.context, 50, 60);
			CGContextAddLineToPoint(args.context, 70, 80);
		});
		renderer->Render({ 10,10,110,110 });
		TEST_ASSERT(paints == 0);
		for (vint scale : { 1,2 })
		{
			target.StartRendering();
			auto context = target.GetCGContext();
			CGContextScaleCTM(context, scale, scale);
			CGContextTranslateCTM(context, 5, 6);
			CGContextSetLineWidth(context, 6);
			CGContextSetRGBFillColor(context, 0, 1, 0, 1);
			CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
			auto textMatrix = CGAffineTransformMakeTranslation(13, 17);
			CGContextSetTextMatrix(context, textMatrix);
			CGContextMoveToPoint(context, 1, 2);
			CGContextAddLineToPoint(context, 3, 4);
			auto path = CGContextCopyPath(context);
			auto transform = CGContextGetCTM(context);
			renderer->Render({ 10,10,110,110 });
			TEST_ASSERT(CGAffineTransformEqualToTransform(CGContextGetCTM(context), transform));
			TEST_ASSERT(CGAffineTransformEqualToTransform(CGContextGetTextMatrix(context), textMatrix));
			auto restoredPath = CGContextCopyPath(context);
			TEST_ASSERT(CGPathEqualToPath(path, restoredPath));
			CGPathRelease(restoredPath);
			CGPathRelease(path);
			// The next element must keep its green paint, line width and unrestricted clip.
			CGContextBeginPath(context);
			CGContextFillRect(context, CGRectMake(150, 150, 10, 10));
			CGContextMoveToPoint(context, 180, 150);
			CGContextAddLineToPoint(context, 180, 170);
			CGContextStrokePath(context);
			TEST_ASSERT(target.Pixel(30 * scale, 30 * scale) == Color(255, 0, 0));
			TEST_ASSERT(target.Pixel(160 * scale, 160 * scale) == Color(0, 255, 0));
			TEST_ASSERT(target.Pixel(183 * scale, 160 * scale) == Color(0, 255, 0));
			TEST_ASSERT(target.Pixel(189 * scale, 160 * scale).a == 0);
			TEST_ASSERT(target.Pixel(5 * scale, 5 * scale).a == 0);
			auto count = paints;
			renderer->Render({ 400,400,450,450 });
			TEST_ASSERT(paints == count);
			target.StopRendering();
			TEST_ASSERT(!target.GetCGContext());
		}
		TEST_ASSERT(paints == 2);
		renderer->SetRenderTarget(nullptr);
		renderer->Render({ 10,10,110,110 });
		TEST_ASSERT(paints == 2);
		element->Rendering.Detach(handler);
	});

	TEST_CASE(L"Clock paints only valid received time and reattaches after target replacement")
	{
		auto element = vl::Ptr(GuiCocoaElement::Create());
		auto attachment = demo::AttachFullControlTestRawElement(element);
		RawCocoaTarget target;
		element->GetRenderer()->SetRenderTarget(&target);
		auto draw = [&]()
		{
			target.StartRendering();
			element->GetRenderer()->Render({ 0,0,240,240 });
			target.StopRendering();
			return target.PixelHash();
		};
		auto blank = draw();
		element->SetId(L"FullControlTest.Clock");
		for (auto data : { L"", L"24:00:00", L"12:60:00", L"12:00:60", L"1:23:45", L"aa:bb:cc" })
		{
			element->SetData(data);
			TEST_ASSERT(draw() == blank);
		}
		element->SetData(L"03:00:00");
		auto three = draw();
		TEST_ASSERT(three != blank && draw() == three);
		TEST_ASSERT(target.Pixel(170, 120) == Color(0, 255, 255));
		TEST_ASSERT(target.Pixel(120, 50) == Color(255, 255, 0));
		TEST_ASSERT(target.Pixel(80, 160).a == 0);
		element->SetData(L"06:30:45");
		TEST_ASSERT(draw() != three && draw() != blank);
		element->SetId(L"other");
		TEST_ASSERT(draw() == blank);
		element->SetId(L"FullControlTest.Clock");
		element->SetData(L"03:00:00");
		element->GetRenderer()->SetRenderTarget(nullptr);
		RawCocoaTarget replacement;
		element->GetRenderer()->SetRenderTarget(&replacement);
		attachment = nullptr;
		attachment = demo::AttachFullControlTestRawElement(element);
		replacement.StartRendering();
		element->GetRenderer()->Render({ 0,0,240,240 });
		replacement.StopRendering();
		TEST_ASSERT(replacement.PixelHash() == three);
		attachment = nullptr;
		replacement.StartRendering();
		element->GetRenderer()->Render({ 0,0,240,240 });
		replacement.StopRendering();
		TEST_ASSERT(replacement.PixelHash() == blank);
		element->GetRenderer()->SetRenderTarget(nullptr);
	});

	TEST_CASE(L"Native remote raw state, collection membership, data-only repaint and retained lifetime")
	{
		// GuiRemoteRendererSingle owns a real native window, rather than a hosted virtual window.
		if (GetHostedApplication()) return;
		auto service = GetCurrentController()->WindowService();
		auto native = service->CreateNativeWindow(INativeWindow::Normal);
		native->SetClientSize({ 300,300 });
		auto getContext = [&]()
		{
			return dynamic_cast<ICoreGraphicsRenderTarget*>(GetGuiGraphicsResourceManager()->GetRenderTarget(native))->GetCGContext();
		};
		RawNativeEvents responses;
		RawNativeRenderer renderer(native);
		renderer.Initialize(&responses);
		auto attachment = demo::AttachFullControlTestRawElements(renderer);
		vint installs = 0, changes = 0, uninstalls = 0, paints = 0;
		vl::Ptr<GuiCocoaElement> retained;
		WString expectedId, expectedData, paintedData;
		renderer.RawElementInstalled.Add([&](const GuiRemoteRawElementEventArgs& args)
		{
			TEST_ASSERT(renderer.GetRawElements().Contains(args.element.Obj()));
			TEST_ASSERT(args.element->GetId() == L"" && args.element->GetData() == L"");
			retained = args.element.Cast<GuiCocoaElement>();
			TEST_ASSERT(retained);
			installs++;
			retained->Rendering.AttachLambda([&](GuiGraphicsComposition*, GuiCocoaElementEventArgs& args)
			{
				TEST_ASSERT(args.context && args.context == getContext());
				paintedData = args.element->GetData();
				paints++;
			});
		});
		renderer.RawElementChanged.Add([&](const GuiRemoteRawElementEventArgs& args)
		{
			TEST_ASSERT(args.element->GetId() == expectedId && args.element->GetData() == expectedData);
			changes++;
		});
		renderer.RawElementUninstalled.Add([&](const GuiRemoteRawElementEventArgs& args)
		{
			TEST_ASSERT(renderer.GetRawElements().Contains(args.element.Obj()));
			uninstalls++;
		});
		auto create = vl::Ptr(new List<RendererCreation>);
		create->Add({ 41,RendererType::SolidBackground });
		create->Add({ 42,RendererType::Raw });
		renderer.RequestRendererCreated(create);
		auto first = retained;
		auto update = [&](vint id, const WString& name, const WString& data)
		{
			expectedId = name;
			expectedData = data;
			ElementBeginRendering begin;
			begin.updatedElements = vl::Ptr(new List<OrdinaryElementDescVariant>);
			begin.updatedElements->Add(ElementDesc_Raw{ id,name,data });
			renderer.RequestRendererBeginRendering(begin);
		};
		update(42, L"", L"");
		TEST_ASSERT(changes == 0);
		update(42, L"FullControlTest.Clock", L"03:00:00");
		TEST_ASSERT(changes == 1 && renderer.needRefresh);
		auto dom = vl::Ptr(new RenderingDom);
		dom->id = 1;
		dom->content.element = 41;
		dom->content.bounds = { 0,0,600,600 };
		dom->content.validArea = dom->content.bounds;
		auto clockDom = vl::Ptr(new RenderingDom);
		clockDom->id = 2;
		clockDom->content.element = 42;
		clockDom->content.bounds = { 0,0,240,240 };
		clockDom->content.validArea = clockDom->content.bounds;
		dom->children = vl::Ptr(new List<vl::Ptr<RenderingDom>>);
		dom->children->Add(clockDom);
		renderer.RequestRendererRenderDom(dom);
		renderer.RequestRendererEndRendering(1);
		TEST_ASSERT(paints > 0 && getContext() != nullptr);
		TEST_ASSERT(paintedData == L"03:00:00");
		auto count = paints;
		update(42, L"FullControlTest.Clock", L"06:30:45");
		renderer.RequestRendererEndRendering(2);
		TEST_ASSERT(paints > count && paintedData == L"06:30:45");
		count = paints;
		update(42, L"other", L"06:30:45");
		TEST_ASSERT(!renderer.needRefresh);
		renderer.RequestRendererEndRendering(3);
		TEST_ASSERT(paints == count && changes == 3);
		update(42, L"other", L"06:30:45");
		TEST_ASSERT(changes == 3);
		update(42, L"FullControlTest.Clock", L"03:00:00");
		attachment = nullptr;
		attachment = demo::AttachFullControlTestRawElements(renderer);
		renderer.RequestRendererEndRendering(4);
		TEST_ASSERT(paintedData == L"03:00:00");
		create->Clear();
		create->Add({ 43,RendererType::Raw });
		renderer.RequestRendererCreated(create);
		update(43, L"FullControlTest.Clock", L"03:00:00");
		TEST_ASSERT(renderer.GetRawElements().Count() == 2);
		update(43, L"", L"");
		renderer.UpdateRenderTarget(nullptr);
		GetGuiGraphicsResourceManager()->RecreateRenderTarget(native);
		renderer.UpdateRenderTarget(GetGuiGraphicsResourceManager()->GetRenderTarget(native));
		native->SetClientSize({ 400,360 });
		renderer.ForceRender();
		TEST_ASSERT(renderer.GetRawElements()[0] == first);
		create->Clear();
		create->Add({ 42,RendererType::Raw });
		renderer.RequestRendererCreated(create);
		TEST_ASSERT(installs == 3 && uninstalls == 1 && retained != first);
		count = paints;
		first->GetRenderer()->Render({ 0,0,240,240 });
		TEST_ASSERT(paints == count);
		auto destroyed = vl::Ptr(new List<vint>);
		destroyed->Add(43);
		renderer.RequestRendererDestroyed(destroyed);
		TEST_ASSERT(uninstalls == 2);
		update(42, L"FullControlTest.Clock", L"03:00:00");
		renderer.RequestRendererEndRendering(5);
		TEST_ASSERT(paintedData == L"03:00:00");
		count = paints;
		renderer.DisconnectFromCore();
		TEST_ASSERT(renderer.GetRawElements().Count() == 1 && uninstalls == 2);
		renderer.ForceRender();
		TEST_ASSERT(paints > count && paintedData == L"03:00:00");
		count = paints;
		renderer.RetainByFatalError(L"Raw clock retained-picture test");
		TEST_ASSERT(paints > count && getContext() != nullptr);
		TEST_ASSERT(renderer.GetRawElements()[0] == retained && retained->GetData() == L"03:00:00");
		TEST_ASSERT(uninstalls == 2);
		renderer.AfterClosing();
		TEST_ASSERT(renderer.GetRawElements().Count() == 0 && uninstalls == 3);
		attachment = nullptr;
		service->DestroyNativeWindow(native);
		count = paints;
		retained->GetRenderer()->Render({ 0,0,240,240 });
		TEST_ASSERT(paints == count);
	});
}

int rawTestArgc = 0;
char** rawTestArgv = nullptr;
int rawTestResult = 0;

void GuiMain()
{
	rawTestResult = unittest::UnitTest::RunAndDisposeTests(rawTestArgc, rawTestArgv);
}

int main(int argc, char* argv[])
{
	auto hosted = argc > 1 && std::strcmp(argv[argc - 1], "--hosted") == 0;
	rawTestArgc = argc - (hosted ? 1 : 0);
	rawTestArgv = argv;
	auto result = hosted ? SetupOSXHostedCoreGraphicsRenderer() : SetupOSXCoreGraphicsRenderer();
	return result == 0 ? rawTestResult : result;
}
