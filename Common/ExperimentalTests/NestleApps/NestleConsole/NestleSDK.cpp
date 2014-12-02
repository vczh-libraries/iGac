#include "NestleSDK.h"

namespace vl
{
	using namespace stream;

	namespace nestle
	{

/***********************************************************************
XML Utility
***********************************************************************/

		void XmlSetProperty(IXMLDOMDocument2* pDom, const wchar_t* name, const wchar_t* value)
		{
			HRESULT hr=S_OK;
			BSTR bstrName=SysAllocString(name);
			BSTR bstrValue=SysAllocString(value);
			if(bstrName && bstrValue)
			{
				VARIANT varValue;
				V_VT(&varValue)=VT_BSTR;
				V_BSTR(&varValue)=bstrValue;
				hr=pDom->setProperty(bstrName, varValue);
			}
			if(bstrName) SysFreeString(bstrName);
			if(bstrValue) SysFreeString(bstrValue);
		}

		IXMLDOMNodeList* XmlQuery(IXMLDOMNode* pDom, const WString& xpath)
		{
			IXMLDOMNodeList* nodes=0;
			BSTR xmlQuery=SysAllocString(xpath.Buffer());
			if(xmlQuery)
			{
				HRESULT hr=pDom->selectNodes(xmlQuery, &nodes);
				if(FAILED(hr))
				{
					nodes=0;
				}
				SysFreeString(xmlQuery);
			}
			return nodes;
		}

		IXMLDOMNode* XmlQuerySingleNode(IXMLDOMNode* pDom, const WString& xpath)
		{
			IXMLDOMNode* node=0;
			BSTR xmlQuery=SysAllocString(xpath.Buffer());
			if(xmlQuery)
			{
				HRESULT hr=pDom->selectSingleNode(xmlQuery, &node);
				if(FAILED(hr))
				{
					node=0;
				}
				SysFreeString(xmlQuery);
			}
			return node;
		}

		WString XmlReadString(IXMLDOMNode* node)
		{
			WString result;
			BSTR text=0;
			HRESULT hr=node->get_text(&text);
			if(SUCCEEDED(hr))
			{
				const wchar_t* candidateItem=text;
				result=candidateItem;
				SysFreeString(text);
			}
			return result;
		}

		WString XmlQueryString(IXMLDOMNode* node, const WString& xpath)
		{
			WString result;
			IXMLDOMNode* textNode=XmlQuerySingleNode(node, xpath);
			if(textNode)
			{
				result=XmlReadString(textNode);
				textNode->Release();
			}
			return result;
		}

		void XmlReadMultipleStrings(IXMLDOMNodeList* textNodes, List<WString>& candidates, int max)
		{
			candidates.Clear();
			while((int)candidates.Count()<max)
			{
				IXMLDOMNode* textNode=0;
				HRESULT hr=textNodes->nextNode(&textNode);
				if(hr==S_OK)
				{
					candidates.Add(XmlReadString(textNode));
					textNode->Release();
				}
				else
				{
					break;
				}
			}
		}

		IXMLDOMDocument2* XmlLoad(const WString& content)
		{
			IXMLDOMDocument2* pDom=0;
			HRESULT hr=CoCreateInstance(__uuidof(DOMDocument60), NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&pDom));
			if(SUCCEEDED(hr))
			{
				pDom->put_async(VARIANT_FALSE);
				pDom->put_validateOnParse(VARIANT_FALSE);
				pDom->put_resolveExternals(VARIANT_FALSE);

				//const wchar_t* xmlns=L"xmlns:as='http://schemas.microsoft.com/Search/2008/suggestions'";
				//XmlSetProperty(pDom, L"SelectionLanguage", L"XPath");
				//XmlSetProperty(pDom, L"SelectionNamespaces", xmlns);

				BSTR xmlContent=SysAllocString(content.Buffer());
				if(xmlContent)
				{
					VARIANT_BOOL isSuccessful=0;
					hr=pDom->loadXML(xmlContent, &isSuccessful);
					if(!(SUCCEEDED(hr) && isSuccessful==VARIANT_TRUE))
					{
						pDom->Release();
						pDom=0;
					}
					SysFreeString(xmlContent);
				}
			}
			return pDom;
		}

/***********************************************************************
Nestle Utility
***********************************************************************/

