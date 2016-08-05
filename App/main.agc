// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		main.agc
//		Purpose:	Main program
//		Date:		2nd August 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

#include "source\common.agc"
#include "source\song.agc"
#include "source\draw.agc"
#include "source\player.agc"
#include "source\manager.agc"
#include "source\tracker.agc"
#include "source\panel.agc"
#include "source\selectoritem.agc"
#include "source\musicselector.agc"
#include "source\io.agc"

#constant BUILD_NUMBER	(0)
#constant BUILD_DATE 	("5 Aug 16")

COMSetup()																							// Set up common constants etc
DRAWBackground()																					// Draw backgrounds
PLAYERLoadSound()																					// Load in bass guitar sounds and metronome
TRACKSetup()																						// Set up the positional track
PANELInitialise()																					// Initialise the panel

if 1=1
	PlayOneSong(IOSelectFromDirectory(""))
else 
	PlayOneSong("f1:ftest.bass")
endif


// ****************************************************************************************************************************************************************
//																			Play a single song
// ****************************************************************************************************************************************************************

function PlayOneSong(songFile$ as String)
	song as Song
	srcFile$ = IOAccessFile(songFile$)																// Convert format, transferring web file if running online
	SongLoad(song,srcFile$)																			// Load song
	//debug$ = debug$ + SONGToString(s)

	position# = 1.0																					// Position in song
	lastTime = GetMilliseconds()																	// Time last loop
	exitFlag = 0																					// Set when completed
	TRACKReset() 																					// Reset the track
	
	while GetRawKeyState(27) = 0 and exitFlag = 0

		elapsed# = (GetMilliseconds() - lastTime) / 1000.0											// Elapsed time in seconds
		lastTime = GetMilliseconds()																// Track last time
		beats# = song.tempo / 60.0 													 				// Convert beats / minute to beats / second.
		beats# = beats# / song.beats 																// Now bars per second
		if ctl.isRunning
			position# = position# + ctl.tempoScalar# * beats# * elapsed#							// Adjust position if not paused
		endif
		MGRMove(song,position#)																		// Move graphics
		TRACKReposition((position# - 1.0) * 100.0 / song.barCount)									// Position tracker bar
		if GetPointerPressed() <> 0 																// Handle mouse clicks
			position# = TRACKClick(GetPointerX(),GetPointerY(),song.barCount,position#)
			position# = PANELClick(GetPointerX(),GetPointerY(),position#)
			if position# < 0 
				position# = 1
				exitFlag = 1
			endif
		endif
		position# = TRACKUpdate(position#,song.barCount)											// Update track mouse drag
		ShowDebug()
		Sync()
	endwhile
	MGRDeleteAll(song)																				// Remove all sprites, texts
endfunction
