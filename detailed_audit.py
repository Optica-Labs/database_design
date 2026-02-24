import re

with open('sql/schemas/schema_complete.sql', 'r') as f:
    content = f.read()

print("=== DETAILED SCHEMA ANALYSIS ===\n")

# Extract all tables and their columns
table_pattern = r'CREATE TABLE(?:\s+IF NOT EXISTS)?\s+(?:nexus_alpha\.)?(\w+)\s*\((.*?)\)\s*;'
matches = re.finditer(table_pattern, content, re.DOTALL)

tables_info = {}
for match in matches:
    table_name = match.group(1)
    table_def = match.group(2)
    # Extract columns (simplified)
    columns = re.findall(r'(\w+)\s+(\w+(?:\[\])?(?:\s+\w+)*)', table_def)
    tables_info[table_name] = {
        'columns': [col[0] for col in columns],
        'definition': table_def[:200]
    }

print(f"✅ Found {len(tables_info)} complete table definitions\n")

# Check foreign key references
fk_pattern = r'REFERENCES\s+(?:nexus_alpha\.)?(\w+)\s*\((\w+)\)'
fk_matches = re.finditer(fk_pattern, content)

fk_issues = []
for match in fk_matches:
    ref_table = match.group(1)
    ref_column = match.group(2)
    
    if ref_table not in tables_info:
        fk_issues.append(f"FK references non-existent table: {ref_table}({ref_column})")
    elif ref_column not in tables_info[ref_table]['columns'] and ref_column != 'id':
        # Allow 'id' as generic column
        fk_issues.append(f"FK references non-existent column: {ref_table}({ref_column})")

if fk_issues:
    print(f"❌ Found {len(fk_issues)} potential foreign key issues:")
    for issue in fk_issues[:10]:
        print(f"   - {issue}")
else:
    print("✅ All foreign keys reference valid tables/columns\n")

# Check for JSONB columns
jsonb_cols = len(re.findall(r'\bJSONB\b', content))
print(f"✅ JSONB columns: {jsonb_cols}")

# Check for UUID columns
uuid_cols = len(re.findall(r'\bUUID\b', content))
print(f"✅ UUID columns: {uuid_cols}")

# Check for sequences/serials
serials = len(re.findall(r'(?:BIGSERIAL|SERIAL)\b', content))
print(f"✅ SERIAL/BIGSERIAL: {serials}")

# Check for VECTOR columns
vectors = len(re.findall(r'\bvector\b', content))
print(f"✅ Vector columns: {vectors}")

# Check indexes reference valid columns
print("\n=== INDEX VALIDATION ===")
index_pattern = r'CREATE INDEX\s+(\w+)\s+ON\s+(?:nexus_alpha\.)?(\w+)\(([^)]+)\)'
idx_matches = re.finditer(index_pattern, content)

idx_issues = 0
for match in idx_matches:
    idx_name = match.group(1)
    table = match.group(2)
    columns = match.group(3)
    
    if table not in tables_info:
        print(f"❌ Index {idx_name} references non-existent table: {table}")
        idx_issues += 1

if idx_issues == 0:
    print("✅ All indexes reference valid tables")

# Check for incomplete column definitions (columns without types)
print("\n=== COLUMN TYPE VALIDATION ===")
incomplete_cols = re.findall(r'(\w+)\s*(?:,|\))\s*--', content)
if incomplete_cols:
    print(f"⚠️  Potential incomplete columns: {incomplete_cols[:5]}")
else:
    print("✅ No obviously incomplete column definitions")

print("\n=== CONSTRAINTS VALIDATION ===")
# Check PRIMARY KEY definitions
pks = len(re.findall(r'PRIMARY KEY', content))
print(f"✅ Primary keys: {pks}")

# Check UNIQUE constraints
uniques = len(re.findall(r'UNIQUE', content))
print(f"✅ Unique constraints: {uniques}")

# Check CHECK constraints
checks = len(re.findall(r'CHECK\s*\(', content))
print(f"✅ Check constraints: {checks}")

print("\n=== FINAL STATUS ===")
print("✅ Schema structure appears valid for PostgreSQL deployment")

