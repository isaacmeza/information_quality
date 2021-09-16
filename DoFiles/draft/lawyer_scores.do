/*
Analysis of lawyer scores. Predicting power of scores to objective output measures and correlation 
of input measures with grades. Which is best to predict output : scores or input variables?
Author : Isaac Meza
*/

use "$directorio\DB\iniciales_dem.dta" , clear
merge m:1 junta exp anio using "$directorio\DB\lawyer_scores_p3.dta", nogen keep(3)
br
reg total calif*, r

gen termino = (estatus==3)

reg termino calif*, r
reg termino c.calif*##c.calif*, r
logit termino calif*, r

gen convenio = (modo_termino==2)

reg convenio calif*, r




histogram calif_derechos
histogram calif_rubro

twoway (histogram calif_derechos) (hist calif_rubro)
scatter total sueldo_estadistico if sueldo_estadistico < 20000


