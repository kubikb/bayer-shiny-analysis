library(shiny)
library(networkD3)

setwd(getwd())

default_terms <- c("Soros","CEU","kormány")

# Read prepared data
word_corrs <- read.delim("data/word_corrs.tsv", sep = "\t", encoding = "UTF-8")
unique_terms <- unique(word_corrs$item1)

# Server Logic
server <- function(input, output) {
  graph_input = reactive({
    
    input_terms <- strsplit(input$terms_input, ',')[[1]]
    input_terms <- trimws(tolower(input_terms))
    valid_terms <- intersect(unique_terms, input_terms)
    
    if (length(valid_terms) == 0) {
      valid_terms <- c("")
    }
    
    terms_df <- word_corrs[
      (word_corrs$item1 %in% valid_terms) & (word_corrs$correlation >= input$min_corr),
      ]
    
    if(nrow(terms_df) == 0){
      terms_df <- data.frame()
      for(term in valid_terms){
        terms_df <- rbind(
          terms_df,
          data.frame(s=term, t=term, v=1)
        )
      }
    }
    
    return(terms_df)
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
        "img {max-height: 200px;}"
      )
    ),
    
    fluidRow(
      # column(
      #   width = 2,
      #   align="center",
      #   img(
      #     src="http://www.sztarklikk.hu/images/articleMain/33421.jpg",
      #     align="center",
      #     class="img-responsive"
      #     )
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
          "After scraping all blog posts from the time period from May 20th, 2015 (start of the blog) to March 9th, 2018 (scraper script",
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
          a(href="https://shiny.rstudio.com/", "Shiny for R.", target="_blank")
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