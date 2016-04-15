#!/usr/bin/python

import os.path as path, os
from shutil import copyfile

SCRIPT_PATH = path.dirname(path.realpath(__file__))
RESOURCE_MAP = {
	"Layouts/": "../Release/Tutorial/GacUI_Layout/UIRes",
	"Controls/": "../Release/Tutorial/GacUI_Controls/UIRes",
}

for (k, v) in RESOURCE_MAP.iteritems():
	files = [fn for fn in next(os.walk(path.join(SCRIPT_PATH, v)))[2]]
	for f in files:
		d = path.join(SCRIPT_PATH, k, path.splitext(f)[0])
		if path.exists(d):
			print 'Copying:', f, 'to', d
			copyfile(path.join(SCRIPT_PATH, v, f), path.join(d, f))