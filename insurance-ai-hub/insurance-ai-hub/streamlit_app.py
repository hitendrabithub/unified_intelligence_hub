import streamlit as st

st.set_page_config(
    page_title="Unified Intelligence Hub",
    layout="wide",
    initial_sidebar_state="expanded",
)

ENTERPRISE_CSS = """
<style>
/* ═══════════════════════════════════════
   CSS VARIABLES
   ═══════════════════════════════════════ */
:root {
    --accent-blue: #635BFF;
    --accent-blue-dim: rgba(99, 91, 255, 0.10);
    --accent: #00D4AA;
    --accent-dim: rgba(0, 212, 170, 0.12);
    --text-primary: #0A2540;
    --text-muted: #8792A2;
    --border: #E3E8EE;
    --border-light: #F0F3F7;
    --shadow-sm: 0 1px 3px rgba(10, 37, 64, 0.06);
    --shadow-md: 0 4px 12px rgba(10, 37, 64, 0.08);
    --shadow-lg: 0 8px 24px rgba(10, 37, 64, 0.12);
    --radius-sm: 8px;
    --radius-md: 12px;
    --transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

/* ═══════════════════════════════════════
   ANIMATIONS
   ═══════════════════════════════════════ */
@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(16px); }
    to { opacity: 1; transform: translateY(0); }
}
@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}
@keyframes pulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: 0.4; transform: scale(0.7); }
}

/* ═══════════════════════════════════════
   HIDE STREAMLIT CHROME (original working set)
   ═══════════════════════════════════════ */
[data-testid="stSidebarNav"] { display: none !important; }
[data-testid="stSidebarUserContent"] { padding-top: 1rem; }
section[data-testid="stSidebar"] > div { padding-top: 0rem; }
/* Make header invisible but keep it in layout so sidebar toggle works */
header[data-testid="stHeader"] { display: none !important; }
/* Hide sidebar collapse button */
[data-testid="stSidebarCollapseButton"] { display: none !important; }
#MainMenu, footer, div[data-testid="stDecoration"] { display: none !important; }

/* ═══════════════════════════════════════
   GLOBAL TYPOGRAPHY
   ═══════════════════════════════════════ */
.main .block-container {
    padding: 1.5rem 2rem 2rem 2rem !important;
    max-width: 1400px;
}
/* Page headers — blue matching sidebar theme */
[data-testid="stHeading"] h2 {
    color: #2E7DAF !important;
}
/* Section subheaders — navy with left accent, smaller size */
[data-testid="stHeading"] h3 {
    color: #2E7DAF !important;
    padding-left: 0.7rem !important;
    border-left: 3px solid #2E7DAF !important;
    font-size: 1.05rem !important;
}

/* ═══════════════════════════════════════
   SIDEBAR — DARK GRADIENT
   ═══════════════════════════════════════ */
section[data-testid="stSidebar"] {
    background: linear-gradient(180deg, #0A2540 0%, #122D4D 50%, #1B4D6E 100%) !important;
    border-right: none !important;
    box-shadow: 4px 0 24px rgba(10, 37, 64, 0.2) !important;
}
section[data-testid="stSidebar"] * {
    color: rgba(255, 255, 255, 0.85) !important;
}
section[data-testid="stSidebar"] [data-testid="stMarkdown"] p,
section[data-testid="stSidebar"] [data-testid="stMarkdown"] li {
    color: rgba(255, 255, 255, 0.6) !important;
    font-size: 0.82rem !important;
}
section[data-testid="stSidebar"] [data-testid="stMarkdown"] strong {
    color: rgba(255, 255, 255, 0.8) !important;
}
section[data-testid="stSidebar"] hr {
    border-color: rgba(255, 255, 255, 0.08) !important;
    margin: 0.75rem 0 !important;
}
/* Sidebar radio nav items */
section[data-testid="stSidebar"] [role="radiogroup"] {
    gap: 2px !important;
}
section[data-testid="stSidebar"] [role="radiogroup"] label {
    background: transparent !important;
    border: 1px solid transparent !important;
    border-radius: var(--radius-sm) !important;
    padding: 0.6rem 0.85rem !important;
    margin: 0 !important;
    transition: var(--transition) !important;
    cursor: pointer !important;
}
section[data-testid="stSidebar"] [role="radiogroup"] label:hover {
    background: rgba(255, 255, 255, 0.06) !important;
    border-color: rgba(255, 255, 255, 0.08) !important;
}
section[data-testid="stSidebar"] [role="radiogroup"] label[data-checked="true"],
section[data-testid="stSidebar"] [role="radiogroup"] label:has(input:checked) {
    background: rgba(0, 212, 170, 0.12) !important;
    border-color: rgba(0, 212, 170, 0.3) !important;
    box-shadow: 0 0 12px rgba(0, 212, 170, 0.08) !important;
}
section[data-testid="stSidebar"] [role="radiogroup"] label[data-checked="true"] p,
section[data-testid="stSidebar"] [role="radiogroup"] label:has(input:checked) p {
    color: #00D4AA !important;
    font-weight: 600 !important;
}
section[data-testid="stSidebar"] [role="radiogroup"] label p {
    font-size: 0.88rem !important;
    color: rgba(255, 255, 255, 0.8) !important;
    margin: 0 !important;
}

/* ═══════════════════════════════════════
   METRIC CARDS
   ═══════════════════════════════════════ */
[data-testid="stMetric"] {
    background: #FFFFFF !important;
    border: 1px solid var(--border) !important;
    border-radius: var(--radius-md) !important;
    padding: 1rem 1.15rem !important;
    box-shadow: var(--shadow-sm) !important;
    transition: var(--transition) !important;
    position: relative;
    overflow: hidden;
    animation: fadeInUp 0.4s ease-out both;
}
[data-testid="stMetric"]::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 3px;
    background: linear-gradient(90deg, var(--accent), var(--accent-blue));
    opacity: 0;
    transition: opacity 0.3s ease;
}
[data-testid="stMetric"]:hover {
    box-shadow: var(--shadow-lg) !important;
    transform: translateY(-3px);
    border-color: rgba(0, 212, 170, 0.25) !important;
}
[data-testid="stMetric"]:hover::before { opacity: 1; }
[data-testid="stMetric"] label {
    font-size: 0.74rem !important;
    font-weight: 500 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.05em !important;
    color: var(--text-muted) !important;
}
[data-testid="stMetric"] [data-testid="stMetricValue"] {
    font-size: 1.5rem !important;
    font-weight: 700 !important;
    color: var(--text-primary) !important;
    letter-spacing: -0.02em !important;
}
[data-testid="stMetric"] [data-testid="stMetricDelta"] { font-weight: 600 !important; }

/* Stagger animation */
[data-testid="stHorizontalBlock"] > div:nth-child(1) [data-testid="stMetric"] { animation-delay: 0s; }
[data-testid="stHorizontalBlock"] > div:nth-child(2) [data-testid="stMetric"] { animation-delay: 0.08s; }
[data-testid="stHorizontalBlock"] > div:nth-child(3) [data-testid="stMetric"] { animation-delay: 0.16s; }
[data-testid="stHorizontalBlock"] > div:nth-child(4) [data-testid="stMetric"] { animation-delay: 0.24s; }

/* ═══════════════════════════════════════
   CHARTS
   ═══════════════════════════════════════ */
[data-testid="stVegaLiteChart"],
[data-testid="stArrowVegaLiteChart"] {
    background: #FFFFFF !important;
    border: 1px solid var(--border) !important;
    border-radius: var(--radius-md) !important;
    padding: 1rem !important;
    box-shadow: var(--shadow-sm) !important;
    transition: var(--transition) !important;
    animation: fadeIn 0.4s ease-out;
}
[data-testid="stVegaLiteChart"]:hover,
[data-testid="stArrowVegaLiteChart"]:hover {
    box-shadow: var(--shadow-md) !important;
}
[data-testid="stVegaLiteChart"]:hover,
[data-testid="stArrowVegaLiteChart"]:hover {
    box-shadow: var(--shadow-md) !important;
}

/* ═══════════════════════════════════════
   DATAFRAMES
   ═══════════════════════════════════════ */
[data-testid="stDataFrame"] {
    border: 1px solid var(--border) !important;
    border-radius: var(--radius-md) !important;
    overflow: hidden;
    box-shadow: var(--shadow-sm) !important;
    animation: fadeIn 0.4s ease-out;
}

/* ═══════════════════════════════════════
   BUTTONS
   ═══════════════════════════════════════ */
.stButton > button {
    border-radius: var(--radius-sm) !important;
    font-weight: 500 !important;
    font-size: 0.84rem !important;
    border: 1px solid var(--border) !important;
    background: #FFFFFF !important;
    color: var(--text-primary) !important;
    padding: 0.45rem 1rem !important;
    transition: var(--transition) !important;
    box-shadow: var(--shadow-sm) !important;
}
.stButton > button:hover {
    border-color: var(--accent-blue) !important;
    color: var(--accent-blue) !important;
    box-shadow: var(--shadow-md), 0 0 0 3px var(--accent-blue-dim) !important;
    transform: translateY(-1px);
}
.stButton > button:active {
    transform: translateY(0) !important;
}

/* ═══════════════════════════════════════
   FORM CONTROLS
   ═══════════════════════════════════════ */
[data-testid="stSelectbox"] > div > div:focus-within,
[data-testid="stMultiSelect"] > div > div:focus-within {
    border-color: var(--accent-blue) !important;
    box-shadow: 0 0 0 3px var(--accent-blue-dim) !important;
}
[data-testid="stTextInput"] input:focus {
    border-color: var(--accent-blue) !important;
    box-shadow: 0 0 0 3px var(--accent-blue-dim) !important;
}

/* ═══════════════════════════════════════
   CHAT MESSAGES
   ═══════════════════════════════════════ */
[data-testid="stChatMessage"] {
    background: #FFFFFF !important;
    border: 1px solid var(--border) !important;
    border-radius: var(--radius-md) !important;
    padding: 1rem 1.25rem !important;
    margin-bottom: 0.75rem !important;
    box-shadow: var(--shadow-sm) !important;
    animation: fadeInUp 0.35s ease-out both;
}
[data-testid="stChatMessage"]:has([data-testid="chatAvatarIcon-assistant"]) {
    border-left: 3px solid var(--accent) !important;
}

/* ═══════════════════════════════════════
   ALERTS & DIVIDERS
   ═══════════════════════════════════════ */
[data-testid="stAlert"] {
    border-radius: var(--radius-md) !important;
    animation: fadeIn 0.4s ease-out;
}
/* Animated pulse dot — target the inner alert div */
[data-testid="stAlert"] > div {
    position: relative !important;
    padding-left: 1.5rem !important;
}
[data-testid="stAlert"] > div::before {
    content: '' !important;
    position: absolute !important;
    left: 0.5rem !important;
    top: 50% !important;
    transform: translateY(-50%) !important;
    width: 8px !important;
    height: 8px !important;
    border-radius: 50% !important;
    background-color: #F5A623 !important;
    animation: pulse 1.5s ease-in-out infinite !important;
}
/* Match dot color to Streamlit's alert icon color */
[data-testid="stAlertContentError"] ~ div::before,
[data-testid="stAlert"]:has([data-testid="stAlertContentError"])  > div::before { background-color: #C0392B !important; }
[data-testid="stAlertContentSuccess"] ~ div::before,
[data-testid="stAlert"]:has([data-testid="stAlertContentSuccess"]) > div::before { background-color: #00D4AA !important; }
[data-testid="stAlertContentWarning"] ~ div::before,
[data-testid="stAlert"]:has([data-testid="stAlertContentWarning"]) > div::before { background-color: #F5A623 !important; }
[data-testid="stAlertContentInfo"] ~ div::before,
[data-testid="stAlert"]:has([data-testid="stAlertContentInfo"]) > div::before { background-color: #635BFF !important; }
[data-testid="stExpander"] {
    border: 1px solid var(--border) !important;
    border-radius: var(--radius-md) !important;
    box-shadow: var(--shadow-sm) !important;
}

/* ═══════════════════════════════════════
   CHAT PAGE — themed input, suggestions, button
   ═══════════════════════════════════════ */
/* Chat text input — blue focus ring + fixed height to prevent button stretch */
[data-testid="stTextInput"] {
    overflow: hidden !important;
    max-height: 2.8rem !important;
}
[data-testid="stTextInput"] input {
    border: 1.5px solid #D0D5DD !important;
    border-radius: var(--radius-sm) !important;
}
[data-testid="stTextInput"] input:focus {
    border-color: var(--accent-blue) !important;
}
/* Remove form border around input + button */
[data-testid="stForm"] {
    border: none !important;
    padding: 0 !important;
}

/* Suggestion buttons — text wraps and centers */
.stButton > button {
    white-space: normal !important;
    line-height: 1.35 !important;
    text-align: center !important;
}
/* 3-column suggestion rows get taller + dark navy style */
[data-testid="stHorizontalBlock"]:has(:nth-child(3)) .stButton > button {
    min-height: 4rem !important;
    max-height: none !important;
    background: linear-gradient(135deg, #1B4D6E, #122D4D) !important;
    color: #FFFFFF !important;
    border: none !important;
    box-shadow: 0 2px 8px rgba(18, 45, 77, 0.25) !important;
}
[data-testid="stHorizontalBlock"]:has(:nth-child(3)) .stButton > button:hover {
    background: linear-gradient(135deg, #236089, #1B4D6E) !important;
    box-shadow: 0 4px 16px rgba(18, 45, 77, 0.35) !important;
    color: #FFFFFF !important;
}
</style>
"""

