-- ============================================================================
-- 99 -- VERIFY
-- ============================================================================
-- Post-create sanity checks.  Raises an exception (aborting the transaction)
-- if the canonical object counts are not met.  Run last.
-- ============================================================================

SET search_path = public;

DO $$
DECLARE
    table_count integer;
    view_count integer;
    product_count integer;
BEGIN
    SELECT count(*) INTO table_count
    FROM information_schema.tables
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

    SELECT count(*) INTO view_count
    FROM information_schema.views
    WHERE table_schema = 'public';

    SELECT count(*) INTO product_count FROM products;

    IF table_count < 94 THEN
        RAISE EXCEPTION 'Verify failed: expected >= 94 base tables, found %', table_count;
    END IF;

    IF view_count < 6 THEN
        RAISE EXCEPTION 'Verify failed: expected >= 6 views, found %', view_count;
    END IF;

    IF product_count < 2 THEN
        RAISE EXCEPTION 'Verify failed: expected >= 2 products, found %', product_count;
    END IF;

    RAISE NOTICE 'Verify OK: % tables, % views, % products.',
        table_count, view_count, product_count;
END $$;
