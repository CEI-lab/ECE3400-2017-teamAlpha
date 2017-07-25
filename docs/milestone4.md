# Milestone 4: Maze-mapping robot
## Team Alpha

### Maze-mapping

For milestone 4, we created a maze-mapping robot and a basestation capable of showing the robot's progress. A video of the system can be seen at the bottom of this page. The robot portion of this milestone is almost the same as in milestone 3, with the exception of the navigation algorithm. The algorithm is an improved version of the baseline DFS we implemented in milestone 3. To solve transmit data back to the basestation, we integrated our maze-navigation code from milestone 3 with radio-transmission code from lab 4. Once we could successfully transmit the robot's coordinates and wall locations to the basestation Arduino, we worked to display this information on the FPGA. We were able to use our Verilog code from lab 4 as the baseline code to display the maze. We added additional support to display more complex graphics, display the done signal and mark all the unvisitable grid spaces. 

Video: https://youtu.be/knB0GVD2b5E

Note: The video does not show the 660Hz tone detection, treasure detection, or the 'done' signal the FPGA must play when the robot has finished traversing the maze. 
