/*==================================================
Name:           4_analysis_cem.do

Project:        Coarsened Exact Matching (CEM)
                Outcome: valor_avaluo
Author:         Maria Corina Hernandez
E-email:        mc.hernandezl12@uniandes.edu.co

----------------------------------------------------
Creation Date:  02 Feb 2026
Output:         
==================================================*/

/*==================================================
              0: Program set up
==================================================*/

clear all
set more off

** Path
/// global dir_0 "C:\Users\Alan\Dropbox\CEM\\"
global dir_0 "C:\Users\USUARIO\Documents\GitHub\TIF_PLMB\\"

** Data
global dir_data "${dir_0}Datos\\"
global dir_raw "${dir_data}raw\\"
global dir_proc "${dir_data}processed\\"
global dir_outcomes "${dir_data}outcomes\\"

** Data
/// global dir_data "${dir_0}DATA\\"

** Paquetes 
** ssc install cem

/*==================================================
      1: Importar datos 
==================================================*/

** Importar los datos 
use "${dir_proc}predios_proc", clear

** Dejar solo el periodo antes del tratamiento 
keep if year==2018 

** Eliminar la variable de año 
drop year

/*==================================================
      3: Arreglar las variables que son 
		 base del matching
==================================================*/

/* Crear variables dummy a partir del destino 
   del inmueble */

** Residencial 
gen dest_residencial = (descripcion_destino=="RESIDENCIAL")

** Comercial
#d;
	gen dest_comercial = inlist(descripcion_destino,
		"COMERCIO EN CORREDOR COM",
		"COMERCIO PUNTUAL",
		"COMERCIO EN CENTRO COMER",
		"PARQUEADEROS");
#d cr

** Industrial
#d;
	gen dest_industrial = inlist(descripcion_destino,
		"INDUSTRIAL",
		"MINERO");
#d cr

** Agricola / rural
#d;
	gen dest_agricola = inlist(descripcion_destino,
		"AGRICOLA",
		"AGROPECUARIO",
		"PECUARIO",
		"AGROINDUSTRIAL",
		"FORESTAL",
		"PREDIO RURAL PARCEL. NO EDIFI.");
#d cr

** Otros (todo lo que no cae en las categorias anteriores)
#d;
      gen dest_otros = (dest_residencial==0 & 
                        dest_comercial==0 & 
                        dest_industrial==0 & 
                        dest_agricola==0);
#d cr 

/*==================================================
      4: Coarsened Exact Matching (CEM)
==================================================*/

** Realizar el CEM y crear los pesos
#d;
	cem area_terreno codigo_estrato (0 1.5 2.5 3.5 4.5 5.5 6.5)
	area_construida max_num_piso 
	dest_residencial dest_comercial 
	dest_industrial dest_agricola dest_otros, treatment(treatment);
#d cr

** Inspeccionar las observaciones con match
tab treatment cem_matched

** Dejar solo las observaciones con match 
drop if cem_matched==0

** Dejar solo las variables relevantes para el match 
#d; 
	keep codigo_lote cem_weights cem_matched 
		 cem_strata codigo_construccion codigo_resto;
#d cr 

** Guardar la base con los pesos
save "${dir_proc}treat_weights.dta", replace

/*==================================================
      5: Pegar al panel y realizar la estimación
==================================================*/

*--- Merge con el panel  original 
#d;
	merge 1:m codigo_lote codigo_construccion codigo_resto 
		using "${dir_proc}predios_proc", gen(_pegados);
#d cr

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       298,332
        from master                         0  (_pegados==1)
        from using                    298,332  (_pegados==2)

    Matched                        27,383,112  (_pegados==3)
    -----------------------------------------
*/

drop if _pegados==2
drop _pegados

*--- Estimación 

** Crear variable del DiD
gen treat = cond(treatment==1 & year>=2019,1,0)

** Estimar el DiD 
#d;
	reghdfe ln_avaluo_real_2014 treat [aweight=cem_weights], 
		a(codigo_lote year)
		vce(robust);
#d cr 

** Output
outreg2 using "${dir_outcomes}DID_CEM.docx", word keep(treat) replace

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1. 
2. 

Version Control:

