ScriptName OUndressScript Extends Quest
; todo ammo unequip?
OsexIntegrationMain OStim

Form[] property DomEquipmentForms auto ;in-inventory versions
Form[] property SubEquipmentForms auto
Form[] property ThirdEquipmentForms auto

ObjectReference[] property DomEquipmentDrops auto ; on-the-ground versions
ObjectReference[] property SubEquipmentDrops auto
ObjectReference[] property ThirdEquipmentDrops auto

Armor Property FakeArmor  Auto  

actor playerref

actor ThirdActorAfterLeaving

Event OnInit()
	OStim = (Self as Quest) as OsexIntegrationMain
	FakeArmor = (Game.GetFormFromFile(0x000800, "Ostim.esp")) as armor

	ongameload()
	playerref = game.GetPlayer()
EndEvent

function strip(actor target) ; if you do a strip mid scene, you MUST disable free cam or else!
	if ostim.TossClothesOntoGround
		StripAndtoss(target)
	elseif ostim.UseStrongerUnequipMethod
		StoreEquipmentForms(target)
		EquipFakeArmor(target)
	else
		form[] things = StoreEquipmentForms(target)
		UnequipForms(target, things)
	endif
EndFunction

function redress(actor target)
	if target.IsDead() 
		Return
	endif


	if ostim.TossClothesOntoGround
		ObjectReference[] things
		if target == ostim.GetDomActor()
			things = DomEquipmentDrops
		elseif target == ostim.GetSubActor()
			things = SubEquipmentDrops
		elseif (target == ostim.GetThirdActor()) || (target == ThirdActorAfterLeaving)
			things = ThirdEquipmentDrops
		endif

		if ostim.FullyAnimateRedress && (target != playerref) && !(ostim.IsSceneAggressiveThemed())
			Form[] stuff = AddDroppedThingsToInv(target, things)
			FullyAnimateRedress(target, stuff)
		else
			PickUpThings(target, things)
		endif 
	else
		Form[] things
		if target == ostim.GetDomActor()
			things = DomEquipmentForms
		elseif target == ostim.GetSubActor()
			things = SubEquipmentForms
		elseif target == ostim.GetThirdActor() || (target == ThirdActorAfterLeaving)
			things = ThirdEquipmentForms
		endif

		if ostim.FullyAnimateRedress && (target != playerref) && !(ostim.IsSceneAggressiveThemed())
			FullyAnimateRedress(target, things)
		else
			EquipForms(target, things)
		endif
	endif
EndFunction

function UpdateFakeArmor()
	Console("Updating fake armor....")

	int i = 30
	While i < 62
		SetSlotInFakeArmor(Armor.GetMaskForSlot(i), false)
		i += 1
	EndWhile

	i = 0
	int l = ostim.StrippingSlots.Length
	while i < l
		SetSlotInFakeArmor(ostim.StrippingSlots[i], true)

		i += 1
	endwhile

	console("Fake armor update complete.")
endfunction	

Function SetSlotInFakeArmor(int iSlot, bool bSlot)
    int Mask = Armor.GetMaskForSlot(iSlot)
    If bSlot
        FakeArmor.AddSlotToMask(Mask)
    Else
        FakeArmor.RemoveSlotFromMask(Mask)
    EndIf
EndFunction

Function EquipFakeArmor(actor target)
	Target.EquipItem(FakeArmor,False,True)
    Utility.Wait(0.15)
    Target.RemoveItem(FakeArmor,99,true,None)

    target.unequipitem(target.GetEquippedObject(0))
	target.unequipitem(target.GetEquippedObject(1))
EndFunction

function UnequipForms(actor target, Form[] items)
	int i = 0

	while i < items.Length
		
		if items[i]
			target.UnEquipItem(items[i], false, true)
		EndIf

		i += 1
	endwhile

	target.unequipitem(target.GetEquippedObject(0))
	target.unequipitem(target.GetEquippedObject(1))
endfunction

