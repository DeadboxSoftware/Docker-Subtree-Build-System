import argparse
import sys
from jinja2 import Environment, FileSystemLoader, select_autoescape
import os
import json

parser = argparse.ArgumentParser(add_help=False)


# ===== SET POSITIONAL ARGUMENT
class MyAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):

        # Set optional arguments to True or False
        if option_string:
            attr = True if values else False
            setattr(namespace, self.dest, attr)

        # Modify value of "command" in the namespace
        if hasattr(namespace, 'command'):
            current_values = getattr(namespace, 'command')
            try:
                current_values.extend(values)
            except AttributeError:
                current_values = values
            finally:
                setattr(namespace, 'command', current_values)
        else:
            setattr(namespace, 'command', values)


# https://stackoverflow.com/a/31347222
parser.add_argument('command', nargs='+', action=MyAction)
parser.add_argument('--fresh', dest='fresh', action='store_true', required=False)
parser.add_argument('--latest', dest='latest', action='store_true', required=False)
parser.add_argument('--db', dest='db', action='store', nargs='?', required=False)
parser.add_argument('--no', dest='migration_no', action='store_true', required=False)
parser.add_argument('--table', dest='table', nargs='+', default=[], required=False)
parser.add_argument('-h', dest='help', action='store_true', required=False)

args = parser.parse_args()

def generate_random_hex_string(length):
    import string
    import random
    # Generate a random string with hex digits (0-9, a-f)
    hex_digits = string.hexdigits.lower()[:16]  # '0123456789abcdef'
    return ''.join(random.choice(hex_digits) for _ in range(length))

def generate_random_base64_string(byte_length):
    import base64
    # Generate random bytes and encode them to a Base64 string
    random_bytes = os.urandom(byte_length)
    return base64.b64encode(random_bytes).decode('utf-8')

def loads_json(file):
    with open(file) as user_file:
        file_contents = user_file.read()
    return json.loads(file_contents)

def home_path(p=None):
    import pathlib
    home_path = pathlib.Path(__file__).parent.parent.resolve()
    if p != None:
        return str(home_path)+f'/{p}'
    else:
        return str(home_path)

def render_template(template, glob={}):
    import random
    loader = FileSystemLoader(home_path())
    env = Environment(
    	loader=loader,
    	autoescape=select_autoescape()
    )
    env.globals.update(glob)
    env.globals['random64'] = generate_random_base64_string
    env.globals['randomstr'] = generate_random_hex_string
    template=env.get_template(template)
    return template.render()

def env_input(keys):
    input_str = 'What environment are you using:\n'
    keys_map = []
    selected_input = 0
    i = 0
    for k in keys:
        keys_map.append(k)
        input_str+=f'* [{i}] {k}\n'
        i+=1
    selected_input = input(input_str) or 0
    return keys_map[int(selected_input)]

def replace_file_dest(map, template):
    fname = home_path(map['template_destination'])

    # Ensure the directory exists
    directory = os.path.dirname(fname)
    if not os.path.exists(directory):
        os.makedirs(directory)

    # Remove the file if it already exists
    if os.path.isfile(fname):
        os.remove(fname)
    
    # Open the file in write mode and write the template
    with open(fname, 'w+') as file:
        file.write(template)


def run_cmd(command):
    import subprocess
    try:
        subprocess.run(command, check=True)
    except FileNotFoundError:
        print("Executable not found. Check the path.")
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {e}")


def copy_folder(source_folder, destination_folder):
    import shutil
    try:
        if os.path.exists(destination_folder):
            print(f"Destination folder '{destination_folder}' already exists. No need to copy.")
            return
        shutil.copytree(source_folder, destination_folder)
        print(f"Folder '{source_folder}' successfully copied to '{destination_folder}'.")
    except shutil.Error as e:
        print(f"Error: {e}")
    except OSError as e:
        print(f"Error: {e}")



