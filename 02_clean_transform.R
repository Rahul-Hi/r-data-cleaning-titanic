## =========================================================
## Script 2 of 3: Data Cleaning, Missing Values, Outliers,
##                 Normalization, Encoding
## =========================================================
library(dplyr)

df <- readRDS("titanic_raw.rds")

## ---------------------------------------------------------
## STEP A: Standardize missing-value representation
## ---------------------------------------------------------
# Cabin and Embarked use "" for missing rather than NA -> convert to NA first
df$Cabin[df$Cabin == ""]       <- NA
df$Embarked[df$Embarked == ""] <- NA

cat("========== MISSING VALUES AFTER STANDARDIZING BLANKS ==========\n")
print(colSums(is.na(df)))

## ---------------------------------------------------------
## STEP B: Handle missing values
## ---------------------------------------------------------
# Age (177 missing, ~19.9%): impute using median Age within each
# Pclass x Sex group (more accurate than a single global median,
# since Age clearly differs by passenger class and sex).
cat("\n========== MEDIAN AGE BY Pclass x Sex (imputation table) ==========\n")
age_lookup <- df %>%
  group_by(Pclass, Sex) %>%
  summarise(median_age = median(Age, na.rm = TRUE), .groups = "drop")
print(age_lookup)

df <- df %>%
  left_join(age_lookup, by = c("Pclass", "Sex")) %>%
  mutate(Age = ifelse(is.na(Age), median_age, Age)) %>%
  select(-median_age)

# Embarked (2 missing): impute with the mode (most frequent port)
embarked_mode <- names(sort(table(df$Embarked), decreasing = TRUE))[1]
cat("\nMode of Embarked used for imputation:", embarked_mode, "\n")
df$Embarked[is.na(df$Embarked)] <- embarked_mode

# Cabin (687 missing, ~77%): too sparse to impute meaningfully.
# Convert to an informative binary flag instead of dropping the signal entirely,
# then drop the free-text Cabin column itself.
df$HasCabinRecord <- ifelse(is.na(df$Cabin), 0, 1)
df$Cabin <- NULL

cat("\n========== MISSING VALUES AFTER CLEANING ==========\n")
print(colSums(is.na(df)))

## ---------------------------------------------------------
## STEP C: Outlier detection (IQR method) on numeric variables
## ---------------------------------------------------------
detect_outliers <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  sum(x < lower | x > upper, na.rm = TRUE)
}

cat("\n========== OUTLIER COUNTS (1.5 x IQR RULE) ==========\n")
cat("Fare outliers :", detect_outliers(df$Fare), "out of", nrow(df), "rows\n")
cat("Age outliers  :", detect_outliers(df$Age), "out of", nrow(df), "rows\n")
cat("SibSp outliers:", detect_outliers(df$SibSp), "out of", nrow(df), "rows\n")
cat("Parch outliers:", detect_outliers(df$Parch), "out of", nrow(df), "rows\n")

# Fare is heavily right-skewed (max 512.33 vs median 14.45) and drives most
# outliers. Rather than deleting these rows (they are legitimate first-class
# fares, not data errors), we cap ("winsorize") Fare at the 99th percentile
# to reduce the influence of extreme values while preserving all records.
fare_cap <- quantile(df$Fare, 0.99, na.rm = TRUE)
cat("\n99th percentile Fare cap used for winsorizing:", round(fare_cap, 2), "\n")
df$Fare_Capped <- ifelse(df$Fare > fare_cap, fare_cap, df$Fare)

## ---------------------------------------------------------
## STEP D: Normalization / feature scaling
## ---------------------------------------------------------
# Z-score standardization (mean 0, sd 1) for Age and the capped Fare,
# creating new columns so the original, interpretable values are kept.
df$Age_z  <- as.numeric(scale(df$Age))
df$Fare_z <- as.numeric(scale(df$Fare_Capped))

# Min-max scaling (0-1) as an alternative, shown for comparison
minmax <- function(x) (x - min(x)) / (max(x) - min(x))
df$Age_minmax  <- minmax(df$Age)
df$Fare_minmax <- minmax(df$Fare_Capped)

cat("\n========== NORMALIZED COLUMNS (first 6 rows) ==========\n")
print(head(df[, c("Age", "Age_z", "Age_minmax", "Fare", "Fare_Capped", "Fare_z", "Fare_minmax")]))

## ---------------------------------------------------------
## STEP E: Encoding categorical variables
## ---------------------------------------------------------
# 1) Factor encoding (ordered where meaningful) for use directly in R models
df$Pclass_f   <- factor(df$Pclass, levels = c(3, 2, 1), ordered = TRUE) # 1st > 2nd > 3rd
df$Sex_f      <- factor(df$Sex)
df$Embarked_f <- factor(df$Embarked)

# 2) Label encoding: integer codes
df$Sex_label      <- as.integer(df$Sex_f)
df$Embarked_label <- as.integer(df$Embarked_f)

# 3) One-hot encoding for nominal variables (Sex, Embarked) via model.matrix
onehot_sex      <- model.matrix(~ Sex_f - 1, data = df)
onehot_embarked <- model.matrix(~ Embarked_f - 1, data = df)
colnames(onehot_sex)      <- gsub("Sex_f", "Sex_", colnames(onehot_sex))
colnames(onehot_embarked) <- gsub("Embarked_f", "Embarked_", colnames(onehot_embarked))

df <- cbind(df, onehot_sex, onehot_embarked)

cat("\n========== ONE-HOT ENCODED COLUMNS (first 6 rows) ==========\n")
print(head(df[, c("Sex", colnames(onehot_sex), "Embarked", colnames(onehot_embarked))]))

# 4) Extract Title from Name as a derived categorical feature (feature engineering)
df$Title <- sub(".*, (.*?)\\..*", "\\1", df$Name)
rare_titles <- names(table(df$Title))[table(df$Title) < 10]
df$Title[df$Title %in% rare_titles] <- "Other"
df$Title <- factor(df$Title)

cat("\n========== ENGINEERED TITLE FEATURE (from Name) ==========\n")
print(table(df$Title))

## ---------------------------------------------------------
## STEP F: Final structure and export
## ---------------------------------------------------------
cat("\n========== FINAL CLEANED STRUCTURE ==========\n")
str(df)

cat("\n========== FINAL DIMENSIONS ==========\n")
print(dim(df))

write.csv(df, "titanic_cleaned.csv", row.names = FALSE)
saveRDS(df, "titanic_cleaned.rds")
cat("\nSaved cleaned dataset to titanic_cleaned.csv / titanic_cleaned.rds\n")
