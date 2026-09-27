-- ============================================================================
-- INSURANCE AI HUB - DML for Missing Tables (6 tables)
-- Database: INSURANCE_AI_HUB
-- Run AFTER 5_INSURANCE_AI_HUB_DDL_MISSING_TABLES.sql
-- ============================================================================


-- ############################################################################
-- SECTION 1: PRODUCTS (20 rows)
-- ############################################################################

INSERT INTO INSURANCE_AI_HUB.ANALYTICS.PRODUCTS
(PRODUCT_ID, PRODUCT_NAME, POLICY_TYPE, PLAN_TIER, BASE_PREMIUM, COVERAGE_MIN, COVERAGE_MAX,
 DEDUCTIBLE_OPTIONS, ELIGIBLE_SEGMENTS, ELIGIBLE_RISK_TIERS, MIN_CREDIT_SCORE, MIN_AGE, MAX_AGE, ELIGIBLE_STATES, IS_ACTIVE)
VALUES
('PROD-001','Essential Auto Protection','Auto','Bronze',85.00,25000.00,100000.00,PARSE_JSON('[500,1000,2500]'),PARSE_JSON('["Individual","Family"]'),PARSE_JSON('["Low","Medium","High"]'),580,18,75,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-002','Premium Auto Shield','Auto','Gold',165.00,100000.00,500000.00,PARSE_JSON('[250,500,1000]'),PARSE_JSON('["Individual","Family","Corporate"]'),PARSE_JSON('["Low","Medium"]'),650,21,70,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-003','Elite Auto Complete','Auto','Platinum',250.00,250000.00,1000000.00,PARSE_JSON('[0,250,500]'),PARSE_JSON('["Corporate","Family"]'),PARSE_JSON('["Low"]'),720,25,65,PARSE_JSON('["CA","NY","FL","TX","IL"]'),TRUE),
('PROD-004','Auto Value Starter','Auto','Silver',120.00,50000.00,200000.00,PARSE_JSON('[500,1000]'),PARSE_JSON('["Individual","Senior"]'),PARSE_JSON('["Low","Medium","High","Very High"]'),550,16,80,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-005','Basic Health Cover','Health','Bronze',150.00,50000.00,250000.00,PARSE_JSON('[1000,2500,5000]'),PARSE_JSON('["Individual"]'),PARSE_JSON('["Low","Medium","High","Very High"]'),500,18,64,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-006','Family Health Plus','Health','Gold',320.00,250000.00,1000000.00,PARSE_JSON('[500,1000,2500]'),PARSE_JSON('["Family","Individual"]'),PARSE_JSON('["Low","Medium"]'),620,18,64,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA"]'),TRUE),
('PROD-007','Corporate Health Elite','Health','Platinum',480.00,500000.00,2000000.00,PARSE_JSON('[0,250,500]'),PARSE_JSON('["Corporate"]'),PARSE_JSON('["Low","Medium"]'),680,21,64,PARSE_JSON('["CA","TX","FL","NY","IL"]'),TRUE),
('PROD-008','Senior Health Advantage','Health','Silver',220.00,100000.00,500000.00,PARSE_JSON('[500,1000]'),PARSE_JSON('["Senior","Individual"]'),PARSE_JSON('["Low","Medium","High"]'),550,55,80,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-009','Homeowner Basic','Home','Bronze',95.00,100000.00,300000.00,PARSE_JSON('[1000,2500,5000]'),PARSE_JSON('["Individual","Family"]'),PARSE_JSON('["Low","Medium","High"]'),600,21,75,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-010','Homeowner Premium','Home','Gold',180.00,300000.00,750000.00,PARSE_JSON('[500,1000,2500]'),PARSE_JSON('["Family","Corporate"]'),PARSE_JSON('["Low","Medium"]'),660,25,70,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA"]'),TRUE),
('PROD-011','Estate Protection Platinum','Home','Platinum',350.00,750000.00,2500000.00,PARSE_JSON('[0,250,500]'),PARSE_JSON('["Corporate","Family"]'),PARSE_JSON('["Low"]'),740,30,65,PARSE_JSON('["CA","NY","FL","TX"]'),TRUE),
('PROD-012','Home Value Shield','Home','Silver',135.00,150000.00,500000.00,PARSE_JSON('[1000,2500]'),PARSE_JSON('["Individual","Senior"]'),PARSE_JSON('["Low","Medium","High"]'),580,21,80,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-013','Term Life Essential','Life','Bronze',45.00,100000.00,500000.00,PARSE_JSON('[0]'),PARSE_JSON('["Individual","Family"]'),PARSE_JSON('["Low","Medium","High","Very High"]'),500,18,65,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-014','Whole Life Gold','Life','Gold',120.00,250000.00,1000000.00,PARSE_JSON('[0]'),PARSE_JSON('["Family","Individual"]'),PARSE_JSON('["Low","Medium"]'),640,21,60,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA"]'),TRUE),
('PROD-015','Universal Life Platinum','Life','Platinum',200.00,500000.00,5000000.00,PARSE_JSON('[0]'),PARSE_JSON('["Corporate","Family"]'),PARSE_JSON('["Low"]'),720,25,55,PARSE_JSON('["CA","NY","FL","TX","IL"]'),TRUE),
('PROD-016','Life Protect Silver','Life','Silver',75.00,200000.00,750000.00,PARSE_JSON('[0]'),PARSE_JSON('["Individual","Senior"]'),PARSE_JSON('["Low","Medium","High"]'),560,18,70,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-017','Corporate Fleet Auto','Auto','Gold',300.00,500000.00,2000000.00,PARSE_JSON('[500,1000]'),PARSE_JSON('["Corporate"]'),PARSE_JSON('["Low","Medium"]'),680,25,65,PARSE_JSON('["CA","TX","FL","NY","IL"]'),TRUE),
('PROD-018','Young Driver Auto','Auto','Bronze',110.00,25000.00,150000.00,PARSE_JSON('[1000,2500]'),PARSE_JSON('["Individual"]'),PARSE_JSON('["Medium","High","Very High"]'),500,16,25,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE),
('PROD-019','Family Wellness Health','Health','Gold',380.00,300000.00,1500000.00,PARSE_JSON('[250,500,1000]'),PARSE_JSON('["Family"]'),PARSE_JSON('["Low","Medium"]'),640,25,64,PARSE_JSON('["CA","TX","FL","NY","IL","OH"]'),TRUE),
('PROD-020','Retiree Life Security','Life','Silver',90.00,100000.00,500000.00,PARSE_JSON('[0]'),PARSE_JSON('["Senior"]'),PARSE_JSON('["Low","Medium","High"]'),550,60,80,PARSE_JSON('["CA","TX","FL","NY","IL","OH","PA","GA","NC","MI"]'),TRUE);


-- ############################################################################
-- SECTION 2: PRODUCT_FEATURES (80 rows - 4 features per product)
-- ############################################################################

INSERT INTO INSURANCE_AI_HUB.ANALYTICS.PRODUCT_FEATURES
(FEATURE_ID, PRODUCT_ID, FEATURE_NAME, FEATURE_CATEGORY, FEATURE_WEIGHT, FEATURE_VALUE)
SELECT
    'FT-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    'PROD-' || LPAD(TRUNC(SEQ4() / 4)::VARCHAR, 3, '0'),
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN CASE MOD(TRUNC(SEQ4()/4), 4) WHEN 0 THEN 'Collision Coverage' WHEN 1 THEN 'Hospitalization' WHEN 2 THEN 'Dwelling Coverage' ELSE 'Death Benefit' END
        WHEN 1 THEN CASE MOD(TRUNC(SEQ4()/4), 4) WHEN 0 THEN 'Roadside Assistance' WHEN 1 THEN 'Prescription Coverage' WHEN 2 THEN 'Personal Property' ELSE 'Cash Value Growth' END
        WHEN 2 THEN CASE MOD(TRUNC(SEQ4()/4), 4) WHEN 0 THEN 'Rental Reimbursement' WHEN 1 THEN 'Preventive Care' WHEN 2 THEN 'Liability Protection' ELSE 'Beneficiary Flexibility' END
        ELSE CASE MOD(TRUNC(SEQ4()/4), 4) WHEN 0 THEN 'Uninsured Motorist' WHEN 1 THEN 'Mental Health Parity' WHEN 2 THEN 'Natural Disaster' ELSE 'Premium Waiver' END
    END,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Coverage' WHEN 1 THEN 'Service' WHEN 2 THEN 'Service' ELSE 'Coverage'
    END,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 0.9 WHEN 1 THEN 0.6 WHEN 2 THEN 0.4 ELSE 0.8
    END,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Full' WHEN 1 THEN '24/7' WHEN 2 THEN 'Up to $50/day' ELSE 'Included'
    END
FROM TABLE(GENERATOR(ROWCOUNT => 80))
WHERE TRUNC(SEQ4() / 4) < 20;


-- ############################################################################
-- SECTION 3: COMPETITOR_RATES (192 rows)
-- 4 competitors × 4 policy types × 4 plan tiers × 3 regions
-- ############################################################################

INSERT INTO INSURANCE_AI_HUB.ANALYTICS.COMPETITOR_RATES
(RATE_ID, COMPETITOR_NAME, POLICY_TYPE, PLAN_TIER, REGION, BENCHMARK_PREMIUM, BENCHMARK_DEDUCTIBLE, BENCHMARK_COVERAGE, EFFECTIVE_DATE, SOURCE)
SELECT
    'CR-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Competitor A' WHEN 1 THEN 'Competitor B' WHEN 2 THEN 'Competitor C' ELSE 'Market Average' END,
    CASE MOD(TRUNC(SEQ4()/4), 4) WHEN 0 THEN 'Auto' WHEN 1 THEN 'Health' WHEN 2 THEN 'Home' ELSE 'Life' END,
    CASE MOD(TRUNC(SEQ4()/16), 4) WHEN 0 THEN 'Bronze' WHEN 1 THEN 'Silver' WHEN 2 THEN 'Gold' ELSE 'Platinum' END,
    CASE MOD(TRUNC(SEQ4()/64), 3) WHEN 0 THEN 'Midwest' WHEN 1 THEN 'Northeast' ELSE 'West' END,
    ROUND(UNIFORM(45, 500, RANDOM()), 2),
    ROUND(UNIFORM(250, 5000, RANDOM()), 2),
    ROUND(UNIFORM(25000, 500000, RANDOM()), 2),
    '2026-09-01',
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Competitor A Public Filings' WHEN 1 THEN 'Competitor B Public Filings' WHEN 2 THEN 'Competitor C Public Filings' ELSE 'Industry Report Q3 2026' END
FROM TABLE(GENERATOR(ROWCOUNT => 192));


-- ############################################################################
-- SECTION 4: MARKET_TRENDS (384 rows)
-- 8 metrics × 4 regions × 12 months
-- ############################################################################

INSERT INTO INSURANCE_AI_HUB.ANALYTICS.MARKET_TRENDS
(TREND_ID, METRIC_NAME, METRIC_CATEGORY, REGION, PERIOD_DATE, METRIC_VALUE, PRIOR_PERIOD_VALUE, CHANGE_PCT, TREND_DIRECTION)
SELECT
    'MT-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    CASE MOD(SEQ4(), 8)
        WHEN 0 THEN 'avg_coverage_amount' WHEN 1 THEN 'avg_premium' WHEN 2 THEN 'claim_frequency'
        WHEN 3 THEN 'loss_ratio_index' WHEN 4 THEN 'customer_retention_rate' WHEN 5 THEN 'new_policy_growth'
        WHEN 6 THEN 'churn_rate' ELSE 'market_share_index'
    END,
    CASE MOD(SEQ4(), 8)
        WHEN 0 THEN 'Pricing' WHEN 1 THEN 'Pricing' WHEN 2 THEN 'Claims'
        WHEN 3 THEN 'Claims' WHEN 4 THEN 'Retention' WHEN 5 THEN 'Growth'
        WHEN 6 THEN 'Retention' ELSE 'Growth'
    END,
    CASE MOD(TRUNC(SEQ4()/8), 4) WHEN 0 THEN 'Midwest' WHEN 1 THEN 'Northeast' WHEN 2 THEN 'Southeast' ELSE 'West' END,
    DATEADD(MONTH, MOD(TRUNC(SEQ4()/32), 12), '2025-10-01'),
    ROUND(UNIFORM(10000, 500000, RANDOM())::FLOAT, 0),
    ROUND(UNIFORM(10000, 500000, RANDOM())::FLOAT, 0),
    ROUND(UNIFORM(-10, 15, RANDOM())::FLOAT, 0),
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'UP' WHEN 1 THEN 'DOWN' ELSE 'STABLE' END
FROM TABLE(GENERATOR(ROWCOUNT => 384));


-- ############################################################################
-- SECTION 5: RECOMMENDATIONS (300 rows)
-- ############################################################################

INSERT INTO INSURANCE_AI_HUB.ANALYTICS.RECOMMENDATIONS
(RECOMMENDATION_ID, CUSTOMER_ID, PRODUCT_ID, MATCH_SCORE, ELIGIBILITY_PASS, RULE_SCORE, SIMILARITY_SCORE,
 RANK, EXPLANATION, RECOMMENDED_BY, RECOMMENDED_AT, STATUS)
SELECT
    'REC-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    'CUST-' || LPAD(UNIFORM(0, 199, RANDOM())::VARCHAR, 5, '0'),
    'PROD-' || LPAD(UNIFORM(1, 20, RANDOM())::VARCHAR, 3, '0'),
    UNIFORM(40, 98, RANDOM()),
    CASE WHEN UNIFORM(0, 1, RANDOM()) > 0.25 THEN TRUE ELSE FALSE END,
    ROUND(UNIFORM(0.1, 1.0, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(0.1, 1.0, RANDOM())::FLOAT, 2),
    MOD(SEQ4(), 5) + 1,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'Customer risk tier and credit score align with product eligibility. High coverage match.'
        WHEN 1 THEN 'Customer segment is Corporate; product targets corporate clients with premium features.'
        WHEN 2 THEN 'Similar customers in the same region have historically chosen this product with high satisfaction.'
        WHEN 3 THEN 'Product tier matches customer spending pattern. Deductible options fit risk tolerance.'
        WHEN 4 THEN 'Age and geographic eligibility confirmed. Coverage range matches customer needs.'
        ELSE 'Multi-factor match: credit score, segment, region, and coverage all align.'
    END,
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'ProductMatchAgent' WHEN 1 THEN 'ManualReview' ELSE 'BatchMatchProcess' END,
    DATEADD(DAY, -UNIFORM(1, 120, RANDOM()), CURRENT_TIMESTAMP()),
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'Accepted' WHEN 1 THEN 'Accepted' WHEN 2 THEN 'Rejected' WHEN 3 THEN 'Pending' ELSE 'Expired' END
FROM TABLE(GENERATOR(ROWCOUNT => 300));


-- ############################################################################
-- SECTION 6: RECOMMENDATION_FEEDBACK (180 rows)
-- ############################################################################

INSERT INTO INSURANCE_AI_HUB.ANALYTICS.RECOMMENDATION_FEEDBACK
(FEEDBACK_ID, RECOMMENDATION_ID, CUSTOMER_ID, ACCEPTED, FEEDBACK_RATING, FEEDBACK_TEXT, CONVERSION_DATE)
SELECT
    'FB-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    'REC-' || LPAD(UNIFORM(0, 299, RANDOM())::VARCHAR, 5, '0'),
    'CUST-' || LPAD(UNIFORM(0, 199, RANDOM())::VARCHAR, 5, '0'),
    CASE WHEN UNIFORM(0, 1, RANDOM()) > 0.35 THEN TRUE ELSE FALSE END,
    UNIFORM(1, 5, RANDOM()),
    CASE MOD(SEQ4(), 8)
        WHEN 0 THEN 'Coverage amount was the right range for my needs.'
        WHEN 1 THEN 'Premium was too high for my budget.'
        WHEN 2 THEN 'Product features aligned well with my family needs.'
        WHEN 3 THEN 'Not relevant to my current situation.'
        WHEN 4 THEN 'Good recommendation, agent explained the benefits clearly.'
        WHEN 5 THEN 'Deductible options were flexible enough.'
        WHEN 6 THEN 'Would prefer a lower-tier product with basic coverage.'
        ELSE 'Exactly what I was looking for. Signed up immediately.'
    END,
    CASE WHEN UNIFORM(0, 1, RANDOM()) > 0.35 THEN DATEADD(DAY, -UNIFORM(1, 90, RANDOM()), CURRENT_DATE()) ELSE NULL END
FROM TABLE(GENERATOR(ROWCOUNT => 180));


-- ============================================================================
-- END OF MISSING TABLES DML
-- ============================================================================
