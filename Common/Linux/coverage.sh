mkdir Coverage
gcov -o ./Obj/ -l ../Source/*.cpp
gcov -o ./Obj/ -l ../Source/Collection/*.cpp
gcov -o ./Obj/ -l ../Source/Parsing/*.cpp
gcov -o ./Obj/ -l ../Source/Reflection/*.cpp
gcov -o ./Obj/ -l ../Source/Regex/*.cpp
gcov -o ./Obj/ -l ../Source/Stream/*.cpp
mv *.gcov ./Coverage/
