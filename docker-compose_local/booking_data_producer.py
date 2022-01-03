from flask import Flask, request
import json, requests, random, logging, traceback, os
from datetime import date, datetime
from faker import Faker
from rstr import Rstr
from dotenv import load_dotenv
import pyinputplus as pyip
import sys, argparse

app = Flask(__name__)
load_dotenv()

def parse_args(args):
    parser=argparse.ArgumentParser()

    parser.add_argument("-a", "--airports", default = os.getenv('AIRPORT_CSV_PATH'), type=str, help="airports file path")
    parser.add_argument("-d", "--database", default = 'local', type=str, help="RDS or localhost")
    parser.add_argument("-p", "--ports", action='store_true', help="Specify ports")
    parser.add_argument("-y", "--yes", action='store_true', help="run automated script")
    
    args, unknown = parser.parse_known_args(args)
    return args


parser = parse_args(sys.argv[1:])

#use RDS host or local host
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

REQ_GET_USERS = host+user_port+os.getenv('REQ_GET_USERS')
REQ_GET_AIRPORTS = host+flight_port+os.getenv('REQ_GET_AIRPORTS')
REQ_GET_BOOKINGS = host+booking_port+os.getenv('REQ_GET_BOOKINGS')
REQ_POST_BOOKINGS = host+booking_port+os.getenv('REQ_POST_BOOKINGS')
REQ_DELETE_BOOKING = host+booking_port+os.getenv('REQ_DELETE_BOOKING')
REQ_LOGIN = host+user_port+os.getenv('REQ_LOGIN')
REQ_GET_FLIGHTS = host+flight_port+os.getenv('REQ_GET_FLIGHTS')

try:
    requests.get(REQ_GET_AIRPORTS)
except:
    print('could not connect to host')
    exit()


TRAVELER = int(os.getenv('TRAVELER'))
GUEST = 'guest'


fake = Faker()


logging.basicConfig(level=logging.INFO)




def generate_passengers():
    passengers = []

    rand = random.randint(1, 10)

    logging.info("Generate %d random passengers" %rand)

    for i in range(0, rand):
         gender =  "male"  if  random.randint(0, 1) ==0  else "female"
         passengers.append({"given_name" : fake.first_name(), 
                            "family_name" : fake.last_name(), 
                            "dob": str(fake.date_between_dates(date_start=datetime(1920,1,1), date_end=datetime(2019,12,31))), 
                            "gender": gender, 
                            "address": fake.address().split("\n")[0][:45]})
    return passengers



def post_booking_agent(user_library, flight_library, num):

    agents = list(filter(lambda x : x['role_id'] != TRAVELER, user_library))

    if len(agents) == 0:
        print('no agents available to book with')
        return

    if len(flight_library) == 0:
        print('no flights to book')
        exit()
    for i in range(num):
        agent = random.choice(agents)
        flight = random.choice(flight_library)
        logging.info('post booking with username %s to flight %d' %(agent['username'], flight['id']))

        booking = {'passengers' : generate_passengers()}


        response = requests.post(REQ_POST_BOOKINGS+'flight=' + str(flight['id'])+'/' +'user='+str(agent['id']), json=booking)

def post_booking_user(user_library, flight_library, num):

    travelers = list(filter(lambda x : x['role_id'] == TRAVELER, user_library))
    
    if len(travelers) == 0:
        print('no travelers to book with')
        return
    if len(flight_library) == 0:
        print('no flights to book')
        exit()

    for i in range(num):
        user = random.choice(travelers)
        flight = random.choice(flight_library)
        logging.info('post booking with username %s to flight %d' %(user['username'], flight['id']))

        booking = {'passengers' : generate_passengers()}

        response = requests.post(REQ_POST_BOOKINGS+'flight=' + str(flight['id'])+'/' +'user='+str(user['id']), json=booking)

def post_booking_guest(flight_library, num):

    for i in range(num):
        booking_guest = {"contact_email": generate_email(), "contact_phone": generate_phone()}
        flight = random.choice(flight_library)
        logging.info('post booking with email %s to flight %d' %(booking_guest['contact_email'], flight['id']))
        booking = {'booking_guest' : booking_guest, 'passengers': generate_passengers()}

        response = requests.post(REQ_POST_BOOKINGS+'flight='+str(flight['id'])+'/'+'user='+GUEST, json=booking)




def generate_phone():
    rstr = Rstr()
    return rstr.xeger(r'((909)|(626)|(900)|(714))-[0-9]{3}-[0-9]{4}')


def generate_email():
    return fake.email()

def delete_bookings(cookies):

    response = requests.get(REQ_GET_BOOKINGS, cookies=cookies)
    if response.status_code == 401 or response.status_code == 403:
        print('insufficient authorization to read bookings')
        exit()
    booking_ids = [b['id'] for b in response.json()]


    for id in booking_ids:
        logging.info('delete booking %d' %id)
        response = requests.delete(REQ_DELETE_BOOKING+str(id))
        if response.status_code == 401 or response.status_code == 403:
            print('insufficient authorization to delete booking %d' %id)
            exit()

def login(username, password):
    credentials = {'username': username, 'password' : password}
    response = requests.post(REQ_LOGIN, json= credentials)
    if response.status_code == 401:
        print('invalid credentials')
        return None
    return response.cookies




if __name__ == '__main__':

    if parser.yes:
        cookies = login(os.getenv("ADMIN_USERNAME"), os.getenv("ADMIN_PASSWORD"))

        user_library = requests.get(REQ_GET_USERS, cookies=cookies).json()
        flight_library = requests.get(REQ_GET_FLIGHTS).json()
        post_booking_agent(user_library, flight_library, int(os.getenv("DEFAULT_LOAD_SIZE")))
        post_booking_user(user_library, flight_library, int(os.getenv("DEFAULT_LOAD_SIZE")))
        post_booking_guest(flight_library, int(os.getenv("DEFAULT_LOAD_SIZE")))
        exit()


    while True:
        print('please login')
        print('username:')
        username = input()
        print('password:')
        password = input()
        cookies = login(username, password)
        if cookies:
            break

    print('would you like to clean the BOOKING database?')
    if(pyip.inputYesNo('delete all bookings in db? (y/n): ') == 'yes'):
        try:
            delete_bookings(cookies)
        except:
            traceback.print_exc()
            logging.error('could not delete bookings')
            exit()

      
    num_booking_agents = pyip.inputNum(min=0, prompt='enter the number of BOOKING AGENTS you want to add: ')

    num_booking_users = pyip.inputNum(min=0, prompt='enter the number of BOOKING USERS you want to add: ')

    num_booking_guests = pyip.inputNum(min=0, prompt='enter the number of BOOKING GUESTS you want to add: ')

    try:
        user_library = requests.get(REQ_GET_USERS, cookies=cookies).json()
        flight_library = requests.get(REQ_GET_FLIGHTS).json()

        post_booking_agent(user_library, flight_library, num_booking_agents)
        print('create booking_user')
        post_booking_user(user_library, flight_library, num_booking_users)
        print('create booking_guest')
        post_booking_guest(flight_library, num_booking_guests)
    except:
        traceback.print_exc()
        logging.warning('unable to perform action. admin privilege required')

    

