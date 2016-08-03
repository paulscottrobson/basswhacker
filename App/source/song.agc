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

type CompilerControl 																													
	fileName$ as String 																			// File name
	line as integer 																				// Line number
	definition$ as string[26]																		// definitions
	bar as integer 																					// bar position
	currentString as integer 																		// current string
	openDefinition as integer 																		// open definition, 0 if none.
endtype

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
	bar.__loaded = 0
endfunction 

// ****************************************************************************************************************************************************************
//																   Add note to a bar
// ****************************************************************************************************************************************************************

function BARAddNote(bar ref as Bar,stringID as integer,fret as integer,mbLength as integer)
	//debug$ = debug$ + "Pluck "+str(stringID)+" at "+str(fret)+" for "+str(mbLength)+"&"
	if bar.noteCount = bar.notes.length then bar.notes.length = bar.notes.length + 8 				// Allocate more space if needed
	inc bar.noteCount 																				// One more note in this bar.
	ASSERT(stringID >= 1 and stringID <= 4,"AddNote:String")										// Check values are legitimate
	ASSERT(fret >= -1 and fret < 22,"AddNote:Fret")
	ASSERT(mbLength >= 0 and mbLength < 1000,"AddNote:position")
	bar.notes[bar.noteCount].stringID = stringID 													// Copy values in
	bar.notes[bar.noteCount].fret = fret
	bar.notes[bar.noteCount].mbLength = mbLength
endfunction

// ****************************************************************************************************************************************************************
//																  Song Loading Assert
// ****************************************************************************************************************************************************************

function SONGLoadAssert(cctl ref as CompilerControl,test as integer,msg$ as String)
	if test = 0 
		ERROR("Assert failed loading "+msg$+" "+cctl.fileName$+" ("+str(cctl.line)+")")
	endif
endfunction

// ****************************************************************************************************************************************************************
//																	Load a song
// ****************************************************************************************************************************************************************

function SONGLoad(song ref as Song,fileName$ as String)
	control as CompilerControl 																		// Create and initialise compiler control structure.
	control.fileName$ = fileName$
	control.line = 1
	control.bar = 1
	control.openDefinition = 0
	control.currentString = -1 																		// illegal value, fails if string not selected
	for i = 1 to 26
		control.definition$[i] = ""
	next i
	
	SONGClear(song) 																				// Clear the song.
	SONGAddBar(song)																				// Add the first bar	
	n$ = mid(fileName$,FindStringReverse(fileName$,"/")+1,9999)										// Remove directory stuff
	song.name$ = left(n$,FindStringReverse(n$,".")-1)												// And file type
	//if GetFileExists(fileName$) = 0 then ERROR("No file "+fileName$)								// Check file exists
	
	// TODO: Process each line of file
	
	song$ = "A0o. 0-2-|3-3-3-3-3-3-3-3-|7-7-7-7-7-7-7-7-|E :X 0-0- ; @X@X@X@X"
	__SONGCompile(song,control,song$)
	
	__SONGPostProcess(song)																			// Post processing
																									// Check definition is closed.
	SONGLoadAssert(control,control.openDefinition = 0,"Definition "+chr(control.openDefinition+64)+" not closed.")

endfunction

// ****************************************************************************************************************************************************************
//															Compile a string.
// ****************************************************************************************************************************************************************

function __SONGCompile(song ref as Song,control ref as CompilerControl,command$ as string)
	if FindString(command$,"//") > 0 																// Remove any comments.
		command$ = Left(command$,FindString(command$,"//"))
	endif
	command$ = ReplaceString(command$,chr(9)," ",9999)												// Remove all tabs, replace with spaces
	command$ = Upper(TrimString(command$," "))														// Trim spaces and make all capitals.
	while command$ <> "" 																			// Process each command
		command$ = __SONGCompileOneCommand(song,control,command$)									// Do one
		command$ = TrimString(command$," ")	
	endwhile
endfunction

// ****************************************************************************************************************************************************************
//															Compile a single command
// ****************************************************************************************************************************************************************

