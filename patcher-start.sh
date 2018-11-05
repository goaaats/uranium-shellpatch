##!/usr/bin/env bash


# Get the name of the kernel. Darwin for macOS, and Linux for linux
# This gets passed to the Python script
KERNELNAME=$(uname -a | cut -d ' ' -f 1)
BASE_URL=raw.githubusercontent.com/ssmocha/uranium-shellpatch/master/
#BASE_URL=pwd

#formatting
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_NONE=$(tput sgr0)

FORMAT_BOLD=$(tput bold)
FORMAT_NONE=$(tput sgr0)

TEXT_STOP=${COLOR_RED}${FORMAT_BOLD}
TEXT_WARN=${COLOR_YELLOW}${FORMAT_BOLD}
TEXT_GO=${COLOR_GREEN}${FORMAT_BOLD}
TEXT_NONE=${FORMAT_NONE}${COLOR_NONE}

function DownloadToFile() # URL, file
{
  if [ "$KERNELNAME" == "Darwin" ]; then
    curl -fsSL "$1" > "$2"
  else
    wget -O "$2" "$1"
  fi
}
function DownloadToStr() # URL
{
  if [ "$KERNELNAME" == "Darwin" ]; then
    curl -fsSL $1
  else
    wget -O - $1 > /dev/null
  fi
}
function SetTitle()
{
  printf "\033]0;${1}\007"
}

function Exit()
{
  # Try to prevent window from automatically closing
  if [ "$KERNELNAME" != "Darwin" ]; then
    read -n 1 -s -r -p "Press any key to exit."
    printf "\n"
  fi
  if [ -e ".patcher.py" ]; then
    rm .patcher.py
  fi
  exit
}
# -------
cd "$(dirname "$0")" # change to working directory in case of .command
SetTitle "Pokémon Uranium Shellpatcher"

# Make sure we're running from the game's directory
if [ "$KERNELNAME" == "Darwin" ]; then
  clear
fi
if [ ! -f "Uranium.exe" ]; then
  echo "${TEXT_STOP}Please run this script from inside of your Pokémon Uranium folder.${TEXT_NONE}"
  Exit
fi

printf "Grabbing scripts"
result=""
if [ "$BASE_URL" == "pwd" ]; then
  printf " ${COLOR_RED}locally${COLOR_NONE}"
  if [ -e "patcher.py" ]; then
    cp patcher.py .patcher.py
  else
    echo "... ${TEXT_STOP}Patcher script missing.${TEXT_NONE}"
    Exit
  fi
else
  DownloadToFile "${BASE_URL}/patcher.py" "${PWD}/.patcher.py"
fi
printf "..."

if [ "$(cat "${PWD}/.patcher.py" | grep "import")" == "" ]; then
  echo " ${TEXT_STOP}Failed to download the patcher script.${TEXT_NONE}"
  rm .patcher.py
  Exit
fi
echo "${TEXT_GO} done${TEXT_NONE}"

# Pass to Python
# Python 2
if [ "$(python -c "print('test')")" != "" ]; then
  if [ "$(python -m pip | grep Usage)" == "" ]; then # pip is missing
    echo "${TEXT_WARN}pip is required in order to use Python's Future module.${TEXT_NONE}"
    echo "${COLOR_YELLOW}Attempting to install it now...${COLOR_NONE}"
    if [ "$KERNELNAME" == "Darwin" ]; then
      sudo python -m easy_install pip
    else #assuming Ubuntu
      sudo apt install python-pip
    fi
    if [ "$(python -m pip | grep Usage)" == "" ]; then
      Exit
    fi
  fi
  #check for Future
  if [ "$(python -m pip freeze | grep future)" == "" ]; then
    echo "${TEXT_WARN}Installing Future...${TEXT_NONE}"
    sudo -H python -m pip install future
  fi
  python "${PWD}/.patcher.py" "${PWD}" "$KERNELNAME" "$BASE_URL"

# Python 3
elif [ "$(python3 -c "print('test')")" != "" ]; then
  if [ "$(python3 -m pip | grep Usage)" == "" ]; then # pip is missing
    echo "${TEXT_WARN}pip is required in order to use Python's Future module.${TEXT_NONE}"
    echo "${COLOR_YELLOW}Attempting to install it now...${COLOR_NONE}"
    if [ "$KERNELNAME" == "Darwin" ]; then
      sudo python3 -m easy_install pip
    else #assuming Ubuntu
      sudo apt install python3-pip
    fi
    if [ "$(python3 -m pip | grep Usage)" == "" ]; then
      Exit
    fi
  fi
  #check for Future
  if [ "$(python3 -m pip freeze | grep future)" == "" ]; then
    echo "${TEXT_WARN}Installing Future...${TEXT_NONE}"
    sudo -H python3 -m pip install future
  fi
  python3 "${PWD}/.patcher.py" "${PWD}" "$KERNELNAME" "$BASE_URL"
else
  echo "${TEXT_STOP}Could not find a Python installation in your PATH.${TEXT_NONE}"
  echo "${COLOR_RED}Stopping.\n${COLOR_NONE}"
fi
if [ -e ".patcher.py" ]; then
  rm .patcher.py
fi
Exit
