#!/bin/python

import json
import sys
import ast


if __name__ == '__main__':
    print(sys.argv)
    print(type(sys.argv[1]))
    object = ast.literal_eval
    print(object)
    print(object['secret_key'])