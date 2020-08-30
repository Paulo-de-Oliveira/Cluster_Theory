/*
 * FlowStatistics.cpp
 *
 *  Created on: Aug 23, 2018
 *      Author: Marry
 */

#include "FlowStatistics.h"
#include <fstream>
using namespace std;

FlowStatistics::FlowStatistics(int number_of_links, int initial_sample_size) {

	sample_total_size = 0;
	n_links = number_of_links;
	start_sample_size = initial_sample_size;

	sum_x = new double[n_links];
	sum_x2 = new double[n_links];

	start_sample = new float*[start_sample_size];
	for(int i = 0; i < start_sample_size; ++i){
		start_sample[i] = new float[n_links];
	}

}

FlowStatistics::~FlowStatistics() {

	delete[] sum_x;
	delete[] sum_x2;

	for (int i = 0; i < start_sample_size; i++) {
		delete[] start_sample[i];
	}
	delete[] start_sample;
}

void FlowStatistics::SetStartValue(int n, int link_index, float value){

	//both n and link_index start from 1
	int row = n-1;
	int col = link_index-1;

	start_sample[row][col] = value;
}

void FlowStatistics::StartMoments(){

	//This function is suppose to be executed after the StarValue matrix is full
	int col;
	int row;
	double value;
	double ssx;
	double ssx2;

	for(int link_index = 1; link_index <= n_links; ++link_index){

		col = link_index - 1;
		ssx = 0;
		ssx2 = 0;

		for(int data_point = 1; data_point <= start_sample_size; ++data_point){

			row = data_point - 1;
			value = (double) start_sample[row][col];

			ssx = ssx + value;
			ssx2 = ssx2 + value*value;
		}

		sum_x[col] = ssx;
		sum_x2[col] = ssx2;

	}

	sample_total_size = start_sample_size;

}

void FlowStatistics::UpdateMoment(int link_index, float value){

	int col = link_index - 1;
	double value_double;

	value_double = (double) value;

	sum_x[col] = sum_x[col] + value_double;
	sum_x2[col] = sum_x2[col] + value_double*value_double;
}

void FlowStatistics::IncreaseSampleSize(){
	sample_total_size = sample_total_size + 1;
}

double FlowStatistics::GetTotalVariance(){

	double total_variance = 0;
	double variance;
	int col;
	double ssx;
	double ssx2;

	int n = sample_total_size;

	for(int link_index = 1; link_index <= n_links; ++link_index){

		col = link_index - 1;
		ssx = sum_x[col];
		ssx2 = sum_x2[col];

		variance = ( ssx2/n - (ssx/n)*(ssx/n) )*n/(n-1);
		total_variance = total_variance + variance;

	}

	return(total_variance);
}

void FlowStatistics::ClearAllData(){

	sample_total_size = 0;

	for(int i = 0; i < start_sample_size; ++i){
	for(int j = 0; j < n_links; ++j){
		start_sample[i][j] = 0;
	}
	}

	for(int i = 0; i < n_links; ++i){
		sum_x[i] = 0;
		sum_x2[i] = 0;
	}
}

void FlowStatistics::printVarianceToFile(char output_file[]){

	ofstream myfile;
	myfile.open (output_file);

	int col;
	double ssx;
	double ssx2;
	double variance;

	int n = sample_total_size;

	for(int link_index = 1; link_index <= n_links; ++link_index){

		col = link_index - 1;
		ssx = sum_x[col];
		ssx2 = sum_x2[col];

		variance = ( ssx2/n - (ssx/n)*(ssx/n) )*n/(n-1);
		myfile << variance << endl;
	}

	myfile.close();
}

void FlowStatistics::printMeanToFile(char output_file[]){

	ofstream myfile;
	myfile.open (output_file);

	int col;
	double ssx;
	double mean;

	int n = sample_total_size;

	for(int link_index = 1; link_index <= n_links; ++link_index){

		col = link_index - 1;
		ssx = sum_x[col];

		mean = ssx/n;
		myfile << mean << endl;
	}

	myfile.close();
}
