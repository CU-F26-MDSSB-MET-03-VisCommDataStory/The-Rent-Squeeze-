"""
Fetch two Eurostat tables and save tidy CSVs in data/.
  ilc_lvho07c : housing cost overburden rate by tenure status
  ilc_lvho02  : distribution of population by tenure status (shares)

Run from the repo root:
    pip install eurostat pandas
    python analysis/fetch_eurostat_data.py
"""
import os
import pandas as pd
import eurostat

os.makedirs("data", exist_ok=True)


def tidy(code, id_cols_keep=None):
    df = eurostat.get_data_df(code)
    print(f"\n{code}: columns = {df.columns.tolist()}")
    geo_col = next(c for c in df.columns if c.lower().startswith("geo"))
    year_cols = [c for c in df.columns if str(c).isdigit()]
    id_cols = [c for c in df.columns if c not in year_cols]
    long = df.melt(id_vars=id_cols, value_vars=year_cols,
                   var_name="year", value_name="value")
    long = long.rename(columns={geo_col: "geo"})
    long["year"] = long["year"].astype(int)
    return long.dropna(subset=["value"])


# 1) overburden rate by tenure
ob = tidy("ilc_lvho07c")
ob.to_csv("data/eurostat_overburden_by_tenure.csv", index=False)
print(ob.head())
print("tenure codes:", sorted(ob["tenure"].unique()))

# 2) tenure shares (total population, all household types)
sh = tidy("ilc_lvho02")
# keep total population: all household types, all income groups
# (this table calls them 'rskpovth' and 'hhcomp'; older versions: 'incgrp', 'hhtyp')
for col in ["rskpovth", "incgrp", "hhcomp", "hhtyp"]:
    if col in sh.columns:
        print(col, "values:", sorted(sh[col].unique()))
        sh = sh[sh[col] == "TOTAL"]
dups = sh.duplicated(["geo", "tenure", "year", "unit"]).sum()
print("duplicate geo/tenure/year rows after filtering (should be 0):", dups)
sh.to_csv("data/eurostat_tenure_shares.csv", index=False)
print(sh.head())
print("tenure codes:", sorted(sh["tenure"].unique()))
print("\nSaved data/eurostat_overburden_by_tenure.csv and data/eurostat_tenure_shares.csv")
