ScriptName OBarsScript Extends Quest
;On-screen bar manager

OsexIntegrationMain OStim

;--------- bars
Osexbar property DomBar auto
Osexbar property SubBar auto
Osexbar property ThirdBar auto ;todo
;---------

Event OnInit()
	OStim = (Self as Quest) as OsexIntegrationMain

	DomBar = (Self as Quest) as Osexbar
	SubBar = (Game.GetFormFromFile(0x000804, "Ostim.esp")) as Osexbar
EndEvent

Function InititializeAllBars()
	InitBar(dombar, true)
	InitBar(subbar, false)
EndFunction

Function InitBar(Osexbar Bar, Bool DomsBar)
	Bar.HAnchor = "left"
	Bar.VAnchor = "bottom"
	Bar.X = 200
	Bar.Alpha = 0.0
	Bar.SetPercent(0.0)
	Bar.FillDirection = "Right"

	If (DomsBar)
		Bar.Y = 692
		Bar.SetColors(0xb0b0b0, 0xADD8E6, 0xffffff)
	Else
		Bar.Y = 647
		Bar.SetColors(0xb0b0b0, 0xffb6c1, 0xffffff)
	EndIf

	SetBarVisible(Bar, False)
EndFunction

Function SetBarVisible(Osexbar Bar, Bool Visible)
	If (Visible)
		Bar.FadeTo(100.0, 1.0)
		Bar.FadedOut = False
	Else
		Bar.FadeTo(0.0, 1.0)
		Bar.FadedOut = True
	EndIf
EndFunction

Bool Function IsBarVisible(Osexbar Bar)
	Return (!Bar.FadedOut)
EndFunction

Function SetBarPercent(Osexbar Bar, Float Percent)
	Bar.SetPercent(Percent / 100.0)
	Float zPercent = Percent / 100.0
	If (zPercent >= 1.0)
		FlashBar(Bar)
	EndIf
EndFunction

Function FlashBar(Osexbar Bar)
	Bar.ForceFlash()
EndFunction