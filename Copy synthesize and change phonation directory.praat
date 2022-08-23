##Script: Copy synthesize and change phonation
##Author: Joe Pearce
##Date: January 2020, updated 23 August 2022
##Description: This script uses KlattGrid to change the voice quality of a sound, and runs on a whole directory
##Instructions: This script runs from the object window

form Change pitch and voice quality
	
	real maxformant 5000

	comment Which new f0s do you want?
		real newpitch1 120
		real newpitch2 165
		real newpitch3 210
		
	comment Modal voice parametres
	boolean make_modal 1
		real flutter_modal 0.1
		real open_phase_modal 0.7
		real spectral_tilt_modal 10
	
	comment Creaky voice parametres
	boolean make_creaky 1
		real flutter_creak 0.25
		real open_phase_creak 0.4
		real spectral_tilt_creak 5
		real max_double_pulsing 0.25
	
	comment Breathy voice parametres
	boolean make_breathy 1
		real flutter_breathy 0.25
		real b1_increase_breathy 1.10 (=10%)
		real open_phase_breathy 0.95
		real spectral_tilt_breathy 30

	comment Choose directories to open and save files in
	word opendirectory N:\originalstimulitest\
	boolean save_files 1
	word savedirectory N:\editedstimulitest\

endform

strings = Create Strings as file list: "list", opendirectory$ + "*.wav"
numberOfFiles = Get number of strings
for ifile to numberOfFiles
   	selectObject: strings
   	fileName$ = Get string: ifile
  	Read from file: opendirectory$ + fileName$
	
soundID = selected ("Sound")
selectObject: soundID
soundName$ = selected$ ("Sound")


#getting time measurements
tmin = Get start time
tmax = Get end time

#changing pitch


selectObject: soundID
Change gender: 75, 600, 1, newpitch1, 1, 1
Rename: soundName$ + "_" + string$ (newpitch1)
soundID1 = selected ("Sound")

selectObject: soundID
Change gender: 75, 600, 1, newpitch2, 1, 1
Rename: soundName$ + "_" +  string$ (newpitch2)
soundID2 = selected ("Sound")

selectObject: soundID
Change gender: 75, 600, 1, newpitch3, 1, 1
Rename: soundName$ + "_" +  string$ (newpitch3)
soundID3 = selected ("Sound")	

#loop that goes through sounds and creates new vq sounds for each of them

for isound from soundID1 to soundID3

	selectObject: isound
	name$ = selected$ ("Sound")

	To Pitch: 0, 75, 600

	minpitch = Get minimum: 0, 0, "Hertz", "Parabolic"
	maxpitch = Get maximum: 0, 0, "Hertz", "Parabolic"
	q1pitch = Get quantile: 0, 0, 0.125, "Hertz"
	q2pitch = Get quantile: 0, 0, 0.25, "Hertz"
	q3pitch = Get quantile: 0, 0, 0.375, "Hertz"
	medianpitch = Get quantile: 0, 0, 0.5, "Hertz"
	
	Remove

	#modal sample
	#transforming the sound to a KlattGrid, setting parametres, 
	#convert back to sound and rename

	if make_modal = 1
   
		selectObject: isound
		To KlattGrid (simple): 0.005, 5, maxformant, 0.025, 50, 60, 600, 100, "yes"
		Add flutter point: 0, flutter_modal
		Add open phase point: 0, open_phase_modal	
		Add spectral tilt point: 0, spectral_tilt_modal
		To Sound
		newname$ = name$ + "modal"
		Rename: name$ + "modal"
		
		if save_files = 1
			Save as WAV file: savedirectory$ + newname$ + ".wav"
		endif

		selectObject: "KlattGrid " + name$ 
		Remove

	endif

	#creaky sample

	if make_creaky = 1

		selectObject: isound


		To KlattGrid (simple): 0.005, 5, maxformant, 0.025, 50, 60, 600, 100, "yes"
	
		Add open phase point: 0, open_phase_creak
		Add spectral tilt point: 0, spectral_tilt_creak
		Add flutter point: 0, flutter_creak
	
		for i to (tmax-tmin)/0.01
			time = tmin + i * 0.01
			pitch = Get pitch at time: time
			if pitch < q1pitch
				Remove pitch points: time - 0.005, time + 0.005
				Add pitch point: time, pitch - 12			
				Add double pulsing point: time, max_double_pulsing
			elsif pitch < q2pitch
				Remove pitch points: time - 0.005, time + 0.005
				Add pitch point: time, pitch - 9			
				Add double pulsing point: time, max_double_pulsing
			elsif pitch < q3pitch
				Remove pitch points: time - 0.005, time + 0.005
				Add pitch point: time, pitch - 6			
				Add double pulsing point: time, max_double_pulsing
			elsif pitch < medianpitch
				Remove pitch points: time - 0.005, time + 0.005
				Add pitch point: time, pitch - 3
				Add double pulsing point: time, max_double_pulsing/2
			else
				Add double pulsing point: time, 0.0
			endif
		endfor

		To Sound
		newname$ = name$ + "creaky"
		Rename: name$ + "creaky"
	
		if save_files = 1
			Save as WAV file: savedirectory$ + newname$ + ".wav"
		endif

		selectObject: "KlattGrid " + name$
		Remove
	endif

# breathy 


	if make_breathy = 1 
	
		selectObject: isound
		
		To KlattGrid (simple): 0.005, 5, maxformant, 0.025, 50, 60, 600, 100, "yes"
	
		for i to (tmax-tmin)/0.01
			time = tmin + i * 0.01

			for i to (tmax-tmin)/0.01
				time = tmin + i * 0.01
				b1 = Get oral formant bandwidth at time: 1, tmin + i * 0.01
				Remove oral formant bandwidth points: 1, time, time
				Add oral formant bandwidth point: 1, time, b1*b1_increase_breathy
			endfor
			
			for i to (tmax-tmin)/0.01
				time = tmin + i * 0.01
				intensity = Get voicing amplitude at time: time
				Add aspiration amplitude point: time, intensity/2.5
			endfor
			
				
		endfor
	
		

		Add open phase point: 0, open_phase_breathy	

		Add spectral tilt point: 0, spectral_tilt_breathy

		Add flutter point: 0, flutter_breathy
	
		To Sound
		newname$ = name$ + "breathy"
		Rename: name$ + "breathy"
		if save_files = 1
			Save as WAV file: savedirectory$ + newname$ + ".wav"
		endif
		selectObject: "KlattGrid " + name$
		Remove
	
	endif

endfor

selectObject: soundID
Remove
selectObject: soundID1
Remove
selectObject: soundID2
Remove
selectObject: soundID3
Remove

endfor