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
Osexbar property ThirdBar auto 
;---------

int blue
int pink
int gray
int yellow
int white

Event OnInit()
	OStim = (Self as Quest) as OsexIntegrationMain

	DomBar = (Self as Quest) as Osexbar
	SubBar = (Game.GetFormFromFile(0x000804, "Ostim.esp")) as Osexbar
	ThirdBar = (Game.GetFormFromFile(0x000DBD, "Ostim.esp")) as Osexbar

	blue = 0xADD8E6
	pink = 0xffb6c1
	yellow = 0xe6e0ad
	gray = 0xb0b0b0
	white = 0xffffff

	InititializeAllBars()

	OnGameLoad()
EndEvent

Function InititializeAllBars()
	InitBar(dombar,0)
	InitBar(subbar, 1)
	InitBar(thirdbar, 2)
EndFunction

Function InitBar(Osexbar Bar, int id)
	Bar.HAnchor = "left"
	Bar.VAnchor = "bottom"
	Bar.X = 200
	Bar.Alpha = 0.0
	Bar.SetPercent(0.0)
	Bar.FillDirection = "Right"

	If (id == 0)
		Bar.Y = 692
		Bar.SetColors(gray, blue, white)
	Elseif (id == 1)
		Bar.Y = 647
		Bar.SetColors(gray, pink, white)
	ElseIf (id == 2)
		Bar.Y = 602
		Bar.SetColors(gray, yellow, white)
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

	If (ostim.EnableThirdBar) && (ostim.GetThirdActor() != none) 
		SetBarPercent(ThirdBar, 0.0)
    	SetBarVisible(ThirdBar, True)
	EndIf


	While ostim.AnimationRunning()
		If (ostim.AutoHideBars && (ostim.GetTimeSinceLastPlayerInteraction() > 15.0)) ; fade out if needed
    		If (IsBarVisible(DomBar))
    			SetBarVisible(DomBar, False)
    		EndIf
    		If (IsBarVisible(SubBar))
    			SetBarVisible(SubBar, False)
    		EndIf
    		If (IsBarVisible(thirdbar))
    			SetBarVisible(thirdbar, False)
    		EndIf
    	EndIf

    	SetBarPercent(DomBar, ostim.getactorexcitement(ostim.GetDomActor()))
		SetBarPercent(SubBar, ostim.getactorexcitement(ostim.GetSubActor()))
		if ostim.GetThirdActor()
			SetBarPercent(ThirdBar, ostim.getactorexcitement(ostim.GetThirdActor()))
		EndIf

		Utility.wait(1)
	EndWhile


	SetBarVisible(DomBar, False)
	SetBarPercent(DomBar, 0.0)
	SetBarVisible(SubBar, False)
	SetBarPercent(SubBar, 0.0)
	SetBarVisible(ThirdBar, False)
	SetBarPercent(ThirdBar, 0.0)
EndEvent

Event OstimOrgasm(string eventName, string strArg, float numArg, Form sender)
	actor act = ostim.getmostrecentorgasmedactor()

	If (Act == ostim.GetDomActor())
		FlashBar(dombar)
		SetBarPercent(DomBar, 0)
	ElseIf (Act == ostim.GetSubActor())
		FlashBar(subbar)
		SetBarPercent(SubBar, 0)
	ElseIf (Act == ostim.GetThirdActor())
		FlashBar(ThirdBar)
		SetBarPercent(ThirdBar, 0)
	EndIf
endevent

Event OstimThirdJoin(string eventName, string strArg, float numArg, Form sender)
	If (ostim.EnableThirdBar)
		OsexIntegrationMain.Console("Launching third actor bar")
		SetBarPercent(ThirdBar, 0.0)
    	SetBarVisible(ThirdBar, True)
	EndIf
Endevent	

Event OstimThirdLeave(string eventName, string strArg, float numArg, Form sender)
	OsexIntegrationMain.Console("Closing third actor bar")
	SetBarVisible(ThirdBar, False)
	SetBarPercent(ThirdBar, 0.0)
Endevent

Function OnGameLoad()
	RegisterForModEvent("ostim_start", "OstimStart")
	RegisterForModEvent("ostim_orgasm", "OstimOrgasm")

	RegisterForModEvent("ostim_thirdactor_join", "OstimThirdJoin")
	RegisterForModEvent("ostim_thirdactor_leave", "OstimThirdLeave")

	osexintegrationmain.Console("Fixing Bars thread")
EndFunction