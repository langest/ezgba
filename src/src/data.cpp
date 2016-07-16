#include <cassert>
#include <cstddef>
#include <algorithm>
#include <fstream>
#include <iterator>
#include <limits>

#include <boost/filesystem.hpp>
#include <boost/filesystem/convenience.hpp>

#include "data.hpp"
#include "error.hpp"


ByteOffset_::operator bool() const {
	return this->valid;
}

ByteOffset_::operator bool() {
	return this->valid;
}


void read_file(std::vector<unsigned char> & data, const std::string & file_path) {
	std::ifstream fstrm;
	std::streampos fsize;
	size_t max_size = std::numeric_limits<size_t>::max();

	fstrm.open(file_path.c_str(), std::ios::binary | std::ios::ate);

	if (fstrm.is_open()) {
		fsize = fstrm.tellg();

		// Reset position b/c of file size reading earlier.
		fstrm.seekg(0, std::ios::beg);
		data.reserve(fsize <= max_size ? (size_t) fsize : max_size);

		// C/C++ standards require all char types to have identical binary layout w/ no padding bits.
		// http://stackoverflow.com/a/10336701
		data.assign(std::istreambuf_iterator<char>(fstrm), std::istreambuf_iterator<char>());
		fstrm.close();
	} else {
		std::string err = "Unable to read file: ";
		err += file_path;
		throw FileIOException(err);
	}
}


std::vector<unsigned char> read_file(const std::string & file_path) {
	std::vector<unsigned char> data;
	read_file(data, file_path);

	// If spec. is < C+11 return copies vector data, >= C+11 moves data.
	return data;
}


void write_file(const std::vector<unsigned char> & data, const std::string & file_path, const bool create_parent_dirs) {
	// Check/create parent directories.
	boost::filesystem::path parent_dirname = boost::filesystem::path(file_path).parent_path();

	if (boost::filesystem::exists(parent_dirname)) {
		if (!boost::filesystem::is_directory(parent_dirname)) {
			std::string e = "Cannot write file; parent directory path exists, but is not a directory: ";
			e += parent_dirname.generic_string();
			throw FileIOException(e);
		}
	} else if (create_parent_dirs) {
		if (!boost::filesystem::create_directories(parent_dirname)) {
			std::string e = "Failed to write file; could not create parent directory: ";
			e += parent_dirname.generic_string();
			throw FileIOException(e);
		}
	} else {
		std::string e = "Failed to write file; parent directory creation is disabled: ";
		e += parent_dirname.generic_string();
		throw FileIOException(e);
	}


	// Write the file.
	std::ofstream ostrm(file_path.c_str(), std::ios::out | std::ios::binary);

	if (ostrm.is_open()) {
		ostrm.write(reinterpret_cast<const char *>(data.data()), data.size());
		ostrm.close();
	} else {
		std::string err = "Could not open file for writing: ";
		err += file_path;
		throw FileIOException(err);
	}
}


void write_dummy_save(const std::string & file_path, const size_t size, const bool create_parent_dirs) {
	std::vector<unsigned char> data;

	for (size_t i=0; i<size; i++) {
		data.push_back((unsigned char) 0xff);
	}

	write_file(data, file_path, create_parent_dirs);
}


