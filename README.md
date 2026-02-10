# TIF_PLMB

# Análisis de Factibilidad TIF para la PLMB
## Modelación Econométrica y Geoespacial en Stata

**Autora:** Maria Corina Hernandez  
**Fecha:** Febrero 2026

---

## Descripción del Proyecto
Este repositorio contiene el código fuente para estimar el mayor valor del avalúo catastral en el área de influencia de la Primera Línea del Metro de Bogotá (PLMB). El objetivo central es evaluar la viabilidad del instrumento **Tax Increment Financing (TIF)** para financiar la extensión de la línea, utilizando un panel de datos catastrales (2014-2025).

## Estructura del Repositorio
Para el correcto funcionamiento de los dofiles, el repositorio debe mantener la siguiente estructura de carpetas:

* **`/Codigos`**: Contiene los archivos `.do` analizados en este documento.
* **`/Datos`**:
    * **`/raw`**: Bases prediales anuales de la UAECD (CSV) y capas geográficas (Shapefiles/DBF) procesadas en ArcGIS con los *buffers* de tratamiento.
    * **`/processed`**: Archivos en formato `.dta` generados tras la limpieza y el pegado (*merge*) de datos.
    * **`/outcomes`**: Resultados finales de la investigación.

## Estructura del Código (.do files)
El flujo de trabajo se divide en cinco etapas principales:

1. **`1_append_merge.do`**: Limpieza y estandarización de la base catastral anual de la UAECD. Crea un panel balanceado y lo vincula con la información geográfica (Shapefiles).
2. **`2_analysis_did.do`**: Implementación del modelo de **Diferencias en Diferencias (DiD)**. Incluye la deflactación de avalúos a precios constantes de 2014 y estimaciones de efectos fijos por lote y año.
3. **`3_analysis_did_heter.do`**: Análisis de heterogeneidad por tramo y por destino económico (Residencial, Comercial, Industrial, etc.).
4. **`4_analysis_cem.do`**: Aplicación de **Coarsened Exact Matching (CEM)** para mejorar la comparabilidad entre el grupo de tratamiento y control, controlando por distancias al CBD, Transmilenio y Malla Vial.
5. **`5_robustez.do`**: Pruebas de sensibilidad utilizando diferentes radios de influencia (*buffers*) de 400m, 800m y 1200m.

## Metodología
La estimación principal utiliza la especificación `reghdfe` para controlar por efectos fijos de alto nivel:

```stata
reghdfe ln_avaluo_real_2014 treat, a(codigo_lote year) vce(cluster codigo_barrio)
```

Se excluyen explícitamente predios públicos, vías y lotes del estado para evitar sesgos en la estimación de la plusvalía capturable.

## Descripción de Outcomes
El código está automatizado para exportar los resultados directamente a la carpeta `/outcomes`. Los principales productos generados son:

### Tablas de Regresión (Formatos .docx)
Utilizando el comando `outreg2`, el sistema genera tablas académicas con los resultados de las estimaciones:

* **`DID_simple.docx`**: Contiene el efecto promedio del tratamiento (ATT) sobre el avalúo real, comparando los buffers de 400m, 800m y 1200m.
* **`DID_heter_tram.docx`**: Desglose del impacto según el tramo de la PLMB. 
* **`CEM_results.docx`**: Resultados del modelo tras el emparejamiento por *Coarsened Exact Matching*.



### Visualizaciones (Formatos .pdf)
Se generan gráficos de coeficientes para analizar la dinámica temporal y la validez de los supuestos:

* **`DiD_windows.pdf`**: Gráfico de DiD dinámico que muestra los coeficientes año a año para verificar la tendencia paralela y la evolución del impacto post-2019.
* **`DiD_windows_com.pdf`**: Análisis específico para el valor comercial, para monitorear las diferencias entre valores catastrales y comerciales.

## Requerimientos
Es necesario instalar los siguientes paquetes en Stata antes de ejecutar los scripts:

```stata
ssc install reghdfe
ssc install ftools
ssc install outreg2
ssc install cem
ssc install coefplot
```

## Configuración de Rutas
El usuario debe ajustar la global dir_0 en los encabezados de los archivos para apuntar a su directorio local de trabajo.