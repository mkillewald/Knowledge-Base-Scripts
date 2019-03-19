#!/bin/bash

# Build your directory structure here
mkdir -p Infrastructure/{Red,Blue}
mkdir -p Recon/{Network,OSINT,Web}
mkdir -p Controls/{Windows,Linux,macOS}
mkdir -p Network_Infrastructure/{Routing_and_Switching,Wireless,Network_Storage}
mkdir -p Post-Exploitation/{AWS,Azure,Linux,macOS,Windows}/{C2,Collection,Credential_Access,Defense_Evasion,Discovery,Execution,Exfiltration,Lateral_Movement,Persistence,Privilege_Escalation}

# Filename of index files to generate
index_filename="index.md"

######## do not change anything below this line ##########

echo "Knowledge Base Initialization Script v0.1"

quiet=0
overwrite=0

for arg in "$@"; do
  case $arg in
    '-q'|'--quiet')
      quiet=1;;
    '-o'|'--overwrite')
      overwrite=1;;
    '-h'|'--help'|*)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -h, --help        display this help message"
      echo "  -o, --overwrite   overwrite all $index_filename files (existing data will be lost)"
      echo "  -q, --quiet       reduce display verbosity"
      exit 0;;
  esac
done

base_path=$PWD
echo "Base path: $base_path" 
echo ""

function build_breadcrumb() {
  breadcrumb=""
  root="$(basename "$base_path")"
  IFS='/' read -ra ADDR <<< "$root$1"
  count=$((${#ADDR[@]} - 1))
  for i in "${ADDR[@]}"; do
    link=""
    parent="../"
    for j in $(seq 1 $count); do
      if [ $count -lt 1 ]; then
        link="./"
      else  
        link="$link$parent"
      fi
    done
    count=$(($count-1))
    breadcrumb+="[${i//_/ }]($link$index_filename)/"
  done
}

function create_index() {
  if [ $quiet -ne 1 ]; then echo "Creating file: $1/$index_filename"; fi
  if [ -e $index_filename ] && [ $overwrite -ne 1 ]; then
    while true; do
      if [ $quiet -eq 1 ]; then echo "Creating file: $1/$index_filename"; fi
      read -p "File exists, Overwrite? [Y]es, [N]o, [O]verwrite All, [E]xit? [N]: " answer </dev/tty
      case $answer in
        [Yy]* ) 
          # break loop, continue on, overwrite file
          if [ $quiet -ne 1 ]; then echo "Overwriting: $1/$index_filename"; fi
          echo ""
          break;; 
        [Nn]* )
          # return from function, skip file
          if [ $quiet -ne 1 ]; then echo "Skipping: $1/$index_filename"; fi
          echo ""
          return;;
        [Oo]* )
          # set overwrite=1, break loop, continue on, overwrite all files from this point on 
          echo ""
          overwrite=1
          break;; 
        [Ee]* )
          # exit script
          echo ""
          exit 1;;
        ?* ) ;; #invalid entry, stay in loop.
        * )
          # default action, return from function, skip file
          if [ $quiet -ne 1 ]; then echo "Skipping: $1/$index_filename"; fi
          echo ""
          return;; 
      esac
    done
  fi
  build_breadcrumb ${1/./}
  echo "## $breadcrumb" > $index_filename
  echo "" >> $index_filename
  for i in $(ls -l | grep '^d' | awk '{print $9}'); do
    echo "- [${i//_/ }](./$i/$index_filename)" >> $index_filename
  done
}

find . -type d -not -path '*/\.*' -print0 | while IFS= read -r -d '' file_path; do 
  cd "$base_path${file_path/./}" && create_index $file_path
done

exitcode=$?
if [ $exitcode -ne 0 ]; then 
  echo "Aborting."
  exit $exitcode
fi

echo "Initialization complete."
exit 0