st.markdown(ENTERPRISE_CSS, unsafe_allow_html=True)

import os
import importlib
import config
import utils
from pages import ai_chat, competitive_pricing, market_trends, matching_accuracy, data_quality, home

importlib.reload(config)
importlib.reload(utils)
importlib.reload(home)
importlib.reload(ai_chat)
importlib.reload(competitive_pricing)
importlib.reload(market_trends)
importlib.reload(matching_accuracy)
importlib.reload(data_quality)

st.connection("snowflake", ttl=14400)

PAGES = {
    "Home": home,
    "Pricing Analytics": competitive_pricing,
    "Market Intelligence": market_trends,
    "Recommendation Analytics": matching_accuracy,
    "Data Quality Health": data_quality,
    "AI Assistant": ai_chat,
}

with st.sidebar:
    st.title("Unified Intelligence Hub")
    st.divider()
    selected_page = st.radio("", list(PAGES.keys()), label_visibility="collapsed")
    st.divider()
    st.subheader("Capabilities")
    st.markdown(
        """
- **Recommendation Engine** -- multi-strategy matching
- **Pricing Analytics** -- competitive benchmarking
- **Market Intelligence** -- churn & trend detection
- **Data Quality** -- root-cause analysis
- **Document Q&A** -- knowledge base search
"""
    )

PAGES[selected_page].render()