Form[] Function StoreEquipmentForms(actor target)
	int arrayID

	if target == ostim.GetDomActor() ;I wish we had pointers of some kind
		arrayid = 0
	elseif target == ostim.GetSubActor()
		arrayid = 1
	elseif target == ostim.GetThirdActor()
		arrayid = 2
	endif
	

	int i = 0
	int l = ostim.StrippingSlots.Length
	
	while i < l
		form thing = target.GetEquippedArmorInSlot(ostim.Strippingslots[i]) as form ;se exclusive function

		if arrayID == 0 ; store the item for lter
			DomEquipmentForms = PapyrusUtil.PushForm(DomEquipmentForms, thing)
		elseif arrayID == 1
			SubEquipmentForms = PapyrusUtil.PushForm(SubEquipmentForms, thing)
		elseif arrayID == 2
			ThirdEquipmentForms = PapyrusUtil.PushForm(ThirdEquipmentForms, thing)
		endif

		i += 1
	endwhile


	if target.GetEquippedObject(0)
		form thing = target.GetEquippedObject(0)
		if arrayID == 0 ; store the item for lter
			DomEquipmentForms = PapyrusUtil.PushForm(DomEquipmentForms, thing)
		elseif arrayID == 1
			SubEquipmentForms = PapyrusUtil.PushForm(SubEquipmentForms, thing)
		elseif arrayID == 2
			ThirdEquipmentForms = PapyrusUtil.PushForm(ThirdEquipmentForms, thing)
		endif
	endif
	if target.GetEquippedObject(1)
		form thing = target.GetEquippedObject(1)
		if arrayID == 0 ; store the item for lter
			DomEquipmentForms = PapyrusUtil.PushForm(DomEquipmentForms, thing)
		elseif arrayID == 1
			SubEquipmentForms = PapyrusUtil.PushForm(SubEquipmentForms, thing)
		elseif arrayID == 2
			ThirdEquipmentForms = PapyrusUtil.PushForm(ThirdEquipmentForms, thing)
		endif
	endif


	if target == ostim.GetDomActor() ;I wish we had pointers of some kind
		return DomEquipmentForms
	elseif target == ostim.GetSubActor()
		return SubEquipmentForms
	elseif target == ostim.GetThirdActor()
		return ThirdEquipmentForms
	endif
EndFunction

function StripAndtoss(actor target)
	int arrayID

	if target == ostim.GetDomActor()
		arrayid = 0
	elseif target == ostim.GetSubActor()
		arrayid = 1
	elseif target == ostim.GetThirdActor()
		arrayid = 2
	endif

	int i = 0
	int l = ostim.StrippingSlots.Length
	
	while i < l
		form item = target.GetEquippedArmorInSlot(ostim.Strippingslots[i]) as form ;se exclusive function

		StripAndTossItem(target, item, arrayID)

		i += 1
	endwhile

	if target.GetEquippedObject(0)
		StripAndTossItem(target, target.GetEquippedObject(0), arrayID)
	endif
	if target.GetEquippedObject(1)
		StripAndTossItem(target, target.GetEquippedObject(1), arrayID)
	endif
endfunction

function StripAndTossItem(actor target, form item, int arrayID, bool doImpulse = true)
	if item
		objectreference thing = target.dropObject(item)
		thing.SetPosition(thing.GetPositionx(), thing.GetPositionY(), thing.GetPositionZ() + 64)
		if doImpulse
			thing.applyHavokImpulse(Utility.RandomFloat(-2.0, 2.0), Utility.RandomFloat(-2.0, 2.0), Utility.RandomFloat(0.2, 1.8), Utility.RandomFloat(5, 25))
		endif
		
		if arrayID == 0 ; store the item for lter
			DomEquipmentDrops = PapyrusUtil.PushObjRef(DomEquipmentDrops, thing)
		elseif arrayID == 1
			SubEquipmentDrops = PapyrusUtil.PushObjRef(SubEquipmentDrops, thing)
		elseif arrayID == 2
			ThirdEquipmentDrops = PapyrusUtil.PushObjRef(ThirdEquipmentDrops, thing)
		endif
	endif
endfunction

Function PickUpThings(actor target, ObjectReference[] items)
	int i = 0

	while i < items.Length
		
		if items[i]
			if playerref.GetItemCount(items[i]) < 1

				target.additem(items[i], 1, true)

				target.EquipItem(items[i].GetBaseObject(), false, true)
			endif
		EndIf

		i += 1
	endwhile
EndFunction

Form[] Function AddDroppedThingsToInv(actor target, ObjectReference[] items)
	form[] forms = new form[1]
	int i = 0

	while i < items.Length
		
		if items[i]
			if playerref.GetItemCount(items[i]) < 1
				target.additem(items[i], 1, true)
				forms = PapyrusUtil.PushForm(forms, items[i].GetBaseObject())
			endif
		EndIf

		i += 1
	endwhile

	return forms
EndFunction

Function EquipForms(actor target, Form[] items)
	int i = 0

	while i < items.Length
		
		if items[i]
			target.EquipItem(items[i], false, true)
		EndIf

		i += 1
	endwhile
