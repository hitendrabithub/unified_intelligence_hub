-- ============================================================================
-- INSURANCE AI HUB - Cortex Agents: DATA_QUALITY_AGENT + INSURANCE_HUB_ORCHESTRATOR
-- Database: INSURANCE_AI_HUB.ANALYTICS
-- Run AFTER: All tables, semantic views (SV_DATA_QUALITY), and all other agents
-- are created (Initialsetup.sql creates the other 3 agents + 3 SVs).
--
-- NOTE: Cortex Agents use CREATE AGENT DDL. The agent_spec is a JSON blob
-- containing tools, instructions, and orchestration config.
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE INSURANCE_AI_HUB;
USE SCHEMA ANALYTICS;


-- ############################################################################
-- 1. DATA_QUALITY_AGENT
--    Conversational root-cause analysis over DQ_RULES, DQ_RESULTS,
--    DQ_SCORES, and DQ_COLUMN_HEALTH via SV_DATA_QUALITY semantic view.
-- ############################################################################

CREATE OR REPLACE AGENT INSURANCE_AI_HUB.ANALYTICS.DATA_QUALITY_AGENT
  COMMENT = 'Data quality agent for conversational root-cause analysis'
  PROFILE = '{
    "display_name": "Data Quality",
    "color": "red"
  }'
  AGENT_SPEC = '{
    "models": {"orchestration": "auto"},
    "orchestration": {
      "budget": {"seconds": 90, "tokens": 30000},
      "tool_not_accessible": "accept"
    },
    "instructions": {
      "response": "You are the Data Quality specialist for Insurance AI Hub.\nRules:\n- Always trace the root-cause chain when investigating quality drops:\n  1. Which table''s score dropped? (DQ_SCORES - compare across SCORE_DATE)\n  2. Which specific rules failed? (DQ_RESULTS - filter by status = FAIL)\n  3. Since when did they start failing? (compare EXECUTION_DATE across runs)\n  4. Is the failing column critical? (DQ_COLUMN_HEALTH - IS_CRITICAL flag)\n  5. What is the recommended fix based on the rule type and error sample?\n- Present quality scores with all dimensions: completeness, accuracy, consistency.\n- For column health, highlight columns with null_pct > 10% or health_status = ''Critical''.\n- Always show the trend direction (UP/DOWN/STABLE) when discussing score changes.\n",
      "orchestration": "Route ALL questions to DataQualityAnalyst. This tool covers:\n- DQ scores, trends, and historical comparisons\n- Rule definitions, pass rates, failure details\n- Column health metrics: nulls, duplicates, outliers\n- Root-cause analysis and impact assessment\n",
      "sample_questions": [
        {"question": "Why did the quality score drop for CUSTOMERS table?"},
        {"question": "Which critical rules failed in the last run?"},
        {"question": "Show me the trend of DQ scores for CLAIMS over time"},
        {"question": "Which columns have the most null values?"}
      ]
    },
    "tools": [
      {
        "tool_spec": {
          "type": "cortex_analyst_text_to_sql",
          "name": "DataQualityAnalyst",
          "description": "Data quality monitoring and root-cause analysis. Handles DQ scores, rule pass/fail results, column health metrics, trend analysis, and impact assessment."
        }
      }
    ],
    "tool_resources": {
      "DataQualityAnalyst": {
        "semantic_view": "INSURANCE_AI_HUB.DATA_QUALITY.SV_DATA_QUALITY",
        "execution_environment": {
          "type": "warehouse",
          "warehouse": "INSURANCE_AI_HUB_WH"
        }
      }
    }
  }';


-- ############################################################################
-- 2. INSURANCE_HUB_ORCHESTRATOR
--    Multi-agent supervisor that delegates to all 4 child agents plus
--    data_to_chart and code_execution tools.
--    Requires: PRODUCT_MATCHING_AGENT, PRICE_OPTIMIZATION_AGENT,
--              MARKET_INTELLIGENCE_AGENT, DATA_QUALITY_AGENT
-- ############################################################################

