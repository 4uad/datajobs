library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinyjs)

library(data.table)

# params

nskills = 10 # top N skills to show in plot

# load jobs data:

data = readRDS("../jobs_clean.RDS")
data[is.na(seniority) | seniority == "", seniority := "Unknown"]

runApp(launch.browser = T)