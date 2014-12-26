//
//  GuiGraphicsCoreGraphics.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/4/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "GuiGraphicsCoreGraphics.h"
#include "GuiGraphicsCoreGraphicsRenderers.h"
#include "GuiGraphicsLayoutProviderCoreText.h"

#include "../../NativeWindow/OSX/CocoaHelper.h"
#include "../../NativeWindow/OSX/CocoaWindow.h"
#include "../../NativeWindow/OSX/CocoaNativeController.h"
#include "../../NativeWindow/OSX/CocoaBaseView.h"

#import <Cocoa/Cocoa.h>

using namespace vl::presentation;
using namespace vl::presentation::osx;

@interface CoreGraphicsView: CocoaBaseView

@property (readonly) CGLayer* drawingLayer;

- (id)initWithCocoaWindow:(CocoaWindow*)cocoaWindow;

- (CGContextRef)getLayerContext;

- (void)resize:(CGSize)size;

@end

inline CGContextRef GetCurrentCGContext()
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 101000
    return [[NSGraphicsContext currentContext] CGContext];
#else
    return (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
#endif
}

@implementation CoreGraphicsView
{

}

- (id)initWithCocoaWindow:(CocoaWindow *)window
{
    if(self = [super initWithCocoaWindow:window])
    {
        [self resize:[self frame].size];
    }
    return self;
}

- (id)init
{
    assert(false);
    return nil;
}

