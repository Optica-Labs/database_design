#!/usr/bin/env python3
"""
Setup default products and tenant for migration.
Creates foundation records in TARGET database.
"""
import requests
import os
from dotenv import load_dotenv

load_dotenv()

TARGET_URL = os.getenv('TARGET_SUPABASE_API_URL')
TARGET_KEY = os.getenv('TARGET_SUPABASE_SERVICE_KEY')

headers = {
    'apikey': TARGET_KEY,
    'Authorization': f'Bearer {TARGET_KEY}',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
}

# Default product IDs for migration
AI_RANGE_PRODUCT_ID = '11111111-1111-1111-1111-111111111111'
NEXUS_PRODUCT_ID = '22222222-2222-2222-2222-222222222222'
DEFAULT_TENANT_ID = '99999999-9999-9999-9999-999999999999'

print("\n" + "="*60)
print("MIGRATION DEFAULTS SETUP")
print("="*60 + "\n")

# Check and insert products
print("Setting up products...")
products = [
    {
        'id': AI_RANGE_PRODUCT_ID,
        'product_code': 'ai-range',
        'product_name': 'AI Range',
        'description': 'Migrated from legacy database',
        'status': 'active'
    },
    {
        'id': NEXUS_PRODUCT_ID,
        'product_code': 'nexus',
        'product_name': 'Nexus',
        'description': 'Migrated from legacy database',
        'status': 'active'
    }
]

for product in products:
    response = requests.post(
        f'{TARGET_URL}/rest/v1/products',
        headers=headers,
        json=product
    )
    if response.status_code in [200, 201]:
        print(f"✅ Product {product['product_code']} created")
    elif response.status_code == 409:
        print(f"ℹ️  Product {product['product_code']} already exists")
    else:
        print(f"❌ Error creating product {product['product_code']}: {response.status_code}")
        print(f"   {response.text}")

# Check and insert default tenant
print("\nSetting up default tenant...")
tenant = {
    'id': DEFAULT_TENANT_ID,
    'tenant_name': 'legacy-migration-tenant',
    'status': 'active',
    'metadata': {'source': 'legacy_migration', 'migration_date': '2026-02-23'}
}

response = requests.post(
    f'{TARGET_URL}/rest/v1/tenants',
    headers=headers,
    json=tenant
)

if response.status_code in [200, 201]:
    print("✅ Default tenant created")
elif response.status_code == 409:
    print("ℹ️  Default tenant already exists")
else:
    print(f"❌ Error creating tenant: {response.status_code}")
    print(f"   {response.text}")

print("\n" + "="*60)
print("MIGRATION DEFAULTS READY")
print("="*60)
print(f"AI Range Product ID: {AI_RANGE_PRODUCT_ID}")
print(f"Nexus Product ID: {NEXUS_PRODUCT_ID}")
print(f"Default Tenant ID: {DEFAULT_TENANT_ID}")
print("="*60 + "\n")
