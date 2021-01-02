ScriptName OStimPlayerAliasScript Extends ReferenceAlias

OSexIntegrationMain Property OStim Auto

Event OnInit()
	OStim = (GetOwningQuest()) as OsexIntegrationMain
Endevent

Event OnPlayerLoadGame()
	OStim.OnLoadGame()
EndEvent