- (void)resize:(CGSize)size
{
    if(_drawingLayer)
    {
        CGLayerRelease(_drawingLayer);
    }
    
    CGContextRef viewContext = GetCurrentCGContext();
    _drawingLayer = CGLayerCreateWithContext(viewContext, size, NULL);
    
    if(_drawingLayer)
    {
        CGContextRef context = CGLayerGetContext(_drawingLayer);
        CGContextSetRGBFillColor(context, 0, 0, 0, 0);
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef context = GetCurrentCGContext();
    
    CGContextDrawLayerAtPoint(context, CGPointMake(0, 0), _drawingLayer);
}

- (CGContextRef)getLayerContext
{
    return CGLayerGetContext(_drawingLayer);
}

@end

namespace vl {
    
    namespace presentation {
        
        namespace elements {
            
            GuiCoreGraphicsElement::GuiCoreGraphicsElement()
            {
                
            }
            
            GuiCoreGraphicsElement::~GuiCoreGraphicsElement()
            {
                
            }
            
        }
        
        namespace elements_coregraphics {
            
            using namespace osx;
            using namespace collections;
            
            class CachedCoreTextFontPackageAllocator
            {
                DEFINE_CACHED_RESOURCE_ALLOCATOR(FontProperties, Ptr<CoreTextFontPackage>)
                
            public:
                
                static Ptr<CoreTextFontPackage> CreateCoreTextFontPackage(const FontProperties& font)
                {
                    NSFontManager* fontManager = [NSFontManager sharedFontManager];
                    
                    Ptr<CoreTextFontPackage> coreTextFont = new CoreTextFontPackage;
                    
                    coreTextFont->font = CreateFontWithGacFont(font);
                    
                    if(!coreTextFont->font)
                    {
                        throw FontNotFoundException(L"Font " + font.fontFamily + L" cannot be found.");
                    }
                    
                    coreTextFont->attributes = [NSMutableDictionary dictionaryWithDictionary:@{ NSFontAttributeName: coreTextFont->font }];
                    
                    if(font.underline)
                    {
                        [coreTextFont->attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
                    }
                    
                    
                    if(font.strikeline)
                    {
                        [coreTextFont->attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSStrikethroughStyleAttributeName];
                    }
                    
                    return coreTextFont;
                }
                
                Ptr<CoreTextFontPackage> CreateInternal(const FontProperties& font)
                {
                    return CreateCoreTextFontPackage(font);
                }
            };
            
            class CachedCharMeasurerAllocator
            {
                DEFINE_CACHED_RESOURCE_ALLOCATOR(FontProperties, Ptr<text::CharMeasurer>)
                
            protected:
                class CoreGraphicsCharMeasurer: public text::CharMeasurer
                {
                protected:
                    Ptr<CoreTextFontPackage>  coreTextFont;
                    
                public:
                    CoreGraphicsCharMeasurer(Ptr<CoreTextFontPackage> font):
                    text::CharMeasurer(font->font.pointSize),
                        coreTextFont(font)
                    {
                        
                    }
                    
                    Size MeasureInternal(wchar_t character, IGuiGraphicsRenderTarget* renderTarget)
                    {
                        WString str(character);
                        NSString* nsStr = WStringToNSString(str);
                        
                        CGSize size = [nsStr sizeWithAttributes:coreTextFont->attributes];
                        return Size(size.width, size.height);
                        
                    }
                    
                    vint MeasureWidthInternal(wchar_t character, IGuiGraphicsRenderTarget* renderTarget)
                    {
                        return MeasureInternal(character, renderTarget).x;
                    }
                    
                    vint GetRowHeightInternal(IGuiGraphicsRenderTarget* renderTarget)
                    {
                        return MeasureInternal(L' ', renderTarget).y;
                    }
                };
                
                Ptr<text::CharMeasurer> CreateInternal(const FontProperties& font)
                {
                    return new CoreGraphicsCharMeasurer(CachedCoreTextFontPackageAllocator::CreateCoreTextFontPackage(font));
                }
            };
            
            
            CoreGraphicsView*   GetCoreGraphicsView(INativeWindow* window);
            void                RecreateCoreGraphicsLayer(INativeWindow* window);
            
            class CoreGraphicsObjectProvider: public ICoreGrpahicsObjectProvider
            {
                
                void RecreateRenderTarget(INativeWindow* window)
                {
                    // todo
                }
                
                ICoreGraphicsRenderTarget* GetNativeCoreGraphicsRenderTarget(INativeWindow* window)
                {
                    CocoaWindow* cocoaWindow = dynamic_cast<CocoaWindow*>(window);
                    if(cocoaWindow)
                        return dynamic_cast<ICoreGraphicsRenderTarget*>(cocoaWindow->GetGraphicsHandler());
                    return 0;
                }
                
                ICoreGraphicsRenderTarget* GetBindedRenderTarget(INativeWindow* window)
                {
                    CocoaWindow* cocoaWindow = dynamic_cast<CocoaWindow*>(window);
                    if(cocoaWindow)
                        return dynamic_cast<ICoreGraphicsRenderTarget*>(cocoaWindow->GetGraphicsHandler());
                    return 0;
                }
                
                void SetBindedRenderTarget(INativeWindow* window, ICoreGraphicsRenderTarget* renderTarget)
                {
                    CocoaWindow* cocoaWindow = dynamic_cast<CocoaWindow*>(window);
                    if(cocoaWindow)
                        cocoaWindow->SetGraphicsHandler(renderTarget);
                }
                
            };
            
            namespace
            {
                ICoreGrpahicsObjectProvider* g_coreGraphicsObjectProvider;
            }
            
            ICoreGrpahicsObjectProvider* GetCoreGraphicsObjectProvider()
            {
                return g_coreGraphicsObjectProvider;
            }
            
            void SetCoreGraphicsObjectProvider(ICoreGrpahicsObjectProvider* provider)
            {
                g_coreGraphicsObjectProvider = provider;
            }
            
            // todo
            class CoreGraphicsRenderTarget: public ICoreGraphicsRenderTarget
            {
            protected:
                CoreGraphicsView*       nativeView;
                List<Rect>              clippers;
                vint                    clipperCoverWholeTargetCounter;
                INativeWindow*          window;
                
            public:
                CoreGraphicsRenderTarget(INativeWindow* _window):
                    nativeView(0),
                    clipperCoverWholeTargetCounter(0),
                    window(_window)
                {
                    nativeView = GetCoreGraphicsView(window);
                    
                    [GetNSNativeContainer(window)->window setContentView:nativeView];
                }
                
                ~CoreGraphicsRenderTarget()
                {
                    [[nativeView window] setContentView:nil];
                }
                
                void StartRendering()
                {
                    SetCurrentRenderTarget(this);
                    
                    [NSGraphicsContext saveGraphicsState];
                    
                    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:(CGContextRef)GetCGContext()
                                                                                                    flipped:true]];
                    
                    CGContextRef context = (CGContextRef)GetCGContext();
                    if(!context)
                        return;
                    
                    CGContextSetFillColorWithColor(context, [NSColor blackColor].CGColor);
                    CGContextFillRect(context, [nativeView frame]);
                    
                    CGContextSaveGState(context);
                    // flip the context, since gac's origin is upper-left (0, 0)
                    // this can also be done just in the view when creating the context
                    // just putting it here for now
                    CGContextScaleCTM(context, 1.0, -1.0);
                    CGContextTranslateCTM(context, 0, -nativeView.frame.size.height);
                }
                
                bool StopRendering()
                {
                    CGContextRef context = (CGContextRef)GetCGContext();
                    if(!context)
                        return false;
                    
                    CGContextRestoreGState(context);
                    [NSGraphicsContext restoreGraphicsState];
                    SetCurrentRenderTarget(0);
                    // todo succeed / not
                    return true;
                }
                
                void PushClipper(Rect clipper)
                {
                    if(clipperCoverWholeTargetCounter > 0)
                    {
                        clipperCoverWholeTargetCounter++;
                    }
                    else
                    {
                        Rect previousClipper = GetClipper();
                        Rect currentClipper;
                        
                        currentClipper.x1 = (previousClipper.x1>clipper.x1?previousClipper.x1:clipper.x1);
                        currentClipper.y1 = (previousClipper.y1>clipper.y1?previousClipper.y1:clipper.y1);
                        currentClipper.x2 = (previousClipper.x2<clipper.x2?previousClipper.x2:clipper.x2);
                        currentClipper.y2 = (previousClipper.y2<clipper.y2?previousClipper.y2:clipper.y2);
                        
                        if(currentClipper.x1 < currentClipper.x2 && currentClipper.y1 < currentClipper.y2)
                        {
                            clippers.Add(currentClipper);
                            
                            CGContextRef context = (CGContextRef)GetCGContext();
                            
                            CGContextSaveGState((CGContextRef)GetCGContext());
                            
                            CGRect rect = CGRectMake(clipper.Left(), clipper.Top(), clipper.Width(), clipper.Height());
                            CGContextClipToRect(context, rect);
                        }
                        else
                        {
                            clipperCoverWholeTargetCounter++;
                        }
                    }
                }
                
                void PopClipper()
                {
                    if(clipperCoverWholeTargetCounter>0)
                    {
                        clipperCoverWholeTargetCounter--;
                    }
                    else if(clippers.Count()>0)
                    {
                        clippers.RemoveAt(clippers.Count()-1);
                        CGContextRestoreGState((CGContextRef)GetCGContext());
                    }
                }
                
                Rect GetClipper()
                {
                    if(clippers.Count()==0)
                    {
                        return Rect(Point(0, 0), window->GetClientSize());
                    }
                    else
                    {
                        return clippers[clippers.Count()-1];
                    }
                }
                
                bool IsClipperCoverWholeTarget()
                {
                    return clipperCoverWholeTargetCounter > 0;
                }
                
                
                /////
                CGContextRef GetCGContext() const
                {
                    return [nativeView getLayerContext];
                }
                
            };
            
            class CoreGraphicsResourceManager: public GuiGraphicsResourceManager, public INativeControllerListener, public ICoreGraphicsResourceManager
            {
            protected:
                SortedList<Ptr<CoreGraphicsRenderTarget>>   renderTargets;
                
                CachedCoreTextFontPackageAllocator          coreTextFonts;
                CachedCharMeasurerAllocator                 charMeasurers;
                
                Ptr<CoreTextLayoutProvider>                 layoutProvider;
                
            public:
                CoreGraphicsResourceManager()
                {
                    g_coreGraphicsObjectProvider = new CoreGraphicsObjectProvider;
                    
                    layoutProvider = new CoreTextLayoutProvider;
                }
                
                IGuiGraphicsRenderTarget* GetRenderTarget(INativeWindow* window)
                {
                    return GetCoreGraphicsObjectProvider()->GetBindedRenderTarget(window);
                }
                
                void RecreateRenderTarget(INativeWindow* window)
                {
                    NativeWindowDestroying(window);
                    GetCoreGraphicsObjectProvider()->RecreateRenderTarget(window);
                    NativeWindowCreated(window);
                }
                
                IGuiGraphicsLayoutProvider* GetLayoutProvider()
                {
                    return layoutProvider.Obj();
                }
                
                void NativeWindowCreated(INativeWindow* window)
                {
                    CoreGraphicsRenderTarget* renderTarget = new CoreGraphicsRenderTarget(window);
                    renderTargets.Add(renderTarget);
                    GetCoreGraphicsObjectProvider()->SetBindedRenderTarget(window, renderTarget);
                }
                
                void NativeWindowDestroying(INativeWindow* window)
                {
                    CoreGraphicsRenderTarget* renderTarget = dynamic_cast<CoreGraphicsRenderTarget*>(GetCoreGraphicsObjectProvider()->GetBindedRenderTarget(window));
                    renderTargets.Remove(renderTarget);
                    GetCoreGraphicsObjectProvider()->SetBindedRenderTarget(window, 0);
                }
                
                Ptr<elements::text::CharMeasurer> CreateCharMeasurer(const FontProperties& font)
                {
                    return charMeasurers.Create(font);
                }
                
                Ptr<CoreTextFontPackage> CreateCoreTextFont(const FontProperties& font)
                {
                    return coreTextFonts.Create(font);
                }
                
                void DestroyCharMeasurer(const FontProperties& font)
                {
                    charMeasurers.Destroy(font);
                }
                
                void DestroyCoreTextFont(const FontProperties& font)
                {
                    coreTextFonts.Destroy(font);
                }
                
                
            };
            
            namespace {
                
                ICoreGraphicsRenderTarget*      g_currentRenderTarget;
                ICoreGraphicsResourceManager*   g_coreGraphicsResourceManager;
                
            }
            
            void SetCurrentRenderTarget(ICoreGraphicsRenderTarget* renderTarget)
            {
                g_currentRenderTarget = renderTarget;
            }
            
            ICoreGraphicsRenderTarget* GetCurrentRenderTarget()
            {
                return g_currentRenderTarget;
            }
            
            ICoreGraphicsResourceManager* GetCoreGraphicsResourceManager()
            {
                return g_coreGraphicsResourceManager;
            }
            
            void SetCoreGraphicsResourceManager(ICoreGraphicsResourceManager* rm)
            {
                g_coreGraphicsResourceManager = rm;
            }
        }
    }
    
}



