# exmo: ExpoMultiomics Module

### Author: Guohuan Zhang, Yuting Wang, Bin Wang (corresponding author)

### Date: 2022-11-30

The exmo package is designed to integrate the multi-omic data to predict the incidence of diseases. It mainly aims to construct various stacked generalization(SG) models to predict the probability of outcome incidence, as well as providing the statistical explanation. Please see the website (http://www.exposomex.cn/#/expomultiomics) for more information. 

Users can install the package using the following code:

```
if (!requireNamespace("devtools", quietly = TRUE)){

	install.packages("devtools")

	devtools::install_github('ExposomeX/exmo',force = TRUE)
 
        devtools::install_github('ExposomeX/extidy',force = TRUE)
}

library(exmo)

library(extidy)
```

"extidy" package is optional if the data file has been well prepared. However, the it is recommended as users may need tidy the data to meet the modeling requirement, such as deleting varaibles with low variance, transforming data type, classifying variable into several level, etc.



### Tips:
   1. Before using the package, a user defined physical output path (i.e., OutPath) is recommended. For example
```
OutPath = "D:/test" #The default path is the current working directory of R. Users can use this code to set the preferred path.
```
   2. For each step, the returned values can be named as users' like by following R language requirement.

   3. All the PID must be the same with the one provided by `InitMO` function, e.g., res$PID.


### Example codes:
1. Initial MultiOmics module:

```
res = InitMO()
res$PID
```

2. Load data for MultiOmics module:
```
res1 = LoadMO(PID=res$PID,
              UseExample="example#1")
```

3. Tidy data
```
res2 = TransImput(PID=res$PID, Group="T", Vars="all.x", Method="lod")

res3 = DelNearZeroVar(PID = res$PID)

res4 = DelMiss(PID = res$PID)

res5 = TransType(PID=res$PID, Vars="all.x", To="numeric")

res6 = TransClass(PID=res$PID, Group="F", Vars="C1", LevelTo="4")

res7 = TransScale(PID=res$PID, Group="T", Vars="all.x", Method="normal")

res8 = TransDistr(PID=res$PID, Vars="C2", Method="log10")

res10 = TransDummy(PID=res$PID, Vars="default")
```

4. Build MultiOmics model

This MultiOmics function is the most critical in the exmo package. You can select one or more arbitrary learning methods in parameter SG_Lrns. Here we
choose lasso(least absolute shrinkage and selection operator) and rf(random forest) as examples. The calculation time depends on the characteristics of your data, the number of learning methods, and the tuning method. For parameter TuneMethod, the default option can provide faster calculations but less accurate results than other autotune methods. If you want to train a better model, choose other auto-tune method and increase the number of tuning times. Please attention, PID must be got from the return result of `InitMO`. 
```
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
                    SG_Lrns ="lasso,rf")
```

5. Visualize MultiOmics model

VizMulOmicCros function is mainly aimed to visualize the modeling results calculated by `MulOmicsCros` function. It can provide plots with high quality of the final results to make it easier for users to understand. You can get different styles of images by selecting different parameters.  Please attention, PID must be got from the return result of `InitMO`. 
```                    
res12 = VizMulOmicCros(PID=res$PID,
                   OutPath = "default",
                   VarsY = "Y1",
                   NodeNum = 100,
                   EdgeThr= 0.45,
                   Layout = "force-directed",
                   Brightness = "light",
                   Palette = 'nejm')
```

6. Exit

After all the analysis is done, please run the `FuncExit` function to delete the data uploaded to the server.
```
FuncExit(PID = res$PID)
```
