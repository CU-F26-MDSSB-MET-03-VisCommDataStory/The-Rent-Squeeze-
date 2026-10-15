
# ============================================================
# THE RENT SQUEEZE: WHO BEARS THE BURDEN?
# Housing-cost overburden across European countries, 2025
# Source: Eurostat (ilc_lvho07c)
# ============================================================

# 1. INSTALL MISSING PACKAGES
packages <- c("ggplot2", "dplyr", "tidyr", "eurostat")

missing <- packages[
  !packages %in% rownames(installed.packages())
]

if (length(missing) > 0) {
  install.packages(missing)
}

# 2. LOAD PACKAGES
library(ggplot2)
library(dplyr)
library(tidyr)
library(eurostat)

# 3. DOWNLOAD EUROSTAT DATA
housing_tenure <- get_eurostat(
  "ilc_lvho07c",
  time_format = "num"
)

# 4. SELECT 2025 DATA AND TWO TENURE GROUPS
# RENT_MKT = Market-price renters
# OWN_L = Homeowners with a mortgage or loan

dumbbell_data <- housing_tenure |>
  filter(
    TIME_PERIOD == 2025,
    unit == "PC",
    tenure %in% c("RENT_MKT", "OWN_L")
  ) |>
  select(geo, tenure, values) |>
  pivot_wider(
    names_from = tenure,
    values_from = values
  ) |>
  filter(
    !is.na(RENT_MKT),
    !is.na(OWN_L)
  )

# 5. COUNTRY NAMES
country_names <- c(
  "AT" = "Austria",
  "BE" = "Belgium",
  "BG" = "Bulgaria",
  "CY" = "Cyprus",
  "CZ" = "Czechia",
  "DE" = "Germany",
  "DK" = "Denmark",
  "EE" = "Estonia",
  "EL" = "Greece",
  "ES" = "Spain",
  "FI" = "Finland",
  "FR" = "France",
  "HR" = "Croatia",
  "HU" = "Hungary",
  "IE" = "Ireland",
  "IT" = "Italy",
  "LT" = "Lithuania",
  "LU" = "Luxembourg",
  "LV" = "Latvia",
  "MT" = "Malta",
  "NL" = "Netherlands",
  "NO" = "Norway",
  "PL" = "Poland",
  "PT" = "Portugal",
  "RO" = "Romania",
  "RS" = "Serbia",
  "SE" = "Sweden",
  "SI" = "Slovenia",
  "SK" = "Slovakia",
  "TR" = "Türkiye"
)

# 6. PREPARE THE PLOT DATA
dumbbell_plot_data <- dumbbell_data |>
  filter(geo %in% names(country_names)) |>
  mutate(
    country = unname(country_names[geo]),
    gap = RENT_MKT - OWN_L
  ) |>
  arrange(desc(gap))

# 7. CHECK THE DATA
print(dumbbell_plot_data)

cat(
  "Number of countries:",
  nrow(dumbbell_plot_data),
  "\n"
)

# 8. CREATE THE DUMBBELL CHART
final_plot <- ggplot(
  dumbbell_plot_data,
  aes(y = reorder(country, gap))
) +
  geom_segment(
    aes(
      x = OWN_L,
      xend = RENT_MKT,
      yend = reorder(country, gap)
    ),
    color = "grey75",
    linewidth = 0.8
  ) +
  geom_point(
    aes(
      x = OWN_L,
      color = "Homeowners with mortgages"
    ),
    size = 2.8
  ) +
  geom_point(
    aes(
      x = RENT_MKT,
      color = "Market-price renters"
    ),
    size = 2.8
  ) +
  scale_color_manual(
    values = c(
      "Homeowners with mortgages" = "#2A9D8F",
      "Market-price renters" = "#E76F51"
    ),
    breaks = c(
      "Homeowners with mortgages",
      "Market-price renters"
    )
  ) +
  labs(
    title = "The Rent Squeeze: Who Bears the Burden?",
    subtitle = paste(
      "Market-price renters vs homeowners",
      "with mortgages across Europe, 2025"
    ),
    x = "Housing-cost overburden rate (%)",
    y = NULL,
    color = NULL,
    caption = "Source: Eurostat (ilc_lvho07c)"
  ) +
  scale_x_continuous(
    breaks = seq(0, 60, 10),
    expand = expansion(mult = c(0.02, 0.08))
  ) +
  coord_cartesian(clip = "off") +
  theme_minimal(base_size = 17) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 25
    ),
    plot.subtitle = element_text(size = 17),
    axis.text.y = element_text(size = 14),
    axis.text.x = element_text(size = 14),
    axis.title.x = element_text(size = 17),
    legend.position = "bottom",
    legend.text = element_text(size = 15),
    plot.caption = element_text(size = 12),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(15, 35, 15, 15)
  )

