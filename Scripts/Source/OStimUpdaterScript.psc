ScriptName OStimUpdaterScript Extends Quest

OsexIntegrationMain OStim
Quest OQuest

Bool Initialized

Event OnInit()
	Initialized = False
	OStim = Game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain
	OQuest = OStim as Quest

	OsexIntegrationMain.Console("Updater ready")
	Initialized = True
EndEvent

Function DoUpdate()
	OStim.DisplayTextBanner("Updating OStim")

	OQuest.Reset()
	OQuest.Stop()
	Utility.Wait(4)
	OQuest.Start()

	OsexIntegrationMain.Console("Updated")
EndFunction

Function OnGameLoad()
	While (!Initialized)
		Utility.Wait(1)
	EndWhile
EndFunction
