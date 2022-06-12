# Imports
import pandas as pd
import requests
import os

def report_data(event, context):
  # Data sources
  S3_BUCKET_NAME = os.environ.get("S3_BUCKET_NAME")
  SERIES_DATA = f"https://{S3_BUCKET_NAME}.s3.amazonaws.com/pr.data.0.Current"
  POPULATION_DATA = f"https://{S3_BUCKET_NAME}.s3.amazonaws.com/population-data.json"

  # Load data
  series = pd.read_csv(SERIES_DATA, delimiter="\t")
  r = requests.get(POPULATION_DATA).json()
  population = pd.json_normalize(r, record_path="data")

  # Filter data between [2013, 2018] inclusive
  population_stats = population[(population["Year"].astype(int) >= 2013) &
                                (population["Year"].astype(int) <= 2018)]
  # Display mean and standard deviation of population
  print(population_stats["Population"].mean(), population_stats["Population"].std())

  # Remove columns names whitespace
  series.rename(columns={"series_id        ": "series_id"}, inplace=True)
  series.rename(columns={"       value": "value"}, inplace=True)
  # Generate report
  max_value_series = series.groupby(["series_id", "year"], as_index=False)["value"].agg("sum")
  max_value_series = max_value_series.sort_values("value", ascending=False).drop_duplicates("series_id", keep="first").sort_index().reset_index(drop=True)
  print(max_value_series)
  
  # Filter series data
  specific_series = series.loc[series["series_id"].str.contains("PRS30006032", case=False)]
  specific_series = specific_series[specific_series["period"].str.contains("Q01", case=False)]
  # Filter population data
  population_extract = population["Population"].astype(int)
  population["Year"] = population["Year"].astype(int)
  # Merge and filter results
  result = pd.merge(specific_series, population, left_on="year", right_on="Year", how="left")
  print(result[["series_id", "year", "period", "value", "Population"]])
  
  return "Data processing complete."
