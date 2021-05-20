ScriptName OsexIntegrationMCM Extends SKI_ConfigBase

; sex settings
Int SetEndOnOrgasm
Int SetEndOnSubOrgasm
Int SetEndOnBothOrgasm
Int SetActorSpeedControl
Int SetsexExcitementMult
Int SetClipinglessFirstPerson
Int SetEndAfterActorHit
Int SetUseRumble
Int SetUseScreenShake
int SetScaling

; clothes settings
Int SetUndressIfNeed
Int SetAlwaysAnimateUndress
Int SetAlwaysUndressAtStart
Int SetonlyUndressChest
Int SetDropClothes
int SetAnimateRedress
Int SetStrongerUnequip

; bar settings
Int SetSubBar
Int SetDomBar
Int SetThirdBar
Int SetAutoHideBar
Int SetMatchColorToGender
int SetHideNPCOnNPCBars

; orgasm settings
Int SetSlowMoOrgasms
Int SetOrgasmBoostsRel

; light settings
Int SetDomLightMode
Int SetSubLightMode
Int SetSubLightBrightness
Int SetDomLightBrightness
Int SetOnlyLightInDark

Int SetResetState
Int SetRebuildDatabase

; keymapping settings
Int SetKeymap
Int SetKeyUp
Int SetKeyDown
Int SetPullOut

Int SetThanks

; light settings
String[] DomLightModeList
String[] SubLightModeList

String[] SubLightBrightList
String[] DomLightBrightList

; bed settings
Int SetEnableBeds
Int SetBedSearchDistance
Int SetBedReallignment
int SetBedAlgo

; ai control settings
Int SetAIControl
Int SetControlToggle
Int SetAIChangeChance

Int SetForceAIIfAttacking
Int SetForceAIIfAttacked
Int SetForceAIInConsensualScenes

; misc settings afaik
Int SetCustomTimescale

Int SetMisallignmentOption
Int SetFlipFix

Int SetUseFades
Int SetUseAutoFades

Int SetMute

; camera settings
Int SetUseFreeCam
Int SetFreeCamFOV
Int SetDefaultFOV
Int SetCameraSpeed
Int SetForceFirstPerson

Int SetUseCosaveWorkaround

; mcm save/load settings
Int ExportSettings
Int ImportSettings

int SetUpdate

OsexIntegrationMain Main


string currPage
int[] SlotSets

actor playerref

int SetUndressingAbout

;ORomance 
int SetORDifficulty
int SetORSexuality
int SetORKey
int SetORColorblind
int SetORStationary
int SetORLeft
int SetORRight
int SetORNakadashi

string ORomance = "ORomance.esp"
int GVORDifficulty = 0x0063A4
int GVORSexuality = 0x0063A5
int GVORKey = 0x006E6A
int GVORLeft = 0x73D2
int GVORRight = 0x73D3
int GVORColorblind = 0x73D0
int GVORStationaryMode = 0x73D1
int GVORNakadashi = 0x73D4

string ONights = "ONights.esp"
int GVONFreqMult = 0x000D65
int GVONStopWhenFound = 0x000D64

int SetONStopWhenFound
int SetONFreqMult

Event OnInit()
	Init()
EndEvent

Function Init()
	Parent.OnGameReload()
	Main = (Self as Quest) as OsexIntegrationMain

	DomLightModeList = new String[3]
	DomLightModeList[0] = "No light"
	DomLightModeList[1] = "Rear light"
	DomLightModeList[2] = "Face light"

	SubLightModeList = new String[3]
	SubLightModeList[0] = "No light"
	SubLightModeList[1] = "Rear light"
	SubLightModeList[2] = "Face light"

	SubLightBrightList = new String[2]
	SubLightBrightList[0] = "Dim"
	SubLightBrightList[1] = "Bright"

	DomLightBrightList = new String[2]
	DomLightBrightList[0] = "Dim"
	DomLightBrightList[1] = "Bright"

	playerref = game.getplayer()
EndFunction

