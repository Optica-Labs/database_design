-- ============================================================================
-- Adversarial AI Safety Database Schema
-- ============================================================================
-- This database serves as the single source of truth for an adversarial 
-- AI safety system that tests client models and assesses output safety.
-- ============================================================================
--
-- IMPORTANT NOTES:
-- 1. IDENTITY columns use (1,1) for explicit clarity and consistency.
-- 2. The 'updated_at' fields should be maintained by application code when
--    records are modified. Consider adding UPDATE triggers if automatic
--    timestamp updates are desired.
-- 3. JSON fields (metadata, capabilities, violation_types) use NVARCHAR(MAX)
--    for flexibility. Use JSON_VALUE/JSON_QUERY functions to access data.
-- ============================================================================

-- ============================================================================
-- CORE ENTITIES
-- ============================================================================

-- Table: ai_agents
-- Stores information about AI agents and ML models in the system
CREATE TABLE ai_agents (
    agent_id BIGINT PRIMARY KEY IDENTITY(1,1),
    agent_name NVARCHAR(255) NOT NULL,
    agent_type NVARCHAR(100) NOT NULL, -- e.g., 'adversarial', 'evaluator', 'classifier'
    model_architecture NVARCHAR(255), -- e.g., 'GPT-4', 'Claude', 'BERT'
    version NVARCHAR(50) NOT NULL,
    description NVARCHAR(MAX),
    capabilities NVARCHAR(MAX), -- JSON array of capabilities
    status NVARCHAR(50) NOT NULL DEFAULT 'active', -- 'active', 'inactive', 'deprecated'
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    created_by NVARCHAR(255),
    metadata NVARCHAR(MAX), -- JSON field for additional flexible data
    CONSTRAINT CHK_agent_status CHECK (status IN ('active', 'inactive', 'deprecated')),
    CONSTRAINT CHK_agent_type CHECK (agent_type IN ('adversarial', 'evaluator', 'classifier', 'monitor', 'other'))
);

-- Table: client_models
-- Stores information about client models being tested
CREATE TABLE client_models (
    model_id BIGINT PRIMARY KEY IDENTITY(1,1),
    client_id NVARCHAR(255) NOT NULL,
    model_name NVARCHAR(255) NOT NULL,
    model_version NVARCHAR(50) NOT NULL,
    model_type NVARCHAR(100), -- e.g., 'llm', 'image-gen', 'classification'
    endpoint_url NVARCHAR(500),
    api_key_hash NVARCHAR(255), -- Hashed API key for security
    deployment_environment NVARCHAR(100), -- e.g., 'production', 'staging', 'development'
    registration_date DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    last_tested DATETIME2,
    status NVARCHAR(50) NOT NULL DEFAULT 'registered', -- 'registered', 'active', 'suspended', 'deactivated'
    risk_level NVARCHAR(50), -- 'low', 'medium', 'high', 'critical'
    metadata NVARCHAR(MAX), -- JSON field
    CONSTRAINT CHK_model_status CHECK (status IN ('registered', 'active', 'suspended', 'deactivated')),
    CONSTRAINT CHK_risk_level CHECK (risk_level IN ('low', 'medium', 'high', 'critical', NULL)),
    INDEX IX_client_models_client_id (client_id),
    INDEX IX_client_models_status (status)
);

-- ============================================================================
-- TESTING & ADVERSARIAL FRAMEWORK
-- ============================================================================

-- Table: test_categories
-- Defines categories of safety tests
CREATE TABLE test_categories (
    category_id INT PRIMARY KEY IDENTITY(1,1),
    category_name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(MAX),
    severity_level NVARCHAR(50) NOT NULL, -- 'low', 'medium', 'high', 'critical'
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT CHK_severity CHECK (severity_level IN ('low', 'medium', 'high', 'critical'))
);

