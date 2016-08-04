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
//ctl.barWidth = 300
DRAWBackground()
PLAYERLoadSound()

s as Song
SongLoad(s,"fred/demo.bass")

//debug$ = debug$ + SONGToString(s)

x# = 1.0
while GetRawKeyState(27) = 0
	MGRMove(s,x#)
	x# = x# + 0.00
	ShowDebug()
	print(x#)
    Print( ScreenFPS() )
    Sync()
endwhile
DRAWDelete(s,s.bars[1])
//DRAWDelete(s,s.bars[3])
//DRAWDelete(s,s.bars[4])
while GetRawKeyState(27) <> 0
    Print( ScreenFPS() )
	Sync()
endwhile
