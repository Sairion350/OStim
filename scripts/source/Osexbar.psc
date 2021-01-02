ScriptName Osexbar Extends SKI_WidgetBase


; -------------------------------------------------------------------------------------------------
; PRIVATE VARIABLES -------------------------------------------------------------------------------


Float	_width			= 292.8
Float	_height			= 25.2
Int		_primaryColor	= 4259840
Int		_secondaryColor	= 3342336
Int		_flashColor		= -1
String 	_fillDirection	= "both"
Float	_percent		= 0.0


; -------------------------------------------------------------------------------------------------
; PROPERTIES --------------------------------------------------------------------------------------

Bool Property FadedOut Auto

Float Property Width
	{Width of the meter in pixels at a resolution of 1280x720. Default: 292.8}
	Float Function get()
		Return _width
	EndFunction

	Function set(Float a_val)
		_width = a_val
		If (Ready)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setWidth", _width)
		EndIf
	EndFunction
EndProperty

Float Property Height
	{Height of the meter in pixels at a resolution of 1280x720. Default: 25.2}
	Float Function get()
		Return _height
	EndFunction

	Function set(Float a_val)
		_height = a_val
		If (Ready)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setHeight", _height)
		EndIf
	EndFunction
EndProperty

Int Property PrimaryColor
	{Primary color of the meter gradient RRGGBB [0x000000, 0xFFFFFF]. Default: 0xFF0000. Convert to decimal when editing this in the CK}
	Int Function get()
		Return _primaryColor
	EndFunction

	Function set(Int a_val)
		_primaryColor = a_val
		If (Ready)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setColor", _primaryColor)
		EndIf
	EndFunction
EndProperty

Int Property SecondaryColor
	{Secondary color of the meter gradient, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK}
	Int Function get()
		Return _secondaryColor
	EndFunction

	Function set(Int a_val)
		SetColors(_primaryColor, a_val, _flashColor)
	EndFunction
EndProperty

Int Property FlashColor
	{Color of the meter warning flash, -1 = automatic. RRGGBB [0x000000, 0xFFFFFF]. Default: -1. Convert to decimal when editing this in the CK}
	Int Function get()
		Return _flashColor
	EndFunction

	Function set(Int a_val)
		_flashColor = a_val
		If (Ready)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".setFlashColor", _flashColor)
		EndIf
	EndFunction
EndProperty

String Property FillDirection
	{The position at which the meter fills from, ["left", "center", "right"] . Default: center}
	String Function get()
		Return _fillDirection
	EndFunction

	Function set(String a_val)
		_fillDirection = a_val
		If (Ready)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setFillDirection", _fillDirection)
		EndIf
	EndFunction
EndProperty

Float Property Percent
	{Percent of the meter [0.0, 1.0]. Default: 0.0}
	Float Function get()
		Return _percent
	EndFunction

	Function set(Float a_val)
		_percent = a_val
		If (Ready)
			UI.InvokeFloat(HUD_MENU, WidgetRoot + ".setPercent", _percent)
		EndIf
	EndFunction
EndProperty


; -------------------------------------------------------------------------------------------------
; EVENTS ------------------------------------------------------------------------------------------


; @override SKI_WidgetBase
Event OnWidgetReset()

	parent.OnWidgetReset()

	; Init numbers
	Float[] numberArgs = new Float[6]
	numberArgs[0] = _width
	numberArgs[1] = _height
	numberArgs[2] = _primaryColor as Float
	numberArgs[3] = _secondaryColor as Float
	numberArgs[4] = _flashColor as Float
	numberArgs[5] = _percent
	UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".initNumbers", numberArgs)

	; Init strings
	String[] stringArgs = new String[1] ;This is an array because I want to add more to it later...
	stringArgs[0] = _fillDirection
	UI.InvokeStringA(HUD_MENU, WidgetRoot + ".initStrings", stringArgs)

	; Init commit
	UI.Invoke(HUD_MENU, WidgetRoot + ".initCommit")

EndEvent


; -------------------------------------------------------------------------------------------------
; FUNCTIONS ---------------------------------------------------------------------------------------


; @overrides SKI_WidgetBase
String Function GetWidgetSource()
	Return "skyui/meter.swf"
EndFunction

; @overrides SKI_WidgetBase
String Function GetWidgetType()
	Return "OsexBar"
EndFunction

Bool Function IsExtending()
	Return True
EndFunction

Function SetPercent(Float a_percent, Bool a_force = False)
	{Sets the meter percent, a_force sets the meter percent without animation}
	_percent = a_percent
	If (Ready)
		Float[] args = new Float[2]
		args[0] = a_percent
		args[1] = a_force as Float
		UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".setPercent", args)
	EndIf
EndFunction

Function ForcePercent(Float a_percent)
	{Convenience function for SetPercent(a_percent, True)}
	SetPercent(a_percent, True)
EndFunction

Function StartFlash(Bool a_force = False)
	{Starts meter flashing. a_force starts the meter flashing If it's already animating}
	If (Ready)
		UI.InvokeBool(HUD_MENU, WidgetRoot + ".startFlash", a_force)
	EndIf
EndFunction

Function ForceFlash()
	{Convenience function for StartFlash(True)}
	StartFlash(True)
EndFunction

Function SetColors(Int a_primaryColor, Int a_secondaryColor = -1, Int a_flashColor = -1)
	{Sets the meter percent, a_force sets the meter percent without animation}
	_primaryColor = a_primaryColor;
	_secondaryColor = a_secondaryColor;
	_flashColor = a_flashColor;

	If (Ready)
		Int[] args = new Int[3]
		args[0] = a_primaryColor
		args[1] = a_secondaryColor
		args[2] = a_flashColor
		UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setColors", args)
	EndIf
EndFunction

Function TransitionColors(Int a_primaryColor, Int a_secondaryColor = -1, Int a_flashColor = -1, Int a_duration = 1000)
	{Sets the meter percent, a_force sets the meter percent without animation}
	_primaryColor = a_primaryColor;
	_secondaryColor = a_secondaryColor;
	_flashColor = a_flashColor;

	If (Ready)
		Int[] args = new Int[4]
		args[0] = a_primaryColor
		args[1] = a_secondaryColor
		args[2] = a_flashColor
		args[3] = a_duration
		UI.InvokeIntA(HUD_MENU, WidgetRoot + ".transitionColors", args)
	EndIf
EndFunction
