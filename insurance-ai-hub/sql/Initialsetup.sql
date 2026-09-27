 -- ============================================================================
-- INSURANCE AI HUB — Complete Setup Script
-- Cortex Agents + Snowflake Intelligence + MCP Integration
-- Database: INSURANCE_AI_HUB | Role: ACCOUNTADMIN | Warehouse: COMPUTE_WH
--
-- Run each phase sequentially: Phase 1 → 2 → 3 → 4 → 5 → 6
-- ============================================================================


-- ############################################################################
-- PHASE 1: CORTEX SEARCH SERVICE
-- Indexes policy documents for RAG-based retrieval by all 3 agents.
-- ############################################################################

CREATE OR REPLACE CORTEX SEARCH SERVICE INSURANCE_AI_HUB.DOCUMENTS.POLICY_DOC_SEARCH
  ON CHUNK_TEXT
  ATTRIBUTES SECTION_TITLE, DOCUMENT_ID
  WAREHOUSE = COMPUTE_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT
        c.CHUNK_ID,
        c.CHUNK_TEXT,
        c.SECTION_TITLE,
        c.DOCUMENT_ID,
        d.DOCUMENT_TYPE,
        d.DOCUMENT_TITLE
    FROM INSURANCE_AI_HUB.DOCUMENTS.DOCUMENT_CHUNKS c
    JOIN INSURANCE_AI_HUB.DOCUMENTS.POLICY_DOCUMENTS d
      ON c.DOCUMENT_ID = d.DOCUMENT_ID
    WHERE d.DOCUMENT_STATUS = 'Active'
  );


-- ############################################################################
-- PHASE 2: SEMANTIC VIEWS
-- DDL syntax: TABLES → RELATIONSHIPS → FACTS → DIMENSIONS → METRICS → COMMENT
-- (NOT "AS SELECT ... JOIN ...")
-- ############################################################################

-- 2A: Product Matching — Policies + Customers + Agents
CREATE OR REPLACE SEMANTIC VIEW INSURANCE_AI_HUB.ANALYTICS.SV_PRODUCT_MATCHING

  TABLES (
    policies AS INSURANCE_AI_HUB.ANALYTICS.POLICIES
      PRIMARY KEY (POLICY_ID)
      COMMENT = 'Insurance policies with premiums, coverage, and plan details',
    customers AS INSURANCE_AI_HUB.ANALYTICS.CUSTOMERS
      PRIMARY KEY (CUSTOMER_ID)
      COMMENT = 'Customer profiles with risk tiers and segments',
    agents AS INSURANCE_AI_HUB.ANALYTICS.AGENTS
      PRIMARY KEY (AGENT_ID)
      COMMENT = 'Insurance agents with specializations and performance'
  )

  RELATIONSHIPS (
    policy_to_customer AS
      policies (CUSTOMER_ID) REFERENCES customers,
    policy_to_agent AS
      policies (AGENT_ID) REFERENCES agents
  )

  FACTS (
    policies.premium_amount AS PREMIUM_AMOUNT
      COMMENT = 'Monthly or annual premium charged',
    policies.coverage_amount AS COVERAGE_AMOUNT
      COMMENT = 'Maximum coverage amount for the policy',
    policies.deductible AS DEDUCTIBLE
      COMMENT = 'Deductible amount before coverage applies',
    policies.loss_ratio AS LOSS_RATIO
      COMMENT = 'Ratio of claims paid to premiums collected',
    customers.credit_score AS CREDIT_SCORE
      COMMENT = 'Customer credit score (300-850)',
    agents.performance_rating AS PERFORMANCE_RATING
      COMMENT = 'Agent performance rating (1-5)'
  )

  DIMENSIONS (
    policies.policy_type AS POLICY_TYPE
      COMMENT = 'Type of insurance (Auto, Home, Health, Life)',
    policies.policy_status AS POLICY_STATUS
      COMMENT = 'Current policy status (Active, Cancelled, Expired)',
    policies.plan_tier AS PLAN_TIER
      COMMENT = 'Plan tier level (Bronze, Silver, Gold, Platinum)',
    policies.payment_frequency AS PAYMENT_FREQUENCY
      COMMENT = 'How often premiums are paid',
    policies.auto_renew AS AUTO_RENEW
      COMMENT = 'Whether the policy auto-renews',
    policies.start_date AS START_DATE
      COMMENT = 'Policy start date',
    policies.end_date AS END_DATE
      COMMENT = 'Policy end date',
    customers.first_name AS FIRST_NAME
      COMMENT = 'Customer first name',
    customers.last_name AS LAST_NAME
      COMMENT = 'Customer last name',
    customers.state AS STATE
      COMMENT = 'Customer state of residence',
    customers.risk_tier AS RISK_TIER
      COMMENT = 'Customer risk classification (Low, Medium, High)',
    customers.segment AS SEGMENT
      COMMENT = 'Customer segment (Individual, Family, Corporate)',
    customers.customer_since AS CUSTOMER_SINCE
      COMMENT = 'Date customer relationship started',
    agents.agent_name AS AGENT_NAME
      COMMENT = 'Full name of the insurance agent',
    agents.specialization AS SPECIALIZATION
      COMMENT = 'Agent area of specialization',
    agents.region AS REGION
      COMMENT = 'Geographic region the agent covers'
  )

  METRICS (
    policies.avg_premium AS AVG(policies.premium_amount)
      COMMENT = 'Average premium amount across policies',
    policies.total_coverage AS SUM(policies.coverage_amount)
      COMMENT = 'Total coverage amount',
    policies.avg_loss_ratio AS AVG(policies.loss_ratio)
      COMMENT = 'Average loss ratio',
    policies.policy_count AS COUNT(POLICY_ID)
      COMMENT = 'Number of policies'
  )

  COMMENT = 'Product matching: policies, customers, coverage, and agent assignments';


