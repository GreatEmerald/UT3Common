/******************************************************************************
UT3HudOverlay

Creation date: 2008-07-15 11:13
Last change: $Id$
Copyright (c) 2008, Wormbo
******************************************************************************/

class UT3HudOverlay extends HudOverlay;


//=============================================================================
// Imports
//=============================================================================


//=============================================================================
// Properties
//=============================================================================

/** Color for the tool tip icon and text. */
var color ToolTipColor;

/** Material containing the tooltip icon. */
var Material DefaultIconMaterial;

/**
Material containing the separator icon displayed between the tooltip icon
and the key name.
*/
var Material ToolTipSepMaterial;
/** Texture coordinates for the separator icon. */
var IntBox ToolTipSepCoords;


//=============================================================================
// Variables
//=============================================================================

/** Last command for key name caching. */
var string CachedCommand;
/** Cached key name for last-used command. */
var string CachedKeyName;

/** Last time a tool tip was drawn. */
var float LastToolTipDrawTime;

/**
Sets up a new tooltip.
The Command must be a console command name and is automatically translated into
a localized key name. If this translation fails, e.g. because the command is
not bound, the tooltip won't be displayed.
*/
static function DrawToolTip(Canvas C, PlayerController PC, string Command, float X, float Y, IntBox IconCoords, optional Material IconMaterial)
{
	local float ResScale, ScaleX, ScaleY, WholeWidth, DrawX, XL, YL;

	if (PC.PlayerReplicationInfo.bOnlySpectator || default.LastToolTipDrawTime == PC.Level.TimeSeconds)
		return; // draw only a single tooltip at any time and don't draw any for spectators

	default.LastToolTipDrawTime = PC.Level.TimeSeconds;

	if (IconMaterial == None)
		IconMaterial = default.DefaultIconMaterial;
	if (!(Command ~= default.CachedCommand)) {
		default.CachedCommand = Command;
		default.CachedKeyName = class'GameInfo'.static.GetKeyBindName(Command, PC);
	}
	if (default.CachedKeyName == "")
		return; // no key bound

	C.DrawColor = default.ToolTipColor;
	C.Style = 5; // STY_Alpha
	C.Font = PC.MyHud.GetMediumFontFor(C);

	// calculate width of the entire tooltip
	ResScale = C.ClipY / 768.0;
	ScaleX = Abs(IconCoords.X2);
	ScaleY = Abs(IconCoords.Y2);
	C.StrLen(default.CachedKeyName, XL, YL);
	WholeWidth = XL + (ScaleX + default.ToolTipSepCoords.X2) * ResScale;

	// draw key name
	DrawX = X - 0.5 * WholeWidth;
	C.SetPos(DrawX, Y - 0.5 * YL);
	C.DrawTextClipped(default.CachedKeyName);

	// draw separator arrow
	DrawX += XL;
	C.SetPos(DrawX, Y - 0.5 * default.ToolTipSepCoords.Y2 * ResScale);
	C.DrawTile(default.DefaultIconMaterial, default.ToolTipSepCoords.X2 * ResScale, default.ToolTipSepCoords.Y2 * ResScale,
		default.ToolTipSepCoords.X1, default.ToolTipSepCoords.Y1, default.ToolTipSepCoords.X2, default.ToolTipSepCoords.Y2);

	// draw tooltip icon
	DrawX += default.ToolTipSepCoords.X2 * ResScale;
	C.SetPos(DrawX, Y - 0.5 * IconCoords.Y2 * ResScale);
	C.DrawTile(IconMaterial, IconCoords.X2 * ResScale, IconCoords.Y2 * ResScale,
		IconCoords.X1, IconCoords.Y1, IconCoords.X2, IconCoords.Y2);
}


function Render(Canvas C)
{
	// TODO
}


/**
Returns the local UT3HudOverlay.
Creates and registers a new instance, if none exists yet.
*/
static function UT3HudOverlay GetHudOverlay(Hud LocalHud)
{
	local int i;
	local UT3HudOverlay NewOverlay;

	if (LocalHud == None) {
		// no HUD
		return None;
	}

	// try to find existing HUD overlay
	for (i = 0; i < LocalHud.Overlays.Length; ++i) {
		if (UT3HudOverlay(LocalHud.Overlays[i]) != None)
			return UT3HudOverlay(LocalHud.Overlays[i]);
	}

	// create new HUD overlay
	NewOverlay = LocalHud.Spawn(class'UT3HudOverlay');
	if (NewOverlay != None) {
		LocalHud.AddHudOverlay(NewOverlay);
	}
	return NewOverlay;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	ToolTipColor        = (R=255,G=255,B=255,A=255)
	DefaultIconMaterial = Material'UT3HUD.Icons.UT3HudIcons'
	ToolTipSepCoords    = (X1=260,Y1=379,X2=29,Y2=27)
}
