library(plumber)
pr <- plumber::plumb("plumber.R")
pr$run(port=3737, host="0.0.0.0")
