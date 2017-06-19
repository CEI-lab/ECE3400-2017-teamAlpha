# Lab 4
## Team Alpha

Note: This lab requires two Arduinos powered on simultaneously. It is fine to have two Arduinos connected to the same PC, but you will only be able to talk to one over the serial monitor at a time in the Arduino IDE. Change between the two by choosing between the two ports in the Tools --> Port menu.

### Hardware

First we handled the hardware:
- Download the radio library and install with the Arduino IDE.
  https://github.com/maniacbug/RF24
- Download the GettingStarted example from the lab4 course repository.
- We skippped soldering two radio headers as there were already complete versions in the lab.
- Found two radios.
- Found two Arduinos.
- Plugged the radios into the Arduinos along with the 3.3V wire.

![Arduino with radio](images/radio.png)

### Software: Getting Started

Then we handled the software for GettingStarted:
- Set the two channel numbers for our team according to the formula given in the lab handout.

``` C
// Radio pipe addresses for the 2 nodes to communicate.
const uint64_t pipes[2] = { 0x0000000002LL, 0x0000000003LL };
```

- Program both Arduinos with the GettingStarted example.
- Plug both Arduinos into the PC simultaneously. Use the serial monitor to set one to transmit mode and confirm that it says it is sending messages. Switch to the other on the serial monitor to see if it is receiving these messages.

### Software: Sending the Maze

We chose to send each position in the maze as a character. According the documentation for the radio library, the default payload size is 32 bytes, so we have more than enough room to send 25 characters for our 5 x 5 maze. We can send the entire maze as a single payload.

[Note: The original lab writeup does not appear to consider this option and assumes every character will be sent as its own payload.]

``` C
//
// Maze
//
unsigned char maze[5][5] =
{
  3, 3, 3, 3, 3,
  3, 1, 1, 1, 3,
  3, 2, 0, 1, 2,
  3, 1, 3, 1, 3,
  3, 0, 3, 1, 0
};
```

Sender side:
``` C
// Send the maze in a single payload
printf("Now sending the maze!\n");
bool ok = radio.write( maze, sizeof(maze) );

if (ok)
  printf("ok...");
else
  printf("failed.\n\r");

// Now, continue listening
radio.startListening();
```

Receiver side:
``` C
unsigned char got_maze[5][5];
bool done = false;
while (!done)
{
  // Fetch the payload.
  done = radio.read( got_maze, sizeof(got_maze) );

  // Print the maze
  for (int i=0; i < 5; i++) {
    for (int j=0; j < 5; j++) {
      printf("%d ", got_maze[i][j]);
    }
    printf("\n");
  }

  // Delay just a little bit to let the other unit
  // make the transition to receiver
  delay(20);

}
```

Because the radio library implements Acks behind the scenes (this is handled by radio.write()), we do not need to manually acknowledge received packets.

A different approach to sending the data, say splitting it over multiple payloads, would require a state machine to resend un-Acked packets.

### Software: Sending New Data

We want to send three pieces of information, the x-coordinate, the y-coordinate, and the state of the current position. Because our maze is 5 x 5, we need 3 bits for each coordinate. Only four values are possible for the state of the current position: unvisited, no wall, wall, and treasure. Hence we need 2 bits for the state.

This gives us 8 bits of data, which can be packed into a single byte. (Note: the default payload size is 32 bytes, so to actually reduce the # of bytes sent by the radio requires changing this setting.)

We pack our byte using a bit shifting scheme and send it in a single payload. It is unpacked on the receiver side using masking along with bit shifting.
