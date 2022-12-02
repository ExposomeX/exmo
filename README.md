#Author: Guohuan Zhang, Yuting Wang, Bin Wang (corresponding author)

#Date: 2022-11-30

#The ExpoMultiomics module is designed to integrate the multi-omic data to predict the incidence of diseases. It mainly aims to construct various stacked generalization(SG) models to predict the probability of outcome incidence, as well as providing the statistical explanation. Please see the website (http://www.exposomex.cn/#/expomultiomics) for more information. Users can install the package using the following code:

  if(!requireNamespace("devtools", quietly = TRUE)){

install.packages("devtools")

}

devtools::install_github('ExposomeX/exmo',force = TRUE)

devtools::install_github('ExposomeX/extidy',force = TRUE)


#"extidy" package is optional if the data file has been well prepared. However, the it is recommended as users may need tidy the data to meet the modeling requirement, such as deleting varaibles with low variance, transforming data type, classifying variable into several level, etc.

library(exmo)

library(extidy)

#OutPath = "D:/test" #The default path is the current working directory of R. Users can use this code to set the preferred path.

#For each step, the returned value can be named as users' like by following R language requirement.

#All the PID must be the same with the one provided by InitMo function, e.g., res$PID.

res = InitMO()
res1 = LoadMO(PID=res$PID,
                  UseExample="example#1")

res2 = TransImput(PID=res$PID, Group="T", Vars="all.x", Method="lod")

res3 = DelNearZeroVar(PID = res$PID)

res4 = DelMiss(PID = res$PID)

res5 = TransType(PID=res$PID, Vars="all.x", To="numeric")

res6 = TransClass(PID=res$PID, Group="F", Vars="C1", LevelTo="4")

res7 = TransScale(PID=res$PID, Group="T", Vars="all.x", Method="normal")

res8 = TransDistr(PID=res$PID, Vars="C2", Method="log10")

res10 = TransDummy(PID=res$PID, Vars="default")


res11 = MulOmicsCros(PID=res$PID,
                    OutPath = "default",
                    OmicGroups = "immunome,metabolome,proteome",
                    VarsY = "Y1",
                    VarsC = "all.c",
                    TuneMethod = "default",
                    TuneNum = 5,
                    RsmpMethod = "cv",
                    Folds = 5,
                    Ratio = 0.67,
                    Repeats = 5,
                    VarsImpThr = 0.85,
                    SG_Lrns ="lasso")
                    
                    
res12 = VizMulOmicCros(PID=res$PID,
                   OutPath = "default",
                   VarsY = "Y1",
                   NodeNum = 100,
                   EdgeThr= 0.45,
                   Layout = "force-directed",
                   Brightness = "light",
                   Palette = 'nejm')

FuncExit(PID = res$PID)
