# Milestone 1: Maze navigation algorithm
## Team Alpha

We used the standard depth-first search (DFS) algorithm to navigate the maze. The maze can be thought of as a graph, where each grid space on the maze is a node in the graph. Adjacent, unblocked grid spaces on the maze are connected nodes in the graph. 

### Matlab simulation

We first wrote a Matlab simulation to test our algorithm. This allowed us to see the efficiency of the algorithm for various maze configurations and make any changes we wanted to. You can read through the Matlab code to understand the details of the simulation. A video of the simulation is shown below.

Note: We implemented a very baseline algorithm. You'll see that the robot traverses the maze very inefficiently, especially when there are unvisitable areas. There are many improvements you can make to this algorithm to make it as efficient as possible!

### Real-time maze mapping

Once we were happy with our algorithm in simulation, we worked on implementing real-time navigation using that algorithm. We were able to use our line-following/turning code from Milestone 1. We also needed to be able to read the locations of front, left, and right walls at every intersection. For wall detection, it was very important to translate the relative wall locations (front, left, right of the robot) into global wall locations (north, south, east, and west of the maze). In our code, you'll see that the navigation algorithm is the same as the algorithm in the Matlab simulation, with some additional support for getting wall information and moving the robot. Below is a video of the robot traversing a maze with the same wall configuration as in the simulation video above.

**Insert video here** 