Event OnPageReset(String Page)
	{Called when a new page is selected, including the initial empty page}
	currPage = page

	If (Page == "Configuration")
		If (!Main)
			Init()
			If (!Main.EndOnDomOrgasm)
				Main.Startup()
			EndIf
			Debug.MessageBox("Anomaly detected in install, please reinstall OStim if it does not start properly")
		EndIf

		UnloadCustomContent()
		SetInfoText(" ")
		Main.playTickBig()
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetThanks = AddTextOption("Thanks!", "")
		SetCursorPosition(1)
		AddTextOption("<font color='" + "#939292" +"'>" + "OStim Settings", "")
		SetCursorPosition(2)

		;=============================================================================================

		AddColoredHeader("Sex scenes")
		SetEndOnOrgasm = AddToggleOption("End sex after Dom actor orgasm", Main.EndOnDomOrgasm)
		SetEndOnSubOrgasm = AddToggleOption("End sex after Sub actor orgasm", Main.EndOnSubOrgasm)
		SetEndOnBothOrgasm = AddToggleOption("Require both actors to orgasm to end", Main.RequireBothOrgasmsToFinish)
		SetActorSpeedControl = AddToggleOption("Actors control speed", Main.EnableActorSpeedControl)
		SetsexExcitementMult = AddSliderOption("Excitement multiplier", Main.SexExcitementMult, "{2} x")
		SetClipinglessFirstPerson = AddToggleOption("Clipping-less first person", Main.EnableImprovedCamSupport)
		SetCustomTimescale = AddSliderOption("Custom timescale", Main.CustomTimescale, "{0}")
		SetMisallignmentOption = AddToggleOption("Enable misalignment protection", Main.MisallignmentProtection)
		SetFlipFix = AddToggleOption("Enable flipped animation fix", Main.FixFlippedAnimations)
		SetUseFades = AddToggleOption("Fade out on intro/outro", Main.UseFades)
		SetEndAfterActorHit = AddToggleOption("End if attacked", Main.EndAfterActorHit)
		SetUseRumble = AddToggleOption("Use controller rumble", Main.UseRumble)
		SetUseScreenShake = AddToggleOption("Use extra screenshake", Main.UseScreenShake)
		SetForceFirstPerson = AddToggleOption("Force return to first person after scene", Main.ForceFirstPersonAfter)
		SetScaling = AddToggleOption("Disable scaling", Main.DisableScaling)
		AddEmptyOption()

		AddColoredHeader("Beds")
		SetEnableBeds = AddToggleOption("Use beds", Main.UseBed)
		SetBedSearchDistance = AddSliderOption("Bed search radius", Main.BedSearchDistance, "{0} meters")
		SetBedReallignment = AddSliderOption("Bed reallignment", Main.BedReallignment, "{0} units")
		SetBedAlgo = AddToggleOption("Use alternate bed search method", Main.UseAlternateBedSearch)
		AddEmptyOption()

		AddColoredHeader("Excitement bars")
		SetDomBar = AddToggleOption("Main actor HUD bar", Main.EnableDomBar)
		SetSubBar = AddToggleOption("Second actor HUD bar", Main.EnableSubBar)
		SetThirdBar = AddToggleOption("Third actor HUD bar", Main.EnableThirdBar)
		SetAutoHideBar = AddToggleOption("Autohide bars", Main.AutoHideBars)
		SetMatchColorToGender = AddToggleOption("Match color to gender", Main.MatchBarColorToGender)
		SetHideNPCOnNPCBars = AddToggleOption("Hide bars in NPC-only scenes", Main.HideBarsInNPCScenes)
		AddEmptyOption()

		AddColoredHeader("System")
		SetResetState = AddTextOption("Reset thread state", "")
		SetRebuildDatabase = AddTextOption("Rebuild animation database", "")
		;SetUpdate = AddTextOption("Update OStim", "")
		SetMute = AddToggleOption("Mute vanilla OSA sounds", Main.MuteOSA)
		;SetUseCosaveWorkaround = AddToggleOption("Fix keys & auto-mode", Main.useBrokenCosaveWorkaround)
		AddEmptyOption()

		;=============================================================================================

		SetCursorPosition(3)
		AddColoredHeader("Undressing")
		SetAlwaysUndressAtStart = AddToggleOption("Fully undress at start", Main.AlwaysUndressAtAnimStart)
		SetUndressIfneed = AddToggleOption("Remove clothes mid-scene", Main.AutoUndressIfNeeded)
		SetDropClothes = AddToggleOption("Toss clothes onto ground", Main.TossClothesOntoGround)
		;SetStrongerUnequip = AddToggleOption("Use stronger unequip method", Main.UseStrongerUnequipMethod) Likely redundant 
		SetAnimateRedress= AddToggleOption("Use animated redress", Main.FullyAnimateRedress)
		;SetAlwaysAnimateUndress = AddToggleOption("Use undress animation", Main.AlwaysAnimateUndress) Removed in 4.0, may be reimplemented but it was bugged
		;SetonlyUndressChest = AddToggleOption("Only undress chest piece", Main.OnlyUndressChest) REMOVED in 4.0
		AddEmptyOption()

		AddColoredHeader("AI Control")
		SetAIControl = AddToggleOption("Enable full-auto control", Main.UseAIControl)
		SetForceAIIfAttacking = AddToggleOption("Force full-auto control if player attacking", Main.UseAIPlayerAggressor)
		SetForceAIIfAttacked = AddToggleOption("Force full-auto control if player is attacked", Main.UseAIPlayerAggressed)
		SetForceAIInConsensualScenes = AddToggleOption("Force full-auto control in consensual scenes", Main.UseAINonAggressive)
		SetUseAutoFades = AddToggleOption("Fade out in between animation transitions", Main.UseAutoFades)
		SetAIChangeChance = AddSliderOption("AI Animation Change Chance", Main.AiSwitchChance, "{0}")
		AddEmptyOption()

		AddColoredHeader("FreeCam")
		SetUseFreeCam = AddToggleOption("Switch to freecam mode on start", Main.UseFreeCam)
		SetFreeCamFOV = AddSliderOption("Freecam FOV", Main.FreecamFOV, "{0}")
		SetDefaultFOV = AddSliderOption("Default FOV", Main.DefaultFOV, "{0}")
		SetCameraSpeed = AddSliderOption("Camera speed", Main.FreecamSpeed, "{0}")
		AddEmptyOption()

		AddColoredHeader("Keys")
		SetKeymap = AddKeyMapOption("Start sex with target", Main.KeyMap)
		SetKeyup = AddKeyMapOption("Increase speed", Main.SpeedUpKey)
		SetKeydown = AddKeyMapOption("Decrease speed", Main.SpeedDownKey)
		SetPullOut = AddKeyMapOption("Pull out", Main.PullOutKey)
		SetControlToggle = AddKeyMapOption("Switch control mode", Main.ControlToggleKey)
		AddEmptyOption()

		AddColoredHeader("Lights")
		SetDomLightMode = AddMenuOption("Main actor light mode", DomLightModeList[Main.DomLightPos])
		SetSubLightMode = AddMenuOption("Second actor light mode", SubLightModeList[Main.SubLightPos])
		SetDomLightBrightness = AddMenuOption("Main actor light brightness", DomLightBrightList[Main.DomLightBrightness])
		SetSubLightBrightness = AddMenuOption("Second actor light brightness", SubLightBrightList[Main.SubLightBrightness])
		SetOnlyLightInDark = AddToggleOption("Only use lights in darkness", Main.LowLightLevelLightsOnly)
		AddEmptyOption()

		AddColoredHeader("Save and load settings.")
		ExportSettings = AddTextOption("Export Settings", "Done")
		ImportSettings = AddTextOption("Import Settings", "Done")
	ElseIf (Page == "")
		LoadCustomContent("Ostim/logo.dds", 184, 31)
		Main.PlayDing()
	ElseIf (Page == "Add-ons")
		SetInfoText(" ")
		Main.playTickBig()
		SetCursorFillMode(TOP_TO_BOTTOM)
		UnloadCustomContent()
		SetThanks = AddTextOption("", "")
		SetCursorPosition(1)
		AddTextOption("<font color='" + "#939292" +"'>" + "Add-on Settings", "")
		SetCursorPosition(2)

		if main.IsModLoaded(ORomance)
			AddColoredHeader("ORomance")
			SetORSexuality = AddToggleOption("Enable NPC sexualities", GetExternalBool(ORomance, GVORSexuality))
			SetORDifficulty = AddSliderOption("Difficulty modifier", GetExternalInt(ORomance, GVORDifficulty), "{0}")
			SetORKey = AddKeyMapOption("Start dialogue", GetExternalInt(oromance, gvorkey))
			SetORColorblind = AddToggleOption("Enable colorless success indicator", GetExternalBool(ORomance, GVORColorblind))
			;SetORStationary = AddToggleOption("Enable gamepad control ", GetExternalBool(ORomance, GVORStationaryMode))
			SetORLeft = AddKeyMapOption("Left Key", GetExternalInt(oromance, GVORLeft))
			SetORRight = AddKeyMapOption("Right Key", GetExternalInt(oromance, GVORRight))
			SetORNakadashi = AddToggleOption("NPCs are not cautious about vaginal ejaculation", GetExternalBool(ORomance, GVORNakadashi))
		endif 

		if main.IsModLoaded(ONights)
			AddColoredHeader("ONights")
			SetONStopWhenFound = AddToggleOption("NPCs stop sex when spotted", GetExternalBool(ONights, GVONStopWhenFound))
			SetONFreqMult = AddSliderOption("Sex frequency Mult", GetExternalFloat(ONights, GVONFreqMult), "{2} x")
			
		endif 

	ElseIf (Page == "Undressing")
		LoadCustomContent("Ostim/logo.dds", 184, 31)
		Main.PlayTickBig()
		UnloadCustomContent()
		SetInfoText(" ")
		Main.playTickBig()
		SetCursorFillMode(LEFT_TO_RIGHT)
		SetUndressingAbout = AddTextOption("What is this?", "")
		SetCursorPosition(1)
		AddTextOption("<font color='" + "#939292" +"'>" + "OStim Undressing", "")
		SetCursorPosition(2)
		AddColoredHeader("Undressing slots")
		AddColoredHeader("")

		DrawSlotPage()
	ElseIf (Page == "About")
		UnloadCustomContent()
		Main.PlayTickBig()
		SetCursorFillMode(TOP_TO_BOTTOM)
		LoadCustomContent("Ostim/info.dds")
	EndIf
EndEvent

