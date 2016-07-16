#ifndef EZGBA_MISC_HPP
#define EZGBA_MISC_HPP


#include <string>


typedef struct Options_struct {
	std::string ips = "";
	bool patch_sram = true;
	bool uniformize = false;
	bool patch_ez4 = true;
	bool patch_complement = true;
	bool trim = false;
	bool in_place = false;
	bool dummy_save = false;
} Options;


bool process_rom(const std::string & input_file, const std::string & output_file, const Options & opts);



#endif //EZGBA_MISC_HPP
