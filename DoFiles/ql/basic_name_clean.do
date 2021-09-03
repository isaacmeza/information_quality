*Basic name cleaning

*-------------------------------------------------------------------------------

args var /*Name variable to clean*/

*Remove blank spaces
replace `var'=stritrim(trim(itrim(upper(`var'))))

*Basic name cleaning 
replace `var' = subinstr(`var', ".", "", .)
replace `var' = subinstr(`var', " & ", " ", .)
replace `var' = subinstr(`var', "&", "", .)
replace `var' = subinstr(`var', " Y ", " ", .)
replace `var' = subinstr(`var', ",", " | ", .)
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
replace `var' = subinstr(`var', "-", " ", .)

*Remove special characters
gen newname = "" 
gen length = length(`var') 
su length, meanonly 

forval i = 1/`r(max)' { 
     local char substr(`var', `i', 1) 
     local OK inrange(`char', "a", "z") | inrange(`char', "A", "Z")  | `char'==" " | `char'=="|"
     replace newname = newname + `char' if `OK' 
}
replace `var'=newname
drop newname length

replace `var'=stritrim(trim(itrim(upper(`var'))))