bool Function GetExternalBool(string modesp, int id)
	;osexintegrationmain.console((game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt())

	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt() == 1

endfunction

Function SetExternalBool(string modesp, int id, bool val)
	int set = 0
	if val
		set = 1
	endif 

	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValueInt(set)
endfunction

Function SetExternalInt(string modesp, int id, int val)
	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValueInt(val)
endfunction
int Function GetExternalInt(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt() 
endfunction

Function SetExternalfloat(string modesp, int id, float val)
	(game.GetFormFromFile(id, modesp) as GlobalVariable).SetValue(val)
endfunction
float Function GetExternalfloat(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValue() 
endfunction

Event OnOptionSelect(Int Option)
	Main.PlayTickBig()
	if currPage == "Undressing"
		OnSlotSelect(option)
	elseif currPage == "Add-ons"
		if option == SetORSexuality
			SetExternalBool(oromance, GVORSexuality, !GetExternalBool(oromance, GVORSexuality))
			SetToggleOptionValue(SetORSexuality, GetExternalBool(oromance, GVORSexuality))
		elseif option == SetORColorblind
			SetExternalBool(oromance, GVORColorblind, !GetExternalBool(oromance, GVORColorblind))
			SetToggleOptionValue(SetORColorblind, GetExternalBool(oromance, GVORColorblind))
		elseif option == SetORNakadashi
			SetExternalBool(oromance, GVORNakadashi, !GetExternalBool(oromance, GVORNakadashi))
			SetToggleOptionValue(SetORNakadashi, GetExternalBool(oromance, GVORNakadashi))
		elseif option == SetORStationary
			SetExternalBool(oromance, GVORStationaryMode, !GetExternalBool(oromance, GVORStationaryMode))
			SetToggleOptionValue(SetORStationary, GetExternalBool(oromance, GVORStationaryMode))
		elseif option == SetONStopWhenFound
			SetExternalBool(ONights, GVONStopWhenFound, !GetExternalBool(ONights, GVONStopWhenFound))
			SetToggleOptionValue(SetONStopWhenFound, GetExternalBool(ONights, GVONStopWhenFound))
		endif

		return
	EndIf

	If (Option == SetEndOnOrgasm)
		Main.EndOnDomOrgasm = !Main.EndOnDomOrgasm
		SetToggleOptionValue(SetEndOnOrgasm, Main.EndOnDomOrgasm)
	ElseIf (Option == SetEndOnSubOrgasm)
		Main.EndOnSubOrgasm = !Main.EndOnSubOrgasm
		SetToggleOptionValue(SetEndOnSubOrgasm, Main.EndOnSubOrgasm)
	ElseIf (Option == SetEndOnBothOrgasm)
		Main.RequireBothOrgasmsToFinish = !Main.RequireBothOrgasmsToFinish
		SetToggleOptionValue(SetEndOnBothOrgasm, Main.RequireBothOrgasmsToFinish)
	ElseIf (Option == SetResetState)
		Main.ResetState()
	ElseIf (Option == SetUpdate)
		Debug.MessageBox("Close all menus now")
		OStimUpdaterScript oupdater = Game.GetFormFromFile(0x000D67, "Ostim.esp") as OStimUpdaterScript
		oupdater.DoUpdate()
	ElseIf (Option == SetRebuildDatabase)
		Debug.MessageBox("Close all menus and watch the console until it is done")
		Main.GetODatabase().InitDatabase()
	ElseIf (Option == SetActorSpeedControl)
		Main.EnableActorSpeedControl = !Main.EnableActorSpeedControl
		SetToggleOptionValue(Option, Main.EnableActorSpeedControl)
	ElseIf (Option == SetEnableBeds)
		Main.UseBed = !Main.UseBed
		SetToggleOptionValue(Option, Main.UseBed)
	ElseIf (Option == SetScaling)
		Main.DisableScaling = !Main.DisableScaling
		SetToggleOptionValue(Option, Main.DisableScaling)
	ElseIf (Option == SetUseRumble)
		Main.UseRumble = !Main.UseRumble
		SetToggleOptionValue(Option, Main.UseRumble)
	ElseIf (Option == SetStrongerUnequip)
		Main.UseStrongerUnequipMethod = !Main.UseStrongerUnequipMethod
		SetToggleOptionValue(Option, Main.UseStrongerUnequipMethod)
	ElseIf (Option == SetFlipFix)
		Main.FixFlippedAnimations = !Main.FixFlippedAnimations
		SetToggleOptionValue(Option, Main.FixFlippedAnimations)
	ElseIf (Option == SetUseScreenShake)
		Main.UseScreenShake = !Main.UseScreenShake
		SetToggleOptionValue(Option, Main.UseScreenShake)
	ElseIf (Option == SetForceAIInConsensualScenes)
		Main.UseAINonAggressive = !Main.UseAINonAggressive
		SetToggleOptionValue(Option, Main.UseAINonAggressive)
	ElseIf (Option == SetDropClothes)
		Main.TossClothesOntoGround = !Main.TossClothesOntoGround
		SetToggleOptionValue(Option, Main.TossClothesOntoGround)
	ElseIf (Option == SetForceAIIfAttacked)
		Main.UseAIPlayerAggressed = !Main.UseAIPlayerAggressed
		SetToggleOptionValue(Option, Main.UseAIPlayerAggressed)
	ElseIf (Option == SetForceFirstPerson)
		Main.ForceFirstPersonAfter = !Main.ForceFirstPersonAfter
		SetToggleOptionValue(Option, Main.ForceFirstPersonAfter)
	ElseIf (Option == SetUseAutoFades)
		Main.UseAutoFades = !Main.UseAutoFades
		SetToggleOptionValue(Option, Main.UseAutoFades)
	ElseIf (Option == SetMatchColorToGender)
		Main.MatchBarColorToGender = !Main.MatchBarColorToGender
		SetToggleOptionValue(Option, Main.MatchBarColorToGender)
	ElseIf (Option == SetHideNPCOnNPCBars)
		Main.HideBarsInNPCScenes = !Main.HideBarsInNPCScenes
		SetToggleOptionValue(Option, Main.HideBarsInNPCScenes)
	ElseIf (Option == SetMute)
		Main.MuteOSA = !Main.MuteOSA
		SetToggleOptionValue(Option, Main.MuteOSA)
	ElseIf (Option == SetEndAfterActorHit)
		Main.EndAfterActorHit = !Main.EndAfterActorHit
		SetToggleOptionValue(Option, Main.EndAfterActorHit)
	ElseIf (Option == SetUseFreeCam)
		Main.UseFreeCam = !Main.UseFreeCam
		SetToggleOptionValue(Option, Main.UseFreeCam)
	ElseIf (Option == SetUseCosaveWorkaround)
		Main.UseBrokenCosaveWorkaround = !Main.UseBrokenCosaveWorkaround
		SetToggleOptionValue(Option, Main.UseBrokenCosaveWorkaround)
	ElseIf (Option == SetForceAIIfAttacking)
		Main.UseAIPlayerAggressor = !Main.UseAIPlayerAggressor
		SetToggleOptionValue(Option, Main.UseAIPlayerAggressor)
	ElseIf (Option == SetUndressIfneed)
		Main.AutoUndressIfNeeded = !Main.AutoUndressIfNeeded
		SetToggleOptionValue(Option, Main.AutoUndressIfNeeded)
	ElseIf (Option == SetBedAlgo)
		Main.UseAlternateBedSearch = !Main.UseAlternateBedSearch
		SetToggleOptionValue(Option, Main.UseAlternateBedSearch)
	ElseIf (Option == SetClipinglessFirstPerson)
		Main.EnableImprovedCamSupport = !Main.EnableImprovedCamSupport
		SetToggleOptionValue(Option, Main.EnableImprovedCamSupport)
	ElseIf (Option == SetAlwaysUndressAtStart)
		Main.AlwaysUndressAtAnimStart = !Main.AlwaysUndressAtAnimStart
		SetToggleOptionValue(Option, Main.AlwaysUndressAtAnimStart)
	ElseIf (Option == SetAIControl)
		Main.UseAIControl = !Main.UseAIControl
		SetToggleOptionValue(Option, Main.UseAIControl)
	ElseIf (Option == SetAlwaysAnimateUndress)
		Main.AlwaysAnimateUndress = !Main.AlwaysAnimateUndress
		SetToggleOptionValue(Option, Main.AlwaysAnimateUndress)
	;ElseIf (Option == SetonlyUndressChest)
	;	Main.OnlyUndressChest = !Main.OnlyUndressChest
	;	SetToggleOptionValue(Option, Main.OnlyUndressChest)
	ElseIf (Option == SetDomBar)
		Main.EnableDomBar = !Main.EnableDomBar
		SetToggleOptionValue(Option, Main.EnableDomBar)
	ElseIf (Option == SetThirdBar)
		Main.EnableThirdBar = !Main.EnableThirdBar
		SetToggleOptionValue(Option, Main.EnableThirdBar)
	ElseIf (Option == SetAnimateRedress)
		Main.FullyAnimateRedress = !Main.FullyAnimateRedress
		SetToggleOptionValue(Option, Main.FullyAnimateRedress)
	ElseIf (Option == SetMisallignmentOption)
		Main.MisallignmentProtection = !Main.MisallignmentProtection
		SetToggleOptionValue(Option, Main.MisallignmentProtection)
	ElseIf (Option == SetSubBar)
		Main.EnableSubBar = !Main.EnableSubBar
		SetToggleOptionValue(Option, Main.EnableSubBar)
	ElseIf (Option == SetAutoHideBar)
		Main.AutoHideBars = !Main.AutoHideBars
		SetToggleOptionValue(Option, Main.AutoHideBars)
	ElseIf (Option == SetSlowMoOrgasms)
		Main.SlowMoOnOrgasm = !Main.SlowMoOnOrgasm
		SetToggleOptionValue(Option, Main.SlowMoOnOrgasm)
	ElseIf (Option == SetOrgasmBoostsRel)
		Main.OrgasmIncreasesRelationship = !Main.OrgasmIncreasesRelationship
		SetToggleOptionValue(Option, Main.OrgasmIncreasesRelationship)
	ElseIf (Option == SetUseFades)
		Main.UseFades = !Main.UseFades
		SetToggleOptionValue(Option, Main.UseFades)
	ElseIf (Option == SetOnlyLightInDark)
		Main.LowLightLevelLightsOnly = !Main.LowLightLevelLightsOnly
		SetToggleOptionValue(Option, Main.LowLightLevelLightsOnly)
	ElseIf (Option == ExportSettings)
		ExportSettings()
		; will probably need to do a popup or something here to cover the delay.
	ElseIf (Option == ImportSettings)
		ImportSettings()
		; will probably need to do a popup or something here to cover the delay.
	EndIf
EndEvent

Event OnOptionHighlight(Int Option)
	;Main.playTickSmall()
	if currPage == "Undressing"
		OnSlotMouseOver(option)
	elseif currPage == "Add-ons"
		If (Option == SetORKey)
			SetInfoText("Press this while looking at an NPC to start interacting\nYou must save and reload for this setting to take affect")
		elseif (option == SetORDifficulty)
			SetInfoText("Increasing this value makes actions easier. Lowering makes them harder. Lowering is not advised usually")
		elseif (option == SetORSexuality)
			SetInfoText("Leaving this off makes all NPCs bisexual. \nTurning it on allows them to be gay/bisexual/hetero")
		elseif (option == SetORColorblind)
			SetInfoText("Makes the success indicator use text instead of color")
		elseif (option == SetORLeft)
			SetInfoText("Left selection key\nSave and reload to take effect")
		elseif (option == SetORRight)
			SetInfoText("Right selection key\nSave and reload to take effect")
		elseif (option == SetORNakadashi)
			SetInfoText("Female NPCs are not cautious about you ejaculating inside them before a relationship and sometimes marriage\nMostly for users with no pregnancy mod")
		ElseIf (Option == SetONFreqMult)
			SetInfoText("The frequency at which NPCs will try to have sex with each other")
		Elseif (Option == SetONStopWhenFound)
			SetInfoText("If checked, NPCs will stop having sex if they know the player can see them")
		endif 

		return
	EndIf
	If (Option == SetEndOnOrgasm)
		SetInfoText("End the Osex scene automatically when the dominant actor (usually the male) orgasms")
	ElseIf (Option == SetEndOnSubOrgasm)
		SetInfoText("End the Osex scene automatically when the submissive actor (usually the female) orgasms")
	ElseIf (Option == SetEndOnBothOrgasm)
		SetInfoText("Will prevent the above 2 settings from ending the scene if both actors have not had an orgasm at least once")
	ElseIf (Option == SetResetState)
		SetInfoText("Click this if you keep getting a Scene Already Running type error")
	ElseIf (Option == SetUndressingAbout)
		SetInfoText("This panel lets you select what armor slots are stripped by OStim. See this if you don't know what that is\nhttps://www.creationkit.com/index.php?title=Biped_Object\nThese slots will apply to both the player AND NPCs\nSlots where the name is green mean that Bethesda designated that slot to be used that way\nCyan names mean that the community has designated that slot to be used that way\nMany mods do not use the proper slots, so take the names with a grain of salt\nMouse over the names to see if you are wearing an armor piece in that slot")
	ElseIf (Option == SetForceAIIfAttacked)
		SetInfoText("If using manual mode by default, this will force automatic mode to activate if the player is the victim in an aggressive scene")
	ElseIf (Option == SetForceAIIfAttacking)
		SetInfoText("If using manual mode by default, this will force automatic mode to activate if the player is the attacker in an aggressive scene")
	ElseIf (Option == SetForceAIInConsensualScenes)
		SetInfoText("If using manual mode by default, this will force automatic mode to activate in consensual scenes")
	ElseIf (Option == SetUseFades)
		SetInfoText("Fade the screen to black when a scene starts/ends")
	ElseIf (Option == SetScaling)
		SetInfoText("Disable changing actor height to fit animations better when scene starts\nDisabling scaling will absolutely wreck animation alignment, turning it off is not recommended\nHowever, turning it off may help fix issues with HDT-SMP")
	ElseIf (Option == SetUseCosaveWorkaround)
		SetInfoText("Some users appear to have a broken SKSE co-save setup\n This manifests itself as full-auto mode not working, and keys not saving\nThis will fix the symptoms of the issue if you have it, but not the core cause")
	ElseIf (Option == SetFreeCamFOV)
		SetInfoText("The field of view of the camera when in freecam mode\nThis is incompatible with Improved Camera")
	ElseIf (Option == SetUseRumble)
		SetInfoText("Rumble a controller on thrust, if a controller is being used")
	ElseIf (Option == SetMatchColorToGender)
		SetInfoText("Change the color of the bars to match the gender of the character")
	ElseIf (Option == SetHideNPCOnNPCBars)
		SetInfoText("Do not show exitement bars if the player is not in a scene")
	ElseIf (Option == SetStrongerUnequip)
		SetInfoText("Use an alternate unequip method that may catch more armor pieces, especially armor with auto-reequip scripts\nHowever, some armor it unequips may not be reequiped in redress\nHas no effect if drop clothes on to ground is enabled")
	ElseIf (Option == SetEndAfterActorHit)
		SetInfoText("End the scene after someone in the scene is hit\n Can misfire with certain other mods")
	ElseIf (Option == SetAnimateRedress)
		SetInfoText("Makes NPCs play redressing animations after a scene ends if they need to redress")
	ElseIf (Option == SetForceFirstPerson)
		SetInfoText("Return to first person after scene ends.\nFixes the hybrid-camera bug in Improved Camera")
	ElseIf (Option == SetCustomTimescale)
		SetInfoText("Changes the timescale during sex scenes, and reverts it back to what it was after the scene ends\nUseful if you don't want sex taking an entire day\n0 = this feature is disabled")
	ElseIf (Option == SetClipinglessFirstPerson)
		 SetInfoText("REQUIRES: Improved Camera, my custom ini settings file\nExperience first person without any clipping")
	ElseIf (Option == SetActorSpeedControl)
		SetInfoText("Let actors increase the scene speed on their own when their Excitement gets high enough \nThis feature is experimental, disable if Osex behaves strangely on it's own")
	ElseIf (Option == SetUndressIfNeed)
		SetInfoText("If actors' genitals are covered by clothes, this will auto-remove the clothes as soon as they need access to their genitals")
	ElseIf (Option == SetBedSearchDistance)
		SetInfoText("High values may increase animation start time")
	ElseIf (Option == SetBedAlgo)
		SetInfoText("Use a slower papyrus bed search method rather than a faster native one\n May find more beds but only enable if a bed is not detected")
	ElseIf (Option == SetUseAutoFades)
		SetInfoText("Fade to black in between animation transitions")
	ElseIf (Option == SetAIChangeChance)
		SetInfoText("Chance that characters will switch animations mid scene\nDoes not affect chance of a foreplay -> full sex transition")
	ElseIf (Option == SetFlipFix)
		SetInfoText("Fix some third party animations being flipped 180 degrees")
	ElseIf (Option == SetDropClothes)
		SetInfoText("Characters will drop clothes they take off onto the ground instead of storing them in their inventory\nCharacters will automatically pick them up when redressing")
	ElseIf (Option == SetAlwaysUndressAtStart)
		SetInfoText("Actors will always get undressed as a scene starts \nMods using this mod's API can force an undress to occur even if this isn't checked")
	ElseIf (Option == SetAlwaysAnimateUndress)
		SetInfoText("Always play Osex's undressing animations instead of just removing the clothes normally\nNote: that Auto-Remove clothes will never use Osex's undress animation\nFurther note: Mods using this mod's API can force an animation to occur even if this isn't checked")
	ElseIf (Option == SetonlyUndressChest)
		SetInfoText("Only remove the chest piece during undressing\nNote: due to bugginess with Osex, if using Undress Animation, only the chest piece is currently removed even with this not checked")
	ElseIf (Option == SetDomBar)
		SetInfoText("Enable the on-screen bar that tracks the dominant actor's Excitement\nActor's orgasm when their Excitement maxes out")
	ElseIf (Option == SetthirdBar)
				SetInfoText("Enable the on-screen bar that tracks the third actor's Excitement\nActor's orgasm when their Excitement maxes out")
	ElseIf (Option == SetSubBar)
		SetInfoText("Enable the on-screen bar that tracks the second actor's Excitement\nActor's orgasm when their Excitement maxes out")
	ElseIf (Option == SetMisallignmentOption)
		SetInfoText("Enable automatic misalignment detection\nYou may want to disable this if you want to do some custom realigning.\nWarning: can cause characters to glitch on some setups, beware enabling this")
	ElseIf (Option == SetEnableBeds)
		SetInfoText("Actors will find the nearest bed to have sex on")
	ElseIf (Option == setupdate)
		SetInfoText("Try to flush out old scripts.\nMay not be reliable, perform a clean install if you get weird behavior after updating")
	ElseIf (Option == SetAIControl)
		SetInfoText("If enabled, scenes will play out on their own without user input via procedural generation\nNote: If you have only used Manual mode briefly or not at all, and never became adept with using it, I STRONGLY recommend you give manual mode a fair chance before using this")
	ElseIf (Option == SetAutoHideBar)
		SetInfoText("Automatically hide the bars during sex when not interacting with the UI")
	ElseIf (Option == SetSlowMoOrgasms)
		SetInfoText("Add in a few seconds of slowmotion right when the player orgasms")
	ElseIf (Option == SetOrgasmBoostsRel)
		SetInfoText("Giving orgasms to actors you have a relationship rank of 0 with will increase them to rank 1, marking them as a friend\nThis may open up unique options in some mods")
	ElseIf (Option == SetDomLightMode)
		SetInfoText("Enable light on main actor at animation start")
	ElseIf (Option == SetMute)
		SetInfoText("Mute sounds coming from the OSA engine\nYou should probably only disable this if you have a soundpack installed")
	ElseIf (Option == SetSubLightMode)
		SetInfoText("Enable light on second actor at animation start")
	ElseIf (Option == SetCameraSpeed)
		SetInfoText("The speed of the freecam")
	ElseIf (Option == SetUseFreeCam)
		SetInfoText("Automatically switch to freecam when a scene starts")
	ElseIf (Option == SetDefaultFOV)
		SetInfoText("The field of view to return to when a scene ends when using free cam")
	ElseIf (Option == SetDomLightBrightness)
		SetInfoText("Set main actor's light's brightness")
	ElseIf (Option == SetSubLightBrightness)
		SetInfoText("Set second actor's light's brightness")
	ElseIf (Option == SetControlToggle)
		SetInfoText("Press during an animation: switch between manual and full-auto control for the duration of that animation \n Press outside of animation: switch between manual and full-auto control permanently")
	ElseIf (Option == SetOnlyLightInDark)
		SetInfoText("Only use actor lights when the scene takes place in a dark area")
	ElseIf (Option == SetRebuildDatabase)
		SetInfoText("This will rebuild OStim's internal animation database.\n You only need to click this if you have installed or uninstalled an animation pack MID-playthrough\n The animation database is automatically built at the start of a new playthrough")
	ElseIf (Option == SetsexExcitementMult)
		SetInfoText("Multiply all the pleasure/second received by actors by this amount\nThis effectively lets you choose how long you want sex to last\n3.0 = 3 times shorter, 0.1 = 10 times longer")
	ElseIf (Option == SetKeymap)
		SetInfoText("Press this while looking at an actor to start OStim.\nStarting OSex through OSA will result in normal OSex instead\nOStim is intended to be played with mods that integrate it into the game instead of using this option")
	ElseIf (Option == SetKeyUp)
		SetInfoText("Increase speed during OStim scene\nThe default key (numpad +) conflicts with many mods, may need to remap")
	ElseIf (Option == SetKeyDown)
		SetInfoText("Decrease speed during OStim scene\nThe default key (numpad -) conflicts with many mods, may need to remap")
	ElseIf (Option == SetUseScreenShake)
		SetInfoText("Use extra screenshake on thrust\n This is not compatible with Improved Camera's first person")
	ElseIf (Option == SetBedReallignment)
		SetInfoText("Move actors forward/back by this amount on a bed")
	ElseIf (Option == SetPullOut)
		SetInfoText("Only usable in manual mode\nWhen pressed during a sexual animation, causes your character to immediately cancel and \"pull out\" of the current animation")
	ElseIf (Option == SetThanks)
		SetInfoText("Thank you for downloading OStim\nLeave a comment and also share it with others online if you enjoy it, to help others find it")
	ElseIf (Option == ExportSettings)
		SetInfoText("Click this button to export the Ostim MCM settings.")
	ElseIf (Option == ImportSettings)
		SetInfoText("Click this button to import the Ostim MCM settings.")

	EndIf
EndEvent

Event OnOptionMenuOpen(Int Option)
	Main.PlayTickBig()
	If (Option == SetDomLightmode)
		SetMenuDialogOptions(DomLightModeList)
		;SetMenuDialogStartIndex(DifficultyIndex)
		;SetMenuDialogDefaultIndex(1)
	ElseIf (Option == SetSubLightMode)
		SetMenuDialogOptions(SubLightModeList)
	ElseIf (Option == SetDomLightBrightness)
		SetMenuDialogOptions(DomLightBrightList)
	ElseIf (Option == SetSubLightBrightness)
		SetMenuDialogOptions(SubLightBrightList)
	EndIf
EndEvent

Event OnOptionMenuAccept(Int Option, Int Index)
	Main.PlayTickBig()
	If (Option == SetDomLightMode)
		Main.DomLightPos = Index
		SetMenuOptionValue(SetDomLightMode, DomLightModeList[Index])
	ElseIf (Option == SetSubLightMode)
		Main.SubLightPos = Index
		SetMenuOptionValue(Option, SubLightModeList[Index])
	ElseIf (Option == SetDomLightBrightness)
		Main.DomLightBrightness = Index
		SetMenuOptionValue(Option, DomLightBrightList[Index])
	ElseIf (Option == SetSubLightBrightness)
		Main.SubLightBrightness = Index
		SetMenuOptionValue(Option, SubLightBrightList[Index])
	EndIf
EndEvent

Event OnOptionSliderOpen(Int Option)
	Main.PlayTickBig()
	If (Option == SetSexExcitementMult)
		SetSliderDialogStartValue(Main.SexExcitementMult)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 3.0)
		SetSliderDialogInterval(0.1)
	ElseIf (Option == SetBedSearchDistance)
		SetSliderDialogStartValue(Main.BedSearchDistance)
		SetSliderDialogDefaultValue(15.0)
		SetSliderDialogRange(1, 30)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetCustomTimescale)
		SetSliderDialogStartValue(Main.CustomTimescale)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(0, 40)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetFreeCamFOV)
		SetSliderDialogStartValue(Main.FreecamFOV)
		SetSliderDialogDefaultValue(45.0)
		SetSliderDialogRange(1, 120)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetDefaultFOV)
		SetSliderDialogStartValue(Main.DefaultFOV)
		SetSliderDialogDefaultValue(85.0)
		SetSliderDialogRange(1, 120)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetCameraSpeed)
		SetSliderDialogStartValue(Main.FreecamSpeed)
		SetSliderDialogDefaultValue(3.0)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetBedReallignment)
		SetSliderDialogStartValue(Main.BedReallignment)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-250, 250)
		SetSliderDialogInterval(1)
	ElseIf (Option == SetAIChangeChance)
		SetSliderDialogStartValue(Main.AiSwitchChance)
		SetSliderDialogDefaultValue(6.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (option == SetORDifficulty)
		SetSliderDialogStartValue(GetExternalInt(oromance, GVORDifficulty))
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-100, 150)
		SetSliderDialogInterval(1)
	elseif (option == SetONFreqMult)
		SetSliderDialogStartValue(GetExternalFloat(ONights, GVONFreqMult))
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 5.0)
		SetSliderDialogInterval(0.1)
	EndIf
