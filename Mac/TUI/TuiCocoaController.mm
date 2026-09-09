#include "TuiCocoaController.h"
#include "../NativeWindow/OSX/CocoaHelper.h"
#include "../NativeWindow/OSX/ServicesImpl/CocoaResourceService.h"
#include "../NativeWindow/OSX/ServicesImpl/CocoaInputService.h"
#include "../NativeWindow/OSX/ServicesImpl/CocoaClipboardService.h"
#include "../NativeWindow/OSX/ServicesImpl/CocoaImageService.h"
#include <unistd.h>
#include <cerrno>
#include <clocale>

namespace vl::presentation::osx
{
	class TuiCocoaResourceService : public CocoaResourceService
	{
	public:
		FontProperties GetDefaultFont() override
		{
			auto font = defaultFont;
			font.fontFamily = L"TuiFont";
			font.size = 1;
			return font;
		}

		void SetDefaultFont(const FontProperties& value) override
		{
			defaultFont = value;
			defaultFont.fontFamily = L"TuiFont";
			defaultFont.size = 1;
		}

		void EnumerateFonts(collections::List<WString>& fonts) override
		{
			fonts.Add(L"TuiFont");
		}
	};

	class TuiCocoaInputService : public CocoaInputService
	{
	public:
		TuiCocoaInputService(INativeCallbackService* callbacks)
			: CocoaInputService(nullptr, callbacks)
		{
		}

		void StartTimer() override
		{
			isTimerEnabled = true;
			console::TUI::StartTimer(16);
		}

		void StopTimer() override
		{
			isTimerEnabled = false;
			if (console::TUI::IsInUse()) console::TUI::StopTimer();
		}
	};

	class TuiCocoaController : public TuiControllerBase
	{
	protected:
		TuiCocoaResourceService	resourceService;
		TuiCocoaInputService		inputService;
		CocoaImageService		imageService;
		CocoaClipboardService	clipboardService;

		void PumpPlatformEvents() override
		{
			@autoreleasepool
			{
				while (!console::TUI::IsStopRequested())
				{
					auto event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:[NSDate distantPast] inMode:NSDefaultRunLoopMode dequeue:YES];
					if (!event) break;
					[NSApp sendEvent:event];
				}
				clipboardService.CheckForUpdates();
			}
		}

	public:
		TuiCocoaController(const TuiConfiguration& configuration)
			: TuiControllerBase(configuration)
			, inputService(&callbackService)
			, clipboardService(&callbackService, &imageService)
		{
		}

		~TuiCocoaController()
		{
			inputService.StopTimer();
		}

		INativeResourceService* ResourceService() override { return &resourceService; }
		INativeInputService* InputService() override { return &inputService; }
		INativeClipboardService* ClipboardService() override { return &clipboardService; }
		INativeImageService* ImageService() override { return &imageService; }

		WString GetExecutablePath() override
		{
			return NSStringToWString([[NSBundle mainBundle] executablePath]);
		}

		void ApplyTitle(const WString& title) override
		{
			WString sanitized;
			for (vint i = 0; i < title.Length(); i++)
			{
				auto c = title[i];
				if (c >= 0x20 && !(c >= 0x7F && c < 0xA0)) sanitized += WString::FromChar(c);
			}
			auto output = wtou8(L"\x1B]2;" + sanitized + L"\x07");
			vint offset = 0;
			while (offset < output.Length())
			{
				auto written = write(STDOUT_FILENO, output.Buffer() + offset, output.Length() - offset);
				if (written == -1 && errno == EINTR) continue;
				CHECK_ERROR(written > 0, L"TuiCocoaController#Failed to set terminal title.");
				offset += written;
			}
		}
	};

	int SetupTuiCocoaRenderer(const TuiConfiguration& configuration)
	{
		CHECK_ERROR(std::setlocale(LC_CTYPE, "") != nullptr, L"SetupTuiCocoaRenderer#Failed to initialize the character locale.");
		@autoreleasepool
		{
			[NSApplication sharedApplication];
			[NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];
			[NSApp finishLaunching];
			TuiCocoaController controller(configuration);
			console::TUI::InstallListener(&controller);
			try
			{
				console::TUI::Start({});
			}
			catch (...)
			{
				console::TUI::UninstallListener(&controller);
				throw;
			}
			console::TUI::UninstallListener(&controller);
		}
		return 0;
	}
}
