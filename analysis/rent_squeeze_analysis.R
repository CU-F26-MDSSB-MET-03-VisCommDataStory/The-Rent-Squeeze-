

# THE RENT SQUEEZE
# Who Bears the Housing-Cost Burden in Europe?


# ============================================================
# SECTION 1: LOAD PACKAGES AND PROJECT SETTINGS
# ============================================================

library(jsonlite)
library(dplyr)
library(ggplot2)

# Confirm that we are in the project root
stopifnot(dir.exists("visualisations"))

# Create the data directory if necessary
dir.create("data", showWarnings = FALSE)

# Reference year
year <- 2025


# ============================================================
# SECTION 2: AUTOMATIC EUROSTAT DATA COLLECTION
# ============================================================

# Download data on the first run.
# Use saved snapshots on subsequent runs to ensure
# reproducibility and prevent changes caused by data revisions.


# ============================================================
# SECTION 2: AUTOMATIC EUROSTAT DATA COLLECTION
# ============================================================

# Download directly from the official Eurostat API.
# Convert JSON-stat data into a standard R data frame.

download_eurostat <- function(id) {

  url <- paste0(
    "https://ec.europa.eu/eurostat/api/dissemination/",
    "statistics/1.0/data/",
    id,
    "?lang=en"
  )

  message("Downloading Eurostat dataset: ", id)

  raw <- jsonlite::fromJSON(
    url,
    simplifyVector = FALSE
  )

  # Extract dimensions in their original order

  dimensions <- unlist(raw$id)

  categories <- lapply(dimensions, function(d) {

    index <- unlist(
      raw$dimension[[d]]$category$index
    )

    names(sort(index))
  })

  names(categories) <- dimensions

  # Reconstruct the JSON-stat observation grid

  result <- expand.grid(
    rev(categories),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )

  result <- result[, dimensions, drop = FALSE]

  # Extract observed values

  values <- rep(NA_real_, nrow(result))

  observed <- unlist(raw$value)

  if (length(observed) > 0) {

    if (!is.null(names(observed))) {

      positions <- as.integer(names(observed)) + 1L

      values[positions] <- as.numeric(observed)

    } else {

      stopifnot(length(observed) == nrow(result))

      values <- as.numeric(observed)
    }
  }

  result$values <- values

  # Standardise the year column

  if ("time" %in% names(result)) {

    names(result)[names(result) == "time"] <-
      "TIME_PERIOD"
  }

  result$TIME_PERIOD <- as.integer(
    result$TIME_PERIOD
  )

  # Remove missing observations

  result <- result[
    !is.na(result$values),
    ,
    drop = FALSE
  ]

  return(result)
}


# Save data snapshots for reproducibility.
# Subsequent runs use the saved data rather than
# downloading potentially revised Eurostat figures.

snapshot <- function(id) {

  path <- file.path(
    "data",
    paste0("rent_squeeze_", id, ".csv")
  )

  if (file.exists(path)) {

    message("Loading saved dataset: ", id)

    return(
      read.csv(
        path,
        stringsAsFactors = FALSE
      )
    )
  }

  d <- download_eurostat(id)

  write.csv(
    d,
    path,
    row.names = FALSE
  )

  return(d)
}


# Housing-cost overburden by tenure

tenure_data <- snapshot("ilc_lvho07c")


# Housing-cost overburden by income quintile

income_data <- snapshot("ilc_lvho07b")


# ============================================================
# SECTION 3: DATA CLEANING AND PREPARATION
# ============================================================

normalise <- function(d) {

  if (
    !"TIME_PERIOD" %in% names(d) &&
    "time" %in% names(d)
  ) {
    names(d)[names(d) == "time"] <- "TIME_PERIOD"
  }

  d %>%
    filter(
      unit == "PC",
      !is.na(values)
    )
}

tenure_data <- normalise(tenure_data)
income_data <- normalise(income_data)


# Tenure categories

tcodes <- c(
  "RENT_MKT",
  "OWN_L",
  "RENT_FR",
  "OWN_NL"
)

tlabels <- c(
  "Market-price renters",
  "Owners with mortgages",
  "Reduced/free renters",
  "Owners without mortgages"
)


# Income quintiles

qcodes <- paste0("QU", 1:5)

qlabels <- c(
  "Lowest 20%",
  "Second 20%",
  "Middle 20%",
  "Fourth 20%",
  "Highest 20%"
)


# Geographical labels

locations <- c(
  DE = "Germany",
  EU27_2020 = "EU-27"
)


# Consistent geographical colours

cols <- c(
  "Germany" = "#2A9D8F",
  "EU-27" = "#4C8AB6"
)


# Consistent tenure colours

tcols <- setNames(
  c(
    "#E76F51",
    "#2A9D8F",
    "#B5BCC3",
    "#B5BCC3"
  ),
  tlabels
)


# ============================================================
# SECTION 4: DATA VALIDATION
# ============================================================

# Check for duplicate observations, missing categories
# and invalid percentage values.

check <- function(d, keys, n = NULL) {

  if (
    anyDuplicated(d[keys]) ||
    (!is.null(n) && nrow(d) != n) ||
    any(
      !is.finite(d$values) |
      d$values < 0 |
      d$values > 100
    )
  ) {

    stop(
      "Unexpected Eurostat coverage or duplicate observations: ",
      paste(keys, collapse = ", ")
    )
  }

  return(d)
}


# Prepare tenure data for 2025

t <- tenure_data %>%
  filter(
    TIME_PERIOD == year,
    tenure %in% tcodes
  ) %>%
  mutate(
    housing_group = factor(
      tenure,
      levels = tcodes,
      labels = tlabels
    )
  )


# Prepare income data for 2025

i <- income_data %>%
  filter(
    TIME_PERIOD == year,
    quant_inc %in% qcodes
  ) %>%
  mutate(
    income_group = factor(
      quant_inc,
      levels = qcodes,
      labels = qlabels
    )
  )


# Prepare Visualisation 1 data

visual1_data <- check(
  filter(t, geo == "DE"),
  "tenure",
  4
)


# Prepare Visualisation 3 data

visual3_data <- check(
  filter(i, geo == "EU27_2020"),
  "quant_inc",
  5
)


# Prepare Visualisation 4A data

visual4a_data <- check(
  filter(
    t,
    geo %in% names(locations),
    tenure %in% tcodes[1:2]
  ),
  c("geo", "tenure"),
  4
) %>%
  mutate(
    location = unname(locations[geo])
  )


# Prepare Visualisation 4B data

visual4b_data <- check(
  filter(
    i,
    geo %in% names(locations)
  ),
  c("geo", "quant_inc"),
  10
) %>%
  mutate(
    location = unname(locations[geo])
  )


# ============================================================
# SECTION 5: EUROPEAN COUNTRY COMPARISON DATA
# ============================================================

countries <- c(
  AT = "Austria",
  BE = "Belgium",
  BG = "Bulgaria",
  HR = "Croatia",
  CY = "Cyprus",
  CZ = "Czechia",
  DK = "Denmark",
  EE = "Estonia",
  FI = "Finland",
  FR = "France",
  DE = "Germany",
  EL = "Greece",
  HU = "Hungary",
  IE = "Ireland",
  IT = "Italy",
  LV = "Latvia",
  LT = "Lithuania",
  LU = "Luxembourg",
  MT = "Malta",
  NL = "Netherlands",
  PL = "Poland",
  PT = "Portugal",
  RO = "Romania",
  SK = "Slovakia",
  SI = "Slovenia",
  ES = "Spain",
  SE = "Sweden",
  IS = "Iceland",
  NO = "Norway",
  CH = "Switzerland",
  RS = "Serbia",
  ME = "Montenegro",
  MK = "North Macedonia",
  AL = "Albania",
  TR = "Türkiye",
  BA = "Bosnia and Herzegovina",
  XK = "Kosovo",
  UK = "United Kingdom",
  EU27_2020 = "EU-27"
)


visual2_data <- check(
  filter(
    t,
    tenure == "RENT_MKT",
    geo %in% names(countries)
  ),
  "geo"
) %>%
  mutate(
    country = unname(countries[geo])
  )

stopifnot(nrow(visual2_data) > 2)


# Exclude EU aggregate when identifying highest
# and lowest individual country rates.

