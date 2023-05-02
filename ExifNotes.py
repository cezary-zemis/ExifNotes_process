import os, pathlib, sys, re, fnmatch, math, fractions
from PIL.ExifTags import Base

def inches(mm):
    return mm / 25.4

def read_environ(env_var_name, default=None):
    if os.environ.get(env_var_name):
        return os.environ.get(env_var_name)
    else:
        return default

def read_exif(exif_data, key_name):
    val = ''
    if Base[key_name].value in exif_data:
        val = exif_data[Base[key_name].value]
    if type(val) is bytes :
        try:
            val = val.decode()
        except UnicodeDecodeError:
            pass
    return val

def read_description(desc_str, key):
    key = '^' + re.escape(key) + ':'
    desc_l = desc_str.split('|')
    for l in range(len(desc_l)):
        desc_l[l] = desc_l[l].strip()
    desc_l = list(filter(lambda x: re.match(key, x), desc_l))
    for l in range(len(desc_l)):
        desc_l[l] = re.sub(key, '', desc_l[l]).strip()
    return desc_l
    
def findfiles(which, where='.'):
    '''Returns list of filenames from `where` path matched by 'which'
       shell pattern. Matching is case-insensitive.'''
    
    # TODO: recursive param with walk() filtering
    rule = re.compile(fnmatch.translate(which), re.IGNORECASE)
    return [name for name in os.listdir(where) if rule.match(name)]

def get_image_files():
    global extensions, path
    image_files = []
    for ext in extensions:
        image_files += [f for f in findfiles('*' + ext, path) if not re.search('contact[_-]sheet', os.path.basename(f))]
    image_files.sort()
    return image_files
    
def fraction_to_float(frac_str):
    try:
        return float(frac_str)
    except ValueError:
        num, denom = frac_str.split('/')
        try:
            leading, num = num.split(' ')
            whole = float(leading)
        except ValueError:
            whole = 0
        frac = float(num) / float(denom)
        return whole - frac if whole < 0 else whole + frac

def print_verbose(str) :
    global verbose
    if verbose :
        print(str)
        
def nice_signed_fraction(fl) :
    nsf = '+'
    if fl < 0 :
        nsf = '-'
    i = math.floor(math.fabs(fl))
    f = str(fractions.Fraction(math.fabs(fl) - i).limit_denominator(4))
    if f == '1/4' :
        f == '¼' 
    elif f == '1/3' :
        f = '⅓'
    elif f == '1/2' :
        f = '½'
    elif f == '2/3' :
        f = '⅔'
    elif f == '3/4' :
        f = '¾'
    if i == 0 and f == '0' :
        return '0'
    else :
        if i != 0 :
            nsf += str(i)
        if f != '0' :
            nsf += f
        return nsf

dry_run = read_environ('DRY_RUN')
verbose = read_environ('VERBOSE')
path = read_environ('WORKING_DIR', '.')
extensions = read_environ('EXTENSIONS', '.tif .tiff .jpg .jpeg').split(' ')
exif_notes_extension = read_environ('EXIF_NOTES_EXTENSION', '.json')
notes_separator = read_environ('NOTES_SEPARATOR', ' | ')
cs_file_name = read_environ('CS_FILE_NAME', '_contact_sheet.jpeg')