CREATE OR REPLACE AGENT INSURANCE_AI_HUB.ANALYTICS.INSURANCE_HUB_ORCHESTRATOR
  COMMENT = 'Supervisor agent - multi-agent orchestrator for Insurance AI Hub'
  PROFILE = '{
    "display_name": "Insurance AI Hub",
    "color": "blue"
  }'
  AGENT_SPEC = '{
    "models": {"orchestration": "auto"},
    "orchestration": {
      "budget": {"seconds": 300, "tokens": 50000},
      "tool_not_accessible": "accept"
    },
    "instructions": {
      "response": "You are the Insurance AI Hub supervisor — the single entry point for all insurance intelligence.\nYou have tools inherited from 4 specialized agents plus your own visualization and code tools.\nRules:\n- Respond in clear, concise business language.\n- Format currency with $ and 2 decimal places.\n- For product matching: explain WHY (eligibility, score, feature alignment).\n- For pricing: compare against market benchmarks when data is available.\n- For data quality: trace root cause - score dropped, rules failed, since when, is it critical, fix.\n- For documents: cite source document title and section.\n- Generate charts when data is suitable for visualization.\n- For multi-step questions, chain tools: structured data first, then documents.\n",
      "orchestration": "ROUTING RULES - choose the right inherited tool:\n1. Product matching, eligibility, recommendations, product features, match accuracy\n   -> Use ProductMatchAnalyst (from Product Matching Agent)\n2. Policy documents, exclusion clauses, coverage terms, contracts\n   -> Use PolicyDocSearch (from Product Matching Agent)\n3. Premiums, pricing, loss ratios, billing, late fees, competitive benchmarks, fraud, friction points\n   -> Use PricingAnalyst (from Price Optimization Agent)\n4. Churn, retention, at-risk policies, market trends, revenue exposure, risk scores\n   -> Use MarketIntelAnalyst (from Market Intelligence Agent)\n5. Data quality, DQ scores, rule failures, column health, data trust\n   -> Use DataQualityAnalyst (from Data Quality Agent)\n6. Visualization requests -> Use data_to_chart after getting data\n7. Complex calculations -> Use code_execution\n8. Cross-domain (e.g., at-risk + exclusions) -> Chain multiple tools\n",
      "sample_questions": [
        {"question": "Match the best products for high-risk corporate customers"},
        {"question": "How do our health premiums compare to market averages?"},
        {"question": "Which policies have churn probability above 0.7 and what do their contracts exclude?"},
        {"question": "Why did the quality score drop for the CUSTOMERS table?"},
        {"question": "What are the top friction points causing claim delays?"},
        {"question": "Show revenue at risk by risk category as a chart"},
        {"question": "Which products have the highest acceptance rate?"}
      ]
    },
    "tools": [
      {"tool_spec": {"type": "agent_toolset", "name": "product_matching_tools"}},
      {"tool_spec": {"type": "agent_toolset", "name": "price_optimization_tools"}},
      {"tool_spec": {"type": "agent_toolset", "name": "market_intelligence_tools"}},
      {"tool_spec": {"type": "agent_toolset", "name": "data_quality_tools"}},
      {"tool_spec": {"type": "data_to_chart", "name": "data_to_chart", "description": "Generates visualizations from data returned by other tools."}},
      {"tool_spec": {"type": "code_execution", "name": "code_execution", "description": "Runs Python for complex calculations and data processing."}}
    ],
    "tool_resources": {
      "product_matching_tools": {"agent_name": "INSURANCE_AI_HUB.ANALYTICS.PRODUCT_MATCHING_AGENT"},
      "price_optimization_tools": {"agent_name": "INSURANCE_AI_HUB.ANALYTICS.PRICE_OPTIMIZATION_AGENT"},
      "market_intelligence_tools": {"agent_name": "INSURANCE_AI_HUB.ANALYTICS.MARKET_INTELLIGENCE_AGENT"},
      "data_quality_tools": {"agent_name": "INSURANCE_AI_HUB.ANALYTICS.DATA_QUALITY_AGENT"}
    }
  }';


-- ============================================================================
-- GRANT USAGE to INSURANCE_HUB_USER role
-- ============================================================================

GRANT USAGE ON CORTEX_AGENT INSURANCE_AI_HUB.ANALYTICS.DATA_QUALITY_AGENT         TO ROLE INSURANCE_HUB_USER;
GRANT USAGE ON CORTEX_AGENT INSURANCE_AI_HUB.ANALYTICS.INSURANCE_HUB_ORCHESTRATOR TO ROLE INSURANCE_HUB_USER;

-- ============================================================================
-- END OF AGENT CREATION
-- ============================================================================
