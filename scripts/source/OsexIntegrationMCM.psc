ScriptName OsexIntegrationMCM Extends SKI_ConfigBase

; sex settings
Int SetEndOnOrgasm
Int SetActorSpeedControl
Int SetsexExcitementMult
Int SetClipinglessFirstPerson
Int SetEndAfterActorHit
Int SetUseRumble
Int SetUseScreenShake

; clothes settings
Int SetUndressIfNeed
Int SetAlwaysAnimateUndress
Int SetAlwaysUndressAtStart
Int SetonlyUndressChest

; bar settings
Int SetSubBar
Int SetDomBar
Int SetAutoHideBar

; orgasm settings
; are these still used??
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

OsexIntegrationMain Main

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
EndFunction

Event OnPageReset(String Page)
	{Called when a new page is selected, including the initial empty page}
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
		SetEndOnOrgasm = AddToggleOption("End sex after main actor orgasm", Main.EndOnDomOrgasm)
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
		SetAutoHideBar = AddToggleOption("Autohide bars", Main.AutoHideBars)
		AddEmptyOption()

		AddColoredHeader("System")
		SetResetState = AddTextOption("Reset thread state", "")
		SetRebuildDatabase = AddTextOption("Rebuild animation database", "")
		SetMute = AddToggleOption("Mute vanilla OSA sounds", Main.MuteOSA)
		;SetUseCosaveWorkaround = AddToggleOption("Fix keys & auto-mode", Main.useBrokenCosaveWorkaround)
		AddEmptyOption()

		;=============================================================================================

		SetCursorPosition(3)
		AddColoredHeader("Undressing")
		SetUndressIfneed = AddToggleOption("Auto-remove clothes", Main.AutoUndressIfNeeded)
		SetAlwaysUndressAtStart = AddToggleOption("Always undress at start", Main.AlwaysUndressAtAnimStart)
		SetAlwaysAnimateUndress = AddToggleOption("Use undress animation", Main.AlwaysAnimateUndress)
		SetonlyUndressChest = AddToggleOption("Only undress chest piece", Main.OnlyUndressChest)
		AddEmptyOption()

		AddColoredHeader("AI Control")
		SetAIControl = AddToggleOption("Enable full-auto control", Main.UseAIControl)
		SetForceAIIfAttacking = AddToggleOption("Force full-auto control if player attacking", Main.UseAIPlayerAggressor)
		SetForceAIIfAttacked = AddToggleOption("Force full-auto control if player is attacked", Main.UseAIPlayerAggressed)
		SetForceAIInConsensualScenes = AddToggleOption("Force full-auto control in consensual scenes", Main.UseAINonAggressive)
		SetUseAutoFades = AddToggleOption("Fade out in between animation transitions", Main.UseAutoFades)
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
	ElseIf (Page == "About")
		UnloadCustomContent()
		Main.PlayTickBig()
		SetCursorFillMode(TOP_TO_BOTTOM)
		LoadCustomContent("Ostim/info.dds")
	EndIf
EndEvent

