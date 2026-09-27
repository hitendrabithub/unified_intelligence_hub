import streamlit as st
import json
from config import SQL_DQ_SCORES_TREND, SQL_DQ_FAILED_RULES, SQL_COLUMN_HEALTH, SQL_DQ_KPI
from utils import run_query, fmt_pct, page_header, metric_row, section_header, get_session, bar_chart, line_chart

DQ_AGENT_FQN = "INSURANCE_AI_HUB.ANALYTICS.DATA_QUALITY_AGENT"


def render():
    page_header("Data Quality Health", "Quality score trends, failed rule drill-down, and column health assessment.")

    df_kpi_dq = run_query(SQL_DQ_KPI)
    if not df_kpi_dq.empty:
        row = df_kpi_dq.iloc[0]
        total_rules = int(row["TOTAL_PASSED"]) + int(row["TOTAL_FAILURES"])
        pass_rate = (row["TOTAL_PASSED"] / total_rules * 100) if total_rules > 0 else 0
        metric_row([
            ("Avg DQ Score", f"{row['AVG_SCORE']:.1f} / 100", None),
            ("Rules Passing", fmt_pct(pass_rate), None),
            ("Failed Rules (Latest)", str(int(row["TOTAL_FAILURES"])), None),
            ("Total Rules Evaluated", str(total_rules), None),
        ])
    st.divider()

    section_header("Quality Score Trends by Table", "Track overall and dimensional quality scores over time")
    df_dq_scores = run_query(SQL_DQ_SCORES_TREND)
    if not df_dq_scores.empty:
        tables = sorted(df_dq_scores["TABLE_NAME"].unique())
        selected_tables = st.multiselect("Select Tables", tables, default=tables)
        df_dq_f = df_dq_scores[df_dq_scores["TABLE_NAME"].isin(selected_tables)]
        if not df_dq_f.empty:
            line_chart(df_dq_f, x="SCORE_DATE", y="OVERALL_SCORE", color="TABLE_NAME")

            dimension = st.selectbox(
                "Score Dimension",
                ["OVERALL_SCORE", "COMPLETENESS_SCORE", "ACCURACY_SCORE", "CONSISTENCY_SCORE"],
            )
            line_chart(df_dq_f, x="SCORE_DATE", y=dimension, color="TABLE_NAME")

    st.divider()
    section_header("Failed Rules Detail", "Rules that failed validation in the latest execution run")
    df_failed = run_query(SQL_DQ_FAILED_RULES)
    if not df_failed.empty:
        st.dataframe(df_failed, use_container_width=True, hide_index=True)
    else:
        st.success("All rules passing -- no failures detected.")

    st.divider()
    section_header("Failures by Table", "Number of failed rules per target table")
    if not df_failed.empty:
        by_table = df_failed.groupby("TARGET_TABLE").size().reset_index(name="FAILURES")
        bar_chart(by_table, x="TARGET_TABLE", y="FAILURES")

    st.divider()
    section_header("Column Health Assessment", "Critical columns flagged for null, duplicate, or outlier issues")
    df_health = run_query(SQL_COLUMN_HEALTH)
    if not df_health.empty:
        critical = df_health[df_health["IS_CRITICAL"] == True]
        if not critical.empty:
            unhealthy = critical[critical["HEALTH_STATUS"] != "Healthy"]
            if not unhealthy.empty:
                st.warning(
                    f"{len(unhealthy)} critical column(s) are not healthy: "
                    + ", ".join(unhealthy["TABLE_NAME"] + "." + unhealthy["COLUMN_NAME"])
                )
        st.dataframe(df_health, use_container_width=True, hide_index=True)

    # DQ AI Assistant
    st.divider()
    st.subheader("🤖 DQ Assistant")
    st.caption("Ask questions about data quality -- scores, failed rules, column health, root-cause analysis.")

    if "dq_messages" not in st.session_state:
        st.session_state.dq_messages = []
    if "dq_input_key" not in st.session_state:
        st.session_state.dq_input_key = 0

    for msg in st.session_state.dq_messages:
        with st.chat_message(msg["role"]):
            st.markdown(msg["content"])

    if st.session_state.dq_messages and st.session_state.dq_messages[-1]["role"] == "user":
        user_text = st.session_state.dq_messages[-1]["content"]
        with st.chat_message("assistant"):
            with st.spinner("Analyzing..."):
                try:
                    session = get_session()
                    session.sql("ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 300").collect()
                    history = []
                    for m in st.session_state.dq_messages:
                        if m["role"] == "user":
                            history.append({"role": "user", "content": [{"type": "text", "text": m["content"]}]})
                        elif m["role"] == "assistant":
                            history.append({"role": "assistant", "content": [{"type": "text", "text": m["content"]}]})
                    if len(history) > 6:
                        history = history[-6:]
                    msg_payload = json.dumps({"messages": history})
                    result = session.sql(
                        "SELECT PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(?, ?)) AS resp",
                        params=[DQ_AGENT_FQN, msg_payload],
                    ).collect()
                    response = json.loads(result[0]["RESP"])
                    parts = []
                    for item in response.get("content", []):
                        if item.get("type") == "text":
                            parts.append(item["text"])
                    answer = "\n\n".join(parts) if parts else "No response received."
                except Exception as e:
                    answer = f"An error occurred: {str(e)}"
        st.session_state.dq_messages.append({"role": "assistant", "content": answer})
        st.rerun()

    dq_suggestions = [
        "Why did the quality score drop for CUSTOMERS?",
        "Which rules are currently failing?",
        "Show column health for the worst table",
    ]
    if not st.session_state.dq_messages:
        cols = st.columns(len(dq_suggestions))
        for i, s in enumerate(dq_suggestions):
            if cols[i].button(s, key=f"dq_sug_{i}", use_container_width=True):
                st.session_state.dq_messages.append({"role": "user", "content": s})
                st.rerun()

    with st.form(key=f"dq_form_{st.session_state.dq_input_key}", clear_on_submit=True):
        input_col, btn_col = st.columns([6, 1])
        with input_col:
            dq_prompt = st.text_input(
                "Ask about data quality...",
                key=f"dq_chat_input_{st.session_state.dq_input_key}",
                label_visibility="collapsed",
                placeholder="Ask about data quality...",
            )
        with btn_col:
            submitted = st.form_submit_button("Clear", use_container_width=True)

    if submitted and not dq_prompt:
        st.session_state.pop("dq_messages", None)
        st.session_state.dq_input_key += 1
        st.rerun()

    if submitted and dq_prompt:
        st.session_state.dq_messages.append({"role": "user", "content": dq_prompt})
        st.session_state.dq_input_key += 1
        st.rerun()
