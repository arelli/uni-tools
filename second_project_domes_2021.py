# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

class BST:
    def __init__(self, length):
        self.tree_array = [[None,None,None] for i in range(length)]
        self.avail_positions = [i for i in range(1,length)]
        self.root = 0
        self.avail = 0  # positions from 1 and after are free

    def get_left(self,index):
        return self.tree_array[index][1]

    def get_right(self,index):
        return self.tree_array[index][2]

    def get_data(self,index):
        return self.tree_array[index][0]

    def insert_key(self,key):  # uses the search function
        not_found = True
        index = self.root
        while not_found:
            curr_data = self.get_data(index)
            if curr_data == key:
                return index  # element already in the tree

            elif key > curr_data:
                if self.get_right(index) == None:
                    self.tree_array[index][2] = self.avail_positions[0]  # connect the new child to its parent node
                    self.tree_array[self.avail_positions[0]] = [key, None, None]  # initialise new Node
                    del self.avail_positions[0]
                    return index
                else:
                    index = self.get_right(index)

            elif key < curr_data:
                if self.get_left(index) == None:
                    self.tree_array[index][1] = self.avail_positions[0]  # connect the new child to its parent node
                    self.tree_array[self.avail_positions[0]] = [key, None, None]  # initialise new Node
                    del self.avail_positions[0]
                    return index
                else:
                    index = self.get_left(index)


    def print_tree(self):
        print(self.tree_array)
        print(self.avail_positions)

    def search_key(self,key):  # key should be an int
        not_found = True
        index = self.root
        while not_found:
            curr_data = self.get_data(index)
            if curr_data==key:
                return index
            elif key > curr_data:
                index = self.get_right(index)
            elif key < curr_data:
                index = self.get_left(index)

            if index == None:
                return -1  # nothing found

    #def search_range(self):

    #def del_element(self):






# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    new_bst = BST(10)
    new_bst.print_tree()

    new_bst.tree_array[0] = [5,None, None]  # create a root
    #del(new_bst.avail_positions[0])

    new_bst.insert_key(2)
    new_bst.insert_key(8)
    new_bst.insert_key(1)
    new_bst.insert_key(3)
    new_bst.insert_key(10)
    new_bst.insert_key(15)
    new_bst.insert_key(12)


    new_bst.print_tree()

