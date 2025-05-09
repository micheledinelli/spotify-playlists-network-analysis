import pandas as pd
import pickle
import networkx as nx
import os

def load_network(path: str) -> nx.Graph:
    """
    Loads a network from a file and returns it as a NetworkX graph.
    Args:
        path (str): The path to the file containing the network data.
    Returns:
        nx.Graph: The loaded network as a NetworkX graph.
    """
    
    if not os.path.exists(path):
        raise FileNotFoundError(f"The file {path} does not exist.")

    G = pickle.load(open(path, 'rb'))
    return G