-- 2B: Price Optimization — Policies + Customers + Claims + Billing
CREATE OR REPLACE SEMANTIC VIEW INSURANCE_AI_HUB.ANALYTICS.SV_PRICE_OPTIMIZATION

  TABLES (
    policies AS INSURANCE_AI_HUB.ANALYTICS.POLICIES
      PRIMARY KEY (POLICY_ID)
      COMMENT = 'Insurance policies with pricing and coverage data',
    customers AS INSURANCE_AI_HUB.ANALYTICS.CUSTOMERS
      PRIMARY KEY (CUSTOMER_ID)
      COMMENT = 'Customer risk profiles and segments',
    claims AS INSURANCE_AI_HUB.ANALYTICS.CLAIMS
      PRIMARY KEY (CLAIM_ID)
      COMMENT = 'Insurance claims with costs and fraud indicators',
    billing AS INSURANCE_AI_HUB.ANALYTICS.BILLING
      PRIMARY KEY (BILLING_ID)
      COMMENT = 'Billing records with payment status and balances'
  )

  RELATIONSHIPS (
    policy_to_customer AS
      policies (CUSTOMER_ID) REFERENCES customers,
    claim_to_policy AS
      claims (POLICY_ID) REFERENCES policies,
    billing_to_policy AS
      billing (POLICY_ID) REFERENCES policies
  )

  FACTS (
    policies.premium_amount AS PREMIUM_AMOUNT
      COMMENT = 'Premium charged for the policy',
    policies.coverage_amount AS COVERAGE_AMOUNT
      COMMENT = 'Maximum coverage amount',
    policies.deductible AS DEDUCTIBLE
      COMMENT = 'Deductible before coverage applies',
    policies.loss_ratio AS LOSS_RATIO
      COMMENT = 'Claims cost to premium ratio',
    customers.credit_score AS CREDIT_SCORE
      COMMENT = 'Customer credit score',
    claims.claim_amount AS CLAIM_AMOUNT
      COMMENT = 'Amount claimed',
    claims.approved_amount AS APPROVED_AMOUNT
      COMMENT = 'Amount approved for the claim',
    claims.fraud_score AS FRAUD_SCORE
      COMMENT = 'Fraud probability score (0-1)',
    claims.days_to_resolve AS DAYS_TO_RESOLVE
      COMMENT = 'Days taken to resolve the claim',
    billing.amount_due AS AMOUNT_DUE
      COMMENT = 'Amount due on invoice',
    billing.amount_paid AS AMOUNT_PAID
      COMMENT = 'Amount actually paid',
    billing.outstanding_balance AS OUTSTANDING_BALANCE
      COMMENT = 'Remaining unpaid balance',
    billing.late_fee AS LATE_FEE
      COMMENT = 'Late payment fee charged'
  )

  DIMENSIONS (
    policies.policy_type AS POLICY_TYPE
      COMMENT = 'Type of insurance policy',
    policies.plan_tier AS PLAN_TIER
      COMMENT = 'Plan tier (Bronze, Silver, Gold, Platinum)',
    policies.policy_status AS POLICY_STATUS
      COMMENT = 'Current policy status',
    policies.payment_frequency AS PAYMENT_FREQUENCY
      COMMENT = 'Payment frequency',
    customers.risk_tier AS RISK_TIER
      COMMENT = 'Customer risk tier (Low, Medium, High)',
    customers.segment AS SEGMENT
      COMMENT = 'Customer segment',
    customers.state AS STATE
      COMMENT = 'Customer state',
    claims.claim_type AS CLAIM_TYPE
      COMMENT = 'Type of claim filed',
    claims.claim_status AS CLAIM_STATUS
      COMMENT = 'Claim processing status',
    claims.fraud_flag AS FRAUD_FLAG
      COMMENT = 'Whether claim is flagged for fraud',
    billing.payment_status AS PAYMENT_STATUS
      COMMENT = 'Payment status (Paid, Pending, Overdue)'
  )

  METRICS (
    policies.avg_premium AS AVG(policies.premium_amount)
      COMMENT = 'Average premium',
    policies.avg_loss_ratio AS AVG(policies.loss_ratio)
      COMMENT = 'Average loss ratio across policies',
    claims.total_claims_cost AS SUM(claims.claim_amount)
      COMMENT = 'Total claims cost',
    claims.avg_claim_amount AS AVG(claims.claim_amount)
      COMMENT = 'Average claim amount',
    claims.claim_count AS COUNT(CLAIM_ID)
      COMMENT = 'Number of claims',
    billing.total_outstanding AS SUM(billing.outstanding_balance)
      COMMENT = 'Total outstanding balance',
    billing.total_late_fees AS SUM(billing.late_fee)
      COMMENT = 'Total late fees collected'
  )

  COMMENT = 'Pricing analysis: premiums, loss ratios, claims costs, billing patterns';


