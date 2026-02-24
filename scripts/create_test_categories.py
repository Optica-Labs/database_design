#!/usr/bin/env python3
"""Create test_categories if they don't exist"""
import os
import requests
from dotenv import load_dotenv

load_dotenv()

target_url = os.getenv('TARGET_SUPABASE_API_URL')
target_key = os.getenv('TARGET_SUPABASE_SERVICE_KEY')
AI_RANGE_PRODUCT_ID = '29e90830-dab0-422e-9c24-9ba2ba6bcad5'

# Create default categories with product_id
print('Creating default test categories...')
categories = [
    {'category_id': 1, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'general', 'description': 'General testing', 'severity_level': 'low'},
    {'category_id': 2, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'security', 'description': 'Security testing', 'severity_level': 'high'},
    {'category_id': 3, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'performance', 'description': 'Performance testing', 'severity_level': 'medium'},
    {'category_id': 4, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'accuracy', 'description': 'Accuracy testing', 'severity_level': 'medium'},
    {'category_id': 5, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'safety', 'description': 'Safety testing', 'severity_level': 'critical'},
    {'category_id': 6, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'bias', 'description': 'Bias testing', 'severity_level': 'high'},
    {'category_id': 7, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'toxicity', 'description': 'Toxicity testing', 'severity_level': 'high'},
    {'category_id': 8, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'jailbreak', 'description': 'Jailbreak testing', 'severity_level': 'critical'},
    {'category_id': 9, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'prompt_injection', 'description': 'Prompt injection testing', 'severity_level': 'high'},
    {'category_id': 10, 'product_id': AI_RANGE_PRODUCT_ID, 'category_name': 'other', 'description': 'Other testing', 'severity_level': 'low'}
]

url = f'{target_url}/rest/v1/test_categories?on_conflict=category_id'
headers = {
    'apikey': target_key,
    'Authorization': f'Bearer {target_key}',
    'Content-Type': 'application/json',
    'Prefer': 'resolution=merge-duplicates'
}

response = requests.post(url, headers=headers, json=categories, timeout=60)
print(f'Status: {response.status_code}')
if response.status_code in [200, 201]:
    print('✅ Test categories created successfully')
else:
    print(f'Error: {response.text[:1000]}')
