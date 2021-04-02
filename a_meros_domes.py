import os
from os import path
import random

rec_size = 32  # A record is 32 bytes long. 4 for the key and 28 for the data.

page_size = 128  # how many bytes a page has.

def formatBinString(string, number_of_bits):  # adds the zeroes needed in the front of the string
    while len(string)<number_of_bits:
        string  = "0" + string
    return string

# takes an INT and outputs a STRING. Bits define the leading zeroes
def decToBin(number, bits):
    temp = int(bin(number), 2)import os
from os import path
import random

rec_size = 32  # A record is 32 bytes long. 4 for the key and 28 for the data.

page_size = 128  # how many bytes a page has.

def formatBinString(string, number_of_bits):  # adds the zeroes needed in the front of the string
    while len(string)<number_of_bits:
        string  = "0" + string
    return string

# takes an INT and outputs a STRING. Bits define the leading zeroes
def decToBin(number, bits):
    temp = int(bin(number), 2)
    return formatBinString(str("{0:b}".format(temp)), bits)


def binToDec(number):  # RETURNS INT!
    return int(number, 2)


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

    def openFile(self, filename, mode):
        # return the number of pages of the file
        self.file = open(filename, mode)
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

# key is a decimal integer we look for
def serialSearch(fileName,key):
    print("Began Serial Search")
    page_number = 0
    record_number = 0
    notFound = True
    tempFile = FileManager(page_size,rec_size)
    tempFile.openFile(fileName,"r")  # open in read mode and not write mode, to avoid truncating the file!
    tempFile.readBlock(0)  # read the first block
    tmpKey = tempFile.fileBuffer[0:32]  # tmpKey is a string!
    tempFile.fileBuffer = tempFile.fileBuffer[256:]  # *********************ADDED
    if tmpKey != decToBin(key,32):
        while notFound:
            for i in range(4):  # search in a page
                record_number +=1
                tmpKey = tempFile.fileBuffer[0:32]
                tempFile.fileBuffer = tempFile.fileBuffer[256:]
                if tmpKey == decToBin(key, 32):
                    notFound = False
                    print("Key found in position " + tmpKey + ", at page No " + str(page_number) + ", rec " + str(record_number))
                    return tempFile.diskUsage()
            record_number = 0
            page_number += 1
            if tempFile.readNextBlock() == 0:
                print("key not found")
                return 0
    else:
        print("Key found in position " + tmpKey)
        return tempFile.diskUsage()

def serialSearchKey(keysFileName, dataFileName, key):
    print("Began Serial Search on The key File")
    page_number = 0
    record_number = 0
    keyBitSize = 32
    notFound = True
    tempFileKeys = FileManager(page_size,rec_size)
    tempFileKeys.openFile(keysFileName,"r")  # open in read mode and not write mode, to avoid truncating the file!
    tempFileKeys.readBlock(page_size)  # read the first block
    tmpKey = tempFileKeys.fileBuffer[0:keyBitSize]  # tmpKey is a string!
    if tmpKey != decToBin(key,keyBitSize):
        while notFound:
            for i in range(int((page_size*8)/keyBitSize)):  # search in a page
                record_number +=1
                tmpKey = tempFileKeys.fileBuffer[keyBitSize:2*keyBitSize]  # the key is the second stored value, [32:64]
                tempFileKeys.fileBuffer = tempFileKeys.fileBuffer[2*keyBitSize:]
                if tmpKey == decToBin(key, keyBitSize):
                    tempFileData = FileManager(page_size, rec_size)
                    tempFileData.openFile(dataFileName, "r")
                    tempFileData.readBlock(tempFileData.page_size*page_number)
                    foundBlock = tempFileData.fileBuffer
                    tempFileData.closeFile()
                    tempFileKeys.closeFile()
                    tmpKey = foundBlock[0:32]
                    foundBlock = foundBlock[256:]
                    if tmpKey != decToBin(key, keyBitSize):
                        for i in range(4):
                            if tmpKey == decToBin(key, 32):
                                notFound = False
                                print("Key found in position " + tmpKey + ", at page No " + str(
                                    page_number) + ", rec " + str(record_number))
                                return tempFileKeys.diskUsage() + tempFileData.diskUsage()
                            tmpKey = foundBlock[0:32]
                            foundBlock = foundBlock[256:]
                    else:
                        print("Key found in position " + tmpKey)
                        return tempFileKeys.diskUsage()
                    # notFound = False
                    # print("Key found in position " + tmpKey + ", at page No " + str(page_number) + ", rec " + str(record_number))
                    # return tempFileKeys.diskUsage()
            record_number = 0
            page_number += 1
            if tempFileKeys.readNextBlock() == 0:
                print("key not found")
                return 0
    else:
        print("Key found in position " + tmpKey)
        return tempFileKeys.diskUsage()

