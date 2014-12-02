# This file is generated from "./makefile.release.makegen" by Vczh Makefile Generator

.PHONY : all clean

bin_TARGET = ././Bin/
obj_TARGET = ././Obj/

PARSERGEN_DIR = ././ParserGen/
PARSERGEN_cpp = $(wildcard $(PARSERGEN_DIR)ParserGen*.cpp) $(PARSERGEN_DIR)Main.cpp
PARSERGEN_h = $(PARSERGEN_DIR)ParserGen.h
VLPP_DIR = ./../../../Libraries/GacUI/Public/Source/
VLPP_cpp = $(VLPP_DIR)Vlpp.cpp
VLPP_h = $(VLPP_DIR)Vlpp.h

PARSERGEN_o = $(patsubst $(PARSERGEN_DIR)%.cpp, $(obj_TARGET)%.o, $(PARSERGEN_cpp))
VLPP_o = $(patsubst $(VLPP_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_cpp))

ALL_o = $(PARSERGEN_o) $(VLPP_o)
all : $(ALL_o)
	g++ -std=c++11 -o2 -o $(bin_TARGET)ParserGen $(ALL_o)

$(PARSERGEN_h) : $(VLPP_h)
$(PARSERGEN_cpp) : $(PARSERGEN_h)
$(VLPP_cpp) : $(VLPP_h)

$(PARSERGEN_o) : $(obj_TARGET)%.o : $(PARSERGEN_DIR)%.cpp
	g++ -std=c++11 -o2 -o $@ -c $<
$(VLPP_o) : $(obj_TARGET)%.o : $(VLPP_DIR)%.cpp
	g++ -std=c++11 -o2 -o $@ -c $<

clean:
	rm $(bin_TARGET)* -rf
	rm $(obj_TARGET)* -rf
