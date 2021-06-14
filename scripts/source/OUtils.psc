ScriptName OUtils

OSexIntegrationMain Function GetOStim() Global
	quest q = game.GetFormFromFile(0x000801, "Ostim.esp") as quest
	return (q as OSexIntegrationMain)
EndFunction

function StoreNPCDataFloat(actor npc, string keys, Float num) Global
	StorageUtil.SetFloatValue(npc as form, keys, num)
	;console("Set value " + num + " for key " + keys)
EndFunction

Float function GetNPCDataFloat(actor npc, string keys) Global
	return StorageUtil.GetFloatValue(npc, keys, -1)
EndFunction

function StoreNPCDataInt(actor npc, string keys, int num) Global
	StorageUtil.SetIntValue(npc as form, keys, num)
	;console("Set value " + num + " for key " + keys)
EndFunction

Int function GetNPCDataInt(actor npc, string keys) Global
	return StorageUtil.GetIntValue(npc, keys, -1)
EndFunction

function StoreNPCDataBool(actor npc, string keys, bool value) Global
	int store 
	if value 
		store = 1
	else 
		store = 0
	endif
	StoreNPCDataInt(npc, keys, store)
	;console("Set value " + store + " for key " + keys)
EndFunction

Bool function GetNPCDataBool(actor npc, string keys) Global
	int value = GetNPCDataInt(npc, keys)
	bool ret = (value == 1)
	;console("got value " + value + " for key " + keys)
	return ret
EndFunction

Bool Function IntArrayContainsValue(Int[] Arr, Int Val) Global
	return Arr.Find(Val) != -1
EndFunction

Bool Function StringArrayContainsValue(String[] Arr, String Val) Global
	return ( PapyrusUtil.CountString(Arr, Val) > 0)
EndFunction

bool Function StringContains(string str, string contains) Global
	return (StringUtil.Find(str, contains) != -1)
EndFunction

bool Function IsModLoaded(string ESPFile) Global
	return (Game.GetModByName(ESPFile) != 255)
Endfunction