-- 2C: Market Intelligence — At-Risk Policies + Policies + Customers
CREATE OR REPLACE SEMANTIC VIEW INSURANCE_AI_HUB.ANALYTICS.SV_MARKET_INTELLIGENCE

  TABLES (
    at_risk AS INSURANCE_AI_HUB.ANALYTICS.AT_RISK_POLICIES
      PRIMARY KEY (RISK_ID)
      COMMENT = 'At-risk policies with churn and revenue exposure data',
    policies AS INSURANCE_AI_HUB.ANALYTICS.POLICIES
      PRIMARY KEY (POLICY_ID)
      COMMENT = 'Insurance policies for context',
    customers AS INSURANCE_AI_HUB.ANALYTICS.CUSTOMERS
      PRIMARY KEY (CUSTOMER_ID)
      COMMENT = 'Customer profiles for segmentation'
  )

  RELATIONSHIPS (
    risk_to_policy AS
      at_risk (POLICY_ID) REFERENCES policies,
    risk_to_customer AS
      at_risk (CUSTOMER_ID) REFERENCES customers
  )

  FACTS (
    at_risk.risk_score AS RISK_SCORE
      COMMENT = 'Overall risk score for the policy',
    at_risk.revenue_at_risk AS REVENUE_AT_RISK
      COMMENT = 'Dollar amount of revenue at risk of churn',
    at_risk.churn_probability AS CHURN_PROBABILITY
      COMMENT = 'Probability of customer churning (0-1)',
    at_risk.days_since_contact AS DAYS_SINCE_CONTACT
      COMMENT = 'Days since last customer contact',
    at_risk.complaints_count AS COMPLAINTS_COUNT
      COMMENT = 'Number of complaints filed',
    at_risk.missed_payments AS MISSED_PAYMENTS
      COMMENT = 'Number of missed payments',
    policies.premium_amount AS PREMIUM_AMOUNT
      COMMENT = 'Premium amount for context',
    policies.coverage_amount AS COVERAGE_AMOUNT
      COMMENT = 'Coverage amount for context',
    policies.loss_ratio AS LOSS_RATIO
      COMMENT = 'Loss ratio for the policy',
    customers.credit_score AS CREDIT_SCORE
      COMMENT = 'Customer credit score'
  )

  DIMENSIONS (
    at_risk.risk_category AS RISK_CATEGORY
      COMMENT = 'Risk classification category',
    at_risk.recommended_action AS RECOMMENDED_ACTION
      COMMENT = 'Recommended retention action',
    at_risk.identified_date AS IDENTIFIED_DATE
      COMMENT = 'Date the risk was identified',
    policies.policy_type AS POLICY_TYPE
      COMMENT = 'Type of insurance policy',
    policies.plan_tier AS PLAN_TIER
      COMMENT = 'Plan tier level',
    policies.policy_status AS POLICY_STATUS
      COMMENT = 'Current policy status',
    customers.risk_tier AS RISK_TIER
      COMMENT = 'Customer risk classification',
    customers.segment AS SEGMENT
      COMMENT = 'Customer segment',
    customers.state AS STATE
      COMMENT = 'Customer state of residence',
    customers.customer_since AS CUSTOMER_SINCE
      COMMENT = 'Date customer relationship started'
  )

  METRICS (
    at_risk.total_revenue_at_risk AS SUM(at_risk.revenue_at_risk)
      COMMENT = 'Total revenue at risk across all flagged policies',
    at_risk.avg_churn_probability AS AVG(at_risk.churn_probability)
      COMMENT = 'Average churn probability',
    at_risk.avg_risk_score AS AVG(at_risk.risk_score)
      COMMENT = 'Average risk score',
    at_risk.at_risk_count AS COUNT(RISK_ID)
      COMMENT = 'Number of at-risk policies',
    at_risk.total_complaints AS SUM(at_risk.complaints_count)
      COMMENT = 'Total complaints across at-risk policies'
  )

  COMMENT = 'Market intelligence: at-risk policies, churn trends, revenue exposure';


