#!/bin/python

######## Parser Helper Script #######
# Param 1: string representation of a python dict from queried from the Secrets Manager
# Param 2: string value of the key to parse from the dict
# Exits with the key to stderr
#####################################

# Example:
#------------------------------------------------------------------------------
# secrets="{{ lookup('aws_secret', SECRET_NAME, region=REGION, nested=true) }}"
# chmod +x parser.py
# db_user=$(python parser.py $secrets "{{ DB_USER }}" 2>&1 > /dev/null)
# db_password=$(python parser.py $secrets "{{ DB_PASSWORD }}" 2>&1 > /dev/null)
# db_host=$(python parser.py $secrets "{{ DB_HOST }}" 2>&1 > /dev/null)
# secret_key=$(python parser.py $secrets "{{ SECRET_KEY }}" 2>&1 > /dev/null)

import sys

if __name__ == '__main__':

    #trim the outher curly braces to produce an array of key-value pairs
    dict_string = sys.argv[1][1:][:-1]
    object = dict_string.split(',')
    dict_obj = {}
    #construct a new python dict from the arrays from colon-separated values
    for x in object:
        parse_x = x.split(':')
        dict_obj[parse_x[0]] = parse_x[1]
    #exit with the value being streamed to stderr
    sys.exit(dict_obj[sys.argv[2]])
