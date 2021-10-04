ScriptName OStimAddon Extends Quest Hidden

; 	HOW TO USE THIS
; This script contains some common things addons need to function
; Have your addon script extend this one, then at the end of the addon's oninit, call InstallAddon()


; Free properties you have access to in all scripts that extend this one
OSexIntegrationMain property ostim auto 
actor property playerref auto 


;------------------------- MUST CALL THIS FROM ONINIT
Function InstallAddon(string name, int RequiredAPIVersion = 24)
	ostim = outils.GetOStim()
	playerref = game.GetPlayer()

	AddonName = name
	RequiredVersion = RequiredAPIVersion


	if ostim.GetAPIVersion() < RequiredVersion
		debug.MessageBox("Your OStim version is out of date. Please update for " + name + " to function.")
		debug.MessageBox("Your OStim version is: " + ostim.GetAPIVersion())
		return 
	endif  

	OStim.RegisterForGameLoadEvent(self) ; register for OnGameLoad() 
	outils.RegisterForOUpdate(self) ;register to update system

	osanative.SendEvent(self, "OnGameLoad") ; call ongameload once.

	debug.Notification(name + " installed")
EndFunction
;---------------------------

Event OnInit()
	Debug.messagebox("Extend me!")
EndEvent

string property AddonName auto
int property RequiredVersion auto 

string[] property RegisteredEvents auto ; Insert events into here to register on each load
; You cannot use this system while extending OnGameLoad.


Event OnGameLoad() ; You can either extend this, or not extend it and use RegisteredEvents
	if RegisteredEvents
			
	endif 
EndEvent

Function RegisterSavedEvents()
	int i = 0 
	int l = RegisteredEvents.Length
	while i < l 
		registerforoevent(RegisteredEvents[i])

		i += 1
	endwhile
EndFunction




Function RegisterForOEvent(string EventName)
	RegisterForModEvent(EventName, EventName)
EndFunction


Event OStim_PreStart(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_Start(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_AnimationChanged(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_SceneChanged(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_Orgasm(string eventName, string strArg, float numArg, Form sender)
EndEvent

Event OStim_End(string eventName, string strArg, float numArg, Form sender)
EndEvent