ByteOffset find_bytes(const std::vector<unsigned char> &data,
					  const std::vector<unsigned char> &find_data,
					  const std::vector<bool> * wildcard_mask) {
	// A true value in wildcard_mask will make the corresponding index in find_data match any value.
	assert((wildcard_mask == NULL || wildcard_mask->size() <= 0) || wildcard_mask->size() == find_data.size());
	bool use_mask = wildcard_mask != NULL && wildcard_mask->size() > 0 && wildcard_mask->size() == find_data.size();

	// Wildcard variant of the Boyer-Moore string matching algorithm. Fast w/ large alphabets.
	if (find_data.size() <= data.size()) {
		size_t data_len = data.size();
		size_t find_len = find_data.size();

		size_t data_idx = find_data.size() - 1;
		size_t find_idx = find_data.size() - 1;

		do {
			if (find_data.at(find_idx) == data.at(data_idx)
				|| (use_mask && wildcard_mask->at(find_idx))) {
				if (find_idx == 0) {
					// Match found.
					return ByteOffset(true, data_idx);
				} else {
					data_idx--;
					find_idx--;
				}
			} else {
				// Find the last index, relative to pattern start, that matches the current data byte.
				size_t last_match_idx = 0;

				for (last_match_idx = find_len-1; last_match_idx > 0; last_match_idx--) {
					if (find_data.at(last_match_idx) == data.at(data_idx)
						|| (use_mask && wildcard_mask->at(last_match_idx))) {
						break;
					}
				}

				data_idx += find_len - std::min(find_idx, last_match_idx+1);
				find_idx = find_len - 1;
			}
		} while (data_idx < data_len);
	}

	return ByteOffset(false, 0);
}


ByteOffset replace_bytes(std::vector<unsigned char> &data,
						 const std::vector<unsigned char> &find_data,
						 const std::vector<unsigned char> &replacement_data,
						 const std::vector<bool> * find_mask,
						 const std::vector<bool> * replacement_mask) {
	// A true value in find_mask will make the corresponding index in find_data match any value.
	// A true value in replacement_mask will make the corresponding index in replacement_data be skipped when writing.

	ByteOffset find_result = find_bytes(data, find_data, find_mask);
	bool found = find_result.valid;
	size_t idx = find_result.offset;

	assert(!found || (idx >= 0 && idx < data.size()));
	assert((replacement_mask == NULL || replacement_mask->size() <= 0) || (replacement_mask->size() == replacement_data.size()));
	bool use_replacement_mask = replacement_mask != NULL && replacement_mask->size() > 0 && replacement_mask->size() == replacement_data.size();

	// Replace data. Overwrites subsequent bytes if replacement is longer than find data.
	if (found) {
		data.reserve(std::max(data.size(), idx+replacement_data.size()+1));

		// TODO Optimize vector data replacement routine.
		for (size_t i = 0; i < replacement_data.size(); i++) {
			if (!use_replacement_mask || !replacement_mask->at(i)) {
				data[idx+i] = replacement_data.at(i);
			}
		}
	}

	return find_result;
}


size_t find_rom_eod(const std::vector<unsigned char> rom_data, const bool interchangeable_empty_byte) {
	assert(rom_data.size() > 0);

	const unsigned char end_byte = rom_data.back();

	if (end_byte == 0xff || end_byte == 0x00) {
		for (size_t i = rom_data.size()-1; i < ((size_t) 0) - 1; i--) {
			if ((!interchangeable_empty_byte && rom_data[i] != end_byte)
				|| (interchangeable_empty_byte && rom_data[i] != 0xff && rom_data[i] != 0x00)) {
				return i;
			}
		}
		
		return 0;
	}

	return rom_data.size() > 0 ? rom_data.size() - 1 : 0;
}


size_t next_aligned_address(const size_t address, const size_t alignment) {
	size_t aligned = address;

	while (aligned % alignment != 0) {
		aligned++;
	}

	return aligned;
}


void read_bytes_to_value(uint32_t & dest,
						 const std::vector<unsigned char> read_data, const size_t read_pos, const size_t read_size,
						 const Endianness read_endianness) {
	// One-line endianness detection.
	// http://esr.ibiblio.org/?p=5095
	bool is_big_endian = *(uint16_t *)"\0\xff" < 0x100;
	bool parallel = is_big_endian;

	if (read_endianness == LITTLE_ENDIAN_BYTE_ORDER) {
		parallel = !parallel;
	}

	dest = 0;

	for (size_t i=0, j=read_size-1; i < read_size && j < ((size_t) 0) - 1; i++, j--) {
		if (parallel) {
			dest += (read_data[read_pos+i] & 0xff) << (i*8);
		} else {
			dest += (read_data[read_pos+i] & 0xff) << (j*8);
		}
	}
}