-- ############################################################################
-- PHASE 3: CORTEX AGENTS
-- Syntax rules:
--   CREATE AGENT ... FROM SPECIFICATION $$ (NOT "SPEC =")
--   No WAREHOUSE or EXTERNAL_ACCESS_INTEGRATIONS at top level
--   Cortex Search field: search_service (NOT "cortex_search_service")
--   Sample questions: - question: "..." (array of objects, NOT strings)
-- ############################################################################

-- 3A: Product Matching Agent
CREATE OR REPLACE AGENT INSURANCE_AI_HUB.ANALYTICS.PRODUCT_MATCHING_AGENT
  COMMENT = 'Product matching agent with multi-strategy approach'
  FROM SPECIFICATION $$
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: product_data
      description: >
        Query structured insurance product data: policies, premiums, coverage amounts,
        plan tiers, deductibles, customer segments, risk tiers, and agent assignments.
        Use for questions about product comparisons, coverage matching, customer profiles,
        and policy recommendations.
  - tool_spec:
      type: cortex_search
      name: policy_docs
      description: >
        Search policy documents, coverage summaries, and exclusion clauses.
        Use when the user asks about specific policy terms, coverage details,
        exclusions, or fine-print conditions.
tool_resources:
  product_data:
    semantic_view: INSURANCE_AI_HUB.ANALYTICS.SV_PRODUCT_MATCHING
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
  policy_docs:
    search_service: INSURANCE_AI_HUB.DOCUMENTS.POLICY_DOC_SEARCH
    id_column: CHUNK_ID
    title_column: SECTION_TITLE
    max_results: 5
