A simple command-line tool for OS X to convert ID3 tag encodings


	Usage: id3c [-s=SOURCE_ENCODING_ID] [-t=TARGET_ENCODING_ID] [-d=DEST] folders or files
	  Options:
	    -l:  List available encodings and IDs
	    -h:  Print usage
	    -s:  Source encoding id, default is GBK_18030_2000
	    -t:  Destination encoding id, default is UTF8
	    -d:  Destination folder, default is SRC_FOLDER/id3c
	    -o:  Overwrite original file, default is no

Dependencies:

Taglib https://taglib.github.io
