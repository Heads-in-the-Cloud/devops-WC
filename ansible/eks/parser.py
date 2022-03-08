#!/bin/python

import json
import sys


if __name__ == '__main__':
    print(sys.argv)
    print(type(sys.argv[1]))
    json.load(sys.argv[1])