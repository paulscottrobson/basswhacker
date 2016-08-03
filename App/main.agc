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

COMSetup()
DRAWBackground()
s as Song
SongLoad(s,"fred/demo.bass")

//debug$ = debug$ + SONGToString(s)

DrawCreate(s,s.bars[1])
DrawMove(s,s.bars[1],100+ctl.barWidth*0)
DrawCreate(s,s.bars[2])
DrawMove(s,s.bars[2],100+ctl.barWidth*1)
DrawCreate(s,s.bars[3])
DrawMove(s,s.bars[3],100+ctl.barWidth*2)

while GetRawKeyState(27) = 0
	ShowDebug()
    Print( ScreenFPS() )
    Sync()
endwhile
