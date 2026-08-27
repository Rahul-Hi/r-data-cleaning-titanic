## =========================================================
## Script 3 of 3: Exploratory Data Analysis & Visualization
## =========================================================
library(dplyr)
library(ggplot2)
library(corrplot)
library(reshape2)

df <- readRDS("titanic_cleaned.rds")
dir.create("plots", showWarnings = FALSE)

## ---------------------------------------------------------
## Descriptive statistics
## ---------------------------------------------------------
cat("========== summary() ON CLEANED NUMERIC VARIABLES ==========\n")
print(summary(df[, c("Age", "Fare_Capped", "SibSp", "Parch")]))

cat("\n========== SURVIVAL RATE OVERALL ==========\n")
print(round(prop.table(table(df$Survived)) * 100, 1))

cat("\n========== SURVIVAL RATE BY SEX ==========\n")
print(round(prop.table(table(df$Sex, df$Survived), margin = 1) * 100, 1))

cat("\n========== SURVIVAL RATE BY PASSENGER CLASS ==========\n")
print(round(prop.table(table(df$Pclass, df$Survived), margin = 1) * 100, 1))

cat("\n========== SURVIVAL RATE BY TITLE ==========\n")
print(round(prop.table(table(df$Title, df$Survived), margin = 1) * 100, 1))

cat("\n========== FARE / AGE SUMMARY BY CLASS ==========\n")
print(df %>% group_by(Pclass) %>%
        summarise(mean_fare = mean(Fare_Capped), mean_age = mean(Age),
                  n = n(), .groups = "drop"))

## ---------------------------------------------------------
## Correlation analysis (numeric variables)
## ---------------------------------------------------------
num_vars <- df %>% select(Survived, Pclass, Age, SibSp, Parch, Fare_Capped, HasCabinRecord)
corr_mat <- cor(num_vars, use = "complete.obs")

cat("\n========== CORRELATION MATRIX (numeric variables) ==========\n")
print(round(corr_mat, 2))

png("plots/01_correlation_heatmap.png", width = 900, height = 800, res = 120)
corrplot(corr_mat, method = "color", type = "upper", addCoef.col = "black",
         tl.col = "black", tl.srt = 45, number.cex = 0.8,
         title = "Correlation Matrix - Titanic Numeric Variables",
         mar = c(0, 0, 2, 0))
dev.off()

## ---------------------------------------------------------
## Visualization 1: Age distribution before vs after imputation context
## ---------------------------------------------------------
p1 <- ggplot(df, aes(x = Age)) +
  geom_histogram(binwidth = 5, fill = "#2c7fb8", color = "white") +
  labs(title = "Distribution of Passenger Age (post-imputation)",
       x = "Age (years)", y = "Count of Passengers") +
  theme_minimal(base_size = 13)
ggsave("plots/02_age_distribution.png", p1, width = 7, height = 5, dpi = 130)

## ---------------------------------------------------------
## Visualization 2: Survival counts by Sex
## ---------------------------------------------------------
p2 <- ggplot(df, aes(x = Sex, fill = factor(Survived))) +
  geom_bar(position = "dodge") +
  scale_fill_manual(values = c("0" = "#d95f02", "1" = "#1b9e77"),
                     labels = c("Did not survive", "Survived"), name = "Outcome") +
  labs(title = "Survival Counts by Sex", x = "Sex", y = "Number of Passengers") +
  theme_minimal(base_size = 13)
ggsave("plots/03_survival_by_sex.png", p2, width = 7, height = 5, dpi = 130)

## ---------------------------------------------------------
## Visualization 3: Fare distribution by Passenger Class (outlier view)
## ---------------------------------------------------------
p3 <- ggplot(df, aes(x = factor(Pclass), y = Fare_Capped, fill = factor(Pclass))) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Fare (99th-pct capped) by Passenger Class",
       x = "Passenger Class", y = "Fare") +
  theme_minimal(base_size = 13)
ggsave("plots/04_fare_by_class_boxplot.png", p3, width = 7, height = 5, dpi = 130)

## ---------------------------------------------------------
## Visualization 4: Survival rate by Class and Sex (grouped bar, %)
## ---------------------------------------------------------
surv_summary <- df %>%
  group_by(Pclass, Sex) %>%
  summarise(survival_rate = mean(Survived) * 100, .groups = "drop")

p4 <- ggplot(surv_summary, aes(x = factor(Pclass), y = survival_rate, fill = Sex)) +
  geom_col(position = "dodge") +
  labs(title = "Survival Rate (%) by Passenger Class and Sex",
       x = "Passenger Class", y = "Survival Rate (%)") +
  theme_minimal(base_size = 13)
ggsave("plots/05_survival_rate_class_sex.png", p4, width = 7, height = 5, dpi = 130)

## ---------------------------------------------------------
## Visualization 5: Outlier detection view for Fare (raw, pre-cap)
## ---------------------------------------------------------
p5 <- ggplot(df, aes(x = "", y = Fare)) +
  geom_boxplot(fill = "#7570b3", outlier.color = "red", outlier.alpha = 0.6) +
  labs(title = "Raw Fare Distribution with Outliers Flagged (before capping)",
       x = "", y = "Fare") +
  theme_minimal(base_size = 13)
ggsave("plots/06_fare_outliers_raw.png", p5, width = 5, height = 5, dpi = 130)

cat("\nAll plots saved to plots/ directory.\n")
cat(list.files("plots"), sep = "\n")
