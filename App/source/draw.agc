// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************
//
//		File:		draw.agc
//		Purpose:	Responsible for drawing and moving the bars, creating and deleting sprites and text as appropriate.
//		Date:		2nd August 2016
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// ****************************************************************************************************************************************************************
// ****************************************************************************************************************************************************************

// ****************************************************************************************************************************************************************
//														Create the background for the stave and tab
// ****************************************************************************************************************************************************************

function DRAWBackground()
	LoadImage(IMG_FRETBOARD,GFXDIR+"fretboard.png")													// Set up the fretboard
	CreateSprite(SPR_FRETBOARD,IMG_FRETBOARD)
	SetSpritePosition(SPR_FRETBOARD,0,ctl.tabY)
	SetSpriteSize(SPR_FRETBOARD,ctl.screenWidth,ctl.tabHeight)
	SetSpriteDepth(SPR_FRETBOARD,DEPTH_BGR+4)
	LoadImage(IMG_STAVE,GFXDIR+"stave.png")
	for n = 1 to 5 																					// For the 5 lines of the stave.
		CreateSprite(SPR_STAVES+n-1,IMG_STAVE)
		SetSpriteSize(SPR_STAVES+n-1,ctl.screenWidth,ctl.staveHeight/20)
		SetSpriteDepth(SPR_STAVES+n-1,DEPTH_BGR+1)
		SetSpritePosition(SPR_STAVES+n-1,0,DRAWGetStaveY(n)-GetSpriteHeight(SPR_STAVES+n-1)/2)
	next n
	//LoadImage(IMG_CLEF,GFXDIR+"bass.png")															// Add bass clef
	//CreateSprite(SPR_CLEF,IMG_CLEF)
	//SetSpritePosition(SPR_CLEF,10,ctl.staveY+ctl.staveHeight/10)
	//SetSpriteDepth(SPR_CLEF,DEPTH_BGR)
	//SetSpriteSize(SPR_CLEF,ctl.staveHeight/2,ctl.staveHeight*8/10)
	LoadImage(IMG_STRING,GFXDIR+"string.png")								
	for n = 1 to STRINGS 																			// Draw the strings
		CreateSprite(SPR_STRINGS+n,IMG_STRING)
		SetSpriteSize(SPR_STRINGS+n,ctl.screenWidth,ctl.tabHeight*(8+n)/8/40)
		SetSpriteDepth(SPR_STRINGS+n,DEPTH_BGR)
		SetSpritePosition(SPR_STRINGS+n,0,DRAWGetStringY(n)-GetSpriteHeight(SPR_STRINGS+n)/2)
	next n
	DRAWLoadNonStaticImages()																		// Load in the other images
endfunction

// ****************************************************************************************************************************************************************
//																	Create stave/tab objects
// ****************************************************************************************************************************************************************

function DRAWCreate(song ref as Song,bar ref as Bar)
	if bar.__loaded <> 0 then exitfunction 															// already done.
	bar.__loaded = 1
	id = bar.__baseID 																				// Shorthands
	sid = id + 500
	CreateSprite(id,IMG_BAR)																		// Bar for tab (t+0)
	SetSpriteDepth(id,DEPTH_BGR+1)
	SetSpriteSize(id,ctl.tabHeight/32,ctl.tabHeight)
	CreateSprite(sid,IMG_RECTANGLE)																	// Bar for stave (t+1)
	SetSpriteDepth(sid,DEPTH_BGR-1)
	SetSpriteSize(sid,ctl.staveHeight/32,ctl.staveHeight)
	SetSpriteColor(sid,0,0,0,255)																	// Make it black
	
	for note = 1 to bar.noteCount																	// Work through each note
		if bar.notes[note].fret >= 0 then __DRAWCreateTabNote(song,bar.notes[note],id+note*10)		// Create tab (not for rests)
		__DRAWCreateStaveNote(song,bar.notes[note],sid+note*10)										// Create stave
	next note
	
endfunction



// ****************************************************************************************************************************************************************
//																	Delete stave/tab objects
// ****************************************************************************************************************************************************************

function DRAWDelete(song ref as Song,bar ref as Bar)
	if bar.__loaded = 0 then exitfunction 															// already done.
	bar.__loaded = 0
	id = bar.__baseID																				// Shorthands
	sid = id + 500
	DeleteSprite(id)																				// Delete tab bar
	DeleteSprite(sid)																				// Delete stave bar
	for note = 1 to bar.noteCount																	// Work through each note
		if bar.notes[note].fret >= 0 then __DRAWDeleteTabNote(song,bar.notes[note],id+note*10)		// Delete tab (not for rests)
		__DRAWDeleteStaveNote(song,bar.notes[note],sid+note*10)										// Delete stave
	next note
endfunction

// ****************************************************************************************************************************************************************
//																	   Move stave/tab objects
// ****************************************************************************************************************************************************************

