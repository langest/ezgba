ezgba v0.2.0 alpha: A GBA ROM Patcher
================================
Applies SRAM, IPS, and EZ4 header patches. Applies special header patch for
compatibility with EZ Flash 4. Did I mention it's compatible with the EZ4?
That means it's compatible with the EZ4. Which means the official EZ4 client is
no longer necessary. *No longer necessary.* **Smell the freedom.**

There's no official website for this app. The only place you should be getting
this file from is from my thread at gbatemp.


License
-------
ezgba is released under an unrestrictive license. See COPYING.txt for details.


Compiling
---------
Windows, Mac OS X, and Linux are all supported. Everything is written in C++.
CMake, Boost, and wxWidgets (if building GUI) are required to compile. Supports
GCC v5+ as far as compilers go.


SRAM Patches
------------
SRAM patches are 1:1 with gbata, but with some exceptions:

 - gbata will ensure the ROM padding is either all `0x00` or all `0xff`. ezgba
   can do this too, but doesn't determine if `0x00` or `0xff` should be used
   as the fill value the same way gbata does. This should be of little
   practical consequence.
 - There are about a dozen or so ROMs that require specialized SRAM patches
   instead of generic patches. gbata will handle them, I won't. You can search
   for some IPS patches on the internet as a solution.

There are about a dozen games that use `FLASH512_V133`, which isn't supported
by my patcher. gbata doesn't support these either, and I haven't found a GBA ROM
patcher that does. But as all 11 ROMs are of the 2-in-1 and 3-in-1 variety, I'm
not too concerned about `V133`.


EZ Flash 4
----------
The EZ Flash 4 client will apply a special header patch to the ROM's reserved
area 1, which stores information regarding the ROM size (`0xb8:0xb9`) and save
size (`0xba:0xbc`). `0xb5:0xb7` is zeroed out, for an unknown reason.

Without this header patch, ROMs on the EZ Flash 4 are still playable, but
won't save properly. Other flash carts may need their own special patches.

The EZ4 special header patch is supported, and is applied by default.


IPS Patches
-----------
Both the RLE and truncate extensions are supported. Some ROMs require
specialized IPS patches for save patching instead of generic SRAM patches; in
this case, you'll need to disable the default SRAM patching, and use the IPS
patch only. If you plan to use it on the EZ4, the EZ4 header patch still needs
to be applied.


Unsupported ROMs
----------------
These are ROMs that either have multiple save strings, that gbata has
specialized patches for, or uses `FLASH512_V133`. To patch any of these ROMs,
you need to manually select and apply the appropriate IPS patch(es).

 - Taiketsu! Ultra Hero (J)
 - Moero!! Jaleco Collection (J) (gbata can't patch this game)
 - Kim Possible (J)
 - Kim Possible 2 - Draken's Demise (E)
 - Kim Possible 2 - Draken's Demise (U)
 - Mother 3 (J)
 - Pokemon Fushigi no Dungeon - Aka no Kyuujotai (J)
 - Sangokushi - Eiketsuden (J)
 - Top Gun - Combat Zones (U) (M5)
 - Ueki no Housoku - Jingi Sakuretsu! Nouryokusha Battle (J)
 - Breath of Fire - Ryuu no Senshi (J) (contains 3 different magic strings)
 - Medabots AX - Metabee Ver. (E) (M5)
 - Medabots AX - Metabee Ver. (U)
 - Medabots AX - Rokusho Ver. (E) (M5)
 - Medabots AX - Rokusho Ver. (U)
 - Metarot G - Kabuto (J)
 - Metarot G - Kuwagata (J)
 - Super Monkey Ball Jr. (U)


Additional Caveats
------------------
 - The program exit status doesn't reflect program runtime errors. This is on
   the TO-DO list.


Credits
-------
 - foobar\_ (note the underscore): the programmer. My account is only at gbatemp.
   Any user named foobar\_ you encounter elsewhere is likely *not* me (I'm sure
   there are many users named "foobar" or some variant of it).
 - TrolleyDave & FAST6191: for the [SRAM patching thread at GBATemp][2].
   Saved me a lot of time and trouble with save patching.
 - totushi: [Square GBA icons(s)][3]
 - coolhj: gbata, from which the SRAM patches were reversed. He doesn't
   show up on Google, but if he had a homepage I'd link to it here.

[2]: https://gbatemp.net/threads/reverse-engineering-gba-patching.60168/
[3]: http://www.totushi.com/
