import streamlit as st
from config import (
    SQL_PREMIUM_VS_BENCHMARK, SQL_LOSS_RATIO_BY_TYPE,
    SQL_BILLING_SUMMARY, SQL_FRICTION_POINTS,
)
from utils import run_query, fmt_currency, page_header, metric_row, section_header, bar_chart


def render():
    page_header("Pricing Analytics", "Price benchmarking, performance ratios, billing health, and operational friction analysis.")

    df_billing = run_query(SQL_BILLING_SUMMARY)
    total_outstanding = df_billing["TOTAL_OUTSTANDING"].sum()
    total_late_fees = df_billing["TOTAL_LATE_FEES"].sum()
    overdue_count = (
        int(df_billing.loc[df_billing["PAYMENT_STATUS"] == "Overdue", "INVOICE_COUNT"].sum())
        if "Overdue" in df_billing["PAYMENT_STATUS"].values else 0
    )
    df_loss = run_query(SQL_LOSS_RATIO_BY_TYPE)
    avg_loss_ratio = df_loss["AVG_LOSS_RATIO"].mean()

    metric_row([
        ("Avg Loss Ratio", f"{avg_loss_ratio:.3f}", None),
        ("Total Outstanding", fmt_currency(total_outstanding), None),
        ("Total Late Fees", fmt_currency(total_late_fees), None),
        ("Overdue Invoices", str(overdue_count), None),
    ])
    st.divider()

    col1, col2 = st.columns(2)
    with col1:
        section_header("Our Price vs Market Average", "Comparing our average premiums against market benchmarks by policy and tier")
        df_bench = run_query(SQL_PREMIUM_VS_BENCHMARK)
        if not df_bench.empty:
            chart_data = df_bench.melt(
                id_vars=["POLICY_TYPE", "PLAN_TIER"],
                value_vars=["OUR_AVG_PREMIUM", "MARKET_AVG_PREMIUM"],
                var_name="Source", value_name="Premium",
            )
            chart_data["Source"] = chart_data["Source"].replace(
                {"OUR_AVG_PREMIUM": "Our Premium", "MARKET_AVG_PREMIUM": "Market Average"}
            )
            chart_data["Label"] = chart_data["POLICY_TYPE"] + " - " + chart_data["PLAN_TIER"]
            bar_chart(chart_data, x="Label", y="Premium", color="Source")
    with col2:
        section_header("Price Gap (Ours - Market)", "Dollar difference between our premiums and market average per segment")
        if not df_bench.empty:
            df_bench["Label"] = df_bench["POLICY_TYPE"] + " - " + df_bench["PLAN_TIER"]
            bar_chart(df_bench, x="Label", y="PRICE_GAP")

    st.divider()
    section_header("Loss Ratio by Type & Tier", "Average claims-to-premium ratio across active policy segments")
    if not df_loss.empty:
        df_loss["Label"] = df_loss["POLICY_TYPE"] + " - " + df_loss["PLAN_TIER"]
        bar_chart(df_loss, x="Label", y="AVG_LOSS_RATIO")
        high_risk = df_loss[df_loss["AVG_LOSS_RATIO"] > 0.7]
        if not high_risk.empty:
            st.warning(f"{len(high_risk)} segments have loss ratio > 0.7")

    st.divider()
    section_header("Billing by Payment Status", "Outstanding balances and late fees grouped by payment status")
    st.dataframe(df_billing, use_container_width=True, hide_index=True)

    st.divider()
    section_header("Top Operational Friction Points", "Most common claim processing delays and their resolution timelines")
    df_friction = run_query(SQL_FRICTION_POINTS)
    if not df_friction.empty:
        bar_chart(df_friction, x="FRICTION_POINT", y="CLAIM_COUNT")
        st.dataframe(df_friction, use_container_width=True, hide_index=True)
