# Later install steps will fail without installing Rcpp >= 0.12.12
install.packages("devtools")

library(devtools)
install_version("Rcpp", version = "0.12.12", repos = "http://cran.us.r-project.org")

my_packages <- c(
    "shiny",
    "dplyr",
    "tidytext",
    "widyr",
    "stringr",
    "networkD3"
  )

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))