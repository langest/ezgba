#ifndef EZGBA_GBA_HPP
#define EZGBA_GBA_HPP

#include <map>
#include <vector>
#include <boost/assign.hpp>

namespace gba {
	enum GbaHeaderField {
		ROM_ENTRY_POINT,
		NINTENDO_LOGO,
		DEBUG_ENABLE,
		GAME_TITLE,
		GAME_CODE,
		MAKER_CODE,
		FIXED_VALUE,
		MAIN_UNIT_CODE,
		DEVICE_TYPE,
		RESERVED_AREA_1,
		SOFTWARE_VERSION,
		COMPLEMENT_CHECK,
		RESERVED_AREA_2,
		MULTIBOOT_ENTRY_POINT,
		MULTIBOOT_BOOT_MODE,
		MULTIBOOT_SLAVE_ID_NUMBER,
		MULTIBOOT_UNUSED_SECTOR,
		MULTIBOOT_JOYBUS_ENTRY_POINT,
	};


	enum SaveType {
		FLASH_V120, FLASH_V121, FLASH_V123, FLASH_V124, FLASH_V125, FLASH_V126,
		FLASH512_V130, FLASH512_V131, FLASH512_V133,
		FLASH1M_V102, FLASH1M_V103,
		EEPROM_V111, EEPROM_V120, EEPROM_V121, EEPROM_V122, EEPROM_V124, EEPROM_V126,
		SRAM_V110, SRAM_V111, SRAM_V112, SRAM_V113,
		FRAM_V100, FRAM_V102, FRAM_V103, FRAM_V110,
		NO_SAVE,
	};


	const std::vector<SaveType> SAVE_TYPES = boost::assign::list_of
		(FLASH_V120) (FLASH_V121) (FLASH_V123) (FLASH_V124) (FLASH_V125) (FLASH_V126)
		(FLASH512_V130) (FLASH512_V131) (FLASH512_V133)
		(FLASH1M_V102) (FLASH1M_V103)
		(EEPROM_V111) (EEPROM_V120) (EEPROM_V121) (EEPROM_V122) (EEPROM_V124) (EEPROM_V126)
		(SRAM_V110) (SRAM_V111) (SRAM_V112) (SRAM_V113)
		(FRAM_V100) (FRAM_V102) (FRAM_V103) (FRAM_V110)
		(NO_SAVE);


	const std::map<GbaHeaderField, size_t> HEADER_FIELD_ADDRESSES = boost::assign::map_list_of
		(ROM_ENTRY_POINT, 0x00000000)
		(NINTENDO_LOGO, 0x00000004)
		(DEBUG_ENABLE, 0x0000009C)
		(GAME_TITLE, 0x000000A0)
		(GAME_CODE, 0x000000AC)
		(MAKER_CODE, 0x000000B0)
		(FIXED_VALUE, 0x000000B2)
		(MAIN_UNIT_CODE, 0x000000B3)
		(DEVICE_TYPE, 0x000000B4)
		(RESERVED_AREA_1, 0x000000B5)
		(SOFTWARE_VERSION, 0x000000BC)
		(COMPLEMENT_CHECK, 0x000000BD)
		(RESERVED_AREA_2, 0x000000BE)
		(MULTIBOOT_ENTRY_POINT, 0x000000C0)
		(MULTIBOOT_BOOT_MODE, 0x000000C4)
		(MULTIBOOT_SLAVE_ID_NUMBER, 0x000000C5)
		(MULTIBOOT_UNUSED_SECTOR, 0x000000C6)
		(MULTIBOOT_JOYBUS_ENTRY_POINT, 0x000000E0);


	const std::map<GbaHeaderField, size_t> HEADER_FIELD_SIZES = boost::assign::map_list_of
		// Sizes are in bytes.
		(ROM_ENTRY_POINT, 4)
		(NINTENDO_LOGO, 156)
		(DEBUG_ENABLE, 1)
		(GAME_TITLE, 12)
		(GAME_CODE, 4)
		(MAKER_CODE, 1)
		(FIXED_VALUE, 1)
		(MAIN_UNIT_CODE, 1)
		(DEVICE_TYPE, 1)
		(RESERVED_AREA_1, 7)
		(SOFTWARE_VERSION, 1)
		(COMPLEMENT_CHECK, 1)
		(RESERVED_AREA_2, 2)
		(MULTIBOOT_ENTRY_POINT, 1)
		(MULTIBOOT_BOOT_MODE, 1)
		(MULTIBOOT_SLAVE_ID_NUMBER, 1)
		(MULTIBOOT_UNUSED_SECTOR, 26)
		(MULTIBOOT_JOYBUS_ENTRY_POINT, 1);


