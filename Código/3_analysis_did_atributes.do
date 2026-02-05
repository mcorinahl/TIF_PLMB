/*==================================================
Name:           2_analysis_did_atributes.do

Project:        Difference in Differences (DiD)
                Outcome: Variables físicas
Author:         Maria Corina Hernandez
E-email:        mc.hernandezl12@uniandes.edu.co

----------------------------------------------------
Creation Date:  03 Feb 2026
Output:         
==================================================*/

/*==================================================
              0: Program set up
==================================================*/

clear all
set more off

** Path
global dir_0 "C:\Users\USUARIO\OneDrive - Universidad de los andes\RA Andes - TIF\\"

** Data
global dir_data "${dir_0}Datos\\"
global dir_raw "${dir_data}raw\\"
global dir_proc "${dir_data}processed\\"
global dir_outcomes "C:\Users\USUARIO\Documents\GitHub\TIF_PLMB\outcomes\\"

** Paquetes 
** ssc install cem
** ssc install outreg2

/*==================================================
      1: Revisar variación en atributos físicos 
==================================================*/

** Importar los datos procesados
use "${dir_proc}predios_proc.dta", clear

* Calcular desviación del área construida por predio y número de pisos
bys id_predio: egen sd_area = sd(area_construida)
gen cambio_area = sd_area > 0
tab cambio_area

bys id_predio: egen sd_pisos = sd(max_num_piso)
gen cambio_pisos = sd_pisos > 0
tab cambio_pisos

* Calcular diferencia entre área máxima y mínima
bys id_predio: egen max_area = max(area_construida)
bys id_predio: egen min_area = min(area_construida)
gen delta_area = max_area - min_area
sum delta_area, d
drop max_area min_area

* Revisar primer año de cambio en área
bys id_predio (year): gen d_area = area_construida != area_construida[_n-1] ///
    if _n > 1
bys id_predio: egen first_change_area = min(cond(d_area==1, year, .))
tab first_change_area

* Revisar correlación con tratamiento (800m)
tab cambio_area treatment, row
tab cambio_pisos treatment, row

/*==================================================
      2: Realizar la estimación
==================================================*/

gen ln_area_cons = log(area_construida)

*--- Estimación DiD

** Crear variable del DiD
gen treat = cond(treatment==1 & year>=2019,1,0)

** Estimar el DiD 
#d;
	reghdfe ln_area_cons treat, 
		a(codigo_manzana year)
		vce(cluster codigo_barrio);
#d cr 

*--- Estimacion DiD con ventanas de tiempo 

forvalues i=2014/2025 {
	gen trat_`i' = cond(year==`i',1*treatment,0)
	la var trat_`i' "`i'"
}


** Estimar el DiD 
replace trat_2018=0
#d;
	reghdfe ln_area_cons trat_*, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr 
estimates store didwin_area

#d;
	coefplot didwin_area, keep(trat_*) vertical yline(0) omitted 
		title("Área Construida") ytitle("ATT");
#d cr 

graph export "${dir_outcomes}DiD_windows_area.pdf", replace 

exit
/* End of do-file */

