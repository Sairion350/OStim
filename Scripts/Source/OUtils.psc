ScriptName OUtils

OSexIntegrationMain Function GetOStim() Global
	quest q = game.GetFormFromFile(0x000801, "Ostim.esp") as quest
	return (q as OSexIntegrationMain)
EndFunction

Function Console(String In) Global
	MiscUtil.PrintConsole("OStim: " + In)
EndFunction

Function RegisterForOUpdate(form f) Global
	(game.GetFormFromFile(0x000D67, "Ostim.esp") as OStimUpdaterScript).AddFormToDatabase(f)
EndFunction

Function ForceOUpdate() Global
	(game.GetFormFromFile(0x000D67, "OStim.esp") as OStimUpdaterScript).DoUpdate()
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
	else 
		Race ActorRace  = GetRaceCached(GetLeveledActorBaseCached(act))
		string RaceName = GetNameCached(act) + MiscUtil.GetRaceEditorID(ActorRace)
		return StringContains(RaceName, "Child")
	endif
EndFunction 



Actor[] Function BaseArrToActorArr(ActorBase[] base) Global
	int l = base.Length
	int i = 0

	Actor[] ret = PapyrusUtil.ActorArray(l, filler = none)
	
	while i < l
		ret[i] = GetActorFromBaseCached(base[i])

		i += 1
	endwhile

	return ret
EndFunction



; Cached natives
; After running once, the value is cached. Once cached a function will return in less than 1 ms instead of a full frame.
; However, note that the cached data is stored in the skse co-save which is sensitive to bloat. Be cautious about calling these on hundreds of
; NPCs.

bool Function IsChildCached(actor act) Global
	int cached = StorageUtil.GetIntValue(act, "ostim_cache_ischild",  missing = -2)
	
	if cached != -2
		return (cached == 1)
	else 
		if ischild(act)
			cached = 1
		else 
			cached = 0
		endif 

		StorageUtil.SetIntValue(act, "ostim_cache_ischild",  cached)
		return (cached == 1)
	endif 
EndFunction

; Cached version of GetActorFromBase in OSANative
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

float Function GetWeightCached(form in) Global
	float cached = StorageUtil.GetFloatValue(in, "ostim_cache_weight",  missing = -2.0)
	if cached != -2
		return cached
	else 
		cached = (in.GetWeight())
		StorageUtil.SetFloatValue(in, "ostim_cache_weight",  cached)
		return cached
	endif 
EndFunction

String Function GetNameCached(Form in) Global
	String cached = StorageUtil.GetStringValue(in, "ostim_cache_name",  missing = "null")
	if cached != "null"
		return cached
	else 
		cached = (in.GetName())
		StorageUtil.SetStringValue(in, "ostim_cache_name",  cached)
		return cached
	endif 
EndFunction

String Function GetDisplayNameCached(ObjectReference in) Global
	String cached = StorageUtil.GetStringValue(in, "ostim_cache_displayname",  missing = "null")
	if cached != "null"
		return cached
	else 
		cached = (in.GetDisplayName())
		StorageUtil.SetStringValue(in, "ostim_cache_displayname",  cached)
		return cached
	endif 
EndFunction

Race Function GetRaceCached(actorbase in) Global
	form cached = StorageUtil.GetFormValue(in, "ostim_cache_race",  missing = none)
	if cached 
		return cached as race 
	else 
		cached = (in.GetRace()) as form 
		StorageUtil.SetFormValue(in, "ostim_cache_race",  cached)
		return cached as race
	endif 
EndFunction

VoiceType Function GetVoiceTypeCached(actorbase in) Global
	form cached = StorageUtil.GetFormValue(in, "ostim_cache_voice",  missing = none)
	if cached 
		return cached as VoiceType 
	else 
		cached = (in.GetVoiceType()) as form 
		StorageUtil.SetFormValue(in, "ostim_cache_voice",  cached)
		return cached as VoiceType
	endif 
EndFunction


