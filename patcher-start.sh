##!/usr/bin/env bash


# Get the name of the kernel. Darwin for macOS, and Linux for linux
# This gets passed to the Python script
KERNELNAME=$(uname -a | cut -d ' ' -f 1)
LINUXDISTRO=$(awk '/PRETTY_NAME/{ print $0 }' /etc/os-release | cut -c 14- | sed 's/.$//')
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
  if [ "$(curl --help | grep Usage)" != "" ]; then
    curl -fsSL "$1" > "$2"
  elif [ "$(wget -h | grep Usage)" != "" ]; then
    wget -O "$2" "$1"
  else
    Exit
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
if [ ! -f "Uranium.exe" ]; then
  if [ -f "bin/mkxp-z.exe" ]; then
  	echo -e "MKXP-Z Port Detected!"
  else
  	echo -e "${TEXT_STOP}Please run this script from inside of your Pokémon Uranium folder.\n${TEXT_NONE}"
  	Exit
  fi
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
  Exit
fi
echo "${TEXT_GO} done${TEXT_NONE}"

# Pass to Python
# Which version do I have? macOS has 2 preinstalled, Ubuntu has 3
if [ "$(python -c "print('test')")" != "" ]; then
  command="python"
elif [ "$(python3 -c "print('test')")" != "" ]; then
  command="python3"
else
  echo "${TEXT_STOP}Could not find an installation of Python.${TEXT_NONE}"
  Exit
fi
abs="$(which ${command})"
echo "Using ${command} (${abs})"
if [ "$(${abs} -m pip | grep Usage)" == "" ]; then # pip is missing
  echo "${TEXT_WARN}pip is required in order install required Python dependencies${TEXT_NONE}"
  echo "${COLOR_YELLOW}Attempting to install it now...${COLOR_NONE}"
  if [ "$KERNELNAME" == "Darwin" ]; then
    sudo ${abs} -m easy_install pip
  else 
  	if [[ "$LINUXDISTRO" == *"buntu"* ]]; then
  		echo -e "Detected ${LINUXDISTRO}"
    		sudo apt install ${command}-pip -y
    	elif [[ "$LINUXDISTRO" == *"Arch"* ]]; then
    		echo -e "Detected ${LINUXDISTRO}"
    		sudo pacman -S ${command}-pip
    	else
    		echo -e "${TEXT_STOP}Couldn't install ${command}-pip automatically - Please open an issue with a screenshot of this message!\nOS: ${LINUXDISTRO}${TEXT_NONE}"
    		Exit
    	fi
  fi
  if [ "$(${abs} -m pip | grep Usage)" == "" ]; then
    Exit
  fi
fi

# Check for future
if [ "$(${abs} -m pip freeze | grep future)" == "" ]; then
  echo "${TEXT_WARN}Attempting to install Future...${TEXT_NONE}"
  sudo -H ${abs} -m pip install future
fi

# Check for tqdm
if [ "$(${abs} -m pip freeze | grep tqdm)" == "" ]; then
  echo "${TEXT_WARN}Attempting to install TQDM...${TEXT_NONE}"
  sudo -H ${abs} -m pip install tqdm
fi

# Check for requests
if [ "$(${abs} -m pip freeze | grep requests)" == "" ]; then
  echo "${TEXT_WARN}Attempting to install Requests...${TEXT_NONE}"
  sudo -H ${abs} -m pip install requests
fi

read -p "Disabling IPv6 could improve patching speed. Disable? [y/n]: " ipv6yesno
if [ "$ipv6yesno" == "y" ] or [ "$ipv6yesno" == "yes" ] or [ "$ipv6yesno" == "Y" ] or [ "$ipv6yesno" == "Yes" ] or [ "$ipv6yesno" == "YES" ]; then
  sudo sysctl net.ipv6.conf.all.disable_ipv6=1
  echo "IPv6 has been disabled."
else
  echo "IPv6 is not disabled."
fi
$abs "${PWD}/.patcher.py" "${PWD}" "$KERNELNAME" "$BASE_URL"
Exit
