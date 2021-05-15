ScriptName OUndressScript Extends Quest

; TODO: Ammo unequip?
OsexIntegrationMain OStim

Form[] Property DomEquipmentForms Auto ;in-inventory versions
Form[] Property SubEquipmentForms Auto
Form[] Property ThirdEquipmentForms Auto

ObjectReference[] Property DomEquipmentDrops Auto ; on-the-ground versions
ObjectReference[] Property SubEquipmentDrops Auto
ObjectReference[] Property ThirdEquipmentDrops Auto

Armor Property FakeArmor Auto

Actor PlayerRef
Actor ThirdActorAfterLeaving

Event OnInit()
	OStim = (Self as Quest) as OsexIntegrationMain
	FakeArmor = (Game.GetFormFromFile(0x000800, "Ostim.esp")) as Armor

	OnGameLoad()
	PlayerRef = Game.GetPlayer()
EndEvent

Function Strip(Actor Target) ; if you do a strip mid scene, you MUST disable free cam or else!
	If (OStim.TossClothesOntoGround)
		StripAndToss(Target)
	Elseif (OStim.UseStrongerUnequipMethod)
		StoreEquipmentForms(Target)
		EquipFakeArmor(Target)
	Else
		Form[] Things = StoreEquipmentForms(Target)
		UnequipForms(Target, Things)
	Endif
EndFunction

Function Redress(Actor Target)
	If Target.IsDead()
		Return
	Endif

	If (OStim.TossClothesOntoGround)
		ObjectReference[] Things
		If (Target == OStim.GetDomActor())
			Things = DomEquipmentDrops
		ElseIf (Target == OStim.GetSubActor())
			Things = SubEquipmentDrops
		ElseIf (Target == OStim.GetThirdActor()) || (target == ThirdActorAfterLeaving)
			Things = ThirdEquipmentDrops
		EndIf

		If (OStim.FullyAnimateRedress && (Target != PlayerRef) && !OStim.IsSceneAggressiveThemed()) && !(Target.IsInCombat())
			Form[] Stuff = AddDroppedThingsToInv(Target, Things)
			FullyAnimateRedress(Target, Stuff)
		Else
			PickUpThings(Target, Things)
		EndIf
	Else
		Form[] Things
		If (Target == OStim.GetDomActor())
			Things = DomEquipmentForms
		ElseIf (Target == OStim.GetSubActor())
			Things = SubEquipmentForms
		ElseIf (Target == OStim.GetThirdActor()) || (Target == ThirdActorAfterLeaving)
			Things = ThirdEquipmentForms
		EndIf

		If (OStim.FullyAnimateRedress && (Target != PlayerRef) && !OStim.IsSceneAggressiveThemed()) && !(Target.IsInCombat())
			FullyAnimateRedress(Target, Things)
		Else
			EquipForms(Target, Things)
		EndIf
	endif
EndFunction

Function UpdateFakeArmor()
	Console("Updating fake armor....")

	Int i = 30
	While (i < 62)
		SetSlotInFakeArmor(Armor.GetMaskForSlot(i), False)
		i += 1
	EndWhile

	i = 0
	Int len = OStim.StrippingSlots.Length
	While (i < len)
		SetSlotInFakeArmor(OStim.StrippingSlots[i], True)
		i += 1
	EndWhile

	Console("Fake armor update complete.")
EndFunction

Function SetSlotInFakeArmor(Int iSlot, Bool bSlot)
    int Mask = Armor.GetMaskForSlot(iSlot)
    If (bSlot)
        FakeArmor.AddSlotToMask(Mask)
    Else
        FakeArmor.RemoveSlotFromMask(Mask)
    EndIf
EndFunction

Function EquipFakeArmor(Actor Target)
	Target.EquipItem(FakeArmor, False, True)
    Utility.Wait(0.15)
    Target.RemoveItem(FakeArmor, 99, True)
    Target.UnequipItem(Target.GetEquippedObject(0))
	Target.UnequipItem(Target.GetEquippedObject(1))
