#!/usr/bin/env python3

import os
import re
from pathlib import Path

# Get all Java files
java_files = []
for root, dirs, files in os.walk('src'):
    for file in files:
        if file.endswith('.java'):
            path = os.path.join(root, file)
            # Extract class name from filename
            class_name = file.replace('.java', '')
            java_files.append((class_name, path))

print(f"Total Java files: {len(java_files)}\n")

# Read all Java files content
all_content = ""
for _, path in java_files:
    try:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            all_content += f.read() + "\n"
    except:
        pass

# Check which classes are used (imported or extended)
unused = []
for class_name, path in java_files:
    # Skip test files
    if 'Test.java' in path or 'Tests.java' in path:
        continue
    
    # Check if the class is referenced (imported or used in code)
    # Look for "import.*ClassName" or "extends ClassName" or "implements ClassName" or "new ClassName"
    patterns = [
        rf'import\s+.*\.{class_name}\s*;',
        rf'\s{class_name}\s+\w+',
        rf'new\s+{class_name}\s*\(',
        rf'extends\s+{class_name}\b',
        rf'implements\s+{class_name}\b',
        rf':\s*{class_name}\b'
    ]
    
    found = False
    for pattern in patterns:
        if re.search(pattern, all_content):
            found = True
            break
    
    if not found:
        unused.append((class_name, path))

print("Unused classes:")
for class_name, path in sorted(unused):
    print(f"  {class_name}: {path}")

print(f"\nTotal unused: {len(unused)}")
