import os
from os import path
import random

rec_size = 32  # A record is 32 bytes long. 4 for the key and 28 for the data.

page_size = 128  # how many bytes a page has.

def formatBinString(string, number_of_bits):  # adds the zeroes needed in the front of the string
    while len(string)<number_of_bits:
        string  = "0" + string
    return string

def StringToBin(string):
    return ''.join(format(ord(i), '08b') for i in string)


def binaryToChar(bin_str):
    binary = int(bin_str)
    decimal, i, n = 0, 0, 0
    while binary != 0:
        dec = binary % 10
        decimal = decimal + dec * pow(2, i)
        binary = binary // 10
        i += 1
    return chr(decimal)


def binToString(str):
    tmp_str = ""
    charSize = 8  # the size of one character in ones and zeroes
    for i in range(int(len(str)/charSize)):
        tmp_str += binaryToChar(str[i*charSize:i*charSize+charSize])
    return tmp_str


def decToBin(number, bits):  # RETURNS STRING of CHARS
    temp = int(bin(number), 2)
    return formatBinString(str("{0:b}".format(temp)), bits)


def binToDec(number):  # RETURNS INT!
    return int(decToBin(number), 2)


class FileManager:
    def __init__(self, pagesize, recsize):
        self.page_size = pagesize*8 # 8 bits per byte
        self.rec_size = recsize*8
        self.fileBuffer = ""  # size of the buffer must always be page_size(128 here)
        self.read_pos = 0  # the position in the file
        self.write_pos = 0  # 1 marks the beginning of the file
        self.numberOfPages = 0
        self.filename = ""
        self.disk_access_counter = 0

    def count(self):
        self.disk_access_counter += 1

    def diskUsage(self):
        return self.disk_access_counter

    def createFile(self, filename):
        # check if file with name filename exists in the same directory. If not, it creates it.
        self.filename = filename
        if path.exists(filename):
            print("file exists!")
            os.remove(filename)
        try:
            open(filename, "x")  # create the file
            print("new file " + str(filename) + " created.")
            return 1
        except Exception:
            print("cannot create file. Aborting")
            return 0

    def openFile(self, filename):
        # return the number of pages of the file
        self.file = open(filename, "w+")
        data = self.file.read()
        characters = len(data)
        self.numberOfPages = characters / self.page_size
        return self.numberOfPages  # return how many pages the file has.

    # Read a page(4*rec_size of bytes) of data from file, from the pos position.
    def readBlock(self, pos):
        try:
            self.file.seek(pos, 0)  # go to the location of the file pointer(pos) to start reading
            self.fileBuffer = ""
            self.fileBuffer = self.file.read(self.page_size)  # read page_size bytes from file and append it to buffer
            self.count()
            return 1
        except Exception:
            print('Could not read block with readBlock(). Exiting...')
            return 0

    # read the next block from the current pointer
    def readNextBlock(self):
        try:
            self.file.seek(self.read_pos, 0)  # go to the location of the file pointer(pos) to start reading
            self.fileBuffer = ""
            self.fileBuffer = self.file.read(self.page_size)  # read from the file and append it to the buffer
            self.read_pos += self.page_size
            self.count()
            return 1
        except Exception:
            print('Could not read block with readNextBlock(). Exiting...')
            return 0

    def writeBlock(self, pos):
        # try:
        self.file.seek(pos, 0)  # go to the location of the file pointer(pos) to start reading
        self.file.write(self.fileBuffer)
        self.write_pos += len(self.fileBuffer)
        if pos == self.page_size*self.numberOfPages:  # like an append
            self.numberOfPages += 1
        self.count()
        return 1
        # except Exception:
        #     print('Could not write block with writeBlock(). Exiting...')
        #     return 0

    def writeNextBlock(self):
        try:
            self.file.seek(self.write_pos, 0)  # go to the location of the file pointer(pos) to start reading
            self.file.read()
            self.file.write(str(self.fileBuffer))
            self.write_pos += len(self.fileBuffer)
            self.write_pos += self.page_size
            self.numberOfPages += 1
            self.count()
            return 1
        except Exception:
            print('Could not write block with writeNextBlock(). Exiting...')
            return 0

    def appendBlock(self):
        try:
            # self.writeBlock(int(self.numberOfPages)*self.page_size)  # this should be faster, but does not work.
            # temp_file = open(self.filename,"r")
            # lastchar = len(temp_file.read())  # find the length of the file
            self.writeBlock(self.write_pos)
            return 1
        except Exception:
            print('Could not write block with appendBlock(). Exiting...')
            return 0

    def deleteBlock(self, position):  # position of the first character of the block we wanna delete
        # read last page of the file on the main memory
        self.readBlock(self.numberOfPages*self.page_size-self.page_size)
        # write it on the location of the deleted block
        self.writeBlock(position)
        # delete the last page
        self.file.seek(self.numberOfPages*self.page_size-self.page_size)
        self.file.truncate()
        # decrement the numberOfPages counter
        self.numberOfPages -= 1

    def closeFile(self):
        try:
            self.file.close()
            return 1
        except Exception:
            print("closeFile() could not close the file.")
            return 0


# First Type of File organisation
# record format:
# ______________________________________________________
# | key  |              data      (28 bytes)           |  x4 in each Page
# ------------------------------------------------------

# Example Data File Generation
file1 = FileManager(page_size, rec_size)
file1.createFile("a_way.txt")
file1.openFile("a_way.txt")

data = ""
numbers = random.sample(range(10**11), 10000)
for i in range(len(numbers)):
    data = data + decToBin(i, 4*8) + decToBin(numbers[i], 28*8)
    # the second argument is to tell the function how many zeroes to add to the final
    # string to comply with thea above specifications.
    if i % 4 == 0:  # each page has 4 records. We write the buffer when it reaches the one page.
        file1.fileBuffer = data
        file1.appendBlock()
        data = ""
        file1.count()

print("FILE ACCESS COUNTER: " + str(file1.diskUsage()))



# Second Type of File organisation
# record format:
# ______________________________________________________
# | key  |              data      (28 bytes)           |  x4 in each Page
# ------------------------------------------------------
# | 0101 |       1001110101101101101011101011          |  (example)
# ------------------------------------------------------
#
# Key file(consisting of key-index pairs):
# ------------------------------------------------------
# |pair|pair|pair|pair|pair|pair|pair|pair|...x16      |
# ------------------------------------------------------
