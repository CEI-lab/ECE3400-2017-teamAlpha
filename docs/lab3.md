# Lab 3: Digital Logic
## Team Alpha, ECE 3400, Fall 2017

_Goal: Take at least two external inputs to the FPGA and display them to a screen driver. Output a sound when done signal is high._

We decided to connect two toggle switches and show the change in a 2-by-2 grid on the screen. Later, this code can be expanded to display the full maze. We worked in two sub-teams. Team 1 took in data from the switches, Team 2 displayed the array on the screen. 
The following figure shows our task assignment:

<img src="/docs/images/lab3_team_assignment.png" alt="lab3_assignment" width="600" height="134"> 

We also had to agree on an interface between our code segments, in our case this is the 2-by-2 array of bits: 

```verilog
reg grid_array [1:0][1:0]; //[rows][columns]
wire [1:0] grid_coord_x; //Index x into the array
wire [1:0] grid_coord_y; //Index y into the array
```

_Lab3, team 1:_

We connected two toggle switches to pins on the FPGA. Switch one control the x-coordinate, switch two the y-coordinate of the highlighted square:

```verilog
	 // current highlighted square, input through GPIO pins
	 wire highlighted_x;
	 wire highlighted_y;	 
	 assign highlighted_x = GPIO[33];
	 assign highlighted_y = GPIO[31];
```

To check our code before the screen driver was ready from Team 2, we also connected four of the LEDs on the FPGA board:

```verilog
assign LED[0] = grid_array[0][0];
assign LED[1] = grid_array[0][1];
assign LED[2] = grid_array[1][0];
assign LED[3] = grid_array[1][1];
```

We then made a state machine that loops through each register in the array and determines if those correspond to the position set by the switches (highlighted_x and highlighted_y):

<img src="/docs/images/FPGA_state_machine.png" alt="FPGA_state_machine" width="250" height="85"> 

```verilog

// State 0: Loop through grid
if (state == 0) begin
  if (grid_ind_x < 1) begin         //If X-coordinate is 0
    grid_ind_x <= grid_ind_x + 1;   //X-coordinate = 1
  end
  else begin                        //If X-coordinate is 1
    grid_ind_x <= 0;                //X-coordinate = 0
    if (grid_ind_y < 1) begin       //If Y-coordinate is 0
      grid_ind_y <= grid_ind_y + 1; //Y-coordinate = 1
    end
    else begin                      //else Y-coordinate = 0
      grid_ind_y <= 0;
    end
  end
  state <= 1;                       //Switch to state 1
end // state 0

// State 1: If at highlighed coordinates, set grid space to 1, else set to 0
else if (state == 1) begin
  if (grid_ind_x == highlighted_x && grid_ind_y == highlighted_y) begin
    grid_array[grid_ind_y][grid_ind_x] <= 1;
  end
  else begin
    grid_array[grid_ind_y][grid_ind_x] <= 0;
  end
  state <= 0;
end // state 1

else begin                          //Default
  state <= state;
end
```

INSERT VIDEO OF LEDs!

Finally, we implemented our code in a separate module so that we could easily merge this with the code of Team 2 at the end of the lab.

_Sound generation_

First, we began by implementing the most basic sound wave - a square wave. We chose to generate a 440Hz wave and output this to  GPIO pin. For this, we wrote a simple state machine to increment a counter and output a pulse based on the value of that counter. Generating a wave of a certain frequency requires considering the frequency that our state machine is clocked at and choosing a counter value based on that to give us our desired frequency. The state machine clock is 25MHz, which means the period of the 440Hz wave will be approximately 56818 cycles (25MHz/440Hz) of the state machine clock period. In other words, square pulse must toggle every 25MHz/440Hz/2 cycles. The code to achieve that as well as a picture of our 440Hz square wave shown below.

```verilog
// Local parameter
localparam CLKDIVIDER_440 = 25000000/440/2;

// Sound variables
reg square_440;                       // 440 Hz square wave
assign GPIO[0] = square_440;
reg [15:0] counter;

// Sound state machine
always @ (posedge CLOCK_25) begin
  if (counter == 0) begin
    counter    <= CLKDIVIDER_440 - 1; // reset clock
    square_440 <= ~square_440;        // toggle the square pulse
  end
  else begin
    counter    <= counter - 1;
    square_440 <= square_440;
  end
end	
```
<img src="/docs/images/square_440.png" alt="440Hz square wave from GPIO pin" width="250" height="85"> 

_Lab 3, team 2:_

We were given a VGA module to drive the screen. We read through this module carefully, and came to the conclusion that it works like the following sketch illustrates. Our job will be to modify the main module. 

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

Third, we want to draw four boxes on the screen and color them dependent on the values in our array (0 for not highlighted, and 1 for highlighted). 

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


_Merging the code:_

Finally, we merged our code so that the switches toggled the state of the screen:



_Concluding Remarks:_

Finally, we have to think about how this will work for our final system. We will have to display the full maze on the screen, including treasures, walls, unknown and travelled areas, and the robot itself. We also need to be able to display when the robot has finished traversing the maze.  Here are the questions we discussed:

* How will we display the maze? Do we stick with a similar array approach to hold the state of each grid space?
* Will it still make sense to use parallel communication between the Arduino and the FPGA when you include all the states? How many bits total will we need to convey all the information at every new location?
* Standardized coordinate system. How do we display the coordinates on the screen? How does the robot think about the maze as it travels? The standard way to interpret images and screens is to place the origin in the upmost left corner, making the positive x direction towards the right, and the positive y-direction downwards. 

_Great links:_

* Very useful links with code examples: http://www.fpga4fun.com/
