-- GENERATED FILE -- DO NOT EDIT BY HAND.
-- Regenerate: python3 scripts/generate_variants.py
-- Source of truth: docs/verification/LIVE_SCHEMA_DDL_COMPACT.sql
-- Subset of the canonical schema; membership: sql/variants/manifests.json.

SET search_path = public;

-- ==========================================================================
-- SEQUENCES
-- ==========================================================================

CREATE SEQUENCE IF NOT EXISTS public.ai_agents_agent_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.audit_logs_log_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.behavioral_traits_catalog_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.client_models_model_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.demographic_traits_catalog_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.linguistic_traits_catalog_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.pca_models_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.product_usage_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.psychographic_traits_catalog_id_seq;
CREATE SEQUENCE IF NOT EXISTS public.technographic_traits_catalog_id_seq;

-- ==========================================================================
-- TABLES
-- ==========================================================================

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

CREATE TABLE IF NOT EXISTS public."peregrine_embeddings" (
    "id" text NOT NULL,
    "embedding_data" jsonb NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "embedding_uuid" uuid DEFAULT gen_random_uuid(),
    "origin" text DEFAULT 'user_generated'::text,
    "archived" boolean DEFAULT false NOT NULL,
    "tenant_id" uuid
);

CREATE TABLE IF NOT EXISTS public."peregrine_pca_models" (
    "id" bigint DEFAULT nextval('pca_models_id_seq'::regclass) NOT NULL,
    "product_id" uuid DEFAULT '5a1961c3-848c-4cdb-adb6-7d66891bf5f1'::uuid NOT NULL,
    "pca_name" text DEFAULT 'peregrine_pca_default'::text NOT NULL,
    "components_count" integer DEFAULT 2 NOT NULL,
    "explained_variance_ratio" jsonb,
    "mean_vector" jsonb,
    "principal_components" jsonb,
    "scaler_params" jsonb,
    "embedding_model" text,
    "embedding_dimensions" integer,
    "is_active" boolean DEFAULT true,
    "version" integer DEFAULT 1,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "explained_variance" double precision[],
    "archived" boolean DEFAULT false NOT NULL,
    "tenant_id" uuid
);

CREATE TABLE IF NOT EXISTS public."peregrine_prompt_library" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "source_type" text NOT NULL,
    "cat_turn_id" bigint,
    "client_prompt_id" uuid,
    "prompt_text" text NOT NULL,
    "prompt_hash" text,
    "cat_stage" integer,
    "quality_score" double precision,
    "gold" boolean DEFAULT false,
    "status" text DEFAULT 'active'::text NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "archived" boolean DEFAULT false NOT NULL
);

CREATE TABLE IF NOT EXISTS public."peregrine_prompt_submissions" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "product_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "model_id" bigint,
    "submitted_by" text,
    "submission_channel" text DEFAULT 'api'::text,
    "prompt_text" text NOT NULL,
    "prompt_hash" text,
    "status" text DEFAULT 'submitted'::text NOT NULL,
    "review_notes" text,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    "archived" boolean DEFAULT false NOT NULL
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

