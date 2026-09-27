-- ============================================================
-- INSURANCE AI HUB - Cortex Search Service
-- Policy document search service for RAG-based retrieval
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE INSURANCE_AI_HUB;
USE SCHEMA DOCUMENTS;

CREATE OR REPLACE CORTEX SEARCH SERVICE POLICY_DOC_SEARCH
    ON CHUNK_TEXT
    ATTRIBUTES SECTION_TITLE, DOCUMENT_ID
    WAREHOUSE = 'COMPUTE_WH'
    TARGET_LAG = '1 hour'
    REFRESH_MODE = INCREMENTAL
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