namespace vl {
    
    namespace presentation {
        
        namespace elements_coregraphics {
            
            using namespace collections;
            
            class CoreGraphicsCocoaNativeWindowListener: public Object, public INativeWindowListener
            {
            protected:
                CoreGraphicsView*       nativeView;
                Size                    previousSize;
                INativeWindow*          window;
                
            public:
                CoreGraphicsCocoaNativeWindowListener(INativeWindow* _window):
                    window(_window)
                {
                    nativeView = [[CoreGraphicsView alloc] initWithCocoaWindow:dynamic_cast<CocoaWindow*>(_window)];
                }
                
                void RebuildLayer(Size size)
                {
                    if(previousSize != size)
                        [nativeView resize:CGSizeMake(size.x, size.y)];
                    previousSize = size;
                }
                
                void Moved()
                {
                    RebuildLayer(window->GetClientSize());
                }
                
                void Paint()
                {
                    
                }
                
                CoreGraphicsView* GetCoreGraphicsView() const
                {
                    return nativeView;
                }
                
                void RecreateRenderTarget()
                {
                    RebuildLayer(window->GetClientSize());
                }
                
            };
            
            class CoreGraphicsCocoaNativeControllerListener: public Object, public INativeControllerListener
            {
            public:
                Dictionary<INativeWindow*, Ptr<CoreGraphicsCocoaNativeWindowListener>>  nativeWindowListeners;
                
