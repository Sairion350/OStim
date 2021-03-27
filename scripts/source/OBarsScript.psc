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
	ThirdBar = (Game.GetFormFromFile(0x000802, "Ostim.esp")) as Osexbar

	blue = 0xADD8E6
	pink = 0xffb6c1
	yellow = 0xe6e0ad
	gray = 0xb0b0b0
	white = 0xffffff

	InititializeAllBars()

	OnGameLoad()

	lastsmacktime = 0
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

Function ColorBar(OSexbar bar, bool female = true, int colorz = -1)
	int color
	if !female 
		color = blue
	else 
		color = pink 
	endif

	if colorz > 0
		color = colorz
	endif

	Bar.SetColors(gray, color, white)
Endfunction

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

float Function GetBarPercent(Osexbar Bar)
	return bar.Percent * 100.0
EndFunction

Function FlashBar(Osexbar Bar)
	Bar.ForceFlash()
EndFunction

Event OstimStart(string eventName, string strArg, float numArg, Form sender)
	
	if ostim.MatchBarColorToGender
		ColorBar(dombar, ostim.AppearsFemale(ostim.GetDomActor()))
		ColorBar(subbar, ostim.AppearsFemale(ostim.GetSubActor()))
		ColorBar(ThirdBar, ostim.AppearsFemale(ostim.GetThirdActor()))

	else
		ColorBar(dombar, colorz = blue)
		ColorBar(subbar, colorz = pink)
		ColorBar(thirdbar, colorz = yellow)
	endif 

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

    	if ((Game.GetRealHoursPassed() * 60 * 60) - lastSmackTime) > 3 ; 3 seconds with no update data... time to fall back
    		SetBarFullnessProper()
        endif
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
		SetBarPercent(DomBar, 100)
		FlashBar(dombar)
		Utility.Wait(2)
		SetBarPercent(DomBar, 0)
	ElseIf (Act == ostim.GetSubActor())
		SetBarPercent(subbar, 100)
		FlashBar(subbar)
		Utility.Wait(2)
		SetBarPercent(SubBar, 0)
	ElseIf (Act == ostim.GetThirdActor())
		SetBarPercent(thirdbar, 100)
		FlashBar(ThirdBar)
		Utility.Wait(2)
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

float lastSmackTime
int lastSpeed
Event OnOSASound(string eventName, string args, float nothing, Form sender)
	string[] argz = new string[3]
	argz = StringUtil.Split(args, ",")

	int formID = argz[1] as Int

	If (formID == 50) || (formID == 60) ; we are getting a smacking sound, bodies have collided.
		;osexintegrationmain.Console("Smack recieved")
		if formid == 60 ;better sync with spank
			Utility.Wait(0.2)
		endif
		float currTime = Game.GetRealHoursPassed() * 60 * 60
		float timediff = currTime - lastSmackTime ; time since last smack sound

		if (timediff > 2.5) ; it's been a long time since we got a smacking sound 
			SetBarFullnessProper() ; set bar to the correct value
		Else
			float correctnessdiffdom 
			float correctnessdiffsub 
			float correctnessdiffthird
			
			correctnessdiffdom = GetBarCorrectnessDifference(0) ;get how far off the current dom bar is
			correctnessdiffsub = GetBarCorrectnessDifference(1)
			if ostim.getthirdActor()
				correctnessdiffthird = GetBarCorrectnessDifference(2) 
			EndIf
			;osexintegrationmain.console("Bar difference: " + correctnessdiffdom)

			if timediff < 1 
				 ; events are coming in at a rate of more than 1/second. Change the error correction to be smaller
				correctnessdiffdom = correctnessdiffdom * timediff	
				correctnessdiffsub = correctnessdiffsub * timediff	
				correctnessdiffthird = correctnessdiffthird * timediff	
			endif


			;osexintegrationmain.console("adding: " + correctnessdiffdom)
			AddBarFullness(0, correctnessdiffdom)
			AddBarFullness(1, correctnessdiffsub)
			AddBarFullness(2, correctnessdiffthird)


		EndIf

		lastSmackTime = currtime
	EndIf

	
endevent

Function SetBarFullnessProper()
	SetBarPercent(DomBar, ostim.getactorexcitement(ostim.GetDomActor()))
	SetBarPercent(SubBar, ostim.getactorexcitement(ostim.GetSubActor()))
	if ostim.GetThirdActor()
		SetBarPercent(ThirdBar, ostim.getactorexcitement(ostim.GetThirdActor()))
	EndIf
EndFunction

Function AddBarFullness(int bar, float amount)
	if bar == 0
		SetBarPercent(DomBar, GetBarPercent(dombar) + amount)
	elseif bar == 1
		SetBarPercent(SubBar, GetBarPercent(subbar) + amount)
    elseif bar == 2
		SetBarPercent(ThirdBar, GetBarPercent(thirdbar) + amount)
	EndIf
EndFunction

float Function GetBarCorrectnessDifference(int barID)
	if barID == 0
		return ostim.getactorexcitement(ostim.GetDomActor()) - GetBarPercent(dombar)
	elseif barID == 1
		return ostim.getactorexcitement(ostim.GetSubActor()) - GetBarPercent(subbar)
	elseif barID == 2
		return ostim.getactorexcitement(ostim.GetThirdActor()) - GetBarPercent(thirdbar)
	endif
EndFunction

Function OnGameLoad()
	RegisterForModEvent("ostim_start", "OstimStart")
	RegisterForModEvent("ostim_orgasm", "OstimOrgasm")

	RegisterForModEvent("ostim_thirdactor_join", "OstimThirdJoin")
	RegisterForModEvent("ostim_thirdactor_leave", "OstimThirdLeave")

	RegisterForModEvent("ostim_osasound", "OnOSASound")


	osexintegrationmain.Console("Fixing Bars thread")
EndFunction