function __SONGCompileOneCommand(song ref as Song,control ref as CompilerControl,command$ as string)

	if control.openDefinition <> 0 																	// In a definition, process that.
		toGive = FindString(command$,";") 															// Give to here to definition
		hasSemiColon = (toGive > 0)
		if hasSemiColon = 0 then toGive = len(command$)+1 											// No semicolon, give the whole string.
		control.definition$[control.openDefinition] = control.definition$[control.openDefinition] + left(command$,toGive-1)
		command$ = mid(command$,toGive+1,99999) 													// Split line between definition and rest
		if hasSemiColon <> 0 then control.openDefinition = 0 										// If semicolon, then not in a definition any more.
		exitfunction command$
	endif

	mbPerBeat = 1000 / song.beats 																	// The number of millibars for each beat in the song.
	
	select left(command$,1)

		case "E" 																					// Select E string
			control.currentString = 1
			command$ = mid(command$,2,99999)
		endcase
		
		case "A" 																					// Select A string
			control.currentString = 2
			command$ = mid(command$,2,99999)
		endcase
		
		case "D" 																					// Select D string
			control.currentString = 3
			command$ = mid(command$,2,99999)
		endcase
		
		case "G" 																					// Select G string
			control.currentString = 4
			command$ = mid(command$,2,99999)
		endcase

		case "/"																					// /n select string N (lowest first)
			control.currentString = asc(mid(command$,2,1))-asc("0")
			SONGLoadAssert(control,control.currentString >= 1 and control.currentString <= 4,"Bad String"+mid(command$,2,1))
			command$ = mid(command$,3,99999)
		endcase 

		case "$"																					// $ rest
			command$ = mid(command$,2,99999)
			BARAddNote(song.bars[control.bar],control.currentString,-1,mbPerBeat) 			
		endcase
		
		case "-"																					// - 50% scalar 
			command$ = mid(command$,2,99999)
			__SONGScaleLastNote(song.bars[control.bar],control,50)
		endcase

		case "="																					// = 25% scalar 
			command$ = mid(command$,2,99999)
			__SONGScaleLastNote(song.bars[control.bar],control,25)
		endcase

		case "."																					// . 150% scalar 
			command$ = mid(command$,2,99999)
			__SONGScaleLastNote(song.bars[control.bar],control,150)
		endcase

		case "O"																					// O 200% scalar 
			command$ = mid(command$,2,99999)
			__SONGScaleLastNote(song.bars[control.bar],control,200)
		endcase
	
		case "|" 																					// | new Bar
			SONGAddBar(song)																
			inc control.bar
			command$ = mid(command$,2,99999)
		endcase
		
		// TODO: {} tempo beats
		case "@"																					// @ definition expand
			command$ = mid(command$,2,99999)
			SONGLoadAssert(control,left(command$,1) >= "A" and left(command$,1) <= "Z","Bad definition "+left(command$,1))
			__SONGCompile(song,control,control.definition$[asc(left(command$,1)) - asc("A") + 1])
			command$ = mid(command$,2,99999)
		endcase 
		
		case ':'																					// : definition
			command$ = mid(command$,2,99999)
			SONGLoadAssert(control,left(command$,1) >= "A" and left(command$,1) <= "Z","Bad definition "+left(command$,1))
			control.openDefinition = asc(left(command$,1)) - asc("A") + 1 							
			command$ = mid(command$,2,99999)
		endcase
		
		case default																				// Nothing, check it is a number
			if FindString("0123456789",left(command$,1)) = 0										// Check there is a number here.
				SONGLoadAssert(control,0,"Unknown command:"+left(command$,8))
			endif
			fret = 0
			while FindString("0123456789",left(command$,1)) > 0 and command$ <> ""					// Extract a number
				fret = fret * 10 + asc(command$) - asc("0")
				command$ = mid(command$,2,99999)
			endwhile
			BARAddNote(song.bars[control.bar],control.currentString,fret,mbPerBeat) 				// Add the note
		endcase
	endselect
endfunction command$

// ****************************************************************************************************************************************************************
//															Change the note length
// ****************************************************************************************************************************************************************

function __SONGScaleLastNote(bar ref as Bar,control ref as CompilerControl,percentScalar as integer)
	SONGLoadAssert(control,bar.noteCount > 0,"No note to modify")									// Check the note to scale exists.
	bar.notes[bar.noteCount].mbLength = bar.notes[bar.noteCount].mbLength * percentScalar / 100 	// Change the note length	
endfunction

// ****************************************************************************************************************************************************************
//												Song post processing - IDs, positions, rest padding
// ****************************************************************************************************************************************************************

function __SONGPostProcess(song ref as Song)
	for b = 1 to song.barCount
		song.bars[b].__baseID = mod(b,8) * 1000 + 10000												// Allocate an ID group
		total = 0 																					// Count up all the lengths
		if song.bars[b].noteCount = 0 																// Empty bar
			for i = 1 to song.beats 																// Add in 4 counting beats
				BARAddNote(song.bars[b],1,-1,1000/song.beats)
			next i
		endif
		for n = 1 to song.bars[b].noteCount
			total = total + song.bars[b].notes[n].mbLength
		next n
		mbHalfBeat = 1000 / song.beats / 2 															// Length of one half beat.
		while total + mbHalfBeat <= 1000 															// While we can fit another half beat or beat in.
			if total + mbHalfBeat*2 <= 1000 then hb = 2 else hb = 1 								// Whole rest or half rest ?
			BARAddNote(song.bars[b],1,-1,mbHalfBeat * hb)											// Add appropriate rest in
			total = total + mbHalfBeat * hb															// Add rest to total
		endwhile
		ASSERT(total <= 1000,"Bar too long at bar "+str(b))
		total = 0																					// Now update the positions
		for n = 1 to song.bars[b].noteCount
			song.bars[b].notes[n].__mbPosition = total
			total = total + song.bars[b].notes[n].mbLength
		next n
	next b
endfunction

// ****************************************************************************************************************************************************************
//															Convert song to string
// ****************************************************************************************************************************************************************

function SONGToString(song ref as Song)
	s$ = song.name$ + " "+str(song.barCount)+ " bars "+str(song.beats)+" beats/bar "+str(song.tempo)+" beats/minute&"
	for bar = 1 to song.barCount
		for note = 1 to song.bars[bar].noteCount 
			if note = 1 then a$ = "Bar:"+str(bar)+" ID:"+str(song.bars[bar].__baseID) else a$ = ""
			a$ = left(a$+"                     ",16)
			a$ = a$ + str(note)+": Str:"+str(song.bars[bar].notes[note].stringID)
			a$ = a$ +" Fret:"+str(song.bars[bar].notes[note].fret)
			a$ = a$ +" Len:"+str(song.bars[bar].notes[note].mbLength)
			a$ = a$ +" Pos:"+str(song.bars[bar].notes[note].__mbPosition)
			s$ = s$ + a$ + "&"
		next note
	next bar
endfunction s$
