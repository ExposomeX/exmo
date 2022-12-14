urlhead = 'http://www.exposomex.cn:8080/'
#library(gridExtra)

#' @title  Initialize ExpoMultiomics module
#' @description Initialize ExpoMultiomics analysis. It can generate an R6 class object
#'     integrating all the analysis information.
#' @usage InitMO()
#' @details ExpoMultiomics module is designed to integrate the multi-omic data to predict the incidence risk.
#'     It mainly aims to construct various stacked generalization(SG) models to predict the probability
#'     of outcome incidence, as well as providing the statistical explanation. In addition, the module can provide
#'     visualization plots with high quality of the final calculation results to make it easier for users to understand.
#' @return An R6 class object.
#' @export
#' @examples res <- InitMO()
#' @author Guohuan Zhang, Yuting Wang, Bin Wang (corresponding author)

InitMO = function(){
  library(gridExtra)
  url = paste0(urlhead,'InitMO')
  seednum = sample(1000, 1)
  res = httr::POST(url,
                   body = list(seednum = seednum),
                   encode = 'json')
  results = unserialize(httr::content(res))
  return(results$eSet)
}



#' @title  Load data file for multiomics module
#' @description Upload data file for multiomics module.
#' @usage LoadMO(PID, UseExample= "default", DataPath, VocaPath)
#' @details
#' @param PID chr. Program ID. It must be the same with the PID generated by InitMo.
#' @param UseExample chr. Method of uploading data. If "default", user should upload their own data files,
#'    or use "example#1" provided by this module.
#' @param DataPath chr. Input file directory, e.g. "D:/test/eg_data.xlsx". It should be
#'    noted that the slash symbol is "/", not "\".
#' @param VocaPath chr. Input file vocabulary, e.g. "D:/test/eg_voca.xlsx". It should be
#'    noted that the slash symbol is "/", not "\".
#' @return An R6 class object containing the input data.
#' @export
#' @examples
#'     res <- InitMO()
#'     res <- LoadMO(PID=res$PID, UseExample = "example#1", DataPath = NULL, VocaPath = NULL)
#' @author Guohuan Zhang, Yuting Wang, Bin Wang (corresponding author)

LoadMO =function(PID,
                 UseExample="default",
                 DataPath= NULL,
                 VocaPath= NULL){
  url = paste0(urlhead,'LoadMO')
  if(UseExample=="default"){
    exdata = readxl::read_excel(DataPath)
    vodata = readxl::read_excel(VocaPath)
    }else{
      exdata = NULL
      vodata = NULL
    }
  res = httr::POST(url,
                   body = serialize(list(PID=PID,
                                         UseExample=UseExample,
                                         Expodata=exdata,
                                         Vocadata=vodata),connection = NULL),
                   httr::content_type('application/x-rds'),
                   encode = 'raw')
  results = unserialize(httr::content(res))

  return(results$eSet)
}



