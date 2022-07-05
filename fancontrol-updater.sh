#!/bin/sh
set -e

url="$(curl -s "https://api.github.com/repos/rem0o/FanControl.Releases/releases" | grep "browser_download_url.*\.zip" | cut -d \" -f 4 | head -n 1)"
filename="$(echo "$url" | sed "s|.*/||")"

install()
{
    filename_folder="`echo $1 | sed 's|.zip||g'`"
    if [ -d "${filename_folder}" ]
    then
        read -p "FanControl is already installed. Do you want to continue anyways? " overwrite
        case "${overwrite}" in
            Nn|NOno) rm -rfv ${folder_name};;
        esac
    fi
    echo "--> Downloading file $1..."
    curl -L $url -o $1
    echo "--> Decompressing file $1..."
    `which unzip` -u $1 -d ${filename_folder}
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