		WString NestleGetSession(const WString& username, const WString& password, const WString& apiKey, const WString& apiSecret)
		{
			WString body=L"api_key="+apiKey+L"&api_secret="+apiSecret+L"&username="+username+L"&password="+password;

			HttpRequest request;
			HttpResponse response;

			request.SetHost(L"https://www.niaowo.me/account/token/");
			request.method=L"POST";
			request.contentType=L"application/x-www-form-urlencoded";
			request.SetBodyUtf8(body);
			HttpQuery(request, response);

			if(response.statusCode==200)
			{
				return response.cookie;
			}
			else
			{
				return L"";
			}
		}

		WString NestleOperateXml(const WString& path, const WString& query, const WString& cookie, const WString& method, const WString& body)
		{
			bool form=false;
			if(method==L"GET" || method==L"DELETE")
			{
				form=false;
			}
			else if(method==L"POST" || method==L"PUT")
			{
				form=true;
			}
			else
			{
				return L"";
			}

			HttpRequest request;
			HttpResponse response;

			request.SetHost(L"https://www.niaowo.me"+path+L".xml"+(query==L""?WString(L""):L"?"+query));
			request.method=method;
			request.cookie=cookie;
			request.acceptTypes.Add(L"application/xml");
			if(form)
			{
				request.contentType=L"application/x-www-form-urlencoded";
				request.SetBodyUtf8(body);
			}
			HttpQuery(request, response);

			if(response.statusCode==200||response.statusCode==302)
			{
				return response.GetBodyUtf8();
			}
			else
			{
				return L"";
			}
		}

		WString NestleGetXml(const WString& path, const WString& query, const WString& cookie)
		{
			return NestleOperateXml(path, query, cookie, L"GET", L"");
		}

		WString NestlePostXml(const WString& path, const WString& query, const WString& cookie, const WString& body)
		{
			return NestleOperateXml(path, query, cookie, L"POST", body);
		}

		WString NestleDeleteXml(const WString& path, const WString& query, const WString& cookie)
		{
			return NestleOperateXml(path, query, cookie, L"DELETE", L"");
		}

		WString NestlePutXml(const WString& path, const WString& query, const WString& cookie, const WString& body)
		{
			return NestleOperateXml(path, query, cookie, L"PUT", body);
		}

/***********************************************************************
<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <topic>
    <id type="integer">1042</id>
    <title>这是vczh写的程序发的贴，不要理我。</title>
    <viewpoint type="integer">306</viewpoint>
    <desc>都说了不要理了&gt;&amp;LT;...</desc>
    <body>&lt;p&gt;都说了不要理了&gt;&amp;LT;&lt;/p&gt;
</body>
    <created type="datetime">2012-10-27T14:00:59+08:00</created>
    <author>geniusvczh_apptest</author>
  </topic>
  <comments type="array">
    <comment>
      <id type="integer">3329</id>
      <body>&lt;p&gt;这是vczh写的程序发的回帖，不要理我。&lt;/p&gt;
</body>
      <author>geniusvczh_apptest</author>
      <created type="datetime">2012-10-27T14:08:05+08:00</created>
    </comment>
  </comments>
</hash>
***********************************************************************/

/***********************************************************************
NestleUser
***********************************************************************/

		NestleUser::NestleUser(IXMLDOMNode* commentElement)
			:id(-1)
		{
			if(commentElement)
			{
				user=XmlQueryString(commentElement, L"./username/text()");
				id=wtoi(XmlQueryString(commentElement, L"./id/text()"));
			}
		}

		NestleUser::~NestleUser()
		{
		}

/***********************************************************************
NestleComment
***********************************************************************/

