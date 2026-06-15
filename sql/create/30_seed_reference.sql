-- ============================================================================
-- 30 -- SEED REFERENCE DATA
-- ============================================================================
-- Minimal reference data required for a functioning database: the product
-- catalog rows that product-scoped tables reference via product_id.
--
-- Idempotent: re-running leaves existing rows untouched (ON CONFLICT DO NOTHING
-- on the products.product_code unique key).
--
-- Demo/sample tenants and example rows are intentionally NOT seeded here; see
-- sql/sample_data/sample_data.sql for an optional demonstration dataset.
-- ============================================================================

SET search_path = public;

INSERT INTO products (product_code, product_name, description, features, pricing_tier, status)
VALUES
    (
        'ai-range',
        'AI Range',
        'Comprehensive AI testing and safety assessment platform with adversarial '
        'testing, compliance checks, and risk evaluation',
        '{"adversarial_testing": true, "safety_evaluation": true, "compliance_reports": true, "custom_scenarios": true, "api_integration": true}'::jsonb,
        'enterprise',
        'active'
    ),
    (
        'peregrine',
        'Peregrine',
        'Advanced AI persona testing and risk analysis system with scenario '
        'generation and behavioral analysis',
        '{"persona_generation": true, "risk_analysis": true, "scenario_testing": true, "behavioral_analysis": true, "vector_search": true}'::jsonb,
        'premium',
        'active'
    )
ON CONFLICT (product_code) DO NOTHING;
