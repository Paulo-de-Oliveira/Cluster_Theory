/*
 * EstimationOptions.h
 *
 *  Created on: Mar 12, 2018
 *      Author: oliveipa
 */

#ifndef ESTIMATIONOPTIONS_H_
#define ESTIMATIONOPTIONS_H_

using namespace std;

class Estimation_Options {
private:
	int clusters;
	int chain_size;
	int burn_in;
	float proposal_std;
	float prior_std;
	int estimation_time_begin;
	int estimation_time_end;
public:
	Estimation_Options(char input_file[]);
	virtual ~Estimation_Options();
	int get_clusters();
	int get_chain_size();
	int get_burn_in();
	float get_proposal_std();
	float get_prior_std();
	int get_estimation_time_begin();
	int get_estimation_time_end();
};


#endif /* ESTIMATIONOPTIONS_H_ */
