#ifndef VCZH_NESTLECLIENT_WINDOWS_LOGINWINDOW
#define VCZH_NESTLECLIENT_WINDOWS_LOGINWINDOW

#include "..\..\..\..\Libraries\GacUI\Public\Source\GacUIIncludes.h"
#include "..\NestleConsole\NestleSDK.h"

namespace vl
{
	namespace nestle
	{
		class LoginWindow : public GuiWindow
		{
		protected:
			GuiSinglelineTextBox*				textUsername;
			GuiSinglelineTextBox*				textPassword;
			GuiButton*							buttonLogin;
			GuiButton*							buttonCancel;
			Ptr<NestleServer>					nestleServer;

			void								buttonLogin_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments);
			void								buttonCancel_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments);
		protected:
			void								InitializeComponents();
		public:
			LoginWindow();
			~LoginWindow();

			Ptr<NestleServer>					CreatedNestleServer();
		};
	}
}

#endif