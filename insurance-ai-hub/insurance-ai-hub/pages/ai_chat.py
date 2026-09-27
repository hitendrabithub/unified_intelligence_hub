import time
import threading
import streamlit as st
from config import CHAT_SUGGESTIONS
from utils import call_agent, extract_text, extract_charts, extract_suggestions, get_session, page_header

CLASSIFY_PROMPT = """Classify the following user question. Determine ALL agent categories needed to fully answer it.

Agents:
- Product Matching: product recommendations, matching, acceptance rates, feedback, suitability, which products to offer
- Price Optimization: pricing, premiums, costs, benchmarks, billing, loss ratios, friction points, competitors, late fees, overdue payments, invoices, deductibles
- Market Intelligence: churn, market trends, retention, revenue at risk, forecasts, segments, growth, at-risk policies, regions, declining trends, market metrics, trend direction
- Data Quality: data quality scores, DQ rules, DQ column health, null percentages, duplicates, accuracy scores, completeness scores, consistency scores, pass rates, failed DQ rules

IMPORTANT: Only include an agent if the question EXPLICITLY asks about its domain.
- "metrics" or "trends" about business/market performance = Market Intelligence (NOT Data Quality)
- "quality" about data integrity, nulls, duplicates, DQ scores = Data Quality
- Do NOT add Data Quality unless the question specifically asks about data integrity, DQ scores, or data issues.

If the question requires information from multiple agents, list ALL of them.
Respond with ONLY the agent name(s), comma-separated. Nothing else.

Examples:
- "What products should we recommend to high-churn customers with overdue payments?" -> Market Intelligence, Price Optimization, Product Matching
- "How do our prices compare to benchmarks?" -> Price Optimization
- "Which regions show a declining trend across multiple metrics?" -> Market Intelligence
- "Why did the data quality score drop recently?" -> Data Quality
- "Which at-risk customers have billing issues and what should we recommend?" -> Market Intelligence, Price Optimization, Product Matching

Question: {question}"""


def _detect_agents(query):
    try:
        session = get_session()
        prompt = CLASSIFY_PROMPT.format(question=query)
        result = session.sql(
            "SELECT SNOWFLAKE.CORTEX.COMPLETE('llama3.1-8b', ?) AS resp",
            params=[prompt],
        ).collect()
        raw = result[0]["RESP"].strip().strip('"').strip("'")
        valid = {"Product Matching", "Price Optimization", "Market Intelligence", "Data Quality"}
        agents = [a.strip() for a in raw.split(",")]
        agents = [a for a in agents if a in valid]
        return agents if agents else None
    except Exception:
        return None


def render():
    page_header("🤖 AI Assistant", "Orchestrates your queries across Product Matching, Price Optimization, Market Intelligence, and Data Quality agents to deliver unified insights.")

    if "messages" not in st.session_state:
        st.session_state.messages = []
    if "input_key_counter" not in st.session_state:
        st.session_state.input_key_counter = 0

    for i, msg in enumerate(st.session_state.messages):
        with st.chat_message(msg["role"]):
            if msg.get("content"):
                st.markdown(msg["content"])
            for spec in msg.get("charts", []):
                st.vega_lite_chart(spec, use_container_width=True)
            if msg["role"] == "assistant" and i == len(st.session_state.messages) - 1:
                if msg.get("suggestions"):
                    st.divider()
                    st.caption("**Suggested follow-ups:**")
                    fcols = st.columns(min(len(msg["suggestions"]), 3))
                    for j, sq in enumerate(msg["suggestions"]):
                        if fcols[j % len(fcols)].button(sq, key=f"followup_{j}", use_container_width=True):
                            st.session_state.messages.append({"role": "user", "content": sq})
                            st.rerun()

    if st.session_state.messages and st.session_state.messages[-1]["role"] == "user":
        user_text = st.session_state.messages[-1]["content"]
        with st.chat_message("assistant"):
            placeholder = st.empty()
            with placeholder, st.spinner("Thinking..."):
                start = time.time()
                detected = _detect_agents(user_text)
                elapsed = time.time() - start
                remaining = 5.0 - elapsed
                if remaining > 0:
                    time.sleep(remaining)
            placeholder.empty()

            agents = detected or []
            result_holder = {}

            history = []
            msgs = st.session_state.messages
            for m in msgs:
                if m["role"] == "user":
                    history.append({"role": "user", "content": [{"type": "text", "text": m["content"]}]})
                elif m["role"] == "assistant" and m.get("content"):
                    history.append({"role": "assistant", "content": [{"type": "text", "text": m["content"]}]})
            if len(history) > 6:
                history = history[-6:]

            def _run():
                try:
                    result_holder["response"] = call_agent(history)
                except Exception as e:
                    result_holder["error"] = str(e)

            thread = threading.Thread(target=_run)
            thread.start()

            status_ph = st.empty()
            if agents:
                idx = 0
                while thread.is_alive():
                    agent_name = agents[idx % len(agents)]
                    status_ph.markdown(f"Talking to **{agent_name}** agent...")
                    time.sleep(3)
                    idx += 1
            else:
                with status_ph, st.spinner("Processing..."):
                    thread.join()
            thread.join()
            status_ph.empty()

            if "error" in result_holder:
                answer = f"An error occurred: {result_holder['error']}"
                charts, suggestions = [], []
            else:
                response = result_holder["response"]
                answer = extract_text(response)
                charts = extract_charts(response)
                suggestions = extract_suggestions(response)

        st.session_state.messages.append({
            "role": "assistant",
            "content": answer,
            "charts": charts,
            "suggestions": suggestions,
        })
        st.rerun()

    if not st.session_state.messages:
        st.markdown("**What can I help you with?**")
        st.caption("Choose a question below or type your own")
        cols = st.columns(3)
        for i, s in enumerate(CHAT_SUGGESTIONS):
            if cols[i % 3].button(s["label"], key=f"sug_{i}", use_container_width=True):
                st.session_state.messages.append({"role": "user", "content": s["label"]})
                st.rerun()

    with st.form(key=f"chat_form_{st.session_state.input_key_counter}", clear_on_submit=True):
        input_col, btn_col = st.columns([6, 1])
        with input_col:
            prompt = st.text_input(
                "Ask a question...",
                key=f"chat_input_{st.session_state.input_key_counter}",
                label_visibility="collapsed",
                placeholder="Ask a question...",
            )
        with btn_col:
            submitted = st.form_submit_button("Clear", use_container_width=True)

    if submitted and not prompt:
        st.session_state.pop("messages", None)
        st.session_state.input_key_counter += 1
        st.rerun()

    if submitted and prompt:
        st.session_state.messages.append({"role": "user", "content": prompt})
        st.session_state.input_key_counter += 1
        st.rerun()