		NestleComment::NestleComment(IXMLDOMNode* commentElement)
			:id(-1)
		{
			if(commentElement)
			{
				body=XmlQueryString(commentElement, L"./body/text()");
				createDateTime=XmlQueryString(commentElement, L"./created/text()");
				author=XmlQueryString(commentElement, L"./author/text()");
				id=wtoi(XmlQueryString(commentElement, L"./id/text()"));
			}
		}

		NestleComment::~NestleComment()
		{
		}

/***********************************************************************
NestlePost
***********************************************************************/

		NestlePost::NestlePost(IXMLDOMNode* topicElement, IXMLDOMNodeList* commentElements)
			:id(-1)
		{
			if(topicElement)
			{
				title=XmlQueryString(topicElement, L"./title/text()");
				description=XmlQueryString(topicElement, L"./desc/text()");
				body=XmlQueryString(topicElement, L"./body/text()");
				createDateTime=XmlQueryString(topicElement, L"./created/text()");
				author=XmlQueryString(topicElement, L"./author/text()");
				id=wtoi(XmlQueryString(topicElement, L"./id/text()"));

				if(commentElements)
				{
					while(true)
					{
						IXMLDOMNode* comment=0;
						HRESULT hr=commentElements->nextNode(&comment);
						if(hr==S_OK)
						{
							comments.Add(new NestleComment(comment));
							comment->Release();
						}
						else
						{
							break;
						}
					}
				}
			}
		}

		NestlePost::NestlePost(const NestlePost& post)
			:title(post.title)
			,description(post.description)
			,body(post.body)
			,createDateTime(post.createDateTime)
			,author(post.author)
			,id(post.id)
		{
			CopyFrom(comments, post.comments);
		}

		NestlePost::~NestlePost()
		{
		}

		NestlePost& NestlePost::operator=(const NestlePost& post)
		{
			title=post.title;
			description=post.description;
			body=post.body;
			createDateTime=post.createDateTime;
			author=post.author;
			id=post.id;
			CopyFrom(comments, post.comments);
			return *this;
		}

/***********************************************************************
NestleTopicsPage
***********************************************************************/

		NestleTopicsPage::NestleTopicsPage(IXMLDOMNode* rootElement)
			:totalPages(-1)
			,currentPage(-1)
		{
			if(rootElement)
			{
				IXMLDOMNodeList* nodeList=XmlQuery(rootElement, L"/hash/topics/topic");
				while(true)
				{
					IXMLDOMNode* node=0;
					HRESULT hr=nodeList->nextNode(&node);
					if(hr==S_OK)
					{
						posts.Add(new NestlePost(node));
						node->Release();
					}
					else
					{
						break;
					}
				}
				nodeList->Release();

				totalPages=wtoi(XmlQueryString(rootElement, L"/hash/page/total-pages/text()"));
				currentPage=wtoi(XmlQueryString(rootElement, L"/hash/page/current-page/text()"))-1;
			}
		}

		NestleTopicsPage::NestleTopicsPage(const NestleTopicsPage& page)
			:totalPages(page.totalPages)
			,currentPage(page.currentPage)
		{
			CopyFrom(posts, page.posts);
		}

		NestleTopicsPage::~NestleTopicsPage()
		{
		}

		NestleTopicsPage& NestleTopicsPage::operator=(const NestleTopicsPage& post)
		{
			totalPages=post.totalPages;
			currentPage=post.currentPage;
			CopyFrom(posts, post.posts);
			return *this;
		}

/***********************************************************************
NestleServer
***********************************************************************/

		template<typename T>
		Ptr<T> CreateObjectFromXml(const WString& xml, const WString& xpath)
		{
			if(xml!=L"")
			{
				IXMLDOMDocument2* pDom=XmlLoad(xml);
				if(pDom)
				{
					if(xpath==L"")
					{
						Ptr<T> object=new T(pDom);
						pDom->Release();
						return object;
					}
					else
					{
						IXMLDOMNode* node=XmlQuerySingleNode(pDom, xpath);
						Ptr<T> object=new T(node);
						node->Release();
						pDom->Release();
						return object;
					}
				}
			}
			return 0;
		}

