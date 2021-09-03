*Do file that updates Pilot3 Document

********************************************************************************


********************************************************************************
*								   	OPERATIONAL		  				  		   *
********************************************************************************
*Prepare for RD
do "$directorio\DoFiles\rd.do"


********************************************************************************
*						     			SS							  		   *
********************************************************************************
*Summary statistics table
do "$directorio\DoFiles\SS.do"
do "$directorio\DoFiles\SS_pres.do"

*Cumulative number of cases
do "$directorio\DoFiles\cum_num_cases.do"
do "$directorio\DoFiles\cum_num_cases_wattrition.do"


********************************************************************************
*						     		BALANCE							  		   *
********************************************************************************
*Cumulative p-value distribution
do "$directorio\DoFiles\pvalue_time_reg.do"

*Balance table/reg
do "$directorio\DoFiles\Balance_reg.do"
do "$directorio\DoFiles\reg_balance.do"


********************************************************************************
*						        	ATTRITION						  		   *
********************************************************************************
*SS
do "$directorio\DoFiles\response_rate.do"

*Attrition ss/regressions
do "$directorio\DoFiles\ss_attrition.do"
do "$directorio\DoFiles\reg_attrition.do"
do "$directorio\DoFiles\reg_attrition_ab.do"

*Predict attrition
do "$directorio\DoFiles\predict_attrition_reg.do"



********************************************************************************
*						   	CHARACTERISTICS REGRESSION			    		   *
********************************************************************************
*Lawyers characteristics
do "$directorio\DoFiles\lawyers_info_reg.do"

*Formation expectations
	*by treatment
do "$directorio\DoFiles\formation_exp.do"
	*by lawyer
do "$directorio\DoFiles\formation_exp_lawyer.do"

*Relation sue-talked
do "$directorio\DoFiles\talked_sue.do"

*Welfare
do "$directorio\DoFiles\welfare_reg_2m.do"
do "$directorio\DoFiles\welfare_reg_lawyer_iv.do"
do "$directorio\DoFiles\find_lawyer.do"


********************************************************************************
*						  		 	EXPECTATIONS				    		   *
********************************************************************************
*SS
do "$directorio\DoFiles\histograms_expectations.do"
do "$directorio\DoFiles\lpoly_exp_treat.do"
do "$directorio\DoFiles\lpoly_exp_treat_nocondition.do"


*Expectation
	*Baseline
do "$directorio\DoFiles\reg_baseline_exp.do"	
do "$directorio\DoFiles\reg_exp_casefile.do"	
	*After treatment
do "$directorio\DoFiles\reg_at.do"

*Expectations and characteristics of talked to lawyers (2W)
do "$directorio\DoFiles\reg_expectations_talked.do"
*Expectations and characteristics of suers (2M)
do "$directorio\DoFiles\reg_expectations_sue.do"

*Expectations by type of lawyer
do "$directorio\DoFiles\exp_type_lawyer.do"
	*Instrumenting with B arm
do "$directorio\DoFiles\iv_exp_law.do"
do "$directorio\DoFiles\iv_exp_law_2.do"
	*Lee bounds
do "$directorio\DoFiles\lb_exp_lawyer.do"

*Update by type of lawyer
do "$directorio\DoFiles\reg_pub_pri_exp.do"


*Updating
do "$directorio\DoFiles\reg_updating.do"
do "$directorio\DoFiles\plot_lee_bounds_exp.do"
*Impact of update in settelement 2sls
do "$directorio\DoFiles\iv_update_exp.do"
*Update by type of lawyer
do "$directorio\DoFiles\update_type_law.do"
*Update against treatment arms
do "$directorio\DoFiles\update_treatment.do"



********************************************************************************
*						   	TREATMENT REGRESSION					  		   *
********************************************************************************
*Main results
do "$directorio\DoFiles\reg_te.do"

*Main results 2w2m sample
do "$directorio\DoFiles\reg_main_arms_2w2m_sample.do"

*IV results
do "$directorio\DoFiles\iv_cf_pl_sue.do"
*Include old A/B or not?
do "$directorio\DoFiles\iv_cf_pl_sue_admin.do"

*Pre/Post 19S
do "$directorio\DoFiles\reg_te_19s.do"

*Bounds
do "$directorio\DoFiles\plot_lee_bounds.do"

*Conditional on already formed expectations
do "$directorio\DoFiles\reg_te_cond_exp.do"

*Admin data
do "$directorio\DoFiles\reg_admin_comp.do"



********************************************************************************
*						   			APPENDIX			   		    		   *
********************************************************************************
*T1-T2 became undistinguishable
do "$directorio\DoFiles\diff_beta_disc_t1.do"




discard
clear
