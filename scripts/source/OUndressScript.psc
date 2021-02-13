ScriptName OUndressScript Extends Quest

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

function strip(actor target) ; if you do a toggle mid scene, you MUST disable free cam or else!
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

		PickUpThings(target, things)
	else
		Form[] things
		if target == ostim.GetDomActor()
			things = DomEquipmentForms
		elseif target == ostim.GetSubActor()
			things = SubEquipmentForms
		elseif target == ostim.GetThirdActor() || (target == ThirdActorAfterLeaving)
			things = ThirdEquipmentForms
		endif

		EquipForms(target, things)
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
EndFunction

function UnequipForms(actor target, Form[] items)
	int i = 0

	while i < items.Length
		
		if items[i]
			target.UnEquipItem(items[i], false, true)
		EndIf

		i += 1
	endwhile
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

Function EquipForms(actor target, Form[] items)
	int i = 0

	while i < items.Length
		
		if items[i]
			target.additem(items[i], 1, true)
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
			EndIf
		ElseIf (!SubNaked)
			If (CClass == "Sx") || (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2") || (CClass == "An")|| (CClass == "BoJ")|| (CClass == "BoF")
				If ostim.IsInFreeCam()
					DidToggle = True
					ostim.ToggleFreeCam()
				EndIf
				strip(ostim.GetSubActor())
			EndIf
		ElseIf (!ThirdNaked)
			If (CClass == "Sx") || (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2") || (CClass == "An")|| (CClass == "BoJ")|| (CClass == "BoF")
				If ostim.IsInFreeCam()
					DidToggle = True
					ostim.ToggleFreeCam()
				EndIf
				strip(ostim.getthirdactor())
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

Function Console(String In)
	OsexIntegrationMain.Console(In)
EndFunction

Function onGameLoad()
	RegisterForModEvent("ostim_prestart", "OStimPreStart")
	RegisterForModEvent("ostim_end", "OstimEnd")

	RegisterForModEvent("ostim_animationchanged", "OstimChange")

	RegisterForModEvent("ostim_thirdactor_join", "OstimThirdJoin")
	RegisterForModEvent("ostim_thirdactor_leave", "OstimThirdLeave")
EndFunction