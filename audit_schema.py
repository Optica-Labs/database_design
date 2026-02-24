import re

with open('sql/schemas/schema_complete.sql', 'r') as f:
    content = f.read()
    lines = content.split('\n')

print("🔍 COMPREHENSIVE SCHEMA AUDIT\n")

# 1. Check for incomplete table definitions
incomplete_tables = re.findall(r'CREATE TABLE (?:IF NOT EXISTS )?(?:nexus_alpha\.)?(\w+)\s*\(\s*\);', content)
if incomplete_tables:
    print(f"ERROR: {len(incomplete_tables)} incomplete table definitions found:")
    for table in incomplete_tables[:5]:
        print(f"   - {table}")
else:
    print("OK: No incomplete table definitions")

# 2. Check for orphaned indexes
tables = set(re.findall(r'CREATE TABLE (?:IF NOT EXISTS )?(?:nexus_alpha\.)?(\w+)', content))
index_tables = set(re.findall(r'CREATE INDEX .+ ON (?:nexus_alpha\.)?(\w+)\(', content))
orphaned = index_tables - tables
if orphaned:
    print(f"\nERROR: {len(orphaned)} indexes reference non-existent tables:")
    for table in sorted(list(orphaned))[:10]:
        print(f"   - {table}")
else:
    print("\nOK: No orphaned indexes")

# 3. Check schema creation
if 'CREATE SCHEMA IF NOT EXISTS nexus_alpha' in content:
    print(f"\nOK: nexus_alpha schema is created")
else:
    print(f"\nERROR: nexus_alpha schema is NOT created")

# 4. Summary
print(f"\nSUMMARY:")
print(f"   Total lines: {len(lines)}")
print(f"   Tables defined: {len(tables)}")
print(f"   Indexes created: {len(list(re.finditer(r'CREATE INDEX', content)))}")
print(f"   Views created: {len(list(re.finditer(r'CREATE.*VIEW', content)))}")
print(f"   Triggers created: {len(list(re.finditer(r'CREATE TRIGGER', content)))}")
print(f"   Foreign keys: {len(re.findall(r'REFERENCES', content))}")