EndFunction

Function UnequipForms(Actor Target, Form[] Items)
	Int i = 0
	While (i < Items.Length)
		Form Item = Items[i]
		If (Item)
			Target.UnequipItem(Item, False, True)
		EndIf
		i += 1
	EndWhile

	Target.UnequipItem(Target.GetEquippedObject(0))
	Target.UnequipItem(Target.GetEquippedObject(1))
EndFunction

Function PushEquipmentForm(Int ArrayID, Form Thing)
	If (ArrayID == 0) ; store the item for lter
		DomEquipmentForms = PapyrusUtil.PushForm(DomEquipmentForms, Thing)
	ElseIf (ArrayID == 1)
		SubEquipmentForms = PapyrusUtil.PushForm(SubEquipmentForms, Thing)
	ElseIf (ArrayID == 2)
		ThirdEquipmentForms = PapyrusUtil.PushForm(ThirdEquipmentForms, Thing)
	EndIf
EndFunction

Form[] Function StoreEquipmentForms(Actor Target)
	Int ArrayID
	If (Target == OStim.GetDomActor()) ; I wish we had pointers of some kind
		ArrayID = 0
	ElseIf (Target == OStim.GetSubActor())
		ArrayID = 1
	ElseIf (Target == OStim.GetThirdActor())
		ArrayID = 2
	EndIf

	Int i = 0
	Int len = OStim.StrippingSlots.Length
	While (i < len)
		Form Thing = Target.GetEquippedArmorInSlot(OStim.StrippingSlots[i]) as Form ; SE exclusive function
		PushEquipmentForm(ArrayID, Thing)
		i += 1
	EndWhile

	Form Obj0 = Target.GetEquippedObject(0)
	If (Obj0)
		PushEquipmentForm(ArrayID, Obj0)
	EndIf

	Form Obj1 = Target.GetEquippedObject(1)
	If (Obj1)
		PushEquipmentForm(ArrayID, Obj1)
	EndIf

	If (Target == OStim.GetDomActor()) ; I wish we had pointers of some kind
		Return DomEquipmentForms
	ElseIf (Target == OStim.GetSubActor())
		Return SubEquipmentForms
	ElseIf (Target == OStim.GetThirdActor())
		Return ThirdEquipmentForms
	EndIf
EndFunction

Function StripAndToss(Actor Target)
	Int ArrayID
	If (Target == OStim.GetDomActor())
		ArrayID = 0
	ElseIf (Target == OStim.GetSubActor())
		ArrayID = 1
	ElseIf (Target == OStim.GetThirdActor())
		ArrayID = 2
	EndIf

	Int i = 0
	Int len = OStim.StrippingSlots.Length
	While (i < len)
		Form Item = Target.GetEquippedArmorInSlot(OStim.Strippingslots[i]) as Form ; SE exclusive function
		StripAndTossItem(Target, Item, ArrayID)
		i += 1
	EndWhile

	Form Obj0 = Target.GetEquippedObject(0)
	If (Obj0)
		StripAndTossItem(Target, Obj0, ArrayID)
	EndIf

	Form Obj1 = Target.GetEquippedObject(1)
	If (Obj1)
		StripAndTossItem(Target, Obj1, ArrayID)
	EndIf
EndFunction

Function StripAndTossItem(Actor Target, Form Item, Int ArrayID, Bool DoImpulse = True)
	If (!Item) ; Is this check really necessary?
		Return
	EndIf

	ObjectReference Thing = Target.DropObject(Item)
	Thing.SetPosition(Thing.GetPositionX(), Thing.GetPositionY(), Thing.GetPositionZ() + 64)
	If (DoImpulse)
		Thing.ApplyHavokImpulse(Utility.RandomFloat(-2.0, 2.0), Utility.RandomFloat(-2.0, 2.0), Utility.RandomFloat(0.2, 1.8), Utility.RandomFloat(5, 25))
	EndIf

	If (ArrayID == 0) ; store the item for lter
		DomEquipmentDrops = PapyrusUtil.PushObjRef(DomEquipmentDrops, Thing)
	ElseIf (ArrayID == 1)
		SubEquipmentDrops = PapyrusUtil.PushObjRef(SubEquipmentDrops, Thing)
	ElseIf (ArrayID == 2)
		ThirdEquipmentDrops = PapyrusUtil.PushObjRef(ThirdEquipmentDrops, Thing)
	EndIf
EndFunction

Function PickUpThings(Actor Target, ObjectReference[] Items)
	Int i = 0
	While (i < Items.Length)
		ObjectReference Item = Items[i]
		If (Item)
			If (PlayerRef.GetItemCount(Item) < 1)
				Target.AddItem(Item, 1, True)
				Target.EquipItem(Item.GetBaseObject(), False, True)
			endif
		EndIf
		i += 1
	EndWhile
EndFunction

Form[] Function AddDroppedThingsToInv(Actor Target, ObjectReference[] Items)
	Form[] Forms = new Form[1]
	Int i = 0
	While (i < Items.Length)
		ObjectReference Item = Items[i]
		If (Item)
			If (PlayerRef.GetItemCount(Item) < 1)
				Target.AddItem(Item, 1, True)
				Forms = PapyrusUtil.PushForm(Forms, Item.GetBaseObject())
			EndIf
		EndIf
		i += 1
	EndWhile

	Return Forms
EndFunction

Function EquipForms(Actor Target, Form[] Items)
	Int i = 0
	While (i < Items.Length)
		Form Item = Items[i]
		If (Item)
			Target.EquipItem(Item, False, True)
		EndIf
		i += 1
	EndWhile
EndFunction

Event OStimEnd(String EventName, String StrArg, Float NumArg, Form Sender)
	Console("Redressing...")

	Redress(OStim.GetDomActor())
	Redress(OStim.GetSubActor())

	Actor ThirdActor = OStim.GetThirdActor()
	If (ThirdActor)
		Redress(ThirdActor)
	EndIf

	ThirdActorAfterLeaving = None
	SendModEvent("ostim_redresscomplete")
EndEvent

Event OStimPreStart(String EventName, String StrArg, Float NumArg, Form Sender)
	Console("Stripping actors...")

	DomEquipmentDrops = new ObjectReference[1]
	SubEquipmentDrops = new ObjectReference[1]
	ThirdEquipmentDrops = new ObjectReference[1]

	DomEquipmentForms = new Form[1]
	SubEquipmentForms = new Form[1]
	ThirdEquipmentForms = new Form[1]

	If (OStim.AlwaysUndressAtAnimStart)
		OStim.UndressDom = True
		OStim.UndressSub = True
	EndIf

	If (OStim.AlwaysAnimateUndress)
		OStim.AnimateUndress = True
	EndIf

	bool didToggle = false
	If (OStim.UndressDom) ; animate undress, and chest-only strip not yet supported
		If OStim.IsInFreeCam() && (OStim.GetDomActor() == playerref)
			DidToggle = True
			OStim.ToggleFreeCam()
		EndIf
		Strip(OStim.GetDomActor())
	EndIf

	If (OStim.UndressSub)
		If OStim.IsInFreeCam() && (OStim.GetSubActor() == playerref)
			DidToggle = True
			OStim.ToggleFreeCam()
		EndIf
		Strip(OStim.GetSubActor())
	EndIf

	; Assume if sub is to be undressed, third actor should also be provided ThirdActor exists.
	Actor ThirdActor = OStim.GetThirdActor()
	If (OStim.UndressSub && ThirdActor)
		If OStim.IsInFreeCam() && (OStim.GetThirdActor() == playerref)
			DidToggle = True
			OStim.ToggleFreeCam()
		EndIf
		Strip(ThirdActor)
		ThirdActorAfterLeaving = ThirdActor
	EndIf

	If (DidToggle)
		OStim.ToggleFreeCam()
	EndIf

	Console("Stripped.")
	SendModEvent("ostim_undresscomplete")
