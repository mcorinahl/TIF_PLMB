setwd("C:/Users/USUARIO/OneDrive - habitatbogota/Documentos/Datos/Paper lincoln 2024/Datos/19Manzanav10")

## paquetes necesario
library(sf)
library(tidyverse)
library(ggthemes)
library(ggspatial)

#Voy a cargar el shapefile
mapa <- read_sf("19Manzanav10.shp")

Residpred=mapa$AResidenci/mapa$A_const
mapa["Residpred"]<-Residpred

library(cem)

datos<- data.frame(mapa$ManCodigo, factor(mapa$SES), factor(mapa$Uso_Agrega), mapa$Residpred, mapa$MAXNPISOS, 
                   mapa$DIST_CBD, log(mapa$V_Terren_1+1), 
                   mapa$Count_lote, mapa$ATerreno,mapa$Age, 
                   mapa$Dred_TM, mapa$PH_Porcent, mapa$Area_huell,
                   mapa$Puntaje, mapa$L1_800,mapa$L2_800, mapa$PreRes_Hec, mapa$Dist_L2)

summary(datos)

#btrabajo<- na.omit(datos[datos$mapa.Residpred>=0.8 & datos$mapa.Residpred<=1 & datos$mapa.D500_L2==0,])

btrabajo<- na.omit(datos[datos$factor.mapa.Uso_Agrega.=="Residencial" & 
                           datos$log.mapa.V_Terren_1...1.>0 &datos$mapa.L2_800==0 &
                           datos$mapa.ATerreno>0 & datos$factor.mapa.SES.!="Undefined",])

summary(btrabajo)

tr <- which(btrabajo$mapa.D500_L1==1)
ct <- which(btrabajo$mapa.D500_L1==0)
ntr <- length(tr)
nct <- length(ct)

mean(btrabajo$log.mapa.V_Terren_1...1.[tr]) - mean(btrabajo$log.mapa.V_Terren_1...1.[ct])

variables<-c("mapa.Residpred", "mapa.MAXNPISOS", "mapa.DIST_CBD",
             "mapa.Count_lote", "mapa.ATerreno", 
             "mapa.Age", "mapa.Dred_TM", "mapa.PH_Porcent", 
             "mapa.Puntaje", "factor.mapa.SES.", "mapa.Area_huell", "mapa.PreRes_Hec")

imbalance(group=btrabajo$mapa.D500_L1, data=btrabajo[variables], drop=c("factor.mapa.SES.", "mapa.Area_huell", "mapa.Residpred", "mapa.ATerreno", "mapa.Dred_TM", "mapa.D500_L2"))

mat <- cem(treatment = "mapa.D500_L1", data = btrabajo, drop=c("factor.mapa.SES.", "mapa.Area_huell", "mapa.Residpred", "mapa.ATerreno", "mapa.Dred_TM", "mapa.D500_L2", "log.mapa.V_Terren_1...1."), keep.all=TRUE)

est <- att(mat, mapa.D500_L1~ mapa.MAXNPISOS+mapa.DIST_CBD+
             mapa.Count_lote+mapa.Age+mapa.PH_Porcent+
             mapa.Puntaje+mapa.PreRes_Hec, data = btrabajo)
est
summary(est)
psample<-pair(mat, data = btrabajo)

library(MatchIt)

mat1 <- matchit(mapa.L1_800~ mapa.MAXNPISOS+mapa.DIST_CBD+
                  mapa.Count_lote+mapa.Age+mapa.PH_Porcent+
                  mapa.Puntaje+mapa.PreRes_Hec, data = btrabajo, 
                method = "cem", k2k=FALSE)

summary(mat1)
#Estimar valores de suelo e incluir a la base

md1 <- match.data(mat1)


lm.mat1<-lm(log.mapa.V_Terren_1...1.~mapa.L1_800+mapa.Dred_TM+mapa.DIST_CBD+
              relevel(factor.mapa.SES., ref="High")+mapa.Age+mapa.PH_Porcent,data=md1, weights = weights)
summary(lm.mat1)

md1["pestimado"]<-lm.mat1$fitted.values
summary(md1)


