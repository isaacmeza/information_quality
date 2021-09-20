/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file: 		idActorTreatInicialcheck.do
* Author:          		Emiliano Ramírez	
* Machine:        		Emiliano Ramírez PC                          				   				                         				   											
* Date of creation:     sept 16, 2021
* Last date of modification: sept 16, 2021
* Modifications:		
* Files used:     
	- DB/iniciales_dem
	- DB/treatment_data
* Files created:  
	- 
* Purpose:
	- Check if id_actor from treatment_data is the same as id_actor from iniciales 
	via nombre_actor string coincidence. 
*******************************************************************************/
*/

*open iniciales demanda db
clear all
cd $directory


use "DB/iniciales_dem.dta", clear

codebook id_actor

/*
257/1,314 observations have id_actor as missing values

only 1,008/1,314 observations have unique id_actor

*/

*for the purpose of this do file qwe get rid of duplicates
duplicates drop id_actor, force 


*give some processing to names

local var nombre_actor

replace `var' = upper(`var')
replace `var' = subinstr(`var', "  ", " ", .)
replace `var' = strltrim(`var')
replace `var' = strrtrim(`var')
replace `var' = subinstr(`var', ".", "", .)
replace `var' = subinstr(`var', `"""', "", .)
replace `var' = subinstr(`var', " & ", " ", .)
replace `var' = subinstr(`var', "&", "", .)
replace `var' = subinstr(`var', ",", "", .)
replace `var' = subinstr(`var', "ñ", "N", .)
replace `var' = subinstr(`var', "Ñ", "N", .)
replace `var' = subinstr(`var', "-", " ", .)
replace `var' = subinstr(`var', "á", "A", .)
replace `var' = subinstr(`var', "é", "E", .)
replace `var' = subinstr(`var', "í", "I", .)
replace `var' = subinstr(`var', "ó", "O", .)
replace `var' = subinstr(`var', "ú", "U", .)
replace `var' = subinstr(`var', "Á", "A", .)
replace `var' = subinstr(`var', "É", "E", .)
replace `var' = subinstr(`var', "Í", "I", .)
replace `var' = subinstr(`var', "Ó", "O", .)
replace `var' = subinstr(`var', "Ú", "U", .)
replace `var' = subinstr(`var', "â", "A", .)
replace `var' = subinstr(`var', "ê", "E", .)
replace `var' = subinstr(`var', "î", "I", .)
replace `var' = subinstr(`var', "ô", "O", .)
replace `var' = subinstr(`var', "ù", "U", .)
replace `var' = subinstr(`var', "Â", "A", .)
replace `var' = subinstr(`var', "Ê", "E", .)
replace `var' = subinstr(`var', "Î", "I", .)
replace `var' = subinstr(`var', "Ô", "O", .)
replace `var' = subinstr(`var', "Û", "U", .)
replace `var' = subinstr(`var', "LIC. ", "", .)


*open treatment data and and give format to nombre_actor variable

frame create treatmentDF
frame change treatmentDF

use "DB/treatment_data.dta", clear

codebook id_actor

*3,831/3,831 unique id_actor

local var nombre_actor

replace `var' = upper(`var')
replace `var' = subinstr(`var', "  ", " ", .)
replace `var' = strltrim(`var')
replace `var' = strrtrim(`var')
replace `var' = subinstr(`var', ".", "", .)
replace `var' = subinstr(`var', `"""', "", .)
replace `var' = subinstr(`var', " & ", " ", .)
replace `var' = subinstr(`var', "&", "", .)
replace `var' = subinstr(`var', ",", "", .)
replace `var' = subinstr(`var', "ñ", "N", .)
replace `var' = subinstr(`var', "Ñ", "N", .)
replace `var' = subinstr(`var', "-", " ", .)
replace `var' = subinstr(`var', "á", "A", .)
replace `var' = subinstr(`var', "é", "E", .)
replace `var' = subinstr(`var', "í", "I", .)
replace `var' = subinstr(`var', "ó", "O", .)
replace `var' = subinstr(`var', "ú", "U", .)
replace `var' = subinstr(`var', "Á", "A", .)
replace `var' = subinstr(`var', "É", "E", .)
replace `var' = subinstr(`var', "Í", "I", .)
replace `var' = subinstr(`var', "Ó", "O", .)
replace `var' = subinstr(`var', "Ú", "U", .)
replace `var' = subinstr(`var', "â", "A", .)
replace `var' = subinstr(`var', "ê", "E", .)
replace `var' = subinstr(`var', "î", "I", .)
replace `var' = subinstr(`var', "ô", "O", .)
replace `var' = subinstr(`var', "ù", "U", .)
replace `var' = subinstr(`var', "Â", "A", .)
replace `var' = subinstr(`var', "Ê", "E", .)
replace `var' = subinstr(`var', "Î", "I", .)
replace `var' = subinstr(`var', "Ô", "O", .)
replace `var' = subinstr(`var', "Û", "U", .)
replace `var' = subinstr(`var', "LIC. ", "", .)


*change varname for recovery later
gen nombre_actorTD=nombre_actor


*change to default frame 
frame change default

*link iniciales_dem with treatment_data
frlink 1:1 id_actor, frame(treatmentDF) 
* (3 observations in frame default unmatched)

*recover nombre_actorTD from treatment_data
frget nombre_actorTD treatment, from(treatmentDF)

*give format to treatment variable

*NOTE: treatment variable is defined as this 

/*
Freq.   Numeric  Label
  383         1  1A
  248         2  1B
  175         3  2A
   76         4  2B
  124         5  3
	3         .  
*/

*but tratamiento inical_dem's variable does not hace 2A and 2B arms if we put those arms together then the following lines continue

replace treatment=3 if treatment==4
replace treatment=4 if treatment==5

*now we check how smilar are nombre_actor frome each db
gen dummyNombreActorSame = [nombre_actor==nombre_actorTD]

/*
dummyNombre |
  ActorSame |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        171       16.95       16.95
          1 |        838       83.05      100.00
------------+-----------------------------------
      Total |      1,009      100.00

*/

*since some observations from iniciales_dem has similar nombre_actor but with order name reversal compared with nombre_actorTD wea are going to use strpos

egen nombre_actorHead=ends(nombre_actor), trim head
egen nombre_actorLast=ends(nombre_actor), trim last

gen containStringHead = strpos(nombre_actorTD, nombre_actorHead)
gen containStringLast = strpos(nombre_actorTD, nombre_actorLast)

*we make a fuzzy dummyNombreActorSame

gen dummyNombreActorFuzz=[containStringLast>0 | containStringHead>0]

/*
dummyNombre |
  ActorFuzz |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         51        5.05        5.05
          1 |        958       94.95      100.00
------------+-----------------------------------
      Total |      1,009      100.00

*/

gen dummyTreatmentSame =[tratamiento == treatment]

tab dummyTreatmentSame

/*
dummyTreatm |
    entSame |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         11        1.09        1.09
          1 |        998       98.91      100.00
------------+-----------------------------------
      Total |      1,009      100.00
*/


*¿qué pasa con la interseccion de los que no coiniciden en nombre ni en tratamiento?

*¿cuántos expedintes calificados no tienen iniciales? 