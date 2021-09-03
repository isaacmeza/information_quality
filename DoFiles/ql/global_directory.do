clear
set more off

global F5 "br;"
global directorio C:\Users\joyce\Documents\lawyers\quality_lawyers



********************************************************************************
*Variables to include in analysis
global input_varlist wage rel_procu rel_ent dw_scian dw_giro_procu indem sal_caidos prima_antig ///
	prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad ///
	codem reinst
global output_varlist pos_rec settlement cr win_asked winpos_asked win_minley win_cprocu duration
global varlist_checklist repre cod_pos contador_desp sal_base sal_dos nulidad imss ptu rec_respo ad_cautelam


global bvc gen horas_sem  salario_diario abogado_pub  c_antiguedad 	


*Exclusion SD from varlist
*(we exclude all benefits for the sd)
local exclude= "indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst"

global sd_varlist_input = " "
foreach var in $input_varlist  {
	*Exclude from varlist SD, those in `exclude'
	if strpos("`exclude'", "`var'")==0	{
		global sd_varlist_input = "${sd_varlist_input} sd_`var'"
		}
	}	

global sd_varlist_output = " "
foreach var in $output_varlist  {
	*Exclude from varlist SD, those in `exclude'
	if strpos("`exclude'", "`var'")==0	{
		global sd_varlist_output = "${sd_varlist_output} sd_`var'"
		}
	}		
	
********************************************************************************	
*List of Id's to highlight
global lista1=122
global lista2=2
global lista3=65
global lista4=69
global lista5=15
global lista6=51
global lista7=27
global lista8=101
global lista9=41
global lista10=81	
