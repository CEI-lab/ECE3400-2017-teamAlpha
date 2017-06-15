# Lab 3: Digital Logic
## Team Alpha, ECE 3400, Fall 2017

_Goal:_ 
Output data from an Arduino through an FPGA to a screen driver. 

We worked in two sub-teams. Team 1 sent data from the Arduino to the FPGA and converted this to something that made sense on the screen - we decided to display a 2-by-2 array of bits. Team 2 displayed the array on the screen and continuously updated it. 
First we had to agree on an interface, in our case this is the 2-by-2 array, defined as:

```verilog
reg grid_array [1:0][1:0]; //[rows][columns]
wire [1:0] grid_coord_x; //Index x into the array
wire [1:0] grid_coord_y; //Index y into the array
```

By the end of the lab, we merged the two codes into one, such that we could flip a bit on the Arduino side, and see the change on the screen. In the future we will extend this to work with a full maze layout. 


_Lab, team 1:_

It is very important to remember that the FPGA only takes 3.3V inputs, the Arduino gives out 5V: do not connect pins directly!! We used a voltage divider to solve this issue.

[![Arduino_FPGA_interface](http://img.youtube.com/vi/0Av38ixX900/0.jpg)](https://youtu.be/0Av38ixX900)


_Lab, team 2:_

We were given a VGA module to drive the screen. Reading through this module, we understand that it works as the illustrated sketch. Our job will be to modify the main module. 

<img src="/docs/images/FPGA_screen_driver.png" alt="FPGA_screen_driver_module" width="600" height="232">

First, we changed the color of the screen to green, blue, and red.

```verilog
assign PIXEL_COLOR = 8'b000_000_00 \\black
assign PIXEL_COLOR = 8'b111_000_00 \\red
assign PIXEL_COLOR = 8'b000_111_00 \\green
assign PIXEL_COLOR = 8'b000_000_11 \\blue
```
(Fyi, underscores in Verilog are ignored by the compiler, they're just there for readability!)

Second, we drew a black square on a red screen, using an if-statement in a combinatorial block: 

```verilog
always @ (*) begin 
  if(PIXEL_COORD_X < 10'd64 && PIXEL_COORD_Y < 10'd64) begin
    PIXEL_COLOR = 8'b000_000_00;
  end
  else begin
    PIXEL_COLOR = 8'b111_000_00;
  end
end
```
The signal inside the bracket is called a sensitivity list. An asterix means that the block will run when any of the signals inside change. We are comparing our 10-bit pixel coordinates to constants. These constants are defined as 10-bits (10), decimal value (d), 64.

Third, we want to draw a two by two grid. 
```verilog
reg grid_array [1:0][1:0]; //2-by-2 array of [rows][columns]
```

Next, we want to have a 2-by-2 grid and update the value in each square depending on the 2-by-2 array of registers. Each register in the array holds the state information for one square of the grid: 0 for unhighlighted, and 1 for highlighted. 

To accomplish this, we must first have some way of determining if the current pixel output by the VGA driver is in the grid, and if so, what square it is in. In order to create modularity in our code, we decided to write a new module that we could instantiate in our top-level module. The module takes in the current x- and y- coordinates from the VGA driver and outputs a 0 or 1 according to the grid space it is in, OR a 2 if the pixel is simply not in the grid. This module is shown below. 

```verilog
`define GRID_TOP_LEFT_X 0   //Potential offset from the corner
`define GRID_TOP_LEFT_Y 0   //Potential offset from the corner
`define BLOCK_SIZE      64  //Each block will be 64 by 64 pixels

module VGACOORD_2_GRIDCOORD(
  vga_pixel_x,  
  vga_pixel_y,
  grid_coord_x,
  grid_coord_y
  );  //Specify all inputs and outputs to the module

  input  [9:0] vga_pixel_x;   //Specify the direction and number of bits in the signal
  input  [9:0] vga_pixel_y;
  output reg [1:0] grid_coord_x;
  output reg [1:0] grid_coord_y;
  
  always @ (*) begin          //begin combinatorial logic to determine which block the pixel is in
    if (vga_pixel_x < `BLOCK_SIZE && vga_pixel_y < `BLOCK_SIZE) begin               //Upper left block
      grid_coord_x = 0;
      grid_coord_y = 0;
    end
    else if (vga_pixel_x < `BLOCK_SIZE && vga_pixel_y < `BLOCK_SIZE * 2) begin      //Lower left block
      grid_coord_x = 0;
      grid_coord_y = 1;
    end
    else if (vga_pixel_x < `BLOCK_SIZE * 2 && vga_pixel_y < `BLOCK_SIZE) begin      //Uper right block
      grid_coord_x = 1;
      grid_coord_y = 0;
    end
    else if (vga_pixel_x < `BLOCK_SIZE * 2 && vga_pixel_y < `BLOCK_SIZE * 2) begin  //Lower right block
      grid_coord_x = 1;
      grid_coord_y = 1;
    end
    else begin                                                                      //Not in the grid
      grid_coord_x = 2;                                               
      grid_coord_y = 2; 
    end
  end
\
endmodule
```

Now we change the main module to instantiate our module and set a color according to the grid coordinate of the current pixel.

```verilog

VGACOORD_2_GRIDCOORD vgacoord_2_gridcoord(    //Instantiate module
  .vga_pixel_x(PIXEL_COORD_X),                //The text after the periods refers to internal wires in the module
  .vga_pixel_y(PIXEL_COORD_Y),                //The text in the parantheses refers to wires external to the module
  .grid_coord_x(grid_coord_x),
  .grid_coord_y(grid_coord_y)
  );

//Always run:
if (grid_coord_x < 2 && grid_coord_y < 2) begin                                   //If within grid
  if (grid_array[grid_coord_y][grid_coord_x] == 1) begin                          //If array reads 1, color square red
    PIXEL_COLOR <= 8'b111_000_00;
  end
  else begin
    PIXEL_COLOR <= 8'b111_111_11;
  end
  else begin
    PIXEL_COLOR <= 9'b000_000_00;
  end
end
```
<img src="/docs/images/FPGA_screen.png" alt="FPGA_control_of_screen" width="400" height="225"> 

_Concluding Remarks:_

Finally, we have to think about how this will work for our final system. We will have to display the full maze on the screen, including treasures, walls, unknown and travelled areas, and the robot itself. We also need to be able to display when the robot has finished traversing the maze.  Here are the questions we discussed:

* How will we display the maze?
* Will it still make sense to use parallel communication between the Arduino and the FPGA when you include all the states?
* Standardized coordinate system. How do we display the coordinates on the screen? How does the robot think about the maze as it travels? The standard way to interpret images and screens is to place the origin in the upmost left corner, making the positive x direction towards the right, and the positive y-direction downwards. 

