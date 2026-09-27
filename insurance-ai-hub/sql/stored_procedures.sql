-- ============================================================
-- INSURANCE AI HUB - Stored Procedures
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE INSURANCE_AI_HUB;
USE SCHEMA ANALYTICS;

-- Risk scoring procedure: evaluates a policy's risk level
-- based on loss ratio and customer risk tier
CREATE OR REPLACE PROCEDURE SP_SCORE_RISK("POLICY_ID" VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
EXECUTE AS OWNER
AS '
BEGIN
    LET result VARIANT := (
        SELECT OBJECT_CONSTRUCT(
            ''policy_id'', p.POLICY_ID,
            ''policy_type'', p.POLICY_TYPE,
            ''plan_tier'', p.PLAN_TIER,
            ''current_premium'', p.PREMIUM_AMOUNT,
            ''coverage_amount'', p.COVERAGE_AMOUNT,
            ''loss_ratio'', p.LOSS_RATIO,
            ''customer_risk_tier'', c.RISK_TIER,
            ''credit_score'', c.CREDIT_SCORE,
            ''risk_assessment'', CASE
                WHEN p.LOSS_RATIO > 0.8 AND c.RISK_TIER = ''High'' THEN ''CRITICAL''
                WHEN p.LOSS_RATIO > 0.8 THEN ''ELEVATED''
                WHEN p.LOSS_RATIO > 0.6 THEN ''ELEVATED''
                ELSE ''NORMAL''
            END,
            ''recommended_action'', CASE
                WHEN p.LOSS_RATIO > 0.8 THEN ''Review for premium adjustment''
                WHEN p.LOSS_RATIO > 0.6 THEN ''Monitor closely''
                ELSE ''No action needed''
            END
        )
        FROM INSURANCE_AI_HUB.ANALYTICS.POLICIES p
        LEFT JOIN INSURANCE_AI_HUB.ANALYTICS.CUSTOMERS c ON p.CUSTOMER_ID = c.CUSTOMER_ID
        WHERE p.POLICY_ID = :POLICY_ID
    );
    RETURN :result;
END;
';
