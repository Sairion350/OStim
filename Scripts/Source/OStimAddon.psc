ScriptName OStimAddon Extends Quest

; 	HOW TO USE THIS
; This script contains some common things addons need to function
; Have your addon script extend this one, then at the end of the addon's oninit, call InstallAddon()


OSexIntegrationMain property ostim auto 
actor property playerref auto 

string property AddonName auto
int property RequiredVersion auto 

;------------------------- MUST CALL THIS FROM ONINIT
Function InstallAddon(string name, int RequiredAPIVersion = 1)
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

Event OnGameLoad() 
{Event called on each game load. Extend this}
EndEvent

Event OnInit()
	Debug.messagebox("Extend me!")
EndEvent

