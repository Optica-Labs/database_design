-- GENERATED FILE -- DO NOT EDIT BY HAND.
-- Regenerate: python3 scripts/generate_canonical_schema.py
-- Source of truth: docs/verification/LIVE_SCHEMA_DDL_COMPACT.sql
-- Naming: legacy prefixes transitioned to peregrine_* (see sql/legacy/README.md).

SET search_path = public;

CREATE OR REPLACE VIEW public.vw_active_alerts AS
SELECT sa.alert_id,
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
    (EXTRACT(epoch FROM (now() - sa.detected_at)) / (3600)::numeric) AS hours_open
   FROM ((safety_alerts sa
     JOIN client_models cm ON ((sa.model_id = cm.model_id)))
     LEFT JOIN safety_assessments ass ON ((sa.assessment_id = ass.assessment_id)))
  WHERE (sa.status = ANY (ARRAY['open'::text, 'investigating'::text]));;

CREATE OR REPLACE VIEW public.vw_agent_interaction_lineage AS
SELECT gr.generation_run_id,
    aif.flow_sequence,
    source_agent.agent_name AS source_agent,
    target_agent.agent_name AS target_agent,
    aif.flow_type,
    aif.size_bytes,
    aif.transfer_timestamp,
    source_ai.interaction_sequence AS source_sequence,
    target_ai.interaction_sequence AS target_sequence
   FROM (((((agent_interaction_flow aif
     JOIN peregrine_generation_runs gr ON ((aif.generation_run_id = gr.id)))
     JOIN agent_interactions source_ai ON ((aif.source_agent_interaction_id = source_ai.id)))
     JOIN agent_interactions target_ai ON ((aif.target_agent_interaction_id = target_ai.id)))
     JOIN ai_agents source_agent ON ((source_ai.ai_agent_id = source_agent.agent_id)))
     JOIN ai_agents target_agent ON ((target_ai.ai_agent_id = target_agent.agent_id)))
  ORDER BY gr.id DESC, aif.flow_sequence;;

CREATE OR REPLACE VIEW public.vw_agent_workflow_summary AS
SELECT gr.generation_run_id,
    gr.id AS run_id,
    aa.agent_name,
    aa.agent_type,
    ai.interaction_sequence,
    ai.status,
    ai.started_at,
    ai.completed_at,
    ai.execution_time_ms,
    ai.error_message,
    count(DISTINCT ail.id) AS libraries_accessed,
    count(DISTINCT aio_in.id) AS inputs_provided,
    count(DISTINCT aio_out.id) AS outputs_generated,
    gr.created_at AS run_created_at
   FROM (((((agent_interactions ai
     JOIN peregrine_generation_runs gr ON ((ai.generation_run_id = gr.id)))
     JOIN ai_agents aa ON ((ai.ai_agent_id = aa.agent_id)))
     LEFT JOIN agent_interaction_libraries ail ON ((ai.id = ail.agent_interaction_id)))
     LEFT JOIN agent_interaction_inputs aio_in ON ((ai.id = aio_in.agent_interaction_id)))
     LEFT JOIN agent_interaction_outputs aio_out ON ((ai.id = aio_out.agent_interaction_id)))
  GROUP BY gr.generation_run_id, gr.id, aa.agent_name, aa.agent_type, ai.interaction_sequence, ai.status, ai.started_at, ai.completed_at, ai.execution_time_ms, ai.error_message, gr.created_at
  ORDER BY gr.id DESC, ai.interaction_sequence;;

CREATE OR REPLACE VIEW public.vw_latest_model_assessments AS
SELECT cm.model_id,
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
   FROM ((((client_models cm
     LEFT JOIN test_executions te ON ((cm.model_id = te.model_id)))
     LEFT JOIN model_outputs mo ON ((te.execution_id = mo.execution_id)))
     LEFT JOIN safety_assessments sa ON ((mo.output_id = sa.output_id)))
     LEFT JOIN adversarial_test_cases atc ON ((te.test_case_id = atc.test_case_id)))
  WHERE (sa.assessed_at = ( SELECT max(sa2.assessed_at) AS max
           FROM ((test_executions te2
             JOIN model_outputs mo2 ON ((te2.execution_id = mo2.execution_id)))
             JOIN safety_assessments sa2 ON ((mo2.output_id = sa2.output_id)))
          WHERE (te2.model_id = cm.model_id)));;

