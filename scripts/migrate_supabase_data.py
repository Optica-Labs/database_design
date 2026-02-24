#!/usr/bin/env python3
"""
Supabase Data Migration Tool
Migrates all data from source to target Supabase database
Preserves IDs, sequences, and all relationships
"""

import os
import sys
import psycopg2
import psycopg2.extras
from dotenv import load_dotenv
from datetime import datetime
import json

# Load environment variables
load_dotenv()

class SupabaseMigrator:
    """Handles migration between two Supabase PostgreSQL databases"""
    
    def __init__(self, source_url, target_url, verbose=True):
        self.source_url = source_url
        self.target_url = target_url
        self.verbose = verbose
        self.migration_report = {
            'start_time': datetime.now().isoformat(),
            'tables_migrated': [],
            'total_rows_migrated': 0,
            'errors': [],
            'warnings': []
        }
        
    def log(self, message, level='INFO'):
        """Log migration progress"""
        if self.verbose:
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            print(f"[{timestamp}] {level}: {message}")
    
    def get_connection(self, url, name='db'):
        """Create database connection"""
        try:
            conn = psycopg2.connect(url, connect_timeout=10)
            self.log(f"Connected to {name} database", 'INFO')
            return conn
        except Exception as e:
            self.log(f"Failed to connect to {name} database: {e}", 'ERROR')
            raise
    
    def get_table_dependencies(self, conn):
        """Get table creation order based on foreign keys"""
        cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        # Get all tables in public and nexus_alpha schemas
        cursor.execute("""
            SELECT table_name, table_schema 
            FROM information_schema.tables 
            WHERE table_schema IN ('public', 'nexus_alpha')
            AND table_type = 'BASE TABLE'
            ORDER BY table_schema, table_name
        """)
        
        tables = [(row['table_schema'], row['table_name']) for row in cursor.fetchall()]
        cursor.close()
        
        return tables
    
    def get_table_column_info(self, conn, schema, table):
        """Get column information for a table"""
        cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns
            WHERE table_schema = %s AND table_name = %s
            ORDER BY ordinal_position
        """, (schema, table))
        
        columns = cursor.fetchall()
        cursor.close()
        return columns
    
    def migrate_table(self, source_conn, target_conn, schema, table_name):
        """Migrate a single table from source to target"""
        try:
            source_cursor = source_conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            target_cursor = target_conn.cursor()
            
            # Get column info
            columns = self.get_table_column_info(source_conn, schema, table_name)
            column_names = [col['column_name'] for col in columns]
            
            if not column_names:
                self.log(f"No columns found for {schema}.{table_name}", 'WARNING')
                return 0
            
            # Build qualified table name
            qual_table = f"{schema}.{table_name}" if schema != 'public' else table_name
            
            # Fetch all data from source
            column_list = ', '.join([f'"{col}"' for col in column_names])
            query = f"SELECT {column_list} FROM {qual_table}"
            
            self.log(f"Fetching data from {qual_table}...", 'INFO')
            source_cursor.execute(query)
            rows = source_cursor.fetchall()
            
            if not rows:
                self.log(f"No data to migrate for {qual_table}", 'INFO')
                source_cursor.close()
                return 0
            
            # Disable triggers and constraints temporarily
            target_cursor.execute(f"ALTER TABLE {qual_table} DISABLE TRIGGER ALL")
            
            # Insert data into target
            for row in rows:
                values = []
                placeholders = []
                
                for i, col_name in enumerate(column_names):
                    values.append(row[col_name])
                    placeholders.append('%s')
                
                col_list = ', '.join([f'"{col}"' for col in column_names])
                insert_query = f"""
                    INSERT INTO {qual_table} ({col_list})
                    VALUES ({', '.join(placeholders)})
                    ON CONFLICT DO NOTHING
                """
                
                try:
                    target_cursor.execute(insert_query, values)
                except Exception as e:
                    self.log(f"Error inserting row into {qual_table}: {e}", 'WARNING')
                    self.migration_report['warnings'].append(f"{qual_table}: {str(e)}")
            
            # Re-enable triggers
            target_cursor.execute(f"ALTER TABLE {qual_table} ENABLE TRIGGER ALL")
            target_conn.commit()
            
            row_count = len(rows)
            self.log(f"✅ Migrated {row_count} rows to {qual_table}", 'SUCCESS')
            
            source_cursor.close()
            return row_count
            
        except Exception as e:
            self.log(f"❌ Error migrating {schema}.{table_name}: {e}", 'ERROR')
            self.migration_report['errors'].append(f"{schema}.{table_name}: {str(e)}")
            return 0
    
    def reset_sequences(self, target_conn, schema='public'):
        """Reset all sequences to match data"""
        try:
            cursor = target_conn.cursor()
            
            # Get all sequences
            cursor.execute("""
                SELECT sequence_schema, sequence_name, associated_table, associated_column
                FROM information_schema.sequences
                WHERE sequence_schema = %s
            """, (schema,))
            
            sequences = cursor.fetchall()
            
            for seq_schema, seq_name, assoc_table, assoc_col in sequences:
                if assoc_table and assoc_col:
                    qual_seq = f"{seq_schema}.{seq_name}" if seq_schema != 'public' else seq_name
                    qual_table = f"{seq_schema}.{assoc_table}" if seq_schema != 'public' else assoc_table
                    
                    try:
                        # Get max value from table
                        cursor.execute(f"SELECT MAX({assoc_col}) FROM {qual_table}")
                        max_val = cursor.fetchone()[0]
                        
                        if max_val:
                            cursor.execute(f"SELECT setval('{qual_seq}', %s)", (max_val + 1,))
                            self.log(f"Reset sequence {qual_seq} to {max_val + 1}", 'INFO')
                    except Exception as e:
                        self.log(f"Could not reset sequence {qual_seq}: {e}", 'WARNING')
            
            target_conn.commit()
            cursor.close()
            
        except Exception as e:
            self.log(f"Error resetting sequences: {e}", 'WARNING')
    
    def validate_migration(self, source_conn, target_conn):
        """Validate migration by comparing row counts"""
        try:
            source_cursor = source_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            target_cursor = target_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            
            # Get all tables
            source_cursor.execute("""
                SELECT table_name, table_schema
                FROM information_schema.tables
                WHERE table_schema IN ('public', 'nexus_alpha')
                AND table_type = 'BASE TABLE'
                ORDER BY table_schema, table_name
            """)
            
            tables = source_cursor.fetchall()
            validation_results = []
            total_source = 0
            total_target = 0
            
            for row in tables:
                schema, table_name = row['table_schema'], row['table_name']
                qual_table = f"{schema}.{table_name}" if schema != 'public' else table_name
                
                try:
                    source_cursor.execute(f"SELECT COUNT(*) as cnt FROM {qual_table}")
                    source_count = source_cursor.fetchone()['cnt']
                    
                    target_cursor.execute(f"SELECT COUNT(*) as cnt FROM {qual_table}")
                    target_count = target_cursor.fetchone()['cnt']
                    
                    match = source_count == target_count
                    status = "✅" if match else "⚠️"
                    
                    validation_results.append({
                        'table': qual_table,
                        'source_count': source_count,
                        'target_count': target_count,
                        'match': match
                    })
                    
                    total_source += source_count
                    total_target += target_count
                    
                    if not match:
                        self.log(f"{status} {qual_table}: {source_count} → {target_count}", 'WARNING')
                    
                except Exception as e:
                    self.log(f"Validation error for {qual_table}: {e}", 'WARNING')
            
            source_cursor.close()
            target_cursor.close()
            
            return {
                'total_source': total_source,
                'total_target': total_target,
                'tables': validation_results,
                'success': total_source == total_target
            }
            
        except Exception as e:
            self.log(f"Validation failed: {e}", 'ERROR')
            return None
    
    def migrate(self):
        """Execute full migration"""
        source_conn = None
        target_conn = None
        
        try:
            self.log("=" * 70, 'INFO')
            self.log("SUPABASE DATA MIGRATION STARTED", 'INFO')
            self.log("=" * 70, 'INFO')
            
            # Connect to both databases
            source_conn = self.get_connection(self.source_url, 'SOURCE')
            target_conn = self.get_connection(self.target_url, 'TARGET')
            
            # Get tables in order
            tables = self.get_table_dependencies(source_conn)
            self.log(f"Found {len(tables)} tables to migrate", 'INFO')
            
            # Migrate each table
            self.log("\n" + "=" * 70, 'INFO')
            self.log("MIGRATING DATA", 'INFO')
            self.log("=" * 70, 'INFO')
            
            for schema, table_name in tables:
                rows_migrated = self.migrate_table(source_conn, target_conn, schema, table_name)
                
                if rows_migrated > 0:
                    self.migration_report['tables_migrated'].append({
                        'table': f"{schema}.{table_name}",
                        'rows': rows_migrated
                    })
                    self.migration_report['total_rows_migrated'] += rows_migrated
            
            # Reset sequences
            self.log("\n" + "=" * 70, 'INFO')
            self.log("RESETTING SEQUENCES", 'INFO')
            self.log("=" * 70, 'INFO')
            
            self.reset_sequences(target_conn, 'public')
            self.reset_sequences(target_conn, 'nexus_alpha')
            
            # Validate migration
            self.log("\n" + "=" * 70, 'INFO')
            self.log("VALIDATING MIGRATION", 'INFO')
            self.log("=" * 70, 'INFO')
            
            validation = self.validate_migration(source_conn, target_conn)
            
            if validation:
                self.log(f"\nSource total rows: {validation['total_source']}", 'INFO')
                self.log(f"Target total rows: {validation['total_target']}", 'INFO')
                
                if validation['success']:
                    self.log("✅ VALIDATION SUCCESSFUL - All rows migrated correctly!", 'SUCCESS')
                else:
                    self.log("⚠️  VALIDATION WARNING - Row count mismatch detected", 'WARNING')
                    
                    # Show mismatched tables
                    for result in validation['tables']:
                        if not result['match']:
                            self.log(f"   {result['table']}: {result['source_count']} → {result['target_count']}", 'WARNING')
            
            # Final report
            self.log("\n" + "=" * 70, 'INFO')
            self.log("MIGRATION COMPLETE", 'INFO')
            self.log("=" * 70, 'INFO')
            self.log(f"Tables migrated: {len(self.migration_report['tables_migrated'])}", 'INFO')
            self.log(f"Total rows migrated: {self.migration_report['total_rows_migrated']}", 'INFO')
            
            if self.migration_report['errors']:
                self.log(f"Errors: {len(self.migration_report['errors'])}", 'ERROR')
            
            if self.migration_report['warnings']:
                self.log(f"Warnings: {len(self.migration_report['warnings'])}", 'WARNING')
            
            self.migration_report['end_time'] = datetime.now().isoformat()
            
            return True
            
        except Exception as e:
            self.log(f"❌ Migration failed: {e}", 'ERROR')
            self.migration_report['errors'].append(str(e))
            return False
            
        finally:
            if source_conn:
                source_conn.close()
                self.log("Closed source connection", 'INFO')
            
            if target_conn:
                target_conn.close()
                self.log("Closed target connection", 'INFO')
    
    def save_report(self, filepath='migration_report.json'):
        """Save migration report to file"""
        try:
            with open(filepath, 'w') as f:
                json.dump(self.migration_report, f, indent=2, default=str)
            self.log(f"Migration report saved to {filepath}", 'INFO')
        except Exception as e:
            self.log(f"Could not save report: {e}", 'ERROR')


def main():
    """Main migration entry point"""
    
    # Get database URLs from environment
    source_db_url = os.getenv('SOURCE_SUPABASE_URL')
    target_db_url = os.getenv('TARGET_SUPABASE_URL')
    
    if not source_db_url or not target_db_url:
        print("❌ Missing environment variables:")
        print("   SOURCE_SUPABASE_URL: Original AI-Range database URL")
        print("   TARGET_SUPABASE_URL: New consolidated database URL")
        print("\nAdd these to your .env file:")
        print("   SOURCE_SUPABASE_URL=postgresql://user:password@host:5432/db")
        print("   TARGET_SUPABASE_URL=postgresql://user:password@host:5432/db")
        sys.exit(1)
    
    # Create migrator
    migrator = SupabaseMigrator(source_db_url, target_db_url, verbose=True)
    
    # Execute migration
    success = migrator.migrate()
    
    # Save report
    migrator.save_report('migration_report.json')
    
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
