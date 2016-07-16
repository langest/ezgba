#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Reads metadata from GBA ROMs.
"""

import enum


"""
The Nintendo logo that shows on GBA boot.
The cartridge contains a copy of the logo, which is verified against a copy harcoded in the GBA BIOS.
If the logo data doesn't match, the game won't start.
"""
GBA_NINTENDO_LOGO_DATA = [
	0x24, 0xFF, 0xAE, 0x51, 0x69, 0x9A, 0xA2, 0x21, 0x3D, 0x84, 0x82, 0x0A, 0x84, 0xE4, 0x09, 0xAD, 0x11, 0x24,
	0x8B, 0x98, 0xC0, 0x81, 0x7F, 0x21, 0xA3, 0x52, 0xBE, 0x19, 0x93, 0x09, 0xCE, 0x20, 0x10, 0x46, 0x4A, 0x4A,
	0xF8, 0x27, 0x31, 0xEC, 0x58, 0xC7, 0xE8, 0x33, 0x82, 0xE3, 0xCE, 0xBF, 0x85, 0xF4, 0xDF, 0x94, 0xCE, 0x4B,
	0x09, 0xC1, 0x94, 0x56, 0x8A, 0xC0, 0x13, 0x72, 0xA7, 0xFC, 0x9F, 0x84, 0x4D, 0x73, 0xA3, 0xCA, 0x9A, 0x61,
	0x58, 0x97, 0xA3, 0x27, 0xFC, 0x03, 0x98, 0x76, 0x23, 0x1D, 0xC7, 0x61, 0x03, 0x04, 0xAE, 0x56, 0xBF, 0x38,
	0x84, 0x00, 0x40, 0xA7, 0x0E, 0xFD, 0xFF, 0x52, 0xFE, 0x03, 0x6F, 0x95, 0x30, 0xF1, 0x97, 0xFB, 0xC0, 0x85,
	0x60, 0xD6, 0x80, 0x25, 0xA9, 0x63, 0xBE, 0x03, 0x01, 0x4E, 0x38, 0xE2, 0xF9, 0xA2, 0x34, 0xFF, 0xBB, 0x3E,
	0x03, 0x44, 0x78, 0x00, 0x90, 0xCB, 0x88, 0x11, 0x3A, 0x94, 0x65, 0xC0, 0x7C, 0x63, 0x87, 0xF0, 0x3C, 0xAF,
	0xD6, 0x25, 0xE4, 0x8B, 0x38, 0x0A, 0xAC, 0x72, 0x21, 0xD4, 0xF8, 0x07
]


class GbaHeaderField(enum.Enum):
	"""
	Represents GBA cartridge header fields.
	See GBATEK_ for more details.

	.. _GBATEK: http://problemkaputt.de/gbatek.htm#gbacartridgeheader
	"""

	"""
	The ROM entry point is a 32-bit ARM branch opcode (eg. ``B rom_start``).
	Data is 4 bytes and begins at ``0x00000000``.
	"""
	ROM_ENTRY_POINT = 0x00000000, 4

	"""
	Huffman compression data (excluding the compression header) containing the Nintendo logo displayed during boot.
	The compression header is harcoded in the BIOS, preventing decompression buffer overflow attacks.

	During the boot sequence, the logo data in the cartridge/multiboot header is verified against a master copy stored in the BIOS,
	succeeding only if they are identical (except for the value at ``0x0000009C``, which used to enable debug capabilities).

	The correct (non-debug) Nintendo logo data is::

		Offset(h) 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

		00000000              24 FF AE 51 69 9A A2 21 3D 84 82 0A
		00000010  84 E4 09 AD 11 24 8B 98 C0 81 7F 21 A3 52 BE 19
		00000020  93 09 CE 20 10 46 4A 4A F8 27 31 EC 58 C7 E8 33
		00000030  82 E3 CE BF 85 F4 DF 94 CE 4B 09 C1 94 56 8A C0
		00000040  13 72 A7 FC 9F 84 4D 73 A3 CA 9A 61 58 97 A3 27
		00000050  FC 03 98 76 23 1D C7 61 03 04 AE 56 BF 38 84 00
		00000060  40 A7 0E FD FF 52 FE 03 6F 95 30 F1 97 FB C0 85
		00000070  60 D6 80 25 A9 63 BE 03 01 4E 38 E2 F9 A2 34 FF
		00000080  BB 3E 03 44 78 00 90 CB 88 11 3A 94 65 C0 7C 63
		00000090  87 F0 3C AF D6 25 E4 8B 38 0A AC 72 21 D4 F8 07

	The value at ``0x0000009C`` is normally set to ``0x21``, but can be set to enable debugging.

	Data is 156 bytes and begins at ``0x00000004``.

	.. seealso:: :py:attr:`.DEBUG_ENABLE`
	"""
	NINTENDO_LOGO = 0x00000004, 156

	"""
	The debug byte is part of the Nintendo logo data, and the value is normally set to ``0x21``.

	Setting both bit 2 and 7 (ie. ``0xA5``) unlocks the BIOS's FIQ/Undefined Instruction handler, which then forwards the
	exceptions to the user handler in cartridge ROM (entry point defined in ``0x080000B4``).
	Other bit combinations do not appear to have special functions.

	Data is 2 *bits (not bytes!)* at ``0x0000009C``. The bits of importance are bits 2 and 7.

	.. seealso:: :py:attr:`.NINTENDO_LOGO` :py:attr:`DEVICE_TYPE`
	"""
	DEBUG_ENABLE = 0x0000009C, 1

	"""
	String displaying the game title, in uppercase ASCII.
	If the game title is less than 12 characters, the rest is padded with ``0x00``.

	Data is 12 bytes at ``0x000000A0``.
	"""
	GAME_TITLE = 0x000000A0, 12

	"""
	A 4-character string used as a unique identifier.

	Commerical games follow the format UTTD, where:

	==== =================================== =============================== ==== =====================
	            U (game type)                   TT (shorthand game title)     D (destination/language)
	---------------------------------------- ------------------------------- --------------------------
	Code Meaning                             Meaning                         Code Destination/language
	==== =================================== =============================== ==== =====================
	A    Normal game (usually 2001 to 2003)  An arbitrary abbreviation for   D    German
	B    Normal game (year 2003 onwards)     the game title (eg. "PM" for    E    USA/English
	C    Normal game (not yet used)          "Pac Man").                     F    French
	F    Famicom/NES                                                         I    Italian
	K    Acceleration sensor                                                 J    Japan
	P    For e-Reader (dot-code scanner)                                     P    Europe/elsewhere
	R    Rumble and Z-axis gyro sensor                                       S    Spanish
	U    RTC and solar sensor
	V    Rumble motor

	Data is 4 bytes, beginning at ``0x000000AC``.
	"""
	GAME_CODE = 0x000000AC, 4

	"""
	Commercial games identify the developer using this code.
	eg. ``0x01`` identifies Nintendo as the developer.

	Data is 1 byte at ``0x000000B0``.
	"""
	MAKER_CODE = 0x000000B0, 1

	"""
	All GBA ROM data should have this value set to ``0x96``.
	Data is 1 byte at ``0x000000B2``.
	"""
	FIXED_VALUE = 0x000000B2, 1

	"""
	Identifies the hardware required for this game.
	Should be ``0x00`` for Game Boy Advance.

	Data is 1 byte at ``0x000000B3``.
	"""
	MAIN_UNIT_CODE = 0x000000B3, 1

	"""
	Normally set to `0x00`.

	With Nintendo's hardware debugger, bit 7 identifies the debugging handlers'
	entry point and size of DACS (debugging and communication system) memory.
	Normal cartridges don't have any memory or mirrors at these addresses, however.

	============== ===================
	Value of bit 7 Meaning
	============== ===================
	0x00           9FFC000h/8MBIT DACS
	0x01           9FE2000h/1MBIT DACS

	The debug handler is enabled by setting the debug byte in the Nintendo logo
	data at ``0x0000009C``.

	Data is 1 byte at ``0x000000B4``.

	.. seealso :py:attr:`DEBUG_ENABLE`
	"""
	DEVICE_TYPE = 0x000000B4, 1

	"""
	Appears to be a useless area, usually filled with ``0x00``.
	Some flash carts or patchers may write their own data in this space.

	Data is 7 bytes at ``0x000000B5``.
	"""
	RESERVED_AREA_1 = 0x000000B5, 7

	"""
	Software version of the game. Usually ``0x00``.
	Data is 1 byte at ``0x000000BC``.
	"""
	SOFTWARE_VERSION = 0x000000BC, 1

	""""
	Header checksum, cartridge won't boot if incorrect.

	.. code-block:: python

		# Python code to calculate GBA complement check.
		checksum = 0

		for b in rom_data[0xa0:0xbd]:
			checksum = (checksum - b) & 0xff

		return (checksum - 0x19) & 0xff

	Data is 1 byte at ``0x000000BD``.
	"""
	COMPLEMENT_CHECK = 0x000000BD, 1

	"""
	Appears to be a useless area, usually filled with ``0x00``.
	Some flash carts or patchers may write their own data in this space.

	Data is 2 bytes at ``0x000000BE``.
	"""
	RESERVED_AREA_2 = 0x000000BE, 2

	"""
	Only used if GB booted by normal or multiplay transfer mode (not joybus).
	Typically contains a 32-bit ARM ``B <start>`` branch opcode, pointing to the actual initialization routine.

	Data is 1 byte at ``0x000000C0``.
	"""
	MULTIBOOT_ENTRY_POINT = 0x000000C0, 1

	"""
	The slave GBA download procedure overwrites this byte by a value which indicates the multiboot transfer mode used.
	Typically set this byte to zero by inserting ``DCB 0x00`` in your source.

	===== ==============
	Value Meaning
	===== ==============
	0x01  Joybus mode
	0x02  Normal mode
	0x03  Multiplay mode

	Data is 1 byte at ``0x000000C4``.
	"""
	MULTIBOOT_BOOT_MODE = 0x000000C4, 1

	"""
	If the GBA was booted in normal or multiplay mode, this byte is overwritten with the slave ID number of the local GBA (this is
	always ``0x01`` for normal mode).
	Typically set this byte to zero by inserting ``DCB 0x00`` in your source.
	When booted in joybus mode, the value is *not* changed and remains the same as uploaded from the master GBA.

	===== ========
	Value Meaning
	===== ========
	0x01  Slave #1
	0x02  Slave #2
	0x03  Slave #3

	Data is 1 byte at ``0x000000C5``.
	"""
	MULTIBOOT_SLAVE_ID_NUMBER = 0x000000C5, 1

	"""
	Appears to be unused.
	Data is 26 bytes at ``0x000000C6``.
	"""
	MULTIBOOT_UNUSED_SECTOR = 0x000000C6, 26

	"""
	If the GBA was booted using joybus transfer mode, the entry point is at this address instead of ``0x000000C0``.
	The intialization procedure should be directly at this address, or redirected to by a 32-bit ARM ``B <start>`` opcode here.
	This entry is unused if joybus isn't supported.

	Data is 1 byte at ``0x000000E0``.
	"""
	MULTIBOOT_JOYBUS_ENTRY_POINT = 0x000000E0, 1


	def __init__(self, address, data_length):
		"""
		Construct a GBA header field representation.

		:param int address: the address of the GBA header field
		:param int data_length: the length of the GBA header field, in bytes
		"""

		self.address = address
		self.data_length = data_length


class GbaSaveType(enum.Enum):
	"""
	Represents Game Boy Advance save types.
	There are four main save types that GBA cartridges broadly fall into: SRAM, Flash, EEPROM, and none/password (ie. no save).
	The save types can usually be detected by searching the ROM data for their magic strings, which are present in commercial
	ROMs. Although it's possible a "real" save type (ie. everthing except for none/password) won't include a magic string in
	the ROM data, this is usually a safe assumption.
	"""

	FLASH_V120 = b'FLASH_V120'
	FLASH_V121 = b'FLASH_V121'
	FLASH_V123 = b'FLASH_V123'
	FLASH_V124 = b'FLASH_V124'
	FLASH_V125 = b'FLASH_V125'
	FLASH_V126 = b'FLASH_V126'

	FLASH512_V130 = b'FLASH512_V130'
	FLASH512_V131 = b'FLASH512_V131'
	FLASH512_V133 = b'FLASH512_V133'

	FLASH1M_V102 = b'FLASH1M_V102'
	FLASH1M_V103 = b'FLASH1M_V103'

	EEPROM_V111 = b'EEPROM_V111'
	EEPROM_V120 = b'EEPROM_V120'
	EEPROM_V121 = b'EEPROM_V121'
	EEPROM_V122 = b'EEPROM_V122'
	EEPROM_V124 = b'EEPROM_V124'
	EEPROM_V126 = b'EEPROM_V126'

	SRAM_V110 = b'SRAM_V110'
	SRAM_V111 = b'SRAM_V111'
	SRAM_V112 = b'SRAM_V112'
	SRAM_V113 = b'SRAM_V113'

	SRAM_F_V100 = b'SRAM_F_V100'
	SRAM_F_V102 = b'SRAM_F_V102'
	SRAM_F_V103 = b'SRAM_F_V103'
	SRAM_F_V110 = b'SRAM_F_V110'

	NO_SAVE = None


	def __init__(self, magic_string):
		self.magic_string = magic_string


def verify_nintendo_logo(rom_data):
	"""
	Verify Nintendo logo data stored in GBA ROM data is correct.

	:param list rom_data: the GBA ROM data
	:returns: bool -- true if valid, false otherwise
	"""

	begin = GbaHeaderField.NINTENDO_LOGO.address
	end = GbaHeaderField.NINTENDO_LOGO.address + GbaHeaderField.NINTENDO_LOGO.data_length
	data_length = GbaHeaderField.NINTENDO_LOGO.data_length

	rom_logo_data = [b for b in rom_data[begin:end]] if len(rom_data) >= begin + data_length else []
	return rom_logo_data == GBA_NINTENDO_LOGO_DATA


def calculate_complement_check(rom_data):
	"""
	Calculate the complement check for a GBA ROM header.

	:param list of bytes rom_data: the GBA ROM header (can include more, but header data is minimum)
	:returns: int -- the calculated checksum

	.. seealso :py:attr:`GbaHeaderField.COMPLEMENT_CHECK`
	"""

	assert(len(rom_data) >= 189)

	checksum = 0

	for b in rom_data[0xa0:0xbd]:
		checksum = (checksum - b) & 0xff

	return (checksum - 0x19) & 0xff
