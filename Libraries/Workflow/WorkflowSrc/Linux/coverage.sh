mkdir Coverage
gcov -o ./Obj/ -l ../../Source/*.cpp
gcov -o ./Obj/ -l ../../Source/Expression/*.cpp
gcov -o ./Obj/ -l ../../Source/Analyzer/*.cpp
gcov -o ./Obj/ -l ../../Source/Runtime/*.cpp
mv *.gcov ./Coverage/
