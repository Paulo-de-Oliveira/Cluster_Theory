/*
 * SensorData.cpp
 *
 *  Created on: Nov 7, 2017
 *      Author: oliveipa
 */

#include <iostream>
#include "SensorData.h"
#include <fstream>
#include <string>
#include <sstream>
#include <stdlib.h>
using namespace std;

SensorData::SensorData(char input_file[]) {

	//Opening the input file
	ifstream myfile;
	myfile.open (input_file);

	//Get the first line
	string line;
	getline(myfile, line);

	//Counting how many columns we have
	stringstream iss(line);
	string token;
	int col = 0;
	while (getline(iss, token, ',')){
		col++;
	}
	int number_of_columns = col;

	//Creating the reference pointers
	char* reference_type;
	int* reference_position;
	reference_type = new char[number_of_columns];
	reference_position = new int[number_of_columns];
	reference_type[0] = ' ';
	reference_position[0] = 0;

	//Initializing the amount of data for each type
	N_pipe_flow = 0;
	N_pump_flow = 0;
	N_pump_status = 0;
	N_node_pressure = 0;
	N_pump_pressure = 0;
	N_tank_level = 0;
	N_reservoir_head = 0;

	//Fill the reference pointers
    int	token_length;
    char sufix;
    col = 0;
    iss.clear();
    iss.str(line);
    getline(iss, token, ',');

    while (getline(iss, token, ',')){
 		col++;
		token_length = token.length();
		sufix = token.at(token_length-1);
		reference_type[col] = sufix;

		switch ( sufix ) {
		case 'Q':
			reference_position[col] = N_pipe_flow;
			N_pipe_flow++;
			break;
		case 'F':
			reference_position[col] = N_pump_flow;
			N_pump_flow++;
			break;
		case 'C':
			reference_position[col] = N_pump_status;
			N_pump_status++;
			break;
		case 'P':
			reference_position[col] = N_node_pressure;
			N_node_pressure++;
			break;
		case 'B':
			reference_position[col] = N_pump_pressure;
			N_pump_pressure++;
			break;
		case 'L':
			reference_position[col] = N_tank_level;
			N_tank_level++;
			break;
		case 'H':
			reference_position[col] = N_reservoir_head;
			N_reservoir_head++;
			break;
		  }
	}

    //Allocating the string ID pointers
	IDs_pipe_flow = new string[N_pipe_flow];
	IDs_pump_flow = new string[N_pump_flow];
	IDs_pump_status = new string[N_pump_status];
	IDs_node_pressure = new string[N_node_pressure];
	IDs_pump_pressure = new string[N_pump_pressure];
	IDs_tank_level = new string[N_tank_level];
	IDs_reservoir_head = new string[N_reservoir_head];

	//Counting how many rows of data we have
	int row = 0;
	if (myfile.is_open())
	{
		while (getline(myfile, line)){
		row++;
		}
	}else{
		cout << "Error opening file";
	}

	//Defining the data size
	data_size = row;

	//Allocating the hour pointer
	hour = new int[data_size];

	//Allocating the sensor data pointers
	this->allocate2D(pipe_flow, N_pipe_flow, data_size);
	this->allocate2D(pump_flow, N_pump_flow, data_size);
	this->allocate2D(pump_status, N_pump_status, data_size);
	this->allocate2D(node_pressure, N_node_pressure, data_size);
	this->allocate2D(pump_pressure, N_pump_pressure, data_size);
	this->allocate2D(tank_level, N_tank_level, data_size);
	this->allocate2D(reservoir_head, N_reservoir_head, data_size);

 	//Going back to the begining of the file
	myfile.clear();
	myfile.seekg(0, ios::beg);

	//Get the first line
	getline(myfile, line);

	//Fill the ID pointers
	int position;
	col = 0;
    iss.clear();
    iss.str(line);

    getline(iss, token, ',');//skip the first column

    while (getline(iss, token, ',')){
 		col++;
		sufix = reference_type[col];
		position = reference_position[col];
		token.erase(token.end()-1, token.end());

		switch ( sufix ) {
		case 'Q':
			IDs_pipe_flow[position] = token;
			break;
		case 'F':
			IDs_pump_flow[position] = token;
			break;
		case 'C':
			IDs_pump_status[position] = token;
			break;
		case 'P':
			IDs_node_pressure[position] = token;
			break;
		case 'B':
			IDs_pump_pressure[position] = token;
			break;
		case 'L':
			IDs_tank_level[position] = token;
			break;
		case 'H':
			IDs_reservoir_head[position] = token;
			break;
		  }
	}

    //Fill the sensor data pointers

	//Reading the values to the pointers
    float value;
    row = 0;
	if (myfile.is_open())
	{
		while (getline(myfile, line)){

			iss.clear();
			iss.str(line);
			col = 0;
			while (getline(iss, token, ',')){
				if(col == 0){
					hour[row] = atoi(token.c_str());
				}else{
					value = atof(token.c_str());
					sufix = reference_type[col];
					position = reference_position[col];

					switch ( sufix ) {
					case 'Q':
						pipe_flow[position][row] = value;
						break;
					case 'F':
						pump_flow[position][row] = value;
						break;
					case 'C':
						pump_status[position][row] = value;
						break;
					case 'P':
						node_pressure[position][row] = value;
						break;
					case 'B':
						pump_pressure[position][row] = value;
						break;
					case 'L':
						tank_level[position][row] = value;
						break;
					case 'H':
						reservoir_head[position][row] = value;
						break;
					  }
				}
				col++;
			}
			row++;
		}
	}else{
		cout << "Error opening file";
	}

	myfile.close();

}

