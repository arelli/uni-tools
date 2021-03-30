import os
from os import path


global rec_size
rec_size = 32  # A record is 32 bytes long. 4 for the key and 28 for the data.

global page_size  # how many bytes a page has.
page_size = 128

global file_pointer
file_pointer = 0

def charToBinary(string):
	return ''.join(format(ord(i), '08b') for i in string)

def BinaryToDecimal(binary): 
	binary1 = binary 
	decimal, i, n = 0, 0, 0
	while(binary != 0): 
		dec = binary % 10
		decimal = decimal + dec * pow(2, i) 
		binary = binary//10
		i += 1
	return (decimal)    
	
def binarytoChar(string):
	str_data =' '
	# slicing the input and converting it 
	# in decimal and then converting it in string
	for i in range(0, len(bin_data), 7):
		temp_data = int(bin_data[i:i + 7])
		decimal_data = BinaryToDecimal(temp_data)
		str_data = str_data + chr(decimal_data) 
	return str_data


class FileManager:
	def __init__(self, page_size,rec_size):
		self.page_size = page_size
		self.rec_size = rec_size
		self.fileBuffer = []  # size of the buffer must always be page_size(128 here)
		self.read_pos = 0  # the position in the file
		self.write_pos = 0
		self.numberOfPages = 0

	def createFile(self, filename):
		#check if file with name filename exists in the same directory. If not, it creates it.
		if path.exists(filename):
			print("file exists!")
		else:
			try:
				f = open(filename, "x")  # create the file 
				print("new file " + str(filename) + " created.")
				return 1
			except:
				print("cannot create file. Aborting")
				return 0


	def openFile(self, filename):
		# return the number of pages of the file
		self.file = open(filename, "rw")
		data = self.file.read()
		characters = len(data)
		numberOfPages = characters/page_size
		self.numberOfPages = numberOfPages
		return numberOfPages   # return how many pages the file has.




	# Read a page(4*rec_size of bytes) of data from file, from the pos position.
	def readBlock(self,pos):
		try:
			self.file.seek(read_pos,0)  # go to the location of the file pointer(pos) to start reading
			self.fileBuffer.append(self.file.read(page_size))  # read page_size bytes of characters from the file and append it to the buffer
			return 1
		except:
			print('Could not read block with readBlock(). Exiting...')
			return 0


	# read the next block from the current pointer
	def readNextBlock(self):
		try:
			self.file.seek(self.read_pos,0)  # go to the location of the file pointer(pos) to start reading
			self.fileBuffer.append(self.file.read(page_size))  # read page_size bytes of characters from the file and append it to the buffer
			self.read_pos += page_size  
			return 1
		except:
			print('Could not read block with readNextBlock(). Exiting...')
			return 0


	def writeBlock(self,pos):
		try:
			self.file.seek(pos,0)  # go to the location of the file pointer(pos) to start reading
			self.file.write(self.fileBuffer)  # read page_size bytes of characters from the file and append it to the buffer
			self.numberOfPages += 1
			return 1
		except:
			print('Could not write block with writeBlock(). Exiting...')
			return 0




	def writeNextBlock(self):
		try:
			self.file.seek(write_pos,0)  # go to the location of the file pointer(pos) to start reading
			self.file.write(self.fileBuffer)  # read page_size bytes of characters from the file and append it to the buffer
			self.write_pos += page_size  
			self.numberOfPages += 1
			return 1
		except:
			print('Could not write block with writeNextBlock(). Exiting...')
			return 0


	def appendBlock(self):
		data = self.file.read()
		try:
			self.file.seek(len(data),0)  # can be donw by opening the file with "a" mode
			self.file.write(self.fileBuffer)  # read page_size bytes of characters from the file and append it to the buffer
			self.numberOfPages += 1
			return 1
		except:
			print('Could not write block with appendtBlock(). Exiting...')
			return 0


	def deleteBlock(self):
		print("deleteBlock not yet implemented.")


	def closeFile(self):
		try:
			self.file.close()
			return 1
		except:
			print("closeFile() could not close the file.")
			return 0




