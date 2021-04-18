# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

COUNT = [10]

class BST:
    def __init__(self, length,root):
        self.tree_array = [[None,None,None] for i in range(length)]
        self.avail_positions = [i for i in range(1,length)]
        self.root = 0
        self.avail = 0  # positions from 1 and after are free
        self.tree_array[0] = [root, None, None]
        self.nodes = 1

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
                    self.nodes += 1
                    return index
                else:
                    index = self.get_right(index)

            elif key < curr_data:
                if self.get_left(index) == None:
                    self.tree_array[index][1] = self.avail_positions[0]  # connect the new child to its parent node
                    self.tree_array[self.avail_positions[0]] = [key, None, None]  # initialise new Node
                    del self.avail_positions[0]
                    self.nodes += 1
                    return index
                else:
                    index = self.get_left(index)


    def print_tree(self):
        print(self.tree_array)
        print(self.avail_positions)
        print("number of nodes:"  +  str(self.nodes))

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

    # make this repetitive instead of recursive If possible
    # https://www.geeksforgeeks.org/print-bst-keys-in-the-given-range/
    def search_range(self,root_index,k1,k2):
        if root_index == None:
            return  # reached the end of the tree
        if (self.tree_array[root_index][0] > k1):
            self.search_range(self.tree_array[root_index][1],k1,k2)  # recursively call to left subtree
        if (self.tree_array[root_index][0] >= k1) and (self.tree_array[root_index][0] <= k2):
            print(self.tree_array[root_index][0])
        if (self.tree_array[root_index][0] < k2):
            self.search_range(self.tree_array[root_index][2], k1, k2)  # recursively call right subtree

    # the next two functions: https://www.geeksforgeeks.org/print-binary-tree-2-dimensions/
    def print2DUtil(self,root, space):
        # Base case
        if (root == None):
            return
        # Increase distance between levels
        space += COUNT[0]
        # Process right child first
        self.print2DUtil(self.tree_array[root][2], space)  # right subtree
        # Print current node after space
        # count
        print()
        for i in range(COUNT[0], space):
            print(end=" ")
        print(self.tree_array[root][0])
        # Process left child
        self.print2DUtil(self.tree_array[root][1], space)  # left subtree

    # Wrapper over print2DUtil()
    def print2D(self):
        self.print2DUtil(self.root, 0)









    # Press the green button in the gutter to run the script.
if __name__ == '__main__':
    new_bst = BST(10,5)
    new_bst.print_tree()

    new_bst.insert_key(2)
    new_bst.insert_key(8)
    new_bst.insert_key(1)
    new_bst.insert_key(3)
    new_bst.insert_key(10)
    new_bst.insert_key(15)
    new_bst.insert_key(12)
    new_bst.insert_key(0)
    new_bst.insert_key(13)


    new_bst.print_tree()
    print("test of the range search:")
    new_bst.search_range(0,2,10)

    new_bst.print2D()

