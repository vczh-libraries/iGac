cd Temp
copy ..\..\GacUISrc\DebugNoReflection\GacUISrc.xml GacUISrc.xml
copy ..\..\GacUISrc\DebugNoReflection\GacUISrc.pdb GacUISrc.pdb
..\..\..\..\Common\Tools\PdbDump.exe GacUISrc.pdb GacUISrcPdb.xml
..\..\..\..\Common\Tools\LinkPdbXml.exe GacUISrcPdb.xml GacUISrc.xml GacUISrcDoc.xml
..\..\..\..\Common\Tools\GenXmlDocRef.exe GacUISrcDoc.xml . reference:gacui
cd ..