# mat2 <- matchit(mapa.D500_L1~ mapa.MAXNPISOS+mapa.DIST_CBD+
#                   mapa.Count_lote+mapa.Age+mapa.PH_Porcent+
#                   mapa.Puntaje+mapa.PreRes_Hec, data = btrabajo, 
#                 method = "cem", k2k=TRUE, k2k.method = "euclidean")
# summary(mat2)
#DatospL2<-match.data(mat2)

mapa2 <- read_sf("C:/Users/USUARIO/OneDrive - habitatbogota/Documentos/Datos/Paper lincoln 2024/Datos/23Manzanav_6/23Manzanav_6.shp")
Residpred=mapa2$AResidenci/mapa2$A_const
mapa2["Residpred"]<-Residpred

datos2<- data.frame(mapa2$ManCodigo, factor(mapa2$SES), factor(mapa2$Uso_Agrega), mapa2$Residpred, mapa2$MAXNPISOS, 
                   mapa2$DIST_CBD, log((mapa2$V_Terren_1)/1.2142), 
                   mapa2$Count_lote, mapa2$ATerreno,mapa2$Age, 
                   mapa2$Dred_TM, mapa2$PH_Porcent, mapa2$Area_huell,
                   mapa2$Puntaje, mapa2$L1_800, mapa2$L2_800, mapa2$PreRes_Hec, mapa2$Dist_L2)
summary(datos2)

datos2<-rename(datos2, mapa.ManCodigo=mapa2.ManCodigo,factor.mapa.SES.=factor.mapa2.SES.,mapa.Residpred=mapa2.Residpred,
       mapa.MAXNPISOS=mapa2.MAXNPISOS, mapa.DIST_CBD=mapa2.DIST_CBD,log.mapa.V_Terren_1...1.=log..mapa2.V_Terren_1..1.2142.,
       mapa.Count_lote=mapa2.Count_lote,mapa.ATerreno=mapa2.ATerreno,mapa.Age=mapa2.Age,mapa.Dred_TM=mapa2.Dred_TM,
       mapa.PH_Porcent=mapa2.PH_Porcent,mapa.Area_huell=mapa2.Area_huell,mapa.Puntaje=mapa2.Puntaje,
       mapa.L1_800=mapa2.L1_800, mapa.L2_800=mapa2.L2_800,mapa.PreRes_Hec=mapa2.PreRes_Hec, factor.mapa.Uso_Agrega.=factor.mapa2.Uso_Agrega.,
       mapa.Dist_L2=mapa2.Dist_L2)
summary(datos2)

#btrabajo2<- na.omit(datos2[datos2$mapa.Residpred>=0.8 & datos2$mapa.Residpred<=1&datos2$mapa.D500_L2==1,])
btrabajo2<- na.omit(datos2[datos2$factor.mapa.Uso_Agrega.=="Residencial" & datos2$log.mapa.V_Terren_1...1.>0 &datos2$mapa.L2_800==1 &
                             datos2$mapa.ATerreno>0 & datos2$factor.mapa.SES.!="Undefined",])

summary(btrabajo2)


library(fastDummies)

# DatoscL2<-rbind(md1,btrabajo2)
# DatoscL2=subset(DatoscL2,select=-c(weights,subclass))
# dummy_cols(DatoscL2, select_columns="factor.mapa.SES.")
#md1["log.mapa.V_Terren_1...1."]<-md1["log.mapa.V_Terren_1...1."]/0.823614
DatoscL2<-rbind(md1,btrabajo2)
DatoscL2<-subset(DatoscL2,select=-c(weights,subclass))
DatoscL2<-DatoscL2[DatoscL2$log.mapa.V_Terren_1...1.>0,]
summary(DatoscL2)

mat3 <- matchit(mapa.L2_800~ mapa.DIST_CBD+
                  mapa.Count_lote+mapa.Age+mapa.PH_Porcent+
                  mapa.Puntaje, data = DatoscL2, 
                method = "cem", k2k=FALSE)

summary(mat3)
md3 <- match.data(mat3)
lm.mat3<-lm(log.mapa.V_Terren_1...1.~mapa.L2_800+mapa.DIST_CBD+mapa.MAXNPISOS+
              relevel(factor.mapa.SES., ref="High")+mapa.Age+mapa.PH_Porcent,data=md3, weights = weights)
summary(lm.mat3)

