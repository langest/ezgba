#!/usr/bin/env python

import argparse
import enum
import os
import random
import re
import string
import sys


RE_ROM_BASENAME = re.compile("(.*?)\s*(?=[()]|$)", re.MULTILINE)
RE_BRACKET = re.compile(".*?\((.*?)\)", re.MULTILINE)
RE_COMPONENT = re.compile("(?:,\s*|^)(.+?)(?=,\s*|$)", re.MULTILINE)
RE_LANGUAGE = re.compile("^(?:[A-Z][a-z]\+)*[A-Z][a-z]$", re.MULTILINE)
RE_VERSION = re.compile("^[vV](?P<compact>(?:[0-9]+\.)*(?:[0-9]+))$|^Rev (?P<rev>[0-9]+)$")
RE_ALTERNATE_VERSION = re.compile("^Alt (?P<alt_ver>[0-9]+)$")
RE_MULTIPACK_PREFIX = re.compile("^([0-9]+)")



class BracketType(enum.Enum):
    ROUND = 0
    SQUARE = 1


class RegionMap(enum.Enum):
    ASIA = "As", ("Asia",),
    AUSTRALIA = "A", ("Australia",),
    BRAZIL = "B", ("Brazil",),
    CANADA = "C", ("Canada",),
    CHINA = "Ch", ("China", "Taiwan",),
    DUTCH = "D", ("Dutch", "Netherlands (Dutch)",),
    EUROPE = "E", ("Europe",),
    FRANCE = "F", ("France",),
    FINLAND = "Fn", ("Finland",),
    GERMANY = "G", ("Germany",),
    GREECE = "Gr", ("Greece",),
    HONG_KONG = "HK", ("Hong Kong",),
    ITALY = "I", ("Italy",),
    JAPAN = "J", ("Japan",),
    KOREA = "K", ("Korea",),
    NETHERLANDS = "Nl", ("Netherlands",),
    NORWAY = "No", ("Norway",),
    RUSSIA = "R", ("Russia",),
    SPAIN = "S", ("Spain",),
    SWEDEN = "Sw", ("Sweden",),
    USA = "U", ("USA",),
    UNITED_KINGDOM = "UK", ("England", "United Kingdom",),
    PUBLIC_DOMAIN = "PD", ("Public Domain",),
    WORLD = "W", ("World",),
    UNKNOWN = "Unk", ("Unk", "Unknown",),
    UNLICENSED = "Unl", ("Unl", "Unlicensed",),

    def __init__(self, goodtools_tag, nointro_tags):
        self.goodtools_tag = goodtools_tag
        self.nointro_tags = nointro_tags


class GenericMap(enum.Enum):
    SGB_ENHANCED = "S", ("SGB Enhanced",),

    ALPHA = "Alpha", ("Alpha",),
    BETA = "Beta", ("Beta",),
    PROTOTYPE = "Prototype", ("Proto", "Prototype",),
    DEBUG = "Debug", ("Debug", "Debug Version",),

    def __init__(self, goodtools_tag, nointro_tags):
        self.goodtools_tag = goodtools_tag
        self.nointro_tags = nointro_tags


def get_regions(tags):
    mapped = []

    for tag in tags:
        for region in RegionMap:
            if tag in region.nointro_tags:
                mapped.append(region.goodtools_tag)
                break
        else:
            # Regions are all grouped together. If one isn't a region,
            # the rest aren't either.
            mapped = []
            break

    return ''.join(mapped)


def get_mapped_tags(tags):
    mapped = []
    success_mask = []

    for tag in tags:
        for map_tag in GenericMap:
            if tag in map_tag.nointro_tags:
                mapped.append(map_tag.goodtools_tag)
                success_mask.append(True)
                break
        else:
            mapped.append(tag)
            success_mask.append(False)

    return mapped, success_mask


