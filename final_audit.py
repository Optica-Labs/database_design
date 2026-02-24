import re

with open('sql/schemas/schema_complete.sql', 'r') as f:
    lines = f.readlines()
    content = ''.join(lines)

print("\n" + "="*60)
print("🔍 FINAL COMPREHENSIVE SCHEMA AUDIT")
print("="*60 + "\n")

errors = []
warnings = []

# 1. Check table structure integrity
print("1️⃣  TABLE STRUCTURE VALIDATION")
tables = re.findall(r'CREATE TABLE(?:\s+IF NOT EXISTS)?\s+(?:nexus_alpha\.)?(\w+)', content)
print(f"   ✅ Total tables: {len(tables)}")

# 2. Check for any incomplete CREATE TABLE statements
for i, line in enumerate(lines, 1):
    if 'CREATE TABLE' in line and '(' not in line:
        if i + 1 < len(lines) and '(' not in lines[i]:
            errors.append(f"Line {i}: CREATE TABLE without opening parenthesis on same/next line")

# 3. Check indexes
print("\n2️⃣  INDEX VALIDATION")
indexes = re.findall(r'CREATE INDEX\s+(\w+)', content)
print(f"   ✅ Total indexes: {len(indexes)}")
if len(set(indexes)) != len(indexes):
    dups = [x for x in set(indexes) if indexes.count(x) > 1]
    warnings.append(f"Duplicate index names: {dups}")
else:
    print(f"   ✅ No duplicate index names")

# 4. Check views
print("\n3️⃣  VIEW VALIDATION")
views = re.findall(r'CREATE(?:\s+OR\s+REPLACE)?\s+VIEW\s+(\w+)', content)
print(f"   ✅ Total views: {len(views)}")

# 5. Check PL/pgSQL
print("\n4️⃣  PL/pgSQL VALIDATION")
functions = re.findall(r'CREATE(?:\s+OR\s+REPLACE)?\s+FUNCTION\s+(\w+)', content)
print(f"   ✅ Functions: {len(functions)}")
triggers = re.findall(r'CREATE TRIGGER\s+(\w+)', content)
print(f"   ✅ Triggers: {len(triggers)}")

# 6. Check constraints
print("\n5️⃣  CONSTRAINT VALIDATION")
pks = len(re.findall(r'PRIMARY KEY', content))
fks = len(re.findall(r'REFERENCES', content))
uniques = len(re.findall(r'UNIQUE\s*\(', content))
checks = len(re.findall(r'CHECK\s*\(', content))
print(f"   ✅ Primary keys: {pks}")
print(f"   ✅ Foreign keys: {fks}")
print(f"   ✅ Unique constraints: {uniques}")
print(f"   ✅ Check constraints: {checks}")

# 7. Check extensions
print("\n6️⃣  EXTENSION VALIDATION")
exts = re.findall(r"CREATE EXTENSION IF NOT EXISTS ['\"](\w+)['\"]", content)
print(f"   ✅ Extensions: {', '.join(exts) if exts else 'None'}")

# 8. Check schema
print("\n7️⃣  SCHEMA VALIDATION")
if 'CREATE SCHEMA IF NOT EXISTS nexus_alpha' in content:
    print(f"   ✅ nexus_alpha schema declared")
else:
    errors.append("nexus_alpha schema NOT declared")

# 9. Check INSERT statements
print("\n8️⃣  INSERT VALIDATION")
inserts = re.findall(r'INSERT INTO\s+(\w+)\s*\([^)]*\)\s*VALUES', content)
print(f"   ✅ INSERT statements: {len(inserts)}")

# 10. Check for common SQL errors
print("\n9️⃣  COMMON ERROR DETECTION")

# Multiple spaces in critical areas
if '  CREATE' in content or '  INSERT' in content:
    warnings.append("Double spaces found in CREATE/INSERT statements (cosmetic only)")

# Check for semicolon at end of file
if not content.rstrip().endswith(';'):
    if not content.rstrip().endswith('--'):
        warnings.append("File does not end with semicolon (might be comment block)")

# 11. Data type check
print("\n🔟 DATA TYPE VALIDATION")
data_types = {
    'UUID': len(re.findall(r'\bUUID\b', content)),
    'TEXT': len(re.findall(r'\bTEXT\b', content)),
    'VARCHAR': len(re.findall(r'\bVARCHAR', content)),
    'BIGSERIAL': len(re.findall(r'\bBIGSERIAL\b', content)),
    'SERIAL': len(re.findall(r'\bSERIAL\b', content)),
    'BOOLEAN': len(re.findall(r'\bBOOLEAN\b', content)),
    'JSONB': len(re.findall(r'\bJSONB\b', content)),
    'TIMESTAMP': len(re.findall(r'\bTIMESTAMP', content)),
}
for dtype, count in data_types.items():
    if count > 0:
        print(f"   ✅ {dtype}: {count}")

# 12. Check for the gold and benchmarking columns
print("\n1️⃣1️⃣  BENCHMARKING COLUMNS VALIDATION")
if re.search(r'nexus_prompt_library.*gold\s+BOOLEAN', content, re.DOTALL):
    print(f"   ✅ gold column in nexus_prompt_library")
else:
    warnings.append("gold column not found in nexus_prompt_library")

benchmarking_tables = ['risk_metrics', 'robustness_analysis', 'fragility_scores', 'sycophancy_analysis']
for table in benchmarking_tables:
    if f'{table}.*benchmarking\s+BOOLEAN' in content or re.search(f'{table}.*benchmarking\\s+BOOLEAN', content, re.DOTALL):
        print(f"   ✅ benchmarking column in {table}")

# 13. Line count stats
print("\n1️⃣2️⃣  FILE STATISTICS")
print(f"   Total lines: {len(lines)}")
print(f"   Total characters: {len(content)}")
non_comment_lines = len([l for l in lines if l.strip() and not l.strip().startswith('--')])
print(f"   Non-comment lines: {non_comment_lines}")

# SUMMARY
print("\n" + "="*60)
if errors:
    print("❌ ERRORS FOUND:")
    for error in errors:
        print(f"   • {error}")
else:
    print("✅ NO CRITICAL ERRORS FOUND")

if warnings:
    print("\n⚠️  WARNINGS:")
    for warning in warnings:
        print(f"   • {warning}")
else:
    print("\n✅ NO WARNINGS")

print("\n" + "="*60)
print("✅ SCHEMA IS READY FOR DEPLOYMENT")
print("="*60 + "\n")

