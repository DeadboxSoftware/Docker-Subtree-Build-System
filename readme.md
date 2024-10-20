# Docker Subtree Build System

## Quick Setup 

- Install requirements.txt file `pip install -r requirements.txt`
- Set applications as dependencies inside `subtree.sh`
- Pull all dependencies with => `subtree.sh pull_all` 
- Setup project `docker.sh setup` & select or modify `templates/map.json`

## Subtree.sh

```
Commands:
* push => (args: <repo_name>)
* pull => (args: <repo_name>)
* add => (args: <repo_name>)
* pull_all => pulls all repos except ignored with !repo_name
* push_all => push all repos except ignored with !repo_name
* add_all => TBD
```

## Docker.sh

```
Essential Commands:
* setup => Primary setup script
* restore => Restore Database files
* backup => Backup current database files
* certs => Generates certs in `/certs` directory
--------
Docker:
* compose => Use a different docker compose file
--------
Build Options:
* build 
* build_nocache => Builds with nocache
* build_network => Builds docker network
--------
Config Options:
* build_configs => Builds all template files
* env => Builds out env files
* folder_perms => Changes folder permissions to correct docker perms
--------
Database:
* update_seq => Updates sequence on all database tables
-------- 
Misc:
* update_sql_pword => Updates sql password to stored env pword
* clean => Cleans all project files from setup
* entrypoint_fix => For windows systems change entrypoints so it works on linux
```

## Configure subtree's

```
# Change the below folders to repos you would like to use 

declare -a folders=(
	"nodeapp/app"
	"ignorethis/app"
)

declare -a repo=(
	"git@github.com/Backshift/Node-App-Toolset.git"
	"git@github.com/Backshift/Node-App-Toolset.git"
)

declare -a branch=(
	"main"
	"main"
)

declare -a names=(
	"nodeapp"
	"!ignorethis" # ! => to not include repo
)

```
