library(testthat)

source("plot-input.R")

context("Plot input data generators")

test_that("while obtaining graph plot input data", {
  word_corrs <- rbind(
    data.frame(from="soros", to="terv", corr=0.99),
    data.frame(from="soros", to="ceu", corr=0.78),
    data.frame(from="soros", to="civil", corr=0.52),
    data.frame(from="orbán", to="viktor", corr=0.98),
    data.frame(from="orbán", to="fidesz", corr=0.6),
    data.frame(from="orbán", to="békemenet", corr=0.3),
    data.frame(from="gyurcsány", to="dk", corr=0.66)
  )
  
  test_that("comma-separated user input terms should be preprocessed", {
    allowed_terms <- c("soros","orbán","gyurcsány","migráns")
    
    expect_equal(
      prepare_input_terms("", allowed_terms),
      character(0),
    )
    
    expect_equal(
      prepare_input_terms("soros", allowed_terms),
      c("soros")
    )
    
    expect_equal(
      prepare_input_terms("Orbán, Gyurcsány, migráns", allowed_terms),
      c("orbán", "gyurcsány", "migráns")
    )
    
    expect_equal(
      prepare_input_terms("idontexist, I dont either", allowed_terms),
      character(0)
    )
  })
  
  test_that("correct output is obtained with terms we have correlation measures for", {
    expected_data = rbind(
      data.frame(term1="soros", term2="terv", correlation=0.99),
      data.frame(term1="soros", term2="ceu", correlation=0.78),
      data.frame(term1="orbán", term2="viktor", correlation=0.98)
    )
    
    input_data = generate_graph_plot_input(word_corrs, c("soros", "orbán"), 0.78)
    
    expect_equal(
      nrow(input_data),
      3
    )
    
    expect_equal(
      colnames(input_data),
      c("term1", "term2", "correlation")
    )
    
    for(i in 1:3){
      expect_equal(
        as.vector(input_data[,i]),
        as.vector(expected_data[,i])
      )
    }
  })
  
  test_that("placeholder output is obtained from terms that do not have associated terms above the required threshold", {
    expected_data = rbind(
      data.frame(term1="gyurcsány", term2="gyurcsány", correlation=1),
      data.frame(term1="orbán", term2="orbán", correlation=1)
    )
    
    input_data = generate_graph_plot_input(word_corrs, c("gyurcsány", "orbán"), 1)
    
    expect_equal(
      nrow(input_data),
      2
    )
    
    expect_equal(
      colnames(input_data),
      c("term1", "term2", "correlation")
    )
    
    for(i in 1:3){
      expect_equal(
        as.vector(input_data[,i]),
        as.vector(expected_data[,i])
      )
    }
  })
  
  test_that("empty output is obtained from empty user input terms", {
    expected_data = rbind(
      data.frame(term1="", term2="", correlation=1)
    )
    
    input_data = generate_graph_plot_input(word_corrs, character(0), 0.78)
    
    expect_equal(
      nrow(input_data),
      1
    )
    
    expect_equal(
      colnames(input_data),
      c("term1", "term2", "correlation")
    )
    
    for(i in 1:3){
      expect_equal(
        as.vector(input_data[,i]),
        as.vector(expected_data[,i])
      )
    }
  })
})