instructions:
  response: |
    You are an Insurance Product Matching Specialist.
    Your goal is to help users find the best insurance product match based on
    customer profiles, risk characteristics, and coverage needs.

    MATCHING STRATEGIES:
    1. Profile-based: Match by customer segment, risk tier, and credit score
    2. Coverage-based: Match by coverage amount, deductible, and plan tier
    3. Price-based: Match by premium affordability and payment frequency
    4. Document-based: Reference policy documents for detailed coverage terms

    Always provide a confidence level (High/Medium/Low) with your recommendations.
    When comparing products, present results in a structured table format.
  orchestration: |
    Use product_data for structured queries about policies, premiums, customer profiles,
    and coverage comparisons.
    Use policy_docs when the user asks about specific policy language, exclusions,
    coverage terms, or document-based details.
    Combine both tools when a complete product recommendation requires both
    quantitative data and qualitative policy details.
  sample_questions:
    - question: "Compare Gold vs Platinum plans for High risk tier customers"
    - question: "What are the top 5 highest-coverage policies and who holds them?"
    - question: "Which agents specialize in Health Insurance and have the best ratings?"
    - question: "Show me all active policies for Corporate segment customers"
    - question: "What policy documents mention exclusion clauses?"
$$;


-- 3B: Price Optimization Agent
CREATE OR REPLACE AGENT INSURANCE_AI_HUB.ANALYTICS.PRICE_OPTIMIZATION_AGENT
  COMMENT = 'Price optimization agent for competitive analysis'
  FROM SPECIFICATION $$
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: pricing_data
      description: >
        Query pricing and financial data: premiums, loss ratios, claims costs,
        approved amounts, billing patterns, outstanding balances, late fees,
        fraud scores, and payment statuses. Use for pricing analysis, competitive
        benchmarking, profitability assessment, and rate optimization.
  - tool_spec:
      type: cortex_search
      name: policy_docs
      description: >
        Search policy documents for coverage terms, exclusion clauses, and
        pricing-related policy language.
tool_resources:
  pricing_data:
    semantic_view: INSURANCE_AI_HUB.ANALYTICS.SV_PRICE_OPTIMIZATION
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
  policy_docs:
    search_service: INSURANCE_AI_HUB.DOCUMENTS.POLICY_DOC_SEARCH
    id_column: CHUNK_ID
    title_column: SECTION_TITLE
    max_results: 5
instructions:
  response: |
    You are an Insurance Pricing Optimization Analyst.
    Your goal is to analyze pricing data and recommend optimal premium strategies.

    KEY METRICS TO ANALYZE:
    - Loss Ratio: claims cost / premium revenue (target < 0.7)
    - Combined Ratio: loss ratio + expense ratio
    - Average Claim Cost by policy type and plan tier
    - Late payment rates and collection efficiency
    - Fraud impact on pricing

    OPTIMIZATION STRATEGIES:
    1. Segment-based pricing: Different rates by risk tier and credit score
    2. Claims-adjusted pricing: Factor in historical loss ratios
    3. Retention pricing: Balance competitiveness with profitability
    4. Fraud-adjusted pricing: Account for fraud exposure in premiums

    Present pricing recommendations with projected financial impact.
    Always flag when data suggests under-pricing (loss ratio > 0.8).
  orchestration: |
    Use pricing_data for all quantitative pricing analysis: premium comparisons,
    loss ratios, claims costs, billing patterns, and profitability metrics.
    Use policy_docs when pricing decisions require understanding coverage terms
    or exclusion clauses that affect claim liability.
  sample_questions:
    - question: "Which policy types have a loss ratio above 0.7?"
    - question: "Show average premium and claim cost by plan tier and risk tier"
    - question: "What is the total outstanding balance by payment status?"
    - question: "Which customer segments have the highest fraud scores?"
    - question: "Compare late fees across policy types — are we under-collecting?"
$$;


