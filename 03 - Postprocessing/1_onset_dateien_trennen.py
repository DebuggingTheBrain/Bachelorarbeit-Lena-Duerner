#-----------------------------------------------------#
#Skript zur Trennung der onset Dateien in zwei unterschiedliche Dateien 
#Autorin: Lena Dürner
#letzte Änderung: 26.06.2025
#-----------------------------------------------------#



import os

# Ursprungs- und Zielverzeichnis
source_root = r"F:\Dataset"
target_root = r"F:\LOG_FILES"  # Zielordner 

# Header zur Trennung
section2_start_header = "Event Type\tCode\tType\tResponse\tRT\tRT Uncertainty\tTime\tUncertainty\tDuration\tUncertainty\tReqTime\tReqDur"

for root, dirs, files in os.walk(source_root):
    for file in files:
        if file.endswith(".log"):
            log_path = os.path.join(root, file)

            with open(log_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            # Index der Trennung
            split_index = None
            for i, line in enumerate(lines):
                if line.strip().startswith("Event Type") and section2_start_header in line:
                    split_index = i
                    break

            if split_index is not None:
                part1_lines = lines[:split_index]
                part2_lines = lines[split_index:]

                # Zielordnerstruktur exakt wie Quelle (ohne log_ Präfix)
                relative_path = os.path.relpath(root, source_root)
                target_dir = os.path.join(target_root, relative_path)
                os.makedirs(target_dir, exist_ok=True)

                base_filename = os.path.splitext(file)[0]

                out1 = os.path.join(target_dir, f"{base_filename}_part1_subject_trial.txt")
                out2 = os.path.join(target_dir, f"{base_filename}_part2_eventtype.txt")

                with open(out1, "w", encoding="utf-8") as f1:
                    f1.writelines(part1_lines)

                with open(out2, "w", encoding="utf-8") as f2:
                    f2.writelines(part2_lines)

                print(f"✓ Getrennt gespeichert: {file} → {target_dir}")
            else:
                print(f"⚠️ Trenn-Header nicht gefunden in Datei: {log_path}")


# ========================================================================
# ENDE DES SKRIPTS
# ========================================================================