#' @title  Build multiomics model
#' @description MulOmicsCros function is designed to integrate the multi-omic data to predict the incidence risk.
#'     It mainly aims to construct various stacked generalization models to predict the probability of outcome
#'     incidence, as well as providing the statistical explanation.
#' @usage MulOmicsCros(PID, OutPath, OmicGroups,VarsY, VarsC, TuneMethod = "default", TuneNum,
#'        RsmpMethod, Folds, Ratio, Repeats, VarsImpThr, SG_Lrns)
#' @details The calculation time depends on the characteristics of your data, the number of learning methods,
#'     and the tuning method. For parameter "TuneMethod", the default option can provide faster calculations but less accurate
#'     results than other autotune methods. If you want to train a better model, choose other auto-tune method and increase the number of tuning times.
#' @param PID chr. Program ID. It must be the same with the PID generated by InitMo.
#' @param OutPath chr. Output file directory, e.g. "D:/test". It should be noted that the slash symbol is "/", not "\".
#'    If "default", the current working directory will be set.
#' @param OmicGroups chr. Groups to be integrated. The groups of outcome and covariates or
#'     confounders are not included. Note that separates different learners by "," and without space(e.g. OmicGroups = "immunome,metabolome,proteome").
#' @param VarsY chr. Outcome variable for modelling. Only one variable can be entered.
#' @param VarsC chr. Covariates needing further statistical test. "all.c" option refers to all covariate variables listed in the data file.
#'     Users can also select part of them by copying available vars. Note that separates different vars by "," and without space(e.g. VarsC = "C1,C2").
#' @param TuneMethod chr. Method for hyper-parameter autotuning.
#'     Options include "default", "random_search", "grid_search", "nloptr"(Non-linear optimization), and "gensa"(Generalized simulated annealing).
#'     The "default" option uses the simple training method for parameter optimization of mlr3 package.
#' @param TuneNum num. Upper limit of model tuning times. It should be more than 20 times to search the appropriate parameters,
#'     but it takes more time. In theory, more time, better training results.
#' @param RsmpMethod chr. Method for resampling. Options include "cv"(cross validation), "loo"(leave-one-out cross validation),
#'     "bootstrap"(bootstrapping), "holdout"(holdout).
#' @param Folds num. Folds for cross validation resampling method. The default value is 5.
#' @param Ratio num. Ratio for "Holdout" resampling method. The default value is 5.
#' @param Repeats num. Repeats for "Bootstrap" resampling method.
#' @param VarsImpThr num. Threshold for feature selection.
#'     It refers to the ratio of accumulated importance of all variables of the selected variables for building the final model.
#' @param SG_Lrns chr. Learners for stacked generalization. Options include "lasso", "enet"(Elastic net), "rf"(Random forest), and "xgboost"(Xgboost).
#'     One or more arbitrary options can be selected at the same time. Note that separates different learners by "," and without space(e.g. SG_Lrns ="lasso,enet,rf,xgboost").
#' @return An R6 class object containing eight elements. The elements of that object include:
#' (1) "Importance": A list containing dataframes that contain the importance of features after modeling a single omic from different omicgroups.
#' (2) "Feature": A list containing dataframes that contain the the coefficients or importance of selected features after modeling a single omic from different learners.
#' (3) "Feature_select": A list containing dataframes that contain the selected features after modeling a single omic from different learners.
#' (4) "ModelStat": A list containing dataframes that contain the r-square value of the single omic model built by different learners.
#' (5) "Prediction_comp": A list containing dataframes that contain the prediction values of the SG model built by different combinations of learners.
#' (6) "SGModel_summary": A dataframe containing the r-square value of the SG model built by different combinations of learners.
#' (7) "NodeNum": The node number generated by different models.
#' (8) "SGplot": A visualized plot for SG model summary.
#' @export
#' @examples
#'    res <- InitMO()
#'    res <- LoadMO(PID=res$PID, UseExample = "example#1", DataPath = NULL, VocaPath = NULL)
#'    res2 <- MulOmicsCros(PID=res$PID, OutPath = "default", OmicGroups = "immunome,metabolome,proteome",
#'    VarsY = "Y1", VarsC = "all.c", TuneMethod = "random_search", TuneNum = 5, RsmpMethod = "cv", Folds = 5,
#'    Ratio = 0.67, Repeats = 5, VarsImpThr = 0.85, SG_Lrns ="lasso,enet,rf,xgboost")
#' @author Guohuan Zhang, Yuting Wang, Bin Wang (corresponding author)

