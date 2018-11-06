#!/usr/bin/python
# -*- coding: utf-8 -*-

# Future is needed for Python 2 compatibility
from __future__ import print_function, division, unicode_literals
from future.standard_library import install_aliases; install_aliases()
from builtins import int, bytes, str, object, range, input

import os, plistlib, re, glob, tempfile, shutil, subprocess, math
import tarfile, tqdm, requests

version="Alpha0.1"
PWD=os.sys.argv[1];KERNEL=os.sys.argv[2].lower();BASEURL=os.sys.argv[3]
pythonversion=os.sys.version[0]
# formatting
class Color:
   PURPLE = '\033[95m'
   CYAN = '\033[96m'
   DARKCYAN = '\033[36m'
   BLUE = '\033[94m'
   GREEN = '\033[92m'
   YELLOW = '\033[93m'
   RED = '\033[91m'
   BOLD = '\033[1m'
   UNDERLINE = '\033[4m'
   END = '\033[0m'

class Patchlist(object):
    __patches__ = []
    __patchnames__ = {\
    45: "(Graphics Patches)",
    51: "1.1.0",
    56: "1.2.0",
    57: "1.2.1",
    63: "1.2.2",
    64: "1.2.2 (HotfixA)",
    68: "1.2.3",
    69: "1.2.4",
    70: "1.2.4 (HotfixA)"
    }

    def __init__(self, liststr):
        for line in liststr.split('\n'):
            item = line.split('\t')
            item[0] = int(item[0])
            self.__patches__.append(item)

    def Length(self):
        return len(self.__patches__)

    def GetIDIndex(self):
        ret = []
        for i in range(len(self.__patches__)):
            ret.append(self.__patches__[i][0])
        return ret

    def GetPathIndex(self):
        ret = []
        for i in range(len(self.__patches__)):
            ret.append(self.__patches__[i][2])
        return ret

    def GetPathFromIndex(self, index):
        return self.__patches__[index][2]

    def GetIDFromIndex(self, index):
        return self.__patches__[index][0]

    def GetIndexFromID(self, ID):
        try:
            return self.GetIDIndex().index(ID)
        except:
            return None

    def GetIndexFromPath(self, path):
        try:
            return self.GetPathIndex().index(path)
        except:
            return None

    def GetPathFromID(self, ID):
        try:
            return self.GetPathFromIndex(self.GetIndexFromID(ID))
        except:
            return None

    def GetPatchName(self, ID):
        if ID in self.__patchnames__:
            return self.__patchnames__[ID]
        elif ID in self.GetIDIndex():
            return self.GetPathFromID(ID)
        else: return "Missingno"

def clear():
    _ = os.system('clear')

def Exists(path):
    if os.path.isfile(path) == True: return True
    if os.path.isdir(path) == True: return True
    return False

def Call(path, *arglist):
    tmp = [path]
    if len(arglist) > 0:
        for x in arglist:
            tmp.append(x)
    return subprocess.check_output(tmp)

def DownloadToFile(url, path):
    r = requests.get(url, stream=True)
    chunks = r.iter_content(chunk_size=1024)
    size = int(math.floor(int(r.headers['Content-length'])/1024))
    with open(path, 'wb') as f:
        for chunk in tqdm.tqdm(chunks, total=size, unit="KB"):
            if chunk:
                f.write(chunk)

def ExtractRarFile(source, dest):
    files = patoolib.list_archive(source)
    print(files)

def DownloadToString(url, encoding="utf-8"):
    r = requests.get(url)
    return r.content.decode(encoding)

