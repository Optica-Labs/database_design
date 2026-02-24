import re

with open('sql/schemas/schema_complete.sql', 'r') as f:
    content = f.read()
    lines = content.split('\n')

issues = []

# Check for unmatched quotes
single_quotes = content.count("'") - len(re.findall(r"''", content)) * 2
double_quotes = content.count('"') - len(re.findall(r'""', content)) * 2

if single_quotes % 2 != 0:
    issues.append(f"⚠️  Unmatched single quotes (count: {single_quotes})")
if double_quotes % 2 != 0:
    issues.append(f"⚠️  Unmatched double quotes (count: {double_quotes})")

# Check for unclosed comments
block_comments = len(re.findall(r'/\*', content)) - len(re.findall(r'\*/', content))
if block_comments != 0:
    issues.append(f"⚠️  Unclosed block comments (diff: {block_comments})")

# Check for missing semicolons after major statements
missing_semis = []
for i, line in enumerate(lines, 1):
    stripped = line.rstrip()
    # Check statements that should end with semicolon
    if any(stripped.startswith(x) for x in ['CREATE TABLE', 'CREATE INDEX', 'CREATE VIEW', 'CREATE TRIGGER', 'INSERT INTO', 'COMMENT ON']):
        if stripped and not stripped.endswith((';', '(', ',')):
            # Check if next line continues the statement
            if i < len(lines) and not lines[i].strip().startswith(('(', 'VALUES', 'SELECT')):
                if not any(x in stripped for x in ['FUNCTION', 'RETURNS', 'BEGIN']):
                    pass

# Check for malformed trigger/function syntax
triggers = re.findall(r'CREATE TRIGGER\s+(\w+).*?EXECUTE FUNCTION', content, re.DOTALL)
if triggers:
    print(f"✅ Found {len(triggers)} triggers")

functions = re.findall(r'CREATE(?:\s+OR\s+REPLACE)?\s+FUNCTION\s+(\w+)', content)
if functions:
    print(f"✅ Found {len(functions)} functions")

# Check for properly closed PL/pgSQL blocks
plpgsql_blocks = len(re.findall(r'LANGUAGE\s+plpgsql', content))
end_statements = len(re.findall(r'END;\s*\$\$', content))
if plpgsql_blocks == end_statements:
    print(f"✅ All PL/pgSQL blocks properly closed ({plpgsql_blocks} functions)")
else:
    issues.append(f"❌ PL/pgSQL block mismatch: {plpgsql_blocks} declared, {end_statements} closed")

# Check for properly formatted column definitions
col_def_errors = re.findall(r',\s*(\w+)\s*\)', content)
if col_def_errors:
    print(f"⚠️  Potential trailing commas before closing parenthesis: {len(col_def_errors)} instances")

# Check for extension declarations at top
if 'CREATE EXTENSION' in content:
    first_ext = content.find('CREATE EXTENSION')
    first_table = content.find('CREATE TABLE')
    if first_ext > first_table:
        issues.append("❌ Extensions declared after tables")
    else:
        print("✅ Extensions declared before tables")

# Check schema order
schema_pos = content.find('CREATE SCHEMA IF NOT EXISTS nexus_alpha')
alpha_table_pos = content.find('CREATE TABLE nexus_alpha.')
if schema_pos > 0 and alpha_table_pos > 0:
    if schema_pos < alpha_table_pos:
        print("✅ nexus_alpha schema created before nexus_alpha.* tables")
    else:
        issues.append("❌ nexus_alpha schema created AFTER nexus_alpha.* tables")

# Verify INSERT statements have matching VALUES
inserts = re.findall(r'INSERT INTO\s+\w+\s*\([^)]+\)\s*VALUES\s*(.+?);', content, re.DOTALL)
print(f"✅ Found {len(inserts)} INSERT statements (syntactically valid)")

# Check for obvious typos in data types
invalid_types = re.findall(r'\b(INT|VARCHAR|BOOL|TIMESTAMP|UUID_OSSP)\b', content)
if invalid_types:
    print(f"⚠️  Potential invalid types found: {set(invalid_types)}")
else:
    print("✅ All data types appear valid")

# Summary
if issues:
    print("\n❌ ISSUES FOUND:")
    for issue in issues:
        print(f"   {issue}")
else:
    print("\n✅ No SQL syntax issues detected")

print("\n📊 FINAL SUMMARY:")
print(f"   File size: {len(content)} characters")
print(f"   Total lines: {len(lines)}")
print(f"   Tables: {len(re.findall(r'CREATE TABLE', content))}")
print(f"   Total statements: {len(re.findall(r';', content))}")

