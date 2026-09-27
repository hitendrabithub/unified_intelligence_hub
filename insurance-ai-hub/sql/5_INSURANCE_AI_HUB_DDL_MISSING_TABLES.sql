-- ============================================================================
-- INSURANCE AI HUB - DDL for Missing Tables (6 tables)
-- Database: INSURANCE_AI_HUB
-- Run AFTER 1_INSURANCE_AI_HUB_DDL_DML.sql (depends on CUSTOMERS FK)
-- ============================================================================

USE DATABASE INSURANCE_AI_HUB;
USE SCHEMA ANALYTICS;


-- ############################################################################
-- 1. PRODUCTS (20 rows) - Product catalog with eligibility rules
-- ############################################################################

CREATE TABLE IF NOT EXISTS INSURANCE_AI_HUB.ANALYTICS.PRODUCTS (
    PRODUCT_ID          VARCHAR(20)     NOT NULL PRIMARY KEY,
    PRODUCT_NAME        VARCHAR(200),
    POLICY_TYPE         VARCHAR(20),
    PLAN_TIER           VARCHAR(20),
    BASE_PREMIUM        DECIMAL(12,2),
    COVERAGE_MIN        DECIMAL(14,2),
    COVERAGE_MAX        DECIMAL(14,2),
    DEDUCTIBLE_OPTIONS  VARIANT,
    ELIGIBLE_SEGMENTS   VARIANT,
    ELIGIBLE_RISK_TIERS VARIANT,
    MIN_CREDIT_SCORE    INT,
    MIN_AGE             INT,
    MAX_AGE             INT,
    ELIGIBLE_STATES     VARIANT,
    IS_ACTIVE           BOOLEAN         DEFAULT TRUE,
    CREATED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
);


-- ############################################################################
-- 2. PRODUCT_FEATURES (80 rows) - Feature weights per product
-- ############################################################################

CREATE TABLE IF NOT EXISTS INSURANCE_AI_HUB.ANALYTICS.PRODUCT_FEATURES (
    FEATURE_ID          VARCHAR(20)     NOT NULL PRIMARY KEY,
    PRODUCT_ID          VARCHAR(20),
    FEATURE_NAME        VARCHAR(200),
    FEATURE_CATEGORY    VARCHAR(50),
    FEATURE_WEIGHT      FLOAT,
    FEATURE_VALUE       VARCHAR(500),
    CREATED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (PRODUCT_ID) REFERENCES INSURANCE_AI_HUB.ANALYTICS.PRODUCTS(PRODUCT_ID)
);


-- ############################################################################
-- 3. COMPETITOR_RATES (192 rows) - Benchmark premiums by competitor
-- ############################################################################

CREATE TABLE IF NOT EXISTS INSURANCE_AI_HUB.ANALYTICS.COMPETITOR_RATES (
    RATE_ID             VARCHAR(20)     NOT NULL PRIMARY KEY,
    COMPETITOR_NAME     VARCHAR(100),
    POLICY_TYPE         VARCHAR(20),
    PLAN_TIER           VARCHAR(20),
    REGION              VARCHAR(50),
    BENCHMARK_PREMIUM   DECIMAL(12,2),
    BENCHMARK_DEDUCTIBLE DECIMAL(10,2),
    BENCHMARK_COVERAGE  DECIMAL(14,2),
    EFFECTIVE_DATE      DATE,
    SOURCE              VARCHAR(100),
    CREATED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
);


-- ############################################################################
-- 4. MARKET_TRENDS (384 rows) - Time-series market indicators
-- ############################################################################

CREATE TABLE IF NOT EXISTS INSURANCE_AI_HUB.ANALYTICS.MARKET_TRENDS (
    TREND_ID            VARCHAR(20)     NOT NULL PRIMARY KEY,
    METRIC_NAME         VARCHAR(100),
    METRIC_CATEGORY     VARCHAR(50),
    REGION              VARCHAR(50),
    PERIOD_DATE         DATE,
    METRIC_VALUE        FLOAT,
    PRIOR_PERIOD_VALUE  FLOAT,
    CHANGE_PCT          FLOAT,
    TREND_DIRECTION     VARCHAR(10),
    CREATED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP()
);


-- ############################################################################
-- 5. RECOMMENDATIONS (300 rows) - Recommendation audit trail
-- ############################################################################

CREATE TABLE IF NOT EXISTS INSURANCE_AI_HUB.ANALYTICS.RECOMMENDATIONS (
    RECOMMENDATION_ID   VARCHAR(20)     NOT NULL PRIMARY KEY,
    CUSTOMER_ID         VARCHAR(20),
    PRODUCT_ID          VARCHAR(20),
    MATCH_SCORE         FLOAT,
    ELIGIBILITY_PASS    BOOLEAN,
    RULE_SCORE          FLOAT,
    SIMILARITY_SCORE    FLOAT,
    RANK                INT,
    EXPLANATION         VARCHAR(1000),
    RECOMMENDED_BY      VARCHAR(50),
    RECOMMENDED_AT      TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    STATUS              VARCHAR(20),
    FOREIGN KEY (CUSTOMER_ID) REFERENCES INSURANCE_AI_HUB.ANALYTICS.CUSTOMERS(CUSTOMER_ID),
    FOREIGN KEY (PRODUCT_ID) REFERENCES INSURANCE_AI_HUB.ANALYTICS.PRODUCTS(PRODUCT_ID)
);


-- ############################################################################
-- 6. RECOMMENDATION_FEEDBACK (180 rows) - Acceptance & ratings
-- ############################################################################

CREATE TABLE IF NOT EXISTS INSURANCE_AI_HUB.ANALYTICS.RECOMMENDATION_FEEDBACK (
    FEEDBACK_ID         VARCHAR(20)     NOT NULL PRIMARY KEY,
    RECOMMENDATION_ID   VARCHAR(20),
    CUSTOMER_ID         VARCHAR(20),
    ACCEPTED            BOOLEAN,
    FEEDBACK_RATING     INT,
    FEEDBACK_TEXT       VARCHAR(500),
    CONVERSION_DATE     DATE,
    CREATED_AT          TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (RECOMMENDATION_ID) REFERENCES INSURANCE_AI_HUB.ANALYTICS.RECOMMENDATIONS(RECOMMENDATION_ID),
    FOREIGN KEY (CUSTOMER_ID) REFERENCES INSURANCE_AI_HUB.ANALYTICS.CUSTOMERS(CUSTOMER_ID)
);

-- ============================================================================
-- END OF MISSING TABLES DDL
-- ============================================================================
