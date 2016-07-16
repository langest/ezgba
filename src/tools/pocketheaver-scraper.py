#!/usr/bin/env python

import bs4
import csv
import requests
import sys
import enum
import urllib
import eta


HOST = "http://releases.pocketheaven.com"
NUM_RELEASES = 2819

class ScrapeError(Exception):
	pass

class NetworkError(ScrapeError):
	pass

class ParseError(ScrapeError):
	pass


class RomField(enum.Enum):
	RELEASE_NUM = "Release_Number", None, None
	LOCALIZED_TITLE_EN = "Localized_Title_EN", None, None

	SYSTEM = "System", "game info", "system"
	PUBLISHER = "Publisher", "game info", "publisher"
	COUNTRY = "Country", "game info", "country"
	LANGUAGE = "Language", "game info", "language"
	GENRE = "Genre", "game info", "genre"
	RELEASE_DATE = "Release_Date", "game info", "date"
	JDB_INFO = None, "game info", "jdb info"

	DUMP_GROUP = "Dump_Group", "dump info", "group"
	DUMP_DIRNAME = "Dump_Directory_Name", "dump info", "dirname"
	DUMP_FILENAME = "Dump_File_Name", "dump info", "filename"
	DUMP_DATE = "Dump_Date", "dump info", "date"

	INTERNAL_TITLE = "Internal_Title", "internal info", "internal name"
	INTERNAL_SERIAL = "Internal_Serial", "internal info", "serial"
	INTERNAL_VERSION = "Internal_Version", "internal info", "version"
	INTERNAL_CHECKSUM = None, "internal info", "checksum"
	COMPLEMENT_CHECK = "Complement_Check", "internal info", "complement"
	CRC32_HASH = "CRC32", "internal info", "crc32"
	ROM_SIZE = "ROM_Size", "internal info", "size"
	SAVE_TYPE = "Save_Type", "internal info", "save type"

	COMMENTS = "Comments", "extra info", "comments"
	RELEASE_NOTES = "Release_Notes", "extra info", "release notes"
	PATCHES = None, "extra info", "patches"

	def __init__(self, csv_field, html_section, html_field):
		self.csv_field = csv_field
		self.html_section = html_section
		self.html_field = html_field

# TODO Add more safety checks.

class RomInfoPage(object):
	def __init__(self, release_num):
		self.url = urllib.parse.urljoin(HOST, "?system=gba&section=release&rel=" + str(release_num).zfill(4))
		self.html = None
		self.fields = {}

	def download(self):
		assert self.url, "URL not set."

		r = requests.get(self.url)

		if not r or not r.text:
			raise NetworkError("Failed to download HTML from: " + self.url)
		elif r.status_code != requests.codes.ok:
			raise NetworkError("Request returned status " + r.status_code)
		else:
			self.html = r.text

	def register_html_field(self, html_section, html_field, html_value):
		for rom_field in RomField:
			if rom_field.html_section == html_section and rom_field.html_field == html_field:
				self.fields[rom_field] = html_value
				break
		else:
			print("Failed to pair HTML field \"%s\".", html_field, file=sys.stderr)

	def parse(self):
		assert self.url, "URL not set."
		assert self.html, "HTML not yet downloaded."

		# Must use html5lib to avoid content cutoff
		# http://stackoverflow.com/a/15588247/1588857
		soup = bs4.BeautifulSoup(self.html, "html5lib")

		# Parse release number and localized EN title.
		try:
			td = soup.find("td", {"class": "text4"})
			b = td.find("b").text.strip()
			split = b.split("-", 1)

			release_num = int(split[0].strip())
			localized_title_en = split[1].strip()

			self.fields[RomField.RELEASE_NUM] = release_num
			self.fields[RomField.LOCALIZED_TITLE_EN] = localized_title_en
		except Exception:
			raise ParseError("Failed to parse HTML: " + self.url);

		# Parse all the rest of the data.
		table = soup.find("table", {"class": "text", "align": "left", "valign": "top"})
		tbody = table.find("tbody")
		section = None

		for tr in tbody.find_all("tr", recursive=False):
			# Is this a section separator?
			b = tr.find("b")
			if b:
				if isinstance(b, str):
					section = b.strip().strip(":").lower()
					continue
				else:
					section = b.text.strip().strip(":").lower()
					continue

			children = [c for c in tr.children]

			# Skip the page turners at the bottom of the table.
			if len(children) < 2:
				continue

			field = children[0].text
			value = children[1]

			if value.string:
				value = value.string.strip()
			elif hasattr(value, "text") and value.text:
				value = value.text.strip()
			else:
				a = value.find("a")

				if not a:
					print("Parsing error: no link in second child, and not text. " + str(tr), file=sys.stderr)
					continue

				value = a.text.strip()

			field = field.strip().rstrip(":").lower()
			value = value.strip()

			if value.lower() == "n/a":
				value = None

			self.register_html_field(section, field, value)


def download_pages(begin = 1, end = NUM_RELEASES):
	for release_num in range(begin, end):
		page = RomInfoPage(release_num)

		for i in range(1, 10):
			try:
				page.download()
				break
			except ScrapeError as e:
				print(e)
		else:
			print("Failed to donwload ROM #%d; skipping.", release_num, file=sys.stderr)
			continue

		page.parse()
		yield page

def _main(argv):
	page = RomInfoPage(227)
	page.download()
	page.parse()

def main(argv):
	if len(argv) < 2:
		print("Must specify output CSV file path.")
		exit(1)

	output_path = argv[1]

	print("Scraping info for %i ROMs." % NUM_RELEASES)
	print("Writing output to \"%s\"" % output_path)


	# Write CSV
	csv_handle = open(output_path, "w", newline="", encoding="UTF8")
	csv_writer = csv.DictWriter(csv_handle, [f.csv_field for f in RomField if f.csv_field], quoting=csv.QUOTE_ALL)
	csv_writer.writeheader()

	progress_bar = eta.ETA(NUM_RELEASES)

	for index, page in enumerate(download_pages()):
		rom_info_dict = {}

		for rom_field in RomField:
			if rom_field.csv_field:
				if rom_field in page.fields and page.fields[rom_field]:
					rom_info_dict[rom_field.csv_field] = page.fields[rom_field]
				else:
					rom_info_dict[rom_field.csv_field] = ""

		csv_writer.writerow(rom_info_dict)
		progress_bar.print_status(extra="(%d/%d)" % (index, NUM_RELEASES))

	progress_bar.done()
	csv_handle.close()

if __name__ == "__main__":
	main(sys.argv)
