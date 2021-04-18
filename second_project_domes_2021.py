# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

class BST:
    def __init__(self, length, root):
        self.tree_array = [[None, None, None] for i in range(length)]
        self.avail_positions = [i for i in range(1, length)]
        self.root = 0
        self.avail = 0  # positions from 1 and after are free
        self.tree_array[0] = [root, None, None]
        self.nodes = 1
        self.space_count = 8  # spacing on print function
        self.list_of_data = [root]  # sorted every node's data is here

    def get_left(self, index):
        return self.tree_array[index][1]

    def get_right(self, index):
        return self.tree_array[index][2]

    def get_data(self, index):
        return self.tree_array[index][0]

    def insert_key(self, key):  # uses the search function
        not_found = True
        index = self.root
        if not self.avail_positions:
            print("No more available space to write nodes")
            return -1
        while not_found:
            curr_data = self.get_data(index)
            if curr_data == key:
                return index  # element already in the tree

            elif key > curr_data:
                if self.get_right(index) == None:
                    self.tree_array[index][2] = self.avail_positions[0]  # connect the new child to its parent node
                    self.tree_array[self.avail_positions[0]] = [key, None, None]  # initialise new Node
                    del self.avail_positions[0]
                    self.list_of_data.append(key)
                    self.list_of_data.sort()
                    self.nodes += 1
                    return index
                else:
                    index = self.get_right(index)

            elif key < curr_data:
                if self.get_left(index) == None:
                    self.tree_array[index][1] = self.avail_positions[0]  # connect the new child to its parent node
                    self.tree_array[self.avail_positions[0]] = [key, None, None]  # initialise new Node
                    del self.avail_positions[0]
                    self.list_of_data.append(key)
                    self.list_of_data.sort()
                    self.nodes += 1
                    return index
                else:
                    index = self.get_left(index)


    def search_key(self, key):  # key should be an int
        buffer = []  # keep the last two nodes traversed in the form of [index_in_tree_data,data]
        not_found = True
        index = self.root
        while not_found:
            curr_data = self.get_data(index)
            if curr_data == key:
                buffer.append([index, self.tree_array[index][0]])
                return buffer
            elif key > curr_data:
                buffer.append([index,self.tree_array[index][0]])
                index = self.get_right(index)
            elif key < curr_data:
                buffer.append([index,self.tree_array[index][0]])
                index = self.get_left(index)

            if len(buffer) > 2:  # retain up to N parent information
                buffer.pop(0)  # keep the buffer 3 long

            if index == None:
                return -1  # nothing found

    # make this repetitive instead of recursive If possible
    # https://www.geeksforgeeks.org/print-bst-keys-in-the-given-range/
    def search_range(self, root_index, k1, k2):
        if root_index == None:
            return  # reached the end of the tree
        if (self.tree_array[root_index][0] > k1):
            self.search_range(self.tree_array[root_index][1], k1, k2)  # recursively call to left subtree
        if (self.tree_array[root_index][0] >= k1) and (self.tree_array[root_index][0] <= k2):
            print(self.tree_array[root_index][0])
        if (self.tree_array[root_index][0] < k2):
            self.search_range(self.tree_array[root_index][2], k1, k2)  # recursively call right subtree

    def delete_node(self, key):
        print("helloeoeooeoe")
        index = self.search_key(key)
        index = index[1][0]
        if (index == None):
            return -1  # node not found

        # there are three cases:
        # 1) the node is a leaf --> delete it and update the available list
        if self.tree_array[index][1] == None and self.tree_array[index][2] == None:
            self.tree_array[index] = [None,None,None]
            self.avail_positions.append(index)  # doesn't matter if it is added in the front or not
            #ALSO DELETE PARENT POINTER TO IT!
            return 0
        # 2) the node has one child --> connect node's parent with node's child

        # 3) the node has 2 children --> find inorder successor and replace the node



    # the next two functions: https://www.geeksforgeeks.org/print-binary-tree-2-dimensions/
    def print2DUtil(self, root, space):
        # Base case
        if (root == None):
            return
        # Increase distance between levels
        space += self.space_count
        # Process right child first
        self.print2DUtil(self.tree_array[root][2], space)  # right subtree
        # Print current node after space
        # count
        print()
        for i in range(self.space_count, space):
            print(end=" ")
        print(self.tree_array[root][0])
        # Process left child
        self.print2DUtil(self.tree_array[root][1], space)  # left subtree

    # Wrapper over print2DUtil()
    def print2D(self):
        self.print2DUtil(self.root, 0)
        print("Data sorted: " + str(self.list_of_data))
        print("number of nodes:" + str(self.nodes))

    # Press the green button in the gutter to run the script.


if __name__ == '__main__':
    new_bst = BST(15, 5)

    new_bst.insert_key(2)
    new_bst.insert_key(8)
    new_bst.insert_key(1)
    new_bst.insert_key(3)
    new_bst.insert_key(10)
    new_bst.insert_key(15)
    new_bst.insert_key(12)
    new_bst.insert_key(0)
    new_bst.insert_key(3)

    print("test of the range search:")
    new_bst.search_range(0, 2, 10)

    new_bst.print2D()


    new_bst.delete_node(12)

    new_bst.print2D()

    print(new_bst.search_key(12))
