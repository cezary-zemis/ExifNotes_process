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
        val = val.decode()
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

def get_image_files()
    global extensions, path
    image_files = []
    for ext in extensions:
        image_files += [f for f in findfiles('*' + ext, path) if not re.search('contact[_-]sheet', os.path.basename(f))]
    image_files.sort()
    return image_files

dry_run = read_environ('DRY_RUN')
path = read_environ('WORKING_DIR', '.')
extensions = read_environ('EXTENSIONS', '.tif .tiff .jpg .jpeg').split(' ')
exif_notes_extension = read_environ('EXIF_NOTES_EXTENSION', '.json')
notes_separator = read_environ('NOTES_SEPARATOR', ' | ')
cs_file_name = read_environ('CS_FILE_NAME', '_contact_sheet.jpeg')
