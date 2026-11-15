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

class RawInterpretorState : public Object
{
public:
	vint								created = 0;
	vint								initialized = 0;
	vint								finalized = 0;
	vint								destroyed = 0;
	vint								attachedAtDestruction = 0;
	vint								painted = 0;
	List<GuiCocoaElement*>			live;
	List<Pair<WString, WString>>		initialValues;
};

class CountingRawInterpretor : public Object, public IGuiGraphicsRawInterpretor
{
protected:
	vl::Ptr<RawInterpretorState>			state;
	GuiCocoaElement*					element = nullptr;
	vl::Ptr<IGuiGraphicsEventHandler>	handler;
public:
	CountingRawInterpretor(vl::Ptr<RawInterpretorState> _state) : state(_state)
	{
		state->created++;
	}

	~CountingRawInterpretor()
	{
		if (handler) state->attachedAtDestruction++;
		state->destroyed++;
	}

	void Initialize(IGuiGraphicsElement* value) override
	{
		element = dynamic_cast<GuiCocoaElement*>(value);
		state->initialized++;
		TEST_ASSERT(!state->live.Contains(element));
		state->live.Add(element);
		state->initialValues.Add({ element->GetInterpretor(), element->GetData() });
		handler = element->Rendering.AttachLambda([this](GuiGraphicsComposition*, GuiCocoaElementEventArgs&) { state->painted++; });
	}

	void Finalize() override
	{
		TEST_ASSERT(state->live.Remove(element));
		TEST_ASSERT(element->Rendering.Detach(handler));
		handler = nullptr;
		state->finalized++;
	}
};

class CountingRawInterpretorFactory : public Object, public IGuiGraphicsRawInterpretorFactory
{
protected:
	vl::Ptr<RawInterpretorState>			state;
public:
	CountingRawInterpretorFactory(vl::Ptr<RawInterpretorState> _state) : state(_state) {}
	IGuiGraphicsRawInterpretor* Create() override { return new CountingRawInterpretor(state); }
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
		TEST_ASSERT(element->GetInterpretor() == L"");
		// The application plugin has loaded before GuiMain, also through the hosted manager.
		TEST_ASSERT(GetGuiGraphicsResourceManager()->GetRawInterpretorFactory(L"FullControlTest::Clock"));
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

