## Pokémon Uranium Shellpatcher

An alternative option to the Neoncube patcher that fails to work on
non-Windows operating systems.

Since it's partially shell script, you should make sure to give it executable permissions.
If you are unable to launch it, it's probably because you haven't done this yet.

To download the script and make it executable, open a Terminal window and type (or copy/paste):

+ For macOS
```sh
cd ~/Downloads
curl https://raw.githubusercontent.com/ssmocha/uranium-shellpatch/master/patcher-start.sh > patcher.command
sudo chmod a+x patcher.command
```

+ For Linux
```sh
cd ~/Downloads
# if you have curl
curl https://raw.githubusercontent.com/ssmocha/uranium-shellpatch/master/patcher-start.sh > patcher.sh
# if you have wget
wget -O ./patcher.sh https://raw.githubusercontent.com/ssmocha/uranium-shellpatch/master/patcher-start.sh
sudo chmod a+x patcher.sh
```

The file should then be in your Downloads folder, ready for you to place
wherever you like (as long as you only like it in the same folder as your
game).
>**Note**: for at least Ubuntu, you may have to run the script from the terminal using:
```sh
bash ./patcher.sh
```

#### Requirements

pip, python-future, requests, tqdm, and Unrar. For macOS and Ubuntu, these can be installed for you.
For other linux distributions you may have to install pip with your own package
manager.
