#!/usr/bin/env python
# coding: utf-8

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import time # wait between requests
import random # wait for a random amount of secs between requests
import re # regex matching
import pandas as pd
from settings import * # linkedin credentials and job search settings

url = 'https://www.linkedin.com/login'

# start driver
driver = webdriver.Chrome(chromeDriver)

# delete any pre-existing cookies so login process is always the same
driver.delete_all_cookies()

# login
driver.get(urlLogin)
user_element = driver.find_element_by_id("username")
pass_element = driver.find_element_by_id("password")
user_element.send_keys(user)
pass_element.send_keys(password)
pass_element.send_keys(Keys.RETURN)

# navigate to search URl, already filtered by country and position
driver.get(urlSearch)

# find the result count and print it
jobCountElem = driver.find_elements_by_css_selector('.jobs-search-two-pane__title-heading small')

jobCount = int(jobCountElem[0].text.split()[0])

# jobCount is used as upper bound for scraping loop
print('{} jobs found.'.format(jobCount))

# for each of the ads found...

for j in range(1, jobCount):

    # navigate to the ad
    url = urlSearch + '&start={}'.format(j)

    driver.get(url)

    # wait for it to load
    time.sleep(4)

    # job id (number in the url)
    jobid = driver.find_element_by_css_selector('a.jobs-details-top-card__job-title-link').get_attribute('href').split('/')[5]

    # big title in the ad
    jobTitle = driver.find_element_by_css_selector('.jobs-details-top-card__job-title').text

    # text body (save the raw HTMl for analysis)
    jobText = driver.find_element_by_css_selector('.jobs-description-content__text span').get_attribute('innerHTML')

    # seniority, found at the bottom of the ad
    seniority = driver.find_elements_by_css_selector('.jobs-box__body.js-formatted-exp-body')

    if not seniority: # some ads do not specify seniority, handle it.
        seniority = ''
        # if seniority is not specified, industry becomes the 1st item
        indElems = driver.find_elements_by_css_selector('.jobs-box__group:nth-child(1) ul li.jobs-box__list-item')

    else:
        seniority = seniority[0].text
        # if seniority is specified, industry becomes the 2nd item
        indElems = driver.find_elements_by_css_selector('.jobs-box__group:nth-child(2) ul li.jobs-box__list-item')
    industry = ';'.join([i.text for i in indElems])

    # get company from ad title and location
    company = driver.find_element_by_css_selector('.jobs-details-top-card__company-info').text.split('\n')

    location = company[-1]
    company = company[1]

    # store all collected data in a 1-row data frame
    njob = pd.DataFrame({
        'id': [jobid],
        'title': [jobTitle],
        'location': [location],
        'company': [company],
        'industry': [industry],
        'seniority': [seniority],
        'text': [jobText]
    })

    # on first iteration, create data frame. Else, concat new df to pre-existing one.
    if j > 1:
        if not job.equals(njob):
            job = njob
            jobs = pd.concat([jobs, job], ignore_index = True)
        else:
            # if the df created on this iter is exactly the same as the previous,
            # it means there aren't any more ads.
            # break the loop
            break
    else:
        job = njob
        jobs = job

    # wait from 1 to 10 seconds (avoid request flooding)
    time.sleep(random.randint(1, 10))

jobs

# output
jobs.to_csv('jobs.txt', sep = "|")
