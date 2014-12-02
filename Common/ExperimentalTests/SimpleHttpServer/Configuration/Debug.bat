mkdir ServiceFolder
cd ServiceFolder
del *.* /Q
copy ..\ServiceConfiguration.xml ServiceConfiguration.xml
copy ..\StorageConfiguration.xml StorageConfiguration.xml
copy ..\..\HelloWorldTestServer\bin\Debug\*.exe *.exe
copy ..\..\HelloWorldTestServer\bin\Debug\*.dll *.dll
copy ..\..\NestleServices\NestleSpider\bin\Debug\*.exe *.exe
copy ..\..\NestleServices\NestleSpider\bin\Debug\*.dll *.dll
copy ..\..\NestleServices\NestleSearch\bin\Debug\*.exe *.exe
copy ..\..\NestleServices\NestleSearch\bin\Debug\*.dll *.dll
cd..