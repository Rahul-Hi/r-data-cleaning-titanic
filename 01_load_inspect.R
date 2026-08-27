## =========================================================
## Week 1 Task: Data Cleaning and Preliminary Analysis in R
## Dataset: Titanic Passenger Data (Kaggle "Titanic - Machine
##          Learning from Disaster" training set, 891 rows, 12 cols)
## Script 1 of 3: Load data and initial inspection
## =========================================================

df <- read.csv("titanic.csv", stringsAsFactors = FALSE)

cat("========== DIMENSIONS ==========\n")
print(dim(df))

cat("\n========== STRUCTURE (str) ==========\n")
str(df)

cat("\n========== FIRST 6 ROWS ==========\n")
print(head(df))

cat("\n========== SUMMARY (raw, before cleaning) ==========\n")
print(summary(df))

cat("\n========== MISSING VALUES PER COLUMN ==========\n")
na_counts <- colSums(is.na(df))
print(na_counts)

cat("\n========== EMPTY STRING COUNTS (categorical blanks) ==========\n")
empty_counts <- sapply(df, function(col) if (is.character(col)) sum(col == "", na.rm = TRUE) else NA)
print(empty_counts)

cat("\n========== DUPLICATE ROWS ==========\n")
cat("Number of exact duplicate rows:", sum(duplicated(df)), "\n")
cat("Number of duplicate PassengerId:", sum(duplicated(df$PassengerId)), "\n")

saveRDS(df, "titanic_raw.rds")
cat("\nSaved raw data to titanic_raw.rds\n")
