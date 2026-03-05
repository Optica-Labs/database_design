#!/usr/bin/env python3
"""
Connection Methods Tester - Automated Testing Script
Tests all 10 connection methods and tracks results
"""

import subprocess
import os
import sys
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

# Color codes for output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
END = '\033[0m'

class ConnectionTester:
    def __init__(self):
        self.results = []
        self.timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
    def test_method_1_python_individual(self):
        """Method 1: Python - psycopg2 (Individual Credentials)"""
        print(f"\n{BLUE}Testing Method 1: Python psycopg2 (Individual Credentials){END}")
        print("-" * 60)
        
        try:
            import psycopg2
            host = os.getenv('SUPABASE_HOST')
            port = os.getenv('SUPABASE_PORT', '5432')
            dbname = os.getenv('SUPABASE_DB')
            user = os.getenv('SUPABASE_USER')
            password = os.getenv('SUPABASE_PASSWORD')
            
            print(f"Connecting to: {host}:{port}/{dbname}")
            conn = psycopg2.connect(
                host=host,
                port=port,
                dbname=dbname,
                user=user,
                password=password,
                connect_timeout=10
            )
            cursor = conn.cursor()
            cursor.execute("SELECT version();")
            result = cursor.fetchone()[0]
            conn.close()
            
            print(f"{GREEN}✅ PASS - Connected successfully{END}")
            print(f"Version: {result[:50]}...")
            self.results.append(("Method 1", "PASS", "Individual credentials work"))
            return True
        except Exception as e:
            print(f"{RED}❌ FAIL - {str(e)[:100]}{END}")
            self.results.append(("Method 1", "FAIL", str(e)[:100]))
            return False
    
    def test_method_2_python_url(self):
        """Method 2: Python - psycopg2 (URL Format)"""
        print(f"\n{BLUE}Testing Method 2: Python psycopg2 (URL Format){END}")
        print("-" * 60)
        
        try:
            import psycopg2
            db_url = os.getenv('DATABASE_URL')
            
            print(f"Connecting with URL format...")
            conn = psycopg2.connect(db_url, connect_timeout=10)
            cursor = conn.cursor()
            cursor.execute("SELECT version();")
            result = cursor.fetchone()[0]
            conn.close()
            
            print(f"{GREEN}✅ PASS - URL format works{END}")
            print(f"Version: {result[:50]}...")
            self.results.append(("Method 2", "PASS", "URL format works"))
            return True
        except Exception as e:
            print(f"{RED}❌ FAIL - {str(e)[:100]}{END}")
            self.results.append(("Method 2", "FAIL", str(e)[:100]))
            return False
    
    def test_method_3_python_pooler(self):
        """Method 3: Python - psycopg2 (Pooler)"""
        print(f"\n{BLUE}Testing Method 3: Python psycopg2 (Pooler Connection){END}")
        print("-" * 60)
        
        try:
            import psycopg2
            pooler_url = os.getenv('TARGET_SUPABASE_URL')
            
            print(f"Connecting via pooler (port 6543)...")
            conn = psycopg2.connect(pooler_url, connect_timeout=10)
            cursor = conn.cursor()
            cursor.execute("SELECT version();")
            result = cursor.fetchone()[0]
            conn.close()
            
            print(f"{GREEN}✅ PASS - Pooler connection works{END}")
            print(f"Version: {result[:50]}...")
            self.results.append(("Method 3", "PASS", "Pooler works"))
            return True
        except Exception as e:
            error_msg = str(e)[:100]
            if "Tenant or user not found" in error_msg:
                print(f"{YELLOW}⚠️  CREDENTIALS EXPIRED - {error_msg}{END}")
                self.results.append(("Method 3", "AUTH EXPIRED", "Credentials need refresh"))
            else:
                print(f"{RED}❌ FAIL - {error_msg}{END}")
                self.results.append(("Method 3", "FAIL", error_msg))
            return False
    
    def test_method_5_psql_direct(self):
        """Method 5: CLI - psql direct"""
        print(f"\n{BLUE}Testing Method 5: CLI psql (Direct){END}")
        print("-" * 60)
        
        try:
            result = subprocess.run(
                ['psql', '-h', os.getenv('SUPABASE_HOST'),
                 '-p', os.getenv('SUPABASE_PORT', '5432'),
                 '-U', os.getenv('SUPABASE_USER'),
                 '-d', os.getenv('SUPABASE_DB'),
                 '-c', 'SELECT version();'],
                env={**os.environ, 'PGPASSWORD': os.getenv('SUPABASE_PASSWORD')},
                capture_output=True,
                timeout=10,
                text=True
            )
            
            if result.returncode == 0:
                print(f"{GREEN}✅ PASS - psql direct works{END}")
                print(f"Output: {result.stdout[:100]}...")
                self.results.append(("Method 5", "PASS", "psql direct works"))
                return True
            else:
                error = result.stderr[:100]
                print(f"{RED}❌ FAIL - {error}{END}")
                self.results.append(("Method 5", "FAIL", error))
                return False
        except FileNotFoundError:
            print(f"{YELLOW}⊘ SKIPPED - psql not installed{END}")
            self.results.append(("Method 5", "SKIPPED", "psql not installed"))
            return None
        except Exception as e:
            print(f"{RED}❌ FAIL - {str(e)[:100]}{END}")
            self.results.append(("Method 5", "FAIL", str(e)[:100]))
            return False
    
    def test_method_6_psql_env(self):
        """Method 6: CLI - psql with env vars"""
        print(f"\n{BLUE}Testing Method 6: CLI psql (With Env Vars){END}")
        print("-" * 60)
        
        try:
            env = os.environ.copy()
            env['PGHOST'] = os.getenv('SUPABASE_HOST')
            env['PGPORT'] = os.getenv('SUPABASE_PORT', '5432')
            env['PGDATABASE'] = os.getenv('SUPABASE_DB')
            env['PGUSER'] = os.getenv('SUPABASE_USER')
            env['PGPASSWORD'] = os.getenv('SUPABASE_PASSWORD')
            
            result = subprocess.run(
                ['psql', '-c', 'SELECT version();'],
                env=env,
                capture_output=True,
                timeout=10,
                text=True
            )
            
            if result.returncode == 0:
                print(f"{GREEN}✅ PASS - psql with env vars works{END}")
                print(f"Output: {result.stdout[:100]}...")
                self.results.append(("Method 6", "PASS", "psql env vars work"))
                return True
            else:
                error = result.stderr[:100]
                print(f"{RED}❌ FAIL - {error}{END}")
                self.results.append(("Method 6", "FAIL", error))
                return False
        except FileNotFoundError:
            print(f"{YELLOW}⊘ SKIPPED - psql not installed{END}")
            self.results.append(("Method 6", "SKIPPED", "psql not installed"))
            return None
        except Exception as e:
            print(f"{RED}❌ FAIL - {str(e)[:100]}{END}")
            self.results.append(("Method 6", "FAIL", str(e)[:100]))
            return False
    
    def print_summary(self):
        """Print summary of all tests"""
        print(f"\n\n{'=' * 60}")
        print(f"{BLUE}TEST SUMMARY - {self.timestamp}{END}")
        print(f"{'=' * 60}\n")
        
        passed = sum(1 for _, status, _ in self.results if status == "PASS")
        failed = sum(1 for _, status, _ in self.results if status == "FAIL")
        skipped = sum(1 for _, status, _ in self.results if status in ["SKIPPED", "AUTH EXPIRED"])
        
        print(f"{GREEN}✅ PASSED: {passed}{END}")
        print(f"{RED}❌ FAILED: {failed}{END}")
        print(f"{YELLOW}⊘ SKIPPED/EXPIRED: {skipped}{END}\n")
        
        print("Detailed Results:")
        print("-" * 60)
        for method, status, note in self.results:
            if status == "PASS":
                icon = f"{GREEN}✅{END}"
            elif status == "FAIL":
                icon = f"{RED}❌{END}"
            elif status == "SKIPPED":
                icon = f"{YELLOW}⊘{END}"
            elif status == "AUTH EXPIRED":
                icon = f"{YELLOW}⚠️{END}"
            else:
                icon = "❓"
            
            print(f"{icon} {method:30} {status:15} {note[:40]}")
        
        print("\n" + "=" * 60)
        
        # Recommendations
        print(f"\n{BLUE}RECOMMENDATIONS:{END}\n")
        
        working_methods = [m for m, s, _ in self.results if s == "PASS"]
        if working_methods:
            print(f"{GREEN}✅ Working methods:{END}")
            for method in working_methods:
                print(f"   - {method}")
        
        failed_methods = [m for m, s, _ in self.results if s == "FAIL"]
        if failed_methods:
            print(f"\n{RED}❌ Failed methods:{END}")
            for method in failed_methods:
                print(f"   - {method}")
            print(f"\n   💡 Update .env credentials from Supabase dashboard and retry")
        
        expired_methods = [m for m, s, _ in self.results if s == "AUTH EXPIRED"]
        if expired_methods:
            print(f"\n{YELLOW}⚠️  Expired methods:{END}")
            for method in expired_methods:
                print(f"   - {method}")
            print(f"\n   💡 Regenerate connection string from Supabase dashboard")
        
        skipped_methods = [m for m, s, _ in self.results if s == "SKIPPED"]
        if skipped_methods:
            print(f"\n{YELLOW}⊘ Skipped methods:{END}")
            for method in skipped_methods:
                print(f"   - {method}")
    
    def run_all_tests(self):
        """Run all available tests"""
        print(f"{BLUE}{'=' * 60}{END}")
        print(f"{BLUE}Connection Methods Tester{END}")
        print(f"{BLUE}Started: {self.timestamp}{END}")
        print(f"{BLUE}{'=' * 60}{END}")
        
        print("\n📋 Running tests...")
        
        # Phase 1: Python methods
        self.test_method_1_python_individual()
        self.test_method_2_python_url()
        self.test_method_3_python_pooler()
        
        # Phase 2: CLI methods
        self.test_method_5_psql_direct()
        self.test_method_6_psql_env()
        
        # Print summary
        self.print_summary()
        
        # Return exit code based on results
        passed = sum(1 for _, status, _ in self.results if status == "PASS")
        return 0 if passed > 0 else 1

def main():
    tester = ConnectionTester()
    exit_code = tester.run_all_tests()
    sys.exit(exit_code)

if __name__ == "__main__":
    main()
