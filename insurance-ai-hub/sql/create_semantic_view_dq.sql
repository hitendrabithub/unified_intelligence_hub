-- ============================================================================
-- INSURANCE AI HUB - Semantic View: SV_DATA_QUALITY
-- Database: INSURANCE_AI_HUB.DATA_QUALITY
-- Run AFTER all DQ tables are populated
-- ============================================================================

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE SEMANTIC VIEW INSURANCE_AI_HUB.DATA_QUALITY.SV_DATA_QUALITY

  TABLES (
    INSURANCE_AI_HUB.DATA_QUALITY.DQ_RULES
      PRIMARY KEY (RULE_ID)
      COMMENT = 'Data quality rules',
    INSURANCE_AI_HUB.DATA_QUALITY.DQ_RESULTS
      PRIMARY KEY (RESULT_ID)
      COMMENT = 'DQ rule execution results',
    INSURANCE_AI_HUB.DATA_QUALITY.DQ_SCORES
      PRIMARY KEY (SCORE_ID)
      COMMENT = 'Quality scores per table over time',
    INSURANCE_AI_HUB.DATA_QUALITY.DQ_COLUMN_HEALTH
      PRIMARY KEY (HEALTH_ID)
      COMMENT = 'Column-level health metrics'
  )

  RELATIONSHIPS (
    RESULT_TO_RULE AS DQ_RESULTS(RULE_ID) REFERENCES DQ_RULES(RULE_ID)
  )

  DIMENSIONS (
    DQ_RULES.RULE_NAME AS RULE_NAME
      WITH SYNONYMS = ('rule', 'validation')
      COMMENT = 'Name of the DQ rule',
    DQ_RULES.TARGET_TABLE AS TARGET_TABLE
      WITH SYNONYMS = ('table')
      COMMENT = 'Table this rule validates',
    DQ_RULES.TARGET_COLUMN AS TARGET_COLUMN
      WITH SYNONYMS = ('column')
      COMMENT = 'Column this rule validates',
    DQ_RULES.RULE_TYPE AS RULE_TYPE
      COMMENT = 'Validation type',
    DQ_RULES.SEVERITY AS SEVERITY
      COMMENT = 'Critical High Medium Low',
    DQ_RULES.RULE_IS_CRITICAL AS DQ_RULES."IS_CRITICAL"
      COMMENT = 'Whether rule is critical',

    DQ_RESULTS.RESULT_STATUS AS DQ_RESULTS."STATUS"
      WITH SYNONYMS = ('pass or fail', 'outcome')
      COMMENT = 'PASS or FAIL',
    DQ_RESULTS.EXECUTION_DATE AS EXECUTION_DATE
      WITH SYNONYMS = ('run date')
      COMMENT = 'When the rule ran',
    DQ_RESULTS.PASS_RATE AS PASS_RATE
      WITH SYNONYMS = ('success rate')
      COMMENT = 'Pct records passing',
    DQ_RESULTS.TOTAL_RECORDS AS TOTAL_RECORDS
      COMMENT = 'Total records evaluated',
    DQ_RESULTS.FAILED_RECORDS AS FAILED_RECORDS
      COMMENT = 'Records that failed',
    DQ_RESULTS.ERROR_SAMPLE AS ERROR_SAMPLE
      COMMENT = 'Sample of failing values',

    DQ_SCORES.SCORE_TABLE AS DQ_SCORES."TABLE_NAME"
      WITH SYNONYMS = ('scored table')
      COMMENT = 'Table name for scoring',
    DQ_SCORES.SCORE_DATE AS SCORE_DATE
      WITH SYNONYMS = ('date')
      COMMENT = 'Quality snapshot date',
    DQ_SCORES.SCORE_TREND AS DQ_SCORES."TREND"
      COMMENT = 'UP DOWN STABLE',
    DQ_SCORES.OVERALL_SCORE AS OVERALL_SCORE
      WITH SYNONYMS = ('quality score', 'DQ score')
      COMMENT = 'Overall quality score',
    DQ_SCORES.COMPLETENESS_SCORE AS COMPLETENESS_SCORE
      COMMENT = 'Completeness score',
    DQ_SCORES.ACCURACY_SCORE AS ACCURACY_SCORE
      COMMENT = 'Accuracy score',
    DQ_SCORES.CONSISTENCY_SCORE AS CONSISTENCY_SCORE
      COMMENT = 'Consistency score',
    DQ_SCORES.RULES_PASSED AS RULES_PASSED
      COMMENT = 'Rules that passed',
    DQ_SCORES.RULES_FAILED AS RULES_FAILED
      COMMENT = 'Rules that failed',

    DQ_COLUMN_HEALTH.HEALTH_TABLE AS DQ_COLUMN_HEALTH."TABLE_NAME"
      COMMENT = 'Table for column health',
    DQ_COLUMN_HEALTH.HEALTH_COLUMN AS DQ_COLUMN_HEALTH."COLUMN_NAME"
      COMMENT = 'Column assessed',
    DQ_COLUMN_HEALTH.HEALTH_STATUS AS HEALTH_STATUS
      COMMENT = 'Healthy Warning Critical',
    DQ_COLUMN_HEALTH.CRITICAL_COL AS DQ_COLUMN_HEALTH."IS_CRITICAL"
      COMMENT = 'Whether column is critical',
    DQ_COLUMN_HEALTH.NULL_PCT AS NULL_PCT
      COMMENT = 'Pct of null values',
    DQ_COLUMN_HEALTH.DUPLICATE_PCT AS DUPLICATE_PCT
      COMMENT = 'Pct of duplicates',
    DQ_COLUMN_HEALTH.OUTLIER_COUNT AS OUTLIER_COUNT
      COMMENT = 'Number of outliers',
    DQ_COLUMN_HEALTH.COL_HEALTH_SCORE AS DQ_COLUMN_HEALTH."SCORE"
      COMMENT = 'Column health score'
  )

  METRICS (
    DQ_RESULTS.AVG_PASS_RATE AS AVG(DQ_RESULTS.PASS_RATE)
      COMMENT = 'Average pass rate',
    DQ_RESULTS.FAILED_RULE_COUNT AS COUNT_IF(DQ_RESULTS."STATUS" = 'FAIL')
      COMMENT = 'Failing rules count',
    DQ_SCORES.AVG_OVERALL AS AVG(DQ_SCORES.OVERALL_SCORE)
      COMMENT = 'Average DQ score'
  )

  COMMENT = 'Data quality monitoring for root-cause analysis';
