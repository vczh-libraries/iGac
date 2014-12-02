// CppAmpConsole.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <amp.h>
#include <iostream>

using namespace std;
using namespace concurrency;

const int Size=100000;
int numbers[Size], sums[Size];

int _tmain(int argc, _TCHAR* argv[])
{
	for(int i=0;i<Size;i++)
	{
		numbers[i]=i+1;
	}

	wcout<<L"Executing CPU ..."<<endl;
	{
		for(int i=0;i<Size;i++)
		{
			int sum=0;
			for(int j=0;j<Size;j++)
			{
				sum+=numbers[j]+j;
			}
			sums[i]=sum;
		}
	}

	wcout<<L"Executing GPU ..."<<endl;
	{
		array_view<const int, 1> avNumbers(Size, numbers);
		array_view<int, 1> avSums(Size, sums);
		avSums.discard_data();

		parallel_for_each(avSums.extent, [=](index<1> i) restrict(amp)
		{
			int sum=0;
			for(int j=0;j<Size;j++)
			{
				sum+=avNumbers[j]+j;
			}
			avSums[i]=sum;
		});
	}

	return 0;
}

