import os
import pandas as pd

# 🔧 Verzeichnis mit den Logfiles
log_root = r"F:\LOG_FILES"

# 🔧 Ausgabe-Datei
output_file = "valid_blocks_log.txt"
results = []

# 🔁 Alle Pfade durchlaufen
for root, dirs, files in os.walk(log_root):
    for file in files:
        if file.endswith("part2_eventtype.txt"):
            full_path = os.path.join(root, file)

            try:
                df = pd.read_csv(full_path, sep='\t', engine='python', encoding='utf-8', on_bad_lines='skip')
                if 'Code' not in df.columns or 'Response' not in df.columns:
                    continue

                # 🔍 Extrahiere VP und Session (T1-T4)
                parts = full_path.split(os.sep)
                vp = [p for p in parts if p.startswith("sub-")][0].replace("sub-", "")
                session = [p for p in parts if p.startswith("ses-")][0].replace("ses-", "")

                # 🔀 Blöcke finden (alle 'changed' Bilder)
                changed_rows = df[df['Code'].astype(str).str.contains("changed", case=False, na=False)]

                for idx, row in changed_rows.iterrows():
                    bildname = row['Code']

                    # Spider oder Bird Block?
                    block_type = "Spider" if "spider" in bildname.lower() else "Bird"

                    # Status: gültig, wenn Response == 2, sonst ungültig
                    try:
                        response_val = int(row['Response'])
                    except:
                        response_val = None

                    status = "gültig" if response_val == 2 else "ungültig"

                    results.append(f"VP{vp} {session} {block_type} Block: {status}")

            except Exception as e:
                print(f"Fehler bei Datei: {full_path} -> {e}")

# 💾 Schreibe Ergebnisse
with open(output_file, "w", encoding="utf-8") as f:
    for line in results:
        f.write(line + "\n")

print(f"✅ Analyse abgeschlossen. Ergebnisse in {output_file}")
