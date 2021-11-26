/*
********************
version 17.0
********************
 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M 
* Machine:	Isaac M 											
* Date of creation:	November. 11, 2021  
* Last date of modification: 
* Modifications: 	
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning 'seguimientos de demanda' coded by Marco & Emiliano following the lawsuits of the casefiles graded by Laura.

*******************************************************************************/
*/


import excel "$directorio\Raw\seguimientos\seguimiento_dem.xlsx", sheet("Hoja 1") ///
	cellrange(B4:U586) firstrow clear
	
rename (Junta Expediente Año MododetérminoOFIREC FechadetérminoFechadeúlti Cantidadotorgadaenlaudoaco CantidadpagadaINEGI MododetérminoEXPEDIENTE N CANTIDADOTORGADAENCONVENIOO DummylaudoconveniopagadoCOM Cantidadpagada) ///
	(junta exp anio modo_termino_ofirec fecha_termino_ofirec_ cantidad_ofirec cantidad_inegi modo_termino_exp fecha_termino_exp cantidad_otorgada convenio_pagado_completo cantidad_pagada)
	
*End mode
foreach var of varlist modo_termino_ofirec modo_termino_exp {
	encode `var', gen(`var'_)
	drop `var'
	rename `var'_ `var'
}

*Quantity
foreach var of varlist cantidad_ofirec cantidad_inegi cantidad_otorgada cantidad_pagada {
	destring `var', replace ignore(",")
}

*Date
gen fecha_termino_ofirec = date(fecha_termino_ofirec_, "DMY")
format fecha_termino_ofirec %td

keep junta exp anio modo_termino_ofirec fecha_termino_ofirec cantidad_ofirec cantidad_inegi modo_termino_exp fecha_termino_exp cantidad_otorgada convenio_pagado_completo cantidad_pagada
order junta exp anio modo_termino_ofirec fecha_termino_ofirec cantidad_ofirec cantidad_inegi modo_termino_exp fecha_termino_exp cantidad_otorgada convenio_pagado_completo cantidad_pagada

					
save "$directorio\DB\seguimiento_dem.dta", replace	