	const std::map<SaveType, std::vector<unsigned char>> SAVE_TYPE_BYTE_PATTERNS = boost::assign::map_list_of
		(FLASH_V120, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x5F) (0x56) (0x31) (0x32) (0x30).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V121, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x5F) (0x56) (0x31) (0x32) (0x31).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V123, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x5F) (0x56) (0x31) (0x32) (0x33).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V124, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x5F) (0x56) (0x31) (0x32) (0x34).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V125, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x5F) (0x56) (0x31) (0x32) (0x35).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V126, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x5F) (0x56) (0x31) (0x32) (0x36).convert_to_container<std::vector<unsigned char>>())

		(FLASH512_V130, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x35) (0x31) (0x32) (0x5F) (0x56) (0x31) (0x33) (0x30).convert_to_container<std::vector<unsigned char>>())
		(FLASH512_V131, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x35) (0x31) (0x32) (0x5F) (0x56) (0x31) (0x33) (0x31).convert_to_container<std::vector<unsigned char>>())
		(FLASH512_V133, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x35) (0x31) (0x32) (0x5F) (0x56) (0x31) (0x33) (0x33).convert_to_container<std::vector<unsigned char>>())

		(FLASH1M_V102, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x31) (0x4D) (0x5F) (0x56) (0x31) (0x30) (0x32).convert_to_container<std::vector<unsigned char>>())
		(FLASH1M_V103, boost::assign::list_of(0x46) (0x4C) (0x41) (0x53) (0x48) (0x31) (0x4D) (0x5F) (0x56) (0x31) (0x30) (0x33).convert_to_container<std::vector<unsigned char>>())

		(EEPROM_V111, boost::assign::list_of(0x45) (0x45) (0x50) (0x52) (0x4F) (0x4D) (0x5F) (0x56) (0x31) (0x31) (0x31).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V120, boost::assign::list_of(0x45) (0x45) (0x50) (0x52) (0x4F) (0x4D) (0x5F) (0x56) (0x31) (0x32) (0x30).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V121, boost::assign::list_of(0x45) (0x45) (0x50) (0x52) (0x4F) (0x4D) (0x5F) (0x56) (0x31) (0x32) (0x31).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V122, boost::assign::list_of(0x45) (0x45) (0x50) (0x52) (0x4F) (0x4D) (0x5F) (0x56) (0x31) (0x32) (0x32).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V124, boost::assign::list_of(0x45) (0x45) (0x50) (0x52) (0x4F) (0x4D) (0x5F) (0x56) (0x31) (0x32) (0x34).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V126, boost::assign::list_of(0x45) (0x45) (0x50) (0x52) (0x4F) (0x4D) (0x5F) (0x56) (0x31) (0x32) (0x36).convert_to_container<std::vector<unsigned char>>())

		// SRAM and FRAM don't require extra patching for flash cart saving (except for the EZ4 patch).
		(SRAM_V110, boost::assign::list_of(0x53) (0x52) (0x41) (0x4D) (0x5F) (0x56) (0x31) (0x31) (0x30).convert_to_container<std::vector<unsigned char>>())
		(SRAM_V111, boost::assign::list_of(0x53) (0x52) (0x41) (0x4D) (0x5F) (0x56) (0x31) (0x31) (0x31).convert_to_container<std::vector<unsigned char>>())
		(SRAM_V112, boost::assign::list_of(0x53) (0x52) (0x41) (0x4D) (0x5F) (0x56) (0x31) (0x31) (0x32).convert_to_container<std::vector<unsigned char>>())
		(SRAM_V113, boost::assign::list_of(0x53) (0x52) (0x41) (0x4D) (0x5F) (0x56) (0x31) (0x31) (0x33).convert_to_container<std::vector<unsigned char>>())

		(FRAM_V100, boost::assign::list_of(0x53) (0x52) (0x41) (0x4D) (0x5F) (0x46) (0x5F) (0x56) (0x31) (0x30) (0x30).convert_to_container<std::vector<unsigned char>>())
		(FRAM_V102, boost::assign::list_of(0x53) (0x52) (0x41) (0x4D) (0x5F) (0x46) (0x5F) (0x56) (0x31) (0x30) (0x32).convert_to_container<std::vector<unsigned char>>())
		(FRAM_V103, boost::assign::list_of(0x53) (0x52) (0x41) (0x4D) (0x5F) (0x46) (0x5F) (0x56) (0x31) (0x30) (0x33).convert_to_container<std::vector<unsigned char>>())
		(FRAM_V110, boost::assign::list_of(0x53) (0x52) (0x41) (0x4D) (0x5F) (0x46) (0x5F) (0x56) (0x31) (0x31) (0x30).convert_to_container<std::vector<unsigned char>>())

		(NO_SAVE, std::vector<unsigned char>());


	const std::map<SaveType, std::vector<unsigned char>> EZFLASH4_PATCHES = boost::assign::map_list_of
		// EZ Flash 4 client adds data from 0xB5 to 0xBC.
		// 0xB9 (inclusive) to 0xBC (inclusive) is used by the EZ4 to store the save data size.

		// FLASH_V* are all 512 Kbit.
		(FLASH_V120, boost::assign::list_of(0x10) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V121, boost::assign::list_of(0x10) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V123, boost::assign::list_of(0x10) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V124, boost::assign::list_of(0x10) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V125, boost::assign::list_of(0x10) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())
		(FLASH_V126, boost::assign::list_of(0x10) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())

		// FLASH512_* are all 512 Kbit.
		(FLASH512_V130, boost::assign::list_of(0x10) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())
		(FLASH512_V131, boost::assign::list_of(0x10) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())
		(FLASH512_V133, boost::assign::list_of(0x10) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())

		// FLASH1M_* are all 1024Kbit.
		(FLASH1M_V102, boost::assign::list_of(0x20) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())
		(FLASH1M_V103, boost::assign::list_of(0x20) (0x00) (0x13).convert_to_container<std::vector<unsigned char>>())

		// EEPROM_V* are all 64Kbit.
		(EEPROM_V111, boost::assign::list_of(0x02) (0x00) (0x12).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V120, boost::assign::list_of(0x02) (0x00) (0x12).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V121, boost::assign::list_of(0x02) (0x00) (0x12).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V122, boost::assign::list_of(0x02) (0x00) (0x12).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V124, boost::assign::list_of(0x02) (0x00) (0x12).convert_to_container<std::vector<unsigned char>>())
		(EEPROM_V126, boost::assign::list_of(0x02) (0x00) (0x12).convert_to_container<std::vector<unsigned char>>())

		// SRAM_* (including SRAM_F*) are all 256Kbit.
		// SRAM and FRAM don't require extra patching for flash cart saving (except for the EZ4 patch).
		(SRAM_V110, boost::assign::list_of(0x08) (0x00) (0x11).convert_to_container<std::vector<unsigned char>>())
		(SRAM_V111, boost::assign::list_of(0x08) (0x00) (0x11).convert_to_container<std::vector<unsigned char>>())
		(SRAM_V112, boost::assign::list_of(0x08) (0x00) (0x11).convert_to_container<std::vector<unsigned char>>())
		(SRAM_V113, boost::assign::list_of(0x08) (0x00) (0x11).convert_to_container<std::vector<unsigned char>>())

		(FRAM_V100, boost::assign::list_of(0x08) (0x00) (0x11).convert_to_container<std::vector<unsigned char>>())
		(FRAM_V102, boost::assign::list_of(0x08) (0x00) (0x11).convert_to_container<std::vector<unsigned char>>())
		(FRAM_V103, boost::assign::list_of(0x08) (0x00) (0x11).convert_to_container<std::vector<unsigned char>>())
		(FRAM_V110, boost::assign::list_of(0x08) (0x00) (0x11).convert_to_container<std::vector<unsigned char>>())

		// No save is 0Kbit (obviously).
		(NO_SAVE, boost::assign::list_of(0x08) (0x00) (0x10).convert_to_container<std::vector<unsigned char>>());


	const unsigned char NINTENDO_LOGO_DATA[] = {
		0x24, 0xFF, 0xAE, 0x51, 0x69, 0x9A, 0xA2, 0x21, 0x3D, 0x84, 0x82, 0x0A, 0x84, 0xE4, 0x09, 0xAD,
		0x11, 0x24, 0x8B, 0x98, 0xC0, 0x81, 0x7F, 0x21, 0xA3, 0x52, 0xBE, 0x19, 0x93, 0x09, 0xCE, 0x20,
		0x10, 0x46, 0x4A, 0x4A, 0xF8, 0x27, 0x31, 0xEC, 0x58, 0xC7, 0xE8, 0x33, 0x82, 0xE3, 0xCE, 0xBF,
		0x85, 0xF4, 0xDF, 0x94, 0xCE, 0x4B, 0x09, 0xC1, 0x94, 0x56, 0x8A, 0xC0, 0x13, 0x72, 0xA7, 0xFC,
		0x9F, 0x84, 0x4D, 0x73, 0xA3, 0xCA, 0x9A, 0x61, 0x58, 0x97, 0xA3, 0x27, 0xFC, 0x03, 0x98, 0x76,
		0x23, 0x1D, 0xC7, 0x61, 0x03, 0x04, 0xAE, 0x56, 0xBF, 0x38, 0x84, 0x00, 0x40, 0xA7, 0x0E, 0xFD,
		0xFF, 0x52, 0xFE, 0x03, 0x6F, 0x95, 0x30, 0xF1, 0x97, 0xFB, 0xC0, 0x85, 0x60, 0xD6, 0x80, 0x25,
		0xA9, 0x63, 0xBE, 0x03, 0x01, 0x4E, 0x38, 0xE2, 0xF9, 0xA2, 0x34, 0xFF, 0xBB, 0x3E, 0x03, 0x44,
		0x78, 0x00, 0x90, 0xCB, 0x88, 0x11, 0x3A, 0x94, 0x65, 0xC0, 0x7C, 0x63, 0x87, 0xF0, 0x3C, 0xAF,
		0xD6, 0x25, 0xE4, 0x8B, 0x38, 0x0A, 0xAC, 0x72, 0x21, 0xD4, 0xF8, 0x07
	};
}

#endif //EZGBA_GBA_HPP
