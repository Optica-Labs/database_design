-- ============================================================================
-- SUPABASE SETUP - Part 1: Extensions and Core Products
-- ============================================================================
-- Run this first in Supabase SQL Editor
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create nexus_alpha schema
CREATE SCHEMA IF NOT EXISTS nexus_alpha;

-- ============================================================================
-- PRODUCT LAYER
-- ============================================================================

CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_code TEXT NOT NULL UNIQUE CHECK (product_code IN ('ai-range', 'nexus')),
    product_name TEXT NOT NULL,
    description TEXT,
    features JSONB DEFAULT '{}'::jsonb,
    pricing_tier TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'beta', 'deprecated', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_products_code_status ON products(product_code, status);

-- Insert default products
INSERT INTO products (product_code, product_name, description, status) VALUES
('ai-range', 'AI Range', 'Comprehensive AI testing and safety assessment platform', 'active'),
('nexus', 'Nexus', 'Advanced AI persona testing and risk analysis system', 'active')
ON CONFLICT (product_code) DO NOTHING;

-- ============================================================================
-- TENANTS & SUBSCRIPTIONS
-- ============================================================================

CREATE TABLE IF NOT EXISTS tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_name TEXT NOT NULL UNIQUE,
    client_id TEXT UNIQUE,
    industry TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS client_product_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    subscription_tier TEXT,
    subscription_status TEXT NOT NULL DEFAULT 'active' CHECK (subscription_status IN ('active', 'trial', 'suspended', 'expired', 'cancelled')),
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    usage_limits JSONB DEFAULT '{}'::jsonb,
    features_enabled JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb,
    UNIQUE(tenant_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_client_subscriptions_tenant ON client_product_subscriptions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_client_subscriptions_product ON client_product_subscriptions(product_id);
CREATE INDEX IF NOT EXISTS idx_client_subscriptions_status ON client_product_subscriptions(subscription_status);
