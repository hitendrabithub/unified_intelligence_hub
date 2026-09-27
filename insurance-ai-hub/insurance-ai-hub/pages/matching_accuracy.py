import streamlit as st
from config import (
    SQL_ACCEPTANCE_RATE, SQL_ACCEPTANCE_BY_PRODUCT,
    SQL_SCORE_DISTRIBUTION, SQL_REC_BY_STATUS,
)
from utils import run_query, fmt_pct, page_header, metric_row, section_header, bar_chart


def render():
    page_header("Recommendation Analytics", "Acceptance rates, match score analysis, and product performance.")

    df_kpi_m = run_query(SQL_ACCEPTANCE_RATE)
    df_status = run_query(SQL_REC_BY_STATUS)
    total_recs = int(df_status["CNT"].sum()) if not df_status.empty else 0
    if not df_kpi_m.empty:
        row = df_kpi_m.iloc[0]
        metric_row([
            ("Acceptance Rate", fmt_pct(row["ACCEPTANCE_RATE_PCT"]), None),
            ("Avg Feedback Rating", f"{row['AVG_RATING']:.2f} / 5", None),
            ("Total Feedback", str(int(row["TOTAL_FEEDBACK"])), None),
            ("Total Recommendations", str(total_recs), None),
        ])
    st.divider()

    mc1, mc2 = st.columns(2)
    with mc1:
        section_header("Match Score Distribution", "How recommendation scores are spread across scoring ranges")
        df_scores = run_query(SQL_SCORE_DISTRIBUTION)
        if not df_scores.empty:
            bar_chart(df_scores, x="SCORE_RANGE", y="REC_COUNT")
    with mc2:
        section_header("Recommendations by Status", "Current state of all generated recommendations")
        if not df_status.empty:
            bar_chart(df_status, x="STATUS", y="CNT")

    st.divider()
    section_header("Product Performance", "Acceptance rates and match scores ranked by product")
    df_products = run_query(SQL_ACCEPTANCE_BY_PRODUCT)
    if not df_products.empty:
        st.dataframe(df_products, use_container_width=True, hide_index=True)
        st.divider()
        pc1, pc2 = st.columns(2)
        with pc1:
            section_header("Acceptance Rate by Product", "Percentage of recommendations accepted per product")
            bar_chart(df_products, x="PRODUCT_NAME", y="ACCEPTANCE_RATE")
        with pc2:
            section_header("Avg Match Score by Product", "Average recommendation confidence score per product")
            bar_chart(df_products, x="PRODUCT_NAME", y="AVG_MATCH_SCORE")
