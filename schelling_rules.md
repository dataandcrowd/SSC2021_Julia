Definition of the Schelling model:

* Agents live in a two-dimensional grid with a Chebyshev metric (this means that there are 8 neighbors around each grid point).
* Agents belong to one of two groups (1 or 2) and can be happy or unhappy.
* Each position of the grid can be occupied by at most one agent and the model is populated by `N < MxM` agents, half from each group, initially all unhappy.

At each step of the simulation, each agent does the following:
* The agent counts the nearby agents that belong to the same group. If these are at least `min_to_be_happy`, then our agent is happy and says put.
* If the agent is unhappy, it moves to a random new location.
