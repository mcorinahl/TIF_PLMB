/*================================================== 
Name:           7_centralidades.do

Project:        Construcción de índices urbanos a nivel manzana y merge a predios
Author:         Maria Corina Hernandez
E-email:        mc.hernandezl12@uniandes.edu.co

----------------------------------------------------
Creation Date:  17 Mar 2026
==================================================*/


/*==================================================
              0: Program set up
==================================================*/ 

clear all
set more off

** Path
global dir_0 "C:\Users\USUARIO\\"
//global dir_0 "C:\Users\proyecto\\"

** Data
global dir_data "${dir_0}OneDrive - Universidad de los andes\RA Andes - TIF\Datos\\"
global dir_raw "${dir_data}raw\\"
global dir_proc "${dir_data}processed\\"
global dir_outcomes "${dir_0}Documents\GitHub\TIF_PLMB\Datos\outcomes\\"
global dir_dist "${dir_0}OneDrive - Universidad de los andes\Archivos de Alvaro Andres Casas Camargo - TIF - PLMB\1. Entregables\Entregable 2 - Modelación de escenarios fiscales y financieros\Memoria de Cálculo y Comentarios\Distancias\\"


/*==================================================
      1: Importar distancias
==================================================*/

** Importar distancia al CBD
import delim "${dir_dist}Distancias_Manzanas-CBD.csv", clear

** Crear codigos String 
cap tostring man_codigo, gen(man_codigo_str)

** Agregar leading 0 donde no esté
replace man_codigo_str = "00" + man_codigo_str if strlen(man_codigo_str) == 7
ren (man_codigo man_codigo_str total_leng) (man_codigo_og man_codigo dist_cbd)

** Revisar distribución de la variable de distancia para crear las cohortes
centile dist_cbd, centile( 5 25 50 75 95 )

/* 
                                                          Binom. interp.   
    Variable |       Obs  Percentile    Centile        [95% conf. interval]
-------------+-------------------------------------------------------------
  total_leng |    42,635          5     3667.37        3589.914    3759.018
             |                   25    9242.638        9187.286    9300.016
             |                   50    12661.31        12610.16    12721.59
             |                   75    16281.16        16221.58    16338.29
             |                   95    19952.99        19896.18    20014.43
*/

xtile dist_cbd_p = dist_cbd, nq(5)
label define distp 1 "P0–20" 2 "P20–40" 3 "P40–60" 4 "P60–80" 5 "P80–100"
label values dist_cbd_p distp

tempfile cbd
save `cbd', replace

** Importar distancia a PLMB
//import delim "${dir_dist}Distancias_Manzanas-TrazadoPLMB.csv", clear

import delim "${dir_0}OneDrive - Universidad de los andes\ARCHIV~2\1D280~1.ENT\ENTREG~3\MEMORI~1\DISTAN~1\DISTAN~4.CSV", clear

** En este archivo los códigos de manzana ya están correctos 
ren total_length dist_plmb

** Revisar distribución de la variable de distancia para crear las cohortes
centile dist_plmb, centile( 5 25 50 75 95 )

/*
                                                          Binom. interp.   
    Variable |       Obs  Percentile    Centile        [95% conf. interval]
-------------+-------------------------------------------------------------
   dist_plmb |    42,635          5    449.4775        435.7532    463.2817
             |                   25    2103.467        2062.918    2144.428
             |                   50    5031.646        4962.781    5096.853
             |                   75    8341.881        8275.049    8417.196
             |                   95    12393.55        12344.68    12438.21
*/

xtile dist_plmb_p = dist_plmb, nq(5)
label define distp 1 "P0–20" 2 "P20–40" 3 "P40–60" 4 "P60–80" 5 "P80–100"
label values dist_plmb_p distp

tempfile plmb
save `plmb', replace

** Importar distancia a la estación de Transmilenio más cercano
import delim "${dir_dist}Distancias_Manzanas-TM.csv", clear

** En este archivo los códigos de manzana ya están correctos 
ren total_length dist_tm

** Revisar distribución de la variable de distancia para crear las cohortes
centile dist_tm, centile( 5 25 50 75 95 )

/*
                                                          Binom. interp.   
    Variable |       Obs  Percentile    Centile        [95% conf. interval]
-------------+-------------------------------------------------------------
     dist_tm |    42,635          5    392.9919        385.6287    399.3504
             |                   25    1004.109        992.0176    1015.556
             |                   50    1807.936        1790.789    1826.007
             |                   75    2908.431        2877.323    2937.882
             |                   95    5069.387        5040.703    5110.162
*/