MulOmicsCros = function(PID = res$PID,
                        OutPath = "default",
                        OmicGroups = "immunome,metabolome,proteome",
                        VarsY = "Y1",
                        VarsC = "all.c",
                        TuneMethod = "default",
                        TuneNum = 5,
                        RsmpMethod = "cv",
                        Folds = 5,
                        Ratio= 0.67,
                        Repeats= 5,
                        VarsImpThr = 0.85,
                        SG_Lrns ="lasso"){
  if(OutPath == 'default'){
    OutPath = getwd()
  }
  url = paste0(urlhead,'MulOmicsCros')
  res = httr::POST(url,
                   body = list(PID=PID,
                               OmicGroups=OmicGroups,
                               VarsY=VarsY,
                               VarsC=VarsC,
                               TuneMethod=TuneMethod,
                               TuneNum=TuneNum,
                               RsmpMethod=RsmpMethod,
                               Folds=Folds,
                               Ratio=Ratio,
                               Repeats=Repeats,
                               VarsImpThr=VarsImpThr,
                               SG_Lrns=SG_Lrns),
                   encode = 'json')
  results = unserialize(httr::content(res))

  for (OmicGroup in names(results$Importance)){

    dir.create(paste0(OutPath,"/1_",OmicGroup))
    dir.create(paste0(OutPath,"/1_",OmicGroup,"/Feature_Explain"))
    dir.create(paste0(OutPath,"/1_",OmicGroup,"/Features_Selection"))
    dir.create(paste0(OutPath,"/1_",OmicGroup,"/Model_Summary"))

    try(writexl::write_xlsx(results$Importance[[OmicGroup]]$lasso,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Feature_Explain/Importance_lasso.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Importance[[OmicGroup]]$enet,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Feature_Explain/Importance_enet.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Importance[[OmicGroup]]$rf,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Feature_Explain/Importance_rf.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Importance[[OmicGroup]]$xgboost,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Feature_Explain/Importance_xgboost.xlsx")),silent = TRUE)


    try(writexl::write_xlsx(results$Feature[[OmicGroup]]$lasso,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Features_Selection/Coefficients_lasso.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Feature[[OmicGroup]]$enet,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Features_Selection/Coefficients_enet.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Feature[[OmicGroup]]$rf,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Features_Selection/Importance_rf.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Feature_select[[OmicGroup]]$xgboost,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Features_Selection/Importance_xgboost.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Feature_select[[OmicGroup]]$lasso,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Features_Selection/Selected.features_lasso.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Feature_select[[OmicGroup]]$enet,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Features_Selection/Selected.features_enet.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Feature_select[[OmicGroup]]$rf,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Features_Selection/Selected.features_rf.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Feature_select[[OmicGroup]]$xgboost,
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Features_Selection/Selected.features_xgboost.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$ModelStat[[OmicGroup]],
                            paste0(OutPath,"/1_",
                                   OmicGroup,
                                   "/Model_Summary/Measures_stat.xlsx")),silent = TRUE)
  }


  dir.create(paste0(OutPath,"/2_SG"))
  dir.create(paste0(OutPath,"/2_SG/Viz_Prediction"))
  dir.create(paste0(OutPath,"/2_SG/Model_Summary"))

  for (SG_Lrn in names(results$Prediction_comp)){
    try(writexl::write_xlsx(results$Prediction_comp[[SG_Lrn]]$lasso$train,
                            paste0(OutPath,"/",
                                   "2_SG/Viz_Prediction/",
                                   "Step1 by lasso Step2 by ",
                                   SG_Lrn,
                                   "_train.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Prediction_comp[[SG_Lrn]]$lasso$test,
                            paste0(OutPath,"/",
                                   "2_SG/Viz_Prediction/",
                                   "Step1 by lasso Step2 by ",
                                   SG_Lrn,
                                   "_test.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Prediction_comp[[SG_Lrn]]$enet$train,
                            paste0(OutPath,"/",
                                   "2_SG/Viz_Prediction/",
                                   "Step1 by enet Step2 by ",
                                   SG_Lrn,
                                   "_train.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Prediction_comp[[SG_Lrn]]$enet$test,
                            paste0(OutPath,"/",
                                   "2_SG/Viz_Prediction/",
                                   "Step1 by enet Step2 by ",
                                   SG_Lrn,
                                   "_test.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Prediction_comp[[SG_Lrn]]$rf$train,
                            paste0(OutPath,"/",
                                   "2_SG/Viz_Prediction/",
                                   "Step1 by rf Step2 by ",
                                   SG_Lrn,
                                   "_train.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Prediction_comp[[SG_Lrn]]$rf$test,
                            paste0(OutPath,"/",
                                   "2_SG/Viz_Prediction/",
                                   "Step1 by rf Step2 by ",
                                   SG_Lrn,
                                   "_test.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Prediction_comp[[SG_Lrn]]$xgboost$train,
                            paste0(OutPath,"/",
                                   "2_SG/Viz_Prediction/",
                                   "Step1 by xgboost Step2 by ",
                                   SG_Lrn,
                                   "_train.xlsx")),silent = TRUE)
    try(writexl::write_xlsx(results$Prediction_comp[[SG_Lrn]]$xgboost$test,
                            paste0(OutPath,"/",
                                   "2_SG/Viz_Prediction/",
                                   "Step1 by xgboost Step2 by ",
                                   SG_Lrn,
                                   "_test.xlsx")),silent = TRUE)
  }
  try(writexl::write_xlsx(results$SGModel_summary,
                          paste0(OutPath,"/",
                                 "2_SG/Model_Summary/",
                                 "Model assessment.xlsx")),silent = TRUE)
  try(writexl::write_xlsx(results$NodeNum,
                          paste0(OutPath,"/",
                                 "2_SG/Model_Summary/",
                                 "Node number.xlsx")),silent = TRUE)
  ggplot2::ggsave(plot=results$SGplot,
                  filename = paste0(OutPath,"/2_SG/Model_Summary/Model assessment_boxplot.png"),
                  width = 10,
                  height = 3.5*results$plotheight)
  return(results)
}



#' @title  Visualize multiomics model results
#' @description VizMulOmicCros function is mainly aimed to visualize the modeling results calculated by MulOmicsCros function.
#'     It can provide plots with high quality of the final results to make it easier for users to understand.
#' @usage VizMulOmicCros(PID, OutPath, VarsY, NodeNum, EdgeThr, Layout, Brightness, Palette)
#' @param PID chr. Program ID. It must be the same with the PID generated by InitMo.
#' @param OutPath chr. Output file directory, e.g. "D:/test". It should be noted that the slash symbol is "/", not "\".
#'     If "default", the current working directory will be set.
#' @param VarsY chr. Outcome variable for modeling. Only one variable can be entered.
#' @param NodeNum num. Number of nodes in the network plot. The maximum number is generated by Multiomics function.
#'     User can set a smaller value if needed.
#' @param EdgeThr num. Threshold of correlation coefficient ranging 0-1 for generating the concerned edges of the network plot.
#' @param Layout chr. Visualization layout. Available options include "force-directed" and "degree-circle".
#' @param Brightness chr. Visualization brightness. Available options include "light" and "dark".
#' @param Palette chr. Visualization palette. Available options include "default1", "default2" and other options about some journal preference styles
#'     including "cell", "nature", "science", "lancet", "nejm", etc.
#' @details You can get different styles of images by selecting different parameters.
#' @return An R6 class object containing seven elements. The elements of that object include:
#' (1) "Importance_plot": Plots for the importance of features after modeling a single omic from different learners.
#' (2) "Measures_boxplot": Plots for the r-square value of the single omic model built by different learners.
#' (3) "NetWork_State": A list containing dataframes that contain nodes and edges used to draw
#'     interOmic network from models built by different learners.
#' (4) "Nodeplot": Interomic node plots from models built by different models.
#' (5) "Networkplot": Interomic network plots from models built by different models.
#' (6) "Prediction_train_plot": Plots for the prediction value of the train set in the SG model built by different combinations of learners.
#' (7) "Prediction_test_plot": Plots for the prediction value of the test set in the SG model built by different combinations of learners.
#' @export
#' @examples
#'    res <- InitMO()
#'    res <- LoadMO(PID=res$PID, UseExample = "example#1", DataPath = NULL, VocaPath = NULL)
#'    res2 <- MulOmicsCros(PID=res$PID, OutPath = "default", OmicGroups = "immunome,metabolome,proteome",
#'    VarsY = "Y1", VarsC = "all.c", TuneMethod = "random_search", TuneNum = 5, RsmpMethod = "cv", Folds = 5,
#'    Ratio = 0.67, Repeats = 5, VarsImpThr = 0.85, SG_Lrns ="lasso,enet,rf,xgboost")
#'    res3 <- VizMulOmicCros(PID=res$PID, OutPath = "default", VarsY = "Y1", NodeNum=100, EdgeThr= 0.45,
#'    Layout = "force-directed", Brightness = "light", Palette = 'default1')
#' @author Guohuan Zhang, Yuting Wang, Ning Gao, Bin Wang (corresponding author)

VizMulOmicCros = function(PID = res$PID,
                       OutPath = "default",
                       VarsY = "Y1",
                       NodeNum,
                       EdgeThr,
                       Layout = "force-directed",
                       Brightness = "light",
                       Palette = "default1"){
  if(OutPath == 'default'){
    OutPath = getwd()
  }
  url = paste0(urlhead,'VizMulOmicCros')
  res = httr::POST(url,
                   body = list(PID=PID,
                               VarsY=VarsY,
                               NodeNum = NodeNum,
                               EdgeThr = EdgeThr,
                               Layout=Layout,
                               Brightness=Brightness,
                               Palette=Palette
                   ),
                   encode = 'json')
  results = unserialize(httr::content(res))

  for (OmicGroup in names(results$Importance_plot)){
    for (learner in names(results$Importance_plot[[OmicGroup]])){
      try(ggplot2::ggsave(
        plot = results$Importance_plot[[OmicGroup]][[learner]],
        filename = paste0(OutPath,"/1_",OmicGroup,
                          "/Feature_Explain/Importance_",learner,"_plot.png"),
        width = 6,
        height = 7),silent = TRUE)

    }

    try(ggplot2::ggsave(plot=results$Measures_boxplot[[OmicGroup]],
                        filename = paste0(OutPath,"/1_",OmicGroup,
                                          "/Model_Summary/Measures_boxplot.png"),
                        width = 10,
                        height = 3.5),
        silent = TRUE

    )
  }

  dir.create(paste0(OutPath,"/2_SG/Viz_InterOmic"))
  for (learner in names(results$NetWork_State)){
    try(writexl::write_xlsx(results$NetWork_State[[learner]]$node,
                            paste0(OutPath,"/2_SG/Viz_InterOmic/Node_Step1.by.",learner,".xlsx")),silent = TRUE)

    try(writexl::write_xlsx(results$NetWork_State[[learner]]$edge,
                            paste0(OutPath,"/2_SG/Viz_InterOmic/Edge_Step1.by.",learner,".xlsx")),silent = TRUE)

  }
  for ( learner in names(results$Nodeplot)){
    try(ggplot2::ggsave(filename = paste0(OutPath,"/2_SG/Viz_InterOmic/NodePlot_",learner,"_",
                                          Brightness,"_",Palette,".png"),
                        plot = results$Nodeplot[[learner]],
                        height = 6,
                        width = 8),
        silent = TRUE
    )
    try(ggplot2::ggsave(paste0(OutPath,"/2_SG/Viz_InterOmic/NetworkPlot_",learner,"_",
                               Layout,"_",Brightness,"_",Palette,".png"),
                        plot = results$Networkplot[[learner]],
                        width =  20,
                        height = 20,
                        units = "cm"),
        silent = TRUE
    )
  }

  for (learner1 in names(results$Prediction_train_plot)){
    for (learner2 in names(results$Prediction_train_plot[[learner1]])){
      try(
        ggplot2::ggsave(plot=results$Prediction_train_plot[[learner1]][[learner2]],
                        filename = paste0(OutPath,"/2_SG/Viz_Prediction/",
                                          learner1," ",learner2,"_Training.png"),
                        width = 6,
                        height = 6),
        silent = TRUE
      )
      try(
        ggplot2::ggsave(plot=results$Prediction_test_plot[[learner1]][[learner2]],
                        filename = paste0(OutPath,"/2_SG/Viz_Prediction/",
                                          learner1," ",learner2,"_Test.png"),
                        width = 6,
                        height = 6),
        silent = TRUE
      )
    }
  }
  return(results)
}



#' @title End the module analysis
#' @description End the module analysis
#' @usage FuncExit(PID)
#' @param PID chr. Program ID. It must be the same with the PID generated by InitBioLink.
#' @details
#' @return
#' @export
#' @examples
#'    res <- InitMO()
#'    res <- LoadMO(PID=res$PID, UseExample = "example#1", DataPath = NULL, VocaPath = NULL)
#'    res2 <- MulOmicsCros(PID=res$PID, OutPath ="default", OmicGroups = "immunome,metabolome,proteome",
#'    VarsY = "Y1", VarsC = "all.c", TuneMethod = "random_search", TuneNum = 5, RsmpMethod = "cv", Folds = 5,
#'    Ratio = 0.67, Repeats = 5, VarsImpThr = 0.85, SG_Lrns ="lasso,enet,rf,xgboost")
#'    res3 <- VizMulOmicCros(PID=res$PID, OutPath = "default", VarsY = "Y1", NodeNum=100, EdgeThr= 0.45,
#'    Layout = "force-directed", Brightness = "light", Palette = 'default1')
#'    FuncExit(PID = res$PID)
#' @author Guohuan Zhang, Yuting Wang, Bin Wang (corresponding author)

FuncExit = function(PID){
  url = paste0(urlhead,'Exit')
  res = httr::POST(url,
                   body = list(PID=PID),
                   encode = 'json')
  if(res$status_code == 200){
    return("Success to exit. Thanks for using ExposomeX platform!")
  }else{
    return("No process needs exit. Thanks for using ExposomeX platform!")
  }
}




