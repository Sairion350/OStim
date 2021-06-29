ScriptName OStimUpdaterScript Extends Quest


Bool Initialized

Form[] property QuestsToUpdate auto 

Event OnInit()
	Initialized = False
	
	ResetQuestDB()

	OUtils.Console("Updater ready")
	Initialized = True
EndEvent

Function ResetQuestDB()
	QuestsToUpdate = new form[4]

	QuestsToUpdate[2] = Quest.GetQuest("0SA") ; 0SA
	QuestsToUpdate[1] = Game.GetFormFromFile(0x0070A4, "OSA.esm") as Quest ; 0SUI
	QuestsToUpdate[0] = Quest.GetQuest("0SAControl") as Quest ; 0SAControl
	QuestsToUpdate[3] = Game.GetFormFromFile(0x000801, "Ostim.esp") as Quest ; ostim
EndFunction

Function DoUpdate()
	OUtils.DisplayTextBanner("Updating OStim")


	Form[] quests = QuestsToUpdate

	int i = 0 
	int l = quests.Length 
	while i < l
		quest q = quests[i] as quest
		
		
		q.reset()
		q.stop()

		q.UnregisterForAllMenus()
		q.UnregisterForUpdateGameTime()
		q.UnregisterForUpdate()
		q.UnregisterForAllModEvents()
		q.UnregisterForAllKeys()



		i += 1
	EndWhile

	ResetQuestDB()
	Utility.Wait(2)
	
	i = 0 
	while i < l 
		quest q = quests[i] as quest
		
		q.start()
		OSANative.ForceFireOnInitEvent(q)
		

		Utility.Wait(0.1)

		i += 1
	EndWhile

	SendModEvent("0SA_UIBoot")


	OUtils.Console("Updated")
EndFunction



Function AddQuestToDatabase(quest q)
	QuestsToUpdate = PapyrusUtil.PushForm(QuestsToUpdate, q as form)
EndFunction
