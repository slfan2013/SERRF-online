normalize = function(file_location = file.choose(new = FALSE), methods="all", scatter_plot = T){
  
  
  if(!"pacman" %in% rownames(installed.packages())){
    cat("Installing packages...\n")
    install.packages('pacman')
  }

  # file_location = "C:\\Users\\Sili\\Documents\\Github\\serrfR.dev\\diagnose.xlsx"
  read_data = function (input = "C:\\Users\\FanslyFTW\\Documents\\GitHub\\app\\Datasets\\mx 426933_Morrissey_HILIC posESI_negESI_human serum_11-2018 submit_injorder.xlsx")
  {
    pacman::p_load(openxlsx, data.table)
    readData = function(path = "G:\\data\\D\\data project D.xlsx") {
      if (grepl("xlsx", path)) {
        d <- openxlsx::read.xlsx(path, sheet = 1, colNames = FALSE)
      }else if (grepl("csv", path)) {
        d <- data.table::fread(path)
      }
      d[d == ""] <- NA
      d = data.table(d)
      # d = data.matrix(d)
      fData <- d[which(!is.na(d[, 1])), c(which(is.na(d[1, ])), sum(is.na(d[1,])) + 1),with=F]
      colnames(fData) = as.character(fData[1, ])
      fData = data.frame(fData[-1, ], stringsAsFactors = F,
                         check.names = FALSE)
      rownames(fData) = 1:nrow(fData)
      fData. = lapply(fData, function(x) {
        if (sum(!is.na(as.numeric(x))) == length(x)) {
          as.numeric(x)
        }
        else {
          x
        }
      })
      fData. = do.call(cbind, lapply(fData., data.frame, stringsAsFactors = FALSE))
      colnames(fData.) = colnames(fData)
      fData = fData.
      fData = fData[, c(ncol(fData), 2:ncol(fData) - 1)]
      fData[[1]] = make.unique(fData[[1]], sep = "_")
      pData <- d[c(which(is.na(d[, 1])), max(which(is.na(d[,
                                                           1]))) + 1), !is.na(d[1, ]),with=F]
      pData <- t(pData)
      colnames(pData) = pData[1, ]
      pData = data.frame(pData[-1, ], stringsAsFactors = F,
                         check.names = FALSE)
      pData. = lapply(pData, function(x) {
        if (sum(!is.na(as.numeric(x))) == length(x)) {
          as.numeric(x)
        }
        else {
          x
        }
      })
      pData. = do.call(cbind, lapply(pData., data.frame, stringsAsFactors = FALSE))
      colnames(pData.) = colnames(pData)
      pData = pData.
      pData = pData[, c(ncol(pData), 2:ncol(pData) - 1)]
      pData[[1]] = make.unique(pData[[1]], sep = "_")
      eData <- d[which(!is.na(d[, 1])), !is.na(d[1, ]),with=F][-1, -1]
      eData <- sapply(eData, as.numeric)
      eData <- data.frame(eData, stringsAsFactors = F)
      fData$label[is.na(fData$label)] = paste0("compound",1:sum(is.na(fData$label)))
      pData$label[is.na(pData$label)] = paste0("compound",1:sum(is.na(pData$label)))
      colnames(eData) = pData[[1]]
      rownames(eData) = fData[[1]]
      return(list(e = eData, f = fData, p = pData))
    }
    data = readData(input)
    e = data$e
    p = data$p
    f = data$f
    data_matrix = as.matrix(data$e)
    sum_NA = sum(is.na(data_matrix))
    if (sum_NA > 0) {
      message_from_R = paste0("<em>Please note, your data has ",
                              sum_NA, " missing values. These values will be replace by half-minimum for each compound before normalization.</em>")
    }else {
      message_from_R = ""
    }
    num_NAs = c()
    for(i in 1:nrow(data_matrix)){
      num_NAs[i] = sum(is.na(data_matrix[i,]))
    }
    too_many_na = num_NAs > (0.05 * ncol(data_matrix))
    # data_matrix = data_matrix[!too_many_na,]
    # f = f[!too_many_na,]
    for (i in 1:nrow(data_matrix)) {
      data_matrix[i, is.na(data_matrix[i, ])] = 1/2 * runif(1,min(data_matrix[i,!is.na(data_matrix[i, ])])*0.9,min(data_matrix[i,!is.na(data_matrix[i, ])])*1.1)
    }
    constant_compound = apply(data_matrix,1,sd,na.rm = TRUE) == 0
    data_matrix = data_matrix[!constant_compound,]
    f = f[!constant_compound,]
    if (!"label" %in% names(p)) {
      stop("cannot find 'label' in your dataset. Please download the example file and read the second sheet: 'Explanation'. ")
    }
    if (!"batch" %in% names(p)) {
      stop("cannot find 'batch' in your dataset. Please download the example file and read the second sheet: 'Explanation'.")
    }
    if (!"sampleType" %in% names(p)) {
      stop("cannot find 'sampleType' in your dataset. Please download the example file and read the second sheet: 'Explanation'.")
    }
    if (!"time" %in% names(p)) {
      stop("cannot find 'time' in your dataset. Please download the example file and read the second sheet: 'Explanation'.")
    }
    if (!"qc" %in% unique(p$sampleType)) {
      stop("cannot find 'qc' in your dataset. Please download the example file and read the second sheet: 'Explanation'.")
    }
    if (!"sample" %in% unique(p$sampleType)) {
      stop("cannot find 'sample' in your dataset. Please download the example file and read the second sheet: 'Explanation'.")
    }
    if (!class(p$time) == "numeric") {
      stop(paste0("'time' is not a right format. Must be number (numeric). Cannot be ",
                  class(p$time)))
    }
    if (any(table(p$batch[p$sampleType == "qc"]) < 5)) {
      stop("Some batches have too little QCs. At least 5 qc needed for EACH batch.")
    }
    sample_rank = rank(p$time, ties.method = "first")
    sample_order = order(p$time, decreasing = FALSE)
    sample_time = p$time
    data_matrix = data_matrix[, sample_order]
    p = p[sample_order, ]
    p$time = order(p$time)
    p$sampleType[!p$sampleType %in% c("qc", "validate")] = "sample"
    return(list(e = data_matrix, f = f, p = p, data_matrix = data_matrix,
                sample_size_summary = as.data.frame.matrix(table(p$batch,
                                                                 p$sampleType)), sample_order = sample_order, sample_time = sample_time,
                sample_rank = sample_rank, message_from_R = message_from_R))
  }

  remove_outlier = function(v){
    out = boxplot.stats(v)$out
    return(list(value = v[!v%in%out],index = which(v%in%out)))
  }

  loess_wrapper_extrapolate <- function (x, y, span.vals = seq(0.25, 1, by = 0.05), folds = 5){
    # Do model selection using mean absolute error, which is more robust than squared error.
    mean.abs.error <- numeric(length(span.vals))

    # Quantify error for each span, using CV
    loess.model <- function(x, y, span){
      loess(y ~ x, span = span, control=loess.control(surface="interpolate",statistics='exact'),family = "gaussian")
    }

    loess.predict <- function(fit, newdata) {
      predict(fit, newdata = newdata)
    }

    span.index <- 0

    for (each.span in span.vals) {
      span.index <- span.index + 1
      mean.abs.error[span.index] = tryCatch({
        y.hat.cv <- bootstrap::crossval(x, y, theta.fit = loess.model, theta.predict = loess.predict, span = each.span, ngroup = folds)$cv.fit
        non.empty.indices <- !is.na(y.hat.cv)
        diff = (y[non.empty.indices] / y.hat.cv[non.empty.indices]) * mean(y[non.empty.indices])
        sd(diff)/mean(diff)
      },error = function(er){
        NA
      })
    }
    best.span <- span.vals[which.min(mean.abs.error)]
    if(length(best.span)==0){
      best.span = 0.75
    }

    best.model <- loess(y ~ x, span = best.span, control=loess.control(surface="interpolate",statistics='exact'),family = "gaussian")

    return(list(best.model, min(mean.abs.error, na.rm = TRUE),best.span))
  }
  shiftData = function(ori,norm){
    ori.min = apply(ori,1,min,na.rm=T)
    norm.min = apply(norm,1,min,na.rm=T)
    return(norm - c(norm.min - ori.min))
  }
  RSD = function(data){
    return(apply(data,1,function(x){
      x = remove_outlier(x)[[1]]
      return(sd(x,na.rm=T)/mean(x,na.rm=T))
    }))
  }

  pacman::p_load(affy, parallel,ranger,caret,pcaMethods,metabolomics,ggplot2,tidyr,graphics,grDevices,Hmisc,gtools,cowplot,RColorBrewer,readr,plotly,stringr,GGally,dplyr,e1071,officer,bootstrap)
  cat("<--------- Waiting User to Select Dataset File --------->\n")
  dta = read_data(file_location)
  cat("<--------- Dataset is read --------->\n")
  e = dta$e
  f = dta$f
  p = dta$p
  sample_rank = dta$sample_rank
  cat(paste0("Number of compounds: ",nrow(f)," \n"))
  cat(paste0("Number of samples: ",sum(p$sampleType=='sample')," \n"))
  cat(paste0("Number of QCs: ",sum(p$sampleType=='qc')," \n"))
  normalized_dataset = list()
  qc_RSDs = list()
  calculation_times = list()
  if('validate'%in%p$sampleType){
    with_validate = TRUE
  }else{
    with_validate = FALSE
  }
  if(with_validate){
    val_RSDs = list()
    cat(paste0("Number of Valiate Samples: ",sum(p$sampleType=='validate')," \n"))
  }
  cat(paste0("Number of batches: ",length(unique(p$batch))," \n"))

  if(identical(methods,"all")){
    methods = c("mTIC","sum","median","PQN","contrast","quantile","linear",'liwong','cubic','batch_ratio','batch_loess','SERRF','svm','nomis','bmis')
  }

  # no normalization.
  start = Sys.time()
  normalized_dataset[['none']] = e[,sample_rank]
  qc_RSDs[['none']] = RSD(e[,p$sampleType=='qc'])
  calculation_times[['none']] = Sys.time() - start
  cat("<!--------- raw data --------->\n")
  cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['none']],na.rm = TRUE),4)*100,"%.\n"))
  cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['none']]<0.2,na.rm = TRUE),".\n"))
  if(with_validate){
    val_RSDs[['none']] = RSD(e[,p$sampleType=='validate'])
    cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['none']],na.rm = TRUE),4)*100,"%.\n"))
    cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['none']]<0.2,na.rm = TRUE),".\n"))
  }
  if('mTIC' %in% methods){
    Sys.sleep(2)
    normalized_dataset[['mTIC']] = tryCatch({
      cat("<!--------- mTIC --------->\n")
      mTIC_skip = FALSE
      if(!'compoundType' %in% colnames(f)){
        cat(paste0("warning: 'compountType' is not in the dataset. mTIC skipped.\n"))
        mTIC_skip = TRUE
      }else{
        mTIC_column = f[['compoundType']]
        if(!'known' %in% unique(f[['compoundType']])){
          cat(paste0("'known' (case-sensitive) is not found in the 'compoundType'. mTIC skipped.\n"))
          mTIC_skip = TRUE
        }
      }
      if(!mTIC_skip){
        start = Sys.time()
        index = mTIC_column %in% "known"
        sums = apply(e[index,], 2, sum, na.rm=T)
        mean_sums = mean(sums, na.rm = TRUE)
        e_norm = t(t(e)/(sums/mean_sums))
        qc_RSDs[['mTIC']] = RSD(e_norm[,p$sampleType=='qc'])
        calculation_times[['mTIC']] = Sys.time() - start
        cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['mTIC']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['mTIC']]<0.2,na.rm = TRUE),".\n"))
        if(with_validate){
          val_RSDs[['mTIC']] = RSD(e_norm[,p$sampleType=='validate'])
          cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['mTIC']],na.rm = TRUE),4)*100,"%.\n"))
          cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['mTIC']]<0.2,na.rm = TRUE),".\n"))
        }
      }else{
        e_norm = NA
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('sum' %in% methods){
    Sys.sleep(2)
    normalized_dataset[['sum']] = tryCatch({
      cat("<!--------- sum normalizaion --------->\n")
      start = Sys.time()
      sums = colSums(e,na.rm = T)
      e_norm = t(t(e)/sums*mean(sums,na.rm = T))
      qc_RSDs[['sum']] = RSD(e_norm[,p$sampleType=='qc'])
      calculation_times[['sum']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['sum']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['sum']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['sum']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['sum']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['sum']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('median' %in% methods){
    Sys.sleep(2)
    normalized_dataset[['median']] = tryCatch({
      cat("<!--------- median normalizaion --------->\n")
      start = Sys.time()
      medians = apply(e, 2, median, na.rm = T)
      e_norm = t(t(e)/medians*median(medians,na.rm = T))
      qc_RSDs[['median']] = RSD(e_norm[,p$sampleType=='qc'])
      calculation_times[['median']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['median']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['median']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['median']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['median']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['median']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('PQN' %in% methods){
    Sys.sleep(2)
    normalized_dataset[['PQN']] = tryCatch({
      cat("<!--------- PQN --------->\n")
      start = Sys.time()
      reference <- apply(e, 1, median, na.rm = TRUE)
      reference[reference==0] = 1
      quotient <- e/reference
      quotient.median <- apply(quotient, 2, median, na.rm = TRUE)
      e_norm <- t(t(e)/quotient.median)
      qc_RSDs[['PQN']] = RSD(e_norm[,p$sampleType=='qc'])
      calculation_times[['PQN']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['PQN']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['PQN']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['PQN']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['PQN']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['PQN']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if("contrast" %in% methods){
    Sys.sleep(2)
    normalized_dataset[['contrast']] = tryCatch({
      cat("<!--------- contrast --------->\n")
      start = Sys.time()
      threshold=1e-11
      e[e <= 0] <- threshold
      maffy.data <- maffy.normalize(data.matrix(e),
                                    subset=1:nrow(e),
                                    span=0.75,
                                    verbose=FALSE,
                                    family="gaussian",
                                    log.it=FALSE)
      subtract <- function(x){
        t(t(x)-apply(x,2,quantile,0.1,na.rm = TRUE))
      }
      e_norm <- subtract(maffy.data)
      rownames(e_norm) = rownames(e)
      colnames(e_norm) = colnames(e)
      qc_RSDs[['contrast']] = RSD(e_norm[,p$sampleType=='qc'])
      calculation_times[['contrast']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['contrast']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['contrast']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['contrast']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['contrast']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['contrast']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })

  }
  if("quantile" %in% methods){
    Sys.sleep(2)
    normalized_dataset[['quantile']] = tryCatch({
      cat("<!--------- quantile --------->\n")
      start = Sys.time()
      normalize.quantile <- get("normalize.quantiles",en=asNamespace("affy"))
      e_norm <- normalize.quantile(data.matrix(e))
      rownames(e_norm) <- rownames(e)
      colnames(e_norm) <- colnames(e)
      qc_RSDs[['quantile']] = RSD(e_norm[,p$sampleType=='qc'])
      calculation_times[['quantile']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['quantile']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['quantile']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['quantile']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['quantile']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['quantile']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('linear' %in% methods){
    Sys.sleep(2)
    normalized_dataset[['linear']] = tryCatch({
      cat("<!--------- linear --------->\n")
      start = Sys.time()
      linear.baseline <- apply(e, 1, median,na.rm = TRUE)
      baseline.mean <- mean(linear.baseline,na.rm = TRUE)
      sample.means <- apply(e, 2, mean,na.rm = TRUE)
      linear.scaling <- baseline.mean/sample.means
      e_norm <- t(t(e) * linear.scaling)
      qc_RSDs[['linear']] = RSD(e_norm[,p$sampleType=='qc'])
      calculation_times[['linear']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['linear']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['linear']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['linear']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['linear']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['linear']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('liwong' %in% methods){
    Sys.sleep(2)
    normalized_dataset[['liwong']] = tryCatch({
      cat("<!--------- liwong --------->\n")
      start = Sys.time()
      average.intensity <- apply(e,2,mean,na.rm = TRUE)
      median.number <- round(ncol(e)/2 + 0.1)
      ordering <- order(average.intensity)
      median.sample.number <- ordering[median.number]
      median.sample <- e[,median.sample.number]
      e_norm <- vector()
      for(i in 1:ncol(e)){
        tryCatch({
          liwong.model <- normalize.invariantset(data=e[,i],
                                                 ref=median.sample,
                                                 prd.td=c(0.003,0.007))
          liwong.sample <- predict(liwong.model$n.curve$fit, e[,i])
        },error = function(er){
          liwong.sample = list();liwong.sample$y = e[,i]
        })

        e_norm <- cbind(e_norm,liwong.sample$y)
      }
      colnames(e_norm) = colnames(e)
      qc_RSDs[['liwong']] = RSD(e_norm[,p$sampleType=='qc'])
      calculation_times[['liwong']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['liwong']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['liwong']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['liwong']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['liwong']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['liwong']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if("cubic" %in% methods){
    Sys.sleep(2)
    normalized_dataset[['cubic']] = tryCatch({
      cat("<!--------- cubic --------->\n")
      start = Sys.time()
      e_norm <- normalize.qspline(e,samples=0.02,target=apply(e,1,mean,na.rm = TRUE),verbose = FALSE)
      rownames(e_norm) <- rownames(e)
      colnames(e_norm) <- colnames(e)
      qc_RSDs[['cubic']] = RSD(e_norm[,p$sampleType=='qc'])
      calculation_times[['cubic']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['cubic']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['cubic']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['cubic']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['cubic']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['cubic']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('batch_ratio' %in% methods){
    Sys.sleep(2)
    normalized_dataset[['batch_ratio']] = tryCatch({
      cat("<!--------- batch ratio --------->\n")
      start = Sys.time()
      e_norm = matrix(,nrow=nrow(e),ncol=ncol(e))
      QC.index = p[["sampleType"]]
      batch = p[["batch"]]
      for(i in 1:nrow(f)){
        means = by(as.numeric(e[i,QC.index=='qc']),batch[QC.index=='qc'], mean, na.rm=T)
        mean_means = mean(means, na.rm = TRUE)
        for(b in 1:length(unique(batch))){
          e_norm[i,batch%in%unique(batch)[b]] = as.numeric(e[i,batch%in%unique(batch)[b]])/(means[[unique(batch)[b]]]/mean_means)
        }
      }
      rownames(e_norm) = rownames(e)
      colnames(e_norm) = colnames(e)
      qc_RSDs[['batch_ratio']] = RSD(e_norm[,p$sampleType=='qc'])
      calculation_times[['batch_ratio']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['batch_ratio']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['batch_ratio']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['batch_ratio']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['batch_ratio']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['batch_ratio']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('batch_loess' %in% methods){
    Sys.sleep(2)
    normalized_dataset[['batch_loess']] = tryCatch({
      cat("<!--------- batch loess --------->\n(This may take a while...)\n")
      start = Sys.time()
      e_norm = matrix(,nrow=nrow(e),ncol=ncol(e))
      QC.index = p[["sampleType"]]
      batch = p[["batch"]]
      time = p[["time"]]
      n_CV = 5
      QC.index.train = QC.index.test = list()
      n_CV = 5
      seed = 1
      set.seed(seed)
      QC.index.train = QC.index.test = list()
      e_qc_only = e[,p$sampleType=='qc']
      if(any(table(p$batch[p$sampleType=='qc']))<7){
        ratio = 0.7
      }else{
        ratio = 0.8
      }
      for(j in 1:n_CV){
        QC.index.train.temp = sample(1L:ncol(e_qc_only),round(ncol(e_qc_only)*ratio))
        QC.index.test.temp = c(1L:ncol(e_qc_only))[!c(1L:ncol(e_qc_only))%in%QC.index.train.temp]
        QC.index.train. = rep('sample',ncol(e_qc_only))
        QC.index.test. = rep('sample',ncol(e_qc_only))
        QC.index.train.[QC.index.train.temp] = 'qc'
        QC.index.test.[QC.index.test.temp] = 'qc'
        QC.index.train[[j]] = QC.index.train.
        QC.index.test[[j]] = QC.index.test.
      }
      loess_fun_cv = function(e,train.index = QC.index,test.index=NULL,batch,time){
        cl = makeCluster(detectCores())
        e_norm = parSapply(cl, X=1:nrow(e), function(i,e,train.index,batch,time,remove_outlier,loess_wrapper_extrapolate){
          # for(i in 1:nrow(e)){
          e_norm = tryCatch({
            line = e[i,]
            for(b in 1:length(unique(batch))){
              outlier_remove = remove_outlier(e[i,(batch %in% unique(batch)[b]) & (train.index=='qc')])
              if(length(outlier_remove$index) == 0){
                lm = loess_wrapper_extrapolate(x=time[(batch %in% unique(batch)[b]) & (train.index=='qc')], y = e[i,(batch %in% unique(batch)[b]) & (train.index=='qc')])[[1]]
              }else{
                lm = loess_wrapper_extrapolate(x=time[(batch %in% unique(batch)[b]) & (train.index=='qc')][-outlier_remove$index], y = e[i,(batch %in% unique(batch)[b]) & (train.index=='qc')][-outlier_remove$index])[[1]]
              }
              line[batch %in% unique(batch)[b]] = predict(lm,newdata  = time[batch %in% unique(batch)[b]])


              if(length(which(is.na(line[batch %in% unique(batch)[b]])))>0){
                for(j in which(is.na(line[batch %in% unique(batch)[b]]))){
                  time_notNA = time[batch %in% unique(batch)[b]][-which(is.na(line[batch %in% unique(batch)[b]]))]
                  closest_time = time_notNA[which.min(abs(time_notNA - time[batch %in% unique(batch)[b]][j]))]
                  line[batch %in% unique(batch)[b]][j] = line[batch %in% unique(batch)[b]][which(time[batch %in% unique(batch)[b]]==closest_time)]
                }
              }

            }
            
            if(sum(line<0)>(length(line)/5)){
              stop("too many negative value. LOESS failed.")
            }else{
              line[line<0] = runif(sum(line<0), min = max(c(median(e[i,], na.rm = TRUE) -  0.1 * sd(e[i,], na.rm = TRUE),0)), max = max(c(median(e[i,], na.rm = TRUE) +  0.1 * sd(e[i,], na.rm = TRUE),1)))
            }
            
            # if(length(which(is.na(line)))>0){
            #   for(j in which(is.na(line))){
            #     time_notNA = time[-which(is.na(line))]
            #     closest_time = time_notNA[which.min(abs(time_notNA - time[j]))]
            #     line[j] = line[which(time==closest_time)]
            #   }
            # }
            e[i,] / (line / median(e[i,], na.rm = TRUE))
            # if(sum((e[i,] / (line / median(e[i,], na.rm = TRUE)))<0)){
            #   stop(i)
            # }
          # }
    
          
          },error = function(er){
            e[i,]
          })
          return(e_norm)
        },e,train.index,batch,time,remove_outlier,loess_wrapper_extrapolate)
        stopCluster(cl)
        e_norm = t(e_norm)
        if(!is.null(test.index)){
          rsd = RSD(e_norm[,test.index=='qc'])
        }else(
          rsd = NULL
        )
        return(list(data = e_norm,rsd = rsd))
      }
      rsds = matrix(,nrow = nrow(e), ncol = n_CV)
      for(i in 1:n_CV){
        rsds[,i] = loess_fun_cv(e=e_qc_only,train.index=QC.index.train[[i]],test.index = QC.index.test[[i]],batch = batch[p$sampleType=='qc'],time=time[p$sampleType=='qc'])[[2]]
      }
      qc_RSD = apply(rsds,1,mean,na.rm = TRUE)
      e_norm = loess_fun_cv(e,train.index = QC.index,test.index=NULL,batch=batch,time=time)[[1]]
      rownames(e_norm) = rownames(e)
      colnames(e_norm) = colnames(e)
      qc_RSDs[['batch_loess']] = qc_RSD
      calculation_times[['batch_loess']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['batch_loess']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['batch_loess']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['batch_loess']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['batch_loess']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['batch_loess']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('SERRF' %in% methods){
    normalized_dataset[['SERRF']] = tryCatch({
      cat("<!--------- SERRF --------->\n(This may take a while...)\n")
      start = Sys.time()
      e_norm = matrix(,nrow=nrow(e),ncol=ncol(e))
      QC.index = p[["sampleType"]]
      batch = p[["batch"]]
      time = p[["time"]]
      batch = factor(batch)
      num = 10
      start = Sys.time();

      cl = makeCluster(detectCores())

      serrfR = function(train = e[,p$sampleType == 'qc'],
                        target = e[,p$sampleType == 'sample'],
                        num = 10,
                        batch. = factor(c(batch[p$sampleType=='qc'],batch[p$sampleType=='sample'])),
                        time. = c(time[p$sampleType=='qc'],time[p$sampleType=='sample']),
                        sampleType. = c(p$sampleType[p$sampleType=='qc'],p$sampleType[p$sampleType=='sample']),cl){


        all = cbind(train, target)
        normalized = rep(0, ncol(all))
        for(j in 1:nrow(all)){
          for(b in 1:length(unique(batch.))){
            current_batch = levels(batch.)[b]
            all[j,batch.%in%current_batch][all[j,batch.%in%current_batch] == 0] = rnorm(length(all[j,batch.%in%current_batch][all[j,batch.%in%current_batch] == 0]))
            all[j,batch.%in%current_batch][is.na(all[j,batch.%in%current_batch])] = rnorm(length(all[j,batch.%in%current_batch][is.na(all[j,batch.%in%current_batch])]),mean = all[j,batch.%in%current_batch][!is.na(all[j,batch.%in%current_batch])])
          }
        }

        corrs_train = list()
        corrs_target = list()
        for(b in 1:length(unique(batch.))){

          current_batch = levels(batch.)[b]

          train_scale = t(apply(train[,batch.[sampleType.=='qc']%in%current_batch],1,scale))
          if(is.null(target[,batch.[!sampleType.=='qc']%in%current_batch])){
            target_scale = t(apply(target[,batch.[!sampleType.=='qc']%in%current_batch],1,scale))
          }else{
            target_scale = scale(target[,batch.[!sampleType.=='qc']%in%current_batch])
          }

          # all_scale = cbind(train_scale, target_scale)

          # e_current_batch = all_scale
          corrs_train[[current_batch]] = cor(t(train_scale), method = "spearman")
          corrs_target[[current_batch]] = cor(t(target_scale), method = "spearman")
          # corrs[[current_batch]][is.na(corrs[[current_batch]])] = 0
        }




        pred = parSapply(cl, X = 1:nrow(all), function(j,all,batch.,ranger, sampleType., time., num,corrs_train,corrs_target){
          # for(j in 1:nrow(all)){
          # j = j+1
          print(j)
          normalized  = rep(0, ncol(all))
          qc_train_value = list()
          qc_predict_value = list()
          sample_value = list()
          sample_predict_value = list()

          for(b in 1:length(levels(batch.))){
            current_batch = levels(batch.)[b]
            e_current_batch = all[,batch.%in%current_batch]
            corr_train = corrs_train[[current_batch]]
            corr_target = corrs_target[[current_batch]]


            corr_train_order = order(abs(corr_train[,j]),decreasing = TRUE)
            corr_target_order = order(abs(corr_target[,j]),decreasing = TRUE)

            sel_var = c()
            l = num
            while(length(sel_var)<(num)){
              sel_var = intersect(corr_train_order[1:l], corr_target_order[1:l])
              sel_var = sel_var[!sel_var == j]
              l = l+1
            }



            train.index_current_batch = sampleType.[batch.%in%current_batch]
            train_data_y = scale(e_current_batch[j, train.index_current_batch=='qc'],scale=F)
            train_data_x = apply(e_current_batch[sel_var, train.index_current_batch=='qc'],1,scale)

            if(is.null(dim(e_current_batch[sel_var, !train.index_current_batch=='qc']))){
              test_data_x = t(scale(e_current_batch[sel_var, !train.index_current_batch=='qc']))
            }else{
              test_data_x = apply(e_current_batch[sel_var, !train.index_current_batch=='qc'],1,scale)
            }

            train_NA_index  = apply(train_data_x,2,function(x){
              sum(is.na(x))>0
            })

            train_data_x = train_data_x[,!train_NA_index]
            test_data_x = test_data_x[,!train_NA_index]

            if(!class(test_data_x)=="matrix"){
              test_data_x = t(test_data_x)
            }

            good_column = apply(train_data_x,2,function(x){sum(is.na(x))==0}) & apply(test_data_x,2,function(x){sum(is.na(x))==0})
            train_data_x = train_data_x[,good_column]
            test_data_x = test_data_x[,good_column]
            if(!class(test_data_x)=="matrix"){
              test_data_x = t(test_data_x)
            }
            train_data = data.frame(y = train_data_y,train_data_x )
            colnames(train_data) = c("y", paste0("V",1:(ncol(train_data)-1)))
            model = ranger(y~., data = train_data)

            test_data = data.frame(test_data_x)
            colnames(test_data) = colnames(train_data)[-1]

            norm = e_current_batch[j,]
            norm[train.index_current_batch=='qc'] = e_current_batch[j, train.index_current_batch=='qc']/((predict(model, data = train_data)$prediction+mean(e_current_batch[j,train.index_current_batch=='qc'],na.rm=TRUE))/mean(e_current_batch[j,train.index_current_batch=='qc'],na.rm=TRUE))
            # norm[!train.index_current_batch=='qc'] =(e_current_batch[j,!train.index_current_batch=='qc'])/((predict(model, data = test_data)$prediction + mean(e_current_batch[j,!train.index_current_batch=='qc'],na.rm=TRUE))/mean(e_current_batch[j,!train.index_current_batch=='qc'],na.rm=TRUE))

            norm[!train.index_current_batch=='qc'] =(e_current_batch[j,!train.index_current_batch=='qc'])/((predict(model,data = test_data)$predictions  + mean(e_current_batch[j, !train.index_current_batch=='qc'],na.rm=TRUE))/(median(e_current_batch[j,!train.index_current_batch=='qc'],na.rm = TRUE)))
            # plot(p$time[!train.index_current_batch=='qc'], (e_current_batch[j,!train.index_current_batch=='qc'])/((predict(model,data = test_data)$predictions  + mean(e_current_batch[j, !train.index_current_batch=='qc'],na.rm=TRUE))/(median(e_current_batch[j,!train.index_current_batch=='qc'],na.rm = TRUE))))
            norm[train.index_current_batch=='qc'] = norm[train.index_current_batch=='qc']/(median(norm[train.index_current_batch=='qc'],na.rm=TRUE)/median(all[j,sampleType.=='qc'],na.rm=TRUE))
            norm[!train.index_current_batch=='qc'] = norm[!train.index_current_batch=='qc']/(median(norm[!train.index_current_batch=='qc'],na.rm=TRUE)/median(all[j,!sampleType.=='qc'],na.rm=TRUE))
            norm[!is.finite(norm)] = rnorm(length(norm[!is.finite(norm)]),sd = sd(norm[is.finite(norm)],na.rm=TRUE)*0.01)
            normalized[batch.%in%current_batch] = norm


            qc_train_value[[b]] = train_data_y + mean(e_current_batch[j, train.index_current_batch=='qc'])
            qc_predict_value[[b]] = predict(model,data = train_data)$predictions + mean(e_current_batch[j, train.index_current_batch=='qc'])
            sample_value[[b]] = e_current_batch[j,!train.index_current_batch=='qc']
            sample_predict_value[[b]] = predict(model,data = test_data)$predictions  + mean(e_current_batch[j, !train.index_current_batch=='qc'])

          }


          # par(mfrow=c(1,2))
          # ylim = c(min(e[j,],norm), max(e[j,],norm))
          # plot(time.[sampleType.=='qc'], unlist(qc_train_value),col = "red",ylim = ylim,main=j)
          # points(time.[sampleType.=='qc'],unlist(qc_predict_value),col = "yellow")
          #
          # points(time.[!sampleType.=='qc'],unlist(sample_value),col = "blue")
          # points(time.[!sampleType.=='qc'],unlist(sample_predict_value),col = "green")
          #
          # plot(time.,normalized, col = factor(sampleType.), ylim = ylim,main=f$label[j])
          #
          # j = j + 1

          #



          # }




          return(normalized)
        },all,batch.,ranger, sampleType., time., num,corrs_train,corrs_target)
        normed = t(pred)

        normed_target = normed[,!sampleType.=='qc']


        for(i in 1:nrow(normed_target)){
          normed_target[i,is.na(normed_target[i,])] = rnorm(sum(is.na(normed_target[i,])), mean = min(normed_target[i,!is.na(normed_target[i,])], na.rm = TRUE), sd = sd(normed_target[i,!is.na(normed_target[i,])])*0.1)
        }
        for(i in 1:nrow(normed_target)){
          normed_target[i,normed_target[i,]<0] = runif(1) * min(normed_target[i,normed_target[i,]>0], na.rm = TRUE)
        }


        normed_train = normed[,sampleType.=='qc']


        for(i in 1:nrow(normed_train)){
          normed_train[i,is.na(normed_train[i,])] = rnorm(sum(is.na(normed_train[i,])), mean = min(normed_train[i,!is.na(normed_train[i,])], na.rm = TRUE), sd = sd(normed_train[i,!is.na(normed_train[i,])])*0.1)
        }
        for(i in 1:nrow(normed_train)){
          normed_train[i,normed_train[i,]<0] = runif(1) * min(normed_train[i,normed_train[i,]>0], na.rm = TRUE)
        }
        return(list(normed_train=normed_train,normed_target=normed_target))
      }


      serrf_normalized = e
      serrf_normalized_modeled = serrfR(train = e[,p$sampleType == 'qc'], target = e[,p$sampleType == 'sample'], num = num,batch. = factor(c(batch[p$sampleType=='qc'],batch[p$sampleType=='sample'])),time. = c(time[p$sampleType=='qc'],time[p$sampleType=='sample']),sampleType. = c(p$sampleType[p$sampleType=='qc'],p$sampleType[p$sampleType=='sample']),cl)
      serrf_normalized[,p$sampleType == 'qc'] = serrf_normalized_modeled$normed_train
      serrf_normalized[,p$sampleType == 'sample'] = serrf_normalized_modeled$normed_target



      qc_only_data = e[,p$sampleType=='qc']
      cv = 5
      RSDs = list()
      if(any(table(p$batch[p$sampleType=='qc']))<7){
        ratio = 0.7
      }else{
        ratio = 0.8
      }
      for(k in 1:cv){
        train_index = sample(1L:sum(p$sampleType=='qc'),round(sum(p$sampleType=='qc')*ratio))
        test_index = c(1L:sum(p$sampleType=='qc'))[!(c(1L:sum(p$sampleType=='qc'))%in%train_index)]
        while(length(unique(batch[p$sampleType=='qc'][test_index]))<length(unique(batch))){
          train_index = sample(1L:sum(p$sampleType=='qc'),round(sum(p$sampleType=='qc')*ratio))
          test_index = c(1L:sum(p$sampleType=='qc'))[!(c(1L:sum(p$sampleType=='qc'))%in%train_index)]
        }
        serrf_normalized_on_cross_validate = serrfR(train = qc_only_data[,train_index], target = qc_only_data[,test_index], num = num,batch. = factor(c(batch[p$sampleType=='qc'][train_index],batch[p$sampleType=='qc'][test_index])),time. = c(time[p$sampleType=='qc'][train_index],time[p$sampleType=='qc'][test_index]),sampleType. = rep(c("qc","sample"),c(length(train_index),length(test_index))),cl)

        RSDs[[k]] = RSD(serrf_normalized_on_cross_validate$normed_target)
      }
      qc_RSD = apply(do.call("cbind",RSDs),1,mean)


      if(with_validate){
        serrf_normalized_validate = serrfR(train = e[,p$sampleType == 'qc'], target = e[,p$sampleType == 'validate'], num = num,batch. = factor(c(batch[p$sampleType=='qc'],batch[p$sampleType=='validate'])),time. = c(time[p$sampleType=='qc'],time[p$sampleType=='validate']),sampleType. = c(p$sampleType[p$sampleType=='qc'],p$sampleType[p$sampleType=='validate']),cl)
        e_norm = e
        e_norm[,p$sampleType=='qc'] = serrf_normalized[,p$sampleType == 'qc']
        e_norm[,p$sampleType=='sample'] = serrf_normalized[,p$sampleType == 'sample']
        e_norm[,p$sampleType=='validate'] = serrf_normalized_validate$normed_target

      }else{
        e_norm[,p$sampleType=='qc'] = serrf_normalized[,p$sampleType == 'qc']
        e_norm[,p$sampleType=='sample'] = serrf_normalized[,p$sampleType == 'sample']
      }
      rownames(e_norm) = rownames(e)
      colnames(e_norm) = colnames(e)
      qc_RSDs[['SERRF']] = qc_RSD
      calculation_times[['SERRF']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['SERRF']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['SERRF']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['SERRF']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['SERRF']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['SERRF']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('svm' %in% methods){
    normalized_dataset[['svm']] = tryCatch({
      cat("<!--------- svm --------->\n(This may take a while...)\n")
      start = Sys.time()
      # https://pubs.rsc.org/en/content/articlepdf/2015/an/c5an01638j
      e_norm = matrix(,nrow=nrow(e),ncol=ncol(e))
      QC.index = p[["sampleType"]]
      batch = p[["batch"]]
      time = p[["time"]]
      n_CV = 5
      QC.index.train = QC.index.test = list()
      n_CV = 5
      seed = 1
      set.seed(seed)
      QC.index.train = QC.index.test = list()
      e_qc_only = e[,p$sampleType=='qc']
      if(any(table(p$batch[p$sampleType=='qc']))<7){
        ratio = 0.7
      }else{
        ratio = 0.8
      }
      for(j in 1:n_CV){
        QC.index.train.temp = sample(1L:ncol(e_qc_only),round(ncol(e_qc_only)*ratio))
        QC.index.test.temp = c(1L:ncol(e_qc_only))[!c(1L:ncol(e_qc_only))%in%QC.index.train.temp]
        QC.index.train. = rep('sample',ncol(e_qc_only))
        QC.index.test. = rep('sample',ncol(e_qc_only))
        QC.index.train.[QC.index.train.temp] = 'qc'
        QC.index.test.[QC.index.test.temp] = 'qc'
        QC.index.train[[j]] = QC.index.train.
        QC.index.test[[j]] = QC.index.test.
      }
      svm_fun_cv = function(e,train.index = QC.index,test.index=NULL,batch,time){
        cl = makeCluster(detectCores())
        e_norm = parSapply(cl, X=1:nrow(e), function(i,e,train.index,batch,time,remove_outlier,trainControl,train){
          # for(i in 1:nrow(e)){
          tryCatch({
            line = e[i,]
            for(b in 1:length(unique(batch))){
              outlier_remove = remove_outlier(e[i,(batch %in% unique(batch)[b]) & train.index=='qc'])
              if(length(outlier_remove$index) == 0){
                dta = data.frame(x = time[(batch %in% unique(batch)[b]) & train.index=='qc'], y = e[i,(batch %in% unique(batch)[b]) & train.index=='qc'])
                lm = train(y~., data=dta, method = "svmLinear", trControl = trainControl(method = "cv", savePred=T))
              }else{
                dta = data.frame(x = time[(batch %in% unique(batch)[b]) & train.index=='qc'][-outlier_remove$index], y = e[i,(batch %in% unique(batch)[b]) & train.index=='qc'][-outlier_remove$index])
                lm = train(y~., data=dta, method = "svmLinear", trControl = trainControl(method = "cv", savePred=T))
              }
              line[batch %in% unique(batch)[b]] = predict(lm,newdata  = data.frame(x = time[batch %in% unique(batch)[b]]))
            }
            if(length(which(is.na(line)))>0){
              for(j in which(is.na(line))){
                time_notNA = time[-which(is.na(line))]
                closest_time = time_notNA[which.min(abs(time_notNA - time[j]))]
                line[j] = line[which(time==closest_time)]
              }
            }
            e_norm = e[i,] / (line / median(e[i,], na.rm = TRUE))
          },error = function(er){
            e[i,]
          })

          # }

        },e,train.index,batch,time,remove_outlier,trainControl,train)
        stopCluster(cl)
        e_norm = t(e_norm)
        if(!is.null(test.index)){
          rsd = RSD(e_norm[,test.index=='qc'])
        }else(
          rsd = NULL
        )
        return(list(data = e_norm,rsd = rsd))
      }
      rsds = matrix(,nrow = nrow(e), ncol = n_CV)
      for(i in 1:n_CV){
        rsds[,i] = svm_fun_cv(e=e_qc_only,train.index=QC.index.train[[i]],test.index = QC.index.test[[i]],batch = batch[p$sampleType=='qc'],time=time[p$sampleType=='qc'])[[2]]
      }
      qc_RSD = apply(rsds,1,mean,na.rm = TRUE)
      e_norm = svm_fun_cv(e,train.index = QC.index,test.index=NULL,batch=batch,time=time)[[1]]
      rownames(e_norm) = rownames(e)
      colnames(e_norm) = colnames(e)
      qc_RSDs[['svm']] = qc_RSD
      calculation_times[['svm']] = Sys.time() - start
      cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['svm']],na.rm = TRUE),4)*100,"%.\n"))
      cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['svm']]<0.2,na.rm = TRUE),".\n"))
      if(with_validate){
        val_RSDs[['svm']] = RSD(e_norm[,p$sampleType=='validate'])
        cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['svm']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['svm']]<0.2,na.rm = TRUE),".\n"))
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })
  }
  if('nomis' %in% methods){
    Sys.sleep(2)
    cat("<!--------- nomis --------->\n")
    normalized_dataset[['nomis']] = tryCatch({cat("nomis normalization.\n")
      start = Sys.time()
      skip_NOMIS = FALSE
      if(!'compoundType' %in% colnames(f)){
        cat(paste0("warning: 'compoundType' is not found. NOMIS is skipped.\n"))
        skip_NOMIS = TRUE
      }else{
        IS_column = f[['compoundType']]
        if(!'istd' %in% unique(f[['compoundType']])){
          cat(paste0("'istd' (case-sensitive) is not found in the 'compoundType'. NOMIS is skipped.\n"))
          skip_NOMIS = TRUE
        }

      }
      if(!skip_NOMIS){
        IS_column = f[['compoundType']]
        istd_index =  which(IS_column%in%'istd')

        inputdata = data.frame(Group = "A", t(log((e + sqrt(e^2 + 4)) * 0.5, base  = exp(1))))
        colnames(inputdata) = c("Group",f$label)
        rownames(inputdata) = paste0("S",1:nrow(inputdata))
        normed = exp(t(Normalise(inputdata,method = 'nomis',nc = istd_index)$output[,-1]))
        qc_RSDs[['nomis']] = RSD(normed[,p$sampleType=='qc'])
        e_norm = rbind(e[istd_index,],normed)
        calculation_times[['nomis']] = Sys.time() - start
        cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['nomis']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['nomis']]<0.2,na.rm = TRUE),".\n"))
        if(with_validate){
          val_RSDs[['nomis']] = RSD(e_norm[,p$sampleType=='validate'])
          cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['nomis']],na.rm = TRUE),4)*100,"%.\n"))
          cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['nomis']]<0.2,na.rm = TRUE),".\n"))
        }
      }else{
        e_norm = NA
      }
      e_norm[,sample_rank]
    },error = function(error){
      error
    })

  }
  if('bmis' %in% methods){
    Sys.sleep(2)
    cat("<!--------- bmis --------->\n")
    normalized_dataset[['bmis']] =tryCatch({cat("bmis normalization.\n")
      start = Sys.time()
      skip_BMIS = FALSE
      if(!'compoundType' %in% colnames(f)){
        cat(paste0("warning: 'compoundType' is not found. BMIS is skipped.\n"))
        skip_BMIS = TRUE
      }else{
        IS_column = f[['compoundType']]
        if(!'istd' %in% unique(f[['compoundType']])){
          cat(paste0("'istd' (case-sensitive) should is not found in the 'compoundType'. BMIS is skipped.\n"))
        }
        skip_BMIS = TRUE
      }
      if(!skip_BMIS){
        f_ = f[,c("label","No","compoundType")]
        p_ = p
        e_ = e
        IS_column = f[['compoundType']]
        istd_index = IS_column%in%'istd'
        Inj_vol_f = data.frame(label = "Inj_vol", No=nrow(f),compoundType = 'istd')
        Inj_vol_e = matrix(apply(e[istd_index,],2,sum,na.rm = TRUE),nrow = 1)
        istd_index = c(istd_index,TRUE)

        f_ = rbind(f_,Inj_vol_f)
        e_ = rbind(e_,Inj_vol_e)
        rownames(e_) = f_$label

        colnames(e_) = paste0("runDate_",ifelse(p_$sampleType=='qc',"Poo",ifelse(p_$sampleType=='validate','Blk',"Smp")),"_",
                              colnames(e_),"_","replicate")

        p_$label = paste0("runDate_",ifelse(p_$sampleType=='qc',"Poo",ifelse(p_$sampleType=='validate','Blk',"Smp")),"_",
                          p_$label,"_","replicate")

        xcms.dat = e_[!istd_index,]


        IS.dat = data.frame(Area = c(t(e_[istd_index,])), Replicate.Name = rep(colnames(e_),sum(istd_index)), MassFeature = rep(f_$label[istd_index],each = ncol(e_)),stringsAsFactors = FALSE)



        xcms.long = cbind(MassFeature = rep(f_$label[!istd_index],ncol(e_)), Replicate.Name = rep(colnames(e_),each = sum(!istd_index)),Area = c(xcms.dat))
        xcms.long = data.frame(xcms.long, stringsAsFactors = FALSE)
        xcms.long$Area = as.numeric(xcms.long$Area)
        IS.means = data.frame(MassFeature = f_$label[istd_index], ave = apply(e_[istd_index,],1,mean,na.rm = T))
        binded <- rbind(IS.dat, xcms.long)
        binded$Replicate.Name = factor(binded$Replicate.Name, levels = unique(binded$Replicate.Name))
        wArea<- binded %>% select(Replicate.Name, MassFeature, Area) %>% spread(key=MassFeature, value=Area) %>% as.data.frame

        IS.list <- unique(IS.dat$MassFeature)
        this.IS <- IS.list[1]
        area.norm <- wArea[,-1] %>%
          sapply(FUN = function(x) x/wArea[,grep(this.IS,
                                                 names(wArea))]) %>%
          as_data_frame %>% mutate(Replicate.Name = wArea$Replicate.Name) %>%
          gather(MassFeature,Area_Norm, -Replicate.Name)
        this.mean <- IS.means %>% filter(MassFeature==this.IS) %>%
          select(ave) %>% as.numeric
        area.norm <- area.norm %>% mutate(Area_Norm = Area_Norm*this.mean)
        key <- ncol(area.norm)
        count <- length(which(!is.na(area.norm$Area_Norm)))/
          length(unique(area.norm$Replicate.Name))
        names(area.norm)[key] <- paste(this.IS,"Norm.Area",sep=".")
        # cat(paste(1, this.IS, count, sep="-"))
        IS.list = f_$label[istd_index]
        for (i in 2:length(IS.list)){
          this.IS <- IS.list[i]
          if(length(wArea[,grep(this.IS, names(wArea))])!=0){
            this.norm <- wArea[,-1] %>%
              sapply(FUN = function(x) x/wArea[,grep(this.IS,
                                                     names(wArea))]) %>%
              as_data_frame %>%
              mutate(Replicate.Name = wArea$Replicate.Name) %>%
              gather(MassFeature,Area_Norm, -Replicate.Name)
            this.mean <- IS.means %>% filter(MassFeature==this.IS) %>%
              select(ave) %>% as.numeric
            this.norm <- this.norm %>% mutate(Area_Norm = Area_Norm*this.mean)
            key <- ncol(area.norm)
            area.norm[,key+1] <- this.norm$Area_Norm
            names(area.norm)[key+1] <- paste(this.IS,"Norm.Area",sep=".")
            count <- length(which(!is.na(this.norm$Area_Norm)))/
              length(unique(this.norm$Replicate.Name))
            # cat(paste(i, this.IS, count, sep="-"))
          }
        }


        # area.norm$Replicate.Name = paste0("runDate_",paste0(rep(ifelse(p_$sampleType=='qc',"Poo",ifelse(p_$sampleType=='validate','Blk',"Smp")),nrow(f_))),"_",
        #                                   area.norm$Replicate.Name,"_","replicate")


        # mydata_new = data.frame(runDate = "runDate", type = ifelse(p$sampleType=='qc',"Poo",ifelse(p$sampleType=='validate','Blk',"Smp")),SampleID = p$label, replicate = "replicate")

        mydata_new <- area.norm %>% separate(Replicate.Name,
                                             c("runDate",
                                               "type","SampID","replicate"),"_") %>%
          mutate(Run.Cmpd = paste(area.norm$Replicate.Name,area.norm$MassFeature))
        binded <- binded %>% mutate(Run.Cmpd = paste(Replicate.Name, MassFeature))

        dat <- full_join(binded, mydata_new)



        cut.off <- 0.4

        dat2 <- dat %>%
          filter(MassFeature %in% IS.dat$MassFeature) %>%
          select(-(Area:MassFeature))  %>%
          select(-(runDate:replicate)) %>%
          gather(key = "MIS", value = "Adjusted_Area", factor_key = TRUE, -Run.Cmpd) %>%
          left_join(dat %>% select(type, MassFeature, Run.Cmpd)) %>%
          mutate(Adjusted_Area = as.numeric(Adjusted_Area))

        smpdat <- dat2 %>%
          filter(type == "Smp")%>%
          group_by(MassFeature, MIS) %>%
          summarise(RSD_ofSmp = sd(Adjusted_Area)/mean(Adjusted_Area))

        alldat <- dat2 %>%
          filter(type == "Poo")%>%
          group_by(MassFeature, MIS) %>%
          summarise(RSD_ofPoo = sd(Adjusted_Area)/mean(Adjusted_Area)) %>%
          left_join(smpdat)

        injectONlY <- alldat %>%
          filter(MIS == "Inj_vol.Norm.Area" ) %>%
          mutate(Orig_RSD = RSD_ofPoo)%>%
          select(-RSD_ofPoo, -RSD_ofSmp, -MIS)

        injectONlY_toPlot <- alldat %>%
          filter(MIS == "Inj_vol.Norm.Area" )

        newalldat <- left_join(alldat, injectONlY) %>%
          mutate(del_RSD = ( Orig_RSD - RSD_ofPoo),
                 percRSD = del_RSD/Orig_RSD) %>%
          mutate(accept_MIS = (percRSD > cut.off))


        longdat <- dat %>%
          select(-(Area:MassFeature))  %>%
          select(-(runDate:replicate)) %>%
          gather(key = "MIS", value = "Adjusted_Area", factor_key = TRUE, -Run.Cmpd) %>%
          left_join(dat %>% select(type, MassFeature, Run.Cmpd)) %>%
          mutate(Adjusted_Area = as.numeric(Adjusted_Area))


        poodat <- longdat %>%
          filter(type == "Poo")%>%
          group_by(MassFeature, MIS) %>%
          summarise(RSD_ofPoo =  sd(Adjusted_Area)/mean(Adjusted_Area))
        poodat <- poodat %>% left_join(poodat %>%
                                         group_by(MassFeature) %>%
                                         summarise(Poo.Picked.IS = unique(MIS)[which.min(RSD_ofPoo)][1]))

        newpoodat <- left_join(poodat, poodat %>%
                                 filter(MIS == "Inj_vol.Norm.Area" ) %>%
                                 mutate(Orig_RSD = RSD_ofPoo) %>%
                                 select(-RSD_ofPoo, -MIS)) %>%
          mutate(del_RSD = (Orig_RSD - RSD_ofPoo)) %>%
          mutate(percentChange = del_RSD/Orig_RSD) %>%
          mutate(accept_MIS = (percentChange > 0.4 & Orig_RSD > 0.1))


        NoAMIS_newpoodat_BMIS <- newpoodat %>%
          filter(MIS == Poo.Picked.IS) %>% #Pulling out just the pooplus is matches
          filter(accept_MIS == "FALSE") %>%
          mutate(FinalBMIS = "Inj_vol.Norm.Area")

        newpoodat_BMIS <- newpoodat %>%
          filter(MIS == Poo.Picked.IS) %>%
          filter(accept_MIS == "TRUE") %>%
          mutate(FinalBMIS = Poo.Picked.IS) %>%
          bind_rows(NoAMIS_newpoodat_BMIS)

        #Makes the full dataset from the fixed ones (where there is no AMIS)
        FullDat_fixed <- left_join(newpoodat, newpoodat_BMIS %>% select(MassFeature, FinalBMIS))
        FullDat_fixed <- FullDat_fixed %>% left_join(FullDat_fixed %>% filter(FinalBMIS == MIS) %>% mutate(FinalRSD = RSD_ofPoo) %>% select(MassFeature, FinalRSD))

        #Only get MFs with FinalRSD < 0.2
        Good_MFs <- FullDat_fixed %>%
          filter(MIS == Poo.Picked.IS) %>%
          filter(FinalRSD < 0.2)

        #Get number of mass features
        MassFeatures <- length(Good_MFs$MassFeature)

        BMIS_percent <- Good_MFs %>%
          filter(FinalBMIS != "Inj_vol.Norm.Area") %>%
          group_by(FinalBMIS) %>%
          summarise(MFs = n()) %>%
          mutate(PercentofBMIS = MFs/MassFeatures)

        BMIS_Summary2 <- Good_MFs %>%
          filter(FinalBMIS != "Inj_vol.Norm.Area")
        MassFeatures2 <- length(BMIS_Summary2$MassFeature)



        #This will give us the number of mass features that were picked as an AMIS for each IS
        AMIS_percent <- FullDat_fixed %>%
          filter(MassFeature %in% Good_MFs$MassFeature) %>%
          filter(accept_MIS == "TRUE") %>%
          group_by(FinalBMIS) %>%
          summarise(MFs = n()) %>%
          mutate(PercentofAMIS = MFs/MassFeatures)  #This gives us the % of the MF chosen by each IS

        Summary <- left_join(AMIS_percent %>% select(-MFs), BMIS_percent %>% select(-MFs)) %>%
          mutate(Originality_Index = PercentofBMIS/PercentofAMIS)

        Summarylong <- left_join(AMIS_percent %>% select(-MFs), BMIS_percent %>%
                                   select(-MFs))%>%
          gather(key = "type", value = "Percent", -FinalBMIS)


        BMIS_normalizedData <- FullDat_fixed %>%
          filter(MIS == FinalBMIS) %>%
          select(MassFeature, Orig_RSD, del_RSD, percentChange, FinalBMIS, FinalRSD) %>%
          right_join(longdat) %>%
          filter(MIS == FinalBMIS) %>%
          left_join(., dat %>% select(Run.Cmpd, runDate, type, SampID, replicate))

        adjusted_area_list =  sapply(unique(BMIS_normalizedData$MassFeature), function(x){
          BMIS_normalizedData[BMIS_normalizedData$MassFeature%in%x,"Adjusted_Area"]
        })
        adjusted_area = do.call(rbind,adjusted_area_list)

        adjusted_area = data.frame(adjusted_area)
        rownames(adjusted_area) = unique(BMIS_normalizedData$MassFeature)

        adjusted_area$index = rownames(adjusted_area)

        adjusted_area_rightorder = merge(f_,adjusted_area,sort = FALSE, by.x = "label", by.y = "index")
        adjusted_area_rightorder = adjusted_area_rightorder[-nrow(adjusted_area_rightorder),]
        adjusted_area_rightorder = adjusted_area_rightorder[,-c(1,2,3)]
        adjusted_area_rightorder = data.matrix(adjusted_area_rightorder)

        result = adjusted_area_rightorder
        e_norm = result
        qc_RSDs[['bmis']] = RSD(e_norm[,p$sampleType=='qc'])
        calculation_times[['bmis']] = Sys.time() - start
        cat(paste0("Average QC RSD:",signif(median(qc_RSDs[['bmis']],na.rm = TRUE),4)*100,"%.\n"))
        cat(paste0("Number of compounds less than 20% QC RSD:",sum(qc_RSDs[['bmis']]<0.2,na.rm = TRUE),".\n"))
        if(with_validate){
          val_RSDs[['bimis']] = RSD(e_norm[,p$sampleType=='validate'])
          cat(paste0("Average Validate Sample RSD:",signif(median(val_RSDs[['bmis']],na.rm = TRUE),4)*100,"%.\n"))
          cat(paste0("Number of compounds less than 20% Validate Sample RSD:",sum(val_RSDs[['bmis']]<0.2,na.rm = TRUE),".\n"))
        }
        e_norm[,sample_rank]
      }else{
        e_norm = NA
      }
    },error = function(error){
      error
    })
  }


  p=p[sample_rank,]
  if(grepl("\\\\",file_location)){
    comp = strsplit(file_location,"\\\\")[[1]]
  }else{
    comp = strsplit(file_location,"/")[[1]]
  }
  filename = gsub("\\.csv|\\.xlsx","",comp[length(comp)])
  root = paste0(paste0(comp[-length(comp)],collapse = "\\"),"\\")
  dir = paste0(root,filename," - normalization result")
  dir.create(dir)
  png(filename=paste0(dir,"\\","Bar Plot and PCA plot.png"), width = 2000, height = 1000 * ifelse(with_validate,3,2))
  qc_RSD_performance = sapply(qc_RSDs,median, na.rm = TRUE)
  qc_RSD_performance = sort(qc_RSD_performance,decreasing = TRUE)
  qc_RSD_performance_color = rep("grey",length(qc_RSD_performance))
  qc_RSD_performance_color[length(qc_RSD_performance_color)-1] = "red"
  qc_RSD_performance_color[length(qc_RSD_performance_color)] = "#ffbf00"
  qc_RSD_performance_color[names(qc_RSD_performance)=='none'] = 'black'
  if(with_validate){
    val_RSDs
    val_RSD_performance = sapply(val_RSDs,median, na.rm = TRUE)
    val_RSD_performance = sort(val_RSD_performance,decreasing = TRUE)
    val_RSD_performance_color = rep("grey",length(val_RSD_performance))
    val_RSD_performance_color[length(val_RSD_performance_color)-1] = "red"
    val_RSD_performance_color[length(val_RSD_performance_color)] = "#ffbf00"
    val_RSD_performance_color[names(val_RSD_performance)=='none'] = 'black'
    layout(matrix(c(1,1,2,2,3,4), 3, 2, byrow = TRUE))
  }else{
    layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))
  }
  par(lty = 0)
  par(mar=c(5,4,4,2)*3)
  bp = barplot(qc_RSD_performance*100, main="QC RSD", xlab="", ylab="RSD (%)",col = qc_RSD_performance_color,width = 1,las=2,cex.axis =5, cex.names=5,cex.main = 5)
  text(bp[which(names(qc_RSD_performance)=='none'),1], qc_RSD_performance['none']*100, paste0(signif(qc_RSD_performance['none'],4)*100,"%"), cex = 5, pos = 3)
  text(bp[nrow(bp),1], qc_RSD_performance[length(qc_RSD_performance)]*100, paste0(signif(qc_RSD_performance[length(qc_RSD_performance)],4)*100,"%"), cex = 5, pos = 3)

  if(with_validate){
    par(lty = 0)
    par(mar=c(5,4,4,2)*3)
    bp = barplot(val_RSD_performance*100, main="Validate Sample RSD", xlab="", ylab="RSD (%)",col = val_RSD_performance_color,width = 1,las=2,cex.axis =5, cex.names=5,cex.main = 5)
    text(bp[which(names(val_RSD_performance)=='none'),1], val_RSD_performance['none']*100, paste0(signif(val_RSD_performance['none'],4)*100,"%"), cex = 5, pos = 3)
    text(bp[nrow(bp),1], val_RSD_performance[length(val_RSD_performance)]*100, paste0(signif(val_RSD_performance[length(val_RSD_performance)],4)*100,"%"), cex = 5, pos = 3)
  }
  pca_color = factor(p$sampleType, levels = c('sample','qc','validate'))
  dots = c(1,16,16)[as.numeric(pca_color)]
  pca_before = prcomp(t(e),scale. = TRUE)
  par(mar=c(4,2,4,2)*3)
  plot(pca_before$x[,1],pca_before$x[,2], col = pca_color,main = 'Before',xlab='raw data',cex.lab=5,yaxt='n', cex.axis=5, cex.main=5, cex.sub=5,ylab="", xaxt='n',cex = 5,pch = dots)

  pca_after = prcomp(t(normalized_dataset[[names(qc_RSD_performance)[length(qc_RSD_performance)]]]),scale. = TRUE)
  plot(pca_after$x[,1],pca_after$x[,2], col = pca_color,main = 'After',xlab = names(qc_RSD_performance)[length(qc_RSD_performance)],cex.lab=5, cex.axis=5, cex.main=5, cex.sub=5,ylab="",yaxt='n', xaxt='n',cex = 5,pch = dots)
  #legend("topright", levels(pca_color),col=c("black","red","green"),pch=c(1,16,16),box.lwd=1,  box.col="black",box.lty=1,cex=5, inset=c(-0.2,0))
  dev.off()
  dir.create(paste0(dir,"\\normalized datasets"))
  for(i in 1:length(methods)){
    if(identical(class(normalized_dataset[[methods[i]]]),"matrix")){
      fwrite(data.table(label = f$label,normalized_dataset[[methods[i]]]),paste0(dir,"\\normalized datasets\\normalized by - ",methods[i],'.csv'))
    }
  }
  fwrite(data.table(label = f$label, do.call('cbind',qc_RSDs)),paste0(dir,"//","QC - RSD.csv"))
  if(with_validate){
    fwrite(data.table(label = f$label, do.call('cbind',val_RSDs)),paste0(dir,"//","Validate Samples - RSD.csv"))
  }
  if(scatter_plot){ # time consuming.
    cat("Generating scatter plots for each compounds. Please be patient...\n")
    dir.create(paste0(dir,"\\scatter plots"))
    for(i in 1:length(methods)){
      if(identical(class(normalized_dataset[[methods[i]]]),"matrix")){
        normalized = normalized_dataset[[methods[i]]]
        dir.create(paste0(dir,"\\scatter plots\\",methods[i]))
        for(j in 1:nrow(e)){
          png(paste0(dir,"\\scatter plots\\",methods[i],"\\",j,"th.png"), width = 480*2, height = 480)
          par(mfrow=c(1,2))
          ylim = c(min(e[j,],normalized[j,]), max(e[j,],normalized[j,]))
          if(Inf %in% ylim){
            ylim[2] = max(e[j,!is.infinite(e[j,])],normalized[j,!is.infinite(normalized[j,])])*1.1
          }
          if(sum(is.na(ylim))<1){
            plot(p$time,normalized_dataset[['none']][j,], col = factor(p$sampleType), ylim = ylim, main = f$label[j])
            plot(p$time,normalized[j,], col = factor(p$sampleType), ylim = ylim)
          }
          dev.off()
        }
      }}
  }

  cat(paste0("Good Job! All the normalizations are finished!\nPlease check your folder: '",dir,"'.\n"))
  return(list(normalized_dataset = normalized_dataset,qc_RSDs = qc_RSDs,calculation_times=calculation_times))
}



o = normalize(methods = "all",scatter_plot = T)
# methods can be either "all" a c() which can include mTIC,sum,median,PQN,contrast,quantile,linear,liwong,cubic,batch_ratio,batch_loess,SERRF,svm,nomis or bmis.
