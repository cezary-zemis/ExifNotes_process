#!/bin/bash

: ${EXTENSION:=".tif"}
: ${EXIF_NOTES_EXTENSION:="_csv.txt"}
MAKES="\
L. & A. Boulade frères - Lyon
Emil Busch A.-G. Rathenow
Jos. Schneider & Co"
unset unsafe
[ -z "$SAFE" ] && unsafe=y

function make() {
    local match
    while read ; do 
	if fgrep "$REPLY" <<< "$1" >&/dev/null ; then
	    match="$REPLY"
	    break
	fi
    done <<< "$MAKES"
    if [ -n "$match" ] ; then
	echo "$match"
    else
	cut -d ' ' -f 1 <<< "$1"
    fi
}

function model() {
    local match
    while read ; do 
	if fgrep "$REPLY" <<< "$1" >&/dev/null ; then
	    match="$REPLY"
	    break
	fi
    done <<< "$MAKES"
    if [ -n "$match" ] ; then
	replace "$match " "" <<< "$1"
    else
	cut -d ' ' -f 2- <<< "$1"
    fi
}

function gps_latitude() {
    sed 's/\([NS]\).*/\1/' <<< "$1"
}

function gps_longtitude() {
    sed 's/[^NS].*[NS] //' <<< "$1"
}

function gps_value() {
    sed s/[NSWE\"°\']//g <<< "$1"
}

function gps_ref() {
    sed 's/[^NSWE]//g' <<< "$1"
}


image_files=( `ls *$EXTENSION 2>/dev/null` ) || { echo "No images found, pattern *$EXTENSION" >&2 ; exit 1; }
exif_notes_file=$(ls *$EXIF_NOTES_EXTENSION 2>/dev/null) || { echo "No Exiv Notes CSV file found, pattern *$EXIF_NOTES_EXTENSION" >&2 ; exit 1 ; }
[ $(wc -l <<< "$exif_notes_file") -eq 1 ] || { echo "Found more than one Exiv Notes CSV file: $exif_notes_csv" >&2 ; exit 1 ; }
exif_notes_entries=$(sed -e '1,/^Frame Count,/ d' < "$exif_notes_file" )
[ $(wc -l <<< "$exif_notes_entries") -eq ${#image_files[*]} ] || { echo "Number of entries in Exiv Notes CSV file does not match number on *.$EXTENSION files" >&2 ; exit 1 ; }
exif_notes_header=$(sed -n '/Frame Count,/q;p' < "$exif_notes_file")

film_stock=$(grep '^Film stock: ' <<< "$exif_notes_header" | sed 's/^[^:]*: //')
camera=$(grep '^Camera: ' <<< "$exif_notes_header" | sed 's/^[^:]*: //')
camera_make=$(make "$camera")
camera_model=$(model "$camera")
camara_serial=$(grep '^Serial number: ' <<< "$exif_notes_header" | sed 's/^[^:]*: //')
artist=$(grep '^Artist name: ' <<< "$exif_notes_header" | sed 's/^[^:]*: //')
copyright=$(grep '^Copyright: ' <<< "$exif_notes_header" | sed 's/^[^:]*: //')
iso=$(grep '^ISO: ' <<< "$exif_notes_header" | sed 's/^[^:]*: //')
film_stock=$(grep '^Film stock: ' <<< "$exif_notes_header" | sed 's/^[^:]*: //')
roll_notes=$(grep '^Notes: ' <<< "$exif_notes_header" | sed 's/^[^:]*: //')

frame_number=0
while IFS=',' read frame date lens lens_serial_number shutter aperture focal_length exposure_compensation frame_notes no_of_exposures filter location address flash light_source ; do
    date=$(sed 's/-/:/g' <<< "$date")
    lens_make=$(make "$lens")
    lens_model=$(model "$lens")
    shutter=$(sed 's/"//' <<< "$shutter")
    aperture=$(sed 's/^f//' <<< "$aperture")
    gps_latitude_value=$(gps_value "$(gps_latitude "$location")")
    gps_latitude_ref=$(gps_ref "$(gps_latitude "$location")")
    gps_longtitude_value=$(gps_value "$(gps_longtitude "$location")")
    gps_logntitude_ref=$(gps_ref "$(gps_longtitude "$location")")
    notes="Film: $film_stock"
    [ -n "$filter" ] && notes="${notes}; Filter: $filter"
    ${DRYRUN:+echo} exiftool \
	${unsafe:+"-overwrite_original"} \
	${unsafe:+"-ignoreMinorErrors"} \
	${camera_make:+"-Make=$camera_make"} \
	${camera_model:+"-Model=$camera_model"} \
	${lens_make:+"-LensMake=$lens_make"} \
	${lens_model:+"-LensModel=$lens_model"} \
	${lens:+"-Lens=$lens"} \
	${lens_serial_number:+"-LensSerialNumber=$lens_serial_number"} \
	${date:+"-DateTime=$date"} \
	${date:+"-DateTimeOriginal=$date"} \
	${shutter:+"-ShutterSpeedValue=$shutter"} \
	${shutter:+"-ExposureTime=$shutter"} \
	${aperture:+"-ApertureValue=$aperture"} \
	${aperture:+"-FNumber=$aperture"} \
	${gps_latitude_value:+"-GPSLatitude=$gps_latitude_value"} \
	${gps_latitude_ref:+"-GPSLatitudeRef=$gps_latitude_ref"} \
	${gps_longtitude_value:+"-GPSLongitude=$gps_longtitude_value"} \
	${gps_logntitude_ref:+"-GPSLongitudeRef=$gps_logntitude_ref"} \
	${exposure_compensation:+"-ExposureCompensation=$exposure_compensation"} \
	${focal_length:+"-FocalLength=$focal_length"} \
	${iso:+"-ISO=$iso"} \
	${artist:+"-Artist=$artist"} \
	${copyright:+"-Copyright=$copyright"} \
	${notes:+"-ImageDescription=$notes"} \
	"${image_files[$frame_number]}"
    : $(( frame_number++ ))
done <<< "$exif_notes_entries[@]"
