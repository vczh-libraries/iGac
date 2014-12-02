#include "UnitTest.h"
#include "../Console.h"
#if defined VCZH_MSVC
#include "../Threading.h"
#endif

namespace vl
{
	namespace unittest
	{
		using namespace vl::console;

/***********************************************************************
UnitTest
***********************************************************************/

#if defined VCZH_MSVC
		SpinLock spinLockUnitTest;
#endif

		void UnitTest::PrintMessage(const WString& string)
		{
#if defined VCZH_MSVC
			SpinLock::Scope scope(spinLockUnitTest);
#endif
			Console::SetColor(false, true, false, true);
			Console::WriteLine(string);
			Console::SetColor(true, true, true, false);
		}

		void UnitTest::PrintInfo(const WString& string)
		{
#if defined VCZH_MSVC
			SpinLock::Scope scope(spinLockUnitTest);
#endif
			Console::SetColor(true, true, true, true);
			Console::WriteLine(string);
			Console::SetColor(true, true, true, false);
		}

		void UnitTest::PrintError(const WString& string)
		{
#if defined VCZH_MSVC
			SpinLock::Scope scope(spinLockUnitTest);
#endif
			Console::SetColor(true, false, false, true);
			Console::WriteLine(string);
			Console::SetColor(true, true, true, false);
		}
	}
}
