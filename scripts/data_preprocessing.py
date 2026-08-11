"""
data_preprocessing.py
Cleans and feature-engineers HR_Analytics.csv into analysis-ready form.

Usage (from Python_Scripts/):
    python data_preprocessing.py
Output:
    ../HR_Analytics_Cleaned.csv
"""

import pandas as pd
import numpy as np
import os

def preprocess(in_path="../HR_Analytics.csv", out_path="../HR_Analytics_Cleaned.csv"):

    print("── Loading ───────────────────────────────────────────")
    if not os.path.exists(in_path):
        raise FileNotFoundError(f"{in_path} not found. Run from Python_Scripts/.")

    df = pd.read_csv(in_path)
    print(f"  Raw shape : {df.shape}")

    # 1. Strip string whitespace
    for col in df.select_dtypes('object'):
        df[col] = df[col].str.strip()

    # 2. Drop constant / redundant columns
    constant_cols = [c for c in df.columns if df[c].nunique() <= 1]
    df.drop(columns=constant_cols, inplace=True)
    print(f"  Dropped constant columns : {constant_cols}")

    # 3. Handle missing values
    missing_before = df.isnull().sum().sum()
    df['YearsWithCurrManager'].fillna(df['YearsWithCurrManager'].median(), inplace=True)
    print(f"  Filled {missing_before} missing values (YearsWithCurrManager → median)")

    # 4. Attrition binary flag
    df['Attrition_Flag'] = (df['Attrition'] == 'Yes').astype(int)

    # 5. Composite satisfaction score
    df['Satisfaction_Score'] = df[['JobSatisfaction','EnvironmentSatisfaction',
                                     'WorkLifeBalance','RelationshipSatisfaction']].mean(axis=1).round(2)

    # 6. Tenure band
    df['Tenure_Band'] = pd.cut(df['YearsAtCompany'],
                                 bins=[-1,2,5,10,20,100],
                                 labels=['0-2 yrs','3-5 yrs','6-10 yrs','11-20 yrs','20+ yrs'])

    # 7. Income band
    df['Income_Band'] = pd.cut(df['MonthlyIncome'],
                                 bins=[0,3000,6000,10000,20000],
                                 labels=['Low','Mid','High','Very High'])

    # 8. Promotion recency flag
    df['No_Recent_Promotion'] = (df['YearsSinceLastPromotion'] >= 3).astype(int)

    # 9. Validation
    print("\n── Validation ────────────────────────────────────────")
    print(f"  Final shape         : {df.shape}")
    print(f"  Nulls remaining     : {df.isnull().sum().sum()}")
    print(f"  Total employees     : {len(df):,}")
    print(f"  Attrition count     : {df['Attrition_Flag'].sum()} ({df['Attrition_Flag'].mean()*100:.1f}%)")
    print(f"  Avg monthly income  : ${df['MonthlyIncome'].mean():,.0f}")
    print(f"  Overtime workers    : {(df['OverTime']=='Yes').mean()*100:.1f}%")

    df.to_csv(out_path, index=False)
    print(f"\n✅  Saved → {out_path}  ({df.shape[0]:,} rows × {df.shape[1]} cols)")
    return df

if __name__ == "__main__":
    preprocess()