# def serialSearchKeyFile(keyFileName,dataFileName,key):
#     notFound = True
#     keysPerPage = 16
#     keyBitLength = 32
#     page_number = 0
#     record_number = 0
#     tempFileKeys = FileManager(page_size,rec_size)
#     tempFileKeys.openFile(keyFileName,"r")  # open in read mode and not write mode, to avoid truncating the file!
#     tempFileKeys.readBlock(page_size)  # read the first block
#     tmpKey = tempFileKeys.fileBuffer[0:keyBitLength]  # tmpKey is a string!
#     if tmpKey != decToBin(key,keyBitLength):
#         while notFound:
#             for i in range(keysPerPage):  # search in a page
#                 record_number +=1
#                 tmpKey = tempFileKeys.fileBuffer[0:keyBitLength]
#                 tempFileKeys.fileBuffer = tempFileKeys.fileBuffer[keyBitLength:]
#                 if tmpKey == decToBin(key, keyBitLength):
#                     notFound = False
#                     print("Key found in position " + tmpKey + ", at page No " + str(page_number) + ", rec " + str(record_number))
#                     return tempFileKeys.diskUsage()
#             record_number = 0
#             page_number += 1
#             if tempFileKeys.readNextBlock() == 0:
#                 print("key not found")
#                 return 0
#     else:
#         print("Key found in position " + tmpKey)
#         return tempFileKeys.diskUsage()

# First Type of File organisation
# record format:
# ______________________________________________________
# | key  |              data      (28 bytes)           |  x4 in each Page
# ------------------------------------------------------

# Example Data File Generation
file1 = FileManager(page_size, rec_size)
file1.createFile("a_way.txt")
file1.openFile("a_way.txt","w+")

dataA = ""
numbers = random.sample(range(10**6), 100000)
for i in range(len(numbers)):
    dataA = dataA + decToBin(i, 4*8) + decToBin(numbers[i], 28*8)
    # the second argument is to tell the function how many zeroes to add to the final
    # string to comply with thea above specifications.
    if i % 4 == 0:  # each page has 4 records. We write the buffer when it reaches the one page.
        file1.fileBuffer = dataA
        file1.appendBlock()
        dataA = ""
        file1.count()

dataASearch = [random.choice(dataA) for i in range(10) ]  # the data we will search for
dataA = []  # free the space of the huge list
file1.closeFile()

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

file2 = FileManager(page_size, rec_size)
file2.createFile("b_way.txt")
file2.openFile("b_way.txt","w+")
file3 = FileManager(4*8, 4*8)
file3.createFile("b_way_keys.txt")
file3.openFile("b_way_keys.txt","w+")

dataB = ""
keys = ""
numbers = random.sample(range(10**6), 100000)
for i in range(len(numbers)):
    dataB = dataB + decToBin(i, 4*8) + decToBin(numbers[i], 28*8)
    keys = keys + decToBin(i,4*8) + decToBin(int(i/4),4*8)
    if i % 4 == 0 and i != 0:
        file2.fileBuffer = dataB
        file2.appendBlock()
        dataB = ""
        file2.count()
    if i%16 == 0 and i != 0:
        file3.fileBuffer = keys
        file3.appendBlock()
        file3.count()
        keys = ""
dataBSearch = [random.choice(dataB) for i in range(10) ]  # the data we will search for
dataB = []  # free the space of the huge list

file2.closeFile()
file3.closeFile()


# Searches:
# print("The total number of disk access(es) is: ", str(serialSearch("a_way.txt",1)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 1)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 10)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 11)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 12)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 13)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 14)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 15)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 16)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 17)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt", "b_way.txt", 18)))

    return formatBinString(str("{0:b}".format(temp)), bits)


def binToDec(number):  # RETURNS INT!
    return int(number, 2)


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

    def openFile(self, filename, mode):
        # return the number of pages of the file
        self.file = open(filename, mode)
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

# key is a decimal integer we look for
def serialSearch(fileName,key):
    print("Began Serial Search")
    page_number = 0
    record_number = 0
    notFound = True
    tempFile = FileManager(page_size,rec_size)
    tempFile.openFile(fileName,"r")  # open in read mode and not write mode, to avoid truncating the file!
    tempFile.readBlock(page_size)  # read the first block
    tmpKey = tempFile.fileBuffer[0:32]  # tmpKey is a string!
    if tmpKey != decToBin(key,32):
        while notFound:
            for i in range(4):  # search in a page
                record_number +=1
                tmpKey = tempFile.fileBuffer[0:32]
                tempFile.fileBuffer = tempFile.fileBuffer[256:]
                if tmpKey == decToBin(key, 32):
                    notFound = False
                    print("Key found in position " + tmpKey + ", at page No " + str(page_number) + ", rec " + str(record_number))
                    return tempFile.diskUsage()
            record_number = 0
            page_number += 1
            if tempFile.readNextBlock() == 0:
                print("key not found")
                return 0
    else:
        print("Key found in position " + tmpKey)
        return tempFile.diskUsage()