		NestleServer::NestleServer(const WString& _username, const WString& _password, const WString& _apiKey, const WString& _apiSecret)
			:username(_username)
			,password(_password)
			,apiKey(_apiKey)
			,apiSecret(_apiSecret)
		{
			cookie=NestleGetSession(username, password, apiKey, apiSecret);
		}

		NestleServer::~NestleServer()
		{
		}

		bool NestleServer::IsLoginSuccess()
		{
			return cookie!=L"";
		}

		void NestleServer::GetUsers(List<Ptr<NestleUser>>& users)
		{
			users.Count();
			int page=0;
			int totalPages=0;
			while(true)
			{
				WString xml=NestleGetXml(L"/users", L"?page="+itow(page+1), cookie);
				IXMLDOMDocument2* pDom=XmlLoad(xml);
				if(pDom)
				{
					totalPages=wtoi(XmlQueryString(pDom, L"/hash/page/total-pages/text()"));
					IXMLDOMNodeList* userNodes=XmlQuery(pDom, L"/hash/members/member");
					if(userNodes)
					{
						while(true)
						{
							IXMLDOMNode* userNode=0;
							HRESULT hr=userNodes->nextNode(&userNode);
							if(hr==S_OK)
							{
								users.Add(new NestleUser(userNode));
								userNode->Release();
							}
							else
							{
								break;
							}
						}
						userNodes->Release();
					}
					pDom->Release();
				}
				if(++page>=totalPages)
				{
					return;
				}
			}
		}

		const WString& NestleServer::GetUsername()
		{
			return username;
		}

		const WString& NestleServer::GetCookie()
		{
			return cookie;
		}

		Ptr<NestleTopicsPage> NestleServer::GetTopics(int pageIndex)
		{
			WString url;
			if(pageIndex==0)
			{
				url=L"/topics";
			}
			else
			{
				url=L"/topics/page/"+itow(pageIndex+1);
			}
			WString xml=NestleGetXml(url, L"", cookie);
			return CreateObjectFromXml<NestleTopicsPage>(xml, L"");
		}

		Ptr<NestlePost> NestleServer::GetTopic(int postId)
		{
			WString url=L"/topics/"+itow(postId);
			WString xml=NestleGetXml(url, L"output=markdown", cookie);
			if(xml!=L"")
			{
				IXMLDOMDocument2* pDom=XmlLoad(xml);
				if(pDom)
				{
					IXMLDOMNode* node=XmlQuerySingleNode(pDom, L"/hash/topic");
					IXMLDOMNodeList* nodeList=XmlQuery(pDom, L"/hash/comments/comment");
					Ptr<NestlePost> post=new NestlePost(node, nodeList);
					nodeList->Release();
					node->Release();
					pDom->Release();
					return post;
				}
			}
			return 0;
		}

		Ptr<NestlePost> NestleServer::PostTopic(const WString& title, const WString& content)
		{
			WString url=L"/topics";
			WString body=L"title="+UrlEncodeQuery(title)+L"&body="+UrlEncodeQuery(content);
			WString xml=NestlePostXml(url, L"", cookie, body);
			return CreateObjectFromXml<NestlePost>(xml, L"/hash");
		}

		Ptr<NestlePost> NestleServer::UpdateTopic(int postId, const WString& title, const WString& content)
		{
			WString url=L"/topics/"+itow(postId);
			WString body=L"title="+UrlEncodeQuery(title)+L"&body="+UrlEncodeQuery(content);
			WString xml=NestlePutXml(url, L"", cookie, body);
			return CreateObjectFromXml<NestlePost>(xml, L"/hash");
		}

		bool NestleServer::DeleteTopic(int postId)
		{
			WString url=L"/topics/"+itow(postId);
			WString xml=NestleDeleteXml(url, L"", cookie);
			return CreateObjectFromXml<NestlePost>(xml, L"/hash");
		}

