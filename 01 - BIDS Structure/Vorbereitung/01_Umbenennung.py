import os

def rename_folders_and_files_with_prefix(directory, prefix="sub-", subprefix="ses-"):
    # Gehe alle Elemente im angegebenen Verzeichnis durch
    for item_name in os.listdir(directory):
        item_path = os.path.join(directory, item_name)
        
        # Wenn es ein Ordner ist
        if os.path.isdir(item_path):
            # Neuer Ordnername mit dem Präfix
            new_item_name = prefix + item_name
            new_item_path = os.path.join(directory, new_item_name)
            
            # Ordner umbenennen
            os.rename(item_path, new_item_path)
            print(f"Ordner '{item_name}' wurde zu '{new_item_name}' umbenannt")

            # Jetzt die Unterordner im neu umbenannten Ordner umbenennen
            for subfolder_name in os.listdir(new_item_path):
                subfolder_path = os.path.join(new_item_path, subfolder_name)
                
                # Überprüfen, ob es ein Unterordner ist
                if os.path.isdir(subfolder_path):
                    new_subfolder_name = subprefix + subfolder_name
                    new_subfolder_path = os.path.join(new_item_path, new_subfolder_name)
                    
                    # Unterordner umbenennen
                    os.rename(subfolder_path, new_subfolder_path)
                    print(f"Unterordner '{subfolder_name}' wurde zu '{new_subfolder_name}' umbenannt")

                # Überprüfen, ob es eine Datei ist
                elif os.path.isfile(subfolder_path):
                    new_file_name = subprefix + subfolder_name
                    new_file_path = os.path.join(new_item_path, new_file_name)

                    # Datei umbenennen
                    os.rename(subfolder_path, new_file_path)
                    print(f"Datei '{subfolder_name}' wurde zu '{new_file_name}' umbenannt")

        # Wenn es eine Datei ist
        elif os.path.isfile(item_path):
            new_file_name = prefix + item_name
            new_file_path = os.path.join(directory, new_file_name)

            # Datei umbenennen
            os.rename(item_path, new_file_path)
            print(f"Datei '{item_name}' wurde zu '{new_file_name}' umbenannt")

# Der Dateipfad, in dem die Umbenennung durchgeführt werden soll
directory = r"F:\Dataset_5"
rename_folders_and_files_with_prefix(directory)