def get_template_data(env_name='', specific_files=False, container_files=False, env={}):
    data = get_map()
    environments = data['environments']
    if env_name == '':
        # IF THE CORE SUBPROCESS IS CALLED
        # THIS WILL THEN PROMPT FOR AN INPUT FOR THE 
        # SELECTED ENVIRONMENT AND SELECT THE CORE_MODULES
        # AS THE FIRST SET OF TEMPLATES TO BE RENDERED
        template_map = data['CORE_MODULES']
        environments_keys = environments.keys()
        environment = env_input(environments_keys)
    else:
        template_map = []
        environment = env_name
    current=environments[environment]
    # Use ENV Specific files
    if specific_files:
        env_specific_files = data["ENVMap"][environment]
        if environment in data["ENVMap"]:
            template_map.extend(env_specific_files)
    # Container files
    if container_files:
        for c in current['containers']:
            template_map.extend(data['containers'][c])
    return {"template_map": template_map, "environments": environments, "current": current, "name": environment}


def get_container_data(env={}):
    data = get_map()
    containers = data['containers']
    current_map = data['environments'][env['ENV_NAME']]['containers']
    template_map = []
    for k in containers:
        print(f"k: {k}")
        if k in current_map:
            template_map.extend(containers[k])
    return {"template_map": template_map}


def set_globs(current, extra={}, env=None):
    glob = current['glob']
    print(glob)
    glob['portmap'] = current['portmap']
    glob.update(extra)
    if env != None:
        glob.update(env)
    return glob

def setup_containers(containers):
    for cont in containers:
        copy_folder(home_path(f"templates/containers/{cont}"), home_path(cont))


def render_templates(template_map, glob):
    for template in template_map:
        rendered_template = render_template(template['template_path'], glob)
        replace_file_dest(template, rendered_template)
    return

def clean_templates(template_map):
    for template in template_map:
        fname=home_path(template['template_destination'])
        if os.path.isfile(fname):
            os.remove(fname)   
    return

def get_env_name():
    dotenv_path = home_path('.env')
    with open(dotenv_path) as f:
        for line in f:
            if line.strip() and not line.startswith("#"):
                key, value = line.strip().split("=", 1)
                os.environ[key] = value
    env_name = os.getenv('ENV_NAME')
    return env_name

def env_to_dict(env_path='.env'):
    from dotenv import load_dotenv
    load_dotenv(dotenv_path=env_path)
    env_dict = {key: os.getenv(key) for key in os.environ if key in os.environ}
    return env_dict

def get_map():
    template_map_path = home_path('templates/map.json')
    data = loads_json(template_map_path)
    return data

def init():
    if args.command == ["core"]:
        data = get_template_data()
        glob = set_globs(data['current'], {"env_name": data["name"]})
        print("===== CORE")
        print(data)
        render_templates(data['template_map'], glob)
    elif args.command == ["containers"]:
        data = get_template_data(get_env_name())
        map_ = get_map()
        env_name = get_env_name()
        env = env_to_dict()
        glob = map_['environments'][env_name]
        data = get_container_data(env=env)
        print(f"=== template data")
        render_templates(data['template_map'], glob)
    elif args.command == ["subtrees"]:
        print("Subtrees")
        run_cmd(['bash', './subtree.sh', "pull_all"])
    elif args.command == ["secondary"]:
        data = get_template_data(get_env_name(), True, True, env=env_to_dict())
        glob = set_globs(data['current'], {"env_name": data["name"]}, env=env_to_dict())
        print("===== SECOND")
        print(data)
        render_templates(data['template_map'], glob)
    elif args.command == ["clean"]:
        # I NEED ALL TEMPLATES MINUS CONTAINERS NOT BEING USED
        # THEN PASS TO CLEAN TEMPLATES as ARR[]
        env = env_to_dict()
        env_name = env["ENV_NAME"]
        template_map = get_map()
        templates = []
        env_containers = template_map["environments"][env_name]["containers"]
        for k in template_map["containers"]:
            if k in env_containers:
                templates.extend(template_map["containers"][k])
        templates.extend(template_map["ENVMap"][env_name])
        clean_templates(templates)
    elif args.command == ["testing"]:
        print(generate_random_hex_string(32))
init()