		Ptr<NestleComment> NestleServer::PostComment(int postId, const WString& content)
		{
			WString url=L"/comments";
			WString body=L"topic="+itow(postId)+L"&body="+UrlEncodeQuery(content);
			WString xml=NestlePostXml(url, L"", cookie, body);
			return CreateObjectFromXml<NestleComment>(xml, L"/hash");
		}

		Ptr<NestleComment> NestleServer::UpdateComment(int commentId, const WString& content)
		{
			WString url=L"/comments/"+itow(commentId);
			WString body=L"body="+UrlEncodeQuery(content);
			WString xml=NestlePutXml(url, L"", cookie, body);
			return CreateObjectFromXml<NestleComment>(xml, L"/hash");
		}

		bool NestleServer::DeleteComment(int commentId)
		{
			WString url=L"/comments/"+itow(commentId);
			WString xml=NestleDeleteXml(url, L"", cookie);
			return CreateObjectFromXml<NestleComment>(xml, L"/hash");
		}

		WString NestleServer::UploadFile(stream::IStream& content, const WString& fileName)
		{
			HttpRequest request;
			HttpResponse response;
			WString ext;
			{
				ext=wupper(fileName);
				int index=ext.Length()-1;
				while(index>=0 && ext[index]!=L'.')
				{
					index--;
				}
				if(index==-1)
				{
					return L"";
				}
				else
				{
					ext=ext.Sub(index, ext.Length()-index);
				}
			}

			WString contentType;
			if(ext==L".GIF") contentType=L"image/gif";
			else if(ext==L".PNG") contentType=L"image/png";
			else if(ext==L".JPG") contentType=L"image/jpeg";
			else if(ext==L".TXT") contentType=L"text/plain";
			else if(ext==L".TORRENT") contentType=L"application/octet-stream";
			else if(ext==L".PDF") contentType=L"image/pdf";
			else return L"";

			WString boundary=L"fucking-kula-not-give-full-documentation";
			WString contentFirst=
				L"--"+boundary+L"\r\n"
				L"Content-Disposition: form-data; name=\"Filedata\"; filename=\""+fileName+L"\"\r\n"
				L"Content-Type: "+contentType+L"\r\n"
				L"Content-Length: "+itow((int)content.Size())+L"\r\n"
				L"\r\n"
				;
			WString contentLast=
				L"--"+boundary+L"--\r\n"
				;

			request.SetHost(L"https://www.niaowo.me/files.xml");
			request.method=L"POST";
			request.cookie=cookie;
			request.acceptTypes.Add(L"application/xml");
			request.contentType=L"multipart/form-data; boundary="+boundary;

			{
				char buffer[65536];

				MemoryStream stream;
				{
					Utf8Encoder encoder;
					EncoderStream encoderStream(stream, encoder);
					StreamWriter writer(encoderStream);
					writer.WriteString(contentFirst);
				}
				while(true)
				{
					int length=content.Read(buffer, sizeof(buffer));
					if(length==0)
					{
						break;
					}
					else
					{
						stream.Write(buffer, length);
					}
				}
				{
					Utf8Encoder encoder;
					EncoderStream encoderStream(stream, encoder);
					StreamWriter writer(encoderStream);
					writer.WriteString(contentLast);
				}

				stream.SeekFromBegin(0);
				request.body.Resize((int)stream.Size());
				int index=0;
				while(true)
				{
					int length=stream.Read(buffer, sizeof(buffer));
					if(length==0)
					{
						break;
					}
					else
					{
						memcpy(&request.body[index], buffer, length);
						index+=length;
					}
				}
			}

			HttpQuery(request, response);

			if(response.statusCode==200||response.statusCode==302)
			{
				WString url;
				WString xml=response.GetBodyUtf8();
				IXMLDOMDocument2* dom=XmlLoad(xml);
				if(dom)
				{
					url=XmlQueryString(dom, L"/hash/url/text()");
				}
				dom->Release();
				return url;
			}
			else
			{
				return L"";
			}
		}
	}
}