def serialSearchKey(keysFileName,key):   # dataFileName,
    print("Began Serial Search")
    page_number = 0
    record_number = 0
    keyBitSize = 32
    notFound = True
    tempFileKeys = FileManager(page_size,rec_size)
    tempFileKeys.openFile(keysFileName,"r")  # open in read mode and not write mode, to avoid truncating the file!
    tempFileKeys.readBlock(page_size)  # read the first block
    tmpKey = tempFileKeys.fileBuffer[0:keyBitSize]  # tmpKey is a string!
    if tmpKey != decToBin(key,keyBitSize):
        while notFound:
            for i in range(int((page_size*8)/keyBitSize)):  # search in a page
                record_number +=1
                tmpKey = tempFileKeys.fileBuffer[keyBitSize:2*keyBitSize]  # the key is the second stored value, [32:64]
                tempFileKeys.fileBuffer = tempFileKeys.fileBuffer[2*keyBitSize:]
                if tmpKey == decToBin(key, keyBitSize):
                    # tempFileData = FileManager(page_size, rec_size)
                    # tempFileData.openFile(dataFileName, "r")
                    #
                    notFound = False

                    print("Key found in position " + tmpKey + ", at page No " + str(page_number) + ", rec " + str(record_number))
                    return tempFileKeys.diskUsage()
            record_number = 0
            page_number += 1
            if tempFileKeys.readNextBlock() == 0:
                print("key not found")
                return 0
    else:
        print("Key found in position " + tmpKey)
        return tempFileKeys.diskUsage()

# def serialSearchKeyFile(keyFileName,dataFileName,key):
#     notFound = True
#     keysPerPage = 16
#     keyBitLength = 32
#     page_number = 0
#     record_number = 0
#     tempFileKeys = FileManager(page_size,rec_size)
#     tempFileKeys.openFile(keyFileName,"r")  # open in read mode and not write mode, to avoid truncating the file!
#     tempFileKeys.readBlock(page_size)  # read the first block
#     tmpKey = tempFileKeys.fileBuffer[0:keyBitLength]  # tmpKey is a string!
#     if tmpKey != decToBin(key,keyBitLength):
#         while notFound:
#             for i in range(keysPerPage):  # search in a page
#                 record_number +=1
#                 tmpKey = tempFileKeys.fileBuffer[0:keyBitLength]
#                 tempFileKeys.fileBuffer = tempFileKeys.fileBuffer[keyBitLength:]
#                 if tmpKey == decToBin(key, keyBitLength):
#                     notFound = False
#                     print("Key found in position " + tmpKey + ", at page No " + str(page_number) + ", rec " + str(record_number))
#                     return tempFileKeys.diskUsage()
#             record_number = 0
#             page_number += 1
#             if tempFileKeys.readNextBlock() == 0:
#                 print("key not found")
#                 return 0
#     else:
#         print("Key found in position " + tmpKey)
#         return tempFileKeys.diskUsage()

# First Type of File organisation
# record format:
# ______________________________________________________
# | key  |              data      (28 bytes)           |  x4 in each Page
# ------------------------------------------------------

# Example Data File Generation
file1 = FileManager(page_size, rec_size)
file1.createFile("a_way.txt")
file1.openFile("a_way.txt","w+")

dataA = ""
numbers = random.sample(range(10**6), 100000)
for i in range(len(numbers)):
    dataA = dataA + decToBin(i, 4*8) + decToBin(numbers[i], 28*8)
    # the second argument is to tell the function how many zeroes to add to the final
    # string to comply with thea above specifications.
    if i % 4 == 0:  # each page has 4 records. We write the buffer when it reaches the one page.
        file1.fileBuffer = dataA
        file1.appendBlock()
        dataA = ""
        file1.count()

dataASearch = [random.choice(dataA) for i in range(10) ]  # the data we will search for
dataA = []  # free the space of the huge list
file1.closeFile()

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

file2 = FileManager(page_size, rec_size)
file2.createFile("b_way.txt")
file2.openFile("b_way.txt","w+")
file3 = FileManager(4*8, 4*8)
file3.createFile("b_way_keys.txt")
file3.openFile("b_way_keys.txt","w+")

dataB = ""
keys = ""
numbers = random.sample(range(10**6), 100000)
for i in range(len(numbers)):
    dataB = dataB + decToBin(i, 4*8) + decToBin(numbers[i], 28*8)
    keys = keys + decToBin(i,4*8) + decToBin(int(i/4),4*8)
    if i % 4 == 0 and i != 0:
        file2.fileBuffer = dataB
        file2.appendBlock()
        dataB = ""
        file2.count()
    if i%16 == 0 and i != 0:
        file3.fileBuffer = keys
        file3.appendBlock()
        file3.count()
        keys = ""
dataBSearch = [random.choice(dataB) for i in range(10) ]  # the data we will search for
dataB = []  # free the space of the huge list

file2.closeFile()
file3.closeFile()


# Searches:
# print("The total number of disk access(es) is: ", str(serialSearch("a_way.txt",14863)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",1)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",10)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",11)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",12)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",13)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",14)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",15)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",16)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",17)))
print("The total number of disk access(es) is: ", str(serialSearchKey("b_way_keys.txt",18)))
