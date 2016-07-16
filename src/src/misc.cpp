#include <iostream>
#include <vector>
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/convenience.hpp>


#include "misc.hpp"
#include "data.hpp"
#include "error.hpp"
#include "patch.hpp"


namespace fs = boost::filesystem;


bool process_rom(const std::string & input_file, const std::string & output_file, const Options & opts) {
	std::vector<unsigned char> rom_data;
	std::vector<unsigned char> ips_data;

	bool success = true;

	try {
		std::cout << "Reading ROM file: " << input_file << std::endl;
		rom_data = read_file(input_file);
	} catch (FileIOException & e) {
		std::cerr << "Error reading ROM file: " << e.error() << std::endl;
		success = false;
	} catch (std::exception &e) {
		std::cerr << "Error reading ROM file: " << e.what() << std::endl;
		success = false;
	}

	if (success && opts.ips.size() > 0) {
		try {
			std::cout << "Reading IPS patch: " << opts.ips << std::endl;
			ips_data = read_file(opts.ips);
		} catch (FileIOException & e) {
			std::cerr << "Error reading IPS patch file: " << e.error() << std::endl;
			success = false;
		} catch (std::exception & e) {
			std::cerr << "Error reading IPS patch file: " << e.what() << std::endl;
			success = false;
		}
	}

	if (rom_data.size() > 0) {
		if (ips_data.size() > 0) {
			try {
				std::cout << "Applying IPS patch." << std::endl;
				apply_ips_patch(rom_data, ips_data);
			} catch (MalformedDataException & e) {
				std::cerr << "Failed to apply IPS patch: " << e.error() << std::endl;
			} catch (std::exception & e) {
				std::cerr << "Failed to apply IPS patch: " << e.what() << std::endl;
			}
		}

		if (opts.uniformize) {
			std::cout << "Uniformizing ROM padding." << std::endl;
			uniformize_rom_padding(rom_data);
		}

		if (opts.patch_sram) {
			try {
				std::cout << "Patching save type to SRAM." << std::endl;
				patch_sram(rom_data);
			} catch (MalformedDataException &e) {
				std::cerr << "Error during IPS patching: " << e.error() << std::endl;
				success = false;
			} catch (PatternNotFoundException &e) {
				std::cerr << "Error during IPS patching: " << e.error() << std::endl;
				success = false;
			}
		}

		if (opts.patch_ez4) {
			try {
				std::cout << "Applying special EZ Flash 4 header patch." << std::endl;
				patch_ezflash4(rom_data);
			} catch (MalformedDataException &e) {
				std::cerr << "Error during EZ4 header patching: " << e.error() << std::endl;
				success = false;
			}
		}

		if (opts.patch_complement) {
			try {
				std::cout << "Correcting complement checksum." << std::endl;
				patch_complement_check(rom_data);
			} catch (MalformedDataException & e) {
				std::cerr << "Error during complement check patch: " << e.error() << std::endl;
				success = false;
			}
		}

		if (opts.trim) {
			std::cout << "Trimming ROM padding." << std::endl;
			trim_padding(rom_data);
		}

		try {
			std::cout << "Writing output file: " << (opts.in_place ? input_file : output_file) << std::endl;

			if (opts.in_place) {
				write_file(rom_data, input_file);
			} else {
				write_file(rom_data, output_file);
			}
		} catch (FileIOException & e) {
			std::cerr << "Failed to write file: " << e.error() << std::endl;
			success = false;
		} catch (std::exception & e) {
			std::cerr << "Failed to write file: " << e.what() << std::endl;
			success = false;
		}

		if (opts.dummy_save) {
			try {
				fs::path rom_write_path = fs::path((opts.in_place ? input_file : output_file));
				fs::path rom_write_parent = rom_write_path.parent_path();
				fs::path dummy_write_path = rom_write_parent / "saver" / rom_write_path.filename();
				dummy_write_path.replace_extension(".sav");
				dummy_write_path = dummy_write_path.native();

				if (!fs::exists(dummy_write_path)) {
					std::cout << "Writing dummy save: " << dummy_write_path << std::endl;
					write_dummy_save(dummy_write_path.generic_string());
				}
			} catch (FileIOException & e) {
				std::cerr << "Failed to write dummy save: " << e.error() << std::endl;
				success = false;
			} catch (std::exception & e) {
				std::cerr << "Failed to write dummy save: " << e.what() << std::endl;
				success = false;
			}
		}

		return success;
	}

	return false;
}