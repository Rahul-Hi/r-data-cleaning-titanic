# R Data Cleaning and Preliminary Analysis – Titanic Dataset

## Project Overview

This project was completed as part of **Week 1: Data Cleaning and Preliminary Analysis with R**. The objective is to demonstrate a complete introductory data-analysis workflow using R, starting with raw data inspection and continuing through data cleaning, transformation, exploratory analysis, and initial insight generation.

The project uses the publicly available **Titanic passenger dataset**, which contains information about passengers and whether they survived the Titanic disaster.

## Objectives

* Inspect and understand the structure of a real-world dataset
* Identify and handle missing values
* Check for duplicate and inconsistent records
* Detect potential outliers using the IQR method
* Transform and standardize numerical variables
* Encode categorical variables appropriately
* Generate descriptive statistics
* Perform correlation analysis
* Create visualizations for exploratory analysis
* Document initial findings and limitations

## Dataset

The standard Titanic training dataset contains:

* **891 passenger records**
* **12 original variables**
* Numerical, categorical, and text-based fields
* Missing values in variables such as `Age`, `Cabin`, and `Embarked`

### Important Variables

| Variable   | Description                        |
| ---------- | ---------------------------------- |
| `Survived` | Survival outcome (0 = No, 1 = Yes) |
| `Pclass`   | Passenger class                    |
| `Sex`      | Passenger sex                      |
| `Age`      | Passenger age                      |
| `SibSp`    | Number of siblings/spouses aboard  |
| `Parch`    | Number of parents/children aboard  |
| `Fare`     | Passenger fare                     |
| `Cabin`    | Cabin information                  |
| `Embarked` | Port of embarkation                |

## Project Structure

```text
├── 01_load_inspect.R
├── 02_clean_transform.R
├── 03_eda_analysis.R
├── titanic_cleaned.csv
└── Titanic_Data_Cleaning_Report.docx
```

## Analysis Workflow

### 1. Data Loading and Inspection

The raw dataset is imported into R and inspected using functions including:

```r
head()
str()
summary()
dim()
colSums(is.na())
```

These functions are used to understand the dataset structure, variable types, dimensions, descriptive statistics, and missing values.

### 2. Missing-Value Handling

Different strategies were applied according to the characteristics of each variable:

* `Age`: missing values replaced using the median
* `Embarked`: missing values replaced using the mode
* `Cabin`: converted into a `CabinKnown` indicator because of its high level of missingness

The goal was to preserve useful information without unnecessarily deleting passenger records.

### 3. Outlier Detection

Potential numerical outliers were identified using the **Interquartile Range (IQR)** method and examined using boxplots.

Outliers were not automatically removed because an extreme observation is not necessarily an error. For example, a high passenger fare may represent a legitimate historical observation.

### 4. Data Transformation

Categorical variables were converted into R factors. Numerical variables such as `Age` and `Fare` were standardized using z-score normalization where appropriate.

Categorical indicator variables were generated using `model.matrix()` when a numerical representation was required.

### 5. Exploratory Data Analysis

The preliminary analysis includes:

* Survival distribution
* Survival rate by sex
* Survival rate by passenger class
* Descriptive statistics
* Numerical correlation analysis
* Distribution and outlier visualization

## Initial Findings

The exploratory analysis produced several notable observations:

* The overall survival rate in the training dataset is approximately **38.4%**.
* Female passengers had a substantially higher observed survival rate than male passengers.
* First-class passengers had a higher observed survival rate than second- and third-class passengers.
* `Fare` has a strongly right-skewed distribution and contains high-value observations that require outlier inspection.
* `Cabin` has substantial missingness, making direct use of the raw variable problematic without transformation.

These findings represent **descriptive associations**, not causal conclusions.

## Tools and Technologies

* **R**
* **RStudio**
* **tidyverse**
* Base R statistical functions
* Data visualization with `ggplot2`
* Git and GitHub

## Reproducibility

To reproduce the analysis:

1. Install R and RStudio.
2. Place the Titanic `train.csv` dataset in the project directory.
3. Install the required package:

```r
install.packages("tidyverse")
```

4. Run the scripts in the following order:

```text
01_load_inspect.R
02_clean_transform.R
03_eda_analysis.R
```

5. The cleaned dataset is exported as:

```text
titanic_cleaned.csv
```

## Limitations

This project is a preliminary exploratory analysis. It does not attempt to establish causal relationships or produce a final predictive model.

Median and mode imputation are simple approaches suitable for this introductory project. More advanced analyses could use multiple imputation, statistical hypothesis testing, feature engineering, and predictive modeling.

## Project Outcome

This project demonstrates a structured R-based workflow for preparing real-world data for analysis. It covers the key stages required for the Week 1 internship task: **data inspection, cleaning, missing-value treatment, outlier detection, transformation, categorical encoding, normalization, exploratory analysis, visualization, and documentation**.

## Author

**Rahul**

This repository was created as part of a technical data-analysis internship project.
