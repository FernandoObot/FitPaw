#!/usr/bin/env python3
import os
import re

# Get all class names from Java files
classes = {}
for root, dirs, files in os.walk('src'):
    for file in files:
        if file.endswith('.java'):
            path = os.path.join(root, file)
            class_name = file.replace('.java', '')
            full_path = path
            classes[class_name] = full_path

# Read all content
all_content = ""
for class_name, path in classes.items():
    try:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            all_content += f.read()
    except:
        pass

# Check usage for each class
unused = []
for class_name, path in sorted(classes.items()):
    # Skip test files
    if 'Test' in class_name:
        continue
    
    # Count how many times the class name appears outside its own file
    count = 0
    import_pattern = rf'import\s+.*\.{class_name}\s*;'
    
    # Count in all files except the definition file
    for other_class, other_path in classes.items():
        if other_class == class_name:
            continue
        try:
            with open(other_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                if re.search(import_pattern, content):
                    count += 1
        except:
            pass
    
    if count == 0:
        # Also check if it's referenced as a qualified name
        qual_count = all_content.count(f'{class_name}')
        if qual_count <= 1:  # Only in the definition itself
            unused.append(class_name)

print("Classes that appear to be unused (not imported):")
for cls in unused:
    print(f"  - {cls}")
print(f"\nTotal: {len(unused)}")
