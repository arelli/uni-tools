
@ECHO OFF
:: Check for Python Installation
ECHO You need to have python 3.x Installed.. See https://www.python.org/downloads/ for more.
python --version 3>NUL
if errorlevel 1 goto errorNoPython

:: Reaching here means Python is installed.
ECHO All the .jpg files in the same folder will be converted and saved to the new folder.
ECHO Python is installed. Proceeding..
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade Pillow
:: Create the python script
echo from PIL import Image >> invert_auto.py
echo import os  # to create the directory if it does not exist >> invert_auto.py
echo import PIL.ImageOps  # to invert the image >> invert_auto.py
echo import glob  # to get a list of files >> invert_auto.py
echo list_of_files = glob.glob("*.jpg") >> invert_auto.py
echo dirName = 'InvertedPlots' >> invert_auto.py
echo try: >> invert_auto.py
echo 	os.mkdir(dirName) >> invert_auto.py
echo 	print("Directory " , dirName ,  " Created ")  >> invert_auto.py
echo except FileExistsError: >> invert_auto.py
echo 	print("Directory " , dirName ,  " already exists") >> invert_auto.py
echo for image_file in list_of_files: >> invert_auto.py
echo 	image = Image.open(image_file) >> invert_auto.py
echo 	inverted_image = PIL.ImageOps.invert(image) >> invert_auto.py
echo 	inverted_image.save('C:/Users/Raf/Desktop/Σχολή/2021 εαρινό/Συστήματα ΕΛέγχου/plots_images/InvertedPlots/INV' + image_file) >> invert_auto.py
:: Delete the python file
python invert_auto.py
print("converted images and saved them in " + str(dirName) + 'directory.')
DEL invert_auto.py
PAUSE

:errorNoPython
echo Try to install Python 3.x
echo Go to python.org/downloads for more.

PAUSE