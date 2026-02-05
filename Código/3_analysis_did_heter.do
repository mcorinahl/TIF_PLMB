/*==================================================
Name:           3_analysis_did_heter.do

Project:        Difference in Differences (DiD) con efectos heterogéneos
                Outcome: valor_avaluo
Author:         Maria Corina Hernandez
E-email:        mc.hernandezl12@uniandes.edu.co

----------------------------------------------------
Creation Date:  04 Feb 2026
Output:         
==================================================*/

/*==================================================
              0: Program set up
==================================================*/

clear all
set more off

** Path
global dir_0 "C:\Users\USUARIO\Documents\GitHub\TIF_PLMB\\"

** Data
global dir_data "${dir_0}Datos\\"
global dir_raw "${dir_data}raw\\"
global dir_proc "${dir_data}processed\\"
global dir_outcomes "${dir_data}outcomes\\"

** Paquetes 
** ssc install cem
** ssc install outreg2


/*==================================================
      1: Importar datos y crear categorías
==================================================*/

** Importar los datos 
use "${dir_proc}predios_proc.dta", clear

/*==================================================
      2: Heterogeneidad por Destino Económico
==================================================*/

	/* Crear variable categórica a partir del destino 
	económico del predio */
  
** Predios del Estado -- se excluyen
drop if inlist(descripcion_destino, ///
    "VIAS", "ESPACIO PÚBLICO", "LOTE DEL ESTADO", ///
    "DOTACIONAL PÚBLICO", "RECREACIONAL PÚBLICO", ///
	"NO URBANIZ/SUELO PROTEG", "TIERRAS IMPRODUCTIVAS")
   
gen dest_cat = .

** Residencial = 1
replace dest_cat = 1 if descripcion_destino=="RESIDENCIAL"

** Comercial = 2
replace dest_cat = 2 if inlist(descripcion_destino, ///
		"COMERCIO EN CORREDOR COM", ///
		"COMERCIO PUNTUAL", ///
		"COMERCIO EN CENTRO COMER", ///
		"PARQUEADEROS")
		
** Industrial = 3
replace dest_cat = 3 if inlist(descripcion_destino, ///
		"INDUSTRIAL", ///
		"AGROINDUSTRIAL")
		
** Agrícola/Rural = 4
replace dest_cat = 4 if inlist(descripcion_destino, ///
		"AGRICOLA", ///
		"AGROPECUARIO", ///
		"PECUARIO", ///
		"FORESTAL", ///
		"PREDIO RURAL PARCEL. NO EDIFI.")

/* Urbanizado no edificado = 5
Se ubica en suelo urbano y tiene un potencial directo de capitalización por el 
Metro. Entonces es clave para expectativas y especulación. 
*/
replace dest_cat = 5 if descripcion_destino=="URBANIZADO NO EDIFICADO"

/* Dotacional Privado = 6
Siendo predios "destinados al desarrollo de actividades de interés público o social,
como educación, salud, culto, cultura o recreación" responden a incentivos privados, 
pero distintos de residencial y comercio. Reaccionan distinto al Metro (hospitales,
colegios)
*/
replace dest_cat = 6 if descripcion_destino=="DOTACIONAL PRIVADO"

** Otros privados = 7
replace dest_cat = 7 if dest_cat==.

** Etiquetar
label define dest_cat 1 "Residencial" 2 "Comercial" 3 "Industrial" ///
                     4 "Agrícola" 5 "Urbanizado no edificado" ///
                     6 "Dotacional privado" 7 "Otros privados"
label values dest_cat dest_cat

/*==================================================
      Realizar la estimación
==================================================*/

*--- Estimación DiD

** Crear variable del DiD
gen treat = cond(treatment==1 & year>=2019,1,0)

** Estimar el DiD 

/* Tomamos como base el destino económico residencial 
*/

#d;
	reghdfe ln_avaluo_real_2014 
		c.treat##i.dest_cat, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr 

** Output
outreg2 using "${dir_outcomes}DID_heter_dest.docx", word keep(treat) replace
	
	
/*==================================================
      3: Heterogeneidad por Tramo
==================================================*/
	
** Estimar el DiD 

#d;
reghdfe ln_avaluo_real_2014 
    c.treat##i.tramo, 
    a(codigo_lote year) 
    vce(cluster codigo_barrio);
#d cr 

** Output
outreg2 using "${dir_outcomes}DID_heter_tram.docx", word keep(treat tramo#c.treat) replace
	
*--- Estimacion DiD con ventanas de tiempo 

* Ventanas dinámicas por tramo
forvalues y = 2014/2025 {
    forvalues t = 1/3 {
        gen trat_`y'_tr`t' = ///
            (year==`y' & treatment==1 & tramo==`t')
        label var trat_`y'_tr`t' "`y' x Tramo `t'"
    }
}

** Estimar el DiD 
foreach t in 1 2 3 {
    replace trat_2018_tr`t' = 0
}

#d;
reghdfe ln_avaluo_real_2014 
    trat_*, 
    a(codigo_lote year) 
    vce(cluster codigo_barrio);
#d cr 

estimates store didwin_tramo


coefplot didwin_tramo, ///
    keep(trat_*_tr1) vertical ///
    yline(0) ///
	xlab(, angle(45)) ///
	title("Tramo 1") ///
    name(tr1, replace)

coefplot didwin_tramo, ///
    keep(trat_*_tr2) vertical ///
    yline(0) ///
	xlab(, angle(45)) ///
	title("Tramo 2") ///
    name(tr2, replace)

coefplot didwin_tramo, ///
    keep(trat_*_tr3) vertical ///
    yline(0) ///
	xlab(, angle(45)) ///
	title("Tramo 3") ///
    name(tr3, replace)
	
graph combine tr1 tr2 tr3, ///
    col(3) ///
    title("Valor catastral por tramo") ///
    ycommon	xcommon

graph export "${dir_outcomes}DiD_windows_tram.pdf", replace 


exit
/* End of do-file */
	
