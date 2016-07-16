#!/usr/bin/env python

# Removes the release group names from rom file names.
# Format: 1138 - Mortal Kombat - Tournament Edition (U)(Mode7).gba
# New: Mortal Kombat - Tournament Edition (U).gba

import os

ROM_DIR = "D:/GBA Roms Untouched"
DRY_RUN = False

rom_list = os.listdir(ROM_DIR)

def run(rom_dir):
	os.chdir(rom_dir)

	for rom_fname in rom_list:
		new_name = rom_fname
		new_path = os.path.join(rom_dir, new_name)
		rom_path = os.path.join(rom_dir, rom_fname)

		# Remove release group name.
		no_extension = ''.join(new_name.split(".")[:-1])
		group = no_extension.split("(")[-1].strip("()")

		if (len(group) > 1):
			new_name = "(".join(no_extension.split("(")[:-1]) + ".gba"
			new_path = os.path.join(rom_dir, new_name)

		# Remove release number.
		release_num = ''.join(new_name.split("-")[0]).strip()

		if len(release_num) == 4:
			new_name = '-'.join(new_name.split("-")[1:]).strip()
			new_path = os.path.join(rom_dir, new_name)

		# If the file already exists, rename it to "alt X"
		if os.path.isfile(new_path):
			alt_num = 1
			no_extension = ''.join(new_name.split(".")[:-1])

			while os.path.isfile(new_path):
				new_name = no_extension + "(alt " + str(alt_num) + ").gba"
				new_path = os.path.join(rom_dir, new_name)
				alt_num += 1


		if DRY_RUN:
			print(rom_fname + " -> " + new_name)
		else:
			print(rom_fname + " -> " + new_name)
			os.rename(rom_fname, new_name)

run(ROM_DIR)