EndFunction

Event OStimEnd(String EventName, String strArg, Float NumArg, Form Sender)
	Console("Redressing...")


	redress(ostim.GetDomActor())
	redress(ostim.GetSubActor())
	if ostim.GetThirdActor()
		redress(ostim.GetThirdActor())
	endif

	ThirdActorAfterLeaving = none
	
	SendModEvent("ostim_redresscomplete")
EndEvent


Event OStimPreStart(String EventName, String strArg, Float NumArg, Form Sender)
	Console("Stripping actors...")

	DomEquipmentDrops = new ObjectReference[1]
	SubEquipmentDrops = new ObjectReference[1]
	ThirdEquipmentDrops = new ObjectReference[1]

	DomEquipmentForms = new Form[1]
	SubEquipmentForms = new Form[1]
	ThirdEquipmentForms = new Form[1]

	If (ostim.AlwaysUndressAtAnimStart)
		ostim.UndressDom = True
		ostim.UndressSub = True
	EndIf

	If (ostim.AlwaysAnimateUndress)
		ostim.AnimateUndress = True
	EndIf



	If (ostim.UndressDom) ;animate undress, and chest-only strip not yet supported
		strip(ostim.GetDomActor())
	EndIf

	If (ostim.UndressSub)
		strip(ostim.GetSubActor())
	EndIf
	
	; Assume if sub is to be undressed, third actor should also be provided ThirdActor exists.
	if (ostim.UndressSub == True && ostim.getThirdActor() != None)
		strip(ostim.GetThirdActor())
		ThirdActorAfterLeaving = ostim.GetThirdActor()
	endIf

	Console("Stripped.")

	SendModEvent("ostim_undresscomplete")
EndEvent