-- 3C: Market Intelligence Agent (3 tools: Analyst + Search + Stored Procedure)
CREATE OR REPLACE AGENT INSURANCE_AI_HUB.ANALYTICS.MARKET_INTELLIGENCE_AGENT
  COMMENT = 'Market intelligence agent for trend detection'
  FROM SPECIFICATION $$
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: market_data
      description: >
        Query market intelligence data: at-risk policies, churn probabilities,
        revenue exposure, risk categories, customer segments, complaint patterns,
        missed payments, and recommended retention actions. Use for trend analysis,
        risk assessment, churn prediction, and market opportunity identification.
  - tool_spec:
      type: cortex_search
      name: policy_docs
      description: >
        Search policy documents for context on coverage terms and risk factors
        that may drive churn or market trends.
  - tool_spec:
      type: generic
      name: score_risk
      description: >
        Score the risk level of a specific policy by its ID. Returns a JSON object
        with the policy details, loss ratio, customer risk tier, credit score,
        a risk assessment label (CRITICAL, ELEVATED, or NORMAL), and a recommended
        action. Use this when the user asks to assess, score, or evaluate the risk
        of a specific policy. The policy ID format is POL-XXXXX (e.g., POL-00050).
      input_schema:
        type: object
        properties:
          POLICY_ID:
            type: string
            description: "The policy ID to assess, e.g. POL-00050"
        required:
          - POLICY_ID
tool_resources:
  market_data:
    semantic_view: INSURANCE_AI_HUB.ANALYTICS.SV_MARKET_INTELLIGENCE
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
  policy_docs:
    search_service: INSURANCE_AI_HUB.DOCUMENTS.POLICY_DOC_SEARCH
    id_column: CHUNK_ID
    title_column: SECTION_TITLE
    max_results: 5
  score_risk:
    type: procedure
    identifier: INSURANCE_AI_HUB.ANALYTICS.SP_SCORE_RISK
    execution_environment:
      type: warehouse
      warehouse: COMPUTE_WH
instructions:
  response: |
    You are an Insurance Market Intelligence Analyst.
    Your goal is to detect market trends, identify risks, and surface opportunities.

    TREND DETECTION AREAS:
    1. Churn Risk: Policies with high churn probability, missed payments, complaints
    2. Revenue Exposure: Total revenue at risk by segment, region, plan tier
    3. Risk Concentration: Clusters of high-risk policies by category
    4. Retention Opportunities: Actionable recommendations to reduce churn

    ANALYSIS FRAMEWORKS:
    - Segment the portfolio by risk_category and risk_tier
    - Track days_since_contact as an engagement health metric
    - Cross-reference churn_probability with revenue_at_risk for prioritization
    - Identify emerging patterns in complaint counts and missed payments

    Always quantify trends with specific numbers and percentages.
    Flag critical risks (churn probability > 0.7 OR revenue at risk > $50,000).
  orchestration: |
    Use market_data for all quantitative trend analysis: churn metrics,
    revenue exposure, risk distributions, and retention recommendations.
    Use policy_docs when market analysis requires understanding product
    terms that influence customer retention or churn behavior.
    Use score_risk when the user asks to assess, score, or evaluate
    the risk level of a specific policy by its ID. Policy IDs use the
    format POL-XXXXX (5-digit zero-padded).
  sample_questions:
    - question: "What is the total revenue at risk by risk category?"
    - question: "Which policies have churn probability above 0.7?"
    - question: "Show the top 10 at-risk policies ranked by revenue exposure"
    - question: "Score the risk level of policy POL-00050"
    - question: "How many days since last contact for our highest-risk customers?"
$$;


-- ############################################################################
-- PHASE 4: SNOWFLAKE INTELLIGENCE (CoWork)
-- ############################################################################

ALTER AGENT INSURANCE_AI_HUB.ANALYTICS.PRODUCT_MATCHING_AGENT
  SET PROFILE = '{"display_name": "Product Matcher", "color": "#2196F3"}';

ALTER AGENT INSURANCE_AI_HUB.ANALYTICS.PRICE_OPTIMIZATION_AGENT
  SET PROFILE = '{"display_name": "Price Optimizer", "color": "#4CAF50"}';