EndEvent

Event OstimChange(String eventName, String strArg, Float numArg, Form sender)
	Bool DidToggle = False

	If (OStim.AutoUndressIfNeeded && OStim.AnimationRunning())
		Bool DomNaked = OStim.IsNaked(OStim.GetDomActor())
		Bool SubNaked = OStim.IsNaked(OStim.GetSubActor())
		Bool ThirdNaked = True

		If OStim.GetThirdActor()
			ThirdNaked = OStim.IsNaked(OStim.GetThirdActor())
		EndIf

		String CClass = OStim.GetCurrentAnimationClass()
		If (!DomNaked)
			If (CClass == "Sx") || (CClass == "Po") || (CClass == "HhPo") || (CClass == "ApPJ") || (CClass == "HhPJ") || (CClass == "HJ") || (CClass == "ApHJ") || (CClass == "DHJ") || (CClass == "SJ")|| (CClass == "An")|| (CClass == "BoJ")|| (CClass == "FJ")
				If OStim.IsInFreeCam() && (OStim.GetDomActor() == playerref)
					DidToggle = True
					OStim.ToggleFreeCam()
				EndIf
				Strip(OStim.GetDomActor())
				SendModEvent("ostim_midsceneundress_dom")
			EndIf
		EndIf
		If (!SubNaked)
			If (CClass == "Sx") || (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2") || (CClass == "An")|| (CClass == "BoJ")|| (CClass == "BoF")
				If OStim.IsInFreeCam() && (OStim.GetSubActor() == playerref)
					DidToggle = True
					OStim.ToggleFreeCam()
				EndIf
				Strip(OStim.GetSubActor())
				SendModEvent("ostim_midsceneundress_sub")
			EndIf
		EndIf
		If (!ThirdNaked)
			If (CClass == "Sx") || (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2") || (CClass == "An")|| (CClass == "BoJ")|| (CClass == "BoF")
				If OStim.IsInFreeCam() && (OStim.GetThirdActor() == playerref)
					DidToggle = True
					OStim.ToggleFreeCam()
				EndIf
				Strip(OStim.GetThirdActor())
				SendModEvent("ostim_midsceneundress_third")
			EndIf
		EndIf
	EndIf

	If (DidToggle)
		OStim.ToggleFreeCam()
	EndIf
EndEvent

Event OstimThirdJoin(String EventName, String StrArg, Float NumArg, Form Sender)
	If (OStim.AlwaysUndressAtAnimStart)
		Console("Stripping third actor")

		Bool DidToggle = False
		If (OStim.IsInFreeCam())
			DidToggle = True
			OStim.ToggleFreeCam()
		EndIf

		Strip(OStim.GetThirdActor())

		If (DidToggle)
			OStim.ToggleFreeCam()
		EndIf
	EndIf

	ThirdActorAfterLeaving = OStim.GetThirdActor()
EndEvent

Event OstimThirdLeave(String EventName, String StrArg, float NumArg, Form Sender)
	Console("Redressing third actor")
	Redress(ThirdActorAfterLeaving)
EndEvent

Form[] Set1
Form[] Set2
Form[] Set3

Actor Act1
Actor Act2
Actor Act3

Event AnimatedRedressThread(String EventName, String StrArg, float NumArg, Form Sender)
	Form[] Items
	Actor Target

	If (NumArg == 1.0)
		Items = Set1
		Target = Act1
	ElseIf (NumArg == 2.0)
		Items = Set2
		Target = Act2
	ElseIf (NumArg == 3.0)
		Items = Set3
		Target = Act3
	EndIf

	;items = PapyrusUtil.
	Bool Female = OStim.AppearsFemale(Target)

	Float StartingHealth = Target.GetAV("Health")

	Utility.Wait(Utility.RandomFloat(0.45, 0.65))

	Int i = 0
	While (i < Items.Length)
		If (Items[i])
			Bool Loaded = Target.Is3DLoaded()
			If OStim.IsActorActive(Target) || Target.IsDead() || (Target.GetAV("Health") < StartingHealth)
				Loaded = False
			EndIf

			Armor ArmorPiece = (Items[i] as Armor)
			Int SlotMask = ArmorPiece.GetSlotMask()

			String UndressAnim = ""
			Float AnimLen = 0
			Float DressPoint = 0

			If ArmorPiece.IsCuirass() || ArmorPiece.IsClothingBody()
				If (Female)
					UndressAnim = "0Eq0ER_F_ST_D_cuirass_0"
					AnimLen = 9
					DressPoint = 4.5
				Else
					UndressAnim = "0Eq0ER_M_ST_D_cuirass_0"
					AnimLen = 8
					DressPoint = 5
				EndIf
			ElseIf ArmorPiece.IsBoots() || ArmorPiece.IsClothingFeet()
				If (Female)
					UndressAnim = "0Eq0ER_F_SI_D_boots_0"
					AnimLen = 17
					DressPoint = 4.5
				Else
					UndressAnim = "0Eq0ER_M_ST_D_boots_0"
					AnimLen = 8
					DressPoint = 5
				EndIf
			ElseIf ArmorPiece.IsHelmet() || ArmorPiece.IsClothingHead()
				If (Female)
					UndressAnim = "0Eq0ER_F_ST_D_helmet_0"
					AnimLen = 12.5
					DressPoint = 9.5
				Else
					UndressAnim = "0Eq0ER_M_ST_D_helmet_0"
					AnimLen = 5
					DressPoint = 3
				EndIf
			ElseIf ArmorPiece.IsGauntlets() || ArmorPiece.IsClothingHands()
				If (Female)
					UndressAnim = "0Eq0ER_F_ST_D_gloves_0"
					AnimLen = 12
					DressPoint = 3
				Else
					UndressAnim = "0Eq0ER_M_ST_D_gloves_0"
					AnimLen = 8
					DressPoint = 6.5
				EndIf
			EndIf

			If (UndressAnim != "" && Loaded)
				Debug.SendAnimationEvent(Target, UndressAnim)
			EndIf
			If (Loaded)
				Utility.Wait(DressPoint)
			EndIf
			If (!Target.IsDead() && !OStim.IsActorActive(Target))
				Target.EquipItem(items[i], false, true)
			EndIf
			If (Loaded)
				Utility.Wait(AnimLen - DressPoint)
			EndIf
		EndIf
		i += 1
	EndWhile

	If !OStim.IsActorActive(Target)
		Debug.SendAnimationEvent(Target, "IdleForceDefaultState")
	endif

	If (NumArg == 1.0)
		Act1 = None
		Set1 = new Form[1]
	ElseIf (NumArg == 2.0)
		Act2 = None
		Set2 = new Form[1]
	ElseIf (NumArg == 3.0)
		Act3 = None
		Set3 = new Form[1]
	EndIf
EndEvent

Function FullyAnimateRedress(Actor Target, Form[] Items)
	Float Arg
	If (Act1 == None)
		Arg = 1.0
		Act1 = Target
		Set1 = Items
	Elseif (Act2 == None)
		Arg = 2.0
		Act2 = Target
		Set2 = Items
	Elseif (Act3 == None)
		Arg = 3.0
		Act3 = Target
		Set3 = Items
	endif

	SendModEvent("ostim_redressthread", numArg = Arg)
EndFunction

Function Console(String In)
	OsexIntegrationMain.Console(In)
EndFunction

Function OnGameLoad()
	RegisterForModEvent("ostim_prestart", "OStimPreStart")
	RegisterForModEvent("ostim_end", "OstimEnd")

	RegisterForModEvent("ostim_animationchanged", "OstimChange")

	RegisterForModEvent("ostim_thirdactor_join", "OstimThirdJoin")
	RegisterForModEvent("ostim_thirdactor_leave", "OstimThirdLeave")

	RegisterForModEvent("ostim_redressthread", "AnimatedRedressThread")
EndFunction
