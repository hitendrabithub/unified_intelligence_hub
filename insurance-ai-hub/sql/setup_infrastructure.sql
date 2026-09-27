-- ============================================================
-- INSURANCE AI HUB - Infrastructure Setup
-- Database, schemas, and warehouse creation
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- Database
CREATE DATABASE IF NOT EXISTS INSURANCE_AI_HUB;

-- Schemas
CREATE SCHEMA IF NOT EXISTS INSURANCE_AI_HUB.ANALYTICS;
CREATE SCHEMA IF NOT EXISTS INSURANCE_AI_HUB.DATA_QUALITY;
CREATE SCHEMA IF NOT EXISTS INSURANCE_AI_HUB.DOCUMENTS;

-- Dedicated warehouse for agent queries
CREATE WAREHOUSE IF NOT EXISTS INSURANCE_AI_HUB_WH
    WAREHOUSE_SIZE = 'X-Small'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    ENABLE_QUERY_ACCELERATION = TRUE
    QUERY_ACCELERATION_MAX_SCALE_FACTOR = 8
    COMMENT = 'Dedicated warehouse for Insurance AI Hub agent queries';