EndEvent

Event OnOptionSliderAccept(Int Option, Float Value)
	Main.PlayTickBig()
	If (Option == SetSexExcitementMult)
		Main.SexExcitementMult = Value
		SetSliderOptionValue(SetsexExcitementMult, Value, "{2} x")
	Elseif (option == SetORDifficulty)
		SetExternalInt(oromance, GVORDifficulty, value as int)
		SetSliderOptionValue(SetORDifficulty, Value as int, "{0}")
	Elseif (option == SetONFreqMult)
		SetExternalFloat(ONights, GVONFreqMult, value)
		SetSliderOptionValue(SetONFreqMult, Value, "{2} x")
	ElseIf (Option == SetBedSearchDistance)
		Main.BedSearchDistance = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0} meters")
	ElseIf (Option == SetCustomTimescale)
		Main.CustomTimescale = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	ElseIf (Option == SetFreeCamFOV)
		Main.FreecamFOV = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	ElseIf (Option == SetDefaultFOV)
		Main.DefaultFOV = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	ElseIf (Option == SetCameraSpeed)
		Main.FreecamSpeed = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	ElseIf (Option == SetBedReallignment)
		Main.BedReallignment = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0} units")
	ElseIf (Option == SetAIChangeChance)
		Main.AiSwitchChance = (Value as Int)
		SetSliderOptionValue(Option, Value, "{0}")
	EndIf