# 9. HIGHLIGHT GERMANY
germany <- dumbbell_plot_data |>
  filter(geo == "DE")

if (nrow(germany) == 1) {

  germany_gap <- germany$gap

  final_plot <- final_plot +
    geom_point(
      data = germany,
      aes(x = OWN_L, y = country),
      inherit.aes = FALSE,
      color = "#2A9D8F",
      size = 4
    ) +
    geom_point(
      data = germany,
      aes(x = RENT_MKT, y = country),
      inherit.aes = FALSE,
      color = "#E76F51",
      size = 4
    ) +
    geom_text(
      data = germany,
      aes(
        x = OWN_L,
        y = country,
        label = paste0(OWN_L, "%")
      ),
      inherit.aes = FALSE,
      color = "#2A9D8F",
      hjust = 1.2,
      size = 4
    ) +
    geom_text(
      data = germany,
      aes(
        x = RENT_MKT,
        y = country,
        label = paste0(RENT_MKT, "%")
      ),
      inherit.aes = FALSE,
      color = "#E76F51",
      hjust = -0.3,
      size = 4
    )

  print(
    paste(
      "Germany gap:",
      round(germany_gap, 1),
      "percentage points"
    )
  )
}

# 10. LABEL THE EXTREME VALUES
romania <- dumbbell_plot_data |>
  filter(geo == "RO")

if (nrow(romania) == 1) {
  final_plot <- final_plot +
    geom_text(
      data = romania,
      aes(
        x = OWN_L,
        y = country,
        label = paste0(OWN_L, "%")
      ),
      inherit.aes = FALSE,
      color = "#2A9D8F",
      hjust = 1.2,
      size = 4
    ) +
    geom_text(
      data = romania,
      aes(
        x = RENT_MKT,
        y = country,
        label = paste0(RENT_MKT, "%")
      ),
      inherit.aes = FALSE,
      color = "#E76F51",
      hjust = -0.3,
      size = 4
    )
}

# 11. DISPLAY THE FINAL GRAPH
print(final_plot)

# 12. SAVE HIGH-RESOLUTION GRAPH
# Saves to your current working directory

ggsave(
  filename = "rent_squeeze_dumbbell.png",
  plot = final_plot,
  width = 13,
  height = 10,
  dpi = 300,
  bg = "white"
)

# 13. SHOW WHERE THE FILE WAS SAVED
getwd()

# ============================================================
# VISUALISATION 2: GERMANY VS EU-27 AVERAGE (2025)
# ============================================================

# Select Germany and the official EU-27 aggregate
germany_eu_data <- housing_tenure |>
  filter(
    TIME_PERIOD == 2025,
    unit == "PC",
    geo %in% c("DE", "EU27_2020"),
    tenure %in% c("RENT_MKT", "OWN_L")
  ) |>
  mutate(
    location = case_when(
      geo == "DE" ~ "Germany",
      geo == "EU27_2020" ~ "EU-27 Average"
    ),
    housing_group = case_when(
      tenure == "RENT_MKT" ~ "Market-price renters",
      tenure == "OWN_L" ~ "Homeowners with mortgages"
    )
  ) |>
  select(location, housing_group, values)

# Display the four values
print(germany_eu_data)


# =====================================================
# VISUALISATION 2: GERMANY VS EU-27
# =====================================================