xtile dist_tm_p = dist_tm, nq(5)
label define distp 1 "P0–20" 2 "P20–40" 3 "P40–60" 4 "P60–80" 5 "P80–100"
label values dist_tm distp

tempfile tm
save `tm', replace

** Importar distancia a la Malla Vial Arterial
// import delim "${dir_dist}Distancias_Manzanas-MallaVialArterial.csv", clear

import delim "${dir_0}OneDrive - Universidad de los andes\ARCHIV~2\1D280~1.ENT\ENTREG~3\MEMORI~1\DISTAN~1\DISTAN~1.CSV", clear

** En este archivo los códigos de manzana ya están correctos
ren total_length dist_malla

** Revisar distribución de la variable de distancia para crear las cohortes
centile dist_malla, centile( 5 25 50 75 95 )

/*
                                                          Binom. interp.   
    Variable |       Obs  Percentile    Centile        [95% conf. interval]
-------------+-------------------------------------------------------------
  dist_malla |    43,695          5    64.67325        62.57101    66.81625
             |                   25    239.9879        237.0525    243.0352
             |                   50     449.683        445.2172    454.2293
             |                   75     783.826        775.6545    791.7683
             |                   95    1937.811        1894.737    1982.492
*/

xtile dist_malla_p = dist_malla, nq(5)
label define distp 1 "P0–20" 2 "P20–40" 3 "P40–60" 4 "P60–80" 5 "P80–100"
label values dist_malla distp

tempfile malla_arterial
save `malla_arterial', replace


/*==================================================
      2: Pegar distancias
==================================================*/

** Importar los datos 
use "${dir_0}OneDrive - Universidad de los andes\RA Andes - TIF\Alex\base_bogota_270221.dta", clear

** Merge archivos de distancia con base principal predios_proc
local file_list malla_arterial tm cbd plmb

foreach d of local file_list {
    merge m:1 man_codigo using ``d'',  nogen keep(master matched)
}

/*
 Result                      Number of obs
    -----------------------------------------
    Not matched                           583
        from master                       583  
        from using                          0  

    Matched                            38,535  
    -----------------------------------------
(label distp already defined)

    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,268
        from master                     1,268  
        from using                          0  

    Matched                            37,850  
    -----------------------------------------
(label distp already defined)

    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,268
        from master                     1,268  
        from using                          0  

    Matched                            37,850  
    -----------------------------------------
(label distp already defined)

    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,268
        from master                     1,268  
        from using                          0  

    Matched                            37,850  
    -----------------------------------------
*/


* Verificar llave
isid man_codigo

/*================================================== 
		3. Generar Índice de ACCESIBILIDAD DE TRANSPORTE (transport_access)
==================================================*/

* Evitar división por cero
foreach var in dist_vtron dist_vloc dist_vinte {
    replace `var' = . if `var' <= 0
}


* Inversos de distancia
gen inv_vtron = 1 / dist_vtron
gen inv_vloc  = 1 / dist_vloc
gen inv_vinte = 1 / dist_vinte


* Estandarización (z-score)
foreach var in inv_vtron inv_vloc inv_vinte {
    egen z_`var' = std(`var')
}

/***********************
* Índice de transporte simple (promedio)
************************/

egen transport_access = rowmean(z_inv_vtron z_inv_vloc z_inv_vinte)

label var transport_access "Accesibilidad por red vial (estandarizada)"

/***********************
* Índice de transporte Tipo Gravedad
************************/

* Parámetro de decaimiento
local gamma = 0.5

* Evitar ceros
foreach var in dist_vtron dist_vloc dist_vinte {
    replace `var' = . if `var' <= 0
}

