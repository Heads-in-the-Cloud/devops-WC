#!/bin/python

import json
import sys
import ast


if __name__ == '__main__':

    dict_string = sys.argv[1][1:][:-1]
    object = dict_string.split(',')
    dict_obj = {}
    for x in object:
        parse_x = x.split(':')
        dict_obj[parse_x[0]] = parse_x[1]
    sys.exit(dict_obj[sys.argv[1]])
