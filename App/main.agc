
#include "source\common.agc"
#include "source\song.agc"

s as Song

SetWindowTitle( "BassWhacker" )
SetWindowSize( 1024, 768, 0 )
SetVirtualResolution( 1024, 768 )
SetOrientationAllowed(0,0,1,1)
SetErrorMode(2)
SetPrintColor(0,0,0)
SetPrintSize(24.0)
img = CreateSprite(LoadImage("gfx/background.png"))
SetSpriteSize(img,1024,768)
SongLoad(s,"fred/demo.bass")

debug$ = SONGToString(s)

while GetRawKeyState(27) = 0
	ShowDebug()
    Print( ScreenFPS() )
    Sync()
endwhile
