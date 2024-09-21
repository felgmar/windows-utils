import datetime
import os
import progressbar
from urllib.request import urlretrieve

program_name: str = "Chromium"
zip_file: str = "chrome-win.zip"
program_files: str | None = os.getenv("ProgramFiles")
install_directory: str | None = f"{program_files}\\The Chromium Project"
userprofile: str | None = os.getenv("USERPROFILE")

def delete_chromium() -> None:
    if os.path.exists(str(install_directory)):
        try:
            print(f"Deleting {program_name}...")
            os.removedirs(str(install_directory))
        except:
            raise
    else:
        raise IOError(f"{program_name} is not installed.")
    
    if os.path.islink(str(userprofile) + "\\Desktop\\Chromium.lnk"):
        try:
            print(f"Deleting shortcut {userprofile}\\Desktop\\Chromium.lnk...")
            os.remove(str(userprofile) + "Desktop\\Chromium.lnk")
        except:
            raise
    else:
        raise FileNotFoundError(f"Could not delete the desktop shortcut for ${program_name}.")

def download_chromium() -> None:
    class download_progress():
        def __init__(self):
            self.time: str = "{:%Y%m%d_%H%M%S}".format(datetime.datetime.now())
            self.progress_bar = None

        def __call__(self, block_number: int, block_size: int, total_size: int):
            if self.progress_bar == None:
                self.progress_bar = progressbar.ProgressBar(max_value=total_size)
                self.progress_bar.print(f"Downloading virtio-win-{args.branch}.{self.time}.iso, please wait...")
                self.progress_bar.start()
                
            bytes_recieved: int = block_number * block_size

            if bytes_recieved < total_size:
                self.progress_bar.update(bytes_recieved)
            else:
                self.progress_bar.finish()

    def get_file(url: str, filename: str):
        try:
            urlretrieve(url, filename, download_progress)
        except:
            raise
