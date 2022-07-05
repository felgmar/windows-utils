#!/bin/sh
set -e

url="$(curl -s "https://api.github.com/repos/PCSX2/pcsx2/releases" | grep "browser_download_url.*\AVX2-Qt.7z" | cut -d \" -f 4 | head -n 1)"
filename="$(echo "$url" | sed "s|.*/||")"

install()
{
    filename_folder="`echo $1 | sed 's|.7z||g'`"
    [ -d "${filename_folder}" ] && echo "The latest version is already installed" && exit 0
    echo "--> Downloading file $1..."
    curl -L $url -o $1
    echo "--> Decompressing file $1..."
    "`which 7z`" x $1 -o"$filename_folder"
    echo "--> Removing the file $1..."
    rm "$1"
    [ $? = "0" ] && \
        echo "--> The package was installed successfully." || echo "An error occurred." && exit 1
}

if [ `uname` != "MINGW64_NT-10.0-22000" ]
then
    echo "This script was only made for Windows 11 v10.0.22000"
    exit 1
fi

install $filename
