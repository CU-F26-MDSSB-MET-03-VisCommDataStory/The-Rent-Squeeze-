# ============================================================
# VISUALISATION 5
# Who rents and who owns? Housing tenure shares across Europe
# Context chart: answers "how large is each group?" (Jan's feedback)
# ============================================================
# Run from the repo root (RStudio: open the project, then source this file).
# Needs: eurostat, dplyr, ggplot2, forcats

library(eurostat)
library(dplyr)
library(ggplot2)
library(forcats)

year_use   <- 2025     # change to 2024 if 2025 is missing for many countries
focus_only <- FALSE    # TRUE = only Germany, Italy, Spain and the EU-27

# 1. Download the tenure-share table (population by tenure status)

tenure_shares_raw <- get_eurostat(
  "ilc_lvho02",
  time_format = "num"
)

# 2. Check the dataset and the codes before filtering

names(tenure_shares_raw)
unique(tenure_shares_raw$tenure)   # expect OWN_L, OWN_NL, RENT_MKT, RENT_FR ...
unique(tenure_shares_raw$rskpovth)  # expect TOTAL ...
unique(tenure_shares_raw$hhcomp)    # expect TOTAL ...

# 3. Prepare the data: total population, all household types

country_names <- bind_rows(eu_countries, efta_countries) %>%
  select(code, name)

tenure_labels <- c(
  "OWN_NL"   = "Owners without mortgage",
  "OWN_L"    = "Owners with mortgage",
  "RENT_MKT" = "Market-price renters",
  "RENT_FR"  = "Reduced/free renters"
)

shares <- tenure_shares_raw %>%
  filter(
    rskpovth == "TOTAL",
    hhcomp == "TOTAL",
    unit == "PC",
    TIME_PERIOD == year_use,
    tenure %in% names(tenure_labels),
    !is.na(values),
    geo %in% c(country_names$code, "EU27_2020")
  ) %>%
  left_join(country_names, by = c("geo" = "code")) %>%
  mutate(
    country = case_when(
      geo == "EU27_2020" ~ "EU-27 average",
      TRUE ~ name
    ),
    housing_group = factor(
      tenure_labels[tenure],
      levels = unname(tenure_labels)
    )
  )

# 4. Keep only countries with all four groups, and check the shares add up

complete <- shares %>%
  group_by(country) %>%
  summarise(n_groups = n(), total = sum(values), .groups = "drop")

print(complete, n = Inf)   # total should be close to 100 for every country

shares <- shares %>%
  inner_join(
    complete %>% filter(n_groups == 4, total > 97, total < 103) %>% select(country),
    by = "country"
  )

if (focus_only) {
  shares <- shares %>%
    filter(country %in% c("Germany", "Italy", "Spain", "EU-27 average"))
}

# 5. Sort countries by their share of tenants (market-price + reduced/free)

order_data <- shares %>%
  filter(tenure %in% c("RENT_MKT", "RENT_FR")) %>%
  group_by(country) %>%
  summarise(tenant_share = sum(values), .groups = "drop")

shares <- shares %>%
  left_join(order_data, by = "country") %>%
  mutate(country = fct_reorder(country, tenant_share))

bold_rows <- ifelse(levels(shares$country) %in% c("Germany", "EU-27 average"),
                    "bold", "plain")

# 6. Create the stacked bar chart

visual5 <- ggplot(
  shares,
  aes(x = values, y = country, fill = housing_group)
) +

  geom_col(width = 0.8, position = position_stack(reverse = TRUE)) +

  # Percentage labels only for the countries in the story
  geom_text(
    data = shares %>%
      filter(country %in% c("Germany", "Italy", "Spain", "EU-27 average"),
             values >= 4),
    aes(label = paste0(round(values, 1), "%")),
    position = position_stack(vjust = 0.5, reverse = TRUE),
    size = 3.2,
    colour = "#222222"
  ) +

  scale_fill_manual(
    values = c(
      "Owners without mortgage" = "#B5BCC3",
      "Owners with mortgage"    = "#2A9D8F",
      "Market-price renters"    = "#E76F51",
      "Reduced/free renters"    = "#F4C7B8"
    )
  ) +

  scale_x_continuous(
    breaks = seq(0, 100, 25),
    labels = function(x) paste0(x, "%"),
    expand = c(0, 0)
  ) +

  labs(
    title = "Who Rents and Who Owns? Housing Tenure Across Europe",
    subtitle = paste0(
      "Share of the population by tenure status, sorted by share of tenants (",
      year_use, ")"
    ),
    x = "Share of population (%)",
    y = NULL,
    fill = NULL,
    caption = "Source: Eurostat (ilc_lvho02), total population"
  ) +

  theme_minimal(base_size = 12) +

  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 11),
    legend.position = "bottom",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 10, face = bold_rows),
    plot.caption = element_text(size = 9)
  )

# 7. Display the graph

print(visual5)

# 8. Save the graph

ggsave(
  "visualisations/visual5_tenure_shares_stacked.png",
  plot = visual5,
  width = 12,
  height = ifelse(focus_only, 5, 11),
  dpi = 300,
  bg = "white"
)
