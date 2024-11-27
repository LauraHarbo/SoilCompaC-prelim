## Modified version of Hanna Meyer's CAST::aoa function
# https://github.com/HannaMeyer/CAST/blob/master/R/aoa.R
# Meyer, H. and Pebesma, E. (2021), Predicting into unknown space? 
# Estimating the area of applicability of spatial prediction models. 
# Methods in Ecology and Evolution. https://doi.org/10.1111/2041-210X.13650

aoa1 <- function(newdata = NULL,
               train = NULL,
               weight = NULL,
               variables = NULL,
               threshold = 0.95,
               cluster_train = NULL)
{
  if (is.null(newdata) | is.null(train) | is.null(variables)) {
    out <- NA
  }

  ## 1. Standardize
  train_scaled <- scale(train[, variables])
  train_scaled[is.na(train_scaled)] <- 0
  
  scaleparam <- attributes(train_scaled)
  newdata_scaled <- scale(newdata[, variables], 
                   center <- scaleparam$`scaled:center`,
                   scale <- scaleparam$`scaled:scale`)
  newdata_scaled[is.na(newdata_scaled) | newdata_scaled == Inf] <- 0
  
  ## 2. Weight
  for (i in 1:nrow(weight)) {
    var <- weight$name[i]
    value <- weight$value[i]
    train_scaled[, var] <- train_scaled[, var] * value
    newdata_scaled[, var] <- newdata_scaled[, var] * value
  }
  
  train_scaled[is.na(train_scaled)] <- 0
  newdata_scaled[is.nan(newdata_scaled)] <- 0
  
  ## 3. Distance
  # ... in parallel
  if (getDoParWorkers() == 1) {
    if (.Platform$OS.type == "unix") {
      library(doMC)
      try(registerDoMC(cores))
    } else {
      library(doParallel)
      cl <- try(makePSOCKcluster(cores))
      try(registerDoParallel(cl))
    }
    mindist <- foreach(z = 1:nrow(newdata_scaled),
                      .combine = "rbind",
                      .packages = c("FNN")) %dopar% {
                        tmp <- knnx.dist(t(matrix(newdata_scaled[z, ])), 
                                      train_scaled, k = 1)
                        return(min(tmp))
                      }
    try(registerDoSEQ(), silent = T)
    try(stopCluster(cl), silent = T)
    
    mindist <- unlist(mindist, use.names = F)
    
    } else {
      
      mindist <- data.frame()
      for (z in 1:nrow(newdata_scaled)) {
        tmp <- FNN::knnx.dist(t(matrix(newdata_scaled[z, ])), train_scaled, k = 1)
        mindist <- rbind(mindist, min(tmp))
      }
  }
  print("mindist done")
  
  train_dist <- as.matrix(dist(train_scaled))
  diag(train_dist) <- NA
  print("train_dist done")

  # Account for clusters (only really relevant for target oriented CV)
  if (!is.null(cluster_train)) {
    for (i in 1:nrow(train_dist)) {
      train_dist[i, cluster_train == cluster_train[i]] <- NA
    }
  }

  ## Dissimilarity index (di)
  train_dist_mean <- apply(train_dist, 1, FUN = function(x) {
    mean(x, na.rm = T)
  })
  train_dist_avrgmean <- mean(train_dist_mean)
  di <- mindist / train_dist_avrgmean
  
  ## Area of applicability (AOA)
  train_dist_min <- apply(train_dist, 1, FUN = function(x) {
    min(x, na.rm = T)
  })
  thres <- quantile(train_dist_min / train_dist_avrgmean,
                    probs = threshold, 
                    na.rm = TRUE)
 AOA <- rep(1, length(di))
  AOA[di > thres] <- 0
  
  out <- tibble(di = as.numeric(unlist(di)),
             AOA = AOA)
  return(out)
  }