                void NativeWindowCreated(INativeWindow* window)
                {
                    Ptr<CoreGraphicsCocoaNativeWindowListener> listener=new CoreGraphicsCocoaNativeWindowListener(window);
                    window->InstallListener(listener.Obj());
                    nativeWindowListeners.Add(window, listener);
                }
                
                void NativeWindowDestroying(INativeWindow* window)
                {
                    Ptr<CoreGraphicsCocoaNativeWindowListener> listener=nativeWindowListeners[window];
                    nativeWindowListeners.Remove(window);
                    window->UninstallListener(listener.Obj());
                }
                
            };
            
            namespace
            {
                CoreGraphicsCocoaNativeControllerListener* g_cocoaListener;
            }
            
            CoreGraphicsView* GetCoreGraphicsView(INativeWindow* window)
            {
                vint index = g_cocoaListener->nativeWindowListeners.Keys().IndexOf(window);
                return index==-1 ? 0 : g_cocoaListener->nativeWindowListeners.Values().Get(index)->GetCoreGraphicsView();
            }
            
            void RecreateCoreGraphicsLayer(INativeWindow* window)
            {
                vint index = g_cocoaListener->nativeWindowListeners.Keys().IndexOf(window);
                if (index == -1)
                {
                    g_cocoaListener->nativeWindowListeners.Values().Get(index)->RecreateRenderTarget();
                }
            }
        }
        
    }
    
}

