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

COMSetup()
DRAWBackground()
PLAYERLoadSound()
TRACKSetup()
PANELInitialise()

song as Song
SongLoad(song,"music/test.bass")
//debug$ = debug$ + SONGToString(s)

position# = 1.0
lastTime = GetMilliseconds()
exitFlag = 0

while GetRawKeyState(27) = 0 and exitFlag = 0

	elapsed# = (GetMilliseconds() - lastTime) / 1000.0												// Elapsed time in seconds
	lastTime = GetMilliseconds()																	// Track last time
	beats# = song.tempo / 60.0 														 				// Convert beats / minute to beats / second.
	beats# = beats# / song.beats 																	// Now bars per second
	if ctl.isRunning
		position# = position# + ctl.tempoScalar# * beats# * elapsed#								// Adjust position if not paused
	endif
	MGRMove(song,position#)																			// Move graphics
	TRACKReposition((position# - 1.0) * 100.0 / song.barCount)										// Position tracker bar
	if GetPointerPressed() <> 0 																	// Handle mouse clicks
		position# = TRACKClick(GetPointerX(),GetPointerY(),song.barCount,position#)
		position# = PANELClick(GetPointerX(),GetPointerY(),position#)
		if position# < 0 
			position# = 1
			exitFlag = 1
		endif
	endif
	position# = TRACKUpdate(position#,song.barCount)												// Update track mouse drag
	ShowDebug()
    Sync()
endwhile
MGRDeleteAll(song)
while GetRawKeyState(27) <> 0
    Print( ScreenFPS() )
	Sync()
endwhile
