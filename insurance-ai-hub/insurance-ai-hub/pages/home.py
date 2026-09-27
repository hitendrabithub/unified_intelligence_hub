import streamlit as st
from config import (
    SQL_AT_RISK_KPI, SQL_ACCEPTANCE_RATE, SQL_BILLING_SUMMARY,
    SQL_DQ_KPI, SQL_HOME_ACTIVE_POLICIES, SQL_HOME_HIGH_RISK_SEGMENTS,
    SQL_HOME_CRITICAL_DQ_ISSUES, SQL_HOME_TOP_AT_RISK, SQL_HOME_REC_SUMMARY,
    SQL_LOSS_RATIO_BY_TYPE,
)
from utils import run_query, fmt_currency, fmt_pct, page_header, metric_row, section_header, bar_chart


def render():
    page_header("Executive Overview", "Cross-domain health snapshot across pricing, market, recommendations, and data quality.")

    # ── Row 1: Top-level KPIs ──
    df_policies = run_query(SQL_HOME_ACTIVE_POLICIES)
    df_atrisk = run_query(SQL_AT_RISK_KPI)
    df_accept = run_query(SQL_ACCEPTANCE_RATE)
    df_dq = run_query(SQL_DQ_KPI)

    cols = st.columns(4)
    if not df_policies.empty:
        r = df_policies.iloc[0]
        cols[0].metric("Total Premium Book", fmt_currency(r["TOTAL_PREMIUM_BOOK"]))
        cols[1].metric("Active Policies", f"{int(r['ACTIVE_POLICIES']):,}")
    if not df_atrisk.empty:
        r = df_atrisk.iloc[0]
        cols[2].metric("Revenue at Risk", fmt_currency(r["TOTAL_REVENUE_AT_RISK"]))
    if not df_dq.empty:
        r = df_dq.iloc[0]
        cols[3].metric("DQ Score", f"{r['AVG_SCORE']:.1f} / 100")

    cols2 = st.columns(4)
    if not df_atrisk.empty:
        r = df_atrisk.iloc[0]
        cols2[0].metric("At-Risk Accounts", str(int(r["TOTAL_AT_RISK"])))
        cols2[1].metric("Avg Churn Probability", fmt_pct(r["AVG_CHURN_PROB"] * 100))
    if not df_accept.empty:
        r = df_accept.iloc[0]
        cols2[2].metric("Recommendation Acceptance", fmt_pct(r["ACCEPTANCE_RATE_PCT"]))
    if not df_dq.empty:
        r = df_dq.iloc[0]
        cols2[3].metric("Failed DQ Rules", str(int(r["TOTAL_FAILURES"])))

    st.divider()

    # ── Row 2: Alerts & Warnings (pulse dots added via CSS) ──
    section_header("Alerts & Warnings", "Items requiring immediate attention across all domains")

    df_loss = run_query(SQL_LOSS_RATIO_BY_TYPE)
    df_billing = run_query(SQL_BILLING_SUMMARY)
    df_crit_dq = run_query(SQL_HOME_CRITICAL_DQ_ISSUES)

    alert_col1, alert_col2 = st.columns(2)

    with alert_col1:
        if not df_loss.empty:
            high_risk = df_loss[df_loss["AVG_LOSS_RATIO"] > 0.7]
            if not high_risk.empty:
                st.warning(f"**Pricing:** {len(high_risk)} policy segments have loss ratio above 0.7")

        if not df_billing.empty and "Overdue" in df_billing["PAYMENT_STATUS"].values:
            overdue = df_billing.loc[df_billing["PAYMENT_STATUS"] == "Overdue"]
            overdue_count = int(overdue["INVOICE_COUNT"].sum())
            overdue_amt = overdue["TOTAL_OUTSTANDING"].sum()
            if overdue_count > 0:
                st.warning(f"**Billing:** {overdue_count} overdue invoices totaling {fmt_currency(overdue_amt)}")

    with alert_col2:
        if not df_crit_dq.empty:
            st.error(f"**Data Quality:** {len(df_crit_dq)} critical rules failing -- lowest pass rate: {df_crit_dq.iloc[0]['PASS_RATE']:.1f}%")
        else:
            st.success("**Data Quality:** All critical rules passing")

        if not df_atrisk.empty:
            r = df_atrisk.iloc[0]
            if r["TOTAL_AT_RISK"] > 0:
                st.warning(f"**Market:** {int(r['TOTAL_AT_RISK'])} accounts at risk with {fmt_currency(r['TOTAL_REVENUE_AT_RISK'])} revenue exposure")

    st.divider()

    # ── Row 3: Key charts ──
    c1, c2 = st.columns(2)

    with c1:
        section_header("Revenue at Risk by Category", "Top risk segments by total revenue exposure")
        df_risk = run_query(SQL_HOME_TOP_AT_RISK)
        if not df_risk.empty:
            bar_chart(df_risk, x="RISK_CATEGORY", y="REVENUE_AT_RISK")

    with c2:
        section_header("Recommendation Pipeline", "Current status breakdown of all recommendations")
        df_rec = run_query(SQL_HOME_REC_SUMMARY)
        if not df_rec.empty:
            r = df_rec.iloc[0]
            r1c1, r1c2 = st.columns(2)
            r1c1.metric("Total", f"{int(r['TOTAL_RECS']):,}")
            r1c2.metric("Accepted", f"{int(r['ACCEPTED']):,}")
            r2c1, r2c2 = st.columns(2)
            r2c1.metric("Pending", f"{int(r['PENDING']):,}")
            r2c2.metric("Rejected", f"{int(r['REJECTED']):,}")

    st.divider()

    # ── Row 4: Tables stacked vertically ──
    section_header("High-Risk Policy Segments", "Active segments with loss ratio above 0.7")
    df_high_risk = run_query(SQL_HOME_HIGH_RISK_SEGMENTS)
    if not df_high_risk.empty:
        st.dataframe(df_high_risk, use_container_width=True, hide_index=True)
    else:
        st.success("No high-risk segments detected.")

    st.divider()

    section_header("Critical DQ Failures", "Critical rules currently failing validation")
    if not df_crit_dq.empty:
        st.dataframe(df_crit_dq, use_container_width=True, hide_index=True)
    else:
        st.success("All critical rules passing.")