using namespace vl::presentation::osx;
using namespace vl::presentation::elements_coregraphics;

void CoreGraphicsMain()
{
    // actually this has to init before ResourceManager
    // as we need to create underlying views first
    g_cocoaListener = new CoreGraphicsCocoaNativeControllerListener();
    GetCurrentController()->CallbackService()->InstallListener(g_cocoaListener);
    
    CoreGraphicsResourceManager resourceManager;
    SetGuiGraphicsResourceManager(&resourceManager);
    SetCoreGraphicsResourceManager(&resourceManager);
    GetCurrentController()->CallbackService()->InstallListener(&resourceManager);
    
    elements_coregraphics::GuiSolidBorderElementRenderer::Register();
    elements_coregraphics::GuiRoundBorderElementRenderer::Register();
    elements_coregraphics::Gui3DBorderElementRenderer::Register();
    elements_coregraphics::Gui3DSplitterElementRenderer::Register();
    elements_coregraphics::GuiSolidBackgroundElementRenderer::Register();
    elements_coregraphics::GuiGradientBackgroundElementRenderer::Register();
    elements_coregraphics::GuiSolidLabelElementRenderer::Register();
    elements_coregraphics::GuiImageFrameElementRenderer::Register();
    elements_coregraphics::GuiPolygonElementRenderer::Register();
    elements_coregraphics::GuiColorizedTextElementRenderer::Register();
    elements_coregraphics::GuiCoreGraphicsElementRenderer::Register();

    elements::GuiDocumentElement::GuiDocumentElementRenderer::Register();
    
    {
        GuiApplicationMain();
        
    }
    
    GetCurrentController()->CallbackService()->UninstallListener(g_cocoaListener);
    delete g_cocoaListener;

}

