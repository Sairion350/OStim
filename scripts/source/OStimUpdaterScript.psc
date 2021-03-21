ScriptName OStimUpdaterScript Extends Quest

OsexIntegrationMain ostim
quest oquest

bool inited

Event OnInit()
	inited = false
	ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain
	oquest = ostim as quest 

	OsexIntegrationMain.Console("Updater ready")
	inited = true
EndEvent

Function DoUpdate()
	ostim.DisplayTextBanner("Updating OStim")
	oquest.Reset()
	oquest.Stop()
	Utility.Wait(4)
	oquest.Start()

	OsexIntegrationMain.Console("Updated")
EndFunction

function ongameload()
	while !inited
		Utility.Wait(1)
	Endwhile

EndFunction