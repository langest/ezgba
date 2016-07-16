#ifndef EZGBA_PATCH_HPP
#define EZGBA_PATCH_HPP


#include "data.hpp"
#include "gba.hpp"

void patch_complement_check(std::vector<unsigned char> & rom_data);

void patch_ezflash4(std::vector<unsigned char> & rom_data);

void uniformize_rom_padding(std::vector<unsigned char> &rom_data, const size_t alignment = 16);

void trim_padding(std::vector<unsigned char> &rom_data, const size_t alignment = 16,
				  const bool interchangeable_empty_byte = true);

void apply_ips_patch(std::vector<unsigned char> &data, const std::vector<unsigned char> &ips_patch);

std::vector<ByteOffset> patch_sram(std::vector<unsigned char> &rom_data);

std::vector<ByteOffset> patch_sram_by_type(std::vector<unsigned char> &rom_data, const gba::SaveType save_type,
						const bool interchangeable_empty_byte = true);

#endif //EZGBA_PATCH_HPP
