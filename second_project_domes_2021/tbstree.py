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

    def get_data(self):
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
        else:
            return '(node not initialised)'


class TBST:  # accepts no double keys!
    def __init__(self, length):
        # the first and last booleans indicate if there is a thread pointer or a normal one.
        self.tree_array = [Node() for _ in range(length)]  # underscore for unused value
        self.avail_positions = [pos for pos in range(1, length)]
        self.root = 0
        self.avail = 0  # positions from 1 and after are free
        self.space_count = 8  # spacing on print function
        self.list_of_data = []  # sorted every node's data is here

    def insert_key(self, key):  # uses the search function
        pass

    def search_key(self, key):  # key should be an int
        pass

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
