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
            if self.fileBuffer == '':
                return 0
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
    if tmpKey != decToBin(key,32):
        while notFound:
            page_number += 1
            for i in range(4):  # search in a page
                record_number +=1
                tmpKey = tempFile.fileBuffer[0:32]
                tempFile.fileBuffer = tempFile.fileBuffer[256:]
                if tmpKey == decToBin(key, 32):
                    notFound = False
                    print("Key found in position " + tmpKey + ", at page No " + str(page_number) + ", rec " + str(record_number))
                    return tempFile.diskUsage()
            record_number = 0
            if tempFile.readNextBlock() == 0:
                print("key not found")
                return 0
    else:
        print("Key found in position " + tmpKey)
        return tempFile.diskUsage()

def serialSearchKey(fileName,key):   # dataFileName,
    print("Began Serial key Search")
    page_number = 0
    record_number = 0
    notFound = True
    tempFile = FileManager(page_size, rec_size)
    tempFile.openFile(fileName, "r")  # open in read mode and not write mode, to avoid truncating the file!
    tempFile.readBlock(0)  # read the first block
    tmpKey = tempFile.fileBuffer[32:64]  # tmpKey is a string!
    if tmpKey != decToBin(key, 32):
        while notFound:
            page_number += 1
            for i in range(16):  # search in a page
                record_number += 1
                tmpKey = tempFile.fileBuffer[32:64]
                tempFile.fileBuffer = tempFile.fileBuffer[64:]
                if tmpKey == decToBin(key, 32):
                    notFound = False
                    print("Key found in position " + tmpKey + ", at page No " + str(page_number) + ", rec " + str(
                        record_number))
                    return tempFile.diskUsage()
            record_number = 0
            if tempFile.readNextBlock() == 0:
                print("key not found")
                return 0
    else:
        print("Key found in position " + tmpKey)
        return tempFile.diskUsage()




# Example Data File Generation
def createSerialFile():
    file1 = FileManager(page_size, rec_size)
    file1.createFile("a_way.txt")
    file1.openFile("a_way.txt","w+")
    keys_number = 1000  # how many entries the file has.
    dataA = ""
    numbers = random.sample(range(10**6), keys_number)
    keys_list = random.sample(range(keys_number), keys_number)
    for i in range(len(numbers)):
        dataA = dataA + decToBin(keys_list[i], 4*8) + decToBin(numbers[i], 28*8)
        # the second argument is to tell the function how many zeroes to add to the final
        # string to comply with thea above specifications.
        if i % 4 == 0:  # each page has 4 records. We write the buffer when it reaches the one page.
            file1.fileBuffer = dataA
            file1.appendBlock()
            dataA = ""
            file1.count()

    file1.closeFile()

def createSerialKeyFile():
    file1 = FileManager(page_size, rec_size)
    file1.createFile("b_way_keys.txt")
    file1.openFile("b_way_keys.txt","w+")
    keys_number = 1000  # how many entries the file has.
    dataA = ""
    numbers = random.sample(range(10**6), keys_number)
    keys_list = random.sample(range(keys_number), keys_number)  #  [i for i in range(keys_number)]
    for i in range(len(numbers)):
        dataA = dataA + decToBin(keys_list[i], 4*8) + decToBin(int(i/16), 4*8)
        # the second argument is to tell the function how many zeroes to add to the final
        # string to comply with thea above specifications.
        if i % 16 == 0 and i != 0:  # each page has 4 records. We write the buffer when it reaches the one page.
            file1.fileBuffer = dataA
            file1.appendBlock()
            dataA = ""
            file1.count()

    file1.closeFile()

createSerialFile()
createSerialKeyFile()

keys_list = random.sample(range(1000), 1000)  # 20 is the number of calculations
simpleSerial = [0 for i in range(20)]
keyFileSerial = [0 for i in range(20)]
for i in range(20):
    simpleSerial[i] = int(serialSearch("a_way.txt",keys_list[i]))

counter = 0
index = 0
while counter < 20:
    keyFileSerial[counter] = int(serialSearchKey("b_way_keys.txt",keys_list[index]))
    if keyFileSerial[counter] == 0:
        index += 1
    else:
        index += 1
        counter += 1



print("The first way's performance is : " + str(sum(simpleSerial)/len(simpleSerial)))
print("The second way's performance is : " + str(sum(keyFileSerial)/len(keyFileSerial)))