CREATE OR REPLACE VIEW public.vw_model_safety_summary AS
SELECT cm.model_id,
    cm.client_id,
    cm.model_name,
    cm.model_version,
    cm.status,
    count(DISTINCT te.execution_id) AS total_tests,
    count(DISTINCT
        CASE
            WHEN (sa.is_safe = true) THEN te.execution_id
            ELSE NULL::bigint
        END) AS safe_tests,
    count(DISTINCT
        CASE
            WHEN (sa.is_safe = false) THEN te.execution_id
            ELSE NULL::bigint
        END) AS unsafe_tests,
    count(DISTINCT
        CASE
            WHEN (sa.risk_level = 'critical'::text) THEN te.execution_id
            ELSE NULL::bigint
        END) AS critical_risks,
    count(DISTINCT
        CASE
            WHEN (sa.risk_level = 'high'::text) THEN te.execution_id
            ELSE NULL::bigint
        END) AS high_risks,
    avg(sa.safety_score) AS avg_safety_score,
    max(te.execution_start) AS last_test_date
   FROM (((client_models cm
     LEFT JOIN test_executions te ON ((cm.model_id = te.model_id)))
     LEFT JOIN model_outputs mo ON ((te.execution_id = mo.execution_id)))
     LEFT JOIN safety_assessments sa ON ((mo.output_id = sa.output_id)))
  GROUP BY cm.model_id, cm.client_id, cm.model_name, cm.model_version, cm.status;;

CREATE OR REPLACE VIEW public.vw_persona_with_traits AS
SELECT p.id,
    p.display_name,
    p.name,
    p.persona_type,
    p.archetype,
    p.status,
    p.use_case_id,
    p.cohort_id,
    p.sub_cohort_id,
    jsonb_object_agg(DISTINCT dtc.key, jsonb_build_object('raw_value', pd.raw_value, 'value', pd.value)) FILTER (WHERE (pd.persona_id IS NOT NULL)) AS demographics,
    jsonb_object_agg(DISTINCT btc.key, jsonb_build_object('raw_value', pbt.raw_value, 'value', pbt.value)) FILTER (WHERE (pbt.persona_id IS NOT NULL)) AS behavioral_traits,
    jsonb_object_agg(DISTINCT ptc.key, jsonb_build_object('raw_value', ppt.raw_value, 'value', ppt.value)) FILTER (WHERE (ppt.persona_id IS NOT NULL)) AS psychographic_traits,
    jsonb_object_agg(DISTINCT ttc.key, jsonb_build_object('raw_value', ptt.raw_value, 'value', ptt.value)) FILTER (WHERE (ptt.persona_id IS NOT NULL)) AS technographic_traits,
    jsonb_object_agg(DISTINCT ltc.key, jsonb_build_object('raw_value', plt.raw_value, 'value', plt.value)) FILTER (WHERE (plt.persona_id IS NOT NULL)) AS linguistic_traits
   FROM ((((((((((personas p
     LEFT JOIN persona_demographics pd ON ((p.id = pd.persona_id)))
     LEFT JOIN demographic_traits_catalog dtc ON ((pd.trait_id = dtc.id)))
     LEFT JOIN persona_behavioral_traits pbt ON ((p.id = pbt.persona_id)))
     LEFT JOIN behavioral_traits_catalog btc ON ((pbt.trait_id = btc.id)))
     LEFT JOIN persona_psychographic_traits ppt ON ((p.id = ppt.persona_id)))
     LEFT JOIN psychographic_traits_catalog ptc ON ((ppt.trait_id = ptc.id)))
     LEFT JOIN persona_technographic_traits ptt ON ((p.id = ptt.persona_id)))
     LEFT JOIN technographic_traits_catalog ttc ON ((ptt.trait_id = ttc.id)))
     LEFT JOIN persona_linguistic_traits plt ON ((p.id = plt.persona_id)))
     LEFT JOIN linguistic_traits_catalog ltc ON ((plt.trait_id = ltc.id)))
  GROUP BY p.id;;
