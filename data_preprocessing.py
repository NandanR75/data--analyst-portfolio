"""
data_preprocessing.py
Cleans, merges, and feature-engineers Orders.csv + Details.csv
into a single analysis-ready file: Cleaned_Merged.csv

Usage (from Python_Scripts/):
    python data_preprocessing.py
"""

import pandas as pd
import numpy as np
import os

def preprocess(orders_path="../Orders.csv", details_path="../Details.csv",
               out_path="../Cleaned_Merged.csv"):

    print("── Loading ───────────────────────────────────────────")
    if not os.path.exists(orders_path) or not os.path.exists(details_path):
        raise FileNotFoundError("Orders.csv or Details.csv not found.")

    orders  = pd.read_csv(orders_path)
    details = pd.read_csv(details_path)
    print(f"  Orders  : {orders.shape}  |  Details : {details.shape}")

    # 1. Strip whitespace
    for col in orders.select_dtypes('object'):
        orders[col] = orders[col].str.strip()
    for col in details.select_dtypes('object'):
        details[col] = details[col].str.strip()

    # 2. Parse date
    orders['Order Date'] = pd.to_datetime(orders['Order Date'], format='%d-%m-%Y')

    # 3. Drop missing primary keys
    before = len(orders)
    orders.dropna(subset=['Order ID'], inplace=True)
    details.dropna(subset=['Order ID'], inplace=True)
    print(f"  Dropped {before - len(orders)} orders with null Order ID")

    # 4. Remove duplicates
    before = len(details)
    details.drop_duplicates(inplace=True)
    print(f"  Removed {before - len(details)} duplicate detail rows")

    # 5. Merge
    df = orders.merge(details, on='Order ID', how='inner')
    print(f"  Merged  : {df.shape}")

    # 6. Feature engineering
    df['Month']      = df['Order Date'].dt.month
    df['Month_Name'] = df['Order Date'].dt.strftime('%b')
    df['Quarter']    = df['Order Date'].dt.quarter.map({1:'Q1',2:'Q2',3:'Q3',4:'Q4'})
    df['Is_Profit']  = (df['Profit'] > 0).astype(int)
    df['Margin_Pct'] = (df['Profit'] / df['Amount'].replace(0, np.nan) * 100).round(2)

    order_total      = df.groupby('Order ID')['Amount'].sum().rename('Order_Total')
    df               = df.merge(order_total, on='Order ID')

    # 7. Validation report
    print("\n── Validation ────────────────────────────────────────")
    print(f"  Nulls remaining   : {df.isnull().sum().sum()}")
    print(f"  Loss-making rows  : {(df['Profit']<0).sum()} ({(df['Profit']<0).mean()*100:.1f}%)")
    print(f"  Total Revenue     : ₹{df['Amount'].sum():,}")
    print(f"  Total Profit      : ₹{df['Profit'].sum():,}")
    print(f"  Overall Margin    : {df['Profit'].sum()/df['Amount'].sum()*100:.2f}%")

    df.to_csv(out_path, index=False, date_format='%Y-%m-%d')
    print(f"\n✅  Saved → {out_path}  ({df.shape[0]:,} rows × {df.shape[1]} cols)")
    return df

if __name__ == "__main__":
    preprocess()