	TEST_CASE(L"Named Cocoa interpretors own independent handlers and finalize exactly once")
	{
		auto manager = GetGuiGraphicsResourceManager();
		auto state = vl::Ptr(new RawInterpretorState);
		auto factory = vl::Ptr(new CountingRawInterpretorFactory(state));
		manager->RegisterRawInterpretorFactory(L"RawTest::A", factory);
		manager->RegisterRawInterpretorFactory(L"RawTest::B", factory);
		auto nativeManager = dynamic_cast<IGuiGraphicsResourceManager*>(GetCoreGraphicsResourceManager());
		TEST_ASSERT(nativeManager->GetRawInterpretorFactory(L"RawTest::A") == factory.Obj());
		TEST_ASSERT(nativeManager->GetRawInterpretorFactory(L"FullControlTest::Clock") == manager->GetRawInterpretorFactory(L"FullControlTest::Clock"));
		TEST_ERROR(manager->RegisterRawInterpretorFactory(L"RawTest::A", factory));
		{
			auto raw = manager->CreateRawElement().Cast<GuiRawElementBase>();
			raw->SetId(L"RawTest::A");
			raw->SetData(L"before");
			TEST_ASSERT(state->created == 0);
			raw->SetInterpretorAndData(L"RawTest::A", L"first");
			TEST_ASSERT(state->created == 1 && state->initialized == 1);
			TEST_ASSERT(state->initialValues[0].key == L"RawTest::A" && state->initialValues[0].value == L"first");
			raw->SetData(L"data only");
			raw->SetId(L"");
			raw->SetInterpretor(L"RawTest::A");
			raw->SetInterpretorAndData(L"RawTest::A", L"data only");
			TEST_ASSERT(state->created == 1 && state->finalized == 0);
			raw->SetInterpretorAndData(L"RawTest::B", L"second");
			TEST_ASSERT(state->created == 2 && state->finalized == 1 && state->destroyed == 1);
			TEST_ASSERT(state->initialValues[1].key == L"RawTest::B" && state->initialValues[1].value == L"second");
			raw->SetInterpretor(L"");
			TEST_ASSERT(state->finalized == 2 && state->destroyed == 2);
			raw->SetInterpretor(L"RawTest::A");
			raw->SetInterpretor(L"RawTest::Missing");
			TEST_ASSERT(raw->GetInterpretor() == L"RawTest::Missing");
			TEST_ASSERT(state->created == 3 && state->finalized == 3 && state->destroyed == 3);
			manager->RegisterRawInterpretorFactory(L"RawTest::Missing", factory);
			raw->SetData(L"no late retry");
			raw->SetInterpretor(L"RawTest::Missing");
			TEST_ASSERT(state->created == 3);
			raw->SetInterpretor(L"RawTest::A");
			{
				auto other = manager->CreateRawElement().Cast<GuiRawElementBase>();
				other->SetInterpretor(L"RawTest::A");
				TEST_ASSERT(state->created == 5 && state->live.Count() == 2);
				TEST_ASSERT(state->live[0] != state->live[1]);
			}
			TEST_ASSERT(state->finalized == 4 && state->destroyed == 4 && state->live.Count() == 1);
		}
		// Neither element had a composition or target to detach the handler before final release.
		TEST_ASSERT(state->created == 5 && state->initialized == 5 && state->finalized == 5 && state->destroyed == 5);
		TEST_ASSERT(state->live.Count() == 0);
		RawCocoaTarget target, replacement;
		{
			auto raw = manager->CreateRawElement().Cast<GuiCocoaElement>();
			auto renderer = raw->GetRenderer();
			vint manualPaints = 0;
			auto manual = raw->Rendering.AttachLambda([&](GuiGraphicsComposition*, GuiCocoaElementEventArgs&) { manualPaints++; });
			renderer->SetRenderTarget(&target);
			raw->SetInterpretor(L"RawTest::A");
			target.StartRendering();
			renderer->Render({ 0,0,200,200 });
			target.StopRendering();
			TEST_ASSERT(state->painted == 1 && manualPaints == 1 && state->created == 6);
			renderer->SetRenderTarget(nullptr);
			renderer->SetRenderTarget(&replacement);
			replacement.StartRendering();
			renderer->Render({ 0,0,200,200 });
			raw->SetInterpretor(L"");
			renderer->Render({ 0,0,200,200 });
			replacement.StopRendering();
			TEST_ASSERT(state->painted == 2 && manualPaints == 3);
			TEST_ASSERT(state->created == 6 && state->finalized == 6 && state->destroyed == 6);
			raw->SetInterpretor(L"RawTest::B");
			TEST_ASSERT(raw->Rendering.Detach(manual));
			// Final release with an attached target must still detach before Rendering dies.
		}
		TEST_ASSERT(state->created == 7 && state->initialized == 7 && state->finalized == 7 && state->destroyed == 7);
		TEST_ASSERT(state->live.Count() == 0);
		TEST_ASSERT(state->attachedAtDestruction == 0);
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

	TEST_CASE(L"Clock plugin paints only received time independently of ID and target replacement")
	{
		auto element = vl::Ptr(GuiCocoaElement::Create());
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
		element->SetData(L"03:00:00");
		TEST_ASSERT(draw() == blank);
		element->SetInterpretor(L"FullControlTest::Clock");
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
		element->SetData(L"03:00:00");
		TEST_ASSERT(draw() == three);
		element->SetInterpretor(L"missing");
		TEST_ASSERT(draw() == blank && element->GetData() == L"03:00:00");
		element->SetInterpretor(L"FullControlTest::Clock");
		TEST_ASSERT(draw() == three);
		element->GetRenderer()->SetRenderTarget(nullptr);
		RawCocoaTarget replacement;
		element->GetRenderer()->SetRenderTarget(&replacement);
		replacement.StartRendering();
		element->GetRenderer()->Render({ 0,0,240,240 });
		replacement.StopRendering();
		TEST_ASSERT(replacement.PixelHash() == three);
		element->SetInterpretor(L"");
		replacement.StartRendering();
		element->GetRenderer()->Render({ 0,0,240,240 });
		replacement.StopRendering();
		TEST_ASSERT(replacement.PixelHash() == blank);
		element->GetRenderer()->SetRenderTarget(nullptr);
	});

