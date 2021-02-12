ScriptName OUndressScript Extends Quest

OsexIntegrationMain OStim

ObjectReference[] property DomEquipment auto
ObjectReference[] property SubEquipment auto
ObjectReference[] property ThirdEquipment auto

Armor Property FakeArmor  Auto  
Int[] Property StrippingSlots auto


Event OnInit()
	OStim = (Self as Quest) as OsexIntegrationMain
	FakeArmor = (Game.GetFormFromFile(0x000800, "Ostim.esp")) as armor

	ongameload()
EndEvent

function strip(actor target)
	EquipFakeArmor(target)
EndFunction

function UpdateFakeArmor()
	Console("Updating fake armor....")

	int i = 28
	While i < 65
		SetSlotInFakeArmor(i, false)
		i += 1
	EndWhile

	i = 0
	int l = StrippingSlots.Length
	while i < l
		SetSlotInFakeArmor(StrippingSlots[i], true)

		i += 1
	endwhile

	console("Fake armor set.")
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


function stripandthrow(actor target, form item, bool drop = true, bool doImpulse = true)
	if item
		objectreference thing = target.dropObject(item)
		thing.SetPosition(thing.GetPositionx(), thing.GetPositionY(), thing.GetPositionZ() + 64)
		if doImpulse
			thing.applyHavokImpulse(Utility.RandomFloat(-2.0, 2.0), Utility.RandomFloat(-2.0, 2.0), Utility.RandomFloat(0.2, 1.8), Utility.RandomFloat(10, 50))
		endif
		;things[0] = thing
	endif
endfunction



Event OStimPreStart(String EventName, String strArg, Float NumArg, Form Sender)
	Console("Stripping actors...")

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
	endIf

	Console("Stripped.")
EndEvent

Function Console(String In)
	OsexIntegrationMain.Console(In)
EndFunction

Function onGameLoad()
	RegisterForModEvent("ostim_prestart", "OStimPreStart")
EndFunction