"""
The Rent Squeeze - Image 1: Germany vs Italy vs Spain vs EU-27
Housing cost overburden rate, homeowners with a mortgage (Eurostat ilc_lvho07c)

Usage:
    pip install pandas openpyxl matplotlib
    # run from the repo root:
    python analysis/rent_squeeze_line_chart.py data/ilc_lvho07c_defaultview_spreadsheet.xlsx
"""
import os
import sys
import warnings
import pandas as pd
import matplotlib.pyplot as plt

warnings.filterwarnings("ignore")

path = sys.argv[1] if len(sys.argv) > 1 else "data/ilc_lvho07c_defaultview_spreadsheet.xlsx"
os.makedirs("data", exist_ok=True)
os.makedirs("figures", exist_ok=True)
raw = pd.read_excel(path, header=None)

# --- locate the header row ("TIME") and the first country row -------------
time_row = raw.index[raw[0] == "TIME"][0]
years = raw.iloc[time_row, 1::2].dropna().astype(int).tolist()   # 2016 ... 2025
tenure = raw.loc[raw[0] == "Tenure status", 2].iloc[0]
data = raw.iloc[time_row + 2:].copy()                            # skip the empty GEO row

# --- tidy: one row per country-year (values sit in cols 1,3,5...; flags in 2,4,6...)
rows = []
for _, r in data.iterrows():
    geo = r[0]
    if pd.isna(geo):
        continue
    for i, y in enumerate(years):
        val, flag = r[1 + 2 * i], r[2 + 2 * i]
        val = pd.to_numeric(val, errors="coerce")                # ':' becomes NaN
        rows.append({"geo": geo, "year": y, "value": val,
                     "flag": "" if pd.isna(flag) else flag})
df = pd.DataFrame(rows)
df.to_csv("data/housing_overburden_tidy.csv", index=False)           # reuse for later charts

# --- pick the series to plot ------------------------------------------------
EU = "European Union - 27 countries (from 2020)"
series = {"Germany": "Germany", "Italy": "Italy", "Spain": "Spain", EU: "EU-27 average"}
colors = {"Germany": "#C0392B", "Italy": "#7F8C8D", "Spain": "#95A5A6", EU: "#2C3E50"}

fig, ax = plt.subplots(figsize=(10, 6))
for geo, label in series.items():
    s = df[(df.geo == geo)].sort_values("year")
    if s.empty:
        print(f"Warning: '{geo}' not found. Check names in housing_overburden_tidy.csv")
        continue
    is_de = geo == "Germany"
    ax.plot(s.year, s.value, color=colors[geo], linewidth=3.5 if is_de else 2,
            linestyle="--" if geo == EU else "-", marker="o" if is_de else None)
    last = s.dropna(subset=["value"]).iloc[-1]
    ax.text(last.year + 0.12, last.value, f"{label} {last.value:.1f}%",
            color=colors[geo], va="center", fontsize=11, fontweight="bold" if is_de else "normal")

ax.set_title("Germany's mortgage owners are moving the opposite way",
             loc="left", fontsize=16, fontweight="bold")
ax.set_ylabel("% of people spending > 40% of income on housing")
ax.set_xticks(years)
ax.set_xlim(years[0] - 0.2, years[-1] + 1.6)
ax.set_ylim(0)
ax.spines[["top", "right"]].set_visible(False)
fig.text(0.01, 0.01, f"Source: Eurostat EU-SILC (ilc_lvho07c). Group: {tenure}. "
         "Housing cost overburden rate.", fontsize=9, color="gray")
plt.tight_layout(rect=(0, 0.03, 1, 1))
plt.savefig("figures/image1_germany_italy_spain.png", dpi=200)
print("Saved figures/image1_germany_italy_spain.png and data/housing_overburden_tidy.csv")
