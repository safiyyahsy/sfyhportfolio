---
layout: page
title: NakNak Restaurant Reviews
subtitle: Web Scraping Pipeline for Sentiment Analysis (Python + Playwright)
---

## Project Overview
This project collected Google Reviews for NakNak Restaurant across multiple branches to support downstream sentiment analysis. My focus was building a reliable web scraping pipeline and delivering a clean, model-ready dataset.

## My Role (Group Project)
**Data Collection Lead** — owned the scraping and dataset preparation end-to-end:
- automated data extraction (review text, rating, date)
- handled pagination/dynamic loading
- cleaned and structured the final dataset for NLP and modeling

## Data Scraping Pipeline
I implemented a Playwright-based scraper to capture review data consistently and reduce manual collection effort.

![Data scraping process](/assets/img/projects/naknak/scraping-process.png)  
*Scraping workflow and Python (Playwright) implementation used to extract reviews.*

## Dataset Output (Sample)
The dataset contains structured records for each review (reviewer name, rating, review text, date) across branches.

![Raw dataset sample](/assets/img/projects/naknak/raw-dataset-sample.png)  
*Example of raw extracted records grouped by branch.*

## How the Dataset Was Used (Team Work)
The cleaned dataset was used by the team for text preprocessing and sentiment classification (k-NN, Naive Bayes, SVM).  
**Best reported result:** **98.83% accuracy (SVM with SMOTE)**.

> Note: I did not implement SMOTE or the classifiers; my contribution was the data extraction and preparation pipeline that enabled the modeling work.

## Skills Demonstrated
- Python (Playwright)
- Web scraping for dynamic content (scroll/pagination)
- Data cleaning and structuring
- Building model-ready datasets for downstream analytics
- Collaboration in a group analytics workflow

[← Back to Projects](/projects.md)