actual <- visual2_data %>%
  filter(geo != "EU27_2020")


# Automatically identify countries to highlight

visual2_data <- visual2_data %>%
  mutate(
    highlight = case_when(
      geo == "DE" ~ "Germany",
      geo == "EU27_2020" ~ "EU-27",
      values == max(actual$values) ~ "Highest rate",
      values == min(actual$values) ~ "Lowest rate",
      TRUE ~ "Other countries"
    )
  )


# ============================================================
# SECTION 6: HISTORICAL TREND DATA
# ============================================================

optional_data <- check(
  filter(
    tenure_data,
    geo %in% names(locations),
    tenure == "RENT_MKT",
    TIME_PERIOD %in% 2015:year
  ),
  c("geo", "TIME_PERIOD")
) %>%
  mutate(
    country = unname(locations[geo])
  )

stopifnot(
  all(names(locations) %in% optional_data$geo)
)


# ============================================================
# SECTION 7: COMMON VISUALISATION DESIGN
# ============================================================

# Percentage formatting

pct <- function(x) {
  sprintf("%.1f%%", x)
}


# Consistent theme for all graphs

base <- theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 17
    ),
    legend.position = "bottom",
    panel.grid.minor = element_blank(),
    plot.caption = element_text(
      size = 9
    )
  )


# Consistent source captions

cap <- function(id) {

  paste0(
    "Source: Eurostat (",
    id,
    "), ",
    year,
    ". Overburden: housing costs exceed 40% ",
    "of disposable income."
  )
}


# Function to display and save graphs

save_plot <- function(p, name, w = 12, h = 7) {

  ggsave(
    filename = file.path(
      "visualisations",
      name
    ),
    plot = p,
    width = w,
    height = h,
    dpi = 300,
    bg = "white"
  )

  print(p)
}


# ============================================================
# VISUALISATION 1
# Housing-cost overburden by tenure in Germany
# ============================================================

p1 <- ggplot(
  visual1_data,
  aes(
    x = housing_group,
    y = values,
    fill = housing_group
  )
) +

  geom_col(
    width = 0.65
  ) +

  geom_text(
    aes(label = pct(values)),
    vjust = -0.5
  ) +

  scale_fill_manual(
    values = tcols
  ) +

  scale_y_continuous(
    expand = expansion(
      mult = c(0, 0.18)
    )
  ) +

  labs(
    title = "Housing-cost overburden across tenure groups in Germany",
    x = NULL,
    y = "Overburden rate (%)",
    caption = cap("ilc_lvho07c")
  ) +

  base +

  theme(
    legend.position = "none",
    axis.text.x = element_text(
      angle = 15,
      hjust = 1
    ),
    panel.grid.major.x = element_blank()
  )


# ============================================================
# VISUALISATION 2
# Market-price renters across Europe
# ============================================================

p2 <- ggplot(
  visual2_data,
  aes(
    x = values,
    y = reorder(country, values),
    fill = highlight
  )
) +

  geom_col(
    width = 0.75
  ) +

  geom_text(
    aes(label = pct(values)),
    hjust = -0.12,
    size = 3.2
  ) +

  scale_fill_manual(
    values = c(
      "Highest rate" = "#C44E52",
      "Lowest rate" = "#D4A64A",
      "Germany" = "#2A9D8F",
      "EU-27" = "#4C8AB6",
      "Other countries" = "#B5BCC3"
    )
  ) +

  scale_x_continuous(
    expand = expansion(
      mult = c(0, 0.15)
    )
  ) +

  labs(
    title = "Housing-cost pressure among market-price renters varies across Europe",
    x = "Overburden rate (%)",
    y = NULL,
    fill = NULL,
    caption = cap("ilc_lvho07c")
  ) +

  base +

  theme(
    panel.grid.major.y = element_blank()
  )


# ============================================================
# VISUALISATION 3
# Housing-cost overburden by income quintile
# ============================================================