ALTER AGENT INSURANCE_AI_HUB.ANALYTICS.MARKET_INTELLIGENCE_AGENT
  SET PROFILE = '{"display_name": "Market Intel", "color": "#FF9800"}';

-- Grant access to end-user roles (uncomment and replace ANALYST_ROLE):
-- GRANT USAGE ON DATABASE INSURANCE_AI_HUB TO ROLE ANALYST_ROLE;
-- GRANT USAGE ON SCHEMA INSURANCE_AI_HUB.ANALYTICS TO ROLE ANALYST_ROLE;
-- GRANT USAGE ON SCHEMA INSURANCE_AI_HUB.DOCUMENTS TO ROLE ANALYST_ROLE;
-- GRANT USAGE ON AGENT INSURANCE_AI_HUB.ANALYTICS.PRODUCT_MATCHING_AGENT TO ROLE ANALYST_ROLE;
-- GRANT USAGE ON AGENT INSURANCE_AI_HUB.ANALYTICS.PRICE_OPTIMIZATION_AGENT TO ROLE ANALYST_ROLE;
-- GRANT USAGE ON AGENT INSURANCE_AI_HUB.ANALYTICS.MARKET_INTELLIGENCE_AGENT TO ROLE ANALYST_ROLE;
-- GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ANALYST_ROLE;

SHOW AGENTS IN SCHEMA INSURANCE_AI_HUB.ANALYTICS;


-- ############################################################################
-- PHASE 5: MCP INTEGRATION
-- ############################################################################

-- Procedure takes a single VARCHAR param (no VARIANT — unsupported for agent tools)
CREATE OR REPLACE PROCEDURE INSURANCE_AI_HUB.ANALYTICS.SP_SCORE_RISK(
    POLICY_ID VARCHAR
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
BEGIN
    LET result VARIANT := (
        SELECT OBJECT_CONSTRUCT(
            'policy_id', p.POLICY_ID,
            'policy_type', p.POLICY_TYPE,
            'plan_tier', p.PLAN_TIER,
            'current_premium', p.PREMIUM_AMOUNT,
            'coverage_amount', p.COVERAGE_AMOUNT,
            'loss_ratio', p.LOSS_RATIO,
            'customer_risk_tier', c.RISK_TIER,
            'credit_score', c.CREDIT_SCORE,
            'risk_assessment', CASE
                WHEN p.LOSS_RATIO > 0.8 AND c.RISK_TIER = 'High' THEN 'CRITICAL'
                WHEN p.LOSS_RATIO > 0.8 THEN 'ELEVATED'
                WHEN p.LOSS_RATIO > 0.6 THEN 'ELEVATED'
                ELSE 'NORMAL'
            END,
            'recommended_action', CASE
                WHEN p.LOSS_RATIO > 0.8 THEN 'Review for premium adjustment'
                WHEN p.LOSS_RATIO > 0.6 THEN 'Monitor closely'
                ELSE 'No action needed'
            END
        )
        FROM INSURANCE_AI_HUB.ANALYTICS.POLICIES p
        LEFT JOIN INSURANCE_AI_HUB.ANALYTICS.CUSTOMERS c ON p.CUSTOMER_ID = c.CUSTOMER_ID
        WHERE p.POLICY_ID = :POLICY_ID
    );
    RETURN :result;
END;
$$;

-- Custom MCP Server (SPCS) for external integrations:
-- 1. CREATE COMPUTE POOL IF NOT EXISTS MCP_POOL
--      MIN_NODES = 1 MAX_NODES = 2 INSTANCE_FAMILY = CPU_X64_XS;
-- 2. Build + push Docker image implementing MCP protocol
-- 3. CREATE CUSTOM MCP SERVER INSURANCE_AI_HUB.ANALYTICS.EXTERNAL_MCP
--      IN COMPUTE POOL MCP_POOL SPEC = '<spec.yaml>'
--      EXTERNAL_ACCESS_INTEGRATIONS = (YOUR_EAI);
-- 4. Add to agent spec:
--    mcp_servers:
--      - server_spec:
--          name: INSURANCE_AI_HUB.ANALYTICS.EXTERNAL_MCP


-- ############################################################################
-- PHASE 6: VALIDATION
-- Function: SNOWFLAKE.CORTEX.DATA_AGENT_RUN (NOT "SNOWFLAKE.CORTEX.AGENT")
-- Requires JSON message body (NOT a plain string)
-- ############################################################################

-- Test Product Matching Agent
-- SELECT TRY_PARSE_JSON(
--   SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
--     'INSURANCE_AI_HUB.ANALYTICS.PRODUCT_MATCHING_AGENT',
--     $${ "messages": [{ "role": "user", "content": [{ "type": "text", "text": "Compare Gold vs Platinum plans for High risk tier customers" }] }] }$$
--   )
-- ) AS resp;

