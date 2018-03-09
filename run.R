library(shiny)

port <- Sys.getenv('PORT')
if(port == ""){
  port = 8080
}

shiny::runApp(
  appDir = getwd(),
  host = '0.0.0.0',
  port = as.numeric(port)
)