# VISUALISATION 1
# Housing-cost burden in Germany

library(ggplot2)
library(dplyr)

# 1. Prepare the data

visual1_new_data <- visual1_data %>%
  mutate(
    housing_group = factor(
      housing_group,
      levels = c(
        "Market-price renters",
        "Owners with mortgages",
        "Reduced/free renters",
        "Owners without mortgages"
      )
    )
  )

# 2. Create the graph

visual1_new <- ggplot(
  visual1_new_data,
  aes(x = housing_group, y = values, fill = housing_group)
) +

  geom_col(width = 0.65) +

  geom_text(
    aes(label = paste0(values, "%")),
    vjust = -0.5,
    size = 5
  ) +

  scale_fill_manual(
    values = c(
      "Market-price renters" = "#E76F51",
      "Owners with mortgages" = "#2A9D8F",
      "Reduced/free renters" = "#B5BCC3",
      "Owners without mortgages" = "#B5BCC3"
    )
  ) +

 annotate(
  "label",
  x = 1.5,
  y = 15.2,
  label = "Only a 0.2 percentage-point gap",
  size = 4.2,
  colour = "#333333",
  fill = "#F5F5F5",
  linewidth = 0
) +

  scale_y_continuous(
    limits = c(0, 20),
    breaks = seq(0, 20, 5)
  ) +

  labs(
    title = "Renting or Buying? Germany's Housing-Cost Burden Is Almost the Same",
    subtitle = "Market-price renters and mortgage holders face nearly identical overburden rates (2025)",
    x = NULL,
    y = "Housing-cost overburden rate (%)",
    caption = "Source: Eurostat (ilc_lvho07c)"
  ) +

  theme_minimal(base_size = 13) +

  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 11),
    axis.text.x = element_text(angle = 15, hjust = 1),
    panel.grid.major.x = element_blank()
  )

# 3. Display the graph

print(visual1_new)

# 4. Save the graph

ggsave(
  "visual1_germany_redesigned.png",
  plot = visual1_new,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)




# VISUALISATION 2
# Housing-cost pressure among market-price renters across Europe
# Target persona: Ogiyonke

library(ggplot2)
library(dplyr)

# 1. Prepare the data

visual2_new_data <- visual2_data %>%
  mutate(
    highlight = case_when(
      country == "Romania" ~ "Highest rate",
      country == "Finland" ~ "Lowest rate",
      country == "Germany" ~ "Germany",
      country == "EU-27 average" ~ "EU-27",
      TRUE ~ "Other countries"
    ),
    country = reorder(country, values)
  )

# 2. Create the graph

visual2_new <- ggplot(
  visual2_new_data,
  aes(x = values, y = country, fill = highlight)
) +

  geom_col(width = 0.75) +

  geom_text(
    aes(label = paste0(round(values, 1), "%")),
    hjust = -0.15,
    size = 3.2
  ) +

  scale_fill_manual(
    values = c(
      "Highest rate" = "#C44E52",
      "Lowest rate" = "#D4A64A",
      "Germany" = "#2A9D8F",
      "EU-27" = "#4C8AB6",
      "Other countries" = "#B5BCC3"
    ),
    breaks = c(
      "Highest rate",
      "Lowest rate",
      "Germany",
      "EU-27",
      "Other countries"
    )
  ) +

  scale_x_continuous(
    limits = c(0, 65),
    breaks = seq(0, 60, 10)
  ) +

  labs(
    title = "Thinking of Moving to Europe? Housing-Cost Pressure Varies Dramatically",
    subtitle = "Housing-cost overburden among market-price renters across European countries (2025)",
    x = "Housing-cost overburden rate (%)",
    y = NULL,
    fill = NULL,
    caption = "Source: Eurostat (ilc_lvho07c)"
  ) +

  theme_minimal(base_size = 12) +

  theme(
    plot.title = element_text(
      face = "bold",
      size = 16
    ),

    plot.subtitle = element_text(
      size = 11
    ),

    legend.position = "bottom",

    panel.grid.major.y = element_blank(),

    axis.text.y = element_text(
      size = 10
    ),

    axis.text.x = element_text(
      size = 10
    ),

    plot.caption = element_text(
      size = 9
    )
  )

# 3. Display the graph

print(visual2_new)

# 4. Save the graph

ggsave(
  "visual2_market_renters_redesigned.png",
  plot = visual2_new,
  width = 12,
  height = 12,
  dpi = 300,
  bg = "white"
)

# ============================================================
# VISUALISATION 3
# Housing-Cost Overburden Across Income Groups
# Target persona: Sofia
# ============================================================


# 1. Download the income dataset

income_data <- get_eurostat(
  "ilc_lvho07b",
  time_format = "num"
)


# 2. Check the dataset

head(income_data)

names(income_data)

unique(income_data$quantile)

# 3. Check the available income groups

unique(income_data$quant_inc)


# 4. Check EU-27 income groups for 2025

visual3_data <- income_data %>%
  filter(
    geo == "EU27_2020",
    TIME_PERIOD == 2025,
    unit == "PC",
    quant_inc %in% c("QU1", "QU2", "QU3", "QU4", "QU5")
  )


# 5. Display the results

visual3_data %>%
  select(quant_inc, values) %>%
  arrange(quant_inc)

# ============================================================
# VISUALISATION 3 - REDESIGNED
# Housing-Cost Overburden Across Income Groups
# ============================================================

# 1. Prepare the data

visual3_new_data <- visual3_data %>%
  mutate(
    income_group = factor(
      quant_inc,
      levels = c("QU1", "QU2", "QU3", "QU4", "QU5"),
      labels = c(
        "Lowest 20%",
        "Second 20%",
        "Middle 20%",
        "Fourth 20%",
        "Highest 20%"
      )
    ),
    bar_colour = case_when(
      quant_inc == "QU1" ~ "Lowest income",
      quant_inc == "QU5" ~ "Highest income",
      TRUE ~ "Other groups"
    )
  )


# 2. Create the redesigned graph

visual3_new <- ggplot(
  visual3_new_data,
  aes(x = income_group, y = values, fill = bar_colour)
) +

  # Bars
  geom_col(width = 0.65) +

  # Percentage labels
  geom_text(
    aes(label = paste0(values, "%")),
    vjust = -0.6,
    size = 4.5
  ) +

  # Choose colours
  scale_fill_manual(
    values = c(
      "Lowest income" = "#C44E52",
      "Other groups" = "#B8BEC5",
      "Highest income" = "#2A9D8F"
    )
  ) +

  # Add the main finding
  annotate(
  "label",
  x = 3.5,
  y = 18,
  label = "43x higher overburden rate\namong the lowest-income group",
  size = 4.5,
  fontface = "bold",
  fill = "#FFF3F3",
  colour = "#8B2E35",
  linewidth = 0
) +

  # Titles and labels
  labs(
    title = "Housing-Cost Pressure Falls Sharply as Income Rises",
    subtitle = "More than 1 in 4 people in the EU's lowest-income group face housing-cost overburden (2025)",
    x = "Income group",
    y = "Housing-cost overburden rate (%)",
    caption = "Source: Eurostat (ilc_lvho07b)"
  ) +

  # Axis settings
  scale_y_continuous(
    limits = c(0, 30),
    breaks = seq(0, 30, 5),
    expand = c(0, 0)
  ) +

  # Clean theme
  theme_minimal(base_size = 13) +

  theme(
    plot.title = element_text(
      face = "bold",
      size = 17
    ),

    plot.subtitle = element_text(
      size = 11
    ),

    axis.text.x = element_text(
      size = 11
    ),

    axis.title = element_text(
      size = 12
    ),

    panel.grid.major.x = element_blank(),

    panel.grid.minor = element_blank(),

    legend.position = "none",

    plot.caption = element_text(
      size = 9,
      hjust = 1
    )
  )


# 3. Display the graph

print(visual3_new)


# 4. Save the redesigned graph

ggsave(
  "visual3_income_groups_redesigned.png",
  plot = visual3_new,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)



# ============================================================
# VISUALISATION 4A
# Germany Compared with the EU-27: Housing Tenure
# ============================================================

# 1. Prepare the data

visual4a_data <- tenure_data %>%
  filter(
    geo %in% c("DE", "EU27_2020"),
    TIME_PERIOD == 2025,
    unit == "PC",
    tenure %in% c("RENT_MKT", "OWN_L"),
    !is.na(values)
  ) %>%
  mutate(
    location = case_when(
      geo == "DE" ~ "Germany",
      geo == "EU27_2020" ~ "EU-27"
    ),
    housing_group = case_when(
      tenure == "RENT_MKT" ~ "Market-price renters",
      tenure == "OWN_L" ~ "Owners with mortgages"
    ),
    location = factor(
      location,
      levels = c("EU-27", "Germany")
    )
  )


# 2. Check the data

visual4a_data %>%
  select(location, housing_group, values)


# 3. Create the dumbbell plot