comparison_plot <- ggplot(
  germany_eu_data,
  aes(
    x = location,
    y = values,
    fill = housing_group
  )
) +
  geom_col(
    position = position_dodge(width = 0.75),
    width = 0.65
  ) +
  geom_text(
    aes(label = paste0(values, "%")),
    position = position_dodge(width = 0.75),
    vjust = -0.5,
    size = 5
  ) +
  scale_fill_manual(
    values = c(
      "Homeowners with mortgages" = "#2A9D8F",
      "Market-price renters" = "#E76F51"
    )
  ) +
  scale_y_continuous(
    limits = c(0, 23),
    breaks = seq(0, 20, 5)
  ) +
  labs(
    title = "Germany's Unusual Housing-Cost Burden",
    subtitle = "Renters and mortgage holders face similar rates, unlike the EU-27 (2025)",
    x = NULL,
    y = "Housing-cost overburden rate (%)",
    fill = NULL,
    caption = "Source: Eurostat (ilc_lvho07c)"
  ) +
  theme_minimal(base_size = 17) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 24
    ),
    plot.subtitle = element_text(size = 16),
    axis.text.x = element_text(size = 16),
    axis.text.y = element_text(size = 13),
    axis.title.y = element_text(size = 15),
    legend.position = "bottom",
    legend.text = element_text(size = 14),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(size = 11)
  )

# Display the graph
print(comparison_plot)

# Save as high-resolution PNG
ggsave(
  "germany_vs_eu27.png",
  plot = comparison_plot,
  width = 11,
  height = 7,
  dpi = 300,
  bg = "white"
)


# ============================================================
# VISUALISATION 3: HOUSING-COST BURDEN TRENDS (2015–2025)
# Germany vs EU-27
# ============================================================

# 1. Load required packages
library(ggplot2)
library(dplyr)
library(tidyr)
library(eurostat)

# 2. Load Eurostat data if it is not already available
if (!exists("housing_tenure")) {
  housing_tenure <- get_eurostat(
    "ilc_lvho07c",
    time_format = "num"
  )
}

# 3. Prepare the data for the line graph
trend_data <- housing_tenure |>
  filter(
    TIME_PERIOD >= 2015,
    TIME_PERIOD <= 2025,
    unit == "PC",
    geo %in% c("DE", "EU27_2020"),
    tenure %in% c("RENT_MKT", "OWN_L")
  ) |>
  mutate(
    location = case_when(
      geo == "DE" ~ "Germany",
      geo == "EU27_2020" ~ "EU-27 Average"
    ),
    housing_group = case_when(
      tenure == "RENT_MKT" ~ "Market-price renters",
      tenure == "OWN_L" ~ "Homeowners with mortgages"
    )
  ) |>
  filter(!is.na(values))

# 4. Check the data
print(trend_data)

# 5. Check which years are available
trend_data |>
  count(location, housing_group)

# 6. Create the line graph
trend_plot <- ggplot(
  trend_data,
  aes(
    x = TIME_PERIOD,
    y = values,
    color = housing_group,
    group = housing_group
  )
) +
  geom_line(
    linewidth = 1.2
  ) +
  geom_point(
    size = 2.5
  ) +
  facet_wrap(
    ~ location,
    ncol = 1
  ) +
  scale_color_manual(
    values = c(
      "Homeowners with mortgages" = "#2A9D8F",
      "Market-price renters" = "#E76F51"
    )
  ) +
  scale_x_continuous(
    breaks = seq(2015, 2025, 2)
  ) +
  scale_y_continuous(
    limits = c(0, NA),
    breaks = seq(0, 40, 5),
    expand = expansion(mult = c(0, 0.08))
  ) +
  labs(
    title = "Has Germany Always Been Different?",
    subtitle = "Housing-cost overburden trends in Germany and the EU-27, 2015–2025",
    x = "Year",
    y = "Housing-cost overburden rate (%)",
    color = NULL,
    caption = "Source: Eurostat (ilc_lvho07c)"
  ) +
  theme_minimal(
    base_size = 13
  ) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 18
    ),
    plot.subtitle = element_text(
      size = 11
    ),
    strip.text = element_text(
      face = "bold",
      size = 13
    ),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

# 7. Display the graph
print(trend_plot)

# 8. Save the graph as a high-resolution PNG
ggsave(
  filename = "housing_burden_trends.png",
  plot = trend_plot,
  width = 12,
  height = 9,
  dpi = 300,
  bg = "white"
)

# 9. Show where the graph was saved
getwd()
