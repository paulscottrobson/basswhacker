
#include "source\common.agc"
#include "source\song.agc"

s as Song

SetErrorMode(2)
SetWindowTitle( "BassWhacker" )
SetWindowSize( 1024, 768, 0 )
SetVirtualResolution( 1024, 768 )
SetOrientationAllowed(0,0,1,1)
SongLoad(s,"fred/demo.bass")

while GetRawKeyState(27) = 0
	ShowDebug()
	print(s.barCount)
	print(s.name$)
	print(s.beats)
	print(s.tempo)
    Print( ScreenFPS() )
    Sync()
endwhile
