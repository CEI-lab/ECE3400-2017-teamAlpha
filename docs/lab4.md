Lab 4
Team Alpha

Note: This lab requires two Arduinos powered on simultaneously. It is fine to have two Arduinos connected to the same PC, but you will only be able to talk to one over the serial monitor at a time in the Arduino IDE. Change between the two by choosing between the two ports in the Tools --> Port menu in the Arduino IDE.

First we handled the hardware:
- Download the radio library and install on the Arduino IDE
  https://github.com/maniacbug/RF24
- Download the Getting Started example from the course repository
  /lab4/...
- Soldering two radio headers
- Found two radios
- Found two Arduinos
- Plugged the radios into the Arduinos along with the 3.3V wire
- Set the two channel numbers for our team according to the formula
- Program both Arduinos with the GettingStarted example
- Plug both Arduinos into the PC simultaneously. Use the serial monitor to set one to transmit mode and confirm that it says it is sending messages. Switch to the other on the serial monitor to see if it is receiving these messages.


- Work out the procedure for sending the entire maze.
We chose to send each position in the maze as a character. According the documentation for the radio library, the default payload size is 32 bytes, so we have more than enough room to send 25 characters for our 5 x 5 maze. We can send the entire maze as a single payload.

[Note: The original lab writeup does not appear to consider this option.]

Because the radio library implements Acks behind the scenes (this is handled by radio.write()), we do not need to manually acknowledge received packets.

A different approach to sending the data, say splitting it over multiple payloads, would require a state machine to handle un-Acknowledged packets.


- Work out the procedure for sending only new information.

We want to send three pieces of information, the x-coordinate, the y-coordinate, and the state of the current position. Because our maze is 5x5, we need 3 bits for each coordinate. Only four values are possible for the state of the current position: unvisited, no wall, wall, treasure. Hence we need 2 bits for the state.

This gives us 8 bits of data, which can be packed into a single byte. (Note: the default payload size is 32 bytes, so to actually reduce the # of bytes sent by the radio requires changing this setting.)

We pack our byte using a bit shifting scheme and send it in a single payload. It is unpacked on the receiver side using masking along with bit shifting.

