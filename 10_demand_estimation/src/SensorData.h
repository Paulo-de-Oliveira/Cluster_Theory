/*
 * SensorData.h
 *
 *  Created on: Nov 7, 2017
 *      Author: oliveipa
 */

#ifndef SENSORDATA_H_
#define SENSORDATA_H_

#include<string> // for string class
using namespace std;

class SensorData {
private:

	int data_size;
	int* hour;

	int N_pipe_flow;
	int N_pump_flow;
	int N_pump_status;
	int N_node_pressure;
	int N_pump_pressure;
	int N_tank_level;
	int N_reservoir_head;

	string* IDs_pipe_flow;
	string* IDs_pump_flow;
	string* IDs_pump_status;
	string* IDs_node_pressure;
	string* IDs_pump_pressure;
	string* IDs_tank_level;
	string* IDs_reservoir_head;

	float** pipe_flow;
	float** pump_flow;
	float** pump_status;
	float** node_pressure;
	float** pump_pressure;
	float** tank_level;
	float** reservoir_head;

public:
	SensorData(char input_file[]);
	virtual ~SensorData();
	int getDataSize();
	int getHourIndex(int h);
	float getPipeFlow(string pipe_id, int index);
	float getPumpFlow(string pump_id, int index);
	float getPumpStatus(string pump_id, int index);
	float getNodePressure(string node_id, int index);
	float getPumpPressure(string pump_id, int index);
	float getTankLevel(string tank_id, int index);
	float getReservoirHead(string reservoir_id, int index);
	void allocate2D(float ** &array, int size1, int size2);
	void printToFile(char output_file[]);
};

#endif /* SENSORDATA_H_ */

