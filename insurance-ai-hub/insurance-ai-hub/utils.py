import streamlit as st
import json
import os
import altair as alt
from config import AGENT_FQN

CONN_TTL = 14400  # 4 hours in seconds
QUERY_TTL = 14400


def get_conn():
    return st.connection("snowflake", ttl=CONN_TTL)


def get_session():
    return get_conn().session()


@st.cache_data(ttl=QUERY_TTL, show_spinner=False)
def run_query(sql):
    return get_conn().query(sql)


def call_agent(messages):
    session = get_session()
    session.sql("ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 300").collect()
    msg_payload = json.dumps({"messages": messages})
    result = session.sql(
        "SELECT PARSE_JSON(SNOWFLAKE.CORTEX.DATA_AGENT_RUN(?, ?)) AS resp",
        params=[AGENT_FQN, msg_payload],
    ).collect()
    return json.loads(result[0]["RESP"])


def extract_text(response):
    parts = []
    for item in response.get("content", []):
        if item.get("type") == "text":
            parts.append(item["text"])
    return "\n\n".join(parts) if parts else ""


def extract_charts(response):
    charts = []
    for item in response.get("content", []):
        if item.get("type") == "chart":
            spec_str = item.get("chart", {}).get("chart_spec", "")
            if spec_str:
                try:
                    charts.append(json.loads(spec_str))
                except json.JSONDecodeError:
                    pass
    return charts


def extract_suggestions(response):
    for item in response.get("content", []):
        if item.get("type") == "suggested_queries":
            return [q["query"] for q in item.get("suggested_queries", [])]
    return []


def fmt_currency(val):
    if val is None:
        return "$0.00"
    if abs(val) >= 1_000_000:
        return f"${val / 1_000_000:,.1f}M"
    if abs(val) >= 1_000:
        return f"${val / 1_000:,.1f}K"
    return f"${val:,.2f}"


def fmt_pct(val, decimals=1):
    if val is None:
        return "0%"
    return f"{val:.{decimals}f}%"


def metric_row(cols_data):
    cols = st.columns(len(cols_data))
    for col, (label, value, delta) in zip(cols, cols_data):
        col.metric(label, value, delta)


def page_header(title, subtitle):
    st.header(title)
    st.caption(subtitle)


def section_header(title, subtitle=None):
    st.subheader(title)
    if subtitle:
        st.caption(subtitle)


GRID_COLOR = "#C8CED6"
Y_AXIS = alt.Axis(grid=True, gridColor=GRID_COLOR, gridDash=[3, 3])
X_AXIS_NOGRID = alt.Axis(grid=False)
X_AXIS_GRID = alt.Axis(grid=True, gridColor=GRID_COLOR, gridDash=[3, 3])
BAR_COLOR = "#635BFF"
LINE_COLORS = ["#635BFF", "#00B4D8", "#F5A623", "#ED5F74", "#00D4AA", "#9C27B0"]


def bar_chart(df, x, y, color=None, height=350):
    x_enc = alt.X(f"{x}:N", title=x.replace("_", " ").title(), axis=X_AXIS_NOGRID)
    y_enc = alt.Y(f"{y}:Q", title=y.replace("_", " ").title(), axis=Y_AXIS)
    enc = {"x": x_enc, "y": y_enc}
    mark_kw = dict(cornerRadiusTopLeft=4, cornerRadiusTopRight=4)
    if color:
        enc["color"] = alt.Color(f"{color}:N", title=color.replace("_", " ").title(),
                                  scale=alt.Scale(range=LINE_COLORS))
    else:
        mark_kw["color"] = BAR_COLOR
    chart = alt.Chart(df).mark_bar(**mark_kw).encode(**enc).properties(height=height)
    st.altair_chart(chart, use_container_width=True)


def line_chart(df, x, y, color=None, height=350):
    x_type = "T" if "DATE" in x.upper() or "PERIOD" in x.upper() else "N"
    x_enc = alt.X(f"{x}:{x_type}", title=x.replace("_", " ").title(), axis=X_AXIS_NOGRID)
    y_enc = alt.Y(f"{y}:Q", title=y.replace("_", " ").title(), axis=Y_AXIS)
    enc = {"x": x_enc, "y": y_enc}
    mark_kw = dict(point=True, strokeWidth=2.5)
    if color:
        enc["color"] = alt.Color(f"{color}:N", title=color.replace("_", " ").title(),
                                  scale=alt.Scale(range=LINE_COLORS))
    else:
        mark_kw["color"] = BAR_COLOR
    chart = alt.Chart(df).mark_line(**mark_kw).encode(**enc).properties(height=height)
    st.altair_chart(chart, use_container_width=True)
