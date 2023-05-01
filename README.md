Concept
===========

There are the following tools here: 
* ExifNotes - reads a JSON file exported from ExifNotes app and applies EXIF tags to image files
* contact-sheet - reads EXIF tags from images and creates a contact sheet file

Installation
============

No installation automatization is provided. I prefere the following way:
* create a repos directory somewhere
* clone ExifNotoes_process into re directory
* symlink executables (ExifNotes and contact-sheet) to a directory that is in your PATH, e.g. ~/bin or /usr/local/bin

Usage
=====

ExifNotes
---------

1. record shooting data (exposure, GPS, camera, lens, film) using ExifNotes app (https://play.google.com/store/apps/details?id=com.tommihirvonen.exifnotes)
1. develop your film and scan it
* there should be separate directory for each roll or batch of sheet films
* files must be namaed the way that sorts properly
* you can put an empty image in place of a failed take (important for a contact sheet)
* the number of images must match number of frames you recorded in the app
1. export roll data from ExifNotes app in JSON format into the directory
1. run ExifNotes script in the directory - it will apply EXIF tags to the images

contact-sheet
-------------

* put a set of images taken on one roll or batch in its own directory
* make sure the images contain EXIF tags
* run contact-sheet in the directory; it requires one or two parameters:
** one parameter - pre-defined frame format: 135, 645, 66, 67, 69, 45, 57, 810; it is used only to set numner of columns and rows
** two parameters - number of columns and rows

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
* 