-- Table: adversarial_test_cases
-- Stores adversarial prompts and test cases for evaluating models
CREATE TABLE adversarial_test_cases (
    test_case_id BIGINT PRIMARY KEY IDENTITY(1,1),
    category_id INT NOT NULL,
    test_name NVARCHAR(255) NOT NULL,
    test_prompt NVARCHAR(MAX) NOT NULL,
    expected_behavior NVARCHAR(MAX), -- Description of safe/expected behavior
    attack_type NVARCHAR(100), -- e.g., 'jailbreak', 'prompt-injection', 'bias-test', 'toxicity'
    severity NVARCHAR(50) NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_by_agent_id BIGINT,
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    updated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    metadata NVARCHAR(MAX), -- JSON field for test parameters
    FOREIGN KEY (category_id) REFERENCES test_categories(category_id),
    FOREIGN KEY (created_by_agent_id) REFERENCES ai_agents(agent_id),
    CONSTRAINT CHK_test_severity CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    INDEX IX_test_cases_category (category_id),
    INDEX IX_test_cases_active (is_active)
);

-- ============================================================================
-- EXECUTION & RESULTS
-- ============================================================================

-- Table: test_executions
-- Records each execution of a test against a client model
CREATE TABLE test_executions (
    execution_id BIGINT PRIMARY KEY IDENTITY(1,1),
    model_id BIGINT NOT NULL,
    test_case_id BIGINT NOT NULL,
    executing_agent_id BIGINT NOT NULL,
    execution_start DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    execution_end DATETIME2,
    status NVARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'running', 'completed', 'failed', 'timeout'
    error_message NVARCHAR(MAX),
    execution_context NVARCHAR(MAX), -- JSON field for execution parameters
    FOREIGN KEY (model_id) REFERENCES client_models(model_id),
    FOREIGN KEY (test_case_id) REFERENCES adversarial_test_cases(test_case_id),
    FOREIGN KEY (executing_agent_id) REFERENCES ai_agents(agent_id),
    CONSTRAINT CHK_execution_status CHECK (status IN ('pending', 'running', 'completed', 'failed', 'timeout')),
    INDEX IX_executions_model (model_id),
    INDEX IX_executions_test (test_case_id),
    INDEX IX_executions_status (status),
    INDEX IX_executions_start (execution_start)
);

-- Table: model_outputs
-- Stores outputs generated by client models during testing
CREATE TABLE model_outputs (
    output_id BIGINT PRIMARY KEY IDENTITY(1,1),
    execution_id BIGINT NOT NULL,
    output_text NVARCHAR(MAX) NOT NULL,
    output_tokens INT,
    generation_time_ms INT,
    temperature FLOAT,
    other_parameters NVARCHAR(MAX), -- JSON field for model parameters
    created_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (execution_id) REFERENCES test_executions(execution_id),
    INDEX IX_outputs_execution (execution_id)
);

-- ============================================================================
-- SAFETY ASSESSMENT
-- ============================================================================

-- Table: safety_assessments
-- Stores safety evaluations of model outputs
CREATE TABLE safety_assessments (
    assessment_id BIGINT PRIMARY KEY IDENTITY(1,1),
    output_id BIGINT NOT NULL,
    evaluator_agent_id BIGINT NOT NULL,
    safety_score DECIMAL(5,2), -- 0-100 scale
    is_safe BIT NOT NULL,
    risk_level NVARCHAR(50) NOT NULL, -- 'low', 'medium', 'high', 'critical'
    violation_types NVARCHAR(MAX), -- JSON array of detected violations
    reasoning NVARCHAR(MAX), -- Explanation of the assessment
    confidence_score DECIMAL(5,2), -- 0-100 scale, confidence in assessment
    assessed_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    metadata NVARCHAR(MAX), -- JSON field
    FOREIGN KEY (output_id) REFERENCES model_outputs(output_id),
    FOREIGN KEY (evaluator_agent_id) REFERENCES ai_agents(agent_id),
    CONSTRAINT CHK_assessment_risk CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
    CONSTRAINT CHK_safety_score CHECK (safety_score >= 0 AND safety_score <= 100),
    CONSTRAINT CHK_confidence CHECK (confidence_score >= 0 AND confidence_score <= 100),
    INDEX IX_assessments_output (output_id),
    INDEX IX_assessments_safe (is_safe),
    INDEX IX_assessments_risk (risk_level)
);

