
# Initial settings --------------------------------------------------------

library(data.table)
library(readxl)
library(fuzzyjoin) # we need to perform some joins by regular expression

# Functions used throughout the code
source("functions.R")

# Load web-scraper output
jobs = fread("../jobs.txt", sep = "|", encoding = "UTF-8", drop = 1)

# Load and standardize location field into a standard region name:
# Greater Barcelona Metropolitan Area becomes "Barcelona"
# Province of Madrid becomes "Madrid"
# This facilitates comparisons and analytics


# Location standardarization -------------------------------------------------

towns = standardizeLocations(loadLocations("locations.xls"))

# for now, 'country' is a constant:
towns[, country := "Spain"]

# replace non ASCII characters from location to facilitate regex matching
jobs[, location := iconv(location,from="UTF-8",to="ASCII//TRANSLIT")]

# regex join: assign standarized region name from location name
jobs = setDT(regex_left_join(x = jobs, y = towns, by = c(location = "regex"), ignore_case = T))[, -c("len", "regex", "CPRO")]

# keep only the first matching regex
jobs = jobs[!duplicated(id)]

# drop missing unknown locations, printing a warning if there are any
jobs = dropMissing(jobs, "region", warning_col = "location")

# Job title standardrization ------------------------------------------------

# Loads a mapping with keywords and their associated role
# i.e.
# ML <-> Machine learning specialist
# analyst <-> Data analyst

roles = setDT(read_excel("roles.xls"))

# Match longest expressions first
roles[, len := nchar(regex)]
setorder(roles, -len)

# remove non ASCII for better regex matching
jobs$title = iconv(jobs$title,from="UTF-8",to="ASCII//TRANSLIT")

# regex join, each job title gets a standard role assigned
jobs = setDT(regex_left_join(x = jobs, y = roles, by = c(title = "regex"), ignore_case = T))[, -c("len", "regex")]

# keep the first match only
jobs = jobs[!duplicated(id)]

# remove non matching titles
jobs = dropMissing(jobs, "role", warning_col = "title")


# Skill requirement standardarization -------------------------------------

# loads a list of skills
skills = fread("skills.txt", sep = "\t", na.strings = "")

# remove non ASCII for better regex matching
jobs$text = iconv(jobs$text,from="UTF-8",to="ASCII//TRANSLIT")

# generate a regex for each skill
# some skills have multiple names in column aka
# these are concatenated with | (alternatives in the regex)
skills[, regex := paste0("(-|^)",
                         ifelse(!is.na(aka), "(", ""),
                         gsub("+", "\\+", ifelse(!is.na(aka), paste(skill, aka, sep = "|"), skill), fixed = T),
                         ifelse(!is.na(aka), ")", ""), "(-|$)")]

# prepare text for regex join, by:????????
# 1. removing HTML tags
# 2. replacing spaces by hyphens
# 3. removing any non alphabetic characters but & and -
jobs[, text := standardizeText(text)]

jobs = setDT(regex_left_join(jobs, skills, by = c(text = "regex"), ignore_case = T))[, -c("regex", "aka")]

# keep only skills that appear in N >= threshold ads
jobs[, skillCount := .N, by = skill]
threshold = 10
jobs = jobs[skillCount >= threshold][, -c("skillCount")]

# Industry standardarization ----------------------------------------------

# list of all unique industries in the ads
uniqueIndustries = unique(strsplit(paste(jobs$industry, collapse = ", "), ", ")[[1]])
uniqueIndustries = as.data.table(uniqueIndustries[!grepl("\\n", uniqueIndustries)])
setnames(uniqueIndustries, "V1", "ind")

# merge jobs and industries
# i.e.
# IT Services, Chemicals matches "IT Services" and "Chemicals"
jobs = setDT(regex_left_join(jobs, uniqueIndustries, by = c(industry = "ind"), ignore_case = T))[, -c("industry")]
setnames(jobs, "ind", "industry")


# Output ------------------------------------------------------------------

saveRDS(jobs, file = "../jobs_clean.RDS")
fwrite(jobs, file = "../jobs_clean.tsv", sep = "\t")