	TEST_CASE(L"Manual Touching draws translated, rotated, scaled and clipped payloads with contact rings")
	{
		auto element = vl::Ptr(GuiCocoaElement::Create());
		element->SetId(L"FullControlTest.Touching");
		auto attachment = demo::AttachFullControlTestTouchingElement(element);
		RawCocoaTarget target;
		element->GetRenderer()->SetRenderTarget(&target);
		auto draw = [&](const WString& data, vint scale = 1)
		{
			element->SetData(data);
			target.StartRendering();
			CGContextScaleCTM(target.context, scale, scale);
			CGContextTranslateCTM(target.context, 5, 6);
			element->GetRenderer()->Render({ 10,20,250,260 });
			target.StopRendering();
			return target.PixelHash();
		};
		TEST_ASSERT(element->GetInterpretor() == L"");
		auto blank = draw(L"");
		for (auto data : { L"1,2,3,4", L"1,2,3,4,-1", L"1,2,3,4,0.5", L"1,2,3,4,1", L"1,2,3,4,0.3333333333333333,7", L"nan,0,1,0,0" })
		{
			TEST_ASSERT(draw(data) == blank);
		}
		for (vint scale : { 1,2 })
		{
			TEST_ASSERT(draw(L"120,120,1,0,0", scale) != blank);
			TEST_ASSERT(target.Pixel(135 * scale, 146 * scale) == Color(135, 206, 235));
			TEST_ASSERT(target.Pixel(60 * scale, 100 * scale) == Color(135, 206, 235));
			TEST_ASSERT(target.Pixel(50 * scale, 100 * scale).a == 0);
			draw(L"150,150,1,0,0", scale);
			TEST_ASSERT(target.Pixel(60 * scale, 100 * scale).a == 0);
			TEST_ASSERT(target.Pixel(165 * scale, 176 * scale) == Color(135, 206, 235));
			draw(L"120,120,0,0.5,0", scale);
			TEST_ASSERT(target.Pixel(135 * scale, 110 * scale) == Color(135, 206, 235));
			TEST_ASSERT(target.Pixel(165 * scale, 146 * scale).a == 0);
			draw(L"120,120,1,0,2,7,120,120,9,20,20", scale);
			// The rings have transparent centers and a yellow two-unit outline.
			auto ring = target.Pixel(151 * scale - 1, 146 * scale);
			TEST_ASSERT(ring.r > 220 && ring.g > 220 && ring.b < 40);
			TEST_ASSERT(target.Pixel(35 * scale, 46 * scale).a == 0);
			draw(L"0,0,1,0,1,7,0,0", scale);
			// Sample the clipped fill well inside the ring's antialiased inner edge.
			TEST_ASSERT(target.Pixel(20 * scale, 31 * scale) == Color(135, 206, 235));
			TEST_ASSERT(target.Pixel(14 * scale, 26 * scale).a == 0);
			TEST_ASSERT(target.Pixel(15 * scale, 25 * scale).a == 0);
		}
		auto manual = draw(L"120,120,1,0,0");
		element->SetInterpretor(L"FullControlTest::Clock");
		TEST_ASSERT(draw(L"120,120,1,0,0") == manual);
		element->SetInterpretor(L"");
		TEST_ASSERT(draw(L"120,120,1,0,0") == manual);
		attachment = nullptr;
		TEST_ASSERT(draw(L"120,120,1,0,0") == blank);
		element->GetRenderer()->SetRenderTarget(nullptr);
	});

	TEST_CASE(L"Remote interpretor-only frames repaint fixed clock data and reconcile manual Touching")
	{
		if (GetHostedApplication()) return;
		auto service = GetCurrentController()->WindowService();
		auto native = service->CreateNativeWindow(INativeWindow::Normal);
		native->SetClientSize({ 300,300 });
		auto provider = GetCoreGraphicsObjectProvider();
		auto nativeTarget = provider->GetBindedRenderTarget(native);
		RawCocoaTarget target;
		provider->SetBindedRenderTarget(native, &target);
		RawNativeEvents responses;
		RawNativeRenderer renderer(native);
		renderer.Initialize(&responses);
		auto create = vl::Ptr(new List<RendererCreation>);
		create->Add({ 42,RendererType::Raw });
		renderer.RequestRendererCreated(create);
		auto raw = renderer.GetRawElements()[0].Cast<GuiCocoaElement>();
		vint paints = 0;
		auto manual = raw->Rendering.AttachLambda([&](GuiGraphicsComposition*, GuiCocoaElementEventArgs&) { paints++; });
		auto update = [&](const WString& rawId, const WString& interpretor, const WString& data)
		{
			ElementBeginRendering begin;
			begin.updatedElements = vl::Ptr(new List<OrdinaryElementDescVariant>);
			begin.updatedElements->Add(ElementDesc_Raw{ .id = 42, .rawId = rawId, .interpretor = interpretor, .data = data });
			renderer.RequestRendererBeginRendering(begin);
		};
		auto dom = vl::Ptr(new RenderingDom);
		dom->id = 1;
		dom->content.element = 42;
		dom->content.bounds = { 0,0,240,240 };
		dom->content.validArea = dom->content.bounds;
		renderer.RequestRendererRenderDom(dom);
		update(L"FullControlTest.Clock", L"", L"03:00:00");
		renderer.RequestRendererEndRendering(1);
		auto blank = target.PixelHash();
		TEST_ASSERT(paints == 1);
		update(L"FullControlTest.Clock", L"FullControlTest::Clock", L"03:00:00");
		TEST_ASSERT(renderer.needRefresh);
		renderer.RequestRendererEndRendering(2);
		auto clock = target.PixelHash();
		TEST_ASSERT(clock != blank && paints == 2);
		TEST_ASSERT(target.Pixel(170, 120) == Color(0, 255, 255));
		TEST_ASSERT(target.Pixel(120, 50) == Color(255, 255, 0));
		update(L"FullControlTest.Clock", L"FullControlTest::Clock", L"03:00:00");
		TEST_ASSERT(!renderer.needRefresh);
		renderer.RequestRendererEndRendering(3);
		TEST_ASSERT(paints == 2 && target.PixelHash() == clock);
		update(L"other", L"FullControlTest::Clock", L"03:00:00");
		TEST_ASSERT(!renderer.needRefresh);
		renderer.RequestRendererEndRendering(4);
		TEST_ASSERT(paints == 2);
		update(L"other", L"missing", L"03:00:00");
		TEST_ASSERT(renderer.needRefresh);
		renderer.RequestRendererEndRendering(5);
		TEST_ASSERT(paints == 3 && target.PixelHash() == blank);
		update(L"other", L"FullControlTest::Clock", L"03:00:00");
		renderer.RequestRendererEndRendering(6);
		TEST_ASSERT(paints == 4 && target.PixelHash() == clock);
		update(L"other", L"FullControlTest::Clock", L"06:30:45");
		renderer.RequestRendererEndRendering(7);
		TEST_ASSERT(paints == 5 && target.PixelHash() != clock && target.PixelHash() != blank);
		update(L"other", L"", L"06:30:45");
		renderer.RequestRendererEndRendering(8);
		TEST_ASSERT(paints == 6 && target.PixelHash() == blank);

		const auto touchingData = WString::Unmanaged(L"120,120,1,0,1,7,120,120");
		update(L"FullControlTest.Touching", L"", touchingData);
		renderer.RequestRendererEndRendering(9);
		TEST_ASSERT(target.PixelHash() == blank);
		// Late enumeration installs the manual painter from already received state.
		auto attachment = demo::AttachFullControlTestRawElements(renderer);
		renderer.ForceRender();
		auto touching = target.PixelHash();
		TEST_ASSERT(touching != blank && target.Pixel(60, 80) == Color(135, 206, 235));
		auto ring = target.Pixel(135, 120);
		TEST_ASSERT(ring.r > 220 && ring.g > 220 && ring.b < 40);
		update(L"FullControlTest.Touching", L"", L"120,120,0,0.5,0");
		renderer.RequestRendererEndRendering(10);
		TEST_ASSERT(target.PixelHash() != touching && target.Pixel(60, 80).a == 0);
		update(L"FullControlTest.Touching", L"", touchingData);
		renderer.RequestRendererEndRendering(11);
		TEST_ASSERT(target.PixelHash() == touching);
		update(L"other", L"", touchingData);
		TEST_ASSERT(!renderer.needRefresh);
		renderer.RequestRendererEndRendering(12);
		renderer.ForceRender();
		TEST_ASSERT(target.PixelHash() == blank);
		update(L"FullControlTest.Touching", L"", touchingData);
		renderer.RequestRendererEndRendering(13);
		renderer.ForceRender();
		TEST_ASSERT(target.PixelHash() == touching);
		attachment = nullptr;
		renderer.ForceRender();
		TEST_ASSERT(target.PixelHash() == blank);
		attachment = demo::AttachFullControlTestRawElements(renderer);
		renderer.ForceRender();
		TEST_ASSERT(target.PixelHash() == touching);

		// Replacement detaches the old manual painter even if the element is retained.
		renderer.RequestRendererCreated(create);
		TEST_ASSERT(renderer.GetRawElements().Count() == 1 && renderer.GetRawElements()[0] != raw);
		update(L"FullControlTest.Touching", L"", touchingData);
		renderer.RequestRendererEndRendering(14);
		TEST_ASSERT(target.PixelHash() == touching);
		raw->GetRenderer()->SetRenderTarget(&target);
		target.StartRendering();
		raw->GetRenderer()->Render({ 0,0,240,240 });
		target.StopRendering();
		TEST_ASSERT(target.PixelHash() == blank);
		raw->GetRenderer()->SetRenderTarget(nullptr);
		TEST_ASSERT(raw->Rendering.Detach(manual));
		// Uninstall also detaches the current manual painter before releasing it.
		raw = renderer.GetRawElements()[0].Cast<GuiCocoaElement>();
		renderer.AfterClosing();
		raw->GetRenderer()->SetRenderTarget(&target);
		target.StartRendering();
		raw->GetRenderer()->Render({ 0,0,240,240 });
		target.StopRendering();
		TEST_ASSERT(target.PixelHash() == blank);
		raw->GetRenderer()->SetRenderTarget(nullptr);
		attachment = nullptr;
		provider->SetBindedRenderTarget(native, nativeTarget);
		service->DestroyNativeWindow(native);
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
		WString expectedId, expectedInterpretor, expectedData, paintedData;
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
			TEST_ASSERT(args.element->GetInterpretor() == expectedInterpretor);
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
		auto update = [&](vint id, const WString& rawId, const WString& interpretor, const WString& data)
		{
			expectedId = rawId;
			expectedInterpretor = interpretor;
			expectedData = data;
			ElementBeginRendering begin;
			begin.updatedElements = vl::Ptr(new List<OrdinaryElementDescVariant>);
			begin.updatedElements->Add(ElementDesc_Raw{ .id = id, .rawId = rawId, .interpretor = interpretor, .data = data });
			renderer.RequestRendererBeginRendering(begin);
		};
		update(42, L"", L"", L"");
		TEST_ASSERT(changes == 0);
		update(42, L"FullControlTest.Clock", L"FullControlTest::Clock", L"03:00:00");
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
		update(42, L"FullControlTest.Clock", L"FullControlTest::Clock", L"06:30:45");
		renderer.RequestRendererEndRendering(2);
		TEST_ASSERT(paints > count && paintedData == L"06:30:45");
		count = paints;
		update(42, L"other", L"FullControlTest::Clock", L"06:30:45");
		TEST_ASSERT(!renderer.needRefresh);
		renderer.RequestRendererEndRendering(3);
		TEST_ASSERT(paints == count && changes == 3);
		update(42, L"other", L"FullControlTest::Clock", L"06:30:45");
		TEST_ASSERT(changes == 3);
		update(42, L"FullControlTest.Clock", L"FullControlTest::Clock", L"03:00:00");
		attachment = nullptr;
		attachment = demo::AttachFullControlTestRawElements(renderer);
		renderer.RequestRendererEndRendering(4);
		TEST_ASSERT(paintedData == L"03:00:00");
		create->Clear();
		create->Add({ 43,RendererType::Raw });
		renderer.RequestRendererCreated(create);
		update(43, L"FullControlTest.Clock", L"FullControlTest::Clock", L"03:00:00");
		TEST_ASSERT(renderer.GetRawElements().Count() == 2);
		update(43, L"", L"", L"");
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
		update(42, L"FullControlTest.Clock", L"FullControlTest::Clock", L"03:00:00");
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
