library(dplyr)
library(tidytext)
library(stringr)
library(widyr)

data_url = "https://raw.githubusercontent.com/kubikb/bayer_blog_parser/master/data/posts_lemmatized.tsv"

top_n_terms <- 50

# Read data
bayer_data_df <- read.delim(
  url(data_url),
  encoding = "UTF-8",
  stringsAsFactors = F
)

# Keep only relevant variables
bayer_data_df <- bayer_data_df[, c("text_id", "full_content_lemma")]

# Break into sentences
sentences_df <- bayer_data_df %>%
  unnest_tokens(
    word,
    full_content_lemma,
    to_lower = T,
    token = "sentences"
  )

sentences_df$text_id <- 1:nrow(sentences_df)
colnames(sentences_df) <- c("text_id", "text")


# Get tokens
word_corrs <- sentences_df %>%
  unnest_tokens(
    word,
    text,
    to_lower = T
 ) %>% 
  filter(!str_detect(word, "[0-9]")) %>%
  filter(!word %in% get_stopwords("hu")$word) %>%
  group_by(word) %>%
  filter(n() >= 20) %>%
  pairwise_cor(word, text_id) %>%
  filter(correlation > .1) %>%
  group_by(item1) %>%
  top_n(n = top_n_terms, wt = correlation)

write.table(word_corrs, "data/word_corrs.tsv", sep = "\t", fileEncoding = "UTF-8")