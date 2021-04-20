# Project Domes Second
# April 2021
# [year_of_enrollment]030118

class BST:  # accepts no double keys!
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
        while not_found:  # search for a leaf to hang our new node under
            curr_data = self.get_data(index)
            if curr_data == key:
                return index  # element already in the tree

            elif key > curr_data:
                if self.get_right(index) == None:  # search a node that has no leaf in our direction
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
            elif curr_data == None:
                return -1
            elif key > curr_data:
                buffer.append([index, self.tree_array[index][0]])
                index = self.get_right(index)
            elif key < curr_data:
                buffer.append([index, self.tree_array[index][0]])
                index = self.get_left(index)

            if len(buffer) > 2:  # keep up to N parent information
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
        search_index = self.search_key(key)  # get the position of the item to be deleted
        index = search_index[(len(search_index)-1)][0]  # 2 is the number of items the search returned buffer has. Index is at position [0].

        child_value = self.tree_array[index][0]
        child_left = self.tree_array[index][1]
        child_right = self.tree_array[index][2]
        if len(search_index) != 1:
            parent_index = search_index[1][0]
            parent_value = self.tree_array[parent_index][0]
        else:  # means that we are deleting the root, which has no parents
            parent_value = None
            parent_index = None
        if index is None:
            return -1  # node not found

        # there are three cases:
        # 1) the node is a leaf --> delete it and update the available list(WORKS)
        if child_left is None and child_right is None:
            self.avail_positions.append(index)  # doesn't matter if it is added in the front or not
            if child_value > parent_value:  # it is the right child
                self.tree_array[parent_index][2] = None  # delete pointer to right child
            elif child_value < parent_value:  # it is the left child
                self.tree_array[parent_index][1] = None  # delete left child
            else:
                return -1
            self.tree_array[index] = [None, None, None]  # delete the actual node
            self.list_of_data.remove(key)
            return 0

        # 2) the node has one child --> connect node's parent with node's child
        if child_left is None and child_right is not None:  # has only right subtree
            self.tree_array[index] = self.tree_array[child_right]  # copy the child(of the child) node to the child
            self.tree_array[child_right] = [None, None, None]  # delete the node
            self.avail_positions.append(child_right)  # add to the available positions list
            self.list_of_data.remove(key)

        if child_left is not None and child_right is None:  # has only left subtree
            self.tree_array[index] = self.tree_array[child_left]  # copy the child(of the child) node to the child
            self.tree_array[child_left] = [None, None, None]  # delete the node
            self.avail_positions.append(child_left)
            self.list_of_data.remove(key)

        # 3) the node has 2 children --> find inorder successor and replace the node
        if (child_left is not None) and (child_right is not None):
            # find the successor node
            index_of_successor = self.list_of_data.index(key) + 1

            # copy successor data(not node!) to the position of the node we want to delete
            index_of_successor = self.search_key(self.list_of_data[index_of_successor])  # index in the inorder list
            index_of_successor = index_of_successor[len(index_of_successor)-1][0]  # translate to index in tree_array
            self.tree_array[index][0] = self.tree_array[index_of_successor][0]  # index in the real tree array

            # if the successor has children, keep the "pointers" to them
            # if self.tree_array[index_of_successor][1] is not None or self.tree_array[index_of_successor][2] is not None:


            # delete parent pointer to the successor node(right or left)
            #big IF for testing if it is root that we re deleting
            # search_index = self.search_key(self.tree_array[index_of_successor][0])
            # parent_index = search_index[len(search_index)-2][0]
            # if self.tree_array[parent_index][0] > self.tree_array[index_of_successor][0]:
            #     self.tree_array[parent_index][1] = None  # delete left child
            # elif self.tree_array[parent_index][0] < self.tree_array[index_of_successor][0]:
            #     self.tree_array[parent_index][2] = None  # delete right child


            # delete the actual successor node and free it in avail list
            self.tree_array[index_of_successor] = [None, None, None]

            # do the necessary housekeeping...
            self.avail_positions.append(index_of_successor)
            self.list_of_data.remove(key)



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


if __name__ == '__main__':
    new_bst = BST(15, 5)  # create a tree with 15 nodes and 5(data) as a root

    for i in [2, 8, 7, 1, 3, 10, 12, 20, 0, 3]:
        new_bst.insert_key(i)

    print("test of the range search:")
    new_bst.search_range(0, 2, 10)

    new_bst.print2D()

    new_bst.delete_node(1)


    new_bst.print2D()

    print(new_bst.search_key(12))
