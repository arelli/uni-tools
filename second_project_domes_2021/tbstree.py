class Node:
    def __init__(self):
        self.data = None
        self.right_pointer = None
        self.left_pointer = None
        self.has_left_thread = False  # indicates if the left_pointer value indicates a thread or a normal subtree
        self.has_right_thread = False
        return

    def has_left(self):
        return self.has_left_thread

    def has_right(self):
        return self.has_right_thread

    def get_left(self):
        return self.left_pointer

    def get_right(self):
        return self.right_pointer

    def get_data(self) -> int:
        return self.data

    def set_data(self,data):
        self.data = data
        return

    def set_left_thread(self,thread):
        self.has_left_thread = True
        self.left_pointer = thread
        return

    def set_right_thread(self,thread):
        self.has_right_thread = True
        self.right_pointer = thread
        return

    def set_left_index(self,pointer):
        self.has_left_thread = False
        self.left_pointer = pointer
        return

    def set_right_index(self, pointer):
        self.has_right_thread = False
        self.right_pointer = pointer

    def __str__(self):
        if self.has_right() and self.has_left():
            return 'D={},L(t)={},R(t)={}'.format(self.data, self.left_pointer, self.right_pointer)
        if self.has_right():
            return 'D={},L={},R(t)={}'.format(self.data, self.left_pointer, self.right_pointer)
        if self.has_left():
            return 'D={},L(t)={},R={}'.format(self.data, self.left_pointer, self.right_pointer)
        if self.data is not None:
            return 'D={}(only)'.format(self.data)
        else:
            return '(node not initialised)'


class TBST:  # accepts no double keys!
    def __init__(self, length):
        self.length = length
        self.tree_array = [Node() for _ in range(length)]  # underscore for unused value
        self.avail_positions = [pos for pos in range(0, length)]
        self.root = 0
        self.avail = 0  # positions from 1 and after are free
        self.space_count = 8  # spacing on print function
        self.list_of_data = []  # sorted every node's data is here

    def get_min(self):
        node = self.tree_array[self.root]
        while node.has_left_thread is not True:
            node = self.tree_array[node.get_left()]
        return node.get_data()

    def get_max(self):
        node = self.tree_array[self.root]
        while node.has_right_thread is not True:
            node = self.tree_array[node.get_right()]
        return node.get_data()


    def insert_key(self, key):  # uses the search function
        not_found = True
        index = self.root
        if not self.avail_positions:
            print("No more available space in the array to write nodes.")
            return -1
        if len(self.avail_positions) == self.length:  # if there is no data in the array
            self.tree_array[self.avail_positions[0]].set_data(key)  # pop() also deletes it
            self.tree_array[self.avail_positions[0]].has_left_thread = True  # special case only for root!
            self.tree_array[self.avail_positions.pop(0)].has_right_thread = True
            self.list_of_data.append(key)
            self.list_of_data.sort()
            return

        while not_found:
            curr_data = self.tree_array[index].get_data()
            if curr_data == key:
                return 1  # this key is already in the tree
            elif key > curr_data:
                if self.tree_array[index].has_right_thread:  # means that there is no right subtree
                    self.tree_array[index].set_right_index(self.avail_positions[0])  # set parent pointer to child
                    self.tree_array[self.avail_positions.pop(0)].set_data(key) # pop() also deletes it
                    self.list_of_data.append(key)
                    self.list_of_data.sort()
                    # TODO: create the threads
                    if key == self.get_max():# doesn't have right thread, only left
                        # find the exactly smaller node and point to it
                        pass
                    else:
                        # find the exactly smaller and the exactly bigger node and point to them
                        pass

                    return index
                else:
                    index = self.tree_array[index].get_right()

            elif key < curr_data:
                if self.tree_array[index].has_left_thread:  # means that there is no left subtree
                    self.tree_array[index].set_left_index(self.avail_positions[0])
                    self.tree_array[self.avail_positions.pop(0)].set_data(key)  # set the data field in the node
                    self.list_of_data.append(key)
                    self.list_of_data.sort()
                    # TODO: create the threads
                    if key == self.get_min():# doesn't have left thread, only right
                        # find the exactly bigger node and point to it
                        pass
                    else:
                        # find the exactly smaller and the exactly bigger node and point to them
                        pass

                    return index
                else:
                    index = self.tree_array[index].get_left()

    def search_key(self, key):  # key should be an int
        buffer = []
        not_found = True
        index = self.root
        while not_found:
            curr_data = self.tree_array[index].get_data()
            buffer.append([index, self.tree_array[index].get_data()])
            if curr_data == key:
                return buffer
            elif curr_data is None:
                return -1  # failed to find the key
            elif key > curr_data:
                index = self.tree_array[index].get_right()
            elif key < curr_data:
                if self.tree_array[index].has_left_thread:
                    return -1
                else:
                    index = self.tree_array[index].get_left()

            if len(buffer)>2:
                buffer.pop(0)


    def search_range_recursive(self, root_index, k1, k2):
        pass

    def search_range(self, k1, k2): # wrapper method of the above
        pass

    def delete_node(self, key):
        pass

    def print_util(self, root, space):
        pass

    def print_tree(self):
        pass
