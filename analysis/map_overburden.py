"""
Map of Europe: housing cost overburden rate by country (Eurostat ilc_lvho07c).

Run from the repo root, after analysis/fetch_eurostat_data.py:
    pip install geopandas matplotlib pandas
    python analysis/map_overburden.py                 # market-price renters, 2025
    python analysis/map_overburden.py OWN_L 2025      # owners with a mortgage

Tenure codes: RENT_MKT, OWN_L, OWN_NL, RENT_FR, TOTAL
Needs data/eurostat_overburden_by_tenure.csv and data/europe_countries.geojson
(country outlines from Natural Earth, public domain; clipped to Europe).
Writes visualisations/map_overburden_<tenure>_<year>.png
"""
import os
import sys
import numpy as np
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
from matplotlib import cm, colors

tenure = sys.argv[1] if len(sys.argv) > 1 else "RENT_MKT"
year = int(sys.argv[2]) if len(sys.argv) > 2 else 2025
LABEL = {"RENT_MKT": "market-price renters", "OWN_L": "owners with a mortgage",
         "OWN_NL": "owners without a mortgage", "RENT_FR": "reduced-price or free renters",
         "TOTAL": "all households"}
CAP = 40   # colour scale stops at 40% so Romania (56%) does not wash out the rest

# Eurostat geo code -> ISO-3 used in the outline file (EL = Greece, UK = United Kingdom)
ISO3 = {"AT": "AUT", "BE": "BEL", "BG": "BGR", "CH": "CHE", "CY": "CYP", "CZ": "CZE",
        "DE": "DEU", "DK": "DNK", "EE": "EST", "EL": "GRC", "ES": "ESP", "FI": "FIN",
        "FR": "FRA", "HR": "HRV", "HU": "HUN", "IE": "IRL", "IS": "ISL", "IT": "ITA",
        "LT": "LTU", "LU": "LUX", "LV": "LVA", "MT": "MLT", "NL": "NLD", "NO": "NOR",
        "PL": "POL", "PT": "PRT", "RO": "ROU", "RS": "SRB", "SE": "SWE", "SI": "SVN",
        "SK": "SVK", "TR": "TUR", "UK": "GBR", "AL": "ALB", "ME": "MNE", "MK": "MKD",
        "BA": "BIH", "XK": "KOS"}
LABELLED = ["DEU", "ITA", "ESP", "ROU", "NLD", "FIN", "FRA", "POL"]

df = pd.read_csv("data/eurostat_overburden_by_tenure.csv")
d = df[(df.tenure == tenure) & (df.year == year)].copy()
d["iso3"] = d["geo"].map(ISO3)
d = d.dropna(subset=["iso3"])                 # drops aggregates such as EU27_2020
if d.empty:
    sys.exit(f"No rows for tenure={tenure}, year={year}. Check the CSV.")
eu = df[(df.tenure == tenure) & (df.year == year) & (df.geo == "EU27_2020")]["value"]

shapes = gpd.read_file("data/europe_countries.geojson")
m = shapes.merge(d[["iso3", "value"]], on="iso3", how="left")

fig, ax = plt.subplots(figsize=(10, 8))
norm = colors.Normalize(vmin=0, vmax=CAP)
cmap = plt.get_cmap("YlOrRd")
m[m.value.isna()].plot(ax=ax, color="#e6e6e6", edgecolor="white", linewidth=0.4)
m[m.value.notna()].plot(ax=ax, column="value", cmap=cmap, norm=norm,
                        edgecolor="white", linewidth=0.5)
for _, r in m[m.iso3.isin(LABELLED) & m.value.notna()].iterrows():
    p = r.geometry.representative_point()
    ax.text(p.x, p.y, f"{r.value:.1f}%", ha="center", va="center", fontsize=8,
            fontweight="bold", color="white" if r.value > 30 else "#222222")
ax.set_xlim(-25, 42)
ax.set_ylim(34, 71.5)
ax.set_aspect(1 / np.cos(np.radians(52)))     # stretch so Europe is not squashed
ax.axis("off")
sm = cm.ScalarMappable(norm=norm, cmap=cmap)
cb = fig.colorbar(sm, ax=ax, shrink=0.55, extend="max", pad=0.01)
cb.set_label("% of people over the 40% line (scale capped at 40%)")
sub = f"Share of people in households spending more than 40% of disposable income on housing ({year})"
if len(eu):
    sub += f". EU-27 average: {eu.iloc[0]:.1f}%"
ax.set_title(f"Housing-cost overburden among {LABEL.get(tenure, tenure)}",
             loc="left", fontsize=15, fontweight="bold", pad=22)
ax.text(0, 1.012, sub, transform=ax.transAxes, fontsize=9, va="bottom")
fig.text(0.01, 0.01, "Source: Eurostat (ilc_lvho07c). Grey = no data. "
         "Outlines: Natural Earth.", fontsize=8, color="gray")
os.makedirs("visualisations", exist_ok=True)
out = f"visualisations/map_overburden_{tenure}_{year}.png"
plt.savefig(out, dpi=200, bbox_inches="tight")
print("Saved", out)
