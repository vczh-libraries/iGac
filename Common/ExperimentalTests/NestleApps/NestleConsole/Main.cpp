#include "NestleSDK.h"

using namespace vl;
using namespace vl::nestle;
using namespace vl::console;

/***********************************************************************
Main
***********************************************************************/

int main(int argc, wchar_t* argv[])
{
	CoInitialize(NULL);

	WString apiKey=L"e1424eb84b6d4169a10c03fb1e73e140";
	WString apiSecret=L"9814021f20054b558105fca1df6559a7";
	WString username;
	WString password;

	int currentPostId=-1;
	bool editingPost=false;
	WString editingPostTitle;
	WString editingPostContent;

	// geniusvczh_apptest
	// fuckkula
	Console::Write(L"Username: ");
	username=Console::Read();
	Console::Write(L"Password: ");
	password=Console::Read();
	NestleServer server(username, password, apiKey, apiSecret);
	if(!server.IsLoginSuccess())
	{
		Console::SetColor(true, false, false, true);
		Console::WriteLine(L"Login failed.");
		Console::SetColor(true, true, true, false);
		Console::WriteLine(L"Press [ENTER] to exit.");
		Console::Read();
		goto EXIT;
	}
	
	Console::WriteLine(L"+----------------------------------------------");
	Console::WriteLine(L"Welcome to Vczh Console Nestle Client 1.0");
	Console::WriteLine(L"Enter \"help\" for all commands, commands are all case sensitive.");
	Console::WriteLine(L"Author: vczh@163.com");
	Console::WriteLine(L"+----------------------------------------------");

	while(true)
	{
		Console::SetColor(false, true, false, true);
		if(editingPost)
		{
			Console::Write(L"New Post>");
		}
		else if(currentPostId==-1)
		{
			Console::Write(username+L">");
		}
		else
		{
			Console::Write(L"Topic "+itow(currentPostId)+L">");
		}
		Console::SetColor(true, true, true, false);
		WString command=Console::Read();

		if(command.Length()>=5 && command.Sub(0, 5)==L"post ")
		{
			currentPostId=-1;
			if(command==L"post ")
			{
				Console::SetColor(true, false, false, true);
				Console::WriteLine(L"<TITLE CANNOT BE EMPTY>");
				Console::SetColor(true, true, true, false);
			}
			else
			{
				editingPost=true;
				editingPostTitle=command.Sub(5, command.Length()-5);
				editingPostContent=L"";
				Console::SetColor(false, true, false, true);
				Console::WriteLine(L"<TITLE>: "+editingPostTitle);
				Console::WriteLine(L"<PLEASE ENTER CONTENT, OR USING send post/cancel post TO FINISH>");
				Console::SetColor(true, true, true, false);
			}
		}
		else if(command==L"send post")
		{
			currentPostId=-1;
			if(editingPost)
			{
				Ptr<NestlePost> post=server.PostTopic(editingPostTitle, editingPostContent);
				if(post)
				{
					Console::SetColor(false, true, false, true);
					Console::WriteLine(L"<SUCCESS> Topic ID = "+itow(post->id));
					Console::SetColor(true, true, true, false);
					editingPost=false;
				}
				else
				{
					Console::SetColor(true, false, false, true);
					Console::WriteLine(L"<OPERATION FAILED>");
					Console::SetColor(true, true, true, false);
				}
			}
			else
			{
				Console::SetColor(true, false, false, true);
				Console::WriteLine(L"<SHOULD USE post COMMAND TO ENTER EDITING MODE FIRST>");
				Console::SetColor(true, true, true, false);
			}
		}
		else if(command==L"cancel post")
		{
			currentPostId=-1;
			if(editingPost)
			{
				editingPost=false;
			}
		}
		else if(command==L"exit")
		{
			break;
		}
		else
		{
			if(editingPost)
			{
				editingPostContent+=command+L"\r\n";
			}
			else if(command==L"help")
			{
				Console::WriteLine(L"+----------------------------------------------");
				Console::WriteLine(L"exit                : Close the client.");
				Console::WriteLine(L"help                : Show help.");
				Console::WriteLine(L"topics [page index] : Get all topics of the specified page. Page index starts from 1, default is 1.");
				Console::WriteLine(L"topic <id>          : Open a topic.");
				Console::WriteLine(L"comments            : Show all comments of the current topic.");
				Console::WriteLine(L"comment <content>   : Post a comment in the current topic.");
				Console::WriteLine(L"post <title>        : Begin a new post with a specified title. Then enter content, until one of the following commands are used.");
				Console::WriteLine(L"send post           : Send out the new post.");
				Console::WriteLine(L"cancel post         : Cancel the new post.");
				Console::WriteLine(L"+----------------------------------------------");
			}
			else if(command.Length()>=6 && command.Sub(0, 6)==L"topics")
			{
				currentPostId=-1;
				int pageIndex=command==L"topics"?0:wtoi(command.Sub(6, command.Length()-6))-1;
				Ptr<NestleTopicsPage> page=server.GetTopics(pageIndex);
				if(page)
				{
					Console::WriteLine(L"+----------------------------------------------");
					Console::WriteLine(L"Total pages  : "+itow(page->totalPages));
					Console::WriteLine(L"Current page : "+itow(page->currentPage));
					Console::WriteLine(L"+----------------------------------------------");
					FOREACH(Ptr<NestlePost>, post, page->posts)
					{
						Console::WriteLine(L"Author : "+post->author);
						Console::WriteLine(L"Id     : "+itow(post->id));
						Console::WriteLine(L"");
						Console::WriteLine(post->title);
						Console::WriteLine(L"+----------------------------------------------");
					}
				}
				else
				{
					Console::SetColor(true, false, false, true);
					Console::WriteLine(L"<OPERATION FAILED>");
					Console::SetColor(true, true, true, false);
				}
			}
			else if(command.Length()>=6 && command.Sub(0, 6)==L"topic ")
			{
				currentPostId=command==L"topic "?-1:wtoi(command.Sub(6, command.Length()-6));
				if(currentPostId==-1)
				{
					Console::SetColor(true, false, false, true);
					Console::WriteLine(L"<WRONG POST ID>");
					Console::SetColor(true, true, true, false);
				}
				else
				{
					Ptr<NestlePost> post=server.GetTopic(currentPostId);
					if(post)
					{
						Console::WriteLine(L"+----------------------------------------------");
						Console::WriteLine(post->title);
						Console::WriteLine(L"+----------------------------------------------");
						Console::WriteLine(L"Author     : "+post->author);
						Console::WriteLine(L"Id         : "+itow(post->id));
						Console::WriteLine(L"Created At : "+post->createDateTime);
						Console::WriteLine(L"+----------------------------------------------");
						Console::WriteLine(post->body);
						Console::WriteLine(L"+----------------------------------------------");
					}
					else
					{
						currentPostId=-1;
						Console::SetColor(true, false, false, true);
						Console::WriteLine(L"<OPERATION FAILED>");
						Console::SetColor(true, true, true, false);
					}
				}
			}
			else if(command==L"comments")
			{
				if(currentPostId==-1)
				{
					Console::SetColor(true, false, false, true);
					Console::WriteLine(L"<SHOULD USE topic TO OPEN TOPIC FIRST>");
					Console::SetColor(true, true, true, false);
				}
				else
				{
					Ptr<NestlePost> post=server.GetTopic(currentPostId);
					if(post)
					{
						Console::WriteLine(L"+----------------------------------------------");
						FOREACH(Ptr<NestleComment>, comment, post->comments)
						{
							Console::WriteLine(L"Author : "+comment->author);
							Console::WriteLine(L"Id     : "+itow(comment->id));
							Console::WriteLine(L"");
							Console::WriteLine(comment->body);
							Console::WriteLine(L"+----------------------------------------------");
						}
					}
					else
					{
						currentPostId=-1;
						Console::SetColor(true, false, false, true);
						Console::WriteLine(L"<OPERATION FAILED>");
						Console::SetColor(true, true, true, false);
					}
				}
			}
			else if(command.Length()>=8 && command.Sub(0, 8)==L"comment ")
			{
				if(currentPostId==-1)
				{
					Console::SetColor(true, false, false, true);
					Console::WriteLine(L"<SHOULD USE topic TO OPEN TOPIC FIRST>");
					Console::SetColor(true, true, true, false);
				}
				else if(command==L"comment ")
				{
					Console::SetColor(true, false, false, true);
					Console::WriteLine(L"<COMMENT CANNOT BE EMPTY>");
					Console::SetColor(true, true, true, false);
				}
				else
				{
					WString content=command.Sub(8, command.Length()-8);
					if(server.PostComment(currentPostId, content))
					{
						Console::SetColor(false, true, false, true);
						Console::WriteLine(L"<SUCCESS>");
						Console::SetColor(true, true, true, false);
					}
					else
					{
						Console::SetColor(true, false, false, true);
						Console::WriteLine(L"<OPERATION FAILED>");
						Console::SetColor(true, true, true, false);
					}
				}
			}
			else
			{
				currentPostId=-1;
				Console::WriteLine(L"<WRONG COMMAND>: "+command);
			}
		}
	}

EXIT:
	CoUninitialize();
	return 0;
}