Event OstimChange(string eventName, string strArg, float numArg, Form sender)
	bool DidToggle = False
	

	
	if ostim.AutoUndressIfNeeded && ostim.AnimationRunning()
		Bool DomNaked = ostim.IsNaked(ostim.GetDomActor())
		Bool SubNaked = ostim.IsNaked(ostim.GetSubActor())
		Bool ThirdNaked = true
		if ostim.getthirdactor()
			ThirdNaked = ostim.IsNaked(ostim.getthirdactor())
		endif
		String CClass = ostim.GetCurrentAnimationClass()
		If (!DomNaked)
			If (CClass == "Sx") || (CClass == "Po") || (CClass == "HhPo") || (CClass == "ApPJ") || (CClass == "HhPJ") || (CClass == "HJ") || (CClass == "ApHJ") || (CClass == "DHJ") || (CClass == "SJ")|| (CClass == "An")|| (CClass == "BoJ")|| (CClass == "FJ")
				If ostim.IsInFreeCam()
					DidToggle = True
					ostim.ToggleFreeCam()
				EndIf
				strip(ostim.getdomactor())
				SendModEvent("ostim_midsceneundress_dom")
			EndIf
		EndIf
		If (!SubNaked)
			If (CClass == "Sx") || (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2") || (CClass == "An")|| (CClass == "BoJ")|| (CClass == "BoF")
				If ostim.IsInFreeCam()
					DidToggle = True
					ostim.ToggleFreeCam()
				EndIf
				strip(ostim.GetSubActor())
				SendModEvent("ostim_midsceneundress_sub")
			EndIf
		EndIf
		If (!ThirdNaked)
			If (CClass == "Sx") || (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2") || (CClass == "An")|| (CClass == "BoJ")|| (CClass == "BoF")
				If ostim.IsInFreeCam()
					DidToggle = True
					ostim.ToggleFreeCam()
				EndIf
				strip(ostim.getthirdactor())
				SendModEvent("ostim_midsceneundress_third")
			EndIf
		EndIf
	EndIf 

	If DidToggle
		ostim.ToggleFreeCam()
	EndIf
EndEvent

Event OstimThirdJoin(string eventName, string strArg, float numArg, Form sender)
	If ostim.AlwaysUndressAtAnimStart
		Console("Stripping third actor")
		bool didToggle = false
		If ostim.IsInFreeCam()
					DidToggle = True
					ostim.ToggleFreeCam()
		EndIf
		Strip(ostim.GetThirdActor())
		If DidToggle
			ostim.ToggleFreeCam()
		EndIf
	EndIf

	ThirdActorAfterLeaving = ostim.GetThirdActor()
EndEvent

Event OstimThirdLeave(string eventName, string strArg, float numArg, Form sender)
	Console("Redressing third actor")
	redress(ThirdActorAfterLeaving)
EndEvent

form[] set1
form[] set2
form[] set3

actor act1
actor act2
actor act3

Event AnimatedRedressThread(string eventName, string strArg, float numArg, Form sender)
	form[] items
	actor target

	if numArg == 1.0
		items = set1
		target = act1
	elseif numarg == 2.0
		items = set2
		target = act2
	elseif numarg == 3.0
		items = set3
		target = act3
	endif

	;items = PapyrusUtil.
	bool female = ostim.AppearsFemale(target)

	float startingHealth = target.GetAV("Health")

	Utility.Wait(Utility.RandomFloat(0.45, afMax = 0.65))

	int i = 0
	while i < items.Length
		
		if items[i]
			bool loaded = target.is3dloaded()
			If ostim.IsActorActive(target) || target.IsDead() || (target.GetAV("Health") < startingHealth)
				loaded = false
			EndIf

			armor armorpiece = (items[i] as armor)
			int slotmask = armorpiece.GetSlotMask()

			string undressAnim = ""
			float AnimLen = 0
			float dressPoint = 0

			if armorpiece.IsCuirass() || armorpiece.IsClothingBody()
				if female
					undressAnim = "0Eq0ER_F_ST_D_cuirass_0"
					AnimLen = 9
					dressPoint = 4.5
				else 
					undressAnim = "0Eq0ER_M_ST_D_cuirass_0"
					AnimLen = 8
					dressPoint = 5
				endif
			ElseIf armorpiece.IsBoots() || armorpiece.IsClothingFeet()
				if female
					undressAnim = "0Eq0ER_F_SI_D_boots_0"
					AnimLen = 17
					dressPoint = 4.5
				else
					undressAnim = "0Eq0ER_M_ST_D_boots_0"
					AnimLen = 8
					dressPoint = 5
				endif
			elseif armorpiece.IsHelmet() || armorpiece.IsClothingHead()
				if female
					undressAnim = "0Eq0ER_F_ST_D_helmet_0"
					AnimLen = 12.5
					dressPoint = 9.5
				else
					undressAnim = "0Eq0ER_M_ST_D_helmet_0"
					AnimLen = 5
					dressPoint = 3
				endif
			elseif armorpiece.IsGauntlets() || armorpiece.IsClothingHands()
				if female
					undressAnim = "0Eq0ER_F_ST_D_gloves_0"
					AnimLen = 12
					dressPoint = 3
				else
					undressAnim = "0Eq0ER_M_ST_D_gloves_0"
					AnimLen = 8
					dressPoint = 6.5
				endif
			endif			



			if undressAnim != "" && loaded
				debug.SendAnimationEvent(target, undressAnim)
			EndIf
			if loaded
				Utility.Wait(dressPoint)
			endif
			if !target.IsDead() && !ostim.IsActorActive(target)
				target.EquipItem(items[i], false, true)
			endif
			if loaded
				Utility.Wait(AnimLen - dressPoint)
			endif


		EndIf


		i += 1
	endwhile

	if !ostim.IsActorActive(target)
		Debug.SendAnimationEvent(target, "IdleForceDefaultState")
	endif 

	if numArg == 1.0
		act1 = none 
		set1 = new form[1]
	elseif numarg == 2.0
		act2 = none 
		set2 = new form[1]
	elseif numarg == 3.0
		act3 = none 
		set3 = new form[1]
	endif
EndEvent

function FullyAnimateRedress(actor target, Form[] items)
	float arg

	if act1 == none
		arg = 1.0
		act1 = target 
		set1 = items
	elseif act2 == none
		arg = 2.0
		act2 = target 
		set2 = items
	elseif act3 == none
		arg = 3.0
		act3 = target 
		set3 = items
	endif

	SendModEvent("ostim_redressthread", numArg = arg)

EndFunction

Function Console(String In)
	OsexIntegrationMain.Console(In)
EndFunction

Function onGameLoad()
	RegisterForModEvent("ostim_prestart", "OStimPreStart")
	RegisterForModEvent("ostim_end", "OstimEnd")

	RegisterForModEvent("ostim_animationchanged", "OstimChange")

	RegisterForModEvent("ostim_thirdactor_join", "OstimThirdJoin")
	RegisterForModEvent("ostim_thirdactor_leave", "OstimThirdLeave")

	
	RegisterForModEvent("ostim_redressthread", "AnimatedRedressThread")
EndFunction