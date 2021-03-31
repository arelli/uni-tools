import os
from os import path
import binascii

rec_size = 32  # A record is 32 bytes long. 4 for the key and 28 for the data.

# how many bytes a page has.
page_size = 5

file_pointer = 0


def charToBinary(string):
    # return ''.join(format(ord(i), '08b') for i in string)
    data_a2b = binascii.a2b_uu(string)
    return data_a2b


def BinaryToDecimal(binary):
    decimal, i, n = 0, 0, 0
    while binary != 0:
        dec = binary % 10
        decimal = decimal + dec * pow(2, i)
        binary = binary // 10
        i += 1
    return decimal


def binarytoChar(bin_data):
    # str_data =' '
    # # slicing the input and converting it
    # # in decimal and then converting it in string
    # for i in range(0, len(bin_data), 7):
    # 	temp_data = int(bin_data[i:i + 7])
    # 	decimal_data = BinaryToDecimal(temp_data)
    # 	str_data = str_data + chr(decimal_data)
    # return str_data
    data_b2a = binascii.b2a_uu(bin_data)
    return data_b2a


class FileManager:
    def __init__(self, pagesize, recsize):
        self.page_size = pagesize
        self.rec_size = recsize
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
        numberOfPages = characters / page_size
        self.numberOfPages = numberOfPages
        return numberOfPages  # return how many pages the file has.

    # Read a page(4*rec_size of bytes) of data from file, from the pos position.
    def readBlock(self, pos):
        try:
            self.file.seek(pos, 0)  # go to the location of the file pointer(pos) to start reading
            self.fileBuffer = ""
            self.fileBuffer = self.file.read(page_size)  # read page_size bytes from file and append it to buffer
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
            self.read_pos += page_size
            self.count()
            return 1
        except Exception:
            print('Could not read block with readNextBlock(). Exiting...')
            return 0

    def writeBlock(self, pos):
        try:
            self.file.seek(pos, 0)  # go to the location of the file pointer(pos) to start reading
            self.file.write(self.fileBuffer)
            if pos == page_size*self.numberOfPages:  # like an append
                self.numberOfPages += 1
            self.count()
            return 1
        except Exception:
            print('Could not write block with writeBlock(). Exiting...')
            return 0

    def writeNextBlock(self):
        try:
            self.file.seek(self.write_pos, 0)  # go to the location of the file pointer(pos) to start reading
            self.file.read()
            self.file.write(str(self.fileBuffer))
            self.write_pos += page_size
            self.numberOfPages += 1
            self.count()
            return 1
        except Exception:
            print('Could not write block with writeNextBlock(). Exiting...')
            return 0

    def appendBlock(self):
        try:
            self.writeBlock(self.numberOfPages*page_size)
        except Exception:
            print('Could not write block with appendtBlock(). Exiting...')
            return 0

    def deleteBlock(self, position):  # position of the first character of the block we wanna delete
        # read last page of the file on the main memory(seems ok!)
        self.readBlock(self.numberOfPages*self.page_size-self.page_size)
        # write it on the location of the deleted block (wtf u not workin)
        self.writeBlock(position)
        #delete the last page(seems ok for now)
        self.file.seek(self.numberOfPages*self.page_size-self.page_size)
        self.file.truncate()
        # decrement the numberOfPages counter(certainly ok)
        self.numberOfPages -= 1

    def closeFile(self):
        try:
            self.file.close()
            return 1
        except Exception:
            print("closeFile() could not close the file.")
            return 0


file1 = FileManager(page_size, rec_size)
testtext = "test.txt"

# test the functions.
file1.createFile(testtext)
file1.openFile(testtext)

file1.fileBuffer = "AZTE,"
file1.writeNextBlock()
file1.fileBuffer = "KARM,"
file1.writeNextBlock()
file1.fileBuffer = "PENC,"
file1.writeNextBlock()

file1.readNextBlock()
print(file1.fileBuffer)

file1.readBlock(5)
print(file1.fileBuffer)

file1.readBlock(10)
print(file1.fileBuffer)

file1.readNextBlock()
print(file1.fileBuffer)

file1.fileBuffer = "TEST,"
file1.writeBlock(10)

print(file1.diskUsage())

file1.fileBuffer = "1111,"
file1.appendBlock()

file1.fileBuffer = "2222,"
file1.appendBlock()

file1.deleteBlock(5)
# file1.fileBuffer = "STAR,"
# file1.writeBlock(0)

file1.closeFile()


# all the above functions are working properly.
