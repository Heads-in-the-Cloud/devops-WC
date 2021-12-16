from flask import Flask, request
import json, requests, random, logging, traceback, os
from datetime import date
from faker import Faker
from requests import cookies
from rstr import Rstr
from dotenv import load_dotenv
import pyinputplus as pyip
import sys, argparse


app = Flask(__name__)

load_dotenv()

fake = Faker()


logging.basicConfig(level=logging.INFO)

def parse_args(args):
    parser=argparse.ArgumentParser()

    parser.add_argument("-a", "--airports", default = os.getenv('AIRPORT_CSV_PATH'), type=str, help="airports file path")
    parser.add_argument("-d", "--database", default = 'local', type=str, help="RDS or localhost")
    parser.add_argument("-p", "--ports", action='store_true', help="Specify ports")
    parser.add_argument("-y", "--yes", action='store_true', help="run automated script")
    
    args, unknown = parser.parse_known_args(args)
    return args

parser = parse_args(sys.argv[1:])

#use RDS instance or local
host = os.getenv('LOCAL')
if parser.database == 'aws':
    host = os.getenv('RDS')

flight_port = ''
user_port = ''
booking_port = ''

#use specified ports if no load balancer exists
if parser.ports:
    flight_port = os.getenv('FLIGHT_PORT')
    user_port = os.getenv('USER_PORT')
    booking_port = os.getenv('BOOKING_PORT')


REQ_LOGIN =host+user_port+os.getenv('REQ_LOGIN') 
REQ_GET_USERS =host+user_port+os.getenv('REQ_GET_USERS') 
REQ_DELETE_USER =host+user_port+os.getenv('REQ_DELETE_USER') 
REQ_POST_USER =host+user_port+os.getenv('REQ_POST_USER') 

ADMIN = os.getenv('ADMIN_USERNAME')
ADMIN_PASS = os.getenv('ADMIN_PASSWORD')

AGENT = os.getenv('AGENT_USERNAME')
AGENT_PASS = os.getenv('AGENT_PASSWORD')

TRAVELER = os.getenv('TRAVELER_USERNAME')
TRAVELER_PASS = os.getenv('TRAVELER_PASSWORD')





def post_user(num):
    
    for i in range(num):
        user = create_user()
        logging.info('creating user %s %s, username=%s email=%s' 
        %(user['given_name'], user['family_name'], user['username'], user['email']))
        response = requests.post(REQ_POST_USER, json=user)


def login():
    response = requests.post(url = REQ_LOGIN, json = {"username" : ADMIN, "password" : ADMIN_PASS})
    if response.status_code == 401:
        logging.error('unable to perform action. admin_example could not be signed in')
        exit()
    return response.cookies



def create_user():

    role = random.randint(1, 3)

    rstr = Rstr()
    firstname = fake.first_name()
    last_name = fake.last_name()
    return {"role_id":role, 
            "given_name": firstname, 
            "family_name": last_name, 
            "username" : firstname+last_name+rstr.xeger(r'[0-9]{,4}'),
            "email" : fake.email(), 
            "password" : "pass", 
            "phone" : generate_phone()}

def generate_phone():
    rstr = Rstr()
    return rstr.xeger(r'((909)|(626)|(900)|(714))-[0-9]{3}-[0-9]{4}')


#if the db is erased, make sure to add an admin, agent, and traveller with usernames used in test class
def create_test_use_cases():
    admin = {"role_id": 1, 
            "given_name": fake.first_name(), 
            "family_name": fake.last_name(), 
            "username" : ADMIN,
            "email" : fake.email(), 
            "password" : ADMIN_PASS, 
            "phone" : generate_phone()}
    agent = {"role_id": 2, 
            "given_name": fake.first_name(), 
            "family_name": fake.last_name(), 
            "username" : AGENT,
            "email" : fake.email(), 
            "password" : AGENT_PASS, 
            "phone" : generate_phone()}

    traveler = {"role_id": 3, 
            "given_name": fake.first_name(), 
            "family_name": fake.last_name(), 
            "username" : TRAVELER,
            "email" : fake.email(), 
            "password" : TRAVELER_PASS, 
            "phone" : generate_phone()}
    response = requests.post(REQ_POST_USER, json=traveler)
    response = requests.post(REQ_POST_USER, json=agent)
    response = requests.post(REQ_POST_USER, json=admin)


def clean_users():

    cookies = login()
    user_ids = [u['id'] for u in requests.get(REQ_GET_USERS, cookies=cookies).json()]

    
    for id in user_ids:
        logging.info('deleting user %d' %id)
        response = requests.delete(REQ_DELETE_USER+str(id), cookies=cookies)
        if response.status_code == 401 or response.status_code == 403:
            print('insufficient authorization to delete user')
            exit()
        cookies = response.cookies
     



if __name__ == '__main__':

    # try:
    #     print(REQ_GET_USERS)
    #     requests.get(REQ_GET_USERS)
        
    # except:
    #     print('could not connect to host')
    #     traceback.print_exc()
    #     exit()

    if parser.yes:
        post_user(int(os.getenv("DEFAULT_LOAD_SIZE")))
        exit()

        
    create_test_use_cases()

    print('would you like to clean the users database?')
    if(pyip.inputYesNo('delete all users in db? (y/n): ') == 'yes'):
        clean_users()

    
    num_users = pyip.inputNum(min=0, prompt='enter the number of USERS you want to add: ')
    post_user(num_users)

    create_test_use_cases()