SensorData::~SensorData() {

	delete[] hour;

	delete[] IDs_pipe_flow;
	delete[] IDs_pump_flow;
	delete[] IDs_pump_status;
	delete[] IDs_node_pressure;
	delete[] IDs_pump_pressure;
	delete[] IDs_tank_level;
	delete[] IDs_reservoir_head;

	for (int i = 0; i < N_pipe_flow; i++) {
		delete[] pipe_flow[i];
	}
	delete[] pipe_flow;

	for (int i = 0; i < N_pump_flow; i++) {
		delete[] pump_flow[i];
	}
	delete[] pump_flow;

	for (int i = 0; i < N_pump_status; i++) {
		delete[] pump_status[i];
	}
	delete[] pump_status;

	for (int i = 0; i < N_node_pressure; i++) {
		delete[] node_pressure[i];
	}
	delete[] node_pressure;

	for (int i = 0; i < N_pump_pressure; i++) {
		delete[] pump_pressure[i];
	}
	delete[] pump_pressure;

	for (int i = 0; i < N_tank_level; i++) {
		delete[] tank_level[i];
	}
	delete[] tank_level;

	for (int i = 0; i < N_reservoir_head; i++) {
		delete[] reservoir_head[i];
	}
	delete[] reservoir_head;

}

void SensorData::allocate2D(float ** &array, int size1, int size2){
	array = new float*[size1];
	for(int i = 0; i < size1; ++i)
	    array[i] = new float[size2];
}

int SensorData::getDataSize(){
	return(data_size);
}

int SensorData::getHourIndex(int h){
	int index = -1;
	int pos = 0;

	while(hour[pos] != h && pos < data_size){
		pos++;
	}

	if(hour[pos] == h){
		index = pos;
	}

	return(index);
}

float SensorData::getPipeFlow(string pipe_id, int index){
	int pos = 0;

	while(IDs_pipe_flow[pos] != pipe_id && pos < N_pipe_flow){
		pos++;
	}

	if(IDs_pipe_flow[pos] == pipe_id){
		return(pipe_flow[pos][index]);
	}else{
		return(-1);
	}
}

