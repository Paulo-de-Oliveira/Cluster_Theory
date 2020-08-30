/*
 * GlobalPattern.cpp
 *
 *  Created on: Nov 6, 2017
 *      Author: oliveipa
 */

#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <stdlib.h>
#include "GlobalPattern.h"
using namespace std;


Global_Pattern::Global_Pattern(char input_file[]) {

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

	//Defining the data size
	data_size = row;

	//Allocating the pointers
	hour = new int[row];
	pattern = new float[row];

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
					hour[row] = atoi(token.c_str());
				}
				if(col == 1){
					pattern[row] = atof(token.c_str());
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

Global_Pattern::~Global_Pattern() {
	delete[] hour;
	delete[] pattern;
}

int Global_Pattern::getDataSize(){
	return(data_size);
}

float Global_Pattern::getPattern(int h){

	float pat = -1;
	int pos = 0;

	while(hour[pos] != h && pos < data_size){
		pos++;
	}

	if(hour[pos] == h){
		pat = pattern[pos];
	}

	return(pat);
}

void Global_Pattern::PrintToFile(char output_file[]){

	ofstream myfile;
	myfile.open (output_file);
	myfile << "data size: " << data_size << endl;
	myfile << "hour,pattern" << endl;

	for(int i = 0; i < data_size; i++){
		myfile << hour[i] << "," << pattern[i] << endl;
	}

	myfile.close();
}
