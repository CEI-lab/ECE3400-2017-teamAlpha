# Milestone 1: Line-following
## Team Alpha

### Line following


First, we worked on getting the robot to follow a black line on a white background. We began by testing the line sensors to get a sense of what values to expect over light and dark surfaces. This was how we determined the threshold values in the Arduino code. Once we had a could determine if of the center of the robot was over a light or dark surface, we were able to use this information to write a simple control algorithm. If either center sensor is over a white surface, the robot will turn left or right to re-position itself over the line. If both the center sensors are over the line, the robot continues to drive forward. 

We used four QRE113 line sensors arranged in the following configuration. As noted in the image, the center two sensors are for keeping the robot on the line it is on, and the two outer sensors are for detecting when the robot has reached an intersection. 

<img src="/docs/images/m1_linesensor.png" alt="Line Sensor Configuration" width="530" height="300">

We needed to connect the sensors to the Arduino via an analog mux since we ran out of analog pins on our final robot. The mux we used has 3 select pins, which are connected to digital pins on the Arduino. The select pins are used the choose from one of the eight analog inputs on the mux. The zInput pin on the mux is connected to an analog pin on the Arduino.

See video of robot following a line here:

[![Line following robot](http://img.youtube.com/vi/TijvBkSl2sc/0.jpg)](http://www.youtube.com/watch?v=TijvBkSl2sc)

### Figure-8

Next, we added turning functionality. As mentioned above, we used two additional line sensors to detect when a robot has arrived at an intersection. Our turning algorithm assumes that the robot is at an intersection. The robot begins its turn by turning off the current line that it is on, and stops turning when the two center sensors have found a new line.

See video of robot moving in a figure-8 here:

[![Figure-8](http://img.youtube.com/vi/rAPimu52CVM/0.jpg)](http://www.youtube.com/watch?v=rAPimu52CVM)