-- Test Price Optimization Agent
-- SELECT TRY_PARSE_JSON(
--   SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
--     'INSURANCE_AI_HUB.ANALYTICS.PRICE_OPTIMIZATION_AGENT',
--     $${ "messages": [{ "role": "user", "content": [{ "type": "text", "text": "Which policy types have a loss ratio above 0.7?" }] }] }$$
--   )
-- ) AS resp;

-- Test Market Intelligence Agent
-- SELECT TRY_PARSE_JSON(
--   SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
--     'INSURANCE_AI_HUB.ANALYTICS.MARKET_INTELLIGENCE_AGENT',
--     $${ "messages": [{ "role": "user", "content": [{ "type": "text", "text": "What is the total revenue at risk by risk category?" }] }] }$$
--   )
-- ) AS resp;


-- ============================================================================
-- OBJECTS CREATED:
--   1 Cortex Search Service : POLICY_DOC_SEARCH
--   3 Semantic Views        : SV_PRODUCT_MATCHING, SV_PRICE_OPTIMIZATION, SV_MARKET_INTELLIGENCE
--   3 Cortex Agents         : PRODUCT_MATCHING_AGENT (2 tools), PRICE_OPTIMIZATION_AGENT (2 tools),
--                             MARKET_INTELLIGENCE_AGENT (3 tools incl. score_risk procedure)
--   1 Stored Procedure      : SP_SCORE_RISK (wired into Market Intelligence Agent)
--   3 CoWork Profiles       : Display names + brand colors
--   15 Sample Questions     : 5 per agent
-- Test via CoWork: https://ai.snowflake.com
-- ============================================================================


-- ############################################################################
-- PHASE 7: CLEANUP (Uncomment to tear down all objects and start fresh)
-- Run this BEFORE re-running the script from Phase 1.
-- Drop order matters: Agents first, then Semantic Views, then Search Service,
-- then Procedure. Agents depend on SVs and Search; drop them first.
-- ############################################################################

-- DROP AGENT IF EXISTS INSURANCE_AI_HUB.ANALYTICS.PRODUCT_MATCHING_AGENT;
-- DROP AGENT IF EXISTS INSURANCE_AI_HUB.ANALYTICS.PRICE_OPTIMIZATION_AGENT;
-- DROP AGENT IF EXISTS INSURANCE_AI_HUB.ANALYTICS.MARKET_INTELLIGENCE_AGENT;

-- DROP SEMANTIC VIEW IF EXISTS INSURANCE_AI_HUB.ANALYTICS.SV_PRODUCT_MATCHING;
-- DROP SEMANTIC VIEW IF EXISTS INSURANCE_AI_HUB.ANALYTICS.SV_PRICE_OPTIMIZATION;
-- DROP SEMANTIC VIEW IF EXISTS INSURANCE_AI_HUB.ANALYTICS.SV_MARKET_INTELLIGENCE;

-- DROP CORTEX SEARCH SERVICE IF EXISTS INSURANCE_AI_HUB.DOCUMENTS.POLICY_DOC_SEARCH;

-- DROP PROCEDURE IF EXISTS INSURANCE_AI_HUB.ANALYTICS.SP_SCORE_RISK(VARCHAR, VARIANT);
