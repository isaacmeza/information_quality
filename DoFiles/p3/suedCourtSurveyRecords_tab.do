/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file: 		suedCourtSurveyRecords_tab.do
* Author:          		Enrique Miranda, Sergio Lopez and revisited and edited by
							Emiliano Ramírez	
* Machine:        		Emiliano Ramirez PC                          				   				                         				   											
* Date of creation:     Sept. 17, 2021
* Last date of modification:   
* Modifications:		
* Files used:     
	-
* Files created:  
	- 
* Purpose:
	- Generate table 5 of Suing according to clients and according to court records
	from Pilot 3 March 2020 draft. 
*******************************************************************************/
*/

*directory 

cd $directorio 
clear all

*First open treatment database 
use "DB\treatment_data.dta", clear 

*we need the coyote variable, so we merge our treatment variable with survey 2 months follow up 
merge 1:1 id_actor using "DB/survey_data_2m.dta" 

*we keep only those that matched 
keep if _merge==3
drop _merge 

*now we need inicales demanda information for our treatment observation, thus we merge with iniciales_dem db
merge 1:1 id_actor using "DB/iniciales_dem.dta" 


*[pendiente]



