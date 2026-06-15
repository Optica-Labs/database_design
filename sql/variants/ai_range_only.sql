-- GENERATED FILE -- DO NOT EDIT BY HAND.
-- Regenerate: python3 scripts/generate_variants.py
-- Source of truth: docs/verification/LIVE_SCHEMA_DDL_COMPACT.sql
-- Subset of the canonical schema; membership: sql/variants/manifests.json.

SET search_path = public;

-- ==========================================================================
-- SEQUENCES
-- ==========================================================================

CREATE SEQUENCE IF NOT EXISTS public.adversarial_test_cases_test_case_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.ai_agents_agent_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.audit_logs_log_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.behavioral_traits_catalog_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.client_models_model_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.compliance_reports_report_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.crawls_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.demographic_traits_catalog_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.generation_runs_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.linguistic_traits_catalog_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.model_outputs_output_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.product_usage_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.psychographic_traits_catalog_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.quality_metrics_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.raw_items_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.safety_alerts_alert_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.safety_assessments_assessment_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.safety_metrics_metric_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.scenario_seeds_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.sources_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.technographic_traits_catalog_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.telemetry_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.test_categories_category_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.test_executions_execution_id_seq;

-- ==========================================================================
-- TABLES
-- ==========================================================================

CREATE TABLE IF NOT EXISTS public."adversarial_test_cases" (
    "test_case_id" bigint DEFAULT nextval('adversarial_test_cases_test_case_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "category_id" integer,
    "test_name" text NOT NULL,
    "test_prompt" text NOT NULL,
    "expected_behavior" text,
    "attack_type" text,
    "severity" text NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_by_agent_id" bigint,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "metadata" jsonb
);

CREATE TABLE IF NOT EXISTS public."ai_agents" (
    "agent_id" bigint DEFAULT nextval('ai_agents_agent_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "agent_name" text NOT NULL,
    "agent_type" text NOT NULL,
    "model_architecture" text,
    "version" text NOT NULL,
    "description" text,
    "capabilities" jsonb,
    "status" text DEFAULT 'active'::text NOT NULL,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "created_by" text,
    "metadata" jsonb
);

CREATE TABLE IF NOT EXISTS public."ai_test_results" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "session_id" uuid,
    "test_type_id" text,
    "persona_id" text,
    "scenario_id" text,
    "status" text,
    "severity" text,
    "findings" text[] DEFAULT ARRAY[]::text[],
    "evidence" text,
    "recommendations" text[] DEFAULT ARRAY[]::text[],
    "tags" text[] DEFAULT ARRAY[]::text[],
    "executed_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "duration_ms" integer,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."peregrine_audit_logs" (
    "log_id" bigint DEFAULT nextval('audit_logs_log_id_seq'::regclass) NOT NULL,
    "event_type" text NOT NULL,
    "entity_type" text NOT NULL,
    "entity_id" bigint NOT NULL,
    "actor_type" text,
    "actor_id" text,
    "action" text NOT NULL,
    "old_values" jsonb,
    "new_values" jsonb,
    "ip_address" text,
    "user_agent" text,
    "timestamp" timestamp with time zone DEFAULT now(),
    "metadata" jsonb,
    "archived" boolean DEFAULT false NOT NULL,
    "tenant_id" uuid
);

CREATE TABLE IF NOT EXISTS public."peregrine_conversations" (
    "id" text NOT NULL,
    "ground_truth_id" text,
    "product_id" uuid,
    "data" jsonb DEFAULT '{}'::jsonb NOT NULL,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "gold_dataset" boolean DEFAULT false,
    "final_rho_p" double precision,
    "robustness_classification" text,
    "is_robust" boolean,
    "final_cumulative_model_risk_c_m" double precision,
    "final_cumulative_user_risk_c_u" double precision,
    "total_turns" integer,
    "archived" boolean DEFAULT false NOT NULL,
    "tenant_id" uuid,
    "conversation_type" text DEFAULT 'standard'::text,
    "model_name" text,
    "user_id" text,
    "session_id" text,
    "status" text DEFAULT 'active'::text,
    "summary_text" text DEFAULT ''::text,
    "summary_updated_at" timestamp with time zone,
    "summarized_turn_count" integer DEFAULT 0,
    "summary_version" integer DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public."peregrine_generation_runs" (
    "id" bigint DEFAULT nextval('generation_runs_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "generation_run_id" uuid NOT NULL,
    "modality" character varying(50) DEFAULT 'text'::character varying,
    "tags" jsonb DEFAULT '[]'::jsonb,
    "plan_metadata" jsonb,
    "coverage_map" jsonb,
    "adaptive_weights" jsonb,
    "status" character varying(50) DEFAULT 'in_progress'::character varying,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "archived" boolean DEFAULT false NOT NULL,
    "tenant_id" uuid
);

CREATE TABLE IF NOT EXISTS public."peregrine_telemetry" (
    "id" bigint DEFAULT nextval('telemetry_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "generation_run_id" bigint NOT NULL,
    "ingression_time" timestamp with time zone DEFAULT now(),
    "egression_time" timestamp with time zone DEFAULT now(),
    "total_entries" integer DEFAULT 0,
    "total_prompt_tokens" integer DEFAULT 0,
    "total_response_tokens" integer DEFAULT 0,
    "total_tokens" integer DEFAULT 0,
    "average_latency_ms" double precision DEFAULT 0.0,
    "success_rate" double precision,
    "repair_rate" double precision,
    "reject_rate" double precision,
    "avg_iterations" double precision,
    "strategy_coverage" jsonb,
    "topic_coverage" jsonb,
    "models_used" jsonb DEFAULT '{}'::jsonb,
    "feature_flags" jsonb DEFAULT '[]'::jsonb,
    "audit_trail_ids" jsonb DEFAULT '[]'::jsonb,
    "retention_policy" character varying(255) DEFAULT ''::character varying,
    "deletion_date" timestamp with time zone,
    "errors" jsonb DEFAULT '[]'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "telemetry_id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "archived" boolean DEFAULT false NOT NULL,
    "tenant_id" uuid
);

CREATE TABLE IF NOT EXISTS public."peregrine_turns" (
    "id" text NOT NULL,
    "conversation_id" text NOT NULL,
    "product_id" uuid,
    "turn_data" jsonb NOT NULL,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "turn_number" integer,
    "risk_severity_r_n" double precision,
    "risk_rate_v_n" double precision,
    "guardrail_erosion_a_n" double precision,
    "likelihood_l_n" double precision,
    "robustness_rho" double precision,
    "cumulative_risk_model_c_m" double precision,
    "cumulative_risk_user_c_u" double precision,
    "failure_potential_z_n" double precision,
    "risk_severity_user_r_u" double precision,
    "toxic_sycophancy_t_syc" double precision,
    "user_risk_r_syc" double precision,
    "agreement_score_a_syc" double precision,
    "pca_metadata_id" text,
    "prompt" text,
    "response" text,
    "archived" boolean DEFAULT false NOT NULL,
    "tenant_id" uuid,
    "user_message" text,
    "model_response" text,
    "model_name" text,
    "api_response_time_ms" double precision,
    "tokens_used" integer
);

CREATE TABLE IF NOT EXISTS public."behavioral_traits_catalog" (
    "id" bigint DEFAULT nextval('behavioral_traits_catalog_id_seq'::regclass) NOT NULL,
    "key" text NOT NULL,
    "label" text NOT NULL,
    "data_type" text DEFAULT 'text'::text NOT NULL,
    "allowed_values" jsonb,
    "description" text,
    "persona_type" text DEFAULT 'regular'::text,
    "applicable_sub_cohorts" jsonb DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS public."client_model_products" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "model_id" bigint NOT NULL,
    "product_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "enabled" boolean DEFAULT true,
    "configuration" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."client_models" (
    "model_id" bigint DEFAULT nextval('client_models_model_id_seq'::regclass) NOT NULL,
    "tenant_id" uuid,
    "client_id" text NOT NULL,
    "model_name" text NOT NULL,
    "model_version" text NOT NULL,
    "model_type" text,
    "endpoint_url" text,
    "api_key_hash" text,
    "deployment_environment" text,
    "registration_date" timestamp with time zone DEFAULT now(),
    "last_tested" timestamp with time zone,
    "status" text DEFAULT 'registered'::text NOT NULL,
    "risk_level" text,
    "metadata" jsonb
);

CREATE TABLE IF NOT EXISTS public."client_product_subscriptions" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "product_id" uuid NOT NULL,
    "subscription_tier" text,
    "subscription_status" text DEFAULT 'active'::text NOT NULL,
    "start_date" timestamp with time zone DEFAULT now(),
    "end_date" timestamp with time zone,
    "usage_limits" jsonb DEFAULT '{}'::jsonb,
    "features_enabled" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "metadata" jsonb DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS public."cohorts" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "use_case_id" uuid,
    "name" text NOT NULL,
    "description" text,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."compliance_reports" (
    "report_id" bigint DEFAULT nextval('compliance_reports_report_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "report_type" text NOT NULL,
    "model_id" bigint,
    "report_period_start" timestamp with time zone NOT NULL,
    "report_period_end" timestamp with time zone NOT NULL,
    "total_tests" integer,
    "passed_tests" integer,
    "failed_tests" integer,
    "critical_issues" integer,
    "high_issues" integer,
    "medium_issues" integer,
    "low_issues" integer,
    "overall_safety_score" numeric(5,2),
    "report_data" jsonb,
    "generated_by_agent_id" bigint,
    "generated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."context_profiles" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "source_intake_id" text NOT NULL,
    "tenant_id" uuid,
    "industry" text NOT NULL,
    "primary_use_case" text NOT NULL,
    "objectives" text[] DEFAULT '{}'::text[],
    "goals" text,
    "guardrails" text[] DEFAULT '{}'::text[],
    "frameworks" text[] DEFAULT '{}'::text[],
    "policies" text[] DEFAULT '{}'::text[],
    "legal_regulatory" text[] DEFAULT '{}'::text[],
    "api_endpoints" text[] DEFAULT '{}'::text[],
    "endpoint_url" text,
    "model_stack" text[] DEFAULT '{}'::text[],
    "ml_stack" text,
    "custom_models" text,
    "guardrails_endpoint" text,
    "guardrails_auth" text,
    "api_access_level" text,
    "integration_scan" text,
    "personas_seed" text[] DEFAULT '{}'::text[],
    "risks_seed" text[] DEFAULT '{}'::text[],
    "regular_users_type" text[] DEFAULT '{}'::text[],
    "regular_users" text,
    "attackers_type" text[] DEFAULT '{}'::text[],
    "attackers" text,
    "ai_agents_type" text[] DEFAULT '{}'::text[],
    "ai_agents" text,
    "user_distribution" text,
    "plans" jsonb DEFAULT '{}'::jsonb,
    "notes" text,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."crawls" (
    "id" bigint DEFAULT nextval('crawls_id_seq'::regclass) NOT NULL,
    "source_id" bigint,
    "started_at" timestamp with time zone DEFAULT now(),
    "finished_at" timestamp with time zone,
    "status" text,
    "stats" jsonb
);

CREATE TABLE IF NOT EXISTS public."demographic_traits_catalog" (
    "id" bigint DEFAULT nextval('demographic_traits_catalog_id_seq'::regclass) NOT NULL,
    "key" text NOT NULL,
    "label" text NOT NULL,
    "data_type" text DEFAULT 'text'::text NOT NULL,
    "allowed_values" jsonb,
    "description" text,
    "persona_type" text DEFAULT 'regular'::text,
    "applicable_sub_cohorts" jsonb DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS public."harms" (
    "id" text NOT NULL,
    "product_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "embedding" vector
);

CREATE TABLE IF NOT EXISTS public."linguistic_traits_catalog" (
    "id" bigint DEFAULT nextval('linguistic_traits_catalog_id_seq'::regclass) NOT NULL,
    "key" text NOT NULL,
    "label" text NOT NULL,
    "data_type" text DEFAULT 'text'::text NOT NULL,
    "allowed_values" jsonb,
    "description" text,
    "persona_type" text DEFAULT 'regular'::text
);

CREATE TABLE IF NOT EXISTS public."model_outputs" (
    "output_id" bigint DEFAULT nextval('model_outputs_output_id_seq'::regclass) NOT NULL,
    "execution_id" bigint,
    "output_text" text NOT NULL,
    "output_tokens" integer,
    "generation_time_ms" integer,
    "temperature" double precision,
    "other_parameters" jsonb,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."model_response_cache" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "cache_key" text NOT NULL,
    "model_type" text NOT NULL,
    "request_input" jsonb NOT NULL,
    "response_output" jsonb NOT NULL,
    "request_hash" text NOT NULL,
    "hit_count" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "expires_at" timestamp without time zone DEFAULT (now() + '01:00:00'::interval)
);

CREATE TABLE IF NOT EXISTS public."nyc_test_results" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "prompt_response_id" uuid,
    "session_id" text,
    "persona_id" text,
    "persona_name" text,
    "test_type" text,
    "prompt" text,
    "response" jsonb,
    "execution_time_ms" integer,
    "success" boolean,
    "error_message" text,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."persona_actions" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "persona_id" text,
    "ts" timestamp with time zone DEFAULT now(),
    "input" text,
    "output" text,
    "metadata" jsonb
);

CREATE TABLE IF NOT EXISTS public."persona_behavioral_traits" (
    "persona_id" text NOT NULL,
    "trait_id" bigint NOT NULL,
    "raw_value" text,
    "value" jsonb,
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."persona_demographics" (
    "persona_id" text NOT NULL,
    "trait_id" bigint NOT NULL,
    "raw_value" text,
    "value" jsonb,
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."persona_linguistic_traits" (
    "persona_id" text NOT NULL,
    "trait_id" bigint NOT NULL,
    "raw_value" text,
    "value" jsonb,
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."persona_memories" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "persona_id" text,
    "ts" timestamp with time zone DEFAULT now(),
    "type" text,
    "content" text NOT NULL,
    "metadata" jsonb,
    "embedding" vector
);

CREATE TABLE IF NOT EXISTS public."persona_plans" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "persona_id" text,
    "ts" timestamp with time zone DEFAULT now(),
    "plan" text NOT NULL,
    "horizon" integer DEFAULT 3,
    "status" text DEFAULT 'active'::text
);

CREATE TABLE IF NOT EXISTS public."persona_psychographic_traits" (
    "persona_id" text NOT NULL,
    "trait_id" bigint NOT NULL,
    "raw_value" text,
    "value" jsonb,
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."persona_reflections" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "persona_id" text,
    "ts" timestamp with time zone DEFAULT now(),
    "summary" text NOT NULL,
    "embedding" vector
);

CREATE TABLE IF NOT EXISTS public."persona_technographic_traits" (
    "persona_id" text NOT NULL,
    "trait_id" bigint NOT NULL,
    "raw_value" text,
    "value" jsonb,
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."personas" (
    "id" text DEFAULT (gen_random_uuid())::text NOT NULL,
    "product_id" uuid NOT NULL,
    "tenant_id" text NOT NULL,
    "session_id" text,
    "use_case_id" uuid,
    "cohort_id" uuid,
    "sub_cohort_id" uuid,
    "name" text NOT NULL,
    "display_name" text NOT NULL,
    "slug" text,
    "archetype" text,
    "persona_type" text DEFAULT 'regular'::text NOT NULL,
    "actor_type" text,
    "domain" text,
    "intent" text,
    "skill_level" text,
    "overview" text,
    "description" text,
    "bio" text,
    "quote" text,
    "traits" jsonb,
    "constraints" jsonb,
    "attributes" jsonb DEFAULT '{}'::jsonb,
    "source" text,
    "is_ai" boolean DEFAULT true,
    "status" text DEFAULT 'active'::text NOT NULL,
    "version" integer DEFAULT 1 NOT NULL,
    "language" text DEFAULT 'English'::text,
    "embedding" vector,
    "created_by" uuid,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."product_usage" (
    "id" bigint DEFAULT nextval('product_usage_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "usage_type" text NOT NULL,
    "usage_metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public."products" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_code" text NOT NULL,
    "product_name" text NOT NULL,
    "description" text,
    "features" jsonb DEFAULT '{}'::jsonb,
    "pricing_tier" text,
    "status" text DEFAULT 'active'::text NOT NULL,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "metadata" jsonb DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS public."prompt_generator_responses" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "generation_run_id" bigint,
    "session_id" uuid,
    "conversation_id" character varying(100),
    "turn_id" character varying(100),
    "persona_id" text,
    "persona_name" text,
    "scenario_id" text,
    "test_type_id" text,
    "threat_vector_id" text,
    "final_prompt" text NOT NULL,
    "final_response" jsonb NOT NULL,
    "generated_text" text,
    "test_types" jsonb,
    "raw_output" jsonb,
    "invocation_id" uuid NOT NULL,
    "model_id" character varying(255) NOT NULL,
    "model_name" text,
    "model_version" text,
    "provider" text,
    "request_payload" jsonb,
    "response_data" jsonb,
    "sanitized_response" jsonb,
    "status" character varying(50) DEFAULT 'success'::character varying,
    "latency_ms" double precision,
    "prompt_tokens" integer DEFAULT 0,
    "completion_tokens" integer DEFAULT 0,
    "total_tokens" integer DEFAULT 0,
    "error_code" character varying(100),
    "error_message" text,
    "cache_hit" boolean DEFAULT false,
    "retry_count" integer DEFAULT 0,
    "invocation_type" character varying(50) DEFAULT 'async'::character varying,
    "caller_context" jsonb,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "completed_at" timestamp with time zone,
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."psychographic_traits_catalog" (
    "id" bigint DEFAULT nextval('psychographic_traits_catalog_id_seq'::regclass) NOT NULL,
    "key" text NOT NULL,
    "label" text NOT NULL,
    "data_type" text DEFAULT 'text'::text NOT NULL,
    "allowed_values" jsonb,
    "description" text,
    "persona_type" text DEFAULT 'regular'::text,
    "applicable_sub_cohorts" jsonb DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS public."quality_metrics" (
    "id" bigint DEFAULT nextval('quality_metrics_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "conversation_id" bigint NOT NULL,
    "methodology" character varying(255) DEFAULT ''::character varying,
    "metrics" jsonb DEFAULT '{}'::jsonb,
    "fit_score" double precision,
    "diversity_score" double precision,
    "policy_risk_score" double precision,
    "length_score" double precision,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."raw_items" (
    "id" bigint DEFAULT nextval('raw_items_id_seq'::regclass) NOT NULL,
    "source_id" bigint,
    "external_id" text,
    "title" text,
    "raw_text" text,
    "metadata" jsonb,
    "content_type" text,
    "sha256" text,
    "inserted_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."risk_assessments" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "context_profile_id" uuid,
    "source_intake_id" text NOT NULL,
    "assessment_mode" text DEFAULT 'agentic'::text,
    "threats" jsonb DEFAULT '[]'::jsonb,
    "scenarios" jsonb DEFAULT '[]'::jsonb,
    "summary" jsonb DEFAULT '{}'::jsonb,
    "agent_endpoint" text,
    "generation_time_ms" integer,
    "api_response_status" integer,
    "error_message" text,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."risks" (
    "id" text NOT NULL,
    "product_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "embedding" vector
);

CREATE TABLE IF NOT EXISTS public."safety_alerts" (
    "alert_id" bigint DEFAULT nextval('safety_alerts_alert_id_seq'::regclass) NOT NULL,
    "model_id" bigint,
    "assessment_id" bigint,
    "alert_type" text NOT NULL,
    "severity" text NOT NULL,
    "title" text NOT NULL,
    "description" text,
    "status" text DEFAULT 'open'::text NOT NULL,
    "detected_at" timestamp with time zone DEFAULT now(),
    "resolved_at" timestamp with time zone,
    "resolved_by" text,
    "resolution_notes" text
);

CREATE TABLE IF NOT EXISTS public."safety_assessments" (
    "assessment_id" bigint DEFAULT nextval('safety_assessments_assessment_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "output_id" bigint,
    "evaluator_agent_id" bigint,
    "safety_score" numeric(5,2),
    "is_safe" boolean NOT NULL,
    "risk_level" text NOT NULL,
    "violation_types" jsonb,
    "reasoning" text,
    "confidence_score" numeric(5,2),
    "assessed_at" timestamp with time zone DEFAULT now(),
    "metadata" jsonb
);

CREATE TABLE IF NOT EXISTS public."safety_metrics" (
    "metric_id" bigint DEFAULT nextval('safety_metrics_metric_id_seq'::regclass) NOT NULL,
    "assessment_id" bigint,
    "metric_name" text NOT NULL,
    "metric_value" numeric(10,4) NOT NULL,
    "metric_unit" text,
    "threshold_exceeded" boolean DEFAULT false NOT NULL,
    "metadata" jsonb
);

CREATE TABLE IF NOT EXISTS public."scenario_intent_personas" (
    "product_id" uuid NOT NULL,
    "intent_id" uuid NOT NULL,
    "persona_id" text NOT NULL,
    "relevance_score" numeric,
    "notes" text,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."scenario_intents" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "scenario_id" text,
    "intent_name" text NOT NULL,
    "description" text,
    "temporal_trigger" text,
    "spatial_trigger" text,
    "event_trigger" text,
    "social_context" text,
    "environmental_context" text,
    "steps" text,
    "available_actions" text,
    "decision_points" text,
    "objects_involved" text,
    "object_states" jsonb,
    "scenario_goal" text,
    "success_criteria" text,
    "failure_conditions" text,
    "constraints" text,
    "information_channels" text,
    "visibility_rules" text,
    "frequency" text,
    "relevance_score" numeric,
    "status" text DEFAULT 'active'::text,
    "priority" text,
    "tags" jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."scenario_personas" (
    "id" text DEFAULT (gen_random_uuid())::text NOT NULL,
    "product_id" uuid NOT NULL,
    "scenario_id" text,
    "persona_id" text,
    "relevance_score" double precision,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."scenario_scores" (
    "id" text DEFAULT (gen_random_uuid())::text NOT NULL,
    "product_id" uuid NOT NULL,
    "scenario_id" text,
    "score_type" text NOT NULL,
    "score_value" double precision NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."scenario_seeds" (
    "id" bigint DEFAULT nextval('scenario_seeds_id_seq'::regclass) NOT NULL,
    "title" text,
    "summary" text,
    "persona_hint" jsonb,
    "scenario_context" text,
    "linked_techniques" bigint[],
    "risk_vector" text,
    "harm_category" text,
    "tags" text[] DEFAULT '{}'::text[],
    "embedding" vector,
    "provenance" jsonb,
    "inserted_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."scenario_test_types" (
    "id" text DEFAULT (gen_random_uuid())::text NOT NULL,
    "product_id" uuid NOT NULL,
    "scenario_id" text,
    "test_type_id" text,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."scenario_threats" (
    "id" text DEFAULT (gen_random_uuid())::text NOT NULL,
    "product_id" uuid NOT NULL,
    "scenario_id" text,
    "threat_vector_id" text,
    "relevance_score" double precision,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."scenarios" (
    "id" text DEFAULT (gen_random_uuid())::text NOT NULL,
    "product_id" uuid NOT NULL,
    "tenant_id" text NOT NULL,
    "session_id" text,
    "persona_id" text,
    "title" text NOT NULL,
    "name" text,
    "scenario_id" text,
    "description" text,
    "context" text,
    "constraints" text,
    "expected_behaviors" text,
    "risk_vectors" text[] DEFAULT '{}'::text[],
    "harm_categories" text[] DEFAULT '{}'::text[],
    "stack_tags" text[] DEFAULT '{}'::text[],
    "tags" text,
    "relevance_score" double precision,
    "severity" text,
    "likelihood" text,
    "objectives" jsonb DEFAULT '[]'::jsonb,
    "generated_prompt" jsonb,
    "status" text DEFAULT 'created'::text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "raw_data" jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."sources" (
    "id" bigint DEFAULT nextval('sources_id_seq'::regclass) NOT NULL,
    "name" text NOT NULL,
    "source_type" text NOT NULL,
    "location" text NOT NULL,
    "config" jsonb DEFAULT '{}'::jsonb,
    "is_active" boolean DEFAULT true,
    "inserted_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."sub_cohorts" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "cohort_id" uuid,
    "name" text NOT NULL,
    "description" text,
    "persona_type" text DEFAULT 'regular'::text,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."technographic_traits_catalog" (
    "id" bigint DEFAULT nextval('technographic_traits_catalog_id_seq'::regclass) NOT NULL,
    "key" text NOT NULL,
    "label" text NOT NULL,
    "data_type" text DEFAULT 'text'::text NOT NULL,
    "allowed_values" jsonb,
    "description" text,
    "persona_type" text DEFAULT 'regular'::text,
    "applicable_sub_cohorts" jsonb DEFAULT '[]'::jsonb
);

CREATE TABLE IF NOT EXISTS public."tenants" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "tenant_name" text NOT NULL,
    "client_id" text,
    "industry" text,
    "status" text DEFAULT 'active'::text NOT NULL,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "metadata" jsonb DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS public."test_categories" (
    "category_id" integer DEFAULT nextval('test_categories_category_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "category_name" text NOT NULL,
    "description" text,
    "severity_level" text NOT NULL,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."test_executions" (
    "execution_id" bigint DEFAULT nextval('test_executions_execution_id_seq'::regclass) NOT NULL,
    "product_id" uuid NOT NULL,
    "model_id" bigint,
    "test_case_id" bigint,
    "executing_agent_id" bigint,
    "session_id" uuid,
    "execution_start" timestamp with time zone DEFAULT now(),
    "execution_end" timestamp with time zone,
    "status" text DEFAULT 'pending'::text NOT NULL,
    "error_message" text,
    "execution_context" jsonb
);

CREATE TABLE IF NOT EXISTS public."test_sessions" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "session_id" text NOT NULL,
    "product_id" uuid NOT NULL,
    "customer_id" text NOT NULL,
    "tenant_id" uuid,
    "session_name" text NOT NULL,
    "description" text,
    "customer_data" jsonb,
    "status" text DEFAULT 'active'::text,
    "tags" text[] DEFAULT ARRAY[]::text[],
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."test_sets" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" text NOT NULL,
    "created_by" text NOT NULL,
    "scenario" text,
    "persona" jsonb,
    "risks" text[] NOT NULL,
    "harms" text[] NOT NULL,
    "test_type" text,
    "status" text DEFAULT 'draft'::text,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."test_turns" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "unit_id" uuid,
    "role" text,
    "content" text,
    "expected_behavior" text,
    "scoring" jsonb,
    "ord" integer NOT NULL,
    "source" text DEFAULT 'user'::text,
    "embedding" vector
);

CREATE TABLE IF NOT EXISTS public."test_types" (
    "id" text NOT NULL,
    "product_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "category" text DEFAULT 'general'::text NOT NULL,
    "category_id" integer,
    "session_id" text,
    "embedding" vector,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."test_units" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "test_set_id" uuid,
    "label" text,
    "ord" integer NOT NULL
);

CREATE TABLE IF NOT EXISTS public."threat_examples" (
    "id" text NOT NULL,
    "product_id" uuid NOT NULL,
    "vector_id" text,
    "source" text,
    "raw_json" jsonb,
    "example_text" text,
    "persona_samples" jsonb,
    "scenario_text" text,
    "expected_system_response" text,
    "evidence_refs" jsonb,
    "severity" text,
    "detection_methods" text[],
    "mitigation" text[],
    "lifecycle_phase" text,
    "exploitation_complexity" text,
    "modalities" text[],
    "embedding" vector,
    "created_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."threat_vectors" (
    "id" text NOT NULL,
    "id_uuid" uuid,
    "product_id" uuid NOT NULL,
    "source" text NOT NULL,
    "name" text,
    "description" text,
    "category" text,
    "threat_categories" text[],
    "harm_categories" text[],
    "modalities" text[],
    "tags" text[] DEFAULT ARRAY[]::text[],
    "framework_alignment" jsonb,
    "metadata" jsonb,
    "severity" text,
    "mitigation" text,
    "raw_json" jsonb,
    "embedding" vector,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."use_cases" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "slug" text,
    "name" text NOT NULL,
    "description" text,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

-- ==========================================================================
-- CONSTRAINTS
-- ==========================================================================

DO $$ BEGIN
    ALTER TABLE ONLY public."adversarial_test_cases" ADD CONSTRAINT "adversarial_test_cases_severity_check" CHECK (severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."adversarial_test_cases" ADD CONSTRAINT "adversarial_test_cases_category_id_fkey" FOREIGN KEY (category_id) REFERENCES test_categories(category_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."adversarial_test_cases" ADD CONSTRAINT "adversarial_test_cases_created_by_agent_id_fkey" FOREIGN KEY (created_by_agent_id) REFERENCES ai_agents(agent_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."adversarial_test_cases" ADD CONSTRAINT "adversarial_test_cases_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."adversarial_test_cases" ADD CONSTRAINT "adversarial_test_cases_pkey" PRIMARY KEY (test_case_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_agents" ADD CONSTRAINT "ai_agents_agent_type_check" CHECK (agent_type = ANY (ARRAY['adversarial'::text, 'evaluator'::text, 'classifier'::text, 'monitor'::text, 'generator'::text, 'other'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_agents" ADD CONSTRAINT "ai_agents_status_check" CHECK (status = ANY (ARRAY['active'::text, 'inactive'::text, 'deprecated'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_agents" ADD CONSTRAINT "ai_agents_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_agents" ADD CONSTRAINT "fk_ai_agents_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_agents" ADD CONSTRAINT "ai_agents_pkey" PRIMARY KEY (agent_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_test_results" ADD CONSTRAINT "ai_test_results_severity_check" CHECK (severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_test_results" ADD CONSTRAINT "ai_test_results_status_check" CHECK (status = ANY (ARRAY['passed'::text, 'failed'::text, 'blocked'::text, 'unknown'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_test_results" ADD CONSTRAINT "ai_test_results_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_test_results" ADD CONSTRAINT "ai_test_results_scenario_id_fkey" FOREIGN KEY (scenario_id) REFERENCES scenarios(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_test_results" ADD CONSTRAINT "ai_test_results_session_id_fkey" FOREIGN KEY (session_id) REFERENCES test_sessions(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_test_results" ADD CONSTRAINT "ai_test_results_test_type_id_fkey" FOREIGN KEY (test_type_id) REFERENCES test_types(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."ai_test_results" ADD CONSTRAINT "ai_test_results_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_audit_logs" ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY (log_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_conversations" ADD CONSTRAINT "conversations_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_conversations" ADD CONSTRAINT "conversations_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_generation_runs" ADD CONSTRAINT "generation_runs_modality_check" CHECK (modality::text = ANY (ARRAY['text'::character varying, 'image'::character varying, 'audio'::character varying]::text[]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_generation_runs" ADD CONSTRAINT "generation_runs_status_check" CHECK (status::text = ANY (ARRAY['in_progress'::character varying, 'completed'::character varying, 'failed'::character varying]::text[]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_generation_runs" ADD CONSTRAINT "fk_generation_runs_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_generation_runs" ADD CONSTRAINT "generation_runs_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_generation_runs" ADD CONSTRAINT "generation_runs_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_generation_runs" ADD CONSTRAINT "generation_runs_generation_run_id_key" UNIQUE (generation_run_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_telemetry" ADD CONSTRAINT "fk_telemetry_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_telemetry" ADD CONSTRAINT "telemetry_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_telemetry" ADD CONSTRAINT "telemetry_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_telemetry" ADD CONSTRAINT "telemetry_generation_run_id_key" UNIQUE (generation_run_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_turns" ADD CONSTRAINT "turns_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_turns" ADD CONSTRAINT "turns_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."behavioral_traits_catalog" ADD CONSTRAINT "behavioral_traits_catalog_data_type_check" CHECK (data_type = ANY (ARRAY['text'::text, 'number'::text, 'boolean'::text, 'date'::text, 'enum'::text, 'json'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."behavioral_traits_catalog" ADD CONSTRAINT "behavioral_traits_catalog_persona_type_check" CHECK (persona_type = ANY (ARRAY['regular'::text, 'adversarial'::text, 'internal'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."behavioral_traits_catalog" ADD CONSTRAINT "behavioral_traits_catalog_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."behavioral_traits_catalog" ADD CONSTRAINT "behavioral_traits_catalog_key_key" UNIQUE (key);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_model_products" ADD CONSTRAINT "client_model_products_model_id_fkey" FOREIGN KEY (model_id) REFERENCES client_models(model_id) ON DELETE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_model_products" ADD CONSTRAINT "client_model_products_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_model_products" ADD CONSTRAINT "client_model_products_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_model_products" ADD CONSTRAINT "client_model_products_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_model_products" ADD CONSTRAINT "client_model_products_model_id_product_id_key" UNIQUE (model_id, product_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_models" ADD CONSTRAINT "client_models_risk_level_check" CHECK (risk_level = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_models" ADD CONSTRAINT "client_models_status_check" CHECK (status = ANY (ARRAY['registered'::text, 'active'::text, 'suspended'::text, 'deactivated'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_models" ADD CONSTRAINT "client_models_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES tenants(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_models" ADD CONSTRAINT "client_models_pkey" PRIMARY KEY (model_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_product_subscriptions" ADD CONSTRAINT "client_product_subscriptions_subscription_status_check" CHECK (subscription_status = ANY (ARRAY['active'::text, 'trial'::text, 'suspended'::text, 'expired'::text, 'cancelled'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_product_subscriptions" ADD CONSTRAINT "client_product_subscriptions_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_product_subscriptions" ADD CONSTRAINT "client_product_subscriptions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_product_subscriptions" ADD CONSTRAINT "client_product_subscriptions_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."client_product_subscriptions" ADD CONSTRAINT "client_product_subscriptions_tenant_id_product_id_key" UNIQUE (tenant_id, product_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."cohorts" ADD CONSTRAINT "cohorts_use_case_id_fkey" FOREIGN KEY (use_case_id) REFERENCES use_cases(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."cohorts" ADD CONSTRAINT "cohorts_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."compliance_reports" ADD CONSTRAINT "compliance_reports_generated_by_agent_id_fkey" FOREIGN KEY (generated_by_agent_id) REFERENCES ai_agents(agent_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."compliance_reports" ADD CONSTRAINT "compliance_reports_model_id_fkey" FOREIGN KEY (model_id) REFERENCES client_models(model_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."compliance_reports" ADD CONSTRAINT "compliance_reports_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."compliance_reports" ADD CONSTRAINT "fk_compliance_reports_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."compliance_reports" ADD CONSTRAINT "compliance_reports_pkey" PRIMARY KEY (report_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."context_profiles" ADD CONSTRAINT "context_profiles_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."context_profiles" ADD CONSTRAINT "context_profiles_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES tenants(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."context_profiles" ADD CONSTRAINT "fk_context_profiles_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."context_profiles" ADD CONSTRAINT "context_profiles_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."context_profiles" ADD CONSTRAINT "context_profiles_source_intake_id_key" UNIQUE (source_intake_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."crawls" ADD CONSTRAINT "crawls_source_id_fkey" FOREIGN KEY (source_id) REFERENCES sources(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."crawls" ADD CONSTRAINT "crawls_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."demographic_traits_catalog" ADD CONSTRAINT "demographic_traits_catalog_data_type_check" CHECK (data_type = ANY (ARRAY['text'::text, 'number'::text, 'boolean'::text, 'date'::text, 'enum'::text, 'json'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."demographic_traits_catalog" ADD CONSTRAINT "demographic_traits_catalog_persona_type_check" CHECK (persona_type = ANY (ARRAY['regular'::text, 'adversarial'::text, 'internal'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."demographic_traits_catalog" ADD CONSTRAINT "demographic_traits_catalog_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."demographic_traits_catalog" ADD CONSTRAINT "demographic_traits_catalog_key_key" UNIQUE (key);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."harms" ADD CONSTRAINT "fk_harms_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."harms" ADD CONSTRAINT "harms_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."harms" ADD CONSTRAINT "harms_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."linguistic_traits_catalog" ADD CONSTRAINT "linguistic_traits_catalog_data_type_check" CHECK (data_type = ANY (ARRAY['text'::text, 'number'::text, 'boolean'::text, 'date'::text, 'enum'::text, 'json'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."linguistic_traits_catalog" ADD CONSTRAINT "linguistic_traits_catalog_persona_type_check" CHECK (persona_type = ANY (ARRAY['regular'::text, 'adversarial'::text, 'internal'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."linguistic_traits_catalog" ADD CONSTRAINT "linguistic_traits_catalog_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."linguistic_traits_catalog" ADD CONSTRAINT "linguistic_traits_catalog_key_key" UNIQUE (key);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."model_outputs" ADD CONSTRAINT "model_outputs_execution_id_fkey" FOREIGN KEY (execution_id) REFERENCES test_executions(execution_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."model_outputs" ADD CONSTRAINT "model_outputs_pkey" PRIMARY KEY (output_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."model_response_cache" ADD CONSTRAINT "model_response_cache_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."nyc_test_results" ADD CONSTRAINT "nyc_test_results_prompt_response_id_fkey" FOREIGN KEY (prompt_response_id) REFERENCES prompt_generator_responses(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."nyc_test_results" ADD CONSTRAINT "nyc_test_results_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_actions" ADD CONSTRAINT "fk_persona_actions_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_actions" ADD CONSTRAINT "persona_actions_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_actions" ADD CONSTRAINT "persona_actions_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_actions" ADD CONSTRAINT "persona_actions_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_behavioral_traits" ADD CONSTRAINT "persona_behavioral_traits_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_behavioral_traits" ADD CONSTRAINT "persona_behavioral_traits_trait_id_fkey" FOREIGN KEY (trait_id) REFERENCES behavioral_traits_catalog(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_behavioral_traits" ADD CONSTRAINT "persona_behavioral_traits_pkey" PRIMARY KEY (persona_id, trait_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_demographics" ADD CONSTRAINT "persona_demographics_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_demographics" ADD CONSTRAINT "persona_demographics_trait_id_fkey" FOREIGN KEY (trait_id) REFERENCES demographic_traits_catalog(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_demographics" ADD CONSTRAINT "persona_demographics_pkey" PRIMARY KEY (persona_id, trait_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_linguistic_traits" ADD CONSTRAINT "persona_linguistic_traits_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_linguistic_traits" ADD CONSTRAINT "persona_linguistic_traits_trait_id_fkey" FOREIGN KEY (trait_id) REFERENCES linguistic_traits_catalog(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_linguistic_traits" ADD CONSTRAINT "persona_linguistic_traits_pkey" PRIMARY KEY (persona_id, trait_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_memories" ADD CONSTRAINT "fk_persona_memories_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_memories" ADD CONSTRAINT "persona_memories_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_memories" ADD CONSTRAINT "persona_memories_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_memories" ADD CONSTRAINT "persona_memories_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_plans" ADD CONSTRAINT "fk_persona_plans_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_plans" ADD CONSTRAINT "persona_plans_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_plans" ADD CONSTRAINT "persona_plans_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_plans" ADD CONSTRAINT "persona_plans_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_psychographic_traits" ADD CONSTRAINT "persona_psychographic_traits_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_psychographic_traits" ADD CONSTRAINT "persona_psychographic_traits_trait_id_fkey" FOREIGN KEY (trait_id) REFERENCES psychographic_traits_catalog(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_psychographic_traits" ADD CONSTRAINT "persona_psychographic_traits_pkey" PRIMARY KEY (persona_id, trait_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_reflections" ADD CONSTRAINT "fk_persona_reflections_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_reflections" ADD CONSTRAINT "persona_reflections_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_reflections" ADD CONSTRAINT "persona_reflections_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_reflections" ADD CONSTRAINT "persona_reflections_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_technographic_traits" ADD CONSTRAINT "persona_technographic_traits_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_technographic_traits" ADD CONSTRAINT "persona_technographic_traits_trait_id_fkey" FOREIGN KEY (trait_id) REFERENCES technographic_traits_catalog(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."persona_technographic_traits" ADD CONSTRAINT "persona_technographic_traits_pkey" PRIMARY KEY (persona_id, trait_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."personas" ADD CONSTRAINT "personas_persona_type_check" CHECK (persona_type = ANY (ARRAY['regular'::text, 'adversarial'::text, 'internal'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."personas" ADD CONSTRAINT "personas_status_check" CHECK (status = ANY (ARRAY['draft'::text, 'active'::text, 'archived'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."personas" ADD CONSTRAINT "personas_cohort_id_fkey" FOREIGN KEY (cohort_id) REFERENCES cohorts(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."personas" ADD CONSTRAINT "personas_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."personas" ADD CONSTRAINT "personas_sub_cohort_id_fkey" FOREIGN KEY (sub_cohort_id) REFERENCES sub_cohorts(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."personas" ADD CONSTRAINT "personas_use_case_id_fkey" FOREIGN KEY (use_case_id) REFERENCES use_cases(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."personas" ADD CONSTRAINT "personas_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."product_usage" ADD CONSTRAINT "product_usage_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."product_usage" ADD CONSTRAINT "product_usage_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."product_usage" ADD CONSTRAINT "product_usage_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."products" ADD CONSTRAINT "products_product_code_check" CHECK (product_code = ANY (ARRAY['ai-range'::text, 'peregrine'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."products" ADD CONSTRAINT "products_status_check" CHECK (status = ANY (ARRAY['active'::text, 'beta'::text, 'deprecated'::text, 'inactive'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."products" ADD CONSTRAINT "products_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."products" ADD CONSTRAINT "products_product_code_key" UNIQUE (product_code);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_invocation_type_check" CHECK (invocation_type::text = ANY (ARRAY['async'::character varying, 'sync'::character varying]::text[]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_status_check" CHECK (status::text = ANY (ARRAY['success'::character varying, 'failed'::character varying, 'error'::character varying]::text[]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "fk_prompt_generator_responses_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_scenario_id_fkey" FOREIGN KEY (scenario_id) REFERENCES scenarios(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_session_id_fkey" FOREIGN KEY (session_id) REFERENCES test_sessions(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_test_type_id_fkey" FOREIGN KEY (test_type_id) REFERENCES test_types(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_threat_vector_id_fkey" FOREIGN KEY (threat_vector_id) REFERENCES threat_vectors(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."prompt_generator_responses" ADD CONSTRAINT "prompt_generator_responses_invocation_id_key" UNIQUE (invocation_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."psychographic_traits_catalog" ADD CONSTRAINT "psychographic_traits_catalog_data_type_check" CHECK (data_type = ANY (ARRAY['text'::text, 'number'::text, 'boolean'::text, 'date'::text, 'enum'::text, 'json'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."psychographic_traits_catalog" ADD CONSTRAINT "psychographic_traits_catalog_persona_type_check" CHECK (persona_type = ANY (ARRAY['regular'::text, 'adversarial'::text, 'internal'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."psychographic_traits_catalog" ADD CONSTRAINT "psychographic_traits_catalog_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."psychographic_traits_catalog" ADD CONSTRAINT "psychographic_traits_catalog_key_key" UNIQUE (key);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."quality_metrics" ADD CONSTRAINT "fk_quality_metrics_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."quality_metrics" ADD CONSTRAINT "quality_metrics_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."quality_metrics" ADD CONSTRAINT "quality_metrics_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."raw_items" ADD CONSTRAINT "raw_items_source_id_fkey" FOREIGN KEY (source_id) REFERENCES sources(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."raw_items" ADD CONSTRAINT "raw_items_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."risk_assessments" ADD CONSTRAINT "risk_assessments_assessment_mode_check" CHECK (assessment_mode = ANY (ARRAY['agentic'::text, 'mock'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."risk_assessments" ADD CONSTRAINT "fk_risk_assessments_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."risk_assessments" ADD CONSTRAINT "risk_assessments_context_profile_id_fkey" FOREIGN KEY (context_profile_id) REFERENCES context_profiles(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."risk_assessments" ADD CONSTRAINT "risk_assessments_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."risk_assessments" ADD CONSTRAINT "risk_assessments_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."risks" ADD CONSTRAINT "fk_risks_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."risks" ADD CONSTRAINT "risks_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."risks" ADD CONSTRAINT "risks_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_alerts" ADD CONSTRAINT "safety_alerts_severity_check" CHECK (severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_alerts" ADD CONSTRAINT "safety_alerts_status_check" CHECK (status = ANY (ARRAY['open'::text, 'investigating'::text, 'resolved'::text, 'false_positive'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_alerts" ADD CONSTRAINT "safety_alerts_assessment_id_fkey" FOREIGN KEY (assessment_id) REFERENCES safety_assessments(assessment_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_alerts" ADD CONSTRAINT "safety_alerts_model_id_fkey" FOREIGN KEY (model_id) REFERENCES client_models(model_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_alerts" ADD CONSTRAINT "safety_alerts_pkey" PRIMARY KEY (alert_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_assessments" ADD CONSTRAINT "safety_assessments_confidence_score_check" CHECK (confidence_score >= 0::numeric AND confidence_score <= 100::numeric);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_assessments" ADD CONSTRAINT "safety_assessments_risk_level_check" CHECK (risk_level = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_assessments" ADD CONSTRAINT "safety_assessments_safety_score_check" CHECK (safety_score >= 0::numeric AND safety_score <= 100::numeric);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_assessments" ADD CONSTRAINT "fk_safety_assessments_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_assessments" ADD CONSTRAINT "safety_assessments_evaluator_agent_id_fkey" FOREIGN KEY (evaluator_agent_id) REFERENCES ai_agents(agent_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_assessments" ADD CONSTRAINT "safety_assessments_output_id_fkey" FOREIGN KEY (output_id) REFERENCES model_outputs(output_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_assessments" ADD CONSTRAINT "safety_assessments_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_assessments" ADD CONSTRAINT "safety_assessments_pkey" PRIMARY KEY (assessment_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_metrics" ADD CONSTRAINT "safety_metrics_assessment_id_fkey" FOREIGN KEY (assessment_id) REFERENCES safety_assessments(assessment_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."safety_metrics" ADD CONSTRAINT "safety_metrics_pkey" PRIMARY KEY (metric_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intent_personas" ADD CONSTRAINT "scenario_intent_personas_relevance_score_check" CHECK (relevance_score >= 0::numeric AND relevance_score <= 1::numeric);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intent_personas" ADD CONSTRAINT "fk_scenario_intent_personas_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intent_personas" ADD CONSTRAINT "scenario_intent_personas_intent_id_fkey" FOREIGN KEY (intent_id) REFERENCES scenario_intents(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intent_personas" ADD CONSTRAINT "scenario_intent_personas_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intent_personas" ADD CONSTRAINT "scenario_intent_personas_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intent_personas" ADD CONSTRAINT "scenario_intent_personas_pkey" PRIMARY KEY (intent_id, persona_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intents" ADD CONSTRAINT "scenario_intents_priority_check" CHECK (priority = ANY (ARRAY['critical'::text, 'high'::text, 'medium'::text, 'low'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intents" ADD CONSTRAINT "scenario_intents_relevance_score_check" CHECK (relevance_score >= 0::numeric AND relevance_score <= 1::numeric);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intents" ADD CONSTRAINT "scenario_intents_status_check" CHECK (status = ANY (ARRAY['draft'::text, 'active'::text, 'archived'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intents" ADD CONSTRAINT "fk_scenario_intents_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intents" ADD CONSTRAINT "scenario_intents_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intents" ADD CONSTRAINT "scenario_intents_scenario_id_fkey" FOREIGN KEY (scenario_id) REFERENCES scenarios(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_intents" ADD CONSTRAINT "scenario_intents_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_personas" ADD CONSTRAINT "fk_scenario_personas_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_personas" ADD CONSTRAINT "scenario_personas_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_personas" ADD CONSTRAINT "scenario_personas_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_personas" ADD CONSTRAINT "scenario_personas_scenario_id_fkey" FOREIGN KEY (scenario_id) REFERENCES scenarios(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_personas" ADD CONSTRAINT "scenario_personas_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_scores" ADD CONSTRAINT "fk_scenario_scores_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_scores" ADD CONSTRAINT "scenario_scores_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_scores" ADD CONSTRAINT "scenario_scores_scenario_id_fkey" FOREIGN KEY (scenario_id) REFERENCES scenarios(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_scores" ADD CONSTRAINT "scenario_scores_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_seeds" ADD CONSTRAINT "scenario_seeds_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_test_types" ADD CONSTRAINT "fk_scenario_test_types_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_test_types" ADD CONSTRAINT "scenario_test_types_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_test_types" ADD CONSTRAINT "scenario_test_types_scenario_id_fkey" FOREIGN KEY (scenario_id) REFERENCES scenarios(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_test_types" ADD CONSTRAINT "scenario_test_types_test_type_id_fkey" FOREIGN KEY (test_type_id) REFERENCES test_types(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_test_types" ADD CONSTRAINT "scenario_test_types_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_threats" ADD CONSTRAINT "fk_scenario_threats_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_threats" ADD CONSTRAINT "scenario_threats_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_threats" ADD CONSTRAINT "scenario_threats_scenario_id_fkey" FOREIGN KEY (scenario_id) REFERENCES scenarios(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_threats" ADD CONSTRAINT "scenario_threats_threat_vector_id_fkey" FOREIGN KEY (threat_vector_id) REFERENCES threat_vectors(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenario_threats" ADD CONSTRAINT "scenario_threats_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenarios" ADD CONSTRAINT "scenarios_persona_id_fkey" FOREIGN KEY (persona_id) REFERENCES personas(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenarios" ADD CONSTRAINT "scenarios_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."scenarios" ADD CONSTRAINT "scenarios_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."sources" ADD CONSTRAINT "sources_source_type_check" CHECK (source_type = ANY (ARRAY['github'::text, 'http'::text, 'file'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."sources" ADD CONSTRAINT "sources_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."sub_cohorts" ADD CONSTRAINT "sub_cohorts_persona_type_check" CHECK (persona_type = ANY (ARRAY['regular'::text, 'adversarial'::text, 'internal'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."sub_cohorts" ADD CONSTRAINT "sub_cohorts_cohort_id_fkey" FOREIGN KEY (cohort_id) REFERENCES cohorts(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."sub_cohorts" ADD CONSTRAINT "sub_cohorts_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."technographic_traits_catalog" ADD CONSTRAINT "technographic_traits_catalog_data_type_check" CHECK (data_type = ANY (ARRAY['text'::text, 'number'::text, 'boolean'::text, 'date'::text, 'enum'::text, 'json'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."technographic_traits_catalog" ADD CONSTRAINT "technographic_traits_catalog_persona_type_check" CHECK (persona_type = ANY (ARRAY['regular'::text, 'adversarial'::text, 'internal'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."technographic_traits_catalog" ADD CONSTRAINT "technographic_traits_catalog_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."technographic_traits_catalog" ADD CONSTRAINT "technographic_traits_catalog_key_key" UNIQUE (key);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."tenants" ADD CONSTRAINT "tenants_status_check" CHECK (status = ANY (ARRAY['active'::text, 'suspended'::text, 'inactive'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."tenants" ADD CONSTRAINT "tenants_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."tenants" ADD CONSTRAINT "tenants_client_id_key" UNIQUE (client_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."tenants" ADD CONSTRAINT "tenants_tenant_name_key" UNIQUE (tenant_name);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_categories" ADD CONSTRAINT "test_categories_severity_level_check" CHECK (severity_level = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_categories" ADD CONSTRAINT "fk_test_categories_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_categories" ADD CONSTRAINT "test_categories_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_categories" ADD CONSTRAINT "test_categories_pkey" PRIMARY KEY (category_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_categories" ADD CONSTRAINT "test_categories_category_name_key" UNIQUE (category_name);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_executions" ADD CONSTRAINT "test_executions_status_check" CHECK (status = ANY (ARRAY['pending'::text, 'running'::text, 'completed'::text, 'failed'::text, 'timeout'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_executions" ADD CONSTRAINT "fk_test_executions_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_executions" ADD CONSTRAINT "test_executions_executing_agent_id_fkey" FOREIGN KEY (executing_agent_id) REFERENCES ai_agents(agent_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_executions" ADD CONSTRAINT "test_executions_model_id_fkey" FOREIGN KEY (model_id) REFERENCES client_models(model_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_executions" ADD CONSTRAINT "test_executions_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_executions" ADD CONSTRAINT "test_executions_session_id_fkey" FOREIGN KEY (session_id) REFERENCES test_sessions(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_executions" ADD CONSTRAINT "test_executions_test_case_id_fkey" FOREIGN KEY (test_case_id) REFERENCES adversarial_test_cases(test_case_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_executions" ADD CONSTRAINT "test_executions_pkey" PRIMARY KEY (execution_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_sessions" ADD CONSTRAINT "fk_test_sessions_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_sessions" ADD CONSTRAINT "test_sessions_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_sessions" ADD CONSTRAINT "test_sessions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES tenants(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_sessions" ADD CONSTRAINT "test_sessions_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_sessions" ADD CONSTRAINT "test_sessions_session_id_key" UNIQUE (session_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_sets" ADD CONSTRAINT "test_sets_test_type_fkey" FOREIGN KEY (test_type) REFERENCES test_types(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_sets" ADD CONSTRAINT "test_sets_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_turns" ADD CONSTRAINT "test_turns_role_check" CHECK (role = ANY (ARRAY['user'::text, 'assistant'::text, 'assistant_expected'::text, 'system'::text, 'tool'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_turns" ADD CONSTRAINT "test_turns_unit_id_fkey" FOREIGN KEY (unit_id) REFERENCES test_units(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_turns" ADD CONSTRAINT "test_turns_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_types" ADD CONSTRAINT "fk_test_types_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_types" ADD CONSTRAINT "test_types_category_id_fkey" FOREIGN KEY (category_id) REFERENCES test_categories(category_id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_types" ADD CONSTRAINT "test_types_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_types" ADD CONSTRAINT "test_types_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_units" ADD CONSTRAINT "test_units_test_set_id_fkey" FOREIGN KEY (test_set_id) REFERENCES test_sets(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."test_units" ADD CONSTRAINT "test_units_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."threat_examples" ADD CONSTRAINT "fk_threat_examples_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."threat_examples" ADD CONSTRAINT "threat_examples_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."threat_examples" ADD CONSTRAINT "threat_examples_vector_id_fkey" FOREIGN KEY (vector_id) REFERENCES threat_vectors(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."threat_examples" ADD CONSTRAINT "threat_examples_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."threat_vectors" ADD CONSTRAINT "threat_vectors_severity_check" CHECK (severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."threat_vectors" ADD CONSTRAINT "fk_threat_vectors_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."threat_vectors" ADD CONSTRAINT "threat_vectors_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."threat_vectors" ADD CONSTRAINT "threat_vectors_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."use_cases" ADD CONSTRAINT "fk_use_cases_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."use_cases" ADD CONSTRAINT "use_cases_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."use_cases" ADD CONSTRAINT "use_cases_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."use_cases" ADD CONSTRAINT "use_cases_slug_key" UNIQUE (slug);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- ==========================================================================
-- INDEXES
-- ==========================================================================

CREATE INDEX IF NOT EXISTS idx_test_cases_active ON public.adversarial_test_cases USING btree (is_active);
CREATE INDEX IF NOT EXISTS idx_test_cases_category ON public.adversarial_test_cases USING btree (category_id);
CREATE INDEX IF NOT EXISTS idx_test_cases_product ON public.adversarial_test_cases USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_ai_agents_product ON public.ai_agents USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_ai_agents_type_status ON public.ai_agents USING btree (agent_type, status);
CREATE INDEX IF NOT EXISTS idx_test_results_session ON public.ai_test_results USING btree (session_id);
CREATE INDEX IF NOT EXISTS idx_test_results_status ON public.ai_test_results USING btree (status);
CREATE INDEX IF NOT EXISTS idx_peregrine_audit_logs_active ON public.peregrine_audit_logs USING btree (log_id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_audit_actor ON public.peregrine_audit_logs USING btree (actor_type, actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_entity ON public.peregrine_audit_logs USING btree (entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_event ON public.peregrine_audit_logs USING btree (event_type);
CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON public.peregrine_audit_logs USING btree ("timestamp");
CREATE INDEX IF NOT EXISTS idx_peregrine_conversations_active ON public.peregrine_conversations USING btree (id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_peregrine_conversations_tenant ON public.peregrine_conversations USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_conv_final_rho ON public.peregrine_conversations USING btree (final_rho_p) WHERE (final_rho_p IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_conv_is_robust ON public.peregrine_conversations USING btree (is_robust) WHERE (is_robust IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_conv_robustness_class ON public.peregrine_conversations USING btree (robustness_classification) WHERE (robustness_classification IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_conversations_gold_dataset ON public.peregrine_conversations USING btree (gold_dataset);
CREATE INDEX IF NOT EXISTS idx_conversations_ground_truth_id ON public.peregrine_conversations USING btree (ground_truth_id);
CREATE INDEX IF NOT EXISTS idx_conversations_product_id ON public.peregrine_conversations USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_peregrine_generation_runs_active ON public.peregrine_generation_runs USING btree (id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_gen_runs_created ON public.peregrine_generation_runs USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_gen_runs_product ON public.peregrine_generation_runs USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_gen_runs_run_id ON public.peregrine_generation_runs USING btree (generation_run_id);
CREATE INDEX IF NOT EXISTS idx_gen_runs_status ON public.peregrine_generation_runs USING btree (status);
CREATE INDEX IF NOT EXISTS idx_generation_runs_created ON public.peregrine_generation_runs USING btree (created_at);
CREATE INDEX IF NOT EXISTS idx_generation_runs_id ON public.peregrine_generation_runs USING btree (generation_run_id);
CREATE INDEX IF NOT EXISTS idx_generation_runs_product ON public.peregrine_generation_runs USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_generation_runs_status ON public.peregrine_generation_runs USING btree (status);
CREATE INDEX IF NOT EXISTS idx_peregrine_telemetry_active ON public.peregrine_telemetry USING btree (id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_telemetry_created ON public.peregrine_telemetry USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_telemetry_gen_run ON public.peregrine_telemetry USING btree (generation_run_id);
CREATE INDEX IF NOT EXISTS idx_telemetry_generation_run ON public.peregrine_telemetry USING btree (generation_run_id);
CREATE INDEX IF NOT EXISTS idx_telemetry_product ON public.peregrine_telemetry USING btree (product_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_telemetry_uuid ON public.peregrine_telemetry USING btree (telemetry_id);
CREATE INDEX IF NOT EXISTS idx_peregrine_turns_active ON public.peregrine_turns USING btree (id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_peregrine_turns_tenant ON public.peregrine_turns USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_turns_conv_turn ON public.peregrine_turns USING btree (conversation_id, turn_number);
CREATE INDEX IF NOT EXISTS idx_turns_conversation_id ON public.peregrine_turns USING btree (conversation_id);
CREATE INDEX IF NOT EXISTS idx_turns_likelihood_l_n ON public.peregrine_turns USING btree (likelihood_l_n) WHERE (likelihood_l_n IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_turns_pca_metadata ON public.peregrine_turns USING btree (pca_metadata_id) WHERE (pca_metadata_id IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_turns_product_id ON public.peregrine_turns USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_turns_prompt_not_null ON public.peregrine_turns USING btree (conversation_id, turn_number) WHERE (prompt IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_turns_response_not_null ON public.peregrine_turns USING btree (conversation_id, turn_number) WHERE (response IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_turns_risk_severity_r_n ON public.peregrine_turns USING btree (risk_severity_r_n) WHERE (risk_severity_r_n IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_turns_robustness_rho ON public.peregrine_turns USING btree (robustness_rho) WHERE (robustness_rho IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_turns_toxic_sycophancy_t_syc ON public.peregrine_turns USING btree (toxic_sycophancy_t_syc) WHERE (toxic_sycophancy_t_syc IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_client_model_products_model ON public.client_model_products USING btree (model_id);
CREATE INDEX IF NOT EXISTS idx_client_model_products_product ON public.client_model_products USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_client_model_products_tenant ON public.client_model_products USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_client_models_client_status ON public.client_models USING btree (client_id, status);
CREATE INDEX IF NOT EXISTS idx_client_models_status_risk ON public.client_models USING btree (status, risk_level);
CREATE INDEX IF NOT EXISTS idx_client_models_tenant ON public.client_models USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_client_subscriptions_product ON public.client_product_subscriptions USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_client_subscriptions_status ON public.client_product_subscriptions USING btree (subscription_status);
CREATE INDEX IF NOT EXISTS idx_client_subscriptions_tenant ON public.client_product_subscriptions USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_reports_model ON public.compliance_reports USING btree (model_id);
CREATE INDEX IF NOT EXISTS idx_reports_period ON public.compliance_reports USING btree (report_period_start, report_period_end);
CREATE INDEX IF NOT EXISTS idx_reports_product ON public.compliance_reports USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_context_profiles_product ON public.context_profiles USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_harms_product ON public.harms USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_outputs_execution ON public.model_outputs USING btree (execution_id);
CREATE INDEX IF NOT EXISTS idx_cache_expires ON public.model_response_cache USING btree (expires_at);
CREATE INDEX IF NOT EXISTS idx_cache_key ON public.model_response_cache USING btree (cache_key);
CREATE INDEX IF NOT EXISTS idx_persona_actions_product ON public.persona_actions USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_persona_memories_persona ON public.persona_memories USING btree (persona_id);
CREATE INDEX IF NOT EXISTS idx_persona_memories_product ON public.persona_memories USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_persona_plans_product ON public.persona_plans USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_persona_reflections_product ON public.persona_reflections USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_personas_product ON public.personas USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_personas_session ON public.personas USING btree (session_id);
CREATE INDEX IF NOT EXISTS idx_personas_tenant ON public.personas USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_personas_tenant_type ON public.personas USING btree (tenant_id, persona_type);
CREATE INDEX IF NOT EXISTS idx_personas_type_status ON public.personas USING btree (persona_type, status);
CREATE INDEX IF NOT EXISTS idx_personas_use_case ON public.personas USING btree (use_case_id);
CREATE INDEX IF NOT EXISTS idx_product_usage_created ON public.product_usage USING btree (created_at);
CREATE INDEX IF NOT EXISTS idx_product_usage_product ON public.product_usage USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_product_usage_product_tenant_date ON public.product_usage USING btree (product_id, tenant_id, created_at);
CREATE INDEX IF NOT EXISTS idx_product_usage_tenant ON public.product_usage USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_product_usage_type ON public.product_usage USING btree (usage_type);
CREATE INDEX IF NOT EXISTS idx_products_code_status ON public.products USING btree (product_code, status);
CREATE INDEX IF NOT EXISTS idx_prompt_generator_responses_invocation ON public.prompt_generator_responses USING btree (invocation_id);
CREATE INDEX IF NOT EXISTS idx_prompt_generator_responses_model ON public.prompt_generator_responses USING btree (model_id);
CREATE INDEX IF NOT EXISTS idx_prompt_generator_responses_persona ON public.prompt_generator_responses USING btree (persona_id);
CREATE INDEX IF NOT EXISTS idx_prompt_generator_responses_product ON public.prompt_generator_responses USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_prompt_generator_responses_scenario ON public.prompt_generator_responses USING btree (scenario_id);
CREATE INDEX IF NOT EXISTS idx_prompt_generator_responses_session ON public.prompt_generator_responses USING btree (session_id);
CREATE INDEX IF NOT EXISTS idx_quality_metrics_conversation ON public.quality_metrics USING btree (conversation_id);
CREATE INDEX IF NOT EXISTS idx_quality_metrics_product ON public.quality_metrics USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_risk_assessments_product ON public.risk_assessments USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_risks_product ON public.risks USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_alerts_model ON public.safety_alerts USING btree (model_id);
CREATE INDEX IF NOT EXISTS idx_alerts_severity ON public.safety_alerts USING btree (severity);
CREATE INDEX IF NOT EXISTS idx_alerts_status ON public.safety_alerts USING btree (status);
CREATE INDEX IF NOT EXISTS idx_assessments_output ON public.safety_assessments USING btree (output_id);
CREATE INDEX IF NOT EXISTS idx_assessments_product ON public.safety_assessments USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_assessments_risk ON public.safety_assessments USING btree (risk_level);
CREATE INDEX IF NOT EXISTS idx_assessments_safe ON public.safety_assessments USING btree (is_safe);
CREATE INDEX IF NOT EXISTS idx_safety_assessments_risk_date ON public.safety_assessments USING btree (risk_level, assessed_at);
CREATE INDEX IF NOT EXISTS idx_metrics_assessment ON public.safety_metrics USING btree (assessment_id);
CREATE INDEX IF NOT EXISTS idx_metrics_name ON public.safety_metrics USING btree (metric_name);
CREATE INDEX IF NOT EXISTS idx_scenario_intent_personas_product ON public.scenario_intent_personas USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_scenario_intents_product ON public.scenario_intents USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_scenario_personas_product ON public.scenario_personas USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_scenario_scores_product ON public.scenario_scores USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_scenario_test_types_product ON public.scenario_test_types USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_scenario_threats_product ON public.scenario_threats USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_scenarios_persona ON public.scenarios USING btree (persona_id);
CREATE INDEX IF NOT EXISTS idx_scenarios_product ON public.scenarios USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_scenarios_session ON public.scenarios USING btree (session_id);
CREATE INDEX IF NOT EXISTS idx_scenarios_tenant ON public.scenarios USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_scenarios_tenant_status ON public.scenarios USING btree (tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_test_categories_product ON public.test_categories USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_executions_model ON public.test_executions USING btree (model_id);
CREATE INDEX IF NOT EXISTS idx_executions_product ON public.test_executions USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_executions_start ON public.test_executions USING btree (execution_start);
CREATE INDEX IF NOT EXISTS idx_executions_status ON public.test_executions USING btree (status);
CREATE INDEX IF NOT EXISTS idx_executions_test ON public.test_executions USING btree (test_case_id);
CREATE INDEX IF NOT EXISTS idx_test_executions_model_status ON public.test_executions USING btree (model_id, status);
CREATE INDEX IF NOT EXISTS idx_test_sessions_customer ON public.test_sessions USING btree (customer_id);
CREATE INDEX IF NOT EXISTS idx_test_sessions_product ON public.test_sessions USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_test_sessions_tenant ON public.test_sessions USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_test_types_product ON public.test_types USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_threat_examples_product ON public.threat_examples USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_threat_vectors_category ON public.threat_vectors USING btree (category);
CREATE INDEX IF NOT EXISTS idx_threat_vectors_product ON public.threat_vectors USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_threat_vectors_severity ON public.threat_vectors USING btree (severity);
CREATE INDEX IF NOT EXISTS idx_use_cases_product ON public.use_cases USING btree (product_id);
