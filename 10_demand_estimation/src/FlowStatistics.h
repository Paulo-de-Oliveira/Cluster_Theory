/*
 * FlowStatistics.h
 *
 *  Created on: Aug 23, 2018
 *      Author: Marry
 */

#ifndef FLOWSTATISTICS_H_
#define FLOWSTATISTICS_H_

class FlowStatistics {
private:
	int sample_total_size;
	int n_links;
	int start_sample_size;
	float** start_sample;
	double* sum_x;
	double* sum_x2;

public:
	FlowStatistics(int number_of_links, int initial_sample_size);
	virtual ~FlowStatistics();
	//both n and link_index start from 1
	void SetStartValue(int n, int link_index, float value);
	//This function is suppose to be executed after the StarValue matrix is full
	void StartMoments();
	//This function adds one link flow per time and update the moments
	void UpdateMoment(int link_index, float value);
	void IncreaseSampleSize();
	double GetTotalVariance();
	void ClearAllData();
	void printVarianceToFile(char output_file[]);
	void printMeanToFile(char output_file[]);
};

#endif /* FLOWSTATISTICS_H_ */
