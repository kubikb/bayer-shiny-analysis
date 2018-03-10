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

# Replace + signs in text coming from Magyarlanc
bayer_data_df$full_content_lemma <- gsub("\\+","",bayer_data_df$full_content_lemma)

# Keep only relevant variables
bayer_data_df <- bayer_data_df[
  , 
  c("text_id", "full_content_lemma", "date", "title")
]

# Break into sentences
sentences_df <- bayer_data_df %>%
  unnest_tokens(
    sentence,
    full_content_lemma,
    to_lower = T,
    token = "sentences"
  )

sentences_df$sentence_id <- 1:nrow(sentences_df)

# Word tokenization
words_df <- sentences_df %>%
  unnest_tokens(
    word,
    sentence,
    to_lower = T
  ) %>% 
  filter(!str_detect(word, "[0-9]")) %>%
  filter(!word %in% get_stopwords("hu")$word)

# Bigram correlations
 word_corrs <- words_df %>%
  group_by(word) %>%
  filter(n() >= 20) %>%
  pairwise_cor(word, text_id) %>%
  filter(correlation > .1) %>%
  group_by(item1) %>%
  top_n(n = top_n_terms, wt = correlation)

# Write term correlations to file
write.table(word_corrs, "data/word_corrs.tsv", sep = "\t", fileEncoding = "UTF-8")

# Filter words_df for terms in word_corrs
unique_terms <- unique(c(word_corrs$item1, word_corrs$item2))
words_df <- words_df[words_df$word %in% unique_terms,]

# Fix dates in words_df
words_df$date <- gsub("\\.","\\-",words_df$date)
words_df$date <- substr(words_df$date,1,nchar(words_df$date)-1)

# Save to file
write.table(words_df, "data/words.tsv", sep = "\t", fileEncoding = "UTF-8")