float SensorData::getPumpFlow(string pump_id, int index){
	int pos = 0;

	while(IDs_pump_flow[pos] != pump_id && pos < N_pump_flow){
		pos++;
	}

	if(IDs_pump_flow[pos] == pump_id){
		return(pump_flow[pos][index]);
	}else{
		return(-1);
	}
}

float SensorData::getPumpStatus(string pump_id, int index){
	int pos = 0;

	while(IDs_pump_status[pos] != pump_id && pos < N_pump_status){
		pos++;
	}

	if(IDs_pump_status[pos] == pump_id){
		return(pump_status[pos][index]);
	}else{
		return(-1);
	}
}

float SensorData::getNodePressure(string node_id, int index){
	int pos = 0;

	while(IDs_node_pressure[pos] != node_id && pos < N_node_pressure){
		pos++;
	}

	if(IDs_node_pressure[pos] == node_id){
		return(node_pressure[pos][index]);
	}else{
		return(-1);
	}
}

float SensorData::getPumpPressure(string pump_id, int index){
	int pos = 0;

	while(IDs_pump_pressure[pos] != pump_id && pos < N_pump_pressure){
		pos++;
	}

	if(IDs_pump_pressure[pos] == pump_id){
		return(pump_pressure[pos][index]);
	}else{
		return(-1);
	}
}

float SensorData::getTankLevel(string tank_id, int index){
	int pos = 0;

	while(IDs_tank_level[pos] != tank_id && pos < N_tank_level){
		pos++;
	}

	if(IDs_tank_level[pos] == tank_id){
		return(tank_level[pos][index]);
	}else{
		return(-1);
	}
}

float SensorData::getReservoirHead(string reservoir_id, int index){
	int pos = 0;

	while(IDs_reservoir_head[pos] != reservoir_id && pos < N_reservoir_head){
		pos++;
	}

	if(IDs_reservoir_head[pos] == reservoir_id){
		return(reservoir_head[pos][index]);
	}else{
		return(-1);
	}
}

void SensorData::printToFile(char output_file[]){

	ofstream myfile;
	myfile.open (output_file);

	myfile << "hour,";

	for(int i = 0; i < N_pipe_flow ; i++){
		myfile << IDs_pipe_flow[i] << "Q,";
	}

	for(int i = 0; i < N_pump_flow ; i++){
		myfile << IDs_pump_flow[i] << "F,";
	}

	for(int i = 0; i < N_pump_status ; i++){
		myfile << IDs_pump_status[i] << "C,";
	}

	for(int i = 0; i < N_node_pressure ; i++){
		myfile << IDs_node_pressure[i] << "P,";
	}

	for(int i = 0; i < N_pump_pressure ; i++){
		myfile << IDs_pump_pressure[i] << "B,";
	}

	for(int i = 0; i < N_tank_level ; i++){
		myfile << IDs_tank_level[i] << "L,";
	}

	for(int i = 0; i < N_reservoir_head ; i++){
		myfile << IDs_reservoir_head[i] << "H,";
	}

	myfile << endl;


	for(int j = 0; j < data_size; j++){

		myfile << hour[j] << ",";

		for(int i = 0; i < N_pipe_flow ; i++){
				myfile << pipe_flow[i][j] << ",";
		}

		for(int i = 0; i < N_pump_flow ; i++){
			myfile << pump_flow[i][j] << ",";
		}

		for(int i = 0; i < N_pump_status ; i++){
			myfile << pump_status[i][j] << ",";
		}

		for(int i = 0; i < N_node_pressure ; i++){
			myfile << node_pressure[i][j] << ",";
		}

		for(int i = 0; i < N_pump_pressure ; i++){
			myfile << pump_pressure[i][j] << ",";
		}

		for(int i = 0; i < N_tank_level ; i++){
			myfile << tank_level[i][j] << ",";
		}

		for(int i = 0; i < N_reservoir_head ; i++){
			myfile << reservoir_head[i][j] << ",";
		}

		myfile << endl;

	}

}

