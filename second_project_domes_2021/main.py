# Project Domes Second
# April 2021
# [year_of_enrollment]030118
import bstree as bst
import tbstree as tbst




if __name__ == '__main__':
    new_node = tbst.Node()
    new_node.set_data(5)
    new_node.set_left_thread(3)
    new_node.set_right_index(6)
    print(new_node)

    new_tree = tbst.TBST(5)
    counter = 0
    for node in new_tree.tree_array:
        print(str(new_tree.tree_array[counter]))
        counter += 1

    # new_bst = bstree.BST(100, 5)  # create a tree with 15 nodes and 5(data) as a root
    #
    # for i in [2, 8, 7, 1, 3, 10, 12, 20, 0, 3]:
    #     new_bst.insert_key(i)
    #
    # print("test of the range search:")
    # new_bst.search_range(1, 5)
    #
    # new_bst.print_tree()
    #
    # new_bst.delete_node(8)
    #
    # # for i in [11,13,14,4]:
    # #     new_bst.insert_key(i)
    #
    #
    # new_bst.print_tree()
    #
    # print(new_bst.search_key(12))