EndEvent

Event OnOptionKeyMapChange(Int Option, Int KeyCode, String ConflictControl, String ConflictName)
	Main.PlayTickBig()
	If (Option == Setkeymap)
		Main.RemapStartKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetKeyUp)
		Main.RemapSpeedUpKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetKeyDown)
		Main.RemapSpeedDownKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetPullOut)
		Main.RemapPulloutKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	ElseIf (Option == SetControlToggle)
		Main.RemapControlToggleKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	Elseif (Option == SetORKey)
		SetExternalInt(oromance, gvorkey, KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	Elseif (Option == SetORLeft)
		SetExternalInt(oromance, GVORLeft, KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	Elseif (Option == SetORRight)
		SetExternalInt(oromance, GVORRight, KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
	EndIf
EndEvent

function DrawSlotPage()
	SlotSets = new int[128]

	string[] names = new string[128]

	names[30] = "<font color='#317335'> Head"
	names[31] = "<font color='#317335'> Head/hair"
	names[32] = "<font color='#317335'> Body armor/clothes"
	names[33] = "<font color='#317335'> Gloves/gauntlets"
	names[34] = "<font color='#317335'> Forearms"
	names[35] = "<font color='#317335'> Amulet"
	names[36] = "<font color='#317335'> Ring"
	names[37] = "<font color='#317335'> Shoes"
	names[38] = "<font color='#317335'> Calves"
	names[39] = "<font color='#317335'> Shield"
	names[40] = "<font color='#317335'> Tail"
	names[41] = "<font color='#317335'> Long hair"
	names[42] = "<font color='#317335'> Circlet"
	names[43] = "<font color='#317335'> Ear rings"

	names[44] = "<font color='#31755c'> Face/mouth"
	names[45] = "<font color='#31755c'> Neck/scarf. Sometimes panties"
	names[46] = "<font color='#31755c'> Extra chest piece"
	names[47] = "<font color='#31755c'> Back (backpack, wings, etc)"
	names[48] = "<font color='#31755c'> Misc"
	names[49] = "<font color='#31755c'> Extra pelvis piece"
	names[52] = "<font color='#31755c'> Extra pelvis piece 2 | SchlongsofSkyrim"
	names[53] = "<font color='#31755c'> Extra leg piece"
	names[54] = "<font color='#31755c'> Extra leg piece 2"
	names[55] = "<font color='#31755c'> Face alternate or jewelry"
	names[56] = "<font color='#31755c'> Extra chest piece 2"
	names[57] = "<font color='#31755c'> Shoulder"
	names[58] = "<font color='#31755c'> Extra arm piece 2"
	names[59] = "<font color='#31755c'> Extra arm piece"
	names[60] = "<font color='#31755c'> Misc"

	int i = 30
	int max = 62

	While i < max
		string additional = ""
		if names[i] != ""
			additional = " " + names[i]
		endif
		SlotSets[i] = AddToggleOption("S. " + i as string + additional, Main.IntArrayContainsValue(main.StrippingSlots, i))

		i += 1
	EndWhile

endfunction

Function OnSlotSelect(int option)

	 int slot = option - 486

	 osexintegrationmain.console(slot)

	 if (slot < 0) || slot > 100
	 	debug.messagebox("Slot error. report to dev please")
	 endif

	 if Main.IntArrayContainsValue(main.StrippingSlots, slot)
	 	; remove this from the array
	 	main.StrippingSlots = PapyrusUtil.RemoveInt(main.StrippingSlots, slot)
	 	SetToggleOptionValue(Option, false)
	 else 
	 	;add this to the array
	 	main.StrippingSlots = PapyrusUtil.PushInt(main.StrippingSlots, slot)
	 	SetToggleOptionValue(Option, true)
	 endif

EndFunction

Function OnSlotMouseOver(int option)
	int slot = option - 486

	armor equipped = playerref.getEquippedArmorInSlot(slot) ; se exclusive

	if equipped
		SetInfoText("Player has armor equipped that matches this slot\nName: " + equipped.getname() + "\nFull slotmask: " + equipped.GetSlotMask())
	else
		SetInfoText("No armor matching this slot on player")
	endif
endfunction

Event OnGameReload()
	Parent.OnGameReload()
EndEvent

Bool Color1
Function AddColoredHeader(String In)
	String Blue = "#6699ff"
	String Pink = "#ff3389"
	String Color
	If Color1
		Color = Pink
		Color1 = False
	Else
		Color = Blue
		Color1 = True
	EndIf

	AddHeaderOption("<font color='" + Color +"'>" + In)
EndFunction

Function ExportSettings()
	; Export to file.
	int OstimSettingsFile = JMap.object()
	
	Debug.MessageBox("Exporting to file, wait a second or two before clicking OK.")
	
	; Sex settings export.
	JMap.SetInt(OstimSettingsFile, "SetEndOnOrgasm", Main.EndOnDomOrgasm as Int)
	JMap.SetInt(OstimSettingsFile, "SetEndOnSubOrgasm", Main.EndOnSubOrgasm as Int)
	JMap.SetInt(OstimSettingsFile, "SetEndOnBothOrgasm", Main.RequireBothOrgasmsToFinish as Int)
	JMap.SetInt(OstimSettingsFile, "SetActorSpeedControl", Main.EnableActorSpeedControl as Int)
	JMap.SetFlt(OstimSettingsFile, "SetsexExcitementMult", Main.SexExcitementMult as Float)
	JMap.SetInt(OstimSettingsFile, "SetClipinglessFirstPerson", Main.EnableImprovedCamSupport as Int)
	JMap.SetInt(OstimSettingsFile, "SetEndAfterActorHit", Main.EndAfterActorHit as Int)
	JMap.SetInt(OstimSettingsFile, "SetUseRumble", Main.UseRumble as Int)
	JMap.SetInt(OstimSettingsFile, "SetUseScreenShake", Main.UseScreenShake as Int)
	JMap.SetInt(OstimSettingsFile, "SetScaling", Main.DisableScaling as Int)
	
	; Clothes settings export.
	JMap.SetInt(OstimSettingsFile, "SetUndressIfNeed", Main.AutoUndressIfNeeded as Int)
	JMap.SetInt(OstimSettingsFile, "SetAlwaysUndressAtStart", Main.AlwaysUndressAtAnimStart as Int)
	JMap.SetInt(OstimSettingsFile, "SetDropClothes", Main.TossClothesOntoGround as Int)
	JMap.SetInt(OstimSettingsFile, "SetAnimateRedress", Main.FullyAnimateRedress as Int)
	;JMap.SetInt(OstimSettingsFile, "SetStrongerUnequip", Main.UseStrongerUnequipMethod as Int)

	; JMap.SetInt(OstimSettingsFile, "SetAlwaysAnimateUndress", Main.AlwaysAnimateUndress as Int) These have been removed in 4.0
	; JMap.SetInt(OstimSettingsFile, "SetonlyUndressChest", Main.OnlyUndressChest as Int) These have been removed in 4.0

	; Bar settings export.
	JMap.SetInt(OstimSettingsFile, "SetSubBar", Main.EnableSubBar as Int)
	JMap.SetInt(OstimSettingsFile, "SetDomBar", Main.EnableDomBar as Int)
	JMap.SetInt(OstimSettingsFile, "SetThirdBar", Main.EnableThirdBar as Int)
	JMap.SetInt(OstimSettingsFile, "SetAutoHideBar", Main.AutoHideBars as Int)
	JMap.SetInt(OstimSettingsFile, "SetMatchColorToGender", Main.MatchBarColorToGender as Int)
	JMap.SetInt(OstimSettingsFile, "SetHideNPCOnNPCBars", Main.HideBarsInNPCScenes as Int)

	; Orgasm settings export.
	; These might have been removed from the mcm.
	;JMap.SetInt(OstimSettingsFile, "SetSlowMoOrgasms", Main.SlowMoOrgasms as Int)
	;JMap.SetInt(OstimSettingsFile, "SetOrgasmBoostsRel", Main.OrgasmBoostsRel as Int)

	; Light settings export.
	Jmap.SetInt(OstimSettingsFile, "SetDomLightMode", Main.DomLightPos as Int)
	Jmap.SetInt(OstimSettingsFile, "SetSubLightMode", Main.SubLightPos as Int)
	Jmap.SetInt(OstimSettingsFile, "SetSubLightBrightness", Main.SubLightBrightness as Int)
	Jmap.SetInt(OstimSettingsFile, "SetDomLightBrightness", Main.DomLightBrightness as Int)
	Jmap.SetInt(OstimSettingsFile, "SetOnlyLightInDark", Main.LowLightLevelLightsOnly as Int)
	
	; Keys settings export.
	JMap.SetInt(OstimSettingsFile, "SetKeymap", Main.KeyMap as Int)
	JMap.SetInt(OstimSettingsFile, "SetKeyUp", Main.SpeedUpKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetKeyDown", Main.SpeedDownKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetPullOut", Main.PullOutKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetControlToggle", Main.ControlToggleKey as Int)

	; Bed settings export.
	JMap.SetInt(OstimSettingsFile, "SetEnableBeds", Main.UseBed as Int)
	JMap.SetInt(OstimSettingsFile, "SetBedSearchDistance", Main.BedSearchDistance as Int)
	JMap.SetInt(OstimSettingsFile, "SetBedReallignment", Main.BedReallignment as Int)
	JMap.SetInt(OstimSettingsFile, "SetBedAlgo", Main.UseAlternateBedSearch as Int)

	; Ai/Control settings export.
	JMap.SetInt(OstimSettingsFile, "SetAIControl", Main.UseAIControl as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIIfAttacking", Main.UseAIPlayerAggressor as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIIfAttacked", Main.UseAIPlayerAggressed as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIInConsensualScenes", Main.UseAINonAggressive as Int)
	JMap.SetInt(OstimSettingsFile, "SetAIChangeChance", Main.AiSwitchChance as Int)

	; Camera settings export.
	JMap.SetInt(OstimSettingsFile, "SetUseFreeCam", Main.UseFreeCam as Int)
	JMap.SetInt(OstimSettingsFile, "SetFreeCamFOV", Main.FreecamFOV as Int)
	JMap.SetInt(OstimSettingsFile, "SetDefaultFOV", Main.DefaultFOV as Int)
	JMap.SetInt(OstimSettingsFile, "SetCameraSpeed", Main.FreecamSpeed as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceFirstPerson", Main.ForceFirstPersonAfter as Int)

	; Misc settings export.
	JMap.SetInt(OstimSettingsFile, "SetCustomTimescale", Main.CustomTimescale as Int)

	JMap.SetInt(OstimSettingsFile, "SetMisallignmentOption", Main.MisallignmentProtection as Int)
	JMap.SetInt(OstimSettingsFile, "SetFlipFix", Main.FixFlippedAnimations as Int)

	JMap.SetInt(OstimSettingsFile, "SetUseFades", Main.UseFades as Int)
	JMap.SetInt(OstimSettingsFile, "SetUseAutoFades", Main.UseAutoFades as Int)
	JMap.SetInt(OstimSettingsFile, "SetMute", Main.MuteOSA as Int)

	int clothes = JArray.objectWithInts(main.StrippingSlots)

	JMap.setObj(OstimSettingsFile,"Slots", clothes)
	
	; Save to file.
	Jvalue.WriteToFile(OstimSettingsFile, JContainers.UserDirectory() + "OstimMCMSettings.json")
	
	; Force page reset to show updated changes.
	ForcePageReset()
EndFunction

Function ImportSettings()
	; Import from file.
	int OstimSettingsFile = JValue.readFromFile(JContainers.UserDirectory() + "OstimMCMSettings.json")
	; Tries to import from Data folder as well, this is to allow Modlist creators to package configuration files as mods for mo2 or vortex.
	int OstimSettingsFileAlt = JValue.readFromFile(".\\Data\\OstimMCMSettings.json")
	if (OstimSettingsFile == False && OstimSettingsFileAlt == False)
		Debug.MessageBox("Tried to import from file, but no file existed.")
		return
	ElseIf (OstimSettingsFile == False && OstimSettingsFileAlt == True)
		OstimSettingsFile = OstimSettingsFileAlt
		Debug.MessageBox("Importing modlist settings from file, wait a second or two before clicking OK.")
	Else
		Debug.MessageBox("Importing from file, wait a second or two before clicking OK.")
	EndIf
	; Sex settings import.
	Main.EndOnDomOrgasm = Jmap.GetInt(OstimSettingsFile, "SetEndOnOrgasm")
	Main.EndOnSubOrgasm = JMap.GetInt(OstimSettingsFile, "SetEndOnSubOrgasm")
	Main.RequireBothOrgasmsToFinish = JMap.GetInt(OstimSettingsFile, "SetEndOnBothOrgasm")
	Main.EnableActorSpeedControl = JMap.GetInt(OstimSettingsFile, "SetActorSpeedControl")
	Main.SexExcitementMult = JMap.GetFlt(OstimSettingsFile, "SetsexExcitementMult")
	Main.EnableImprovedCamSupport = JMap.GetInt(OstimSettingsFile, "SetClipinglessFirstPerson")
	Main.EndAfterActorHit = JMap.GetInt(OstimSettingsFile, "SetEndAfterActorHit")
	Main.UseRumble = JMap.GetInt(OstimSettingsFile, "SetUseRumble")
	Main.UseScreenShake = JMap.GetInt(OstimSettingsFile, "SetUseScreenShake")
	Main.DisableScaling = JMap.GetInt(OstimSettingsFile, "SetScaling")
	
	; Clothes settings import.
	Main.AutoUndressIfNeeded = JMap.GetInt(OstimSettingsFile, "SetUndressIfNeed")
	Main.TossClothesOntoGround = JMap.GetInt(OstimSettingsFile, "SetDropClothes")
	Main.FullyAnimateRedress = JMap.GetInt(OstimSettingsFile, "SetAnimateRedress")
	;Main.UseStrongerUnequipMethod = JMap.GetInt(OstimSettingsFile, "SetStrongerUnequip")
	Main.AlwaysUndressAtAnimStart = JMap.GetInt(OstimSettingsFile, "SetAlwaysUndressAtStart")
	
	; Main.AlwaysAnimateUndress = JMap.GetInt(OstimSettingsFile, "SetAlwaysAnimateUndress") These have been removed in 4.0
	; Main.OnlyUndressChest = JMap.GetInt(OstimSettingsFile, "SetonlyUndressChest") These have been removed in 4.0
	
	; Bar settings import.
	Main.EnableSubBar = JMap.GetInt(OstimSettingsFile, "SetSubBar")
	Main.EnableDomBar = JMap.GetInt(OstimSettingsFile, "SetDomBar")
	Main.EnableThirdBar = JMap.GetInt(OstimSettingsFile, "SetThirdBar")
	Main.AutoHideBars = JMap.GetInt(OstimSettingsFile, "SetAutoHideBar")
	Main.MatchBarColorToGender = JMap.GetInt(OstimSettingsFile, "SetMatchColorToGender")
	Main.HideBarsInNPCScenes = JMap.GetInt(OstimSettingsFile, "SetHideNPCOnNPCBars")

	; Light settings export.
	Main.DomLightPos = Jmap.GetInt(OstimSettingsFile, "SetDomLightMode")
	Main.SubLightPos = Jmap.GetInt(OstimSettingsFile, "SetSubLightMode")
	Main.SubLightBrightness = Jmap.GetInt(OstimSettingsFile, "SetSubLightBrightness")
	Main.DomLightBrightness = Jmap.GetInt(OstimSettingsFile, "SetDomLightBrightness")
	Main.LowLightLevelLightsOnly = Jmap.GetInt(OstimSettingsFile, "SetOnlyLightInDark")
	
	; Keys settings import.
	Main.KeyMap = JMap.GetInt(OstimSettingsFile, "SetKeymap")
	Main.RemapStartKey(Main.KeyMap)
	Main.SpeedUpKey = JMap.GetInt(OstimSettingsFile, "SetKeyUp")
	Main.RemapSpeedUpKey(Main.SpeedUpKey)
	Main.SpeedDownKey = JMap.GetInt(OstimSettingsFile, "SetKeyDown")
	Main.RemapSpeedDownKey(Main.SpeedDownKey)
	Main.PullOutKey = JMap.GetInt(OstimSettingsFile, "SetPullOut")
	Main.RemapPullOutKey(Main.PullOutKey)
	Main.ControlToggleKey = JMap.GetInt(OstimSettingsFile, "SetControlToggle")
	Main.RemapControlToggleKey(Main.ControlToggleKey)
	
	; Bed settings export.
	Main.UseBed = JMap.GetInt(OstimSettingsFile, "SetEnableBeds")
	Main.BedSearchDistance = JMap.GetInt(OstimSettingsFile, "SetBedSearchDistance")
	Main.BedReallignment = JMap.GetInt(OstimSettingsFile, "SetBedReallignment")
	Main.UseAlternateBedSearch = JMap.GetInt(OstimSettingsFile, "SetBedAlgo")
	Main.AiSwitchChance = JMap.GetInt(OstimSettingsFile, "SetAIChangeChance")
	
	; Ai/Control settings export.
	Main.UseAIControl = JMap.GetInt(OstimSettingsFile, "SetAIControl")
	Main.UseAIPlayerAggressor = JMap.GetInt(OstimSettingsFile, "SetForceAIIfAttacking")
	Main.UseAIPlayerAggressed = JMap.GetInt(OstimSettingsFile, "SetForceAIIfAttacked")
	Main.UseAINonAggressive = JMap.GetInt(OstimSettingsFile, "SetForceAIInConsensualScenes")
	
	; Camera settings export.
	Main.UseFreeCam = JMap.GetInt(OstimSettingsFile, "SetUseFreeCam")
	Main.FreecamFOV = JMap.GetInt(OstimSettingsFile, "SetFreeCamFOV")
	Main.DefaultFOV = JMap.GetInt(OstimSettingsFile, "SetDefaultFOV")
	Main.FreecamSpeed = JMap.GetInt(OstimSettingsFile, "SetCameraSpeed")
	Main.ForceFirstPersonAfter = JMap.GetInt(OstimSettingsFile, "SetForceFirstPerson")

	; Misc settings export.
	Main.CustomTimescale = JMap.GetInt(OstimSettingsFile, "SetCustomTimescale")
	
	Main.MisallignmentProtection = JMap.GetInt(OstimSettingsFile, "SetMisallignmentOption")
	Main.FixFlippedAnimations = JMap.GetInt(OstimSettingsFile, "SetFlipFix")
	
	Main.UseFades = JMap.GetInt(OstimSettingsFile, "SetUseFades")
	Main.UseAutoFades = JMap.GetInt(OstimSettingsFile, "SetUseAutoFades")
	
	Main.MuteOSA = JMap.GetInt(OstimSettingsFile, "SetMute")
	
	main.StrippingSlots = JArray.asIntArray((jmap.getObj(OstimSettingsFile, "Slots")))

	; Force page reset to show updated changes.
	ForcePageReset()
EndFunction
