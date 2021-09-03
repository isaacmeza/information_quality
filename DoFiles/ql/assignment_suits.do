*Selection of suits from id's

use "$directorio\DB\lawyer_dataset_collapsed.dta", clear

*Keep only id's to test
keep if  inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10)						
keep office_emp_law id
tempfile temp
save `temp'

use "$directorio\DB\lawyer_dataset.dta", clear
duplicates drop
duplicates drop junta exp anio, force
merge m:1 office_emp_law using `temp', nogen
keep if !missing(id)

*Seed
set seed X5f477e32ccbd3e6487cdece355f57f2a00041b66

*Random selection of suits
bysort office_emp_law : gen draw=(runiform()<=(8/repeats))
 
*Select 5 suits from each id
bysort office_emp_law : gen num_draw=sum(draw)  
replace draw=0 if num_draw>5
  
*Keep sample of 50 suits 
keep if draw==1
count

sort id junta exp anio
preserve
keep junta exp anio
save "$directorio\_aux\assignment_1.dta", replace
restore

order id junta exp anio
rename id despacho
export delimited using "$directorio\DB\lawyer_dataset_sample.csv", replace
drop  office_emp_law gp_office_emp_law nombre_abogado_1 nombre_abogado_2 nombre_abogado_3 abogados_orden gp_orden repeats draw  num_draw
*Anonimize
export delimited using "$directorio\DB\lawyer_dataset_sampleanon.csv", replace