def get_num_languages(tags):
    langs = []

    for tag in tags:
        if RE_LANGUAGE.match(tag):
            langs.extend([lang for lang in tag.split("+") if not lang in langs])
        else:
            # Languages are always grouped together. If one tag isn't a
            # language, the rest aren't languages either.
            langs = []
            break

    return len(langs)


def get_version(tags):
    # Version string is always alone. If there's more than one tag in a
    # bracket, it can't be a version string.
    if len(tags) == 1:
        ver_str = tags[0]
        m = RE_VERSION.match(ver_str)

        if m:
            if m.group('compact'):
                return m.group('compact').upper()
            elif m.group('rev'):
                return "V1.%s" % m.group('rev')

    return ''


def get_alternate_version(tags):
    # Version string is always alone. More than one tag means none them
    # are version strings.
    if len(tags) == 1:
        ver_str = tags[0]
        m = RE_ALTERNATE_VERSION.match(ver_str)

        if m:
            if m.group('alt_ver'):
                return m.group('alt_ver')

    return ''


def get_converted_tags(tags):
    num_langs = get_num_languages(tags)
    mapped_tags, mapped_successes = get_mapped_tags(tags)
    regions = get_regions(tags)
    version = get_version(tags)
    alternate_version = get_alternate_version(tags)

    if mapped_tags and not False in mapped_successes:
        return BracketType.ROUND, mapped_tags
    elif num_langs >= 2:
        return BracketType.ROUND, ["M%d" % num_langs]
    elif regions:
        return BracketType.ROUND, [regions]
    elif version:
        return BracketType.ROUND, [version]
    elif alternate_version:
        if int(alternate_version) > 1:
            return BracketType.SQUARE, ["a%s" % alternate_version]
        else:
            return BracketType.SQUARE, ["a"]
    elif num_langs == 1 and True in mapped_successes:
        return BracketType.ROUND, mapped_tags
    elif num_langs == 1:
        # Single-language games don't get special tags.
        return BracketType.ROUND, []
    else:
        # # DEBUG
        # print("Unmapped: %s" % ", ".join(mapped_tags), file=sys.stderr)
        return BracketType.ROUND, mapped_tags


def get_tags(s):
    # For each bracket, check its comma-separated contents.
    pos = 0
    tags  = []

    while True:
        m = RE_COMPONENT.match(s, pos)

        if m and m.lastindex >= 1:
            tags.append(m.group(1))
            pos = m.end(0)
        else:
            break

    return tags


def get_brackets(s, pos):
    brackets = []

    while True:
        m = RE_BRACKET.match(s, pos)

        if not m or m.lastindex < 1:
            # No more brackets.
            break
        else:
            tags = get_tags(m.group(1))
            pos = m.end(0)
            brackets.append(tags)

    return brackets, pos


def get_rom_basename(rom_filename):
    m = RE_ROM_BASENAME.match(rom_filename)

    if not m or m.lastindex < 1:
        return None, -1
    else:
        return m.group(1), m.end(0)


def get_abbreviated_basename(rom_basename):
    split = rom_basename.split(" - ")
    parts = []

    if len(split) > 1:
        for s in split[1:]:
            abbrev = ''.join(ss[0] for ss in s.split(' '))
            parts.append(abbrev)

    abbreviated_basename = split[0]

    if parts:
        abbreviated_basename += ' - '
        abbreviated_basename += ' - '.join(parts)

    return abbreviated_basename


def get_abbreviated_multipack_basename(rom_basename):
    split = rom_basename.split(" - ")

    if len(split) > 1:
        prefix = split[0]

        # FIXME Doesn't detect "4 Games on One Game Pak (Racing).gba"
        if prefix[0] in string.digits and \
            ("Game" in prefix or \
            "in 1" in prefix.lower() or "in-1" in prefix.lower() or \
            "in one" in prefix.lower() or "in-one" in prefix.lower() or \
            (prefix[-1] in string.digits and ''.join([b for b in prefix if b in string.ascii_letters]))):
            # Leading char already verified to be a digit. Won't throw.
            m = RE_MULTIPACK_PREFIX.match(prefix)
            num_games = m.group(1)

            return "%s-in-1 - %s" % (num_games, ' - '.join(split[1:]))

    return rom_basename


