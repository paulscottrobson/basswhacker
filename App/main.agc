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

COMSetup()
DRAWBackground()
PLAYERLoadSound()

s as Song
SongLoad(s,"music/test.bass")
//debug$ = debug$ + SONGToString(s)

position# = 1.0
while GetRawKeyState(27) = 0
	MGRMove(s,position#)
	position# = position# + 0.004
	ShowDebug()
	print(position#)
    Print( ScreenFPS() )
    Sync()
endwhile
MGRDeleteAll(s)
while GetRawKeyState(27) <> 0
    Print( ScreenFPS() )
	Sync()
endwhile