* Fricción de distancia (no lineal)
gen f_vtron = 1 / (dist_vtron^`gamma')
gen f_vloc  = 1 / (dist_vloc^`gamma')
gen f_vinte = 1 / (dist_vinte^`gamma')

* Accesibilidad combinada
egen friction_index = rowmean(f_vtron f_vloc f_vinte)

/*********************************
* Índice de transporte exponencial
**********************************/

* Parámetro de decaimiento
local lambda = 0.01   

* Evitar ceros
foreach var in dist_vtron dist_vloc dist_vinte {
    replace `var' = . if `var' <= 0
}

* Decaimiento exponencial
gen exp_vtron = exp(-`lambda' * dist_vtron)
gen exp_vloc  = exp(-`lambda' * dist_vloc)
gen exp_vinte = exp(-`lambda' * dist_vinte)


* Accesibilidad de transporte
egen transport_access_exp = rowmean(exp_vtron exp_vloc exp_vinte)

/*================================================== 
		4. Generar Índices de ACCESO ECONÓMICO (economic_access)
==================================================*/

* Log de empleo (evitar log(0))
gen log_emp = log(1 + tot_emp_mz)

** Índice basado en promedio simple
gen economic_access = log_emp * transport_access

label var economic_access "Acceso a oportunidades económicas"

** Grupos de accesibilidad
xtile access_group = economic_access, nq(5)

label var access_group "Quintiles de accesibilidad económica"

** Índice basado en gravedad 
gen economic_access_gr = log_emp * friction_index

label var economic_access_gr "Accesibilidad tipo gravedad (gamma=`gamma')"

** Índice basado en decaimiento
gen economic_access_exp = log_emp * transport_access_exp

label var economic_access_exp "Accesibilidad exponencial (lambda=`lambda')"


/*================================================== 
		5. Generar variable de centralidad
==================================================*/

* Verificar variable existente
assert dist_cbd > 0 if !missing(dist_cbd)

gen ln_dist_cbd = log(dist_cbd)

label var ln_dist_cbd "Log distancia al CBD"


* Quintiles CBD
xtile cbd_group = dist_cbd, nq(5)

label var cbd_group "Quintiles distancia CBD"

/*================================================== 
		6. Generar Índice de EQUIPAMIENTOS (amenities_index)
==================================================*/

* Lista de variables
local equip dist_educa dist_salud dist_entre dist_eqrec dist_eqpar

* Inversos
foreach var of local equip {
    replace `var' = . if `var' <= 0
    gen inv_`var' = 1 / `var'
}

* Estandarizar
foreach var of local equip {
    egen z_`var' = std(inv_`var')
}

* Índice

egen amenities_index = rowmean( ///
    z_dist_educa ///
    z_dist_salud ///
    z_dist_entre ///
    z_dist_eqrec ///
    z_dist_eqpar ///
)

label var amenities_index "Acceso a equipamientos"

/*================================================== 
		7. Merge manzanas a predios
==================================================*/


* GUARDAR BASE DE MANZANA CON VARIABLES GENERADAS
ren man_codigo mancodigo
keep mancodigo dist_plmb economic_access* access_group ln_dist_cbd cbd_group amenities_index 

save "${dir_proc}manzanas_access.dta", replace


use "${dir_proc}predios_proc_ai2.dta", clear

* Merge
merge m:1 mancodigo using "${dir_proc}manzanas_access.dta", gen(m_distancias)

* Verificar merge

drop if m_distancias == 2   // manzanas sin predios
drop m_distancias

/*================================================== 
		8. Modelos de efectos heterogéneos
==================================================*/

*---------------------------------------------------------------*
* Tratamiento continuo
*---------------------------------------------------------------*

gen post = cond( year >= 2019, 1, 0)
gen inv_dist_plmb = 1/dist_plmb

#d;
	reghdfe ln_avaluo_real_2014 c.post##c.inv_dist_plmb, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr


*---------------------------------------------------------------*
* Accesibilidad económica continua
*---------------------------------------------------------------*

* 1) Accesibilidad medida con promedio simple
#d;
	reghdfe ln_avaluo_real_2014 c.treat##c.economic_access, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr


* 2) Accesibilidad medida con gravedad
#d;
	reghdfe ln_avaluo_real_2014 c.treat##c.economic_access_gr, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr

* 3) Accesibilidad medida con decaimiento
#d;
	reghdfe ln_avaluo_real_2014 c.treat##c.economic_access_exp, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr

*---------------------------------------------------------------*
* Accesibilidad económica por quintiles
*---------------------------------------------------------------*

#d;
	reghdfe ln_avaluo_real_2014 c.treat##i.access_group, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr

*---------------------------------------------------------------*
* Centralidad
*---------------------------------------------------------------*

#d;
	reghdfe ln_avaluo_real_2014 c.treat##c.ln_dist_cbd, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr

*---------------------------------------------------------------*
* Centralidad por quintiles
*---------------------------------------------------------------*

#d;
	reghdfe ln_avaluo_real_2014 c.treat##i.cbd_group, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr

*---------------------------------------------------------------*
* Equipamientos
*---------------------------------------------------------------*

#d;
	reghdfe ln_avaluo_real_2014 c.treat##c.amenities_index, 
		a(codigo_lote year)
		vce(cluster codigo_barrio);
#d cr


