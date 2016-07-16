#ifndef EZGBA_DATA_HPP
#define EZGBA_DATA_HPP

#include <string>
#include <vector>

#ifdef _WIN32
	typedef __int32 int32_t;
	typedef __int16 int16_t;
	typedef unsigned __int32 uint32_t;
	typedef unsigned __int16 uint16_t;
#else
	#include <stdint.h>
#endif


typedef struct ByteOffset_ {
	bool valid;
	size_t offset;

	ByteOffset_(const bool matched = false, const size_t offset = 0) : valid(matched), offset(offset) {}
	explicit operator bool() const;
	explicit operator bool();
} ByteOffset;


enum Endianness {
	BIG_ENDIAN_BYTE_ORDER,
	LITTLE_ENDIAN_BYTE_ORDER
};


void read_file(std::vector<unsigned char> & data, const std::string & file_path);

std::vector<unsigned char> read_file(const std::string & file_path);

void write_file(const std::vector<unsigned char> & data, const std::string & file_path, const bool create_parent_dirs = true);

void write_dummy_save(const std::string & file_path, const size_t size = 512, const bool create_parent_dirs = true);

ByteOffset find_bytes(const std::vector<unsigned char> & data,
					  const std::vector<unsigned char> & find_data,
					  const std::vector<bool> * wildcard_mask = NULL);

ByteOffset replace_bytes(std::vector<unsigned char> & data,
						 const std::vector<unsigned char> & find_data,
						 const std::vector<unsigned char> & replacement_data,
						 const std::vector<bool> * find_mask = NULL,
						 const std::vector<bool> * replacement_mask = NULL);

size_t find_rom_eod(const std::vector<unsigned char> rom_data, const bool interchangeable_empty_byte = true);

size_t next_aligned_address(const size_t address, const size_t alignment);

void read_bytes_to_value(uint32_t & dest,
						 const std::vector<unsigned char> read_data, const size_t read_pos, const size_t read_size,
						 const Endianness read_endianness = BIG_ENDIAN_BYTE_ORDER);

#endif //EZGBA_DATA_HPP
