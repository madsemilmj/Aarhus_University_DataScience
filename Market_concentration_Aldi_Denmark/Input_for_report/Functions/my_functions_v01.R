
### GET ADDRESSES
get_adr_info <- function(res){
  results <- tibble(
    name = res$results$name,
    address = res$results$formatted_address,
    lat    = res$results$geometry$location$lat,
    lng    = res$results$geometry$location$lng
  )
  return(results)
}


########----------------------------------------------------------------#######


###MAKE CIRCLES

make_circles <- function(centers, radius, nPoints = 1000){
  # centers: the data frame of centers with ID
  # radius: radius measured in kilometer
  #
  meanLat <- mean(centers$lat)
  # length per longitude changes with lattitude, so need correction
  radiusLon <- radius /111 / cos(meanLat/57.3) 
  radiusLat <- radius / 111
  circleDF <- data.frame(ID = rep(centers$address, each = nPoints))
  angle <- seq(0,2*pi,length.out = nPoints)
  
  circleDF$lon <- unlist(lapply(centers$lng, function(x) x + radiusLon * cos(angle)))
  circleDF$lat <- unlist(lapply(centers$lat, function(x) x + radiusLat * sin(angle)))
  return(circleDF)
}
