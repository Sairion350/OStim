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

Function DisplayTextBanner(String Txt) Global
	UI.InvokeString("HUD Menu", "_root.HUDMovieBaseInstance.QuestUpdateBaseInstance.ShowNotification", Txt)
EndFunction

bool Function IsChild(actor act) Global
	; Normally, we can just use act.ischild() to see if an actor is a child.
	; However, some mods unset this flag.
	; Note: OSA will automatically fail start scenes with child actors, so you don't have to use this to filter actors beforehand
	if act.IsChild()
		return true 
	endif
	Race ActorRace  = act.GetLeveledActorBase().GetRace()
	string RaceName = act.GetName() + MiscUtil.GetRaceEditorID(ActorRace)
	return StringContains(RaceName, "Child")
EndFunction

; Cached version of GetActorFromBase
; Lookups are fast (~15ms in base game), but grow as the user adds more forms. This caches the result so you only need to lookup once
Actor Function GetActorFromBaseCached(ActorBase in) Global
	form cached = StorageUtil.GetFormValue(in, "ostim_cache_actor",  missing = none)
	if cached 
		return cached as actor 
	else 
		cached = OSANative.GetActorFromBase(in) as form 
		StorageUtil.SetFormValue(in, "ostim_cache_actor",  cached)
		return cached as actor
	endif 

EndFunction

Actor[] Function BaseArrToActorArr(ActorBase[] base)
	int l = base.Length
	int i = 0

	Actor[] ret = PapyrusUtil.ActorArray(l, filler = none)
	
	while i < l
		ret[i] = GetActorFromBaseCached(base[i])

		i += 1
	endwhile

	return ret
EndFunction


;Cached natives

ActorBase Function GetLeveledActorBaseCached(actor in) Global
	form cached = StorageUtil.GetFormValue(in, "ostim_cache_actorbase",  missing = none)
	if cached 
		return cached as ActorBase 
	else 
		cached = (in.GetLeveledActorBase()) as form 
		StorageUtil.SetFormValue(in, "ostim_cache_actorbase",  cached)
		return cached as actorbase
	endif 
EndFunction

int Function GetSexCached(actorbase in) Global
	int cached = StorageUtil.GetIntValue(in, "ostim_cache_sex",  missing = -2)
	if cached != -2
		return cached
	else 
		cached = (in.GetSex())
		StorageUtil.SetIntValue(in, "ostim_cache_sex",  cached)
		return cached
	endif 
EndFunction

int Function GetFormIDCached(form in) Global
	int cached = StorageUtil.GetIntValue(in, "ostim_cache_formid",  missing = -2)
	if cached != -2
		return cached
	else 
		cached = (in.GetFormID())
		StorageUtil.SetIntValue(in, "ostim_cache_formid",  cached)
		return cached
	endif 
EndFunction


