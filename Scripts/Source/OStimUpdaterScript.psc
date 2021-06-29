ScriptName OStimUpdaterScript Extends Quest


Bool Initialized

Bool Updating

Form[] property FormsToUpdate auto 

Event OnInit()
	Initialized = False
	Updating = false
	
	ResetQuestDB()

	OUtils.Console("Updater ready")
	Initialized = True
EndEvent

Function ResetQuestDB()
	FormsToUpdate = new form[4]

	FormsToUpdate[2] = Quest.GetQuest("0SA") ; 0SA
	FormsToUpdate[1] = Game.GetFormFromFile(0x0070A4, "OSA.esm") as Quest ; 0SUI
	FormsToUpdate[0] = Quest.GetQuest("0SAControl") as Quest ; 0SAControl
	FormsToUpdate[3] = Game.GetFormFromFile(0x000801, "Ostim.esp") as Quest ; ostim
EndFunction

Function DoUpdate()
	Updating = true 

	OUtils.DisplayTextBanner("Updating OStim")


	Form[] Forms = FormsToUpdate

	int i = 0 
	int l = forms.Length 
	while i < l
		form f = forms[i]
		quest q = forms[i] as quest
		
		if q
			q.reset()
			q.stop()
		endif

		f.UnregisterForAllMenus()
		f.UnregisterForUpdateGameTime()
		f.UnregisterForUpdate()
		f.UnregisterForAllModEvents()
		f.UnregisterForAllKeys()



		i += 1
	EndWhile

	ResetQuestDB()
	Utility.Wait(2)
	
	i = 0 
	while i < l 
		form f = forms[i]
		quest q = forms[i] as quest
		
		if q 
			q.start()
		endif 

		OSANative.ForceFireOnInitEvent(f)
		

		Utility.Wait(0.1)

		i += 1
	EndWhile

	SendModEvent("0SA_UIBoot")


	OUtils.Console("Updated")

	Updating = false
EndFunction



Function AddFormToDatabase(form f)
	while Updating
		Utility.Wait(1)
	EndWhile

	 
	FormsToUpdate = PapyrusUtil.PushForm(FormsToUpdate, f)
EndFunction
