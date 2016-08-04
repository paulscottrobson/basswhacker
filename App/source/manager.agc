// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		manager.agc
//		Purpose:	Manages redrawing / positioning.
//		Date:		3rd August 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Remove all stave / tab stuff
// ****************************************************************************************************************************************************************

function MGRDeleteAll(song ref as Song)
	for bar = 1 to song.barCount
		DRAWDelete(song,song.bars[bar])
	next bar
endfunction

// ****************************************************************************************************************************************************************
//																		Move the tab and stave
// ****************************************************************************************************************************************************************

function MGRMove(song ref as Song,position# as float)

	if position# > song.barCount+1 then position# = song.barCount + 1 								// As far as you can go.
	if position# < 1 then position# = 1
	
	if abs(position# - song.__lastPosition#) > 0.5													// Moved too far ? Reset everything.
		MGRDeleteAll(song)
	else 																							// Normal scrolling.
		if position# > song.__lastPosition# 														// Moved forward
			bStart = floor(song.__lastPosition#)													// bar to start
			bEnd = floor(position#)
			mbStart = (song.__lastPosition# - floor(song.__lastPosition#)) * 1000 					// first position to check.
			mbEnd = (position# - floor(position#)) * 1000 											// last position to check.
			if bStart <> bEnd 																		// changed bar
				__MGRPlaySearch(song.bars[bStart],mbStart,1000)										// end of first bar.
				__MGRPlaySearch(song.bars[bEnd],0,mbEnd)											// start of second bar.
				PLAYERMetronome(1)
			else
				__MGRPlaySearch(song.bars[bStart],mbStart,mbEnd)
				beatLength = 1000 / song.beats 														// Check if different beat
				if mbStart / beatLength <> mbEnd / beatLength and mbEnd <> 1000 then PLAYERMetronome(0)
			endif
		endif
	endif
	barNumber = floor(position#)																	// Current bar
	offset# = ctl.barPoint - (position# - Floor(position#)) * ctl.barWidth							// Physical position on screen
	while offset# + ctl.barWidth > -40																// Work backwards till off screen
		offset# = offset# - ctl.barWidth
		dec barNumber
	endwhile
	while offset# < ctl.screenWidth 																// Work forwards till off RHS
		if barNumber >= 1 and barNumber <= song.barCount 											// legitimate bar value ?
			DRAWMove(song,song.bars[barNumber],offset#)												// move there
		endif
		offset# = offset# + ctl.barWidth															// forward one display ba
		inc barNumber
	endwhile		
	
	y = ctl.tabY-GetSpriteHeight(SPR_SPHERE)														// Position the bouncing sphere
	barNumber = floor(position#) 																	// Current bar.
	beatPosition = (position# - barNumber) * 1000.0 												// Position in bar.
	for n = 1 to song.bars[barNumber].noteCount
		if song.bars[barNumber].notes[n].fret >= 0
			if beatPosition >= song.bars[barNumber].notes[n].__mbPosition and beatPosition < song.bars[barNumber].notes[n].__noteEnd 
				st = song.bars[barNumber].notes[n].__mbPosition										// start time
				angle# = (beatPosition - st) * 180 / (song.bars[barNumber].notes[n].__noteEnd - st) // angle in degrees
				y = y - sin(angle#) * ctl.bounceHeight 
			endif
		endif
	next n		
	SetSpritePosition(SPR_SPHERE,ctl.barPoint-GetSpriteWidth(SPR_SPHERE)/2,y)
	song.__lastPosition# = position#																// Store last position.
endfunction

// ****************************************************************************************************************************************************************
//										Look for an audio note in the range in the given bar, and play it if found
// ****************************************************************************************************************************************************************

function __MGRPlaySearch(bar ref as Bar,start as integer,afterEnd as integer)
	noteID = 0 																						// Look for note.
	for note = 1 to bar.noteCount
		if bar.notes[note].__mbPosition >= start and bar.notes[note].__mbPosition < afterEnd then noteID = note
	next note
	if noteID > 0 and bar.notes[noteID].fret >= 0 then PLAYERPlay(bar.notes[noteID])				// Play found note
endfunction
