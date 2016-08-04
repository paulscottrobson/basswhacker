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

COMSetup()
DRAWBackground()
PLAYERLoadSound()
TRACKSetup()

song as Song
SongLoad(song,"music/test.bass")
//debug$ = debug$ + SONGToString(s)

position# = 1.0
lastTime = GetMilliseconds()
while GetRawKeyState(27) = 0

	elapsed# = (GetMilliseconds() - lastTime) / 1000.0												// Elapsed time in seconds
	lastTime = GetMilliseconds()																	// Track last time
	beats# = song.tempo / 60.0 														 				// Convert beats / minute to beats / second.
	beats# = beats# / song.beats 																	// Now bars per second
	position# = position# + beats# * elapsed#														// Adjust position
	MGRMove(song,position#)																			// Move graphics
	TRACKReposition((position# - 1.0) * 100.0 / song.barCount)										// Position tracker bar
	if GetPointerPressed() <> 0 																	// Handle mouse clicks
		TRACKClick(GetPointerX(),GetPointerY())
	endif
	position# = TRACKUpdate(position#,song.barCount)												// Update track mouse drag
	ShowDebug()
	print(GetMilliseconds() / 1000.0)
	print(position#)
	print(elapsed#)
    Print( ScreenFPS() )
    Sync()
endwhile
MGRDeleteAll(song)
while GetRawKeyState(27) <> 0
    Print( ScreenFPS() )
	Sync()
endwhile
