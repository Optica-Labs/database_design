#!/usr/bin/env python3
"""
Supabase API-Based Data Migration
Migrates data using REST API (HTTPS) - works on IPv4 networks
"""

import os
import sys
import requests
import json
from dotenv import load_dotenv
from datetime import datetime
from data_transformations import transform_table_data

load_dotenv()

class SupabaseAPIMigrator:
    """Migrates data between Supabase projects using REST API"""
    
    def __init__(self):
        # Source configuration
        self.source_url = os.getenv('SOURCE_SUPABASE_API_URL')  # e.g., https://hxejcqyxkvqujbzjcpmk.supabase.co
        self.source_key = os.getenv('SOURCE_SUPABASE_SERVICE_KEY')
        
        # Target configuration
        self.target_url = os.getenv('TARGET_SUPABASE_API_URL')  # e.g., https://aayinvrvtumndpubwtui.supabase.co
        self.target_key = os.getenv('TARGET_SUPABASE_SERVICE_KEY')
        
        self.report = {
            'start_time': datetime.now().isoformat(),
            'tables_migrated': [],
            'errors': [],
            'warnings': []
        }
        
    def log(self, message, level='INFO'):
        """Log migration progress"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"[{timestamp}] {level}: {message}")
    
    def validate_config(self):
        """Validate configuration"""
        if not self.source_url or not self.source_key:
            self.log("Missing SOURCE configuration", 'ERROR')
            self.log("Need: SOURCE_SUPABASE_API_URL and SOURCE_SUPABASE_SERVICE_KEY", 'ERROR')
            return False
        
        if not self.target_url or not self.target_key:
            self.log("Missing TARGET configuration", 'ERROR')
            self.log("Need: TARGET_SUPABASE_API_URL and TARGET_SUPABASE_SERVICE_KEY", 'ERROR')
            return False
        
        return True
    
    def get_tables(self, base_url, api_key):
        """Get list of all tables from a Supabase project in migration order"""
        headers = {
            'apikey': api_key,
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        }
        
        # Tables in proper dependency order for migration
        # Stage 1: Foundation (already done - skip)
        # Stage 2: Use Cases and Cohorts
        # Stage 3: Personas and Traits
        # Stage 4: Context and Risk
        # Stage 5: Threats
        # Stage 6: Testing
        # Stage 7: Sessions and Responses
        tables = [
            # Stage 2: Foundation tables
            'use_cases',
            'cohorts',
            'sub_cohorts',
            
            # Stage 3: Personas and traits
            'personas',
            'persona_demographics',
            'persona_behavioral_traits',
            'persona_psychographic_traits',
            'persona_technographic_traits',
            'persona_linguistic_traits',
            
            # Stage 4: Context and risk
            'context_profiles',
            'risk_assessments',
            
            # Stage 5: Threats and risks
            'threat_vectors',
            'threat_examples',
            'risks',
            'harms',
            
            # Stage 6: Testing infrastructure
            'test_types',
            'scenarios',
            'scenario_intents',
            'scenario_threats',
            'scenario_scores',
            'scenario_test_types',
            
            # Stage 7: Sessions and responses
            'test_sessions',
            'prompt_generator_responses',
        ]
        
        return tables
    
    def fetch_table_data(self, base_url, api_key, table_name, limit=1000, offset=0):
        """Fetch data from a table via API"""
        url = f"{base_url}/rest/v1/{table_name}?limit={limit}&offset={offset}"
        headers = {
            'apikey': api_key,
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json',
            'Prefer': 'return=representation'
        }
        
        try:
            response = requests.get(url, headers=headers, timeout=30)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            self.log(f"Error fetching {table_name}: {e}", 'ERROR')
            return None
    
    def insert_table_data(self, base_url, api_key, table_name, data):
        """Insert or update data into a table via API (UPSERT)"""
        if not data:
            return True
        
        # Composite key tables (junction tables) use different conflict resolution
        composite_key_tables = [
            'persona_demographics',
            'persona_behavioral_traits',
            'persona_psychographic_traits',
            'persona_technographic_traits',
            'persona_linguistic_traits',
            'scenario_intents',
            'scenario_threats',
            'scenario_scores',
            'scenario_test_types'
        ]
        
        # Use appropriate on_conflict parameter
        if table_name in composite_key_tables:
            # For composite key tables, specify both columns
            if table_name.startswith('persona_'):
                conflict_cols = 'persona_id,trait_id'
            elif table_name.startswith('scenario_'):
                # Different composite keys for scenario junction tables
                if table_name == 'scenario_test_types':
                    conflict_cols = 'scenario_id,test_type_id'
                elif table_name == 'scenario_intents':
                    conflict_cols = 'scenario_id,intent_id'
                elif table_name == 'scenario_threats':
                    conflict_cols = 'scenario_id,threat_vector_id'
                elif table_name == 'scenario_scores':
                    conflict_cols = 'scenario_id,score_type'
                else:
                    conflict_cols = 'id'
            else:
                conflict_cols = 'id'
            url = f"{base_url}/rest/v1/{table_name}?on_conflict={conflict_cols}"
        else:
            url = f"{base_url}/rest/v1/{table_name}?on_conflict=id"
        
        headers = {
            'apikey': api_key,
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json',
            'Prefer': 'resolution=merge-duplicates'
        }
        
        # Insert in batches of 100 (or individually for debugging)
        batch_size = 100
        for i in range(0, len(data), batch_size):
            batch = data[i:i+batch_size]
            try:
                response = requests.post(url, headers=headers, json=batch, timeout=60)
                response.raise_for_status()
                self.log(f"  Upserted batch {i//batch_size + 1} ({len(batch)} rows)", 'INFO')
            except requests.exceptions.RequestException as e:
                # If batch fails, try inserting one by one
                if batch_size > 1 and len(batch) > 1:
                    self.log(f"Batch failed, trying individual inserts for {table_name}...", 'INFO')
                    success_count = 0
                    for idx, row in enumerate(batch):
                        try:
                            ind_response = requests.post(url, headers=headers, json=[row], timeout=60)
                            ind_response.raise_for_status()
                            success_count += 1
                        except requests.exceptions.RequestException as ind_e:
                            self.log(f"  Row {i+idx} failed: {str(ind_e)[:200]}", 'WARNING')
                            if hasattr(ind_e, 'response') and ind_e.response:
                                self.log(f"  Response: {ind_e.response.text[:500]}", 'WARNING')
                    self.log(f"  Individually inserted {success_count}/{len(batch)} rows", 'INFO')
                    if success_count == 0:
                        return False
                else:
                    self.log(f"Error upserting into {table_name}: {e}", 'ERROR')
                    if hasattr(e, 'response') and e.response:
                        self.log(f"Response: {e.response.text[:1000]}", 'ERROR')
                    return False
        
        return True
    
    def migrate_table(self, table_name):
        """Migrate a single table with transformation support"""
        try:
            self.log(f"Migrating {table_name}...", 'INFO')
            
            # Fetch all data from source (paginated)
            all_data = []
            offset = 0
            limit = 1000
            
            while True:
                data = self.fetch_table_data(self.source_url, self.source_key, table_name, limit, offset)
                
                if data is None:
                    self.log(f"Failed to fetch {table_name}", 'WARNING')
                    break
                
                if not data:
                    break
                
                all_data.extend(data)
                self.log(f"  Fetched {len(data)} rows (total: {len(all_data)})", 'INFO')
                
                if len(data) < limit:
                    break
                
                offset += limit
            
            if not all_data:
                self.log(f"No data to migrate for {table_name}", 'INFO')
                return 0
            
            # Transform data
            try:
                transformed_data = transform_table_data(table_name, all_data)
                if len(transformed_data) != len(all_data):
                    self.log(f"  ⚠️  Transformation changed row count: {len(all_data)} → {len(transformed_data)}", 'WARNING')
                else:
                    self.log(f"  ✓ Transformed {len(transformed_data)} rows", 'INFO')
            except Exception as e:
                self.log(f"  ❌ Error transforming {table_name}: {e}", 'ERROR')
                return 0
            
            # Insert into target
            success = self.insert_table_data(self.target_url, self.target_key, table_name, transformed_data)
            
            if success:
                self.log(f"✅ Migrated {len(transformed_data)} rows to {table_name}", 'SUCCESS')
                return len(transformed_data)
            else:
                self.log(f"❌ Failed to migrate {table_name}", 'ERROR')
                return 0
                
        except Exception as e:
            self.log(f"Error migrating {table_name}: {e}", 'ERROR')
            self.report['errors'].append(f"{table_name}: {str(e)}")
            return 0
    
    def migrate(self):
        """Execute full migration"""
        try:
            self.log("=" * 70, 'INFO')
            self.log("SUPABASE API MIGRATION STARTED", 'INFO')
            self.log("=" * 70, 'INFO')
            
            if not self.validate_config():
                return False
            
            # Get tables
            tables = self.get_tables(self.source_url, self.source_key)
            self.log(f"Found {len(tables)} tables to migrate", 'INFO')
            
            # Migrate each table
            self.log("\n" + "=" * 70, 'INFO')
            self.log("MIGRATING DATA", 'INFO')
            self.log("=" * 70, 'INFO')
            
            total_rows = 0
            for table in tables:
                rows = self.migrate_table(table)
                if rows > 0:
                    self.report['tables_migrated'].append({
                        'table': table,
                        'rows': rows
                    })
                    total_rows += rows
                print()  # Blank line between tables
            
            # Summary
            self.log("=" * 70, 'INFO')
            self.log("MIGRATION COMPLETE", 'INFO')
            self.log("=" * 70, 'INFO')
            self.log(f"Tables migrated: {len(self.report['tables_migrated'])}", 'INFO')
            self.log(f"Total rows migrated: {total_rows}", 'INFO')
            
            if self.report['errors']:
                self.log(f"Errors: {len(self.report['errors'])}", 'ERROR')
            
            self.report['end_time'] = datetime.now().isoformat()
            self.report['total_rows'] = total_rows
            
            return True
            
        except Exception as e:
            self.log(f"Migration failed: {e}", 'ERROR')
            return False
    
    def save_report(self, filepath='migration_api_report.json'):
        """Save migration report"""
        try:
            with open(filepath, 'w') as f:
                json.dump(self.report, f, indent=2)
            self.log(f"Report saved to {filepath}", 'INFO')
        except Exception as e:
            self.log(f"Could not save report: {e}", 'ERROR')


def main():
    """Main entry point"""
    
    print("\n🔧 Supabase API Migration Tool")
    print("=" * 70)
    print("This tool uses HTTPS REST API (works on IPv4 networks)\n")
    
    # Create migrator
    migrator = SupabaseAPIMigrator()
    
    # Execute migration
    success = migrator.migrate()
    
    # Save report
    migrator.save_report()
    
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