p3 <- ggplot(
  visual3_data,
  aes(
    x = income_group,
    y = values,
    fill = quant_inc
  )
) +

  geom_col(
    width = 0.65
  ) +

  geom_text(
    aes(label = pct(values)),
    vjust = -0.5
  ) +

  scale_fill_manual(
    values = setNames(
      c(
        "#C44E52",
        rep("#B8BEC5", 3),
        "#2A9D8F"
      ),
      qcodes
    )
  ) +

  scale_y_continuous(
    expand = expansion(
      mult = c(0, 0.18)
    )
  ) +

  labs(
    title = "Housing-cost pressure across EU income groups",
    x = NULL,
    y = "Overburden rate (%)",
    caption = cap("ilc_lvho07b")
  ) +

  base +

  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank()
  )


# ============================================================
# VISUALISATION 4A
# Germany versus EU by tenure
#
# NEW DESIGN: Horizontal bar comparison
# Replaces the previous dumbbell chart.
# ============================================================

# Automatically calculate percentage-point differences

visual4a_data <- visual4a_data %>%
  group_by(location) %>%
  mutate(
    gap =
      values[tenure == "RENT_MKT"] -
      values[tenure == "OWN_L"],

    panel = sprintf(
      "%s | Renter minus mortgage: %.1f pp",
      location,
      gap
    )
  ) %>%
  ungroup()



# VISUALISATION 4A
# Germany versus EU-27 by housing tenure

p4a <- ggplot(
  visual4a_data %>%
    mutate(
      panel = factor(
        panel,
        levels = unique(panel[order(
          !grepl("^Germany", panel)
        )])
      )
    ),
  aes(
    x = values,
    y = housing_group,
    fill = housing_group
  )
) +

  geom_col(
    width = 0.65
  ) +

  geom_text(
    aes(label = pct(values)),
    hjust = -0.15,
    size = 5,
    fontface = "bold"
  ) +

  facet_wrap(
    ~panel,
    ncol = 1,
    labeller = labeller(
      panel = function(x) {
        gsub(
          "Renter minus mortgage:",
          "Gap:",
          x,
          fixed = TRUE
        )
      }
    )
  ) +

  scale_fill_manual(
    values = tcols
  ) +

  scale_x_continuous(
    breaks = seq(0, 20, 5),
    expand = expansion(
      mult = c(0, 0.15)
    )
  ) +

  labs(
    title = "Germany's renters and mortgage holders face almost equal housing-cost burdens",
    x = "Overburden rate (%)",
    y = NULL,
    caption = cap("ilc_lvho07c")
  ) +

  base +

  theme(
    legend.position = "none",

    plot.title = element_text(
      size = 17,
      face = "bold",
      margin = margin(b = 18)
    ),

    strip.text = element_text(
      size = 13,
      face = "bold",
      hjust = 0
    ),

    axis.text.y = element_text(
      size = 12,
      colour = "#333333"
    ),

    axis.text.x = element_text(
      size = 11
    ),

    axis.title.x = element_text(
      size = 12
    ),

    panel.grid.major.y = element_blank(),

    panel.grid.minor = element_blank(),

    panel.grid.major.x = element_line(
      colour = "#E8E8E8",
      linewidth = 0.4
    ),

    panel.spacing = grid::unit(0.8, "lines"),

    plot.caption = element_text(
      size = 10,
      colour = "#555555"
    )
  )


# ============================================================
# VISUALISATION 4B
# Germany versus EU by income quintile
#
# NEW DESIGN: Income profile chart
# Replaces the previous dumbbell chart.
# ============================================================


# VISUALISATION 4B
# Germany versus EU-27 by income quintile

