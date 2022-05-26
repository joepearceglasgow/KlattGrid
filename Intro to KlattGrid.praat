#adapted from example KlattGrid script by David Weenink to create a diphthong

#this first line creates a new KlattGrid, named 'kg', with a start time of 0 and an end time of 0.5
#the rest of the paramenters specify things like the number of formants, etc.

Create KlattGrid... kg 0 0.5 6 1 1 6 1 1 1

#now that we have a KlattGrid, we're going to add a pitch point at 120Hz
#As we keep voicing constant the time we put it at isn't important
Add pitch point... 0.1 120

#and now add a voicing amplitude point at 90 dB
Add voicing amplitude point... 0.1 90
Play

#these first few lines of script create the most basic sound that the synthesizer can make
#you end up with the buzz of voicing that hasn't yet passed through the vocal tract filter!

#here we add two formants at 0.1 seconds
#the first has a frequency of 800 Hz and a bandwidth of 50 Hz
#the first has a frequency of 1200 Hz and a bandwidth of 50 Hz
#it should end up sounding like /a/

Add oral formant frequency point... 1 0.1 800
Add oral formant bandwidth point... 1 0.1 50
Add oral formant frequency point... 2 0.1 1200
Add oral formant bandwidth point... 2 0.1 50

Play

