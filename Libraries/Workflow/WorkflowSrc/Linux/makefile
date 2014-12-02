# This file is generated from "./makefile.debug-clang.makegen" by Vczh Makefile Generator

.PHONY : all clean

bin_TARGET = ././Bin/
obj_TARGET = ././Obj/

UNITTEST_DIR = ./../WorkflowSrc/
UNITTEST_cpp = $(wildcard $(UNITTEST_DIR)*.cpp)
VLPP_BASIC_DIR = ./../../Source/../../../Common/Source/./
VLPP_BASIC_cpp = $(wildcard $(VLPP_BASIC_DIR)*.cpp)
VLPP_BASIC_h = $(wildcard $(VLPP_BASIC_DIR)*.h)
VLPP_COLLECTIONS_DIR = ./../../Source/../../../Common/Source/./Collections/
VLPP_COLLECTIONS_cpp = $(wildcard $(VLPP_COLLECTIONS_DIR)*.cpp)
VLPP_COLLECTIONS_h = $(wildcard $(VLPP_COLLECTIONS_DIR)*.h)
VLPP_JSON_DIR = ./../../Source/../../../Common/Source/./Parsing/Json/
VLPP_JSON_cpp = $(wildcard $(VLPP_JSON_DIR)*.cpp)
VLPP_JSON_h = $(wildcard $(VLPP_JSON_DIR)*.h)
VLPP_PARSING_DIR = ./../../Source/../../../Common/Source/./Parsing/
VLPP_PARSING_cpp = $(wildcard $(VLPP_PARSING_DIR)*.cpp)
VLPP_PARSING_h = $(wildcard $(VLPP_PARSING_DIR)*.h)
VLPP_REFLECTION_DIR = ./../../Source/../../../Common/Source/./Reflection/
VLPP_REFLECTION_cpp = $(wildcard $(VLPP_REFLECTION_DIR)*.cpp)
VLPP_REFLECTION_h = $(wildcard $(VLPP_REFLECTION_DIR)*.h)
VLPP_REGEX_DIR = ./../../Source/../../../Common/Source/./Regex/
VLPP_REGEX_cpp = $(wildcard $(VLPP_REGEX_DIR)*.cpp)
VLPP_REGEX_h = $(wildcard $(VLPP_REGEX_DIR)*.h)
VLPP_STREAM_DIR = ./../../Source/../../../Common/Source/./Stream/
VLPP_STREAM_cpp = $(wildcard $(VLPP_STREAM_DIR)*.cpp)
VLPP_STREAM_h = $(wildcard $(VLPP_STREAM_DIR)*.h)
VLPP_UNITTEST_DIR = ./../../Source/../../../Common/Source/./UnitTest/
VLPP_UNITTEST_cpp = $(wildcard $(VLPP_UNITTEST_DIR)*.cpp)
VLPP_UNITTEST_h = $(wildcard $(VLPP_UNITTEST_DIR)*.h)
VLPP_XML_DIR = ./../../Source/../../../Common/Source/./Parsing/Xml/
VLPP_XML_cpp = $(wildcard $(VLPP_XML_DIR)*.cpp)
VLPP_XML_h = $(wildcard $(VLPP_XML_DIR)*.h)
WORKFLOW_ANALYZER_DIR = ./../../Source/./Analyzer/
WORKFLOW_ANALYZER_cpp = $(wildcard $(WORKFLOW_ANALYZER_DIR)*.cpp)
WORKFLOW_ANALYZER_h = $(wildcard $(WORKFLOW_ANALYZER_DIR)*.h)
WORKFLOW_BASIC_DIR = ./../../Source/./
WORKFLOW_BASIC_h = $(wildcard $(WORKFLOW_BASIC_DIR)*.h)
WORKFLOW_EXPRESSION_DIR = ./../../Source/./Expression/
WORKFLOW_EXPRESSION_cpp = $(wildcard $(WORKFLOW_EXPRESSION_DIR)*.cpp)
WORKFLOW_EXPRESSION_h = $(wildcard $(WORKFLOW_EXPRESSION_DIR)*.h)
WORKFLOW_RUNTIME_DIR = ./../../Source/./Runtime/
WORKFLOW_RUNTIME_cpp = $(wildcard $(WORKFLOW_RUNTIME_DIR)*.cpp)
WORKFLOW_RUNTIME_h = $(wildcard $(WORKFLOW_RUNTIME_DIR)*.h)

UNITTEST_o = $(patsubst $(UNITTEST_DIR)%.cpp, $(obj_TARGET)%.o, $(UNITTEST_cpp))
VLPP_BASIC_o = $(patsubst $(VLPP_BASIC_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_BASIC_cpp))
VLPP_COLLECTIONS_o = $(patsubst $(VLPP_COLLECTIONS_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_COLLECTIONS_cpp))
VLPP_JSON_o = $(patsubst $(VLPP_JSON_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_JSON_cpp))
VLPP_PARSING_o = $(patsubst $(VLPP_PARSING_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_PARSING_cpp))
VLPP_REFLECTION_o = $(patsubst $(VLPP_REFLECTION_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_REFLECTION_cpp))
VLPP_REGEX_o = $(patsubst $(VLPP_REGEX_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_REGEX_cpp))
VLPP_STREAM_o = $(patsubst $(VLPP_STREAM_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_STREAM_cpp))
VLPP_UNITTEST_o = $(patsubst $(VLPP_UNITTEST_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_UNITTEST_cpp))
VLPP_XML_o = $(patsubst $(VLPP_XML_DIR)%.cpp, $(obj_TARGET)%.o, $(VLPP_XML_cpp))
WORKFLOW_ANALYZER_o = $(patsubst $(WORKFLOW_ANALYZER_DIR)%.cpp, $(obj_TARGET)%.o, $(WORKFLOW_ANALYZER_cpp))
WORKFLOW_EXPRESSION_o = $(patsubst $(WORKFLOW_EXPRESSION_DIR)%.cpp, $(obj_TARGET)%.o, $(WORKFLOW_EXPRESSION_cpp))
WORKFLOW_RUNTIME_o = $(patsubst $(WORKFLOW_RUNTIME_DIR)%.cpp, $(obj_TARGET)%.o, $(WORKFLOW_RUNTIME_cpp))

