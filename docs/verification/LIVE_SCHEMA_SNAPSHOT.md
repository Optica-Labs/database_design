# Live Supabase Public Schema Snapshot

Captured (UTC): 2026-03-16T17:17:07.569700+00:00

## Summary

- Relations: 100
- Base tables: 94
- Views: 6
- Columns: 1193
- Constraints: 708
- Indexes: 368

## Tables

### adversarial_test_cases

Columns: 13 | Constraints: 11 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | test_case_id | bigint | NO | nextval('adversarial_test_cases_test_case_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | category_id | integer | YES |  |
| 4 | test_name | text | NO |  |
| 5 | test_prompt | text | NO |  |
| 6 | expected_behavior | text | YES |  |
| 7 | attack_type | text | YES |  |
| 8 | severity | text | NO |  |
| 9 | is_active | boolean | NO | true |
| 10 | created_by_agent_id | bigint | YES |  |
| 11 | created_at | timestamp with time zone | YES | now() |
| 12 | updated_at | timestamp with time zone | YES | now() |
| 13 | metadata | jsonb | YES |  |

### agent_interaction_decisions

Columns: 10 | Constraints: 12 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | agent_interaction_id | uuid | NO |  |
| 4 | decision_point | text | NO |  |
| 5 | decision_type | character varying | NO |  |
| 6 | decision_criteria | jsonb | NO |  |
| 7 | decision_result | character varying | NO |  |
| 8 | alternative_paths | jsonb | YES |  |
| 9 | confidence_score | double precision | YES |  |
| 10 | created_at | timestamp with time zone | NO | now() |

### agent_interaction_flow

Columns: 11 | Constraints: 14 | Indexes: 6

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | generation_run_id | bigint | NO |  |
| 4 | source_agent_interaction_id | uuid | NO |  |
| 5 | target_agent_interaction_id | uuid | NO |  |
| 6 | flow_type | character varying | NO |  |
| 7 | flow_sequence | integer | NO |  |
| 8 | data_exchanged | jsonb | YES |  |
| 9 | transfer_timestamp | timestamp with time zone | NO | now() |
| 10 | size_bytes | integer | YES |  |
| 11 | created_at | timestamp with time zone | NO | now() |

### agent_interaction_inputs

Columns: 8 | Constraints: 10 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | agent_interaction_id | uuid | NO |  |
| 4 | input_key | text | NO |  |
| 5 | input_type | character varying | NO |  |
| 6 | input_value | text | YES |  |
| 7 | input_description | text | YES |  |
| 8 | created_at | timestamp with time zone | NO | now() |

### agent_interaction_libraries

Columns: 10 | Constraints: 12 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | agent_interaction_id | uuid | NO |  |
| 4 | library_type | character varying | NO |  |
| 5 | library_id | uuid | NO |  |
| 6 | library_name | text | YES |  |
| 7 | access_type | character varying | NO |  |
| 8 | item_count | integer | YES | 1 |
| 9 | access_details | jsonb | YES | '{}'::jsonb |
| 10 | created_at | timestamp with time zone | NO | now() |

### agent_interaction_metrics

Columns: 8 | Constraints: 10 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | agent_interaction_id | uuid | NO |  |
| 4 | metric_name | character varying | NO |  |
| 5 | metric_value | double precision | NO |  |
| 6 | metric_unit | character varying | YES |  |
| 7 | metric_category | character varying | YES |  |
| 8 | created_at | timestamp with time zone | NO | now() |

### agent_interaction_outputs

Columns: 10 | Constraints: 10 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | agent_interaction_id | uuid | NO |  |
| 4 | output_key | text | NO |  |
| 5 | output_type | character varying | NO |  |
| 6 | output_value | text | YES |  |
| 7 | output_size_bytes | integer | YES |  |
| 8 | output_description | text | YES |  |
| 9 | quality_score | double precision | YES |  |
| 10 | created_at | timestamp with time zone | NO | now() |

### agent_interactions

Columns: 16 | Constraints: 14 | Indexes: 8

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | tenant_id | uuid | NO |  |
| 4 | generation_run_id | bigint | NO |  |
| 5 | ai_agent_id | bigint | NO |  |
| 6 | interaction_sequence | integer | NO |  |
| 7 | status | character varying | NO | 'pending'::character varying |
| 8 | started_at | timestamp with time zone | YES |  |
| 9 | completed_at | timestamp with time zone | YES |  |
| 10 | execution_time_ms | integer | YES |  |
| 11 | error_message | text | YES |  |
| 12 | error_details | jsonb | YES |  |
| 13 | retry_count | integer | YES | 0 |
| 14 | metadata | jsonb | YES | '{}'::jsonb |
| 15 | created_at | timestamp with time zone | NO | now() |
| 16 | updated_at | timestamp with time zone | NO | now() |

### ai_agents

Columns: 13 | Constraints: 11 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | agent_id | bigint | NO | nextval('ai_agents_agent_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | agent_name | text | NO |  |
| 4 | agent_type | text | NO |  |
| 5 | model_architecture | text | YES |  |
| 6 | version | text | NO |  |
| 7 | description | text | YES |  |
| 8 | capabilities | jsonb | YES |  |
| 9 | status | text | NO | 'active'::text |
| 10 | created_at | timestamp with time zone | YES | now() |
| 11 | updated_at | timestamp with time zone | YES | now() |
| 12 | created_by | text | YES |  |
| 13 | metadata | jsonb | YES |  |

### ai_test_results

Columns: 15 | Constraints: 8 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | session_id | uuid | YES |  |
| 3 | test_type_id | text | YES |  |
| 4 | persona_id | text | YES |  |
| 5 | scenario_id | text | YES |  |
| 6 | status | text | YES |  |
| 7 | severity | text | YES |  |
| 8 | findings | ARRAY | YES | ARRAY[]::text[] |
| 9 | evidence | text | YES |  |
| 10 | recommendations | ARRAY | YES | ARRAY[]::text[] |
| 11 | tags | ARRAY | YES | ARRAY[]::text[] |
| 12 | executed_at | timestamp with time zone | YES |  |
| 13 | completed_at | timestamp with time zone | YES |  |
| 14 | duration_ms | integer | YES |  |
| 15 | created_at | timestamp with time zone | YES | now() |

### alpha_audit_logs

Columns: 15 | Constraints: 7 | Indexes: 6

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | log_id | bigint | NO | nextval('audit_logs_log_id_seq'::regclass) |
| 2 | event_type | text | NO |  |
| 3 | entity_type | text | NO |  |
| 4 | entity_id | bigint | NO |  |
| 5 | actor_type | text | YES |  |
| 6 | actor_id | text | YES |  |
| 7 | action | text | NO |  |
| 8 | old_values | jsonb | YES |  |
| 9 | new_values | jsonb | YES |  |
| 10 | ip_address | text | YES |  |
| 11 | user_agent | text | YES |  |
| 12 | timestamp | timestamp with time zone | YES | now() |
| 13 | metadata | jsonb | YES |  |
| 14 | archived | boolean | NO | false |
| 15 | tenant_id | uuid | YES |  |

### alpha_benchmark_results

Columns: 24 | Constraints: 5 | Indexes: 12

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | product_id | uuid | YES |  |
| 3 | ground_truth_id | text | YES |  |
| 4 | benchmark_name | text | NO |  |
| 5 | result_data | jsonb | YES | '{}'::jsonb |
| 6 | score | double precision | YES |  |
| 7 | created_at | timestamp with time zone | YES | now() |
| 8 | updated_at | timestamp with time zone | YES | now() |
| 9 | benchmark_run_id | text | YES |  |
| 10 | prompt | text | YES |  |
| 11 | response | text | YES |  |
| 12 | category | text | YES |  |
| 13 | subcategory | text | YES |  |
| 14 | expected_behavior | text | YES |  |
| 15 | metric_focus | text | YES |  |
| 16 | model_id | text | YES |  |
| 17 | latency_ms | double precision | YES |  |
| 18 | risk_score | double precision | YES |  |
| 19 | robustness | double precision | YES |  |
| 20 | scenario_id | text | YES |  |
| 21 | turn_number | integer | YES |  |
| 22 | response_timestamp | timestamp with time zone | YES |  |
| 23 | archived | boolean | NO | false |
| 24 | tenant_id | uuid | YES |  |

### alpha_benchmark_runs

Columns: 26 | Constraints: 6 | Indexes: 9

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | product_id | uuid | NO |  |
| 3 | model_key | text | NO |  |
| 4 | provider | text | NO |  |
| 5 | phi_score_phi | double precision | YES |  |
| 6 | fragility_classification | text | YES |  |
| 7 | total_conversations | integer | YES |  |
| 8 | fragile_conversations | integer | YES |  |
| 9 | peregrine_score_n | double precision | YES |  |
| 10 | peregrine_tier | text | YES |  |
| 11 | total_prompts | integer | YES |  |
| 12 | avg_risk_score | double precision | YES |  |
| 13 | avg_robustness_rho | double precision | YES |  |
| 14 | avg_latency_ms | double precision | YES |  |
| 15 | avg_toxic_sycophancy | double precision | YES |  |
| 16 | max_user_risk | double precision | YES |  |
| 17 | sycophancy_trap_pct | double precision | YES |  |
| 18 | consistency_score_sigma | double precision | YES |  |
| 19 | gold_standard_path | text | YES |  |
| 20 | run_metadata | jsonb | YES | '{}'::jsonb |
| 21 | created_at | timestamp with time zone | YES | now() |
| 22 | updated_at | timestamp with time zone | YES | now() |
| 23 | prompt_responses_count | integer | YES |  |
| 24 | migration_notes | jsonb | YES | '{}'::jsonb |
| 25 | archived | boolean | NO | false |
| 26 | tenant_id | uuid | YES |  |

### alpha_consistency_results

Columns: 15 | Constraints: 10 | Indexes: 8

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('consistency_results_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | model_key | text | NO |  |
| 4 | generation_run_id | bigint | YES |  |
| 5 | stability_score_sigma | double precision | NO |  |
| 6 | dispersion | double precision | NO |  |
| 7 | classification | text | NO |  |
| 8 | n_samples | integer | NO |  |
| 9 | source | text | NO | 'benchmark'::text |
| 10 | conversation_id | text | YES |  |
| 11 | prompt_text | text | YES |  |
| 12 | created_at | timestamp with time zone | YES | now() |
| 13 | updated_at | timestamp with time zone | YES | now() |
| 14 | archived | boolean | NO | false |
| 15 | tenant_id | uuid | YES |  |

### alpha_conversations

Columns: 24 | Constraints: 5 | Indexes: 9

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | ground_truth_id | text | YES |  |
| 3 | product_id | uuid | YES |  |
| 4 | data | jsonb | NO | '{}'::jsonb |
| 5 | created_at | timestamp with time zone | YES | now() |
| 6 | updated_at | timestamp with time zone | YES | now() |
| 7 | gold_dataset | boolean | YES | false |
| 8 | final_rho_p | double precision | YES |  |
| 9 | robustness_classification | text | YES |  |
| 10 | is_robust | boolean | YES |  |
| 11 | final_cumulative_model_risk_c_m | double precision | YES |  |
| 12 | final_cumulative_user_risk_c_u | double precision | YES |  |
| 13 | total_turns | integer | YES |  |
| 14 | archived | boolean | NO | false |
| 15 | tenant_id | uuid | YES |  |
| 16 | conversation_type | text | YES | 'standard'::text |
| 17 | model_name | text | YES |  |
| 18 | user_id | text | YES |  |
| 19 | session_id | text | YES |  |
| 20 | status | text | YES | 'active'::text |
| 21 | summary_text | text | YES | ''::text |
| 22 | summary_updated_at | timestamp with time zone | YES |  |
| 23 | summarized_turn_count | integer | YES | 0 |
| 24 | summary_version | integer | YES | 0 |

### alpha_embeddings

Columns: 8 | Constraints: 5 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | embedding_data | jsonb | NO |  |
| 3 | metadata | jsonb | YES | '{}'::jsonb |
| 4 | created_at | timestamp with time zone | YES | now() |
| 5 | embedding_uuid | uuid | YES | gen_random_uuid() |
| 6 | origin | text | YES | 'user_generated'::text |
| 7 | archived | boolean | NO | false |
| 8 | tenant_id | uuid | YES |  |

### alpha_generation_runs

Columns: 13 | Constraints: 10 | Indexes: 11

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('generation_runs_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | generation_run_id | uuid | NO |  |
| 4 | modality | character varying | YES | 'text'::character varying |
| 5 | tags | jsonb | YES | '[]'::jsonb |
| 6 | plan_metadata | jsonb | YES |  |
| 7 | coverage_map | jsonb | YES |  |
| 8 | adaptive_weights | jsonb | YES |  |
| 9 | status | character varying | YES | 'in_progress'::character varying |
| 10 | created_at | timestamp with time zone | YES | now() |
| 11 | updated_at | timestamp with time zone | YES | now() |
| 12 | archived | boolean | NO | false |
| 13 | tenant_id | uuid | YES |  |

### alpha_pca_models

Columns: 17 | Constraints: 7 | Indexes: 6

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('pca_models_id_seq'::regclass) |
| 2 | product_id | uuid | NO | '5a1961c3-848c-4cdb-adb6-7d66891bf5f1'::uuid |
| 3 | pca_name | text | NO | 'peregrine_pca_default'::text |
| 4 | components_count | integer | NO | 2 |
| 5 | explained_variance_ratio | jsonb | YES |  |
| 6 | mean_vector | jsonb | YES |  |
| 7 | principal_components | jsonb | YES |  |
| 8 | scaler_params | jsonb | YES |  |
| 9 | embedding_model | text | YES |  |
| 10 | embedding_dimensions | integer | YES |  |
| 11 | is_active | boolean | YES | true |
| 12 | version | integer | YES | 1 |
| 13 | created_at | timestamp with time zone | YES | now() |
| 14 | updated_at | timestamp with time zone | YES | now() |
| 15 | explained_variance | ARRAY | YES |  |
| 16 | archived | boolean | NO | false |
| 17 | tenant_id | uuid | YES |  |

### alpha_prompt_library

Columns: 16 | Constraints: 15 | Indexes: 9

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | tenant_id | uuid | NO |  |
| 4 | source_type | text | NO |  |
| 5 | cat_turn_id | bigint | YES |  |
| 6 | client_prompt_id | uuid | YES |  |
| 7 | prompt_text | text | NO |  |
| 8 | prompt_hash | text | YES |  |
| 9 | cat_stage | integer | YES |  |
| 10 | quality_score | double precision | YES |  |
| 11 | gold | boolean | YES | false |
| 12 | status | text | NO | 'active'::text |
| 13 | metadata | jsonb | YES | '{}'::jsonb |
| 14 | created_at | timestamp with time zone | YES | now() |
| 15 | updated_at | timestamp with time zone | YES | now() |
| 16 | archived | boolean | NO | false |

### alpha_prompt_submissions

Columns: 14 | Constraints: 13 | Indexes: 6

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | tenant_id | uuid | NO |  |
| 4 | model_id | bigint | YES |  |
| 5 | submitted_by | text | YES |  |
| 6 | submission_channel | text | YES | 'api'::text |
| 7 | prompt_text | text | NO |  |
| 8 | prompt_hash | text | YES |  |
| 9 | status | text | NO | 'submitted'::text |
| 10 | review_notes | text | YES |  |
| 11 | metadata | jsonb | YES | '{}'::jsonb |
| 12 | created_at | timestamp with time zone | YES | now() |
| 13 | updated_at | timestamp with time zone | YES | now() |
| 14 | archived | boolean | NO | false |

### alpha_telemetry

Columns: 27 | Constraints: 9 | Indexes: 8

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('telemetry_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | generation_run_id | bigint | NO |  |
| 4 | ingression_time | timestamp with time zone | YES | now() |
| 5 | egression_time | timestamp with time zone | YES | now() |
| 6 | total_entries | integer | YES | 0 |
| 7 | total_prompt_tokens | integer | YES | 0 |
| 8 | total_response_tokens | integer | YES | 0 |
| 9 | total_tokens | integer | YES | 0 |
| 10 | average_latency_ms | double precision | YES | 0.0 |
| 11 | success_rate | double precision | YES |  |
| 12 | repair_rate | double precision | YES |  |
| 13 | reject_rate | double precision | YES |  |
| 14 | avg_iterations | double precision | YES |  |
| 15 | strategy_coverage | jsonb | YES |  |
| 16 | topic_coverage | jsonb | YES |  |
| 17 | models_used | jsonb | YES | '{}'::jsonb |
| 18 | feature_flags | jsonb | YES | '[]'::jsonb |
| 19 | audit_trail_ids | jsonb | YES | '[]'::jsonb |
| 20 | retention_policy | character varying | YES | ''::character varying |
| 21 | deletion_date | timestamp with time zone | YES |  |
| 22 | errors | jsonb | YES | '[]'::jsonb |
| 23 | created_at | timestamp with time zone | YES | now() |
| 24 | updated_at | timestamp with time zone | YES | now() |
| 25 | telemetry_id | uuid | NO | gen_random_uuid() |
| 26 | archived | boolean | NO | false |
| 27 | tenant_id | uuid | YES |  |

### alpha_turns

Columns: 29 | Constraints: 7 | Indexes: 13

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | conversation_id | text | NO |  |
| 3 | product_id | uuid | YES |  |
| 4 | turn_data | jsonb | NO |  |
| 5 | created_at | timestamp with time zone | YES | now() |
| 6 | updated_at | timestamp with time zone | YES | now() |
| 16 | turn_number | integer | YES |  |
| 17 | risk_severity_r_n | double precision | YES |  |
| 18 | risk_rate_v_n | double precision | YES |  |
| 19 | guardrail_erosion_a_n | double precision | YES |  |
| 20 | likelihood_l_n | double precision | YES |  |
| 21 | robustness_rho | double precision | YES |  |
| 22 | cumulative_risk_model_c_m | double precision | YES |  |
| 23 | cumulative_risk_user_c_u | double precision | YES |  |
| 24 | failure_potential_z_n | double precision | YES |  |
| 25 | risk_severity_user_r_u | double precision | YES |  |
| 26 | toxic_sycophancy_t_syc | double precision | YES |  |
| 27 | user_risk_r_syc | double precision | YES |  |
| 28 | agreement_score_a_syc | double precision | YES |  |
| 29 | pca_metadata_id | text | YES |  |
| 30 | prompt | text | YES |  |
| 31 | response | text | YES |  |
| 32 | archived | boolean | NO | false |
| 33 | tenant_id | uuid | YES |  |
| 34 | user_message | text | YES |  |
| 35 | model_response | text | YES |  |
| 36 | model_name | text | YES |  |
| 37 | api_response_time_ms | double precision | YES |  |
| 38 | tokens_used | integer | YES |  |

### alpha_vectors_2d

Columns: 10 | Constraints: 7 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | x | double precision | NO |  |
| 3 | y | double precision | NO |  |
| 4 | metadata | jsonb | YES | '{}'::jsonb |
| 5 | created_at | timestamp with time zone | YES | now() |
| 6 | vector_uuid | uuid | YES | gen_random_uuid() |
| 7 | origin | text | YES | 'user_generated'::text |
| 8 | pca_metadata_id | text | YES |  |
| 9 | archived | boolean | NO | false |
| 10 | tenant_id | uuid | YES |  |

### analysis_results

Columns: 7 | Constraints: 5 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | product_id | uuid | YES |  |
| 3 | ground_truth_id | text | YES |  |
| 4 | analysis_type | text | NO |  |
| 5 | result_data | jsonb | NO |  |
| 6 | created_at | timestamp with time zone | YES | now() |
| 7 | updated_at | timestamp with time zone | YES | now() |

### auth_tenant_mapping

Columns: 8 | Constraints: 13 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | auth_user_id | uuid | NO |  |
| 3 | tenant_id | uuid | NO |  |
| 4 | product_id | uuid | NO |  |
| 5 | role | text | NO | 'member'::text |
| 6 | is_active | boolean | NO | true |
| 7 | created_at | timestamp with time zone | NO | now() |
| 8 | updated_at | timestamp with time zone | NO | now() |

### behavioral_traits_catalog

Columns: 8 | Constraints: 8 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('behavioral_traits_catalog_id_seq'::regclass) |
| 2 | key | text | NO |  |
| 3 | label | text | NO |  |
| 4 | data_type | text | NO | 'text'::text |
| 5 | allowed_values | jsonb | YES |  |
| 6 | description | text | YES |  |
| 7 | persona_type | text | YES | 'regular'::text |
| 8 | applicable_sub_cohorts | jsonb | YES | '[]'::jsonb |

### client_model_products

Columns: 8 | Constraints: 9 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | model_id | bigint | NO |  |
| 3 | product_id | uuid | NO |  |
| 4 | tenant_id | uuid | NO |  |
| 5 | enabled | boolean | YES | true |
| 6 | configuration | jsonb | YES | '{}'::jsonb |
| 7 | created_at | timestamp with time zone | YES | now() |
| 8 | updated_at | timestamp with time zone | YES | now() |

### client_models

Columns: 14 | Constraints: 9 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | model_id | bigint | NO | nextval('client_models_model_id_seq'::regclass) |
| 2 | tenant_id | uuid | YES |  |
| 3 | client_id | text | NO |  |
| 4 | model_name | text | NO |  |
| 5 | model_version | text | NO |  |
| 6 | model_type | text | YES |  |
| 7 | endpoint_url | text | YES |  |
| 8 | api_key_hash | text | YES |  |
| 9 | deployment_environment | text | YES |  |
| 10 | registration_date | timestamp with time zone | YES | now() |
| 11 | last_tested | timestamp with time zone | YES |  |
| 12 | status | text | NO | 'registered'::text |
| 13 | risk_level | text | YES |  |
| 14 | metadata | jsonb | YES |  |

### client_product_subscriptions

Columns: 12 | Constraints: 9 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | tenant_id | uuid | NO |  |
| 3 | product_id | uuid | NO |  |
| 4 | subscription_tier | text | YES |  |
| 5 | subscription_status | text | NO | 'active'::text |
| 6 | start_date | timestamp with time zone | YES | now() |
| 7 | end_date | timestamp with time zone | YES |  |
| 8 | usage_limits | jsonb | YES | '{}'::jsonb |
| 9 | features_enabled | jsonb | YES | '{}'::jsonb |
| 10 | created_at | timestamp with time zone | YES | now() |
| 11 | updated_at | timestamp with time zone | YES | now() |
| 12 | metadata | jsonb | YES | '{}'::jsonb |

### cohorts

Columns: 6 | Constraints: 4 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | use_case_id | uuid | YES |  |
| 3 | name | text | NO |  |
| 4 | description | text | YES |  |
| 5 | created_at | timestamp with time zone | YES | now() |
| 6 | updated_at | timestamp with time zone | YES | now() |

### compliance_reports

Columns: 17 | Constraints: 10 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | report_id | bigint | NO | nextval('compliance_reports_report_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | report_type | text | NO |  |
| 4 | model_id | bigint | YES |  |
| 5 | report_period_start | timestamp with time zone | NO |  |
| 6 | report_period_end | timestamp with time zone | NO |  |
| 7 | total_tests | integer | YES |  |
| 8 | passed_tests | integer | YES |  |
| 9 | failed_tests | integer | YES |  |
| 10 | critical_issues | integer | YES |  |
| 11 | high_issues | integer | YES |  |
| 12 | medium_issues | integer | YES |  |
| 13 | low_issues | integer | YES |  |
| 14 | overall_safety_score | numeric | YES |  |
| 15 | report_data | jsonb | YES |  |
| 16 | generated_by_agent_id | bigint | YES |  |
| 17 | generated_at | timestamp with time zone | YES | now() |

### context_profiles

Columns: 34 | Constraints: 10 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | source_intake_id | text | NO |  |
| 4 | tenant_id | uuid | YES |  |
| 5 | industry | text | NO |  |
| 6 | primary_use_case | text | NO |  |
| 7 | objectives | ARRAY | YES | '{}'::text[] |
| 8 | goals | text | YES |  |
| 9 | guardrails | ARRAY | YES | '{}'::text[] |
| 10 | frameworks | ARRAY | YES | '{}'::text[] |
| 11 | policies | ARRAY | YES | '{}'::text[] |
| 12 | legal_regulatory | ARRAY | YES | '{}'::text[] |
| 13 | api_endpoints | ARRAY | YES | '{}'::text[] |
| 14 | endpoint_url | text | YES |  |
| 15 | model_stack | ARRAY | YES | '{}'::text[] |
| 16 | ml_stack | text | YES |  |
| 17 | custom_models | text | YES |  |
| 18 | guardrails_endpoint | text | YES |  |
| 19 | guardrails_auth | text | YES |  |
| 20 | api_access_level | text | YES |  |
| 21 | integration_scan | text | YES |  |
| 22 | personas_seed | ARRAY | YES | '{}'::text[] |
| 23 | risks_seed | ARRAY | YES | '{}'::text[] |
| 24 | regular_users_type | ARRAY | YES | '{}'::text[] |
| 25 | regular_users | text | YES |  |
| 26 | attackers_type | ARRAY | YES | '{}'::text[] |
| 27 | attackers | text | YES |  |
| 28 | ai_agents_type | ARRAY | YES | '{}'::text[] |
| 29 | ai_agents | text | YES |  |
| 30 | user_distribution | text | YES |  |
| 31 | plans | jsonb | YES | '{}'::jsonb |
| 32 | notes | text | YES |  |
| 33 | created_at | timestamp with time zone | YES | now() |
| 34 | updated_at | timestamp with time zone | YES | now() |

### conversation_embeddings

Columns: 7 | Constraints: 5 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | conversation_id | text | NO |  |
| 3 | product_id | uuid | YES |  |
| 4 | embedding | ARRAY | NO |  |
| 5 | embedding_model | text | YES |  |
| 6 | created_at | timestamp with time zone | YES | now() |
| 7 | updated_at | timestamp with time zone | YES | now() |

### conversation_metrics

Columns: 9 | Constraints: 5 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | conversation_id | text | NO |  |
| 3 | product_id | uuid | YES |  |
| 4 | ground_truth_id | text | YES |  |
| 5 | metric_name | text | NO |  |
| 6 | metric_value | double precision | YES |  |
| 7 | metadata | jsonb | YES | '{}'::jsonb |
| 8 | created_at | timestamp with time zone | YES | now() |
| 9 | updated_at | timestamp with time zone | YES | now() |

### crawls

Columns: 6 | Constraints: 3 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('crawls_id_seq'::regclass) |
| 2 | source_id | bigint | YES |  |
| 3 | started_at | timestamp with time zone | YES | now() |
| 4 | finished_at | timestamp with time zone | YES |  |
| 5 | status | text | YES |  |
| 6 | stats | jsonb | YES |  |

### demographic_traits_catalog

Columns: 8 | Constraints: 8 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('demographic_traits_catalog_id_seq'::regclass) |
| 2 | key | text | NO |  |
| 3 | label | text | NO |  |
| 4 | data_type | text | NO | 'text'::text |
| 5 | allowed_values | jsonb | YES |  |
| 6 | description | text | YES |  |
| 7 | persona_type | text | YES | 'regular'::text |
| 8 | applicable_sub_cohorts | jsonb | YES | '[]'::jsonb |

### gold_prompt_metadata_staging

Columns: 6 | Constraints: 2 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | prompt_text | text | NO |  |
| 2 | ground_truth_id | text | YES |  |
| 3 | category | text | YES |  |
| 4 | subcategory | text | YES |  |
| 5 | expected_behavior | text | YES |  |
| 6 | metric_focus | text | YES |  |

### harms

Columns: 5 | Constraints: 6 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | product_id | uuid | NO |  |
| 3 | name | text | NO |  |
| 4 | description | text | YES |  |
| 5 | embedding | USER-DEFINED | YES |  |

### jailbreak_attempts

Columns: 10 | Constraints: 3 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | conversation_id | text | YES |  |
| 3 | turn_id | text | YES |  |
| 4 | product_id | uuid | YES |  |
| 5 | ground_truth_id | text | YES |  |
| 6 | attempt_type | text | YES |  |
| 7 | success | boolean | YES | false |
| 8 | attempt_data | jsonb | YES | '{}'::jsonb |
| 9 | created_at | timestamp with time zone | YES | now() |
| 10 | updated_at | timestamp with time zone | YES | now() |

### linguistic_traits_catalog

Columns: 7 | Constraints: 8 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('linguistic_traits_catalog_id_seq'::regclass) |
| 2 | key | text | NO |  |
| 3 | label | text | NO |  |
| 4 | data_type | text | NO | 'text'::text |
| 5 | allowed_values | jsonb | YES |  |
| 6 | description | text | YES |  |
| 7 | persona_type | text | YES | 'regular'::text |

### llm_invocations

Columns: 57 | Constraints: 10 | Indexes: 16

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | invocation_id | uuid | NO | gen_random_uuid() |
| 3 | product_id | uuid | YES |  |
| 4 | session_id | uuid | YES |  |
| 5 | conversation_id | bigint | YES |  |
| 6 | turn_id | bigint | YES |  |
| 7 | agent_id | uuid | YES |  |
| 8 | agent_name | text | YES |  |
| 9 | agent_type | text | YES |  |
| 10 | agent_cohort | text | YES |  |
| 11 | agent_sub_cohort | text | YES |  |
| 12 | agent_metadata | jsonb | YES |  |
| 13 | scenario_id | text | YES |  |
| 14 | test_type_id | text | YES |  |
| 15 | threat_vector_id | text | YES |  |
| 16 | test_execution_id | bigint | YES |  |
| 17 | pipeline_stage | text | YES |  |
| 18 | process_phase | text | YES |  |
| 19 | workflow_step | text | YES |  |
| 20 | model_id | text | YES |  |
| 21 | model_name | text | YES |  |
| 22 | model_version | text | YES |  |
| 23 | provider | text | YES |  |
| 24 | system_prompt | text | YES |  |
| 25 | user_prompt | text | YES |  |
| 26 | final_prompt | text | NO |  |
| 27 | final_response | text | YES |  |
| 28 | generated_text | text | YES |  |
| 29 | raw_output | jsonb | YES |  |
| 30 | request_payload | jsonb | YES |  |
| 31 | response_data | jsonb | YES |  |
| 32 | sanitized_response | jsonb | YES |  |
| 33 | status | text | YES | 'pending'::text |
| 34 | invocation_type | text | YES |  |
| 35 | latency_ms | integer | YES |  |
| 36 | prompt_tokens | integer | YES |  |
| 37 | completion_tokens | integer | YES |  |
| 38 | total_tokens | integer | YES |  |
| 39 | cost_usd | numeric | YES |  |
| 40 | confidence_score | numeric | YES |  |
| 41 | safety_score | numeric | YES |  |
| 42 | coherence_score | numeric | YES |  |
| 43 | error_code | text | YES |  |
| 44 | error_message | text | YES |  |
| 45 | retry_count | integer | YES | 0 |
| 46 | max_retries | integer | YES |  |
| 47 | cache_hit | boolean | YES | false |
| 48 | cached_from | uuid | YES |  |
| 49 | caller_context | jsonb | YES |  |
| 50 | trace_id | text | YES |  |
| 51 | parent_invocation_id | uuid | YES |  |
| 52 | tags | ARRAY | YES |  |
| 53 | metadata | jsonb | YES |  |
| 54 | created_at | timestamp with time zone | YES | now() |
| 55 | started_at | timestamp with time zone | YES |  |
| 56 | completed_at | timestamp with time zone | YES |  |
| 57 | updated_at | timestamp with time zone | YES | now() |

### model_metadata

Columns: 7 | Constraints: 4 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | product_id | uuid | YES |  |
| 3 | model_name | text | NO |  |
| 4 | model_version | text | YES |  |
| 5 | metadata | jsonb | YES | '{}'::jsonb |
| 6 | created_at | timestamp with time zone | YES | now() |
| 7 | updated_at | timestamp with time zone | YES | now() |

### model_outputs

Columns: 8 | Constraints: 4 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | output_id | bigint | NO | nextval('model_outputs_output_id_seq'::regclass) |
| 2 | execution_id | bigint | YES |  |
| 3 | output_text | text | NO |  |
| 4 | output_tokens | integer | YES |  |
| 5 | generation_time_ms | integer | YES |  |
| 6 | temperature | double precision | YES |  |
| 7 | other_parameters | jsonb | YES |  |
| 8 | created_at | timestamp with time zone | YES | now() |

### model_response_cache

Columns: 10 | Constraints: 7 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | cache_key | text | NO |  |
| 3 | model_type | text | NO |  |
| 4 | request_input | jsonb | NO |  |
| 5 | response_output | jsonb | NO |  |
| 6 | request_hash | text | NO |  |
| 7 | hit_count | integer | YES | 0 |
| 8 | created_at | timestamp with time zone | YES | now() |
| 9 | updated_at | timestamp with time zone | YES | now() |
| 10 | expires_at | timestamp without time zone | YES | (now() + '01:00:00'::interval) |

### nyc_test_results

Columns: 12 | Constraints: 3 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | prompt_response_id | uuid | YES |  |
| 3 | session_id | text | YES |  |
| 4 | persona_id | text | YES |  |
| 5 | persona_name | text | YES |  |
| 6 | test_type | text | YES |  |
| 7 | prompt | text | YES |  |
| 8 | response | jsonb | YES |  |
| 9 | execution_time_ms | integer | YES |  |
| 10 | success | boolean | YES |  |
| 11 | error_message | text | YES |  |
| 12 | created_at | timestamp with time zone | YES | now() |

### persona_actions

Columns: 7 | Constraints: 6 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | persona_id | text | YES |  |
| 4 | ts | timestamp with time zone | YES | now() |
| 5 | input | text | YES |  |
| 6 | output | text | YES |  |
| 7 | metadata | jsonb | YES |  |

### persona_behavioral_traits

Columns: 5 | Constraints: 5 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | persona_id | text | NO |  |
| 2 | trait_id | bigint | NO |  |
| 3 | raw_value | text | YES |  |
| 4 | value | jsonb | YES |  |
| 5 | updated_at | timestamp with time zone | YES | now() |

### persona_demographics

Columns: 5 | Constraints: 5 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | persona_id | text | NO |  |
| 2 | trait_id | bigint | NO |  |
| 3 | raw_value | text | YES |  |
| 4 | value | jsonb | YES |  |
| 5 | updated_at | timestamp with time zone | YES | now() |

### persona_linguistic_traits

Columns: 5 | Constraints: 5 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | persona_id | text | NO |  |
| 2 | trait_id | bigint | NO |  |
| 3 | raw_value | text | YES |  |
| 4 | value | jsonb | YES |  |
| 5 | updated_at | timestamp with time zone | YES | now() |

### persona_memories

Columns: 8 | Constraints: 7 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | persona_id | text | YES |  |
| 4 | ts | timestamp with time zone | YES | now() |
| 5 | type | text | YES |  |
| 6 | content | text | NO |  |
| 7 | metadata | jsonb | YES |  |
| 8 | embedding | USER-DEFINED | YES |  |

### persona_plans

Columns: 7 | Constraints: 7 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | persona_id | text | YES |  |
| 4 | ts | timestamp with time zone | YES | now() |
| 5 | plan | text | NO |  |
| 6 | horizon | integer | YES | 3 |
| 7 | status | text | YES | 'active'::text |

### persona_psychographic_traits

Columns: 5 | Constraints: 5 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | persona_id | text | NO |  |
| 2 | trait_id | bigint | NO |  |
| 3 | raw_value | text | YES |  |
| 4 | value | jsonb | YES |  |
| 5 | updated_at | timestamp with time zone | YES | now() |

### persona_reflections

Columns: 6 | Constraints: 7 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | persona_id | text | YES |  |
| 4 | ts | timestamp with time zone | YES | now() |
| 5 | summary | text | NO |  |
| 6 | embedding | USER-DEFINED | YES |  |

### persona_technographic_traits

Columns: 5 | Constraints: 5 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | persona_id | text | NO |  |
| 2 | trait_id | bigint | NO |  |
| 3 | raw_value | text | YES |  |
| 4 | value | jsonb | YES |  |
| 5 | updated_at | timestamp with time zone | YES | now() |

### personas

Columns: 32 | Constraints: 15 | Indexes: 7

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO | (gen_random_uuid())::text |
| 2 | product_id | uuid | NO |  |
| 3 | tenant_id | text | NO |  |
| 4 | session_id | text | YES |  |
| 5 | use_case_id | uuid | YES |  |
| 6 | cohort_id | uuid | YES |  |
| 7 | sub_cohort_id | uuid | YES |  |
| 8 | name | text | NO |  |
| 9 | display_name | text | NO |  |
| 10 | slug | text | YES |  |
| 11 | archetype | text | YES |  |
| 12 | persona_type | text | NO | 'regular'::text |
| 13 | actor_type | text | YES |  |
| 14 | domain | text | YES |  |
| 15 | intent | text | YES |  |
| 16 | skill_level | text | YES |  |
| 17 | overview | text | YES |  |
| 18 | description | text | YES |  |
| 19 | bio | text | YES |  |
| 20 | quote | text | YES |  |
| 21 | traits | jsonb | YES |  |
| 22 | constraints | jsonb | YES |  |
| 23 | attributes | jsonb | YES | '{}'::jsonb |
| 24 | source | text | YES |  |
| 25 | is_ai | boolean | YES | true |
| 26 | status | text | NO | 'active'::text |
| 27 | version | integer | NO | 1 |
| 28 | language | text | YES | 'English'::text |
| 29 | embedding | USER-DEFINED | YES |  |
| 30 | created_by | uuid | YES |  |
| 31 | created_at | timestamp with time zone | YES | now() |
| 32 | updated_at | timestamp with time zone | YES | now() |

### product_prompt_lineage

Columns: 8 | Constraints: 12 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | ai_range_turn_id | bigint | NO |  |
| 3 | peregrine_prompt_id | uuid | NO |  |
| 4 | ai_range_product_id | uuid | NO |  |
| 5 | peregrine_product_id | uuid | NO |  |
| 6 | lineage_type | text | NO | 'stage4'::text |
| 7 | created_at | timestamp with time zone | YES | now() |
| 8 | metadata | jsonb | YES | '{}'::jsonb |

### product_usage

Columns: 6 | Constraints: 8 | Indexes: 6

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('product_usage_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | tenant_id | uuid | NO |  |
| 4 | usage_type | text | NO |  |
| 5 | usage_metadata | jsonb | YES | '{}'::jsonb |
| 6 | created_at | timestamp with time zone | NO | now() |

### products

Columns: 10 | Constraints: 8 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_code | text | NO |  |
| 3 | product_name | text | NO |  |
| 4 | description | text | YES |  |
| 5 | features | jsonb | YES | '{}'::jsonb |
| 6 | pricing_tier | text | YES |  |
| 7 | status | text | NO | 'active'::text |
| 8 | created_at | timestamp with time zone | YES | now() |
| 9 | updated_at | timestamp with time zone | YES | now() |
| 10 | metadata | jsonb | YES | '{}'::jsonb |

### prompt_generator_responses

Columns: 39 | Constraints: 17 | Indexes: 8

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | generation_run_id | bigint | YES |  |
| 4 | session_id | uuid | YES |  |
| 5 | conversation_id | character varying | YES |  |
| 6 | turn_id | character varying | YES |  |
| 7 | persona_id | text | YES |  |
| 8 | persona_name | text | YES |  |
| 9 | scenario_id | text | YES |  |
| 10 | test_type_id | text | YES |  |
| 11 | threat_vector_id | text | YES |  |
| 12 | final_prompt | text | NO |  |
| 13 | final_response | jsonb | NO |  |
| 14 | generated_text | text | YES |  |
| 15 | test_types | jsonb | YES |  |
| 16 | raw_output | jsonb | YES |  |
| 17 | invocation_id | uuid | NO |  |
| 18 | model_id | character varying | NO |  |
| 19 | model_name | text | YES |  |
| 20 | model_version | text | YES |  |
| 21 | provider | text | YES |  |
| 22 | request_payload | jsonb | YES |  |
| 23 | response_data | jsonb | YES |  |
| 24 | sanitized_response | jsonb | YES |  |
| 25 | status | character varying | YES | 'success'::character varying |
| 26 | latency_ms | double precision | YES |  |
| 27 | prompt_tokens | integer | YES | 0 |
| 28 | completion_tokens | integer | YES | 0 |
| 29 | total_tokens | integer | YES | 0 |
| 30 | error_code | character varying | YES |  |
| 31 | error_message | text | YES |  |
| 32 | cache_hit | boolean | YES | false |
| 33 | retry_count | integer | YES | 0 |
| 34 | invocation_type | character varying | YES | 'async'::character varying |
| 35 | caller_context | jsonb | YES |  |
| 36 | metadata | jsonb | YES | '{}'::jsonb |
| 37 | created_at | timestamp with time zone | YES | now() |
| 38 | completed_at | timestamp with time zone | YES |  |
| 39 | updated_at | timestamp with time zone | YES | now() |

### psychographic_traits_catalog

Columns: 8 | Constraints: 8 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('psychographic_traits_catalog_id_seq'::regclass) |
| 2 | key | text | NO |  |
| 3 | label | text | NO |  |
| 4 | data_type | text | NO | 'text'::text |
| 5 | allowed_values | jsonb | YES |  |
| 6 | description | text | YES |  |
| 7 | persona_type | text | YES | 'regular'::text |
| 8 | applicable_sub_cohorts | jsonb | YES | '[]'::jsonb |

### quality_metrics

Columns: 10 | Constraints: 6 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('quality_metrics_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | conversation_id | bigint | NO |  |
| 4 | methodology | character varying | YES | ''::character varying |
| 5 | metrics | jsonb | YES | '{}'::jsonb |
| 6 | fit_score | double precision | YES |  |
| 7 | diversity_score | double precision | YES |  |
| 8 | policy_risk_score | double precision | YES |  |
| 9 | length_score | double precision | YES |  |
| 10 | created_at | timestamp with time zone | YES | now() |

### raw_items

Columns: 9 | Constraints: 3 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('raw_items_id_seq'::regclass) |
| 2 | source_id | bigint | YES |  |
| 3 | external_id | text | YES |  |
| 4 | title | text | YES |  |
| 5 | raw_text | text | YES |  |
| 6 | metadata | jsonb | YES |  |
| 7 | content_type | text | YES |  |
| 8 | sha256 | text | YES |  |
| 9 | inserted_at | timestamp with time zone | YES | now() |

### risk_assessments

Columns: 14 | Constraints: 8 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | context_profile_id | uuid | YES |  |
| 4 | source_intake_id | text | NO |  |
| 5 | assessment_mode | text | YES | 'agentic'::text |
| 6 | threats | jsonb | YES | '[]'::jsonb |
| 7 | scenarios | jsonb | YES | '[]'::jsonb |
| 8 | summary | jsonb | YES | '{}'::jsonb |
| 9 | agent_endpoint | text | YES |  |
| 10 | generation_time_ms | integer | YES |  |
| 11 | api_response_status | integer | YES |  |
| 12 | error_message | text | YES |  |
| 13 | created_at | timestamp with time zone | YES | now() |
| 14 | updated_at | timestamp with time zone | YES | now() |

### risk_metrics

Columns: 8 | Constraints: 3 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | conversation_id | text | YES |  |
| 3 | product_id | uuid | YES |  |
| 4 | ground_truth_id | text | YES |  |
| 5 | risk_score | double precision | YES |  |
| 6 | risk_data | jsonb | YES | '{}'::jsonb |
| 7 | created_at | timestamp with time zone | YES | now() |
| 8 | updated_at | timestamp with time zone | YES | now() |

### risks

Columns: 5 | Constraints: 6 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | product_id | uuid | NO |  |
| 3 | name | text | NO |  |
| 4 | description | text | YES |  |
| 5 | embedding | USER-DEFINED | YES |  |

### robustness_analysis

Columns: 8 | Constraints: 3 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | conversation_id | text | YES |  |
| 3 | product_id | uuid | YES |  |
| 4 | ground_truth_id | text | YES |  |
| 5 | robustness_score | double precision | YES |  |
| 6 | analysis_data | jsonb | YES | '{}'::jsonb |
| 7 | created_at | timestamp with time zone | YES | now() |
| 8 | updated_at | timestamp with time zone | YES | now() |

### safety_alerts

Columns: 12 | Constraints: 10 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | alert_id | bigint | NO | nextval('safety_alerts_alert_id_seq'::regclass) |
| 2 | model_id | bigint | YES |  |
| 3 | assessment_id | bigint | YES |  |
| 4 | alert_type | text | NO |  |
| 5 | severity | text | NO |  |
| 6 | title | text | NO |  |
| 7 | description | text | YES |  |
| 8 | status | text | NO | 'open'::text |
| 9 | detected_at | timestamp with time zone | YES | now() |
| 10 | resolved_at | timestamp with time zone | YES |  |
| 11 | resolved_by | text | YES |  |
| 12 | resolution_notes | text | YES |  |

### safety_assessments

Columns: 12 | Constraints: 12 | Indexes: 6

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | assessment_id | bigint | NO | nextval('safety_assessments_assessment_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | output_id | bigint | YES |  |
| 4 | evaluator_agent_id | bigint | YES |  |
| 5 | safety_score | numeric | YES |  |
| 6 | is_safe | boolean | NO |  |
| 7 | risk_level | text | NO |  |
| 8 | violation_types | jsonb | YES |  |
| 9 | reasoning | text | YES |  |
| 10 | confidence_score | numeric | YES |  |
| 11 | assessed_at | timestamp with time zone | YES | now() |
| 12 | metadata | jsonb | YES |  |

### safety_metrics

Columns: 7 | Constraints: 6 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | metric_id | bigint | NO | nextval('safety_metrics_metric_id_seq'::regclass) |
| 2 | assessment_id | bigint | YES |  |
| 3 | metric_name | text | NO |  |
| 4 | metric_value | numeric | NO |  |
| 5 | metric_unit | text | YES |  |
| 6 | threshold_exceeded | boolean | NO | false |
| 7 | metadata | jsonb | YES |  |

### safety_scores

Columns: 9 | Constraints: 3 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | conversation_id | text | YES |  |
| 3 | turn_id | text | YES |  |
| 4 | product_id | uuid | YES |  |
| 5 | ground_truth_id | text | YES |  |
| 6 | safety_score | double precision | YES |  |
| 7 | score_data | jsonb | YES | '{}'::jsonb |
| 8 | created_at | timestamp with time zone | YES | now() |
| 9 | updated_at | timestamp with time zone | YES | now() |

### scenario_intent_personas

Columns: 6 | Constraints: 9 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | product_id | uuid | NO |  |
| 2 | intent_id | uuid | NO |  |
| 3 | persona_id | text | NO |  |
| 4 | relevance_score | numeric | YES |  |
| 5 | notes | text | YES |  |
| 6 | created_at | timestamp with time zone | YES | now() |

### scenario_intents

Columns: 28 | Constraints: 10 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | scenario_id | text | YES |  |
| 4 | intent_name | text | NO |  |
| 5 | description | text | YES |  |
| 6 | temporal_trigger | text | YES |  |
| 7 | spatial_trigger | text | YES |  |
| 8 | event_trigger | text | YES |  |
| 9 | social_context | text | YES |  |
| 10 | environmental_context | text | YES |  |
| 11 | steps | text | YES |  |
| 12 | available_actions | text | YES |  |
| 13 | decision_points | text | YES |  |
| 14 | objects_involved | text | YES |  |
| 15 | object_states | jsonb | YES |  |
| 16 | scenario_goal | text | YES |  |
| 17 | success_criteria | text | YES |  |
| 18 | failure_conditions | text | YES |  |
| 19 | constraints | text | YES |  |
| 20 | information_channels | text | YES |  |
| 21 | visibility_rules | text | YES |  |
| 22 | frequency | text | YES |  |
| 23 | relevance_score | numeric | YES |  |
| 24 | status | text | YES | 'active'::text |
| 25 | priority | text | YES |  |
| 26 | tags | jsonb | YES |  |
| 27 | created_at | timestamp with time zone | YES | now() |
| 28 | updated_at | timestamp with time zone | YES | now() |

### scenario_personas

Columns: 6 | Constraints: 7 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO | (gen_random_uuid())::text |
| 2 | product_id | uuid | NO |  |
| 3 | scenario_id | text | YES |  |
| 4 | persona_id | text | YES |  |
| 5 | relevance_score | double precision | YES |  |
| 6 | created_at | timestamp with time zone | YES | now() |

### scenario_scores

Columns: 7 | Constraints: 8 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO | (gen_random_uuid())::text |
| 2 | product_id | uuid | NO |  |
| 3 | scenario_id | text | YES |  |
| 4 | score_type | text | NO |  |
| 5 | score_value | double precision | NO |  |
| 6 | metadata | jsonb | YES | '{}'::jsonb |
| 7 | created_at | timestamp with time zone | YES | now() |

### scenario_seeds

Columns: 12 | Constraints: 2 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('scenario_seeds_id_seq'::regclass) |
| 2 | title | text | YES |  |
| 3 | summary | text | YES |  |
| 4 | persona_hint | jsonb | YES |  |
| 5 | scenario_context | text | YES |  |
| 6 | linked_techniques | ARRAY | YES |  |
| 7 | risk_vector | text | YES |  |
| 8 | harm_category | text | YES |  |
| 9 | tags | ARRAY | YES | '{}'::text[] |
| 10 | embedding | USER-DEFINED | YES |  |
| 11 | provenance | jsonb | YES |  |
| 12 | inserted_at | timestamp with time zone | YES | now() |

### scenario_test_types

Columns: 5 | Constraints: 7 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO | (gen_random_uuid())::text |
| 2 | product_id | uuid | NO |  |
| 3 | scenario_id | text | YES |  |
| 4 | test_type_id | text | YES |  |
| 5 | created_at | timestamp with time zone | YES | now() |

### scenario_threats

Columns: 6 | Constraints: 7 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO | (gen_random_uuid())::text |
| 2 | product_id | uuid | NO |  |
| 3 | scenario_id | text | YES |  |
| 4 | threat_vector_id | text | YES |  |
| 5 | relevance_score | double precision | YES |  |
| 6 | created_at | timestamp with time zone | YES | now() |

### scenarios

Columns: 26 | Constraints: 7 | Indexes: 6

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO | (gen_random_uuid())::text |
| 2 | product_id | uuid | NO |  |
| 3 | tenant_id | text | NO |  |
| 4 | session_id | text | YES |  |
| 5 | persona_id | text | YES |  |
| 6 | title | text | NO |  |
| 7 | name | text | YES |  |
| 8 | scenario_id | text | YES |  |
| 9 | description | text | YES |  |
| 10 | context | text | YES |  |
| 11 | constraints | text | YES |  |
| 12 | expected_behaviors | text | YES |  |
| 13 | risk_vectors | ARRAY | YES | '{}'::text[] |
| 14 | harm_categories | ARRAY | YES | '{}'::text[] |
| 15 | stack_tags | ARRAY | YES | '{}'::text[] |
| 16 | tags | text | YES |  |
| 17 | relevance_score | double precision | YES |  |
| 18 | severity | text | YES |  |
| 19 | likelihood | text | YES |  |
| 20 | objectives | jsonb | YES | '[]'::jsonb |
| 21 | generated_prompt | jsonb | YES |  |
| 22 | status | text | YES | 'created'::text |
| 23 | metadata | jsonb | YES | '{}'::jsonb |
| 24 | raw_data | jsonb | YES |  |
| 25 | created_at | timestamp with time zone | YES | now() |
| 26 | updated_at | timestamp with time zone | YES | now() |

### sources

Columns: 7 | Constraints: 6 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('sources_id_seq'::regclass) |
| 2 | name | text | NO |  |
| 3 | source_type | text | NO |  |
| 4 | location | text | NO |  |
| 5 | config | jsonb | YES | '{}'::jsonb |
| 6 | is_active | boolean | YES | true |
| 7 | inserted_at | timestamp with time zone | YES | now() |

### sub_cohorts

Columns: 7 | Constraints: 5 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | cohort_id | uuid | YES |  |
| 3 | name | text | NO |  |
| 4 | description | text | YES |  |
| 5 | persona_type | text | YES | 'regular'::text |
| 6 | created_at | timestamp with time zone | YES | now() |
| 7 | updated_at | timestamp with time zone | YES | now() |

### sycophancy_events

Columns: 9 | Constraints: 3 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | conversation_id | text | YES |  |
| 3 | turn_id | text | YES |  |
| 4 | product_id | uuid | YES |  |
| 5 | ground_truth_id | text | YES |  |
| 6 | sycophancy_score | double precision | YES |  |
| 7 | event_data | jsonb | YES | '{}'::jsonb |
| 8 | created_at | timestamp with time zone | YES | now() |
| 9 | updated_at | timestamp with time zone | YES | now() |

### technographic_traits_catalog

Columns: 8 | Constraints: 8 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | bigint | NO | nextval('technographic_traits_catalog_id_seq'::regclass) |
| 2 | key | text | NO |  |
| 3 | label | text | NO |  |
| 4 | data_type | text | NO | 'text'::text |
| 5 | allowed_values | jsonb | YES |  |
| 6 | description | text | YES |  |
| 7 | persona_type | text | YES | 'regular'::text |
| 8 | applicable_sub_cohorts | jsonb | YES | '[]'::jsonb |

### tenants

Columns: 8 | Constraints: 7 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | tenant_name | text | NO |  |
| 3 | client_id | text | YES |  |
| 4 | industry | text | YES |  |
| 5 | status | text | NO | 'active'::text |
| 6 | created_at | timestamp with time zone | YES | now() |
| 7 | updated_at | timestamp with time zone | YES | now() |
| 8 | metadata | jsonb | YES | '{}'::jsonb |

### test_categories

Columns: 6 | Constraints: 9 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | category_id | integer | NO | nextval('test_categories_category_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | category_name | text | NO |  |
| 4 | description | text | YES |  |
| 5 | severity_level | text | NO |  |
| 6 | created_at | timestamp with time zone | YES | now() |

### test_executions

Columns: 11 | Constraints: 11 | Indexes: 7

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | execution_id | bigint | NO | nextval('test_executions_execution_id_seq'::regclass) |
| 2 | product_id | uuid | NO |  |
| 3 | model_id | bigint | YES |  |
| 4 | test_case_id | bigint | YES |  |
| 5 | executing_agent_id | bigint | YES |  |
| 6 | session_id | uuid | YES |  |
| 7 | execution_start | timestamp with time zone | YES | now() |
| 8 | execution_end | timestamp with time zone | YES |  |
| 9 | status | text | NO | 'pending'::text |
| 10 | error_message | text | YES |  |
| 11 | execution_context | jsonb | YES |  |

### test_sessions

Columns: 13 | Constraints: 10 | Indexes: 5

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | session_id | text | NO |  |
| 3 | product_id | uuid | NO |  |
| 4 | customer_id | text | NO |  |
| 5 | tenant_id | uuid | YES |  |
| 6 | session_name | text | NO |  |
| 7 | description | text | YES |  |
| 8 | customer_data | jsonb | YES |  |
| 9 | status | text | YES | 'active'::text |
| 10 | tags | ARRAY | YES | ARRAY[]::text[] |
| 11 | metadata | jsonb | YES | '{}'::jsonb |
| 12 | created_at | timestamp with time zone | YES | now() |
| 13 | updated_at | timestamp with time zone | YES | now() |

### test_sets

Columns: 10 | Constraints: 7 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | tenant_id | text | NO |  |
| 3 | created_by | text | NO |  |
| 4 | scenario | text | YES |  |
| 5 | persona | jsonb | YES |  |
| 6 | risks | ARRAY | NO |  |
| 7 | harms | ARRAY | NO |  |
| 8 | test_type | text | YES |  |
| 9 | status | text | YES | 'draft'::text |
| 10 | created_at | timestamp with time zone | YES | now() |

### test_turns

Columns: 9 | Constraints: 5 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | unit_id | uuid | YES |  |
| 3 | role | text | YES |  |
| 4 | content | text | YES |  |
| 5 | expected_behavior | text | YES |  |
| 6 | scoring | jsonb | YES |  |
| 7 | ord | integer | NO |  |
| 8 | source | text | YES | 'user'::text |
| 9 | embedding | USER-DEFINED | YES |  |

### test_types

Columns: 9 | Constraints: 8 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | product_id | uuid | NO |  |
| 3 | name | text | NO |  |
| 4 | description | text | YES |  |
| 5 | category | text | NO | 'general'::text |
| 6 | category_id | integer | YES |  |
| 7 | session_id | text | YES |  |
| 8 | embedding | USER-DEFINED | YES |  |
| 9 | created_at | timestamp with time zone | YES | now() |

### test_units

Columns: 4 | Constraints: 4 | Indexes: 1

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | test_set_id | uuid | YES |  |
| 3 | label | text | YES |  |
| 4 | ord | integer | NO |  |

### threat_examples

Columns: 18 | Constraints: 6 | Indexes: 2

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | product_id | uuid | NO |  |
| 3 | vector_id | text | YES |  |
| 4 | source | text | YES |  |
| 5 | raw_json | jsonb | YES |  |
| 6 | example_text | text | YES |  |
| 7 | persona_samples | jsonb | YES |  |
| 8 | scenario_text | text | YES |  |
| 9 | expected_system_response | text | YES |  |
| 10 | evidence_refs | jsonb | YES |  |
| 11 | severity | text | YES |  |
| 12 | detection_methods | ARRAY | YES |  |
| 13 | mitigation | ARRAY | YES |  |
| 14 | lifecycle_phase | text | YES |  |
| 15 | exploitation_complexity | text | YES |  |
| 16 | modalities | ARRAY | YES |  |
| 17 | embedding | USER-DEFINED | YES |  |
| 18 | created_at | timestamp with time zone | YES | now() |

### threat_vectors

Columns: 19 | Constraints: 7 | Indexes: 4

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | id_uuid | uuid | YES |  |
| 3 | product_id | uuid | NO |  |
| 4 | source | text | NO |  |
| 5 | name | text | YES |  |
| 6 | description | text | YES |  |
| 7 | category | text | YES |  |
| 8 | threat_categories | ARRAY | YES |  |
| 9 | harm_categories | ARRAY | YES |  |
| 10 | modalities | ARRAY | YES |  |
| 11 | tags | ARRAY | YES | ARRAY[]::text[] |
| 12 | framework_alignment | jsonb | YES |  |
| 13 | metadata | jsonb | YES |  |
| 14 | severity | text | YES |  |
| 15 | mitigation | text | YES |  |
| 16 | raw_json | jsonb | YES |  |
| 17 | embedding | USER-DEFINED | YES |  |
| 18 | created_at | timestamp with time zone | YES | now() |
| 19 | updated_at | timestamp with time zone | YES | now() |

### turn_embeddings

Columns: 7 | Constraints: 5 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | text | NO |  |
| 2 | turn_id | text | NO |  |
| 3 | product_id | uuid | YES |  |
| 4 | embedding | ARRAY | NO |  |
| 5 | embedding_model | text | YES |  |
| 6 | created_at | timestamp with time zone | YES | now() |
| 7 | updated_at | timestamp with time zone | YES | now() |

### use_cases

Columns: 7 | Constraints: 7 | Indexes: 3

| # | Column | Type | Nullable | Default |
|---:|---|---|:---:|---|
| 1 | id | uuid | NO | gen_random_uuid() |
| 2 | product_id | uuid | NO |  |
| 3 | slug | text | YES |  |
| 4 | name | text | NO |  |
| 5 | description | text | YES |  |
| 6 | created_at | timestamp with time zone | YES | now() |
| 7 | updated_at | timestamp with time zone | YES | now() |

## Views

- vw_active_alerts
- vw_agent_interaction_lineage
- vw_agent_workflow_summary
- vw_latest_model_assessments
- vw_model_safety_summary
- vw_persona_with_traits

## Notes

This file is generated by scripts/snapshot_live_schema.py from live Supabase metadata.
Use LIVE_SCHEMA_SNAPSHOT.json for machine-readable full details.
