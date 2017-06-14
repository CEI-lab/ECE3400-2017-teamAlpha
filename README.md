# ECE 3400 2017: Team Alpha

Our team members: Claire Chen, Christopher Fedors, Ryan O'Hern, and Kirstin Petersen

This website describes useful links, solutions to the labs, and our final robot, we hope you will find it useful and create much better websites yourselves!

## Lab 1: Microprocessors

//Goal:// 

The goal of this lab is to get acquainted with the Arduino Uno and to build and control a basic robot. 

//Lab://

First, we installed the Arduino IDE from this link: https://www.arduino.cc/en/Main/Software 

Second, we tested the blink sketch on the Arduino (File->Examples->Basics->Blink):
Code-snippet:

<video>



Third, we modified it to work with an external LED, by adding these lines of code:

```C
pinMode(9, OUTPUT); //Setup pin 9 as output
digitalWrite(ledPin, HIGH); //Turn on LED
digitalWrite(ledPin, LOW); //Turn off LED
```

<video>

Fourth, we communicated over serial interface:

Serial.begin(9600); //Setup serial interface to communicate with 9600 baudrate
Serial.println('Alpha team!'); //Send text 

<Screenshot>

Fifth, we read an analog input from a potentiometer connected to A0, and used it to control the brightness of the LED:

potmeter = analogRead(A0); //Reads an ADC conversion from pin A0 using default settings for the ADC (10 bit conversion).
Serial.println(potmeter);  //Send the potmeter value to the screen
analogWrite(ledPin, potmeter>>2); //The analog write function only takes 8bits, so we have to divide our value by 4

Sixth, we controlled a continuous rotation servo-motor using the library servo.h:

#include <Servo.h>  //Library
Servo myservo;      //Declare instance
myservo.attach(11); //Attach the servo input to pin 11 (set it up as a pwm output, 20Hz)
myservo.write(0);   //0 is full speed reverse, 90 no speed, 180 full speed ahead

<video>

Finally, we assembled our robot and made it drive in a square:

<pic of parts>

<video>

//Helpful links://

* We found the [Arduino website](http://lmgtfy.com/?q=arduino+analog+write Arduino website) to be incredibly helpful.
* Also, this [https://playground.arduino.cc/Main/ShowInfo code] allows you to diagnose your Arduino Uno. Here, you can see how fast a clock cycle really is, how long a conversion takes, etc.

# Lab 2 Signal Processing

Buzzer and IR?

# Lab 3 Wireless Communication

# Lab 4 Digital Logic

//Goal:// Output data from an Arduino through an FPGA to a screen driver. 

We worked in two sub-teams. Team 1 sent data from the Arduino to the FPGA and converted this to something that made sense on the screen - in our case a 2 by 2 array of bits. Team 2 displayed the 2 by 2 array on the screen and continuously updated it. By the end of the lab, we merged the two codes into one, such that we could flip a bit on the Arduino side, and see the change on the screen. In the future we will extend this to work with a full maze layout. 
Fyi: Consider how to efficiently implement this so that it doesn't take up too much space on the FPGA. And not too many pins either. Serial or parallel?

//Lab, team 1://


//Lab, team 2://

We were given a VGA module to drive the screen. Reading through this module, we understand that it works as the illustrated sketch. Our job will be to modify the main module. 

![FPGA_screen_driver_module](/docs/images/FPGA_screen_driver.png =800x309)

First, we changed the color of the screen to green, blue, and red.

```verilog
assign PIXEL_COLOR = 8'b000_000_00 \\black
assign PIXEL_COLOR = 8'b111_000_00 \\red
assign PIXEL_COLOR = 8'b000_111_00 \\green
assign PIXEL_COLOR = 8'b000_000_11 \\blue
```
(Fyi, underscores in verilog are ignored by the compiler, they're just there for readability!)

Second, we drew a black square on a red screen, using an if statement in a combinatorial block. The signal inside the bracket is called a sensitivity list. A star means that the block will run when any of the signals inside change. 

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

Third, we want to draw a two by two grid. 
```verilog
reg grid_array [1:0][1:0]; //2-by-2 array of [rows][columns]
```

Specify the coordinate system. How does the robot think about it? The screen draws from the upper left corner, counting x positive toards the right, and y postive downwards. 