p4b <- ggplot(
  visual4b_data,
  aes(
    x = income_group,
    y = values,
    colour = location,
    group = location
  )
) +

  geom_line(
    data = filter(
      visual4b_data,
      location != "Germany"
    ),
    linewidth = 1.1
  ) +

  geom_line(
    data = filter(
      visual4b_data,
      location == "Germany"
    ),
    linewidth = 1.6
  ) +

  geom_point(
    size = 3.8
  ) +

  geom_text(
    aes(
      label = pct(values),
      vjust = ifelse(
        location == "Germany",
        -1.2,
        1.8
      )
    ),
    size = 4.5,
    fontface = "bold",
    show.legend = FALSE
  ) +

  scale_colour_manual(
    values = cols
  ) +

  scale_y_continuous(
    breaks = seq(0, 35, 5),
    expand = expansion(
      mult = c(0.12, 0.18)
    )
  ) +

  labs(
    title = "Housing-cost overburden is higher in Germany across every income quintile",
    x = NULL,
    y = "Overburden rate (%)",
    colour = NULL,
    caption = cap("ilc_lvho07b")
  ) +

  base +

  theme(
    plot.title = element_text(
      size = 17,
      face = "bold",
      margin = margin(b = 18)
    ),

    axis.text.x = element_text(
      size = 11,
      colour = "#333333"
    ),

    axis.text.y = element_text(
      size = 11
    ),

    axis.title.y = element_text(
      size = 12
    ),

    panel.grid.major.x = element_blank(),

    panel.grid.minor = element_blank(),

    panel.grid.major.y = element_line(
      colour = "#E8E8E8",
      linewidth = 0.4
    ),

    legend.position = "bottom",

    legend.text = element_text(
      size = 12
    ),

    plot.caption = element_text(
      size = 10,
      colour = "#555555"
    )
  )


# ============================================================
# SECTION 8: SYNTHETIC DATA GENERATION
# ============================================================

# RESEARCH PURPOSE:
#
# The observed Eurostat datasets describe housing-cost
# overburden by tenure and income separately.
#
# Our selected datasets do not directly provide
# overburden rates for combined income-tenure groups.
#
# This synthetic scenario demonstrates how such a
# combined analysis could be visualised.
#
# IMPORTANT:
# Synthetic results are hypothetical, not observed
# Eurostat statistics.
#
# MODEL ASSUMPTIONS:
#
# 1. Each tenure group contains equal proportions
#    of the five income quintiles.
#
# 2. The observed German income profile informs
#    the relative odds of housing-cost overburden.
#
# 3. Synthetic values are calibrated to reproduce
#    the observed German tenure rates.
#
# 4. Observed income margins are not independently
#    reproduced by this model.
#
# 5. The model is deterministic, meaning that it
#    produces the same output for the same inputs.
#
# No random sampling is required.


# Extract the observed German income profile

q <- visual4b_data %>%
  filter(geo == "DE") %>%
  arrange(quant_inc)


# Convert probabilities to log-odds.
# Small probability bounds prevent infinite values.

profile <- qlogis(
  pmin(
    0.9999,
    pmax(
      0.0001,
      q$values / 100
    )
  )
)


# Centre the income profile

profile <- profile - mean(profile)


# Generate synthetic income-tenure combinations

synthetic <- bind_rows(

  lapply(

    seq_len(nrow(visual1_data)),

    function(j) {

      # Observed tenure overburden probability

      target <- visual1_data$values[j] / 100


      # Calculate hypothetical income-specific
      # probabilities within each tenure group.

      probs <- if (target == 0 || target == 1) {

        rep(target, 5)

      } else {

        # Calibrate the model to reproduce
        # the observed tenure rate.

        a <- uniroot(

          function(a) {

            mean(
              plogis(a + profile)
            ) - target

          },

          interval = c(-100, 100),

          tol = 1e-12

        )$root


        plogis(a + profile)
      }


      # Return synthetic observations

      data.frame(

        housing_group = as.character(
          visual1_data$housing_group[j]
        ),

        income_group = qlabels,

        values = 100 * probs,

        observed_tenure_rate = 100 * target,

        assumed_weight = 0.2
      )
    }
  )
)


# ============================================================
# SECTION 9: SYNTHETIC DATA VALIDATION
# ============================================================

# Check whether synthetic tenure averages reproduce
# the observed tenure rates under our assumptions.

validation <- synthetic %>%
  group_by(housing_group) %>%
  summarise(

    simulated_margin = sum(
      values * assumed_weight
    ),

    observed = first(
      observed_tenure_rate
    ),

    .groups = "drop"
  )


# Stop execution if calibration fails

stopifnot(

  max(
    abs(
      validation$simulated_margin -
      validation$observed
    )
  ) < 1e-6
)


# Organise synthetic income groups

synthetic$income_group <- factor(
  synthetic$income_group,
  levels = qlabels
)


# Organise synthetic tenure groups

synthetic$housing_group <- factor(
  synthetic$housing_group,
  levels = rev(tlabels)
)