-- Table: safety_metrics
-- Stores detailed safety metrics for assessments
CREATE TABLE safety_metrics (
    metric_id BIGINT PRIMARY KEY IDENTITY(1,1),
    assessment_id BIGINT NOT NULL,
    metric_name NVARCHAR(100) NOT NULL, -- e.g., 'toxicity', 'bias', 'hallucination'
    metric_value DECIMAL(10,4) NOT NULL,
    metric_unit NVARCHAR(50), -- e.g., 'score', 'percentage', 'count'
    threshold_exceeded BIT NOT NULL DEFAULT 0,
    metadata NVARCHAR(MAX),
    FOREIGN KEY (assessment_id) REFERENCES safety_assessments(assessment_id),
    INDEX IX_metrics_assessment (assessment_id),
    INDEX IX_metrics_name (metric_name)
);

-- ============================================================================
-- AUDIT & COMPLIANCE
-- ============================================================================

-- Table: audit_logs
-- Comprehensive audit trail of all system activities
CREATE TABLE audit_logs (
    log_id BIGINT PRIMARY KEY IDENTITY(1,1),
    event_type NVARCHAR(100) NOT NULL, -- e.g., 'model_registered', 'test_executed', 'assessment_completed'
    entity_type NVARCHAR(100) NOT NULL, -- e.g., 'client_model', 'test_execution', 'safety_assessment'
    entity_id BIGINT NOT NULL,
    actor_type NVARCHAR(100), -- 'agent', 'user', 'system'
    actor_id NVARCHAR(255),
    action NVARCHAR(100) NOT NULL, -- 'create', 'read', 'update', 'delete', 'execute'
    old_values NVARCHAR(MAX), -- JSON field
    new_values NVARCHAR(MAX), -- JSON field
    ip_address NVARCHAR(50),
    user_agent NVARCHAR(500),
    timestamp DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    metadata NVARCHAR(MAX),
    INDEX IX_audit_entity (entity_type, entity_id),
    INDEX IX_audit_actor (actor_type, actor_id),
    INDEX IX_audit_timestamp (timestamp),
    INDEX IX_audit_event (event_type)
);

-- Table: compliance_reports
-- Stores compliance and summary reports
CREATE TABLE compliance_reports (
    report_id BIGINT PRIMARY KEY IDENTITY(1,1),
    report_type NVARCHAR(100) NOT NULL, -- e.g., 'daily_summary', 'model_audit', 'safety_review'
    model_id BIGINT,
    report_period_start DATETIME2 NOT NULL,
    report_period_end DATETIME2 NOT NULL,
    total_tests INT,
    passed_tests INT,
    failed_tests INT,
    critical_issues INT,
    high_issues INT,
    medium_issues INT,
    low_issues INT,
    overall_safety_score DECIMAL(5,2),
    report_data NVARCHAR(MAX), -- JSON field with detailed report data
    generated_by_agent_id BIGINT,
    generated_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (model_id) REFERENCES client_models(model_id),
    FOREIGN KEY (generated_by_agent_id) REFERENCES ai_agents(agent_id),
    INDEX IX_reports_model (model_id),
    INDEX IX_reports_period (report_period_start, report_period_end)
);

-- ============================================================================
-- ALERTS & NOTIFICATIONS
-- ============================================================================