function DRAWMove(song ref as Song,bar ref as Bar,x as integer)
	if x < -ctl.barWidth-32 or x > ctl.screenWidth + 32 											// Off screen
		DRAWDelete(song,bar)																		// Delete it
		exitfunction
	endif
	DRAWCreate(song,bar)																			// Create it if required
	id = bar.__baseID																				// Shorthands
	sid = id + 500
	SetSpritePosition(id,x,ctl.tabY)																// Position tab bar
	SetSpritePosition(sid,x-ctl.barWidth/15,ctl.staveY)																// Position stave bar
	for note = 1 to bar.noteCount																	// Work through each note
		x1 = x + ctl.barWidth * bar.notes[note].__mbPosition / 1000 								// Where it goes horizontally
		if bar.notes[note].fret >= 0 then __DRAWMoveTabNote(song,bar.notes[note],id+note*10,x1)		// Move tab (not for rests)
		__DRAWMoveStaveNote(song,bar.notes[note],sid+note*10,x1)									// Move stave
	next note
endfunction

// ****************************************************************************************************************************************************************
//																	TAB note create, delete, move
// ****************************************************************************************************************************************************************

function __DRAWCreateTabNote(song ref as Song,note ref as Note,id as integer)
	CreateSprite(id,IMG_NOTEBOX)																	// Create note box.
	SetSpriteDepth(id,DEPTH_NOTES+1)
	sz = ctl.barWidth * 123 / 1000
	SetSpriteSize(id,sz,sz)
	__DRAWColourTabNote(id,note.fret)
	text$ = str(note.fret)																			// Fret position
	scale = 11
	if ctl.showNoteNameInTab <> 0
		text$ = PLAYERConvertToName(PLAYERConvertToNoteSharp(PLAYERGetNoteIndex(note.stringID,note.fret)))
		scale = 8
	endif
	CreateText(id,text$)																			// Create text box.
	SetTextDepth(id,DEPTH_NOTES)
	SetTextSize(id,ctl.barWidth*scale/100)
	SetTextColor(id,255,255,255,255)
endfunction

function __DRAWDeleteTabNote(song ref as Song,note ref as Note,id as integer)
	DeleteSprite(id)
	DeleteText(id)
endfunction

function __DRAWMoveTabNote(song ref as Song,note ref as Note,id as integer,x as integer)
	y = DRAWGetStringY(STRINGS+1-note.stringID)
	SetSpritePosition(id,x-GetSpriteWidth(id)/2,y-GetSpriteHeight(id)/2)
	SetTextPosition(id,x-GetTextTotalWidth(id)/2,y-GetTextTotalHeight(id)/2)
endfunction

function __DRAWColourTabNote(id as integer,fret as integer)
	col$ = "#00F#0F0#F00#0FF#FF0#F80#888#F0F#800#880#088#A33#8F0#FCD"
	p = mod(fret,len(col$)/4) * 4 + 2																// Work out which to use
	SetSpriteColorRed(id,Val(mid(col$,p+0,1),16)*15+15)												// And colour the sprite
	SetSpriteColorGreen(id,Val(mid(col$,p+1,1),16)*15+15)
	SetSpriteColorBlue(id,Val(mid(col$,p+2,1),16)*15+15)
endfunction

// ****************************************************************************************************************************************************************
//																	STAVE note create, delete, move
// ****************************************************************************************************************************************************************

function __DRAWCreateStaveNote(song ref as Song,note ref as Note,id as integer)
	mb = 1000 / song.beats																			// How many mBars per beat
	if note.fret >= 0 																				// Create a note (spr + 0)
		qBeat# = note.mbLength / (1000.0 / song.beats / 4.0)
		bestImage = __DRAWGetBestStave(qBeat#)
		CreateSprite(id,abs(bestImage))
		if bestImage < 0 																			// Dotted note
			CreateSprite(id+2,IMG_CIRCLE)
			SetSpriteSize(id+2,ctl.barWidth/40,ctl.barWidth/40)
			SetSpriteDepth(id+2,DEPTH_NOTES)
			SetSpriteColor(id+2,0,0,0,255)
		endif
		s# = ctl.barWidth / 2000.0
	else
		if note.mbLength <= mb/2 then img = IMG_2REST else img = IMG_4REST 							// Create a reset
		CreateSprite(id,img)
		s# = ctl.barWidth / 1800.0
	endif
	SetSpriteScale(id,s#,s#*1)																	// Set size, initial position
	SetSpriteDepth(id,DEPTH_NOTES)
	SetSpriteColor(id,0,0,0,255)
	SetSpritePositionByOffset(id,0,DRAWGetStaveY(3))
	if note.fret >= 0 
		SetSpriteOffset(id,GetSpriteWidth(id)*0.3,GetSpriteHeight(id)*0.84)							// Note, put offset in bottom of note
		n = PLAYERGetNoteIndex(note.stringID,note.fret)												// Get note index
		n# = PLAYERConvertToNoteSharp(n)															// Get fractional version
		if ctl.showNoteName <> 0
			CreateText(id,PLAYERConvertToName(n#))													// Get name and create text (txt + 0)
			//CreateText(id,str(Floor(n#)))																
			SetTextColor(id,0,0,0,255)																// Setup text
			SetTextSize(id,ctl.barWidth/12)	
			SetTextDepth(id,DEPTH_NOTES)
		endif
		SetSpritePositionByOffset(id,0,DRAWGetStaveY(6-Floor(n#)/2.0))								// Position note on stave
		if n# = 0 or n# > 11 																		// Off top/bottom of stave, need a bar.
			CreateSprite(id+1,IMG_RECTANGLE)														// (spr + 1)
			SetSpriteDepth(id+1,DEPTH_NOTES+1)
			SetSpriteSize(id+1,ctl.barWidth/12,ctl.barWidth/80)
			SetSpriteColor(id+1,0,0,0,255)
			SetSpritePositionByOffset(id+1,0,DRAWGetStaveY(6-Floor(n#)/2))
		endif
		if floor(n#) <> n# 																			// Is it a sharp note
			CreateText(id+1,"#")																	// Sharp text (text + 1)
			SetTextSize(id+1,ctl.barWidth/9)
			SetTextColor(id+1,0,0,0,255)
		endif
	endif
endfunction

function __DRAWDeleteStaveNote(song ref as Song,note ref as Note,id as integer)
	DeleteSprite(id)
	if GetTextExists(id) <> 0 then DeleteText(id)
	if GetSpriteExists(id+1) <> 0 then DeleteSprite(id+1)
	if GetTextExists(id+1) <> 0 then DeleteText(id+1)
	if GetSpriteExists(id+2) <> 0 then DeleteSprite(id+2)
endfunction

function __DRAWMoveStaveNote(song ref as Song,note ref as Note,id as integer,x as integer)
	y = DRAWGetStaveY(3)
	if GetTextExists(id) <> 0 then SetTextPosition(id,x-GetTextTotalWidth(id)/2,DRAWGetStaveY(6.5))
	SetSpritePositionByOffset(id,x,GetSpriteYByOffset(id))
	if GetSpriteExists(id+1) <> 0 then SetSpritePositionByOffset(id+1,x,GetSpriteYByOffset(id+1))
	if GetTextExists(id+1) <> 0 then SetTextPosition(id+1,GetSpriteX(id)-GetTextTotalWidth(id+1),GetSpriteYByOffset(id)-GetTextTotalHeight(id+1)/2)
	if GetSpriteExists(id+2) <> 0 then SetSpritePositionByOffset(id+2,GetSpriteX(id)+GetSpriteWidth(id)*4/3,GetSpriteYByOffset(id))
endfunction

// ****************************************************************************************************************************************************************
//																		Get stave options
// ****************************************************************************************************************************************************************

function __DRAWGetBestStave(quarterBeat# as float)
	result = -1
	bestScore# = 999999		
	for i = 0 to 7
		tqBeat# = pow(2,mod(i,4))
		if i >= 4 then tqBeat# = tqBeat# * 3 / 2
		if abs(tqBeat# - quarterBeat#) < bestScore#
			bestScore# = abs(tqBeat# - quarterBeat#)
			result = pow(2,mod(i,4))+IMG_1NOTE-1
			if i >= 4 then result = -result
		endif
	next i
endfunction result

// ****************************************************************************************************************************************************************
//													Load objects required for stave/tab drawing (non static ones)
// ****************************************************************************************************************************************************************

function DRAWLoadNonStaticImages()
	LoadImage(IMG_BAR,GFXDIR+"bar.png")
	LoadImage(IMG_RECTANGLE,GFXDIR+"rectangle.png")
	LoadImage(IMG_NOTEBOX,GFXDIR+"notebutton.png")
	LoadImage(IMG_CIRCLE,GFXDIR+"circle.png")
	LoadImage(IMG_4REST,GFXDIR+"4rest.png")
	LoadImage(IMG_2REST,GFXDIR+"2rest.png")
	LoadImage(IMG_1NOTE,GFXDIR+"1note.png")
	LoadImage(IMG_2NOTE,GFXDIR+"2note.png")
	LoadImage(IMG_4NOTE,GFXDIR+"4note.png")
	LoadImage(IMG_8NOTE,GFXDIR+"8note.png")
	SetTextDefaultFontImage(LoadImage(GFXDIR+"font_l.png"))
endfunction

// ****************************************************************************************************************************************************************
//																Get stave vertical position
// ****************************************************************************************************************************************************************

function DRAWGetStaveY(n# as float)
	n = ctl.staveY + ctl.staveHeight * (n# - 1) / 4
endfunction n

// ****************************************************************************************************************************************************************
//																Get string vertical position
// ****************************************************************************************************************************************************************

function DRAWGetStringY(n as integer)
	w = ctl.tabHeight * 65 / 100
	n = ctl.tabY + (ctl.tabHeight-w)/2 + w * (n - 1) / (STRINGS-1)
endfunction n

// TODO : correct character
// TODO : 4 beat note
