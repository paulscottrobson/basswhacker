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

COMSetup()
DRAWBackground()
s as Song
SongLoad(s,"fred/demo.bass")

//debug$ = debug$ + SONGToString(s)


x# = 90.0
while GetRawKeyState(27) = 0
	DrawMove(s,s.bars[1],x#+ctl.barWidth*0)
	DrawMove(s,s.bars[2],x#+ctl.barWidth*1)
	DrawMove(s,s.bars[3],x#+ctl.barWidth*2)
	DrawMove(s,s.bars[4],x#+ctl.barWidth*3)
	x# = x# -  0.8
	ShowDebug()
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
