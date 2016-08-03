// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		common.agc
//		Purpose:	Constants, Structures, Global Definitions
//		Date:		2nd August 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//																	Constants
// ****************************************************************************************************************************************************************

#constant GFXDIR 	"gfx/" 																				// Graphics here

#constant STRINGS 			(4) 																		// Number of strings

#constant DEPTH_BGR 		(90) 																		// Background item depths, +5
#constant DEPTH_NOTES		(80)																		// Note depths, +5

#constant IMG_STAVE 		(100)																		// Stave line image
#constant IMG_FRETBOARD 	(101)																		// Fretboard image
#constant IMG_CLEF 			(102) 																		// Bass Clef image
#constant IMG_STRING 		(103) 																		// String image
#constant IMG_RECTANGLE		(104)																		// General rectangle
#constant IMG_BAR 			(105)																		// Bar on Fretboard
#constant IMG_NOTEBOX 		(106) 																		// Box containing note.
#constant IMG_FONT 			(107)																		// Font image

#constant IMG_4REST 		(108) 																		// Rest (4 quarter beats)
#constant IMG_2REST 		(109) 																		// Rest (2 quarter beats)
#constant IMG_1NOTE 		(110)
#constant IMG_2NOTE 		(111)
#constant IMG_4NOTE 		(112)
#constant IMG_8NOTE 		(113)

#constant SPR_STAVES 		(200)																		// Stave sprites (5)
#constant SPR_FRETBOARD		(205)																		// Fretboard sprite
#constant SPR_STRINGS 		(206)																		// String sprites
#constant SPR_CLEF 			(220) 																		// Bass clef sprite

// ****************************************************************************************************************************************************************
//													Constant values that aren't actual constants
// ****************************************************************************************************************************************************************

type Constants																							// Control constants
	screenWidth,screenHeight as integer																	// Screen size
	staveY,staveHeight as integer																		// Stave width and height
	tabY,tabHeight as integer 																			// Tab width and height
	barWidth as integer 																				// Graphical width of one bar
endtype

global debug$ as string = ""																			// String containing debug information
global ctl as Constants

// ****************************************************************************************************************************************************************
//																Print Debug Information
// ****************************************************************************************************************************************************************

function ShowDebug()
	for l = 1 to CountStringTokens(debug$,"&")
		print("DBG:"+chr(34)+GetStringToken(debug$,"&",l)+chr(34))
	next l
endfunction

// ****************************************************************************************************************************************************************
//																	Assert/Error
// ****************************************************************************************************************************************************************

function ERROR(msg$ as String)
	while GetRawKeyState(27) = 0 																	// Display until escaped.
		print(msg$)
		Sync()
	endwhile
	End
endfunction

function ASSERT(assert as integer,msg$ as String)
	if assert = 0 then ERROR("Assert Failed : "+msg$)
endfunction

// ****************************************************************************************************************************************************************
//																	Structures
// ****************************************************************************************************************************************************************

type Note 																							// An individual note
	stringID as integer 																			// String (1 = E, 2 = A, 3 = D, 4 = G)
	fret as integer 																				// Fret position (0 = open string, -1 = rest)
	mbLength as integer 																			// Length of note in 1000ths of bar (millibars)
	__mbPosition as integer 																		// Note position in 1000ths of bar (millibars)
endtype

type Bar 																							// An individual bar
	noteCount as integer																			// Notes in bar (first note 0)
	notes as Note[1]																				// Notes in bar. Note length is not the same as noteCount necessarily
	__baseID as integer 																			// base ID for sprites/texts/etc. in this bar. Allocates 1000.
	__loaded as integer 																			// True if sprite/text for this bar display exist.
endtype

type Song 																							// An individual song
	name$ as string																					// Song name (stripped part of file name)
	barCount as	integer																				// number of bars in song (first bar 1)
	beats as integer 																				// beats per bar.
	tempo as integer 																				// tempo in beats / minute
	bars as Bar[1] 																					// Bar data (chunk extended, do not use size)
endtype

// ****************************************************************************************************************************************************************
//																	Set up Common things and screen
// ****************************************************************************************************************************************************************

function COMSetup()
	ctl.screenWidth = 1024																			// Screen size
	ctl.screenHeight = 768

	ctl.staveY = 150																				// Screen items 
	ctl.staveHeight = 100
	ctl.tabY = 400
	ctl.tabHeight = 300
	
	ctl.barWidth = 350																				// Width of one bar on screen
	
	SetWindowTitle("BassWhacker")																	// Screen set up
	SetWindowSize(ctl.screenWidth,ctl.screenHeight,0)
	SetVirtualResolution(ctl.screenWidth,ctl.screenHeight)
	SetOrientationAllowed(0,0,1,1)
	SetErrorMode(2)
	SetPrintColor(0,0,0)
	SetPrintSize(24.0)
	img = CreateSprite(LoadImage(GFXDIR+"background.png"))											// Background image
	SetSpriteSize(img,ctl.screenWidth,ctl.screenHeight)
	SetSpriteDepth(img,99)
endfunction
	
