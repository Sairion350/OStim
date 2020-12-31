ScriptName OStimPlayerAliasScript extends ReferenceAlias
 
OSexIntegrationMain Property OStim Auto

event onInit()
	OStim = (GetOwningQuest()) as OsexIntegrationMain
endevent 

Event OnPlayerLoadGame()
	OStim.onLoadGame()
EndEvent