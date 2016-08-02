// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		song.agc
//		Purpose:	Song Manager / Loader
//		Date:		2nd August 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

global __SONGFileName$ as string = "<nofile>"														// Keeps track of position for errors.
global __SONGLine as integer = 42 											

global __SONGDefinitions$ as string[26] 															// Definitions made using the :x format
global __SONGCurrentBar = 1 																		// Current Bar (when loading)
global __SONGmbPosition = 0 																		// Position in current bar (when loading)
global __SONGDefinitionTarget = 0 																	// Definition target - 1..26 means defining, 0 is normal.

// ****************************************************************************************************************************************************************
//																Clear a Song structure
// ****************************************************************************************************************************************************************

function SONGClear(song ref as Song)
	song.name$ = "" 																				// Clear all name and count of bars
	song.barCount = 0
	song.beats = 4 																					// Default beats and temp
	song.tempo = 100
	song.bars.length = 16 																			// Space for 16 bars.
endfunction

// ****************************************************************************************************************************************************************
//																Add empty bar to song
// ****************************************************************************************************************************************************************

function SONGAddBar(song ref as Song)
	if song.barCount = song.bars.length then song.bars.length = song.bars.length + 16 				// Allocate space
	inc song.barCount 																				// Bump bar count
	BARClear(song.bars[song.barCount])																// Clear the new bar
endfunction

// ****************************************************************************************************************************************************************
//																Clear a bar structure
// ****************************************************************************************************************************************************************

function BARClear(bar ref as Bar)
	bar.noteCount = 0																				// Clear count of notes
	bar.notes.length = 8 																			// Allocate space for 8 notes in song.
	bar.__baseID = -1 																				// illegal value, allocated afer loading
endfunction 

// ****************************************************************************************************************************************************************
//																   Add note to a bar
// ****************************************************************************************************************************************************************

function BARAddNote(bar ref as Bar,stringID as integer,fret as integer,mbPosition as integer)
	if bar.noteCount = bar.notes.length then bar.notes.length = bar.notes.length + 8 				// Allocate more space if needed
	inc bar.noteCount 																				// One more note in this bar.
	ASSERT(stringID >= 1 and stringID <= 4,"AddNote:String")										// Check values are legitimate
	ASSERT(fret >= 0 and fret < 22,"AddNote:Fred")
	ASSERT(mbPosition >= 0 and mbPosition < 1000,"AddNote:position")
	if bar.noteCount > 1 then ASSERT(mbPosition > bar.notes[bar.noteCount-1].mbPosition,"AddNote:seq")
	bar.notes[bar.noteCount].stringID = stringID 													// Copy values in
	bar.notes[bar.noteCount].fret = fret
	bar.notes[bar.noteCount].mbPosition = mbPosition
endfunction

// ****************************************************************************************************************************************************************
//																  Song Loading Assert
// ****************************************************************************************************************************************************************

function SONGLoadAssert(test as integer,msg$ as String)
	if test = 0 
		ERROR("Assert failed loading "+msg$+" "+__SONGFileName$+" ("+str(__SONGLine)+")")
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Load a song
// ****************************************************************************************************************************************************************

function SONGLoad(song ref as Song,fileName$ as String)
	SONGClear(song) 																				// Clear the song.
	SONGAddBar(song)																				// Add the first bar
	__SONGFileName$ = fileName$ 																	// Save file name
	__SONGLine = 1 																					// Line number in that file
	__SONGCurrentBar = 1 																			// Currently at bar 1, position 0
	__SONGmbPosition = 0 
	for i = 1 to 26 																				// Clear all definitions.
		__SONGDefinitions$[i] = "" 
	next i
	__SONGDefinitionTarget = 0																		// Not currently targetting a definition
	n$ = mid(fileName$,FindStringReverse(fileName$,"/")+1,9999)										// Remove directory stuff
	song.name$ = left(n$,FindStringReverse(n$,".")-1)												// And file type
	//if GetFileExists(fileName$) = 0 then ERROR("No file "+fileName$)								// Check file exists
	
	// Process each line of file.
	
endfunction

// ****************************************************************************************************************************************************************
//															Convert song to string
// ****************************************************************************************************************************************************************

function SONGToString(song ref as Song)
	s$ = song.name$ + " "+str(song.barCount)+ " bars "+str(song.beats)+" beats/bar "+str(song.tempo)+" beats/minute;;"
endfunction s$