CREATE TABLE IF NOT EXISTS public."peregrine_vectors_2d" (
    "id" text NOT NULL,
    "x" double precision NOT NULL,
    "y" double precision NOT NULL,
    "metadata" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "vector_uuid" uuid DEFAULT gen_random_uuid(),
    "origin" text DEFAULT 'user_generated'::text,
    "pca_metadata_id" text,
    "archived" boolean DEFAULT false NOT NULL,
    "tenant_id" uuid
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

CREATE TABLE IF NOT EXISTS public."linguistic_traits_catalog" (
    "id" bigint DEFAULT nextval('linguistic_traits_catalog_id_seq'::regclass) NOT NULL,
    "key" text NOT NULL,
    "label" text NOT NULL,
    "data_type" text DEFAULT 'text'::text NOT NULL,
    "allowed_values" jsonb,
    "description" text,
    "persona_type" text DEFAULT 'regular'::text
);

CREATE TABLE IF NOT EXISTS public."product_prompt_lineage" (
    "id" uuid DEFAULT gen_random_uuid() NOT NULL,
    "ai_range_turn_id" bigint NOT NULL,
    "peregrine_prompt_id" uuid NOT NULL,
    "ai_range_product_id" uuid NOT NULL,
    "peregrine_product_id" uuid NOT NULL,
    "lineage_type" text DEFAULT 'stage4'::text NOT NULL,
    "created_at" timestamp with time zone DEFAULT now(),
    "metadata" jsonb DEFAULT '{}'::jsonb
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

CREATE TABLE IF NOT EXISTS public."risk_metrics" (
    "id" text NOT NULL,
    "conversation_id" text,
    "product_id" uuid,
    "ground_truth_id" text,
    "risk_score" double precision,
    "risk_data" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."robustness_analysis" (
    "id" text NOT NULL,
    "conversation_id" text,
    "product_id" uuid,
    "ground_truth_id" text,
    "robustness_score" double precision,
    "analysis_data" jsonb DEFAULT '{}'::jsonb,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public."sycophancy_events" (
    "id" text NOT NULL,
    "conversation_id" text,
    "turn_id" text,
    "product_id" uuid,
    "ground_truth_id" text,
    "sycophancy_score" double precision,
    "event_data" jsonb DEFAULT '{}'::jsonb,
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

-- ==========================================================================
-- CONSTRAINTS
-- ==========================================================================

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
    ALTER TABLE ONLY public."peregrine_embeddings" ADD CONSTRAINT "embeddings_origin_check" CHECK (origin = ANY (ARRAY['default'::text, 'user_generated'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_embeddings" ADD CONSTRAINT "embeddings_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_pca_models" ADD CONSTRAINT "pca_models_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_pca_models" ADD CONSTRAINT "pca_models_pca_name_key" UNIQUE (pca_name);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_library" ADD CONSTRAINT "chk_peregrine_prompt_source" CHECK (source_type = 'cat-astrophic'::text AND cat_turn_id IS NOT NULL AND client_prompt_id IS NULL OR source_type = 'client'::text AND client_prompt_id IS NOT NULL AND cat_turn_id IS NULL);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_library" ADD CONSTRAINT "peregrine_prompt_library_source_type_check" CHECK (source_type = ANY (ARRAY['cat-astrophic'::text, 'client'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_library" ADD CONSTRAINT "peregrine_prompt_library_status_check" CHECK (status = ANY (ARRAY['active'::text, 'inactive'::text, 'archived'::text, 'rejected'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_library" ADD CONSTRAINT "fk_peregrine_prompt_library_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_library" ADD CONSTRAINT "peregrine_prompt_library_client_prompt_id_fkey" FOREIGN KEY (client_prompt_id) REFERENCES peregrine_prompt_submissions(id) ON DELETE SET NULL;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_library" ADD CONSTRAINT "peregrine_prompt_library_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_library" ADD CONSTRAINT "peregrine_prompt_library_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_library" ADD CONSTRAINT "peregrine_prompt_library_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_submissions" ADD CONSTRAINT "client_prompt_submissions_status_check" CHECK (status = ANY (ARRAY['submitted'::text, 'approved'::text, 'rejected'::text, 'archived'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_submissions" ADD CONSTRAINT "client_prompt_submissions_submission_channel_check" CHECK (submission_channel = ANY (ARRAY['api'::text, 'ui'::text, 'import'::text, 'other'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_submissions" ADD CONSTRAINT "client_prompt_submissions_model_id_fkey" FOREIGN KEY (model_id) REFERENCES client_models(model_id) ON DELETE SET NULL;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_submissions" ADD CONSTRAINT "client_prompt_submissions_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_submissions" ADD CONSTRAINT "client_prompt_submissions_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_submissions" ADD CONSTRAINT "fk_client_prompt_submissions_product" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_prompt_submissions" ADD CONSTRAINT "client_prompt_submissions_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_turns" ADD CONSTRAINT "fk_turns_pca_model" FOREIGN KEY (pca_metadata_id) REFERENCES peregrine_pca_models(pca_name) ON DELETE SET NULL;
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
    ALTER TABLE ONLY public."peregrine_vectors_2d" ADD CONSTRAINT "vectors_2d_origin_check" CHECK (origin = ANY (ARRAY['default'::text, 'user_generated'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_vectors_2d" ADD CONSTRAINT "fk_vectors2d_pca_model" FOREIGN KEY (pca_metadata_id) REFERENCES peregrine_pca_models(pca_name) ON DELETE SET NULL;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."peregrine_vectors_2d" ADD CONSTRAINT "vectors_2d_pkey" PRIMARY KEY (id);
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
    ALTER TABLE ONLY public."product_prompt_lineage" ADD CONSTRAINT "product_prompt_lineage_lineage_type_check" CHECK (lineage_type = ANY (ARRAY['stage4'::text, 'other'::text]));
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."product_prompt_lineage" ADD CONSTRAINT "product_prompt_lineage_ai_range_product_id_fkey" FOREIGN KEY (ai_range_product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."product_prompt_lineage" ADD CONSTRAINT "product_prompt_lineage_peregrine_product_id_fkey" FOREIGN KEY (peregrine_product_id) REFERENCES products(id) ON DELETE RESTRICT;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."product_prompt_lineage" ADD CONSTRAINT "product_prompt_lineage_peregrine_prompt_id_fkey" FOREIGN KEY (peregrine_prompt_id) REFERENCES peregrine_prompt_library(id) ON DELETE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."product_prompt_lineage" ADD CONSTRAINT "product_prompt_lineage_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."product_prompt_lineage" ADD CONSTRAINT "product_prompt_lineage_ai_range_turn_id_peregrine_prompt_id_key" UNIQUE (ai_range_turn_id, peregrine_prompt_id);
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
    ALTER TABLE ONLY public."risk_metrics" ADD CONSTRAINT "risk_metrics_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."risk_metrics" ADD CONSTRAINT "risk_metrics_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."robustness_analysis" ADD CONSTRAINT "robustness_analysis_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."robustness_analysis" ADD CONSTRAINT "robustness_analysis_pkey" PRIMARY KEY (id);
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."sycophancy_events" ADD CONSTRAINT "sycophancy_events_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;
DO $$ BEGIN
    ALTER TABLE ONLY public."sycophancy_events" ADD CONSTRAINT "sycophancy_events_pkey" PRIMARY KEY (id);
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

-- ==========================================================================
-- INDEXES
-- ==========================================================================

CREATE INDEX IF NOT EXISTS idx_ai_agents_product ON public.ai_agents USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_ai_agents_type_status ON public.ai_agents USING btree (agent_type, status);
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
CREATE INDEX IF NOT EXISTS idx_peregrine_embeddings_active ON public.peregrine_embeddings USING btree (id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_embeddings_origin ON public.peregrine_embeddings USING btree (origin);
CREATE INDEX IF NOT EXISTS idx_embeddings_uuid ON public.peregrine_embeddings USING btree (embedding_uuid);
CREATE INDEX IF NOT EXISTS idx_peregrine_pca_models_active ON public.peregrine_pca_models USING btree (id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_pca_models_active ON public.peregrine_pca_models USING btree (is_active) WHERE (is_active = true);
CREATE INDEX IF NOT EXISTS idx_pca_models_created ON public.peregrine_pca_models USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_pca_models_embedding_model ON public.peregrine_pca_models USING btree (embedding_model);
CREATE INDEX IF NOT EXISTS idx_peregrine_prompt_library_active ON public.peregrine_prompt_library USING btree (id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_peregrine_prompt_library_cat_turn ON public.peregrine_prompt_library USING btree (cat_turn_id);
CREATE INDEX IF NOT EXISTS idx_peregrine_prompt_library_gold ON public.peregrine_prompt_library USING btree (gold);
CREATE INDEX IF NOT EXISTS idx_peregrine_prompt_library_hash ON public.peregrine_prompt_library USING btree (prompt_hash);
CREATE INDEX IF NOT EXISTS idx_peregrine_prompt_library_product ON public.peregrine_prompt_library USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_peregrine_prompt_library_source ON public.peregrine_prompt_library USING btree (source_type);
CREATE INDEX IF NOT EXISTS idx_peregrine_prompt_library_status ON public.peregrine_prompt_library USING btree (status);
CREATE INDEX IF NOT EXISTS idx_peregrine_prompt_library_tenant ON public.peregrine_prompt_library USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_peregrine_prompt_submissions_active ON public.peregrine_prompt_submissions USING btree (id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_client_prompt_submissions_hash ON public.peregrine_prompt_submissions USING btree (prompt_hash);
CREATE INDEX IF NOT EXISTS idx_client_prompt_submissions_product ON public.peregrine_prompt_submissions USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_client_prompt_submissions_status ON public.peregrine_prompt_submissions USING btree (status);
CREATE INDEX IF NOT EXISTS idx_client_prompt_submissions_tenant ON public.peregrine_prompt_submissions USING btree (tenant_id);
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
CREATE INDEX IF NOT EXISTS idx_peregrine_vectors_2d_active ON public.peregrine_vectors_2d USING btree (id) WHERE (archived = false);
CREATE INDEX IF NOT EXISTS idx_vectors2d_pca_metadata ON public.peregrine_vectors_2d USING btree (pca_metadata_id) WHERE (pca_metadata_id IS NOT NULL);
CREATE INDEX IF NOT EXISTS idx_vectors_2d_origin ON public.peregrine_vectors_2d USING btree (origin);
CREATE INDEX IF NOT EXISTS idx_vectors_2d_uuid ON public.peregrine_vectors_2d USING btree (vector_uuid);
CREATE INDEX IF NOT EXISTS idx_client_model_products_model ON public.client_model_products USING btree (model_id);
CREATE INDEX IF NOT EXISTS idx_client_model_products_product ON public.client_model_products USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_client_model_products_tenant ON public.client_model_products USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_client_models_client_status ON public.client_models USING btree (client_id, status);
CREATE INDEX IF NOT EXISTS idx_client_models_status_risk ON public.client_models USING btree (status, risk_level);
CREATE INDEX IF NOT EXISTS idx_client_models_tenant ON public.client_models USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_client_subscriptions_product ON public.client_product_subscriptions USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_client_subscriptions_status ON public.client_product_subscriptions USING btree (subscription_status);
CREATE INDEX IF NOT EXISTS idx_client_subscriptions_tenant ON public.client_product_subscriptions USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_prompt_lineage_ai_range_turn ON public.product_prompt_lineage USING btree (ai_range_turn_id);
CREATE INDEX IF NOT EXISTS idx_prompt_lineage_peregrine_prompt ON public.product_prompt_lineage USING btree (peregrine_prompt_id);
CREATE INDEX IF NOT EXISTS idx_prompt_lineage_products ON public.product_prompt_lineage USING btree (ai_range_product_id, peregrine_product_id);
CREATE INDEX IF NOT EXISTS idx_product_usage_created ON public.product_usage USING btree (created_at);
CREATE INDEX IF NOT EXISTS idx_product_usage_product ON public.product_usage USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_product_usage_product_tenant_date ON public.product_usage USING btree (product_id, tenant_id, created_at);
CREATE INDEX IF NOT EXISTS idx_product_usage_tenant ON public.product_usage USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_product_usage_type ON public.product_usage USING btree (usage_type);
CREATE INDEX IF NOT EXISTS idx_products_code_status ON public.products USING btree (product_code, status);
CREATE INDEX IF NOT EXISTS idx_risk_metrics_conversation_id ON public.risk_metrics USING btree (conversation_id);
CREATE INDEX IF NOT EXISTS idx_risk_metrics_ground_truth_id ON public.risk_metrics USING btree (ground_truth_id);
CREATE INDEX IF NOT EXISTS idx_risk_metrics_product_id ON public.risk_metrics USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_robustness_conversation_id ON public.robustness_analysis USING btree (conversation_id);
CREATE INDEX IF NOT EXISTS idx_robustness_ground_truth_id ON public.robustness_analysis USING btree (ground_truth_id);
CREATE INDEX IF NOT EXISTS idx_robustness_product_id ON public.robustness_analysis USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_sycophancy_conversation_id ON public.sycophancy_events USING btree (conversation_id);
CREATE INDEX IF NOT EXISTS idx_sycophancy_ground_truth_id ON public.sycophancy_events USING btree (ground_truth_id);
CREATE INDEX IF NOT EXISTS idx_sycophancy_product_id ON public.sycophancy_events USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_sycophancy_turn_id ON public.sycophancy_events USING btree (turn_id);
