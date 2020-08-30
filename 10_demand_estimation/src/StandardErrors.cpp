/*
 * StandardErrors.cpp
 *
 *  Created on: Aug 21, 2018
 *      Author: Marry
 */

#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <stdlib.h>
#include "StandardErrors.h"
using namespace std;

StandardErrors::StandardErrors(char input_file[]) {

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

	//Counting how many rows we have
	int row = 0;
	if (myfile.is_open())
	{
		while (getline(myfile, line)){
		row++;
		}
		myfile.close();
	}else{
		cout << "Error opening file";
	}

	//Defining the number of nodes
	number_of_sensors = row;

	//Allocating the pointers
	sensor_id = new string[row];
	std_error = new float[row];

	//Opening the input file again
	myfile.open (input_file);
	getline(myfile, line);

	//Reading the values to the pointers
	row = 0;
	if (myfile.is_open())
	{
		while (getline(myfile, line)){

			iss.clear();
			iss.str(line);
			col = 0;
			while (getline(iss, token, ',')){
				if(col == 0){
					sensor_id[row] = token;
				}
				if(col == 1){
					std_error[row] = atof(token.c_str());
				}
				col++;
			}
			row++;
		}
		myfile.close();
	}else{
		cout << "Error opening file";
	}

}

StandardErrors::~StandardErrors() {
	delete[] sensor_id;
	delete[] std_error;
}

int StandardErrors::getNumberOfSensors(){
	return(number_of_sensors);
}

string StandardErrors::getSensorID(int index){
	return(sensor_id[index]);
}

float StandardErrors::getSensorStdev(string id){

	float stdev = -1;
	int pos = 0;

	while(sensor_id[pos] != id && pos < number_of_sensors){
		pos++;
	}

	if(sensor_id[pos] == id){
		stdev = std_error[pos];
	}

	return(stdev);
}

void StandardErrors::PrintToFile(char output_file[]){

	ofstream myfile;
	myfile.open (output_file);
	myfile << "number of sensors: " << number_of_sensors << endl;
	myfile << "sensor_id,stdev" << endl;

	for(int i = 0; i < number_of_sensors; i++){
		myfile << sensor_id[i] << "," << std_error[i] << endl;
	}

	myfile.close();

}




