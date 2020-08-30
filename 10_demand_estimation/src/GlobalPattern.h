/*
 * GlobalPattern.h
 *
 *  Created on: Nov 6, 2017
 *      Author: oliveipa
 */

#ifndef GLOBALPATTERN_H_
#define GLOBALPATTERN_H_

#include<string> // for string class
using namespace std;

class Global_Pattern {
private:
	int data_size;
	int* hour;
	float* pattern;
public:
	Global_Pattern(char input_file[]);
	virtual ~Global_Pattern();
	int getDataSize();
	float getPattern(int h);
	void PrintToFile(char output_file[]);
};

#endif /* GLOBALPATTERN_H_ */
