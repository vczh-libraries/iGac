cd Temp
mkdir StaticMetaDoc
mkdir StaticHtmlDoc
cd ..
..\..\..\Common\Tools\GenDocIndex.exe meta Temp\StaticMetaDoc Temp DocumentRawItems
..\..\..\Common\Tools\GenDocIndex.exe html Temp\StaticHtmlDoc Temp DocumentRawItems
..\..\..\Common\Tools\Recurcpy.exe Source										Temp\ReleaseFolder\Public\Source		include cpp h exe
..\..\..\Common\Tools\Recurcpy.exe Temp\StaticHtmlDoc							Temp\ReleaseFolder\Public\Document		include html
..\..\..\Common\Tools\Recurcpy.exe ..\GaclibServices\GaclibWebPage\Content\		Temp\ReleaseFolder\Public\Content		include css gif
..\..\..\Common\Tools\Recurcpy.exe ..\GacUIDemo									Temp\ReleaseFolder\GacUIDemo			include sln vssscc vcxproj filters vspscc cpp h bmp jpg gif png ico txt xml