def rename_roms(rom_dir, abbrev=False, abbrev_multi=True, brand=True, dry_run=False):
    # Used for dry run.
    written_listing = []

    # Helps avoid file name conflicts.
    temp_dir = os.path.join(rom_dir, 'Rename-' + ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase) for _ in range(8)))

    if not dry_run:
        os.makedirs(temp_dir)

    for rom_filename in os.listdir(rom_dir):
        rom_filepath = os.path.join(rom_dir, rom_filename)

        if os.path.isfile(rom_filepath):
            print(":::: %s" % rom_filename)
            basename, pos = get_rom_basename(rom_filename)
            round_tags = []
            square_tags = []

            if not basename or pos < 0:
                print("     Cannot determine basename for \"%s\"" % rom_filename, file=sys.stderr)
            else:
                # Convert bracket contents to GoodTools-style.
                brackets, pos = get_brackets(rom_filename, pos)

                for tags in brackets:
                    bracket_type, converted = get_converted_tags(tags)

                    if bracket_type == BracketType.ROUND:
                        round_tags.append("(%s)" % ", ".join(converted))
                    elif bracket_type == BracketType.SQUARE:
                        square_tags.append("[%s]" % ", ".join(converted))

                # Concatenate ROM name components.
                new_filename = basename if not abbrev else get_abbreviated_basename(basename)
                new_filename = new_filename if not abbrev_multi else get_abbreviated_multipack_basename(basename)
                new_filepath = None

                if round_tags:
                    new_filename += ' '
                    new_filename += ' '.join(round_tags)

                if square_tags:
                    new_filename += ' '
                    new_filename += ' '.join(square_tags)

                if brand:
                    new_filename += ' [~]'

                # Re-add the file extension.
                split = rom_filename.split('.')

                if len(split) > 1:
                    new_filename += ".%s" % split[-1]

                # Rename the files if !dry_run.
                print("  -> %s" % new_filename)
                new_filepath = os.path.join(temp_dir, new_filename)

                if (not dry_run and os.path.exists(new_filepath)) or (dry_run and new_filename in written_listing):
                    print("     Cannot rename; file at \"%s\" already exists." % new_filepath, file=sys.stderr)
                else:
                    written_listing.append(new_filename)

                    if not dry_run:
                        os.rename(rom_filepath, new_filepath)

    if not dry_run:
        for rom_filename in os.listdir(temp_dir):
            current_filepath = os.path.join(temp_dir, rom_filename)
            final_filepath = os.path.join(rom_dir, rom_filename)

            os.rename(current_filepath, final_filepath)

        os.rmdir(temp_dir)



def main(argv=None):
    argv = argv if argv else sys.argv

    parser = argparse.ArgumentParser(description='Rename No-Intro ROM files to more closely resemble GoodTools.')
    parser.add_argument('rom_dir', metavar='DIR', type=str,
        help='all files within first depth level of this directory path will be renamed')
    parser.add_argument('--abbrev', dest='abbrev', required=False, action='store_true',
        help='abbreviate space-delimited strings that follow a hyphen')
    parser.add_argument('--no-brand', dest='brand', required=False, action='store_false',
        help='disable appending the branding tag')
    parser.add_argument('--dry-run', dest='dry_run', required=False, action='store_true',
        help='verbalize with no action')
    parser.add_argument('--abbrev-multi', dest='abbrev_multi', required=False, action='store_false',
        help='abbreviate multi-pack file name prefixes')

    args = parser.parse_args(argv[1:])

    rename_roms(args.rom_dir, abbrev=args.abbrev, abbrev_multi=args.abbrev_multi, brand=args.brand, dry_run=args.dry_run)


if __name__ == '__main__':
    main(sys.argv)
