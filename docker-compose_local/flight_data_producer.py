from flask import Flask, request
import requests, random, logging, traceback, os, json
from datetime import datetime, date, timedelta
from dotenv import load_dotenv
import pyinputplus as pyip
import csv, sys, argparse
import xlrd

from requests import cookies


app = Flask(__name__) 
load_dotenv()


#misc variables
DAYS_IN_A_WEEK = 7
DAY_INTERVAL = 2


logging.basicConfig(level=logging.INFO)



def parse_args(args):
    parser=argparse.ArgumentParser()

    parser.add_argument("-a", "--airports", default = os.getenv('AIRPORT_CSV_PATH'), type=str, help="airports file path")
    parser.add_argument("-d", "--database", default = 'local', type=str, help="RDS or localhost")
    parser.add_argument("-p", "--ports", action='store_true', help="Specify ports")
    parser.add_argument("-y", "--yes", action='store_true', help="run automated script")


    args, unknown = parser.parse_known_args(args)
    return args



#read csv library for airports
airport_library = []
try:        

    parser = parse_args(sys.argv[1:])

    AIRPORT_FILE_PATH = parser.airports

    host = os.getenv('LOCAL')

    #use RDS instance or local
    if parser.database == 'aws':
        host = os.getenv('RDS')

    flight_port = ''
    user_port = ''
    booking_port = ''
    #if there is no load balancer, then specify 5000 for users port, 5001 for flights, 5002 for bookings
    if parser.ports:
        flight_port = os.getenv("FLIGHT_PORT")
        user_port = os.getenv("USER_PORT")
        booking_port = os.getenv("BOOKING_PORT")

    #path variables
    REQ_GET_AIRPLANES = host+ flight_port +os.getenv('REQ_GET_AIRPLANES')
    REQ_GET_ROUTES = host+ flight_port +os.getenv('REQ_GET_ROUTES')
    REQ_GET_FLIGHTS = host+ flight_port +os.getenv('REQ_GET_FLIGHTS')
    REQ_GET_AIRPLANE_TYPES = host+ flight_port +os.getenv('REQ_GET_AIRPLANE_TYPES')
    REQ_GET_AIRPORTS = host+ flight_port +os.getenv('REQ_GET_AIRPORTS')

    REQ_POST_AIRPORT = host+ flight_port +os.getenv('REQ_POST_AIRPORT')
    REQ_POST_AIRPLANE_TYPE = host+ flight_port +os.getenv('REQ_POST_AIRPLANE_TYPE')
    REQ_POST_AIRPLANE = host+ flight_port +os.getenv('REQ_POST_AIRPLANE')
    REQ_POST_ROUTE = host+ flight_port +os.getenv('REQ_POST_ROUTE')
    REQ_POST_FLIGHTS = host+ flight_port +os.getenv('REQ_POST_FLIGHTS')

    REQ_DELETE_AIRPLANE_TYPES = host+ flight_port +os.getenv('REQ_DELETE_AIRPLANE_TYPES')
    REQ_DELETE_AIRPORTS = host+ flight_port +os.getenv('REQ_DELETE_AIRPORTS')

    REQ_LOGIN = host+user_port +os.getenv('REQ_LOGIN')



    #handle .csv and .xlsx files differently
    if AIRPORT_FILE_PATH.endswith('.csv'):

        with open(AIRPORT_FILE_PATH, 'r') as csv_file:
            logging.info('opening csv %s' %AIRPORT_FILE_PATH)
            csv_reader = csv.reader(csv_file)
            for line in csv_reader:
                airport_library.append({'iata_id': line[0], 'city': line[1]})

    elif AIRPORT_FILE_PATH.endswith('.xlsx'):
        loc = (AIRPORT_FILE_PATH)
        wb = xlrd.open_workbook(loc)
        sheet = wb.sheet_by_index(0)
        iata_col, city_col = None, None
        for i in range (len(sheet.row(0))):
            if sheet.row(0)[i].value == os.getenv('IATA_COL'):
                iata_col = i
            elif sheet.row(0)[i].value == os.getenv('CITY_COL'):
                city_col = i
        for i in range(1, sheet.nrows):
            iata_id = sheet.cell_value(i, iata_col)
            city = sheet.cell_value(i, city_col)
            if iata_id != '' and city != '':
                airport_library.append({
                    'iata_id': sheet.cell_value(i, iata_col),
                    'city': sheet.cell_value(i, city_col)
                })

    else:
        print('file must either be a csv or xslx file')
        exit()
except:
    logging.warning('could not open airports file from path')
    logging.warning('you will not be able to add AIRPORTS')


try:
    check_status = requests.get(REQ_GET_AIRPORTS)
except:

    print('could not connect to host')
    exit()


def get_airplane_types(cookies):
    response = requests.get(REQ_GET_AIRPLANE_TYPES, cookies=cookies)
    if(response.status_code == 401 or response.status_code == 403):
        print('insufficient authorization to read airplane types')
        return
    airplane_type_library = response.json()
    return [airplane_type['id'] for airplane_type in airplane_type_library]

def add_departure_time(departure_time_library, airplane_id, departure_time):
    departure_time = datetime.strptime(departure_time.replace('T', ' '), '%Y-%m-%d %H:%M:%S')

    if airplane_id in departure_time_library:
        departure_time_library[airplane_id].append(departure_time)
    else:
        departure_time_library[airplane_id] = [departure_time]


def get_flight(existing_departure_times):

    departure_time = datetime.now() + timedelta(days=DAYS_IN_A_WEEK) #try a departure time in a week from today

    logging.info("compiling all existing departure times of airplane")
    
    
    existing_departure_times.sort()
    logging.info("Filter existing departure times by dates before current day and sort by ascending")
    existing_departure_times= list(filter( lambda x: x > datetime.now(), existing_departure_times))


    for i in range(0, len(existing_departure_times)):

        if abs((existing_departure_times[i] - departure_time).days) <= 2:
            logging.info("Difference in number of days: %d" %abs((existing_departure_times[i]-departure_time).days))

            departure_time = existing_departure_times[i] + timedelta(days=(DAY_INTERVAL))

        else:
            break

    return str(departure_time.replace(microsecond=0))




def post_flight(num, cookies):
    airplanes = requests.get(REQ_GET_AIRPLANES, cookies=cookies).json()
    routes = requests.get(REQ_GET_ROUTES).json()

    if (num > 0 and (len(routes) < 1 or len(airplanes) < 1 )):
        print('there must be at least one route and at least one airplane to post a flight')
        exit()

    flight_library = requests.get(REQ_GET_FLIGHTS).json()
    flights = []
    
    departure_time_library = {}
    for flight in flight_library:
       add_departure_time(departure_time_library, flight['airplane_id'], flight['departure_time'])
    
    for i in range(num):
        airplane_id = random.choice(airplanes)['id']

        route_id = random.choice(routes)['id']
        departure_time = get_flight(departure_time_library[airplane_id] if airplane_id in departure_time_library else [])

        flight = { 'id': None, 'route_id':route_id, 'airplane_id':airplane_id, 'departure_time': departure_time,
        'reserved_seats': 0, 'seat_price' : 5*random.randint(20, 100)}

        add_departure_time(departure_time_library, airplane_id, departure_time)

        flights.append(flight)
        
    response = requests.post(REQ_POST_FLIGHTS, json = flights, cookies=cookies)
    if response.status_code == 401 or response.status_code == 403:
        print('insufficient authentication to post flight')
        return

def post_airport(num, cookies):

    existing_airports = requests.get(REQ_GET_AIRPORTS).json()
    for i in range(num):
        airport = None
        while(True):
            if len(existing_airports) >= len(airport_library):
                return cookies
            airport = random.choice(airport_library)
            if existing_airports.count(airport) == 0:
                existing_airports.append(airport)
                break
        logging.info('adding airport: %s, %s' %(airport['iata_id'], airport['city']))
        response = requests.post(REQ_POST_AIRPORT, json=airport, cookies=cookies)
        if response.status_code == 401 or response.status_code == 403:
            print('insufficient authentication to post airport')
            exit()       
        cookies = response.cookies
    return cookies

def post_airplane_type(num, cookies):

    for i in range(num):

        max_capacity = 50*random.randint(1, 5) + 25*random.randint(0, 1)

        airplane_type = {'max_capacity' : max_capacity}
        response = requests.post(REQ_POST_AIRPLANE_TYPE, json=airplane_type, cookies=cookies)
        if response.status_code == 401 or response.status_code == 403:
            print('insufficient authentication to post airplane type')
            exit()
        print('added airplane of type id: %s with max capacity: %s' %(response.json()['id'], max_capacity))
        cookies = response.cookies
    return cookies

def post_airplane(num, cookies):
    
    airplane_type_ids = get_airplane_types(cookies)
    if num > 0 and len(airplane_type_ids) < 1:
        print('there must be at least one airplane type in the database to create an airplane')
        exit()

    for i in range(num):
        type_id = airplane_type_ids[random.randint(0, len(airplane_type_ids))-1]
        logging.info('adding airplane of type %d' %type_id)
        airplane = {'type_id' : type_id}
        response = requests.post(REQ_POST_AIRPLANE, json=airplane, cookies=cookies)
        if response.status_code == 401 or response.status_code == 403:
            print('insufficient authentication to post airplane')
            exit()
        cookies = response.cookies
    return cookies

def post_route(num, cookies):
    airports = requests.get(REQ_GET_AIRPORTS).json()
    if num > 0 and len(airports) < 2:
        print('there must be at least two airports in the database to create a route')
        exit()

    existing_routes = requests.get(REQ_GET_ROUTES).json()
    existing_routes = [{'origin_id': r['origin_id'], 'destination_id': r['destination_id']} for r in existing_routes]

    
    for i in range(num):
        route = None
        while True:
            route = {'origin_id' : airports[random.randint(0, len(airports)-1)]['iata_id'],
                    'destination_id' : airports[random.randint(0, len(airports)-1)]['iata_id']}
            
            if route['origin_id'] == route['destination_id']:
                continue

            if existing_routes.count(route) == 0:
                existing_routes.append(route)
                break
        logging.info('adding route %s - %s' %(route['origin_id'], route['destination_id']))
        response = requests.post(REQ_POST_ROUTE, json = route, cookies=cookies)
        if response.status_code == 401 or response.status_code == 403:
            print('insufficient authentication to post route')
            exit()
        cookies = response.cookies
    return cookies
    
def delete_all_airplane_types(cookies):
    type_ids = get_airplane_types(cookies)
    for id in type_ids:
        logging.info('deleting airplane type %d' %id)
        response = requests.delete(REQ_DELETE_AIRPLANE_TYPES+str(id), cookies=cookies)
        if(response.status_code == 401 or response.status_code == 403):
            print('insufficient authorization to perform action')
            exit()
        cookies = response.cookies
    return cookies

def delete_all_airports(cookies):
    airports = requests.get(REQ_GET_AIRPORTS).json()
    for airport in airports:
        logging.info('deleting airport %s, %s' %(airport['iata_id'], airport['city']))
        response = requests.delete(REQ_DELETE_AIRPORTS+airport['iata_id'], cookies=cookies)
        if(response.status_code == 401 or response.status_code == 403):
            print('insufficient authorization to perform action')
            exit()
        cookies = response.cookies
    return cookies

def login(username, password):
    credentials = {'username': username, 'password' : password}
    response = requests.post(REQ_LOGIN, json= credentials)
    if response.status_code == 401:
        print('invalid user credentials')
    return response.cookies

if __name__ == '__main__':

    if parser.yes:
        cookies = login(os.getenv("ADMIN_USERNAME"), os.getenv("ADMIN_PASSWORD"))
        cookies = post_airport(int(os.getenv("DEFAULT_LOAD_SIZE")), cookies=cookies)
        cookies = post_route(int(os.getenv("DEFAULT_LOAD_SIZE")), cookies=cookies)
        cookies = post_airplane_type(int(os.getenv("DEFAULT_LOAD_SIZE")), cookies=cookies)
        cookies = post_airplane(int(os.getenv("DEFAULT_LOAD_SIZE")), cookies=cookies)
        post_flight(int(os.getenv("DEFAULT_LOAD_SIZE")), cookies=cookies)
        exit()



    print('Please Login')
    cookies = None

    while True:
        print('username: ')
        username = input()
        print('password:')
        password = input()
        cookies = login(username, password)
        if cookies:
            break
        
    print('would you like to clean the database?')
    if(pyip.inputYesNo('delete all airports in db? (y/n): ') == 'yes'):
        try:
            cookies = delete_all_airports(cookies=cookies)
        except:
            print('something went wrong with deleting airports')
    
    if(pyip.inputYesNo(prompt='delete all airplane types? (y/n): ') == 'yes'):
        try:
            cookies = delete_all_airplane_types(cookies=cookies)
        except:
            print('something went wrong with deleting airplane types')

    num_airports = pyip.inputNum(min=0, prompt='enter the number of AIRPORTS you want to add: ')
    num_routes = pyip.inputNum(min=0, prompt='enter the number of ROUTES you want to add: ')
    num_airplane_types = pyip.inputNum(min=0, prompt='enter the number of AIRPLANE TYPES you want to add: ')
    num_airplanes = pyip.inputNum(min=0, prompt='enter the number of AIRPLANES you want to add: ')
    num_flights = pyip.inputNum(min=0, prompt='enter the number of FLIGHTS you want to add: ')

    cookies = post_airport(num_airports, cookies=cookies)
    cookies = post_route(num_routes, cookies=cookies)
    cookies = post_airplane_type(num_airplane_types, cookies=cookies)
    cookies = post_airplane(num_airplanes, cookies=cookies)
    post_flight(num_flights, cookies=cookies)

    











