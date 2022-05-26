##This script uses KlattGrid to change the voice quality of a sound

##This script runs from the object window


#Form to enter parameters desired for each voice quality setting

form Change voice quality

	real maxformant 5000
		#this helps praat to find formants
		#start by using 5500 for a female speaker and 5000 for a male speaker
		#but play around with this if the results are unsatisfactory

	comment Modal copy synthesis 
	boolean make_modal 1			
	#creates a checkbox to ask the user if they want to create a modal voice, copy synthesized from the original with very little changed
	#we'll also use some of these parameters for the portions of periodic voicing in the creaky voice
		
		#allows the user to specify the open phase of their modal voice
		#KlattGrid's default is 0.7, although Klatt & Klatt 1990 recommended 50% for a male voice and 60% for a female voice

		real open_phase_modal 0.6	
		
		#allows the user to specify H1-H2 for the modal voice - I use 8Hz, which is what Klatt & Klatt 1990 use for a non-breathy voice in their original synthesizer
		real spectral_tilt_modal 8	
		
		#flutter is a measure of period-to-period fluctuations in f0 
		#you might want some flutter in modal voice to increase the perception of naturalness if you were working with a pitch track with no fluctuations, e.g if it was synthesized
		real flutter_modal 0
		
	comment Creaky voice parametres
	boolean make_creaky 1			
	#creates a checkbox to ask the user if they want to create a creaky voice 
		real flutter_creak 0.5		
		real open_phase_creak 0.25
		real spectral_tilt_creak 5
		real max_double_pulsing 1
	
	comment Breathy voice parametres
	boolean make_breathy 1
		#creates a checkbox to ask the user if they want to create a breathy voice 
		real flutter_breathy 0.25
		real b1_increase_breathy 1.10 (=10%)
		real open_phase_breathy 0.95
		real spectral_tilt_breathy 25

endform

#here we set the selected sound as a numerical variable, so that we can tell praat to select the sound we want to work with later in a line like the one that follows
#then we tell praat to save the name of that sound object as a string variable, so that we can use that to rename it later

soundID = selected ("Sound")
selectObject: soundID
name$ = selected$ ("Sound")


#getting time & pitch measurements
#we'll need these later!

tmin = Get start time
tmax = Get end time

selectObject: soundID

To Pitch: 0, 75, 600
q1pitch = Get quantile: 0, 0, 0.25, "Hertz"
medianpitch = Get quantile: 0, 0, 0.5, "Hertz"	

Remove



####modal sample
#transforming the sound to a KlattGrid, setting parametres, 
#convert back to sound and rename

	if make_modal = 1
   
		selectObject: soundID
		To KlattGrid (simple): 0.005, 5, maxformant, 0.025, 50, 60, 600, 100, "yes"
		Add open phase point: 0, open_phase_modal	
		Add spectral tilt point: 0, spectral_tilt_modal
		Add flutter point: 0, flutter_modal
		To Sound

		#these next few lines tell praat to rename the resulting sound file, then remove it from the object list

		newname$ = name$ + "modal"
		Rename: name$ + "modal"
		
		selectObject: "KlattGrid " + name$ 
		Remove

	endif

####creaky sample

	if make_creaky = 1

		selectObject: soundID

		To KlattGrid (simple): 0.005, 5, maxformant, 0.025, 50, 60, 600, 100, "yes"
	
		Add open phase point: 0, open_phase_modal	
		Add spectral tilt point: 0, spectral_tilt_modal
		Add flutter point: 0, flutter_modal
	
		#This section tells praat to check what the pitch is every 0.005 seconds
		#then add different amounts of double pulsing and flutter depending on whether the pitch is below the median or the first quartile
			
		for i to (tmax-tmin)/0.005
			time = tmin + i * 0.005
			pitch = Get pitch at time: time
			if pitch < q1pitch			
				Add double pulsing point: time, max_double_pulsing
				Add flutter point: time, flutter_creak
				Add open phase point: time, open_phase_creak
				Add spectral tilt point: time, spectral_tilt_creak
			elsif pitch < medianpitch
				Add double pulsing point: time, max_double_pulsing/2
				Add flutter point: time, flutter_creak/2
				Add open phase point: time, open_phase_creak
				Add spectral tilt point: time, spectral_tilt_creak
			else
				Add double pulsing point: time, 0.0
				Add open phase point: time, open_phase_creak
				Add spectral tilt point: time, spectral_tilt_creak
				Add flutter point: time, flutter_modal
			endif
		endfor

		To Sound
		newname$ = name$ + "creaky"
		Rename: name$ + "creaky"
	
		selectObject: "KlattGrid " + name$
		Remove
	endif

#### breathy 


#there is a 'breathiness' tier - but in my experience it's very glitchy, so we're going to use the aspiration amplitude tier instead to create aspiration noise
	
	
	if make_breathy = 1 
	
		selectObject: soundID
		
		To KlattGrid (simple): 0.005, 5, maxformant, 0.025, 50, 60, 600, 100, "yes"
	
		#this next section tells praat to check the formant bandwidth and increase the bandwidth of the formant by 10%
			
		for i to (tmax-tmin)/0.01
			time = tmin + i * 0.01

			for i to (tmax-tmin)/0.01
				time = tmin + i * 0.01
				b1 = Get oral formant bandwidth at time: 1, tmin + i * 0.01
				Remove oral formant bandwidth points: 1, time, time
				Add oral formant bandwidth point: 1, time, b1*b1_increase_breathy
			endfor
			
		#this next section tells praat to check the voicing amplitude, then add aspiration that varies dynamically according to the voicing amplitude
			for i to (tmax-tmin)/0.01
				time = tmin + i * 0.01
				intensity = Get voicing amplitude at time: time
				Add aspiration amplitude point: time, intensity/2.5
			endfor
			
				
		endfor
	
		
		#these next few lines add points to tiers that don't vary according to a different parameter
		
		Add open phase point: 0, open_phase_breathy	

		Add spectral tilt point: 0, spectral_tilt_breathy

		Add flutter point: 0, flutter_breathy
	
		To Sound
		newname$ = name$ + "breathy"
		Rename: name$ + "breathy"

		selectObject: "KlattGrid " + name$
		Remove
	
	endif

