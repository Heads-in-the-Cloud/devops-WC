#!/bin/python

import json
import sys
import ast


if __name__ == '__main__':
    print(sys.argv)
    print(type(sys.argv[1]))
    dict_string = sys.argv[1][1:][:-1]
    object = dict_string.split(',')
    dict_obj = {}
    for x in object:
        parse_x = x.split(':')
        dict_obj[parse_x[0]] = parse_x[1]
    print(dict_obj)
    # object = ast.literal_eval(sys.argv[1])
    # print(object)
    # print(object['secret_key'])