# Save synthetic data separately

write.csv(

  synthetic,

  "data/rent_squeeze_synthetic_income_tenure.csv",

  row.names = FALSE
)


# Save validation results

write.csv(

  validation,

  "data/rent_squeeze_synthetic_validation.csv",

  row.names = FALSE
)


# ============================================================
# VISUALISATION 5
# Synthetic income-tenure interaction
#
# NEW DESIGN: Heatmap
# ============================================================

p5 <- ggplot(
  synthetic,
  aes(
    x = income_group,
    y = housing_group,
    fill = values
  )
) +

  geom_tile(
    colour = "white",
    linewidth = 1.2
  ) +

  geom_text(
    aes(
      label = pct(values),
      colour = values >= 20
    ),
    size = 4.5,
    fontface = "bold"
  ) +

  scale_colour_manual(
    values = c(
      "TRUE" = "white",
      "FALSE" = "#422222"
    ),
    guide = "none"
  ) +

  scale_fill_gradient(
    low = "#FBE8DF",
    high = "#9B282B",
    limits = c(0, 40),
    breaks = c(0, 10, 20, 30, 40),
    name = "Simulated overburden (%)"
  ) +

  labs(
    title = "Low-income renters and mortgage holders face the greatest simulated burden in Germany",
    x = "Income quintile",
    y = NULL,
    caption = paste0(
      "Synthetic scenario for 2025: illustrative estimates, not observed Eurostat rates.\n",
      "Assumes equal income-quintile weights within each tenure group.\n",
      "Calibrated to observed tenure rates; income profile informs relative odds.\n",
      "Sources: Eurostat (ilc_lvho07b and ilc_lvho07c)."
    )
  ) +

  base +

  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(
      size = 11,
      face = "bold"
    ),
    axis.text.y = element_text(
      size = 11
    ),
    plot.title = element_text(
      size = 14,
      face = "bold"
    ),
    plot.caption = element_text(
      size = 9,
      hjust = 0
    ),
    legend.position = "bottom"
  )

# ============================================================
# OPTIONAL VISUALISATION
# Historical housing-cost overburden trends
# Germany versus EU-27, 2015-2025
# ============================================================

p6 <- ggplot(

  optional_data,

  aes(
    x = TIME_PERIOD,
    y = values,
    colour = country,
    group = country
  )

) +

  geom_line(
    linewidth = 1.2
  ) +

  geom_point(
    size = 2.5
  ) +

  geom_text(

    data = filter(
      optional_data,
      TIME_PERIOD == year
    ),

    aes(
      label = pct(values)
    ),

    hjust = -0.15,

    show.legend = FALSE

  ) +

  scale_colour_manual(
    values = cols
  ) +

  scale_x_continuous(

    breaks = 2015:year,

    expand = expansion(
      mult = c(0.02, 0.12)
    )

  ) +

  labs(

    title = "Housing-cost overburden among market-price renters over time",

    x = "Year",

    y = "Overburden rate (%)",

    colour = NULL,

    caption = "Source: Eurostat (ilc_lvho07c), 2015–2025."

  ) +

  base


# ============================================================
# SECTION 10: EXPORT ALL SEVEN VISUALISATIONS
# ============================================================

save_plot(
  p1,
  "visual1_germany_redesigned.png"
)

save_plot(
  p2,
  "visual2_market_renters_redesigned.png",
  12,
  12
)

save_plot(
  p3,
  "visual3_income_groups_redesigned.png"
)

save_plot(
  p4a,
  "visual4a_germany_eu_tenure.png"
)

save_plot(
  p4b,
  "visual4b_germany_eu_income.png"
)

save_plot(
  p5,
  "visual5_synthetic_income_tenure.png",
  14,
  7
)

save_plot(
  p6,
  "optional_housing_cost_trends.png"
)


# ============================================================
# SECTION 11: RECORD THE R ENVIRONMENT
# ============================================================

# Record R and package versions for reproducibility.

writeLines(

  capture.output(
    sessionInfo()
  ),

  "data/rent_squeeze_session_info.txt"
)


# ============================================================
# ANALYSIS COMPLETE
# ============================================================

message(
  "Seven graphs exported. Synthetic calibration checks passed."
)
