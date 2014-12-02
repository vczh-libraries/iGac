#ifndef VCZH_NESTLECLIENT_WINDOWS_NEWPOSTWINDOW
#define VCZH_NESTLECLIENT_WINDOWS_NEWPOSTWINDOW

#include "..\..\..\..\Libraries\GacUI\Public\Source\GacUIIncludes.h"
#include "..\NestleConsole\NestleSDK.h"

namespace vl
{
	namespace nestle
	{
		class NewPostWindow : public GuiWindow
		{
		protected:
			GuiSinglelineTextBox*				textTitle;
			GuiMultilineTextBox*				textBody;
			GuiButton*							buttonPost;
			GuiButton*							buttonCancel;
			Ptr<NestleServer>					server;
			Ptr<NestlePost>						post;

			void								buttonPost_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments);
			void								buttonCancel_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments);
		protected:
			void								InitializeComponents();
		public:
			NewPostWindow(Ptr<NestleServer> _server);
			~NewPostWindow();

			Ptr<NestlePost>						GetCommittedPost();
		};
	}
}

#endif