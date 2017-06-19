# Lab 2
## Team Alpha

Goal: Capture a 660Hz tone using the Electret microphone, amplify the signal, and process the signal using a Fast Fourier Transform running on the Arduino. Show the expected spike in the FFT bin containg 660Hz.

First, we found a web application to generate a tone: http://www.szynalski.com/tone-generator/

Second, we read through the example code provided with the Open Music Labs FFT library (fft_adc_serial.pde). This code interacts with the Arduino's ADC directly in "free running" mode, bypassing the interface provided by analogRead(). In theory, this allows us to sample from the ADC faster than the analogRead().

### TODO: Add the arduino info script where we timed the ADC conversion. Explain the theoretical maximum speed of ADC free-running versus analogRead().

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

We found information on "free running" mode here: http://www.microsmart.co.za/technical/2014/03/01/advanced-arduino-adc

The ADC on the Arduino has a clockspeed of 125kHz by default. (This can be checked in wiring.c) Conversion takes 13 ADC cycles. 125k / 13 = 9600, giving us our sampling frequency of 9.6kHz. This is good enough for detecting the 660Hz tone.

![Amplifier circuit, image 0](images/amp0)
![Amplifier circuit, image 1](images/amp1)

### TODO:
- Annotating the Open Music FFT script.
- Information on the GetInfo Arduino script and timing analogRead().
- Explanation of the bug we found.
- Screen shots of function generator.
- Image of amplification circuit.
- Annotation of the code we finally used with analogRead().
- Graph of output with correct code.
- Providing an ISR driven Open Music FFT script that doesn't have the sampling rate bug (optional).
