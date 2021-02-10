ScriptName OBarsScript Extends Quest
;On-screen bar manager

OsexIntegrationMain OStim

Event OnInit()
	OStim = (Self as Quest) as OsexIntegrationMain
EndEvent