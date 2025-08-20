import os
import glob
import subprocess
import shutil
from simnibs import sim_struct, localite, run_simnibs

# Pfad zu subject2mni (SimNIBS 4.5 Tool)
SUBJECT2MNI_CMD = r"H:\SimNIBS-4.5\bin\subject2mni.cmd"  # ggf. anpassen

# Coilmodell (einmal definieren)
COIL_PATH = r"H:\Neuronavigation\MagVenture_Cool-D-B80.nii.gz"

subjects = [
    {
        "id": "sub-SM2VP012_ses-T1",
        "subpath": r"H:\headmodels\sub-SM2VP012_ses-T1\m2m_sub-SM2VP012_ses-T1",
        "instrument": r"H:\Neuronavigation\SM2_VP012_20020101_SM2_VP012_5150bb100185f715\Sessions\Session_20250217165222275\InstrumentMarkers\InstrumentMarker20250220135321515.xml",
        "trigger": r"H:\Neuronavigation\SM2_VP012_20020101_SM2_VP012_5150bb100185f715\Sessions\Session_20250217165222275\TMSTrigger\TriggerMarkers_Coil1_20250220135317309.xml"
    }
]


# Basis-Ausgabeordner
OUTPUT_BASE = r"G:\tutorial_output"
os.makedirs(OUTPUT_BASE, exist_ok=True)

def run_subject2mni_conversion(msh_file, m2m_path, output_dir):
    """Ruft subject2mni.cmd auf, um .msh in .nii zu konvertieren."""
    cmd = f'"{SUBJECT2MNI_CMD}" --in "{msh_file}" --m2mpath "{m2m_path}" -o "{output_dir}" --labels 1,2'
    print(f"Running: {cmd}")
    subprocess.run(cmd, shell=True, check=True)

for subj in subjects:
    subj_output_dir = os.path.join(OUTPUT_BASE, subj["id"])
    nii_check = glob.glob(os.path.join(subj_output_dir, "*.nii"))

    if nii_check:  # Schon verarbeitet?
        print(f"Überspringe {subj['id']} – NIfTI-Dateien existieren bereits.")
        continue

    print(f"Starte Simulation für {subj['id']}...")
    os.makedirs(subj_output_dir, exist_ok=True)

    # --- SimNIBS Setup ---
    s = sim_struct.SESSION()
    s.subpath = subj["subpath"]
    s.pathfem = subj_output_dir

    loc = localite()
    s.add_tmslist(loc.read(subj["instrument"]))
    s.add_tmslist(loc.read(subj["trigger"]))

    for tmslist in s.poslists:
        tmslist.fnamecoil = COIL_PATH

    run_simnibs(s)

    # --- Nachbearbeitung: MSH → NIfTI (mit Unterordnern und Umbenennung) ---
    msh_files = glob.glob(os.path.join(subj_output_dir, "*.msh"))
    msh_files.sort()

    for i, msh_file in enumerate(msh_files, start=1):
        nummer = f"{i:04d}"
        output_folder = os.path.join(subj_output_dir, nummer)
        os.makedirs(output_folder, exist_ok=True)

        print(f"Konvertiere {os.path.basename(msh_file)} nach NIfTI...")

        # subject2mni aufrufen
        run_subject2mni_conversion(msh_file, subj["subpath"], output_folder)

        # Umbenennen der erzeugten Dateien
        tmp_foldername = nummer
        nii_e_src = os.path.join(output_folder, f"{tmp_foldername}_MNI_E.nii.gz")
        nii_magn_src = os.path.join(output_folder, f"{tmp_foldername}_MNI_magnE.nii.gz")

        base_name = os.path.basename(msh_file).replace(".msh", "")
        nii_e_dst = os.path.join(output_folder, f"{base_name}_MNI_E.nii.gz")
        nii_magn_dst = os.path.join(output_folder, f"{base_name}_MNI_magnE.nii.gz")

        if os.path.exists(nii_e_src):
            shutil.move(nii_e_src, nii_e_dst)
            print(f"Verschoben: {nii_e_src} → {nii_e_dst}")
        else:
            print(f"Warnung: Datei {nii_e_src} nicht gefunden!")

        if os.path.exists(nii_magn_src):
            shutil.move(nii_magn_src, nii_magn_dst)
            print(f"Verschoben: {nii_magn_src} → {nii_magn_dst}")
        else:
            print(f"Warnung: Datei {nii_magn_src} nicht gefunden!")

    # Optional: Lösche MSH-Dateien, wenn alle NIfTI-Dateien vorhanden sind
    all_nii_found = True
    for msh_file in msh_files:
        base_name = os.path.basename(msh_file).replace(".msh", "")
        nii_e_file = None
        nii_magn_file = None
        # Prüfe in welchem Unterordner das Ergebnis liegt (hier einfach alle nummerierten Ordner prüfen)
        found_e = False
        found_magn = False
        for i in range(1, len(msh_files)+1):
            nummer = f"{i:04d}"
            folder = os.path.join(subj_output_dir, nummer)
            if os.path.exists(os.path.join(folder, f"{base_name}_MNI_E.nii.gz")):
                found_e = True
            if os.path.exists(os.path.join(folder, f"{base_name}_MNI_magnE.nii.gz")):
                found_magn = True
        if not (found_e and found_magn):
            all_nii_found = False
            print(f"Warnung: NIfTI-Dateien für {base_name} fehlen.")

    if all_nii_found:
        for msh_file in msh_files:
            os.remove(msh_file)
        print(f"MSH-Dateien gelöscht für {subj['id']}")
    else:
        print(f"Nicht alle NIfTI-Dateien gefunden – MSH-Dateien werden behalten.")

print("Alle Probanden verarbeitet.")