Event OnOptionSelect(Int Option)
	Main.PlayTickBig()
	If (Option == SetEndOnOrgasm)
		Main.EndOnDomOrgasm = !Main.EndOnDomOrgasm
		SetToggleOptionValue(SetEndOnOrgasm, Main.EndOnDomOrgasm)
	ElseIf (Option == SetResetState)
		Main.ResetState()
	ElseIf (Option == SetRebuildDatabase)
		Debug.MessageBox("Close all menus and watch the console until it is done")
		Main.GetODatabase().InitDatabase()
	ElseIf (Option == SetActorSpeedControl)
		Main.EnableActorSpeedControl = !Main.EnableActorSpeedControl
		SetToggleOptionValue(Option, Main.EnableActorSpeedControl)
	ElseIf (Option == SetEnableBeds)
		Main.UseBed = !Main.UseBed
		SetToggleOptionValue(Option, Main.UseBed)
	ElseIf (Option == SetUseRumble)
		Main.UseRumble = !Main.UseRumble
		SetToggleOptionValue(Option, Main.UseRumble)
	ElseIf (Option == SetFlipFix)
		Main.FixFlippedAnimations = !Main.FixFlippedAnimations
		SetToggleOptionValue(Option, Main.FixFlippedAnimations)
	ElseIf (Option == SetUseScreenShake)
		Main.UseScreenShake = !Main.UseScreenShake
		SetToggleOptionValue(Option, Main.UseScreenShake)
	ElseIf (Option == SetForceAIInConsensualScenes)
		Main.UseAINonAggressive = !Main.UseAINonAggressive
		SetToggleOptionValue(Option, Main.UseAINonAggressive)
	ElseIf (Option == SetForceAIIfAttacked)
		Main.UseAIPlayerAggressed = !Main.UseAIPlayerAggressed
		SetToggleOptionValue(Option, Main.UseAIPlayerAggressed)
	ElseIf (Option == SetForceFirstPerson)
		Main.ForceFirstPersonAfter = !Main.ForceFirstPersonAfter
		SetToggleOptionValue(Option, Main.ForceFirstPersonAfter)
	ElseIf (Option == SetUseAutoFades)
		Main.UseAutoFades = !Main.UseAutoFades
		SetToggleOptionValue(Option, Main.UseAutoFades)
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
	ElseIf (Option == SetonlyUndressChest)
		Main.OnlyUndressChest = !Main.OnlyUndressChest
		SetToggleOptionValue(Option, Main.OnlyUndressChest)
	ElseIf (Option == SetDomBar)
		Main.EnableDomBar = !Main.EnableDomBar
		SetToggleOptionValue(Option, Main.EnableDomBar)
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
	If (Option == SetEndOnOrgasm)
		SetInfoText("End the Osex scene automatically when the dominant actor (usually the male) orgasms")
	ElseIf (Option == SetResetState)
		SetInfoText("Click this if you keep getting a Scene Already Running type error")
	ElseIf (Option == SetForceAIIfAttacked)
		SetInfoText("If using manual mode by default, this will force automatic mode to activate if the player is the victim in an aggressive scene")
	ElseIf (Option == SetForceAIIfAttacking)
		SetInfoText("If using manual mode by default, this will force automatic mode to activate if the player is the attacker in an aggressive scene")
	ElseIf (Option == SetForceAIInConsensualScenes)
		SetInfoText("If using manual mode by default, this will force automatic mode to activate in consensual scenes")
	ElseIf (Option == SetUseFades)
		SetInfoText("Fade the screen to black when a scene starts/ends")
	ElseIf (Option == SetUseCosaveWorkaround)
		SetInfoText("Some users appear to have a broken SKSE co-save setup\n This manifests itself as full-auto mode not working, and keys not saving\nThis will fix the symptoms of the issue if you have it, but not the core cause")
	ElseIf (Option == SetFreeCamFOV)
		SetInfoText("The field of view of the camera when in freecam mode\nThis is incompatible with Improved Camera")
	ElseIf (Option == SetUseRumble)
		SetInfoText("Rumble a controller on thrust, if a controller is being used")
	ElseIf (Option == SetEndAfterActorHit)
		SetInfoText("End the scene after someone in the scene is hit\n Can misfire with certain other mods")
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
	ElseIf (Option == SetFlipFix)
		SetInfoText("Fix some third party animations being flipped 180 degrees")
	ElseIf (Option == SetAlwaysUndressAtStart)
		SetInfoText("Actors will always get undressed as a scene starts \nMods using this mod's API can force an undress to occur even if this isn't checked")
	ElseIf (Option == SetAlwaysAnimateUndress)
		SetInfoText("Always play Osex's undressing animations instead of just removing the clothes normally\nNote: that Auto-Remove clothes will never use Osex's undress animation\nFurther note: Mods using this mod's API can force an animation to occur even if this isn't checked")
	ElseIf (Option == SetonlyUndressChest)
		SetInfoText("Only remove the chest piece during undressing\nNote: due to bugginess with Osex, if using Undress Animation, only the chest piece is currently removed even with this not checked")
	ElseIf (Option == SetDomBar)
		SetInfoText("Enable the on-screen bar that track's the dominant actor's Excitement\nActor's orgasm when their Excitement maxes out")
	ElseIf (Option == SetSubBar)
		SetInfoText("Enable the on-screen bar that track's the second actor's Excitement\nActor's orgasm when their Excitement maxes out")
	ElseIf (Option == SetMisallignmentOption)
		SetInfoText("Enable automatic misalignment detection\nYou may want to disable this if you want to do some custom realigning.")
	ElseIf (Option == SetEnableBeds)
		SetInfoText("Actors will find the nearest bed to have sex on")
	ElseIf (Option == SetAIControl)
		SetInfoText("If enabled, scenes will play out on their own without user input via procedural generation\nNote: If you have only used Manual mode briefly or not at all, and never became adept with using it, I STRONGLY recommend you give manual mode a fair chance before using this")
	ElseIf (Option == SetAutoHideBar)
		SetInfoText("Automatically hide the bars during sex when not interacting with the UI")
	ElseIf (Option == SetSlowMoOrgasms)
		SetInfoText("Add in a few seconds of slowmotion right when the player orgasms\nUnrelated to this Option, if sexlab is installed, cum effects and sound effects will be extracted and used from it as well\nA reinstall may be needed to detect sexlab if installed after this mod")
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
	EndIf
