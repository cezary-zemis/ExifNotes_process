Concept
===========

There are the following tools here: 
* ExifNotes - reads a JSON file exported from ExifNotes app and applies EXIF tags to image files
* contact-sheet - reads EXIF tags from images and creates a contact sheet file

Notes
-----

* Tested only on Linux, however it shoud work on any system supporting Python 3

Installation
============

No installation automatization is provided. I use the following way:
* Python 3 and the following Python moduels are reqired:
    * Pillow
	* piexif
* exiftool binary must be installed
* create a repos directory somewhere
* clone ExifNotoes_process into the directory
* symlink executables (ExifNotes and contact-sheet) to a directory that is in your PATH, e.g. ~/bin or /usr/local/bin

Usage
=====

ExifNotes
---------

* record shooting data (exposure, GPS, camera, lens, film etc) using ExifNotes app (https://play.google.com/store/apps/details?id=com.tommihirvonen.exifnotes)
* develop your film and scan it
    * there should be separate directory for each roll or batch of sheet films
    * files must be namaed the way that sorts properly
    * you can put an empty image in place of a failed take (important for a contact sheet)
    * the number of images must match number of frames you recorded in the app
* export roll data from ExifNotes app in JSON format into the directory
* run ExifNotes script in the directory - it will apply EXIF tags to the images

contact-sheet
-------------

* put a set of images taken on one roll or batch in its own directory
* make sure the images contain EXIF tags
* run contact-sheet in the directory; it requires one or two parameters:
    * one parameter - pre-defined frame format: ff (135full frame), 645, 66, 67, 69, 45, 57, 810; it is used only to set number of columns and rows
    * two parameters - number of columns and rows

Notes:
* contact sheet files will be overwritten without any warning; no security mechanism is implemented
* thumbnail size and font size is determined automatically

Environment
-----------

Environment variables can be used to change behaviour of the tools. 
* DRY_RUN - if set to a non-empty value supress actual job, only displays what would be done; implemented only in ExifNotes
* WORKING_DIR - use insted of current directory
* EXTENSIONS - space separated set of file name extensions to be regardes as images
* EXIF_NOTES_EXTENSION - file name extension of ExifNotes roll data export
* NOTES_SEPARATOR - string that separates fields in ImageDescription tag
* CS_FILE_NAME - fixed part of contact sheet file name
* RESOLUTION - contact sheet image resolution [DPI]
* PAPER_WIDTH - contact sheet image width [mm]
* PAPER_HEIGHT - contact sheet image height [mm]
* MARGIN_LEFT, MARGIN_RIGTH, MARGIN_TOP, MARGIN_BOTTOM - margins [mm]
* HEADER_HEIGTH - height of page header [mm]
* TEXT_BOX_HEIGTH - height of thumbnail desciprion text box [mm]
* PADDING_HORIZONTAL - padding between columns [mm]
* PADDING_VERTICAL - padding between rows [mm]
* PADDING_TEXT_BOX - vertical padding between between a thumbnail and its description [mm]
* PADDING_HEADER - vertical padding between page header and the first row [mm]
* FONT_NAME - name of TrueType font to be used
* MIN_FONT_SIZE - font will not be scaled down below this value (text will be croped) [pixels]

TODO
====

* automatic text wrapping 
* automatic seting height of text boxes depending on film formats
* support for processing details 
* drop using exiftool, use native Python methods instead
* improve font handling to run smoothly im most common environments
