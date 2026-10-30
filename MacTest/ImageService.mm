#include "../Mac/NativeWindow/OSX/ServicesImpl/CocoaImageService.h"
#include <cstring>

using namespace vl;
using namespace vl::presentation;
using namespace vl::presentation::osx;
using namespace vl::stream;

TEST_FILE
{
    TEST_CASE(L"Encode native images and transcode JPEG to PNG")
    {
        @autoreleasepool
        {
            CocoaImageService service;
            NSBitmapImageRep* fixture = [[[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:nullptr pixelsWide:3 pixelsHigh:2
                bitsPerSample:8 samplesPerPixel:3 hasAlpha:NO isPlanar:NO
                colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:9 bitsPerPixel:24] autorelease];
            const unsigned char pixels[] = {
                255,0,0, 0,255,0, 0,0,255,
                255,255,0, 0,255,255, 255,0,255
            };
            memcpy(fixture.bitmapData, pixels, sizeof(pixels));
            NSData* jpeg = [fixture representationUsingType:NSBitmapImageFileTypeJPEG properties:@{}];
            auto image = service.CreateImageFromMemory(const_cast<void*>(jpeg.bytes), jpeg.length);
            TEST_ASSERT(image && image->GetFrameCount() == 1);
            TEST_ASSERT(image->GetFrame(0)->GetSize() == vl::presentation::Size(3, 2));
            for (auto format : { INativeImage::Unknown, INativeImage::Png, INativeImage::Jpeg, INativeImage::Bmp, INativeImage::Gif, INativeImage::Tiff })
            {
                MemoryStream encoded;
                image->SaveToStream(encoded, format);
                TEST_ASSERT(encoded.Size() > 0);
                if (format == INativeImage::Png || format == INativeImage::Unknown)
                {
                    TEST_ASSERT(encoded.Size() > 8);
                    TEST_ASSERT(memcmp(encoded.GetInternalBuffer(), "\x89PNG\r\n\x1a\n", 8) == 0);
                }
                encoded.SeekFromBegin(0);
                auto decoded = service.CreateImageFromStream(encoded);
                TEST_ASSERT(decoded && decoded->GetFrame(0)->GetSize() == vl::presentation::Size(3, 2));
            }
            MemoryStream png;
            image->SaveToStream(png, INativeImage::Png);
            auto reloaded = service.CreateImageFromMemory(png.GetInternalBuffer(), png.Size());
            auto before = static_cast<CocoaImageFrame*>(image->GetFrame(0))->GetCGImage();
            auto after = static_cast<CocoaImageFrame*>(reloaded->GetFrame(0))->GetCGImage();
            unsigned char a[24] = {}, b[24] = {};
            auto color = CGColorSpaceCreateDeviceRGB();
            auto ca = CGBitmapContextCreate(a, 3, 2, 8, 12, color, kCGImageAlphaPremultipliedLast);
            auto cb = CGBitmapContextCreate(b, 3, 2, 8, 12, color, kCGImageAlphaPremultipliedLast);
            CGContextDrawImage(ca, CGRectMake(0, 0, 3, 2), before);
            CGContextDrawImage(cb, CGRectMake(0, 0, 3, 2), after);
            TEST_ASSERT(memcmp(a, b, sizeof(a)) == 0);
            CGContextRelease(ca);
            CGContextRelease(cb);
            CGColorSpaceRelease(color);

            char small[1];
            MemoryWrapperStream shortStream(small, 1);
            TEST_ERROR(image->SaveToStream(shortStream, INativeImage::Png));
            TEST_ERROR(image->SaveToStream(png, INativeImage::Wmp));

            const unsigned char animatedGif[] = {
                'G','I','F','8','9','a', 1,0,1,0,0x80,0,0, 0,0,0,255,255,255,
                0x21,0xF9,4,0,10,0,0,0, 0x2C,0,0,0,0,1,0,1,0,0, 2,2,0x44,1,0,
                0x21,0xF9,4,0,10,0,0,0, 0x2C,0,0,0,0,1,0,1,0,0, 2,2,0x4C,1,0,
                0x3B
            };
            auto animation = service.CreateImageFromMemory(const_cast<unsigned char*>(animatedGif), sizeof(animatedGif));
            TEST_ASSERT(animation && animation->GetFrameCount() == 2);
            TEST_ASSERT(animation->GetFrame(0)->GetSize() == vl::presentation::Size(1, 1));
            TEST_ASSERT(animation->GetFrame(1)->GetSize() == vl::presentation::Size(1, 1));
        }
    });
}

void GuiMain() {}
int main(int argc, char* argv[])
{
    return unittest::UnitTest::RunAndDisposeTests(argc, argv);
}
