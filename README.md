# Data Jobs Skill Analysis
This is a personal project. It combines a variety of techniques: data acquisition with a web-scraper written in Python, data cleansing and intensive text mining on R and, finally, a R Shiny app that presents the results in a friendly manner.

#### -- Project Status: Active

## Project Intro/Objective
The purpose of this project is to collect useful data from recent job listings on LinkedIn and use it to determine the most demanded skills in an industry. A Shiny web app allows users to filter these ads based on different criteria and get customized results for their interests. i.e., one could filter out everything but machine learning-related jobs in a particular city.

The text mining algorithms are currently optimized to mine jobs related to data science jobs, located in Spain and written in Spanish or English, but they could be seamlessly optimized for other types of jobs, countries and languages too.

### Methods Used
* Web scraping
* Text mining
* Data cleansing
* Front-end web development
* Data visualization

### Technologies
* R
* RStudio
* Shiny
* HTML
* CSS
* JavaScript
* Python
* Pandas, jupyter
* Selenium
* Chrome driver

## Project Description

There are few job portals that offer public APIs with a relevant list of local Data Science related job offers. In addition, these announcements are most of the time in the form of natural language and unstructured, which makes them challenging to mine massively and draw conclusions.

This project tries to solve these problems, focusing, for now, on the Data Science industry in Spain, with the final goal to generalizing it both in geography and in work areas. The problem of data extraction has been solved using a web scraper in Selenium, run from a Jupyter Notebook. This has allowed the automatic extraction of a file with data from hundreds of LinkedIn ads. This process, for politeness, has been carried out very slowly to avoid sending too many requests in short periods of time to the server.

Using the extracted files, several fields have been coerced to standardized values:
* ad location has been matched with a list of municipalities in Spain and thus the advertisements have been classified by province.
* ad title has been matched with a list of roles linked to data science, classifying all the ads in different categories: data scientist, machine learning specialist, data engineer, etc.
* ad text body has been matched with a list of technological skills, in order to list those that are required for the job

Finally, a simple Shiny app has been built. It allows visualization of the most relevant conclusions while giving the possibility to apply a variety of filters.

![shiny app demo](https://i.imgur.com/evFncFk.gif)

In view of this, `<SQL>` is easily identified as the most demanded skill in Spanish Data Science jobs, as it is explicitly requested in 56.1% of the analyzed offers. It is closely followed by another hard skill, `<Python>`, at 52.0%. Much further back is another well-known statistical programming language, `<R>`, which is listed in almost one in three offers. These results also highlight the importance of soft skills, such as communication. This is emphasized by 39.5% of advertisers, as well as a good command of English, which is required for almost half of the positions.

```

## Contact
* [LinkedIn](https://www.linkedin.com/in/auad1/).  
* [E-mail](mailto:dmartinauad@gmail.com)
