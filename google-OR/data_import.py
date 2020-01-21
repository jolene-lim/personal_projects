# Setup
import configparser
import requests

config = configparser.ConfigParser()
config.read('config.ini')


# Create dist matrix
def create_dist_matrix():
    # Create data
    origin = build_origin(False)
    destination = build_dest(False)
    data = origin + destination

    api_key = config['GOOGLE']['dist_matrix_key']

    # Prepare API Query
    num_addresses = len(data)
    max_pairs = 100 // num_addresses

    q, r = divmod(num_addresses, max_pairs)
    dest_addresses = data
    distance_matrix = []

    # Query
    for i in range(q):
        origin_addresses = data[i * max_pairs: (i + 1) * max_pairs]
        response = send_request(origin_addresses, dest_addresses, api_key)
        distance_matrix += build_distance_matrix(response)

    if r > 0:
        origin_addresses = data[q * max_pairs: q * max_pairs + r]
        response = send_request(origin_addresses, dest_addresses, api_key)
        distance_matrix += build_distance_matrix(response)

    return distance_matrix


def send_request(origin_addresses, dest_addresses, api_key):
    def build_address_str(addresses):
        # Build a pipe-separated string of addresses
        address_str = ''
        for i in range(len(addresses) - 1):
            address_str += addresses[i] + '|'
        address_str += addresses[-1]
        return address_str

    request = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric'
    origin_address_str = build_address_str(origin_addresses)
    dest_address_str = build_address_str(dest_addresses)
    request = request + '&origins=' + origin_address_str + '&destinations=' + dest_address_str + '&key=' + api_key
    response = requests.get(request).json()
    return response


def build_distance_matrix(response):
    distance_matrix = []
    for row in response['rows']:
        row_list = [row['elements'][j]['distance']['value'] for j in range(len(row['elements']))]
        distance_matrix.append(row_list)
    return distance_matrix


# Choose origin and destination
def build_origin(clean_str):
    options = get_origins("voluntarywelfareorgs")['SrchResults']
    del options[0]
    output = []
    for vwo in options:
        if vwo['NAME'] == 'Beyond Social Services - REACH network':
            if clean_str:
                address = vwo['ADDRESSBLOCKHOUSENUMBER'] + ",+" + vwo['ADDRESSSTREETNAME'] \
                          + ",+SINGAPORE" + vwo['ADDRESSPOSTALCODE']
                address = address.replace(" ", "+")
            else:
                address = vwo['ADDRESSBLOCKHOUSENUMBER'] + ", " + vwo['ADDRESSSTREETNAME'] \
                          + ", SINGAPORE " + vwo['ADDRESSPOSTALCODE']
                address = address.title()
            output.append(address)
    return output


def build_dest(clean_str):
    options = get_destinations()['result']['records']
    addresses = []
    for bldg in options:
        n_rentals = int(bldg['1room_rental']) + int(bldg['2room_rental']) + \
                    int(bldg['3room_rental']) + int(bldg['other_room_rental'])
        if n_rentals > 0:
            address = bldg['blk_no'] + ", " + bldg['street'] + ", " + "Singapore"
            address = address.title()
            if clean_str:
                address = address.replace(" ", "+").upper()
            addresses.append([address, n_rentals])

    addresses.sort(key = lambda x: x[1])

    top15 = []
    for row in addresses:
        top15.append(row[0])
    top15 = top15[0:15]

    return top15


# Create origin and destination options
def get_origins(theme):
    url = "https://developers.onemap.sg/privateapi/themesvc/retrieveTheme?"
    url = url + "queryName=" + theme + "&token=" + get_onemap_token()

    response = requests.get(url).json()

    return response


def get_destinations():
    url = "https://data.gov.sg/api/action/datastore_search?"
    url += "resource_id=482bfa14-2977-4035-9c61-c85f871daf4e" + '&q={"bldg_contract_town":"BM"}' + '&limit=100000'

    resp = requests.get(url).json()

    return resp


# Create token
def get_onemap_token():
    API_endpoint = "https://developers.onemap.sg/privateapi/auth/post/getToken"
    auth = {'email': (None, config['ONEMAPSG']['email']),
            'password': (None, config['ONEMAPSG']['password'])}

    no_file_multipart_req = requests.Request('POST', API_endpoint, files = auth).prepare()
    s = requests.Session()
    resp = s.send(no_file_multipart_req)
    token = resp.json()['access_token']

    return token


