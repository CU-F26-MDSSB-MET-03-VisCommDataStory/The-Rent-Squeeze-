# The Rent Squeeze: Who Bears the Housing-Cost Burden in Europe?


**Project Overview**

This project explores housing-cost pressure across Europe using Eurostat data. We are interested in understanding whether housing-cost overburden differs depending on housing tenure and income level, and whether Germany follows or differs from the broader European pattern. Our visualisations are designed for people making real-life decisions about housing, including renters and people considering relocating to Europe.


The project is being developed as part of the Visual Communication and Data Storytelling.

**Research Questions**

Our data story will explore three main questions:

**1. Which tenure groups face the highest housing-cost burden across Europe?**

**2. How does the housing-cost burden of market-price renters differ between European countries?**

**3. How does housing-cost overburden across tenure and income groups in Germany compare with the broader European pattern?**


We will also examine how housing-cost overburden varies across income groups.

**Target Audience and Personas**

Our data story is designed for people interested in understanding housing affordability across Europe. We have developed three personas to represent different audiences and guide our visualisations.

**Persona 1: Elena – A Renter Considering Homeownership**

Elena is a 28-year-old working professional living in Germany. She currently rents an apartment but is considering buying a home. She wants to understand whether renters experience greater housing-cost pressure than homeowners, particularly those with mortgages. Our visualisations will help her compare housing-cost overburden across different tenure groups and understand Germany's position within Europe.

**Persona 2: Ogiyonke – A Professional Considering Relocation to Europe**

Ogiyonke is a 32-year-old South African IT professional who has received job offers in European countries and is considering relocating. Before accepting an offer, she wants to understand how housing-cost pressure differs between countries, particularly for people renting at market prices. Our country comparisons will help her understand where market-price renters experience greater housing-cost pressure, providing useful context as she evaluates potential relocation destinations. face greater housing-cost burdens and better understand the housing affordability challenges she might encounter.

**Persona 3: Sofia – A Housing Policy Researcher**

Sofia is a 35-year-old housing policy researcher based in Brussels. She is interested in understanding housing affordability inequalities across Europe, particularly how housing-cost overburden differs between renters, homeowners and income groups. She also wants to examine how these patterns change over time and whether Germany differs from the broader European trend. Our visualisations will help her identify inequalities and patterns that could inform housing policy discussions.

These three personas represent different perspectives: individual housing decisions, international relocation and housing policy research. They guide our choice of visualisations and help us communicate housing-cost inequalities in a meaningful and accessible way.

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

2nd quintile - 20%–40% of the income distribution 

3rd quintile - 40%–60% of the income distribution 

4th quintile - 60%–80% of the income distribution 

5th quintile — highest-income 20%



Our analysis will mainly focus on the latest available data, with particular attention to 2025 where data are available.

**What is Housing-Cost Overburden?**

Eurostat defines the housing-cost overburden rate as the percentage of people living in households where total housing costs account for more than 40% of disposable household income.

The measure therefore allows us to compare housing-cost pressure across different groups and countries.

**Planned Analysis**

We plan to use visualisations to:

- Compare housing-cost overburden across different tenure groups, particularly renters and homeowners.
- Examine how housing-cost overburden among market-price renters differs across European countries.
- Investigate differences in housing-cost overburden across income quintiles.
- Compare Germany with the broader European pattern to identify similarities and differences in housing-cost pressure across tenure and income groups.

Our visualisations will be guided by the information needs of our three target personas, helping audiences understand how housing-cost pressure varies across countries, housing tenure groups and income levels.

Our analysis examines housing-cost overburden from two complementary perspectives: **housing tenure and income level**. The tenure-based analysis compares renters and homeowners, while the income-based analysis examines differences across income quintiles. Although both perspectives contribute to understanding housing-cost inequality, they represent different population groupings and will be analysed separately.

We will therefore avoid assuming that differences in housing-cost overburden between tenure groups are directly explained by income levels, as our selected datasets do not establish this relationship.

**Planned Visualisations**

We plan to develop four main visualisations to communicate housing-cost overburden across Europe. Each visualisation will address a specific aspect of our research questions and respond to the information needs of our target personas.

**1. Housing-Cost Overburden by Tenure Status**

This visualisation will compare housing-cost overburden rates across different tenure groups, including market-price renters, reduced-price renters, homeowners with mortgages and homeowners without mortgages. We plan to use a grouped bar chart or dot plot to highlight differences between these groups across European countries.

- **Dataset:** Eurostat ilc_lvho07c
- **Research Question:** RQ1
- **Target Persona:** Elena

**2. Housing-Cost Overburden Among Market-Price Renters Across Europe**

This visualisation will compare housing-cost overburden rates among market-price renters across European countries. We plan to use a ranked horizontal bar chart to identify countries with relatively higher and lower rates.

- **Dataset:** Eurostat ilc_lvho07c
- **Research Question:** RQ2
- **Target Persona:** Ogiyonke

**3. Housing-Cost Overburden Across Income Quintiles**

This visualisation will examine how housing-cost overburden differs across five income quintiles, from the lowest-income 20% to the highest-income 20%. We plan to use a bar chart or dot plot to communicate differences in housing-cost pressure across income groups.

- **Dataset:** Eurostat ilc_lvho07b
- **Research Focus:** Income-related housing-cost inequality
- **Target Persona:** Sofia

**4. Germany Compared with the European Union**

This visualisation will compare Germany's housing-cost overburden rates with the EU aggregate across selected tenure and income groups. We plan to use a grouped bar chart or small-multiple plots to highlight similarities and differences between Germany and the broader European pattern.

- **Datasets:** Eurostat ilc_lvho07c and ilc_lvho07b
- **Research Question:** RQ3
- **Target Personas:** Elena and Sofia

**Optional: Housing-Cost Overburden Over Time**

Depending on data availability and the findings of our initial analysis, we may develop an additional time-series visualisation to examine how housing-cost overburden has changed over time, particularly in Germany compared with the EU aggregate.

The final choice of visualisations will depend on data availability, completeness and the patterns identified during our analysis. We aim to present the findings clearly and avoid drawing conclusions that are not supported by the data.

**Tools**

The project will be developed using:

- R

- ggplot2

- dplyr

- tidyr

- Quarto

- GitHub

**Project Structure**

The repository will contain the analysis, visualisations and final data story. The structure may develop as the project progresses.

```textThe-Rent-Squeeze-/
│
├── README.md
├── report.qmd
├── data/
├── figures/
└── ...
```

**Expected Story**

Our initial expectation is that housing-cost pressure will not be distributed equally across Europe. Market-price renters may experience relatively high housing-cost overburden, while lower-income groups may also face greater pressure. However, these are hypotheses rather than conclusions. The final story will be guided by what the data show, with Germany used as a specific country case within the European comparison.