md3["pestimado"]<-lm.mat3$fitted.values
summary(md3)

# Datosproy<-match.data(mat3)
# Datosproy<-dummy_cols(Datosproy, select_columns="factor.mapa.SES.")
# Datosproy["Proy"]=1.4872e+01+7.4853e-02*Datosproy["mapa.D500_L1"]-1.0248e-04*Datosproy["mapa.Dred_TM"]-3.1695e-05*Datosproy["mapa.DIST_CBD"]-6.8575e-03*Datosproy["mapa.Age"]+5.3986e-02*Datosproy["mapa.PH_Porcent"]-8.9764e-02*Datosproy["factor.mapa.SES._Low"]+3.6207e-01*Datosproy["factor.mapa.SES._Medium"]
# summary(lm(log.mapa.V_Terren_1...1.~mapa.D500_L1+mapa.Dred_TM+mapa.DIST_CBD+mapa.Age+mapa.PH_Porcent+factor.mapa.SES._Low+factor.mapa.SES._Medium, data=Datosproy))

write.table(md3, file="Base_2023.csv")
write.table(md1, file="Base_2019.csv")

mapa2 <- read_sf("C:/Users/USUARIO/OneDrive - habitatbogota/Documentos/Datos/Paper lincoln 2024/Datos/23Manzanav_6/23Manzanav_6.shp")
Residpred=mapa2$AResidenci/mapa2$A_const
mapa2["Residpred"]<-Residpred

datos2<- data.frame(mapa2$ManCodigo, factor(mapa2$SES), factor(mapa2$Uso_Agrega), mapa2$Residpred, mapa2$MAXNPISOS, 
                    mapa2$DIST_CBD, log((mapa2$V_Terren_1)/1.2142), 
                    mapa2$Count_lote, mapa2$ATerreno,mapa2$Age, 
                    mapa2$Dred_TM, mapa2$PH_Porcent, mapa2$Area_huell,
                    mapa2$Puntaje, mapa2$L1_800, mapa2$L2_800, mapa2$PreRes_Hec, mapa2$Dist_L2)
summary(datos2)

datos2<-rename(datos2, mapa.ManCodigo=mapa2.ManCodigo,factor.mapa.SES.=factor.mapa2.SES.,mapa.Residpred=mapa2.Residpred,
               mapa.MAXNPISOS=mapa2.MAXNPISOS, mapa.DIST_CBD=mapa2.DIST_CBD,log.mapa.V_Terren_1...1.=log..mapa2.V_Terren_1..1.2142.,
               mapa.Count_lote=mapa2.Count_lote,mapa.ATerreno=mapa2.ATerreno,mapa.Age=mapa2.Age,mapa.Dred_TM=mapa2.Dred_TM,
               mapa.PH_Porcent=mapa2.PH_Porcent,mapa.Area_huell=mapa2.Area_huell,mapa.Puntaje=mapa2.Puntaje,
               mapa.L1_800=mapa2.L1_800, mapa.L2_800=mapa2.L2_800,mapa.PreRes_Hec=mapa2.PreRes_Hec, factor.mapa.Uso_Agrega.=factor.mapa2.Uso_Agrega.,
               mapa.Dist_L2=mapa2.Dist_L2)
summary(datos2)

btrabajo<- na.omit(datos2[datos2$factor.mapa.Uso_Agrega.=="Residencial" & 
                           datos2$log.mapa.V_Terren_1...1.>0 &datos2$mapa.L2_800==0 &
                           datos2$mapa.ATerreno>0 & datos2$factor.mapa.SES.!="Undefined",])


library(MatchIt)

mat1 <- matchit(mapa.L1_800~ mapa.MAXNPISOS+mapa.DIST_CBD+
                  mapa.Count_lote+mapa.Age+mapa.PH_Porcent+
                  mapa.Puntaje+mapa.PreRes_Hec, data = btrabajo, 
                method = "cem", k2k=FALSE)

summary(mat1)

md1 <- match.data(mat1)


lm.mat1<-lm(log.mapa.V_Terren_1...1.~mapa.L1_800+mapa.Dred_TM+mapa.DIST_CBD+
              relevel(factor.mapa.SES., ref="High")+mapa.Age+mapa.PH_Porcent,data=md1, weights = weights)
summary(lm.mat1)