def main(pwd=PWD, kernel=KERNEL, baseurl=BASEURL):
    clear()
    local=False
    if baseurl=="pwd":
        local=True
    pwd+="/"

    print(Color.GREEN+"P O K é M O N  U R A N I U M  S H E L L P A T C H E R  "+Color.END+"v"+version)
    print("by "+Color.BOLD+"mocha "+Color.END+"(@ss.Cocoa#1750) -- Python%s on %s\n" %(pythonversion, kernel))

    # Download the patchlist from the game's server
    # Not using bash so using the real one is much easier
    print("Grabbing patchlist...", end="")
    response=DownloadToString("http://pokemonuranium.org/Patches/patchlist.txt")
    patches=Patchlist(response)
    print(Color.CYAN+" done"+Color.END)

    # Guess the game's version from the neoncube file
    print("Getting current version...", end="")
    neoncubever = 0
    if Exists(pwd+"neoncube.file"):
        with open(pwd+"neoncube.file", "r") as f:
            try:
                neoncubever = int(f.read())
                print(Color.CYAN+" done"+Color.END)
            except:
                print(Color.RED+" failed, assuming < "\
                +str(patches.GetIDIndex()[0])+Color.END)
    else:
        print(Color.RED+" neoncube.file missing, assuming < "\
        +str(patches.GetIDIndex()[0])+Color.END)

    # Version checks
    print(Color.YELLOW+"\nClient version  : "+Color.END, end="")
    print(patches.GetPatchName(neoncubever))
    print(Color.YELLOW+"Req.   version  : "+Color.END, end="")
    print(patches.GetPatchName(patches.GetIDFromIndex(patches.Length()-1))+"\n")
    if neoncubever < patches.GetIDIndex()[-1]:
        requiredpatches = []
        for ID in patches.GetIDIndex():
            if ID > neoncubever and patches.GetPathFromID(ID).find(".rar") > -1: # Can't scan remote dirs yet
                requiredpatches.append(ID)
        # Since we need Unrar, check if it's installed
        if not Exists(pwd+"rar/unrar"):
            print("-------------")
            print(Color.RED+Color.BOLD+\
            "Unrar is not installed. This script requires it to continue."+Color.END)
            print(Color.RED+"Would you like to download it now? [Y\\n]: "+Color.END, end="")
            decision = input()
            if decision in ["N", "n"]:
                exit()
            if kernel == "darwin":
                fname = "rarosx-5.6.1.tar.gz"
            else:
                fname = "rarlinux-x64-5.6.1.tar.gz"
            print(Color.YELLOW+"Downloading https://www.rarlab.com/rar/"+fname+"..."+Color.END)
            DownloadToFile("https://www.rarlab.com/rar/"+fname, pwd+"rar.tar.gz")
            if not Exists(pwd+"rar.tar.gz"):
                exit()
            print(Color.YELLOW+"Extracting to rar/unrar ..."+Color.END)
            Call("tar","-xzf",pwd+"rar.tar.gz", "rar/unrar")
            if not Exists(pwd+"rar/unrar"):
                exit()
            os.remove(pwd+"rar.tar.gz")

        #start downloading updates
        print("-------------")
        tempdir = tempfile.mkdtemp()+"/"
        for ID in requiredpatches:
            print(Color.YELLOW+Color.BOLD+"Downloading update "+Color.END, end="")
            print(Color.BOLD+str(requiredpatches.index(ID)+1), end="")
            print(Color.YELLOW+"/"+Color.END, end="")
            print(Color.BOLD+str(len(requiredpatches)), end="")
            print(Color.YELLOW+" ("+patches.GetPatchName(ID)+") ..."+Color.END)

            currentfile=patches.GetPathFromID(ID)
            DownloadToFile("http://pokemonuranium.org/Patches/"+currentfile, tempdir+currentfile)
            print(Color.YELLOW+"Extracting... "+Color.END, end="")
            output = Call(pwd+"rar/unrar", "x", "-o+", tempdir+currentfile, pwd)
            if bytes(output).find(b"All OK") == -1:
                print("\n"+Color.RED+output)
                print(Color.BOLD+"Extraction failed. Stopping."+Color.END)
                exit()
            print(Color.YELLOW+"cleaning up... \n"+Color.END)
            os.remove(tempdir+currentfile)
            with open(pwd+"neoncube.file", "w") as nfile:
                nfile.seek(0)
                nfile.truncate()
                nfile.write(str(ID))

        print(Color.BOLD+"Checking for leftover files..."+Color.END)
        if Exists(pwd+".version"): # Python > Bash
            os.remove(pwd+".version")
        if Exists(pwd+".patchlist.plist"): # Python > Bash
            os.remove(pwd+".patchlist.plist")
        found = glob.glob(pwd+"*.rar")
        if len(found) > 0:
            for f in found:
                os.remove(f)
        found = glob.glob(tempdir+"*.rar")
        if len(found) > 0:
            for f in found:
                os.remove(f)
        found = glob.glob(pwd+"*.tar.gz")
        if len(found) > 0:
            for f in found:
                os.remove(f)

        shutil.rmtree(tempdir)

    print("-------------")
    print(Color.BOLD+Color.GREEN+"Your game is up to date."+Color.END)
    print(Color.GREEN+"Please make sure to check the changelog:\n"\
    +Color.UNDERLINE+"http://pokemonuranium.org/Patches/news.html"+Color.END)


main()
