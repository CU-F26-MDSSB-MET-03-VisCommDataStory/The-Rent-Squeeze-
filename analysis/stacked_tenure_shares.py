"""
Stacked bar chart: housing tenure shares by country (who rents, who owns).
Context chart for the Rent Squeeze story: how large is each group?

Run from the repo root, AFTER analysis/fetch_eurostat_data.py:
    python analysis/stacked_tenure_shares.py            # all countries, 2025
    python analysis/stacked_tenure_shares.py 2024       # another year
    python analysis/stacked_tenure_shares.py 2025 focus # only DE, IT, ES + EU-27

Reads  data/eurostat_tenure_shares.csv  (Eurostat ilc_lvho02)
Writes visualisations/stacked_tenure_shares_<year>.png
"""
import os
import sys
import pandas as pd
import matplotlib.pyplot as plt

year = int(sys.argv[1]) if len(sys.argv) > 1 else 2025
focus = len(sys.argv) > 2 and sys.argv[2] == "focus"
CSV = os.environ.get("TENURE_CSV", "data/eurostat_tenure_shares.csv")

NAMES = {"AT": "Austria", "BE": "Belgium", "BG": "Bulgaria", "CH": "Switzerland",
         "CY": "Cyprus", "CZ": "Czechia", "DE": "Germany", "DK": "Denmark",
         "EE": "Estonia", "EL": "Greece", "ES": "Spain", "FI": "Finland",
         "FR": "France", "HR": "Croatia", "HU": "Hungary", "IE": "Ireland",
         "IS": "Iceland", "IT": "Italy", "LT": "Lithuania", "LU": "Luxembourg",
         "LV": "Latvia", "MT": "Malta", "NL": "Netherlands", "NO": "Norway",
         "PL": "Poland", "PT": "Portugal", "RO": "Romania", "SE": "Sweden",
         "SI": "Slovenia", "SK": "Slovakia", "EU27_2020": "EU-27 average"}
# order of the stack, left to right, with the team's colours
GROUPS = [("OWN_NL", "Owners without mortgage", "#B5BCC3"),
          ("OWN_L", "Owners with mortgage", "#2A9D8F"),
          ("RENT_MKT", "Market-price renters", "#E76F51"),
          ("RENT_FR", "Reduced/free renters", "#F4C7B8")]

df = pd.read_csv(CSV)
print("columns:", df.columns.tolist())
print("tenure codes found:", sorted(df["tenure"].unique()))
d = df[(df.year == year) & (df.tenure.isin([g[0] for g in GROUPS]))
       & (df.geo.isin(NAMES))]
if d.duplicated(["geo", "tenure"]).any():
    sys.exit("Several rows per country and tenure. Re-run analysis/fetch_eurostat_data.py "
             "(the CSV still mixes income and household groups).")
wide = d.pivot_table(index="geo", columns="tenure", values="value")
missing = [g[0] for g in GROUPS if g[0] not in wide.columns]
if missing:
    sys.exit(f"Missing tenure codes {missing}. Compare with the codes printed above.")
wide = wide[[g[0] for g in GROUPS]].dropna()
wide["total"] = wide.sum(axis=1)
print(wide["total"].round(1).to_string())          # should be close to 100
wide = wide[(wide.total > 97) & (wide.total < 103)]
if focus:
    wide = wide.loc[[c for c in ["DE", "IT", "ES", "EU27_2020"] if c in wide.index]]
wide["tenants"] = wide["RENT_MKT"] + wide["RENT_FR"]
wide = wide.sort_values("tenants")                  # most tenants at the top
if wide.empty:
    sys.exit(f"No complete rows for {year}. Try another year.")

fig, ax = plt.subplots(figsize=(11, 5 if focus else 10))
left = pd.Series(0.0, index=wide.index)
for code, label, colour in GROUPS:
    ax.barh([NAMES[g] for g in wide.index], wide[code], left=left,
            color=colour, label=label, height=0.8)
    if focus or code in ("OWN_L", "RENT_MKT"):
        for g, v, l in zip(wide.index, wide[code], left):
            if g in ("DE", "IT", "ES", "EU27_2020") and v >= 4:
                ax.text(l + v / 2, NAMES[g], f"{v:.1f}%", ha="center",
                        va="center", fontsize=8, color="#222222")
    left = left + wide[code]

for tick in ax.get_yticklabels():
    if tick.get_text() in ("Germany", "EU-27 average"):
        tick.set_fontweight("bold")
ax.set_xlim(0, 100)
ax.set_xlabel("Share of population (%)")
ax.set_title("Who Rents and Who Owns? Housing Tenure Across Europe",
             loc="left", fontsize=15, fontweight="bold", pad=26)
ax.text(0, 1.012, f"Share of the population by tenure status, sorted by share of tenants ({year})",
        transform=ax.transAxes, fontsize=10, va="bottom")
ax.spines[["top", "right"]].set_visible(False)
ax.legend(ncol=4, loc="upper center", bbox_to_anchor=(0.5, -0.07), frameon=False)
fig.text(0.01, 0.005, "Source: Eurostat (ilc_lvho02), total population, all household types",
         fontsize=8, color="gray")
plt.tight_layout(rect=(0, 0.02, 1, 0.97))
os.makedirs("visualisations", exist_ok=True)
out = f"visualisations/stacked_tenure_shares_{year}{'_focus' if focus else ''}.png"
plt.savefig(out, dpi=200)
print("Saved", out)