ALL_o = $(VLPP_BASIC_o) $(VLPP_COLLECTIONS_o) $(VLPP_JSON_o) $(VLPP_PARSING_o) $(VLPP_REFLECTION_o) $(VLPP_REGEX_o) $(VLPP_STREAM_o) $(VLPP_UNITTEST_o) $(VLPP_XML_o) $(WORKFLOW_ANALYZER_o) $(WORKFLOW_EXPRESSION_o) $(WORKFLOW_RUNTIME_o) $(UNITTEST_o)
all : $(ALL_o)
	clang++ -std=c++11 -g -pthread -fprofile-arcs -o $(bin_TARGET)UnitTest $(ALL_o)

$(VLPP_COLLECTIONS_h) : $(VLPP_BASIC_h)
$(VLPP_STREAM_h) : $(VLPP_COLLECTIONS_h)
$(VLPP_PARSING_h) : $(VLPP_STREAM_h)
$(VLPP_REFLECTION_h) : $(VLPP_STREAM_h)
$(VLPP_XML_h) : $(VLPP_PARSING_h)
$(VLPP_UNITTEST_h) : $(VLPP_BASIC_h)
$(VLPP_JSON_h) : $(VLPP_PARSING_h)
$(VLPP_BASIC_cpp) : $(VLPP_BASIC_h)
$(VLPP_COLLECTIONS_cpp) : $(VLPP_COLLECTIONS_h)
$(VLPP_JSON_cpp) : $(VLPP_JSON_h)
$(VLPP_PARSING_cpp) : $(VLPP_PARSING_h)
$(VLPP_REFLECTION_cpp) : $(VLPP_REFLECTION_h)
$(VLPP_REGEX_cpp) : $(VLPP_REGEX_h)
$(VLPP_STREAM_cpp) : $(VLPP_STREAM_h)
$(VLPP_UNITTEST_cpp) : $(VLPP_UNITTEST_h)
$(VLPP_XML_cpp) : $(VLPP_XML_h)
$(WORKFLOW_BASIC_h) : $(VLPP_BASIC_h) $(VLPP_COLLECTIONS_h) $(VLPP_JSON_h) $(VLPP_PARSING_h) $(VLPP_REFLECTION_h) $(VLPP_REGEX_h) $(VLPP_STREAM_h) $(VLPP_XML_h)
$(WORKFLOW_EXPRESSION_h) : $(WORKFLOW_BASIC_h)
$(WORKFLOW_RUNTIME_h) : $(WORKFLOW_BASIC_h)
$(WORKFLOW_ANALYZER_h) : $(WORKFLOW_EXPRESSION_h) $(WORKFLOW_RUNTIME_h)
$(WORKFLOW_ANALYZER_cpp) : $(WORKFLOW_ANALYZER_h)
$(WORKFLOW_EXPRESSION_cpp) : $(WORKFLOW_EXPRESSION_h)
$(WORKFLOW_RUNTIME_cpp) : $(WORKFLOW_RUNTIME_h)
$(UNITTEST_cpp) : $(WORKFLOW_ANALYZER_h) $(WORKFLOW_BASIC_h) $(WORKFLOW_EXPRESSION_h) $(WORKFLOW_RUNTIME_h)

$(VLPP_BASIC_o) : $(obj_TARGET)%.o : $(VLPP_BASIC_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(VLPP_COLLECTIONS_o) : $(obj_TARGET)%.o : $(VLPP_COLLECTIONS_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(VLPP_JSON_o) : $(obj_TARGET)%.o : $(VLPP_JSON_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(VLPP_PARSING_o) : $(obj_TARGET)%.o : $(VLPP_PARSING_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(VLPP_REFLECTION_o) : $(obj_TARGET)%.o : $(VLPP_REFLECTION_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(VLPP_REGEX_o) : $(obj_TARGET)%.o : $(VLPP_REGEX_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(VLPP_STREAM_o) : $(obj_TARGET)%.o : $(VLPP_STREAM_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(VLPP_UNITTEST_o) : $(obj_TARGET)%.o : $(VLPP_UNITTEST_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(VLPP_XML_o) : $(obj_TARGET)%.o : $(VLPP_XML_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(WORKFLOW_ANALYZER_o) : $(obj_TARGET)%.o : $(WORKFLOW_ANALYZER_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(WORKFLOW_EXPRESSION_o) : $(obj_TARGET)%.o : $(WORKFLOW_EXPRESSION_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(WORKFLOW_RUNTIME_o) : $(obj_TARGET)%.o : $(WORKFLOW_RUNTIME_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<
$(UNITTEST_o) : $(obj_TARGET)%.o : $(UNITTEST_DIR)%.cpp
	clang++ -std=c++11 -g -fprofile-arcs -ftest-coverage -o $@ -c $<

clean:
	rm $(bin_TARGET)* -rf
	rm $(obj_TARGET)* -rf
