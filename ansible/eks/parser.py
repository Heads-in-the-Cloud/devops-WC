#!/bin/python

import json
import sys
import ast


if __name__ == '__main__':
    print(sys.argv)
    print(type(sys.argv[1]))
    object = json.loads(sys.argv[1])
    print(object)
    # object = ast.literal_eval(sys.argv[1])
    # print(object)
    # print(object['secret_key'])