# Lab 2
## Team Alpha

Goal: Capture a 660Hz tone using the Electret microphone, amplify the signal, and process the signal using a Fast Fourier Transform running on the Arduino. Show the expected spike in the FFT bin containg 660Hz.

First, we found a web application to generate a tone: http://www.szynalski.com/tone-generator/

Second, we read through the example code provided with the Open Music Labs FFT library (fft_adc_serial.pde). This code interacts with the Arduino's ADC directly in "free running" mode, bypassing the interface provided by analogRead(). In theory, this allows use to sample from the ADC faster than the analogRead().

We found information on "free running" mode here: http://www.microsmart.co.za/technical/2014/03/01/advanced-arduino-adc

The ADC on the Arduino has a clockspeed of 125kHz by default. (This can be checked in wiring.c) Conversion takes 13 ADC cycles. 125k / 13 = 9600, giving us our sampling frequency of 9.6kHz. This is good enough for detecting the 660Hz tone.

### TODO:
- Annotating the Open Music FFT script.
- Information on the GetInfo Arduino script and timing analogRead().
- Explanation of the bug we found.
- Screen shots of function generator.
- Image of amplification circuit.
- Annotation of the code we finally used with analogRead().
- Graph of output with correct code.
- Providing an ISR driven Open Music FFT script that doesn't have the sampling rate bug (optional).
