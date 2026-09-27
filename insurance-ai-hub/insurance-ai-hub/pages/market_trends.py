import streamlit as st
from config import SQL_MARKET_TRENDS, SQL_AT_RISK_SUMMARY, SQL_AT_RISK_KPI
from utils import run_query, fmt_currency, fmt_pct, page_header, metric_row, section_header, bar_chart, line_chart


def render():
    page_header("Market Intelligence", "Time-series indicators, at-risk account analysis, and retention opportunities.")

    df_kpi = run_query(SQL_AT_RISK_KPI)
    if not df_kpi.empty:
        row = df_kpi.iloc[0]
        metric_row([
            ("At-Risk Accounts", str(int(row["TOTAL_AT_RISK"])), None),
            ("Revenue at Risk", fmt_currency(row["TOTAL_REVENUE_AT_RISK"]), None),
            ("Avg Churn Probability", fmt_pct(row["AVG_CHURN_PROB"] * 100), None),
            ("Avg Days Since Contact", str(int(row["AVG_DAYS_SINCE_CONTACT"])), None),
        ])
    st.divider()

    section_header("Market Trend Indicators", "Key metric trends over time, filterable by region")
    df_trends = run_query(SQL_MARKET_TRENDS)
    if not df_trends.empty:
        metrics = sorted(df_trends["METRIC_NAME"].unique())
        f1, f2 = st.columns(2)
        with f1:
            selected_metric = st.selectbox("Select Metric", metrics, index=0)
        df_f = df_trends[df_trends["METRIC_NAME"] == selected_metric]
        regions = sorted(df_f["REGION"].unique())
        with f2:
            selected_regions = st.multiselect("Filter by Region", regions, default=regions)
        df_f = df_f[df_f["REGION"].isin(selected_regions)]
        if not df_f.empty:
            line_chart(df_f, x="PERIOD_DATE", y="METRIC_VALUE", color="REGION")
            latest = df_f.sort_values("PERIOD_DATE").groupby("REGION").last().reset_index()
            st.caption("Latest period values:")
            lcols = st.columns(len(latest))
            for i, (_, r) in enumerate(latest.iterrows()):
                delta_str = f"{r['CHANGE_PCT']:+.1f}%" if r["CHANGE_PCT"] else None
                lcols[i].metric(r["REGION"], f"{r['METRIC_VALUE']:.2f}", delta_str)

    st.divider()
    section_header("Revenue at Risk by Category", "Total revenue exposure broken down by risk classification")
    df_risk = run_query(SQL_AT_RISK_SUMMARY)
    if not df_risk.empty:
        bar_chart(df_risk, x="RISK_CATEGORY", y="TOTAL_REVENUE_AT_RISK")
        st.dataframe(df_risk, use_container_width=True, hide_index=True)
