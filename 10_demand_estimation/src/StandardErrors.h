/*
 * StandardErrors.h
 *
 *  Created on: Aug 21, 2018
 *      Author: Marry
 */

#ifndef STANDARDERRORS_H_
#define STANDARDERRORS_H_

#include<string> // for string class
using namespace std;

class StandardErrors {
private:
	int number_of_sensors;
	string* sensor_id;
	float* std_error;
public:
	StandardErrors(char input_file[]);
	virtual ~StandardErrors();
	int getNumberOfSensors();
	string getSensorID(int index);
	float getSensorStdev(string id);
	void PrintToFile(char output_file[]);
};

#endif /* STANDARDERRORS_H_ */
