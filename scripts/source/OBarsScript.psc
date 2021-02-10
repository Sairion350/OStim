ScriptName OBarsScript Extends Quest

;
;			██████╗  █████╗ ██████╗ ███████╗
;			██╔══██╗██╔══██╗██╔══██╗██╔════╝
;			██████╔╝███████║██████╔╝███████╗
;			██╔══██╗██╔══██║██╔══██╗╚════██║
;			██████╔╝██║  ██║██║  ██║███████║
;			╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
;
;				Code related to the on-screen bars





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

	InititializeAllBars()

	OnGameLoad()
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

Event OstimStart(string eventName, string strArg, float numArg, Form sender)
	If (ostim.EnableDomBar)
    	SetBarPercent(DomBar, 0.0)
    	SetBarVisible(DomBar, True)
	EndIf

	If (ostim.EnableSubBar)
		SetBarPercent(SubBar, 0.0)
    	SetBarVisible(SubBar, True)
	EndIf


	While ostim.AnimationRunning()
		If (ostim.AutoHideBars && (ostim.GetTimeSinceLastPlayerInteraction() > 15.0)) ; fade out if needed
    		If (IsBarVisible(DomBar))
    			SetBarVisible(DomBar, False)
    		EndIf
    		If (IsBarVisible(SubBar))
    			SetBarVisible(SubBar, False)
    		EndIf
    	EndIf

    	SetBarPercent(DomBar, ostim.getactorexcitement(ostim.GetDomActor()))
		SetBarPercent(SubBar, ostim.getactorexcitement(ostim.GetSubActor()))

		Utility.wait(1)
	EndWhile


	SetBarVisible(DomBar, False)
	SetBarPercent(DomBar, 0.0)
	SetBarVisible(SubBar, False)
	SetBarPercent(SubBar, 0.0)
EndEvent

Event OstimOrgasm(string eventName, string strArg, float numArg, Form sender)
	actor act = ostim.getmostrecentorgasmedactor()

	If (Act == ostim.GetDomActor())
		FlashBar(dombar)
		SetBarPercent(DomBar, 0)
	ElseIf (Act == ostim.GetSubActor())
		FlashBar(subbar)
		SetBarPercent(SubBar, 0)
	EndIf
endevent


Function OnGameLoad()
	RegisterForModEvent("ostim_start", "OstimStart")
	RegisterForModEvent("ostim_orgasm", "OstimOrgasm")

	osexintegrationmain.Console("Fixing Bars thread")
EndFunction