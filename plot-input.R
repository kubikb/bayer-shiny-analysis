prepare_input_terms <- function(input_terms_str, allowed_terms){
  # Split by comma
  input_terms <- strsplit(input_terms_str, ',')[[1]]
  
  # Trim and lowercase
  input_terms <- trimws(tolower(input_terms))
  
  # Filter for allowed terms
  valid_terms <- intersect(allowed_terms, input_terms)
  
  return(valid_terms)
}

generate_graph_plot_input <- function(word_corrs, filter_terms, min_corr) {
  if(length(filter_terms) == 0){
    filter_terms <- c("")
  }
  
  # Filter for valid terms and filter based on correlation
  terms_df <- word_corrs[
    (word_corrs[,1] %in% filter_terms) & (word_corrs[,3] >= min_corr),
    ]
  
  # Handle cases where filter leads to empty df
  if(nrow(terms_df) == 0){
    terms_df <- data.frame()
    for(term in filter_terms){
      terms_df <- rbind(
        terms_df,
        data.frame(term1=term, term2=term, correlation=1)
      )
    }
  }
  
  colnames(terms_df) <- c("term1", "term2", "correlation")
  
  return(terms_df)
}