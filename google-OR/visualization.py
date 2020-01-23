import configparser
import requests
import folium
from ratelimit import limits
config = configparser.ConfigParser()
config.read('config.ini')


def print_solution(data, manager, routing, solution):
    """Prints solution on console."""
    max_route_distance = 0
    for vehicle_id in range(data['num_vehicles']):
        index = routing.Start(vehicle_id)
        plan_output = 'Route for vehicle {}:\n'.format(vehicle_id)
        route_distance = 0
        while not routing.IsEnd(index):
            plan_output += ' {} -> '.format(manager.IndexToNode(index))
            previous_index = index
            index = solution.Value(routing.NextVar(index))
            route_distance += routing.GetArcCostForVehicle(
                previous_index, index, vehicle_id)
        plan_output += '{}\n'.format(manager.IndexToNode(index))
        plan_output += 'Distance of the route: {}m\n'.format(route_distance)
        print(plan_output)
        max_route_distance = max(route_distance, max_route_distance)
    print('Maximum of the route distances: {}m'.format(max_route_distance))


def visualize(data, locations, add_dict, manager, routing, solution):

    # Create map
    output_map = folium.Map(
        location = (locations[0][0] - 0.01, locations[0][1] - 0.005),
        zoom_start = 14,
    )

    # Draw route lines
    for vehicle_id in range(data['num_vehicles']):
        vehicle_route = []
        route_distance = 0

        index = routing.Start(vehicle_id)
        while not routing.IsEnd(index):
            node = manager.IndexToNode(index)
            vehicle_route.append(locations[node])
            plot(output_map, locations[node], add_dict[node], node, 'cadetblue')
            previous_index = index
            index = solution.Value(routing.NextVar(index))
            route_distance += routing.GetArcCostForVehicle(previous_index, index, vehicle_id)

        node = manager.IndexToNode(index)
        vehicle_route.append(locations[node])
        plot(output_map, locations[node], add_dict[node], node, 'red')

        if route_distance > 0:
            folium.PolyLine(
                vehicle_route,
                color = get_color(vehicle_id),
                tooltip = ('<b>Person ID</b>: ' + str(vehicle_id) + '<br>'
                           '<b>Distance Travelled</b>: ' + str(route_distance) + 'm<br>')
            ).add_to(output_map)

    output_map.save("route_planning.html")


def plot(target_map, point, add, node_id, color):
    folium.CircleMarker(
        location = (point[0], point[1]),
        color = color,
        fill = True,
        fill_opacity = 0.7,
        tooltip = ('<b>Node</b>: ' + str(node_id) + '<br>'
                   '<b>Address:</b> ' + add + '<br>')
    ).add_to(target_map)


def get_color(vehicle_id):
    color_dict = {0: 'red', 1: 'blue', 2: 'green', 3: 'purple', 4: 'orange', 5: 'darkred',
                  6: 'lightred', 7: 'beige', 8: 'darkblue', 9: 'darkgreen', 10: 'cadetblue',
                  11: 'darkpurple', 12: 'white', 13: 'pink', 14: 'lightblue', 15: 'lightgreen',
                  16: 'gray', 17: 'black', 18: 'lightgray'}

    output = color_dict[vehicle_id % 18]
    return output


@limits(calls = 50, period = 1)
def geocode(address_list):
    latlng_list = []
    api_key = config['GOOGLE']['dist_matrix_key']

    for add in address_list:
        req = "https://maps.googleapis.com/maps/api/geocode/json"
        params = {'key': api_key,
                  'address': add}
        resp = requests.get(req, params = params).json()
        lat = resp['results'][0]['geometry']['location']['lat']
        lng = resp['results'][0]['geometry']['location']['lng']
        latlng_list.append((lat, lng))

    return latlng_list




