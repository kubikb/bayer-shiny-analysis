library(shiny)
library(networkD3)

setwd(getwd())

source("plot-input.R")

default_terms <- c("kormány","Orbán","Soros")
min_date <- "2015-05-20"
max_date <- "2018-03-09"

# Read prepared data
word_corrs <- read.delim("data/word_corrs.tsv", sep = "\t", encoding = "UTF-8", stringsAsFactors = F)
unique_terms <- unique(c(word_corrs$item1, word_corrs$item2))

# Server Logic
server <- function(input, output) {
  graph_input = reactive({
    valid_terms <- prepare_input_terms(input$terms_input, unique_terms)
    
    return(
      generate_graph_plot_input(
        word_corrs,
        valid_terms,
        input$min_corr
      )
    )
  });
  
  output$force <- renderForceNetwork({ 
    simpleNetwork(
      graph_input(),
      zoom = T
    )
  })
}

# UI
ui <- shinyUI(
  fluidPage(
    title = "Analysis of Zsolt Bayer's blog",
    
    tags$head(
      includeHTML("google-analytics.html"),
      tags$style(
        type="text/css",
        "img {max-height: 150px; display:inline-block;}"
      )
    ),
    
    fluidRow(
      # column(
      #   width = 2,
      #   align="center",
      #   div(
      #     class="thumbnail",
      #     img(
      #       src="http://www.sztarklikk.hu/images/articleMain/33421.jpg",
      #       align="center",
      #       class="img-responsive"
      #     )
      #   )
      # ),
      
      column(
        width = 10,
        offset = 1,
        h1("Word Association Network of Blog Post from Zsolt Bayer"),
        p(
          "This website visualizes the word association network obtained from blog posts by",
          a(href="https://badog.blogstar.hu/", "Zsolt Bayer.", target="_blank"),
          "Mr. Bayer is a publicist from Hungary known in the political life as an ardent supporter of Viktor Orbán, prime minister of Hungary (1998-2002, 2010-), and the party Fidesz."
        ),
        p(
          "After scraping all blog posts from the time period from", 
          min_date,
          "to",
          max_date,
          "(scraper script",
          a(href="https://github.com/kubikb/bayer_blog_parser", "HERE", target="_blank"),
          "), data was cleaned, lemmatized using the awesome",
          a(href="http://www.inf.u-szeged.hu/rgai/magyarlanc", "Magyarlánc tool", target="_blank"),
          "and analyzed with the help of",
          a(href="https://github.com/juliasilge/tidytext", "tidytext for R.", target="_blank")
        ),
        p(
          "It was created by",
          a(href="https://www.linkedin.com/in/balintkubik/", "Bálint Kubik", target="_blank"),
          "to play with network visualization in",
          a(href="https://shiny.rstudio.com/", "Shiny for R.", target="_blank"),
          "Github repository with the source can be found",
          a(href="https://github.com/kubikb/bayer-shiny-analysis", "HERE.", target="_blank")
        )
      )
    ),
    
    
    fluidRow(
      column(6,
             align="center",
             textInput("terms_input", h3("Terms to analyze (comma-separated)"), 
                       placeholder = paste("For example:", paste(default_terms, collapse = ", ")),
                       value = paste(default_terms, collapse = ", "))
      ),
      column(6,
             align="center",
             sliderInput("min_corr", h3("Minimum correlation between terms"),
                         min = 0.1, max = 1.0, value = 0.15)
      )
    ),
    
    fluidRow(
      forceNetworkOutput("force")
    )
  )
)

# Run the app ----
shinyApp(ui = ui, server = server)