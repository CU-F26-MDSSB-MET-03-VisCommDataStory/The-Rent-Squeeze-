# The Rent Squeeze: Who Bears the Housing-Cost Burden in Europe?


**Project Overview**

This project explores housing-cost pressure across Europe using Eurostat data. We are interested in understanding whether housing-cost overburden differs depending on housing tenure and income level, and whether Germany follows or differs from the broader European pattern.


The project is being developed as part of the Visual Communication and Data Storytelling.

**Research Questions**

Our data story will explore three main questions:

**1. Which tenure groups face the highest housing-cost burden across Europe?**

**2. How does the housing-cost burden of market-price renters differ between European countries?**

**3. Does Germany follow the broader European pattern, or does it stand out?**


We will also examine how housing-cost overburden varies across income groups.

**Data**

We use two Eurostat datasets:

**1. Housing-cost overburden by tenure status**

Dataset: ilc_lvho07c

Link : https://ec.europa.eu/eurostat/databrowser/view/ilc_lvho07c/default/table?lang=en&utm_source

This dataset shows the percentage of people living in households that are overburdened by housing costs, broken down by housing tenure:

- Market-price renters

- Reduced-price or free renters

- Owners with a mortgage or housing loan

- Owners without a mortgage or housing loan

**2. Housing-cost overburden by income quintile**

Dataset: ilc_lvho07b

Link: https://ec.europa.eu/eurostat/databrowser/view/ilc_lvho07b/default/table?lang=en&utm_source

This dataset shows the housing-cost overburden rate across five income groups, or income quintiles. Each quintile represents 20% of the population, ranked according to equivalised disposable income.



1st quintile — lowest-income 20%

2nd quintile

3rd quintile

4th quintile

5th quintile — highest-income 20%



Our analysis will mainly focus on the latest available data, with particular attention to 2025 where data are available.

**What is Housing-Cost Overburden?**

Eurostat defines the housing-cost overburden rate as the percentage of people living in households where total housing costs account for more than 40% of disposable household income.

The measure therefore allows us to compare housing-cost pressure across different groups and countries.

**Planned Analysis**

We plan to use visualisations to:

Compare housing-cost overburden across different tenure groups.

Compare market-price renters across European countries.

Examine differences in housing-cost overburden across income quintiles.

Compare Germany with the broader European pattern.

Identify whether Germany shows a different pattern from other European countries.

**Tools**

The project will be developed using:

R

ggplot2

dplyr

tidyr

Quarto

GitHub

**Project Structure**

The repository will contain the analysis, visualisations and final data story. The structure may develop as the project progresses.

DataStory_HousingCosts/
│
├── README.md
├── report.qmd
├── data/
├── figures/
└── ...

**Expected Story**

Our initial expectation is that housing-cost pressure will not be distributed equally across Europe. Market-price renters may experience relatively high housing-cost overburden, while lower-income groups may also face greater pressure. However, these are hypotheses rather than conclusions. The final story will be guided by what the data show, with Germany used as a specific country case within the European comparison.