EndEvent

Event OnOptionSliderAccept(Int Option, Float Value)
	Main.PlayTickBig()
	If (Option == SetSexExcitementMult)
		Main.SexExcitementMult = Value
		SetSliderOptionValue(SetsexExcitementMult, Value, "{2} x")
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
	EndIf
EndEvent

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
	; Temp setting for performance testing.
	float ftimestart = Utility.GetCurrentRealTime()
	; Export to file.
	int OstimSettingsFile = JMap.object()
	
	Debug.MessageBox("Exporting to file...")
	
	; Sex settings export
	JMap.SetInt(OstimSettingsFile, "SetEndOnOrgasm", Main.EndOnDomOrgasm as Int)
	JMap.SetInt(OstimSettingsFile, "SetActorSpeedControl", Main.EnableActorSpeedControl as Int)
	JMap.SetInt(OstimSettingsFile, "SetsexExcitementMult", Main.SexExcitementMult as Int)
	JMap.SetInt(OstimSettingsFile, "SetClipinglessFirstPerson", Main.EnableImprovedCamSupport as Int)
	JMap.SetInt(OstimSettingsFile, "SetEndAfterActorHit", Main.EndAfterActorHit as Int)
	JMap.SetInt(OstimSettingsFile, "SetUseRumble", Main.UseRumble as Int)
	JMap.SetInt(OstimSettingsFile, "SetUseScreenShake", Main.UseScreenShake as Int)
	
	; Clothes settings export
	JMap.SetInt(OstimSettingsFile, "SetUndressIfNeed", Main.AutoUndressIfNeeded as Int)
	JMap.SetInt(OstimSettingsFile, "SetAlwaysAnimateUndress", Main.AlwaysAnimateUndress as Int)
	JMap.SetInt(OstimSettingsFile, "SetAlwaysUndressAtStart", Main.AlwaysUndressAtAnimStart as Int)
	JMap.SetInt(OstimSettingsFile, "SetonlyUndressChest", Main.OnlyUndressChest as Int)

	; Bar settings export
	JMap.SetInt(OstimSettingsFile, "SetSubBar", Main.EnableSubBar as Int)
	JMap.SetInt(OstimSettingsFile, "SetDomBar", Main.EnableDomBar as Int)
	JMap.SetInt(OstimSettingsFile, "SetAutoHideBar", Main.AutoHideBars as Int)

	; Orgasm settings export
	; These might have been removed from the mcm.
	;JMap.SetInt(OstimSettingsFile, "SetSlowMoOrgasms", Main.SlowMoOrgasms as Int)
	;JMap.SetInt(OstimSettingsFile, "SetOrgasmBoostsRel", Main.OrgasmBoostsRel as Int)

	; Light settings export
	Jmap.SetInt(OstimSettingsFile, "SetDomLightMode", DomLightModeList[Main.DomLightPos] as Int)
	Jmap.SetInt(OstimSettingsFile, "SetSubLightMode", SubLightModeList[Main.SubLightPos] as Int)
	Jmap.SetInt(OstimSettingsFile, "SetSubLightBrightness", DomLightBrightList[Main.DomLightBrightness] as Int)
	Jmap.SetInt(OstimSettingsFile, "SetDomLightBrightness", SubLightBrightList[Main.SubLightBrightness] as Int)
	Jmap.SetInt(OstimSettingsFile, "SetOnlyLightInDark", Main.LowLightLevelLightsOnly as Int)
	
	; Keys settings export MAKE SURE TO TEST THESE
	JMap.SetInt(OstimSettingsFile, "SetKeymap", Main.KeyMap as Int)
	JMap.SetInt(OstimSettingsFile, "SetKeyUp", Main.SpeedUpKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetKeyDown", Main.SpeedDownKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetPullOut", Main.PullOutKey as Int)
	JMap.SetInt(OstimSettingsFile, "SetControlToggle", Main.ControlToggleKey as Int)

	; Bed settings export
	JMap.SetInt(OstimSettingsFile, "SetEnableBeds", Main.UseBed as Int)
	JMap.SetInt(OstimSettingsFile, "SetBedSearchDistance", Main.BedSearchDistance as Int)
	JMap.SetInt(OstimSettingsFile, "SetBedReallignment", Main.BedReallignment as Int)
	JMap.SetInt(OstimSettingsFile, "SetBedAlgo", Main.UseAlternateBedSearch as Int)

	; Ai/Control settings export
	JMap.SetInt(OstimSettingsFile, "SetAIControl", Main.UseAIControl as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIIfAttacking", Main.UseAIPlayerAggressor as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIIfAttacked", Main.UseAIPlayerAggressed as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceAIInConsensualScenes", Main.UseAINonAggressive as Int)

	; Camera settings export
	JMap.SetInt(OstimSettingsFile, "SetUseFreeCam", Main.UseFreeCam as Int)
	JMap.SetInt(OstimSettingsFile, "SetFreeCamFOV", Main.FreecamFOV as Int)
	JMap.SetInt(OstimSettingsFile, "SetDefaultFOV", Main.DefaultFOV as Int)
	JMap.SetInt(OstimSettingsFile, "SetCameraSpeed", Main.FreecamSpeed as Int)
	JMap.SetInt(OstimSettingsFile, "SetForceFirstPerson", Main.ForceFirstPersonAfter as Int)

	; Misc settings export
	JMap.SetInt(OstimSettingsFile, "SetCustomTimescale", Main.CustomTimescale as Int)

	JMap.SetInt(OstimSettingsFile, "SetMisallignmentOption", Main.MisallignmentProtection as Int)
	JMap.SetInt(OstimSettingsFile, "SetFlipFix", Main.FixFlippedAnimations as Int)

	JMap.SetInt(OstimSettingsFile, "SetUseFades", Main.UseFades as Int)
	JMap.SetInt(OstimSettingsFile, "SetUseAutoFades", Main.UseAutoFades as Int)

	JMap.SetInt(OstimSettingsFile, "SetMute", Main.MuteOSA as Int)

	; Save to file.
	Jvalue.WriteToFile(OstimSettingsFile, JContainers.UserDirectory() + "OstimMCMSettings.json")
	
	; Force page reset to show updated changes.
	ForcePageReset()
	; Temp setting for performance testing.
	float ftimeEnd = Utility.GetCurrentRealTime()
	Debug.Trace("We took " + (ftimeEnd - ftimeStart) + " seconds to run")
EndFunction

Function ImportSettings()
	; Temp setting for performance testing.
	float ftimestart = Utility.GetCurrentRealTime()
	; Import from file.
	int OstimSettingsFile = JValue.readFromFile(JContainers.UserDirectory() + "OstimMCMSettings.json")
	
	Debug.MessageBox("Importing from file...")
	
	; Sex settings import
	Main.EndOnDomOrgasm = Jmap.GetInt(OstimSettingsFile, "SetEndOnOrgasm")
	Main.EnableActorSpeedControl = JMap.GetInt(OstimSettingsFile, "SetActorSpeedControl")
	Main.SexExcitementMult = JMap.GetInt(OstimSettingsFile, "SetsexExcitementMult")
	Main.EnableImprovedCamSupport = JMap.GetInt(OstimSettingsFile, "SetClipinglessFirstPerson")
	Main.EndAfterActorHit = JMap.GetInt(OstimSettingsFile, "SetEndAfterActorHit")
	Main.UseRumble = JMap.GetInt(OstimSettingsFile, "SetUseRumble")
	Main.UseScreenShake = JMap.GetInt(OstimSettingsFile, "SetUseScreenShake")
	
	; Clothes settings import
	Main.AutoUndressIfNeeded = JMap.GetInt(OstimSettingsFile, "SetUndressIfNeed")
	Main.AlwaysAnimateUndress = JMap.GetInt(OstimSettingsFile, "SetAlwaysAnimateUndress")
	Main.AlwaysUndressAtAnimStart = JMap.GetInt(OstimSettingsFile, "SetAlwaysUndressAtStart")
	Main.OnlyUndressChest = JMap.GetInt(OstimSettingsFile, "SetonlyUndressChest")
	
	; Bar settings import
	Main.EnableSubBar = JMap.GetInt(OstimSettingsFile, "SetSubBar")
	Main.EnableDomBar = JMap.GetInt(OstimSettingsFile, "SetDomBar")
	Main.AutoHideBars = JMap.GetInt(OstimSettingsFile, "SetAutoHideBar")

	; Light settings import
	DomLightModeList[Main.DomLightPos] = Jmap.GetInt(OstimSettingsFile, "SetDomLightMode")
	SubLightModeList[Main.SubLightPos] = Jmap.GetInt(OstimSettingsFile, "SetSubLightMode")
	DomLightBrightList[Main.DomLightBrightness] = Jmap.GetInt(OstimSettingsFile, "SetSubLightBrightness")
	SubLightBrightList[Main.SubLightBrightness] = Jmap.GetInt(OstimSettingsFile, "SetDomLightBrightness")
	Main.LowLightLevelLightsOnly = Jmap.GetInt(OstimSettingsFile, "SetOnlyLightInDark")
	
	; Keys settings import MAKE SURE TO TEST THESE
	Main.RemapStartKey(JMap.GetInt(OstimSettingsFile, "SetKeymap"))
	Main.RemapSpeedUpKey(JMap.GetInt(OstimSettingsFile, "SetKeyUp"))
	Main.RemapSpeedDownKey(JMap.GetInt(OstimSettingsFile, "SetKeyDown"))
	Main.RemapPullOutKey(JMap.GetInt(OstimSettingsFile, "SetPullOut"))
	Main.RemapControlToggleKey(JMap.GetInt(OstimSettingsFile, "SetControlToggle"))
	
	; Bed settings export
	Main.UseBed = JMap.GetInt(OstimSettingsFile, "SetEnableBeds")
	Main.BedSearchDistance = JMap.GetInt(OstimSettingsFile, "SetBedSearchDistance")
	Main.BedReallignment = JMap.GetInt(OstimSettingsFile, "SetBedReallignment")
	Main.UseAlternateBedSearch = JMap.GetInt(OstimSettingsFile, "SetBedAlgo")
	
	; Ai/Control settings export
	Main.UseAIControl = JMap.GetInt(OstimSettingsFile, "SetAIControl")
	Main.UseAIPlayerAggressor = JMap.GetInt(OstimSettingsFile, "SetForceAIIfAttacking")
	Main.UseAIPlayerAggressed = JMap.GetInt(OstimSettingsFile, "SetForceAIIfAttacked")
	Main.UseAINonAggressive = JMap.GetInt(OstimSettingsFile, "SetForceAIInConsensualScenes")
	
	; Camera settings export
	Main.UseFreeCam = JMap.GetInt(OstimSettingsFile, "SetUseFreeCam")
	Main.FreecamFOV = JMap.GetInt(OstimSettingsFile, "SetFreeCamFOV")
	Main.DefaultFOV = JMap.GetInt(OstimSettingsFile, "SetDefaultFOV")
	Main.FreecamSpeed = JMap.GetInt(OstimSettingsFile, "SetCameraSpeed")
	Main.ForceFirstPersonAfter = JMap.GetInt(OstimSettingsFile, "SetForceFirstPerson")

	; Misc settings export
	Main.CustomTimescale = JMap.GetInt(OstimSettingsFile, "SetCustomTimescale")
	
	Main.MisallignmentProtection = JMap.GetInt(OstimSettingsFile, "SetMisallignmentOption")
	Main.FixFlippedAnimations = JMap.GetInt(OstimSettingsFile, "SetFlipFix")
	
	Main.UseFades = JMap.GetInt(OstimSettingsFile, "SetUseFades")
	Main.UseAutoFades = JMap.GetInt(OstimSettingsFile, "SetUseAutoFades")
	
	Main.MuteOSA = JMap.GetInt(OstimSettingsFile, "SetMute")
	
	; Force page reset to show updated changes.
	ForcePageReset()
	; Temp setting for performance testing.
	float ftimeEnd = Utility.GetCurrentRealTime()
	Debug.Trace("We took " + (ftimeEnd - ftimeStart) + " seconds to run")
EndFunction