-- Table: safety_alerts
-- Tracks safety alerts and incidents
CREATE TABLE safety_alerts (
    alert_id BIGINT PRIMARY KEY IDENTITY(1,1),
    model_id BIGINT NOT NULL,
    assessment_id BIGINT,
    alert_type NVARCHAR(100) NOT NULL, -- e.g., 'critical_failure', 'repeated_violations', 'pattern_detected'
    severity NVARCHAR(50) NOT NULL,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    status NVARCHAR(50) NOT NULL DEFAULT 'open', -- 'open', 'investigating', 'resolved', 'false_positive'
    detected_at DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    resolved_at DATETIME2,
    resolved_by NVARCHAR(255),
    resolution_notes NVARCHAR(MAX),
    FOREIGN KEY (model_id) REFERENCES client_models(model_id),
    FOREIGN KEY (assessment_id) REFERENCES safety_assessments(assessment_id),
    CONSTRAINT CHK_alert_severity CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    CONSTRAINT CHK_alert_status CHECK (status IN ('open', 'investigating', 'resolved', 'false_positive')),
    INDEX IX_alerts_model (model_id),
    INDEX IX_alerts_status (status),
    INDEX IX_alerts_severity (severity)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Additional composite indexes for common query patterns
CREATE INDEX IX_test_executions_model_status ON test_executions(model_id, status);
CREATE INDEX IX_safety_assessments_risk_date ON safety_assessments(risk_level, assessed_at);
CREATE INDEX IX_client_models_status_risk ON client_models(status, risk_level);

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: vw_latest_model_assessments
-- Shows the latest safety assessment for each model
GO
CREATE VIEW vw_latest_model_assessments AS
SELECT 
    cm.model_id,
    cm.client_id,
    cm.model_name,
    cm.model_version,
    cm.status AS model_status,
    cm.risk_level AS model_risk_level,
    sa.assessment_id,
    sa.safety_score,
    sa.is_safe,
    sa.risk_level AS assessment_risk_level,
    sa.assessed_at,
    sa.confidence_score,
    mo.output_text,
    atc.test_name,
    atc.attack_type
FROM client_models cm
LEFT JOIN test_executions te ON cm.model_id = te.model_id
LEFT JOIN model_outputs mo ON te.execution_id = mo.execution_id
LEFT JOIN safety_assessments sa ON mo.output_id = sa.output_id
LEFT JOIN adversarial_test_cases atc ON te.test_case_id = atc.test_case_id
WHERE sa.assessed_at = (
    SELECT MAX(sa2.assessed_at)
    FROM test_executions te2
    JOIN model_outputs mo2 ON te2.execution_id = mo2.execution_id
    JOIN safety_assessments sa2 ON mo2.output_id = sa2.output_id
    WHERE te2.model_id = cm.model_id
);
GO

-- View: vw_model_safety_summary
-- Provides aggregate safety statistics per model
GO
CREATE VIEW vw_model_safety_summary AS
SELECT 
    cm.model_id,
    cm.client_id,
    cm.model_name,
    cm.model_version,
    cm.status,
    COUNT(DISTINCT te.execution_id) AS total_tests,
    COUNT(DISTINCT CASE WHEN sa.is_safe = 1 THEN te.execution_id END) AS safe_tests,
    COUNT(DISTINCT CASE WHEN sa.is_safe = 0 THEN te.execution_id END) AS unsafe_tests,
    COUNT(DISTINCT CASE WHEN sa.risk_level = 'critical' THEN te.execution_id END) AS critical_risks,
    COUNT(DISTINCT CASE WHEN sa.risk_level = 'high' THEN te.execution_id END) AS high_risks,
    AVG(sa.safety_score) AS avg_safety_score,
    MAX(te.execution_start) AS last_test_date
FROM client_models cm
LEFT JOIN test_executions te ON cm.model_id = te.model_id
LEFT JOIN model_outputs mo ON te.execution_id = mo.execution_id
LEFT JOIN safety_assessments sa ON mo.output_id = sa.output_id
GROUP BY 
    cm.model_id,
    cm.client_id,
    cm.model_name,
    cm.model_version,
    cm.status;
GO

-- View: vw_active_alerts
-- Shows all open safety alerts with context
GO
CREATE VIEW vw_active_alerts AS
SELECT 
    sa.alert_id,
    sa.alert_type,
    sa.severity,
    sa.title,
    sa.status,
    sa.detected_at,
    cm.model_id,
    cm.client_id,
    cm.model_name,
    cm.model_version,
    ass.safety_score,
    ass.risk_level,
    DATEDIFF(HOUR, sa.detected_at, GETUTCDATE()) AS hours_open
FROM safety_alerts sa
JOIN client_models cm ON sa.model_id = cm.model_id
LEFT JOIN safety_assessments ass ON sa.assessment_id = ass.assessment_id
WHERE sa.status IN ('open', 'investigating');
GO
