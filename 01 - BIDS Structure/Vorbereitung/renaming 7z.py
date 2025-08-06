import os
import re

# Hauptordner
root_dir = r'F:\Dataset'

# Muster: Alles bis _T1 oder _T4, danach eine Zahl, dann .7z
pattern = re.compile(r'^(.*_T[14])_[0-9]+\.7z$')

# Durchlaufe alle Unterordner
for dirpath, _, filenames in os.walk(root_dir):
    for filename in filenames:
        if filename.endswith('.7z'):
            match = pattern.match(filename)
            if match:
                new_filename = match.group(1) + '.7z'
                old_path = os.path.join(dirpath, filename)
                new_path = os.path.join(dirpath, new_filename)

                # Umbenennen, falls noch nicht passiert
                if old_path != new_path:
                    print(f"📝 Umbenennen:\n  {old_path}\n→ {new_path}")
                    os.rename(old_path, new_path)

print("\n✅ Alle passenden .7z-Dateien wurden umbenannt.")
