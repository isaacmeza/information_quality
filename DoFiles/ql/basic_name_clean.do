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
replace `var' = subinstr(`var', "�", "N", .)
replace `var' = subinstr(`var', "-", " ", .)
replace `var' = subinstr(`var', "�", "A", .)
replace `var' = subinstr(`var', "�", "E", .)
replace `var' = subinstr(`var', "�", "I", .)
replace `var' = subinstr(`var', "�", "O", .)
replace `var' = subinstr(`var', "�", "U", .)
replace `var' = subinstr(`var', "�", "A", .)
replace `var' = subinstr(`var', "�", "E", .)
replace `var' = subinstr(`var', "�", "I", .)
replace `var' = subinstr(`var', "�", "O", .)
replace `var' = subinstr(`var', "�", "U", .)
replace `var' = subinstr(`var', "�", "A", .)
replace `var' = subinstr(`var', "�", "E", .)
replace `var' = subinstr(`var', "�", "I", .)
replace `var' = subinstr(`var', "�", "O", .)
replace `var' = subinstr(`var', "�", "U", .)
replace `var' = subinstr(`var', "�", "A", .)
replace `var' = subinstr(`var', "�", "E", .)
replace `var' = subinstr(`var', "�", "I", .)
replace `var' = subinstr(`var', "�", "O", .)
replace `var' = subinstr(`var', "�", "U", .)
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


