# Lab 2
## Team Alpha

Goal: Capture a 660Hz tone using the Electret microphone, amplify the signal, and process the signal using a Fast Fourier Transform running on the Arduino. Show the expected spike in the FFT bin in our output containing 660Hz.

### Tone generation
First, we found a [web application to generate a tone](http://www.szynalski.com/tone-generator).

![Tone generator](images/tone_generator.png)

### Timing ADC capture: analogRead() versus Free Running Mode
- Information on the GetInfo Arduino script
- Screen capture of GetInfo output


### Open Music FFT script
We read through the example code provided with the Open Music Labs FFT library (fft_adc_serial.pde). This code interacts with the Arduino's ADC directly in "free running" mode, bypassing the interface provided by analogRead(). As shown above, this allows us to sample from the ADC faster than the analogRead().

***fft_adc_serial***
***All comments here were added by the ECE3400 TA's:***
```C
cli(); // Turn off global interrupts.
// We do not want the Arduino context switching during the sampling process to
// handle an interrupt.

// Grab 256 samples. Note that this does not reference FFT_N, defined at the top
// of the script, as it should. This is bad style and could introduce a bug, as
// this code will always take 256 samples even if FFT_N changes.
for (int i = 0 ; i < 512 ; i += 2) {
  // The ADC is controlled by writing directly to the control register, ADCSRA.
  // This allows us to avoid the overhead involved with
  // Wait for the ADC to convert.
  while(!(ADCSRA & 0x10));
  // Restart the conversion.
  ADCSRA = 0xf5;
  // Grab the upper and lower bytes from the two ADC registers.
  // The ADC has a resolution of 10 bits, which requires two 8-bit registers.
  byte m = ADCL;
  byte j = ADCH;
  // Take the two register values and combine them to form an
  // 16-bit signed integer. This is what the FFT library expects.
  int k = (j << 8) | m;
  k -= 0x0200;
  k <<= 6;
  // Load the created signed integer into the data structure used by the FFT
  // library to perform the FFT calculation. Only use the even numbered indices.
  // The library considers the even numbered indices as the real component of the
  // inputs and the odd numbered indices as the complex component of the inputs.
  fft_input[i] = k;
  fft_input[i+1] = 0;
}
// Call the necessary functions to run the FFT.
fft_window();
fft_reorder();
fft_run();
fft_mag_log();
sei(); // Turn on global interrupts
```


### Microphone test circuit
- Images of the circuit with amplifier


### Testing the FFT using the function generator
- Timing --> bucket math
- Function generator screen shot
- Serial output
- Explanation of the bug we found
- Graph of the serial output


### analogRead() code
- Annotated code snippet
- Timing --> bucket math
- Graph of the serial output
