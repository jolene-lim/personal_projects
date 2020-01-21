import data_import
import visualization
from ortools.constraint_solver import routing_enums_pb2
from ortools.constraint_solver import pywrapcp


def main():

    # Get user input
    print("How many volunteers:")
    n_vehicles = int(input())
    print("Max distance(m) for each volunteer")
    max_dist = int(input())

    # Instantiate the data problem.
    data = {'origin': data_import.build_origin(True),
            'destination': data_import.build_dest(True),
            'distance_matrix': data_import.create_dist_matrix(),
            'num_vehicles': n_vehicles,
            'depot': 0}

    # Create the routing index manager.
    manager = pywrapcp.RoutingIndexManager(len(data['distance_matrix']),
                                           data['num_vehicles'], data['depot'])

    # Create Routing Model.
    routing = pywrapcp.RoutingModel(manager)

    # Create and register a transit callback.
    def distance_callback(from_index, to_index):
        """Returns the distance between the two nodes."""
        # Convert from routing variable Index to distance matrix NodeIndex.
        from_node = manager.IndexToNode(from_index)
        to_node = manager.IndexToNode(to_index)
        return data['distance_matrix'][from_node][to_node]

    transit_callback_index = routing.RegisterTransitCallback(distance_callback)

    # Define cost of each arc.
    routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)

    # Add Distance constraint.
    dimension_name = 'Distance'
    routing.AddDimension(
        transit_callback_index,
        0,  # no slack
        max_dist,  # vehicle maximum travel distance
        True,  # start cumul to zero
        dimension_name)
    distance_dimension = routing.GetDimensionOrDie(dimension_name)
    distance_dimension.SetGlobalSpanCostCoefficient(100)

    # Setting first solution heuristic.
    search_parameters = pywrapcp.DefaultRoutingSearchParameters()
    search_parameters.first_solution_strategy = (
        routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC)

    # Solve the problem.
    solution = routing.SolveWithParameters(search_parameters)

    # Print solution on console.
    if solution:
        locations = visualization.geocode(data['origin']) + visualization.geocode(data['origin'])
        add_dict = data_import.build_origin(False) + data_import.build_dest(False)

        visualization.print_solution(data, manager, routing, solution)
        visualization.visualize(data, locations, add_dict, manager, routing, solution)
    else:
        print("No solution found :( Try adjusting parameters")


if __name__ == '__main__':
    main()
