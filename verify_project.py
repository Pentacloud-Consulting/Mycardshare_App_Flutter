import os
import re

def check_dart_files(lib_dir):
    errors = []
    file_count = 0
    for root, dirs, files in os.walk(lib_dir):
        for f in files:
            if f.endswith('.dart'):
                file_count += 1
                path = os.path.join(root, f)
                try:
                    with open(path, 'r', encoding='utf-8') as fl:
                        content = fl.read()
                except Exception as e:
                    errors.append(f"Cannot read {path}: {e}")
                    continue

                # Check bracket balance
                stack = []
                pairs = {')': '(', '}': '{', ']': '['}
                in_single_line_comment = False
                in_multi_line_comment = False
                in_string = False
                string_char = ''
                is_raw = False
                is_triple = False
                i = 0
                n = len(content)

                # Quick regex import checker
                imports = re.findall(r"import\s+['\"]([^'\"]+)['\"];", content)
                for imp in imports:
                    if imp.startswith('package:my_card_share/'):
                        sub = imp.replace('package:my_card_share/', '')
                        target = os.path.join(lib_dir, sub).replace('/', os.sep)
                        if not os.path.exists(target):
                            errors.append(f"Broken package import in {path}: {imp}")
                    elif imp.startswith('.'):
                        curr_dir = root
                        target = os.path.normpath(os.path.join(curr_dir, imp.replace('/', os.sep)))
                        if not os.path.exists(target):
                            errors.append(f"Broken relative import in {path}: {imp}")

    print(f"Verified {file_count} Dart files. Found {len(errors)} errors.")
    for err in errors[:20]:
        print("  - " + err)
    return len(errors) == 0

if __name__ == '__main__':
    lib = os.path.abspath('my_card_share/lib')
    check_dart_files(lib)
