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
	LoadImage(IMG_CLEF,GFXDIR+"bass.png")															// Add bass clef
	CreateSprite(SPR_CLEF,IMG_CLEF)
	SetSpritePosition(SPR_CLEF,10,ctl.staveY+ctl.staveHeight/10)
	SetSpriteDepth(SPR_CLEF,DEPTH_BGR)
	SetSpriteSize(SPR_CLEF,ctl.staveHeight/2,ctl.staveHeight*8/10)
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
endfunction

// ****************************************************************************************************************************************************************
//																	   Move stave/tab objects
// ****************************************************************************************************************************************************************

function DRAWMove(song ref as Song,bar ref as Bar,x as integer)
	id = bar.__baseID																				// Shorthands
	sid = id + 500
	SetSpritePosition(id,x,ctl.tabY)																// Position tab bar
	SetSpritePosition(sid,x,ctl.staveY)																// Position stave bar
endfunction

// ****************************************************************************************************************************************************************
//													Load objects required for stave/tab drawing (non static ones)
// ****************************************************************************************************************************************************************

function DRAWLoadNonStaticImages()
	LoadImage(IMG_BAR,GFXDIR+"bar.png")
	LoadImage(IMG_RECTANGLE,GFXDIR+"rectangle.png")
endfunction

// ****************************************************************************************************************************************************************
//																Get stave vertical position
// ****************************************************************************************************************************************************************

function DRAWGetStaveY(n as integer)
	n = ctl.staveY + ctl.staveHeight * (n - 1) / 4
endfunction n

// ****************************************************************************************************************************************************************
//																Get string vertical position
// ****************************************************************************************************************************************************************

function DRAWGetStringY(n as integer)
	w = ctl.tabHeight * 65 / 100
	n = ctl.tabY + (ctl.tabHeight-w)/2 + w * (n - 1) / (STRINGS-1)
endfunction n
