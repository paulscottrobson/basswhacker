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

global debug$ as string = ""																			// String containing debug information

// ****************************************************************************************************************************************************************
//																Print Debug Information
// ****************************************************************************************************************************************************************

function ShowDebug()
	for l = 1 to CountStringTokens(debug$,";;")
		print("DBG:"+chr(34)+GetStringToken(debug$,";;",l)+chr(34))
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
	fret as integer 																				// Fret position (0 = open string)
	mbPosition as integer 																			// Note position in 1000ths of bar (millibars)
endtype

type Bar 																							// An individual bar
	noteCount as integer																			// Notes in bar (first note 0)
	notes as Note[1]																				// Notes in bar. Note length is not the same as noteCount necessarily
	__baseID as integer 																			// base ID for sprites/texts/etc. in this bar. Allocates 1000.
endtype

type Song 																							// An individual song
	name$ as string																					// Song name (stripped part of file name)
	barCount as	integer																				// number of bars in song (first bar 1)
	beats as integer 																				// beats per bar.
	tempo as integer 																				// tempo in beats / minute
	bars as Bar[1] 																					// Bar data (chunk extended, do not use size)
endtype
	