visual4a <- ggplot(
  visual4a_data,
  aes(
    x = values,
    y = location,
    colour = housing_group
  )
) +

  geom_line(
    aes(group = location),
    colour = "grey65",
    linewidth = 2
  ) +

  geom_point(size = 6) +

  geom_text(
    data = subset(visual4a_data, location == "EU-27"),
    aes(label = paste0(values, "%")),
    vjust = -1.5,
    size = 4,
    show.legend = FALSE
  ) +

  geom_text(
    data = subset(
      visual4a_data,
      location == "Germany" & tenure == "RENT_MKT"
    ),
    aes(label = paste0(values, "%")),
    hjust = -0.5,
    vjust = -1,
    size = 4,
    show.legend = FALSE
  ) +

  geom_text(
    data = subset(
      visual4a_data,
      location == "Germany" & tenure == "OWN_L"
    ),
    aes(label = paste0(values, "%")),
    hjust = 1.5,
    vjust = 2,
    size = 4,
    show.legend = FALSE
  ) +

  scale_colour_manual(
    values = c(
      "Market-price renters" = "#E76F51",
      "Owners with mortgages" = "#2A9D8F"
    )
  ) +

  scale_x_continuous(
    breaks = seq(0, 20, 5)
  ) +

  coord_cartesian(
    xlim = c(0, 23),
    ylim = c(0.4, 2.6),
    clip = "off"
  ) +

  annotate(
    "label",
    x = 5,
    y = 2.35,
    label = "Germany: Only a 0.2 percentage-point gap",
    size = 4,
    colour = "#216E63",
    fill = "#E8F5F1"
  ) +

  annotate(
    "label",
    x = 12,
    y = 0.65,
    label = "EU-27: A 13.6 percentage-point gap",
    size = 4,
    colour = "#A64736",
    fill = "#FFF0EC"
  ) +

  labs(
    title = "Germany's Housing-Cost Divide Looks Different from the EU's",
    subtitle = "Renters and mortgage holders face almost identical overburden rates in Germany (2025)",
    x = "Housing-cost overburden rate (%)",
    y = NULL,
    colour = NULL,
    caption = "Source: Eurostat (ilc_lvho07c)"
  ) +

  theme_minimal(base_size = 14) +

  theme(
    plot.title = element_text(
      face = "bold",
      size = 17
    ),
    plot.subtitle = element_text(
      size = 12
    ),
    axis.text.y = element_text(
      face = "bold",
      size = 14
    ),
    legend.position = "bottom",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )


# 4. Display the graph

print(visual4a)


# 5. Save the graph

ggsave(
  "visual4a_germany_eu_tenure.png",
  plot = visual4a,
  width = 12,
  height = 6,
  dpi = 300,
  bg = "white"
)






# ============================================================
# VISUALISATION 4B
# Germany Compared with the EU-27: Income Groups
# ============================================================

# 1. Prepare the data

visual4b_data <- income_data %>%
  filter(
    geo %in% c("DE", "EU27_2020"),
    TIME_PERIOD == 2025,
    unit == "PC",
    quant_inc %in% c("QU1", "QU2", "QU3", "QU4", "QU5"),
    !is.na(values)
  ) %>%
  mutate(
    location = case_when(
      geo == "DE" ~ "Germany",
      geo == "EU27_2020" ~ "EU-27"
    ),
    income_group = case_when(
      quant_inc == "QU1" ~ "Lowest 20%",
      quant_inc == "QU2" ~ "Second 20%",
      quant_inc == "QU3" ~ "Middle 20%",
      quant_inc == "QU4" ~ "Fourth 20%",
      quant_inc == "QU5" ~ "Highest 20%"
    ),
    income_group = factor(
      income_group,
      levels = c(
        "Highest 20%",
        "Fourth 20%",
        "Middle 20%",
        "Second 20%",
        "Lowest 20%"
      )
    )
  )


# 2. Check the data

visual4b_data %>%
  select(location, income_group, values) %>%
  arrange(income_group, location)


# 3. Create the connected dot plot

visual4b <- ggplot(
  visual4b_data,
  aes(
    x = values,
    y = income_group,
    colour = location
  )
) +

  geom_line(
    aes(group = income_group),
    colour = "grey70",
    linewidth = 1.5
  ) +

  geom_point(
    size = 5
  ) +

  geom_text(
    aes(
      label = paste0(values, "%")
    ),
    vjust = -1.2,
    size = 3.8,
    show.legend = FALSE
  ) +

  scale_colour_manual(
    values = c(
      "EU-27" = "#4C84A6",
      "Germany" = "#2A9D8F"
    )
  ) +

  scale_x_continuous(
    breaks = seq(0, 40, 5),
    expand = expansion(mult = c(0.05, 0.12))
  ) +

  labs(
    title = "Germany's Housing-Cost Burden Exceeds the EU Average at Every Income Level",
    subtitle = "The lowest-income 20% face the greatest pressure: 31.5% in Germany versus 25.9% in the EU-27 (2025)",
    x = "Housing-cost overburden rate (%)",
    y = "Income group",
    colour = NULL,
    caption = "Source: Eurostat (ilc_lvho07b)"
  ) +

  theme_minimal(base_size = 14) +

  theme(
    plot.title = element_text(
      face = "bold",
      size = 18
    ),
    plot.subtitle = element_text(
      size = 12
    ),
    axis.text.y = element_text(
      face = "bold",
      size = 12
    ),
    legend.position = "bottom",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )


# 4. Display the graph

print(visual4b)


# 5. Save the graph

ggsave(
  "visual4b_germany_eu_income.png",
  plot = visual4b,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)