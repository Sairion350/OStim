scriptname OsexIntegrationMCM extends SKI_ConfigBase

int setEndOnOrgasm ;sex settings
int setActorSpeedControl
int setUndressIfneed
int setsexExcitementMult
int setClipinglessFirstPerson
int setEndAfterActorHit
int setUseRumble
int setUseScreenShake
 ;clothes settings
int setAlwaysAnimateUndress
int setAlwaysUndressAtStart
int setonlyUndressChest

int setSubBar; bar settings
int setDomBar
int setAutoHideBar

int setSlowMoOrgasms ;orgasm settings
int setOrgasmBoostsRel

int setDomLightMode ; light settings
int setSubLightMode
int setSubLightBrightness
int setDomLightBrightness
int setOnlyLightInDark

int setResetState
int setRebuildDatabase

int setKeymap
int setKeyUp
int setKeyDown
int setPullOut

int setThanks

string[] domLightModeList
string[] subLightModeList

string[] subLightBrightList
string[] domLightBrightList

int setEnableBeds
int setBedSearchDistance
int setBedReallignment

int setAIControl
int setControlToggle

int setForceAIIfAttacking
int setForceAIIfAttacked
int setForceAIInConsensualScenes

int setCustomTimescale

int setMisallignmentOption
int setFlipFix

int setUseFades
int setUseAutoFades

int setMute

int setUseFreeCam
int setFreeCamFOV
int setDefaultFOV
int setCameraSpeed
int setForceFirstPerson

int setUseCosaveWorkaround



OsexIntegrationmain main
Event OnInit()
	init()
endevent
function init()
	parent.OnGameReload()
	main = (self as quest) as OsexIntegrationMain

	domLightModeList = new string[3]
	domLightModeList[0] = "No light"
	domLightModeList[1] = "Rear light"
	domLightModeList[2] = "Face light"

	subLightModeList = new string[3]
	subLightModeList[0] = "No light"
	subLightModeList[1] = "Rear light"
	subLightModeList[2] = "Face light"

	subLightBrightList = new string[2]
	subLightBrightList[0] = "Dim"
	subLightBrightList[1] = "Bright"

	domLightBrightList = new string[2]
	domLightBrightList[0] = "Dim"
	domLightBrightList[1] = "Bright"
endfunction

event OnPageReset(string page)
	{Called when a new page is selected, including the initial empty page}
	if page == "Configuration"
		if main == None


			init()
			if (main.endOnDomOrgasm != true)
				main.startup()
			endif
			debug.MessageBox("Anomaly detected in install, please reinstall OStim if it does not start properly")
		endif
		UnloadCustomContent()
		SetInfoText(" ")
		main.playTickBig()
		SetCursorFillMode(TOP_TO_BOTTOM)
		setThanks = AddTextOption("Thanks!", "")
		SetCursorPosition(1)
		AddTextOption("<font color='" + "#939292" +"'>" + "OStim Settings", "")
		SetCursorPosition(2)

		;=============================================================================================

		addColoredHeader("Sex scenes")
		setEndOnOrgasm = AddToggleOption("End sex after main actor orgasm", main.endOnDomOrgasm)
		setActorSpeedControl = AddToggleOption("Actors control speed", main.enableActorSpeedControl)
		setsexExcitementMult = AddSliderOption("Excitement multiplier", main.sexExcitementMult, "{2} x")
		setClipinglessFirstPerson = AddToggleOption("Clipping-less first person", main.enableImprovedCamSupport)
		setCustomTimescale = AddSliderOption("Custom timescale", main.customTimescale, "{0}")
		setMisallignmentOption = AddToggleOption("Enable misalignment protection", main.misallignmentProtection)
		setFlipFix = AddToggleOption("Enable flipped animation fix", main.fixFlippedAnimations)
		setUseFades = AddToggleOption("Fade out on intro/outro", main.useFades)
		setEndAfterActorHit = AddToggleOption("End if attacked", main.endAfterActorHit)
		setUseRumble = AddToggleOption("Use controller rumble", main.useRumble)
		setUseScreenShake = AddToggleOption("Use extra screenshake", main.useScreenShake)
		setForceFirstPerson = AddToggleOption("Force return to first person after scene", main.forceFirstPersonAfter)
		AddEmptyOption()

		addColoredHeader("Beds")
		setEnableBeds = AddToggleOption("Use beds", main.usebed)
		setBedSearchDistance = AddSliderOption("Bed search radius", main.bedSearchDistance, "{0} meters")
		setBedReallignment = AddSliderOption("Bed reallignment", main.bedReallignment, "{0} units")
		AddEmptyOption()

		addColoredHeader("Excitement bars")
		setDomBar = AddToggleOption("Main actor HUD bar", main.enableDomBar)
		setSubBar = AddToggleOption("Second actor HUD bar", main.enableSubBar)
		setAutoHideBar = AddToggleOption("Autohide bars", main.autoHideBars)
		AddEmptyOption()

		addColoredHeader("System")
		setResetState = AddTextOption("Reset thread state", "")
		setRebuildDatabase = AddTextOption("Rebuild animation database", "")
		setMute = AddToggleOption("Mute vanilla OSA sounds", main.muteOSA)
		;setUseCosaveWorkaround = AddToggleOption("Fix keys & auto-mode", main.useBrokenCosaveWorkaround)
		AddEmptyOption()

		;=============================================================================================

		SetCursorPosition(3)
		addColoredHeader("Undressing")
		setUndressIfneed = AddToggleOption("Auto-remove clothes", main.autoUndressIfNeeded)
		setAlwaysUndressAtStart = AddToggleOption("Always undress at start", main.alwaysUndressAtAnimStart)
		setAlwaysAnimateUndress = AddToggleOption("Use undress animation", main.alwaysAnimateUndress)
		setonlyUndressChest = AddToggleOption("Only undress chest piece", main.onlyUndressChest)
		AddEmptyOption()
		
		addColoredHeader("AI Control")
		setAIControl = AddToggleOption("Enable full-auto control", main.UseAIControl)
		setForceAIIfAttacking = AddToggleOption("Force full-auto control if player attacking", main.useAIPlayerAggressor)
		setForceAIIfAttacked = AddToggleOption("Force full-auto control if player is attacked", main.useAIPlayerAggressed)
		setForceAIInConsensualScenes = AddToggleOption("Force full-auto control in consensual scenes", main.useAINonAggressive)
		setUseAutoFades = AddToggleOption("Fade out in between animation transitions", main.useAutoFades)
		AddEmptyOption()

		addColoredHeader("FreeCam")
		setUseFreeCam = AddToggleOption("Switch to freecam mode on start", main.useFreeCam)
		setFreeCamFOV = AddSliderOption("Freecam FOV", main.freecamFOV, "{0}")
		setDefaultFOV = AddSliderOption("Freecam FOV", main.defaultFOV, "{0}")
		setCameraSpeed = AddSliderOption("Camera speed", main.freecamSpeed, "{0}")
		AddEmptyOption()
	
		addColoredHeader("Keys")
		setKeymap = AddKeyMapOption("Start sex with target", main.keymap)
		setKeyup = AddKeyMapOption("Increase speed", main.speedUpKey)
		setKeydown = AddKeyMapOption("Decrease speed", main.speedDownKey)
		setPullOut = AddKeyMapOption("Pull out", main.PullOutKey)
		setControlToggle = AddKeyMapOption("Switch control mode", main.ControlToggleKey)
		AddEmptyOption()

		addColoredHeader("Lights")
		setDomLightMode = AddMenuOption("Main actor light mode", domLightModeList[main.domLightPos])
		setSubLightMode = AddMenuOption("Second actor light mode", subLightModeList[main.subLightPos])
		setDomLightBrightness = AddMenuOption("Main actor light brightness", domLightBrightList[main.domLightBrightness])
		setSubLightBrightness = AddMenuOption("Second actor light brightness", subLightBrightList[main.subLightBrightness])
		setOnlyLightInDark = AddToggleOption("Only use lights in darkness", main.lowLightLevelLightsOnly)
		AddEmptyOption()
		
	elseif page == ""
		LoadCustomContent("Ostim/logo.dds", 184, 31)
		main.playding()
	elseif page == "About"
		UnloadCustomContent()
		main.playTickBig()
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		LoadCustomContent("Ostim/info.dds")

		
	endif	

endEvent

event onoptionselect(int option)
	main.playTickBig()
	if option == setEndOnOrgasm
		main.endOnDomOrgasm = !main.endOnDomOrgasm
		SetToggleOptionValue(setendonorgasm, main.endOnDomOrgasm)
	elseif option == setResetState
		main.resetState()
	elseif option == setRebuildDatabase
		debug.MessageBox("Close all menus and watch the console until it is done")
		main.getODatabase().initDatabase()
	elseif option == setActorSpeedControl
		main.enableActorSpeedControl = !main.enableActorSpeedControl
		SetToggleOptionValue(option, main.enableActorSpeedControl)	
	elseif option == setEnableBeds
		main.useBed = !main.useBed
		SetToggleOptionValue(option, main.usebed)
	elseif option == setUseRumble
		main.useRumble = !main.useRumble
		SetToggleOptionValue(option, main.useRumble)
	elseif option == setFlipFix
		main.fixFlippedAnimations = !main.fixFlippedAnimations
		SetToggleOptionValue(option, main.fixFlippedAnimations)
	elseif option == setUseScreenShake
		main.useScreenShake = !main.useScreenShake
		SetToggleOptionValue(option, main.useScreenShake)
	elseif option == setForceAIInConsensualScenes
		main.useAINonAggressive = !main.useAINonAggressive
		SetToggleOptionValue(option, main.useAINonAggressive)
	elseif option == setForceAIIfAttacked
		main.useAIPlayerAggressed = !main.useAIPlayerAggressed
		SetToggleOptionValue(option, main.useAIPlayerAggressed)	
	elseif option == setForceFirstPerson
		main.forceFirstPersonAfter = !main.forceFirstPersonAfter
		SetToggleOptionValue(option, main.forceFirstPersonAfter)	
	elseif option == setUseAutoFades
		main.useAutoFades = !main.useAutoFades
		SetToggleOptionValue(option, main.useAutoFades)	
	elseif option == setMute
		main.muteOSA = !main.muteOSA
		SetToggleOptionValue(option, main.muteOSA)	
	elseif option == setEndAfterActorHit
		main.endAfterActorHit = !main.endAfterActorHit
		SetToggleOptionValue(option, main.endAfterActorHit)	
	elseif option == setUseFreeCam
		main.useFreeCam = !main.useFreeCam
		SetToggleOptionValue(option, main.useFreeCam)
	elseif option == setUseCosaveWorkaround
		main.useBrokenCosaveWorkaround = !main.useBrokenCosaveWorkaround
		SetToggleOptionValue(option, main.useBrokenCosaveWorkaround)	
	elseif option == setForceAIIfAttacking
		main.useAIPlayerAggressor = !main.useAIPlayerAggressor
		SetToggleOptionValue(option, main.useAIPlayerAggressor)	
	elseif option == setUndressIfneed
		main.autoUndressIfNeeded = !main.autoUndressIfNeeded
		SetToggleOptionValue(option, main.autoUndressIfNeeded)	
	elseif option == setClipinglessFirstPerson
		main.enableImprovedCamSupport = !main.enableImprovedCamSupport
		SetToggleOptionValue(option, main.enableImprovedCamSupport)	
	elseif option == setAlwaysUndressAtStart
		main.alwaysUndressAtAnimStart = !main.alwaysUndressAtAnimStart
		SetToggleOptionValue(option, main.alwaysUndressAtAnimStart)	
	elseif option == setAIControl
		main.UseAIControl = !main.UseAIControl
		SetToggleOptionValue(option, main.UseAIControl)	
	elseif option == setAlwaysAnimateUndress
		main.alwaysAnimateUndress = !main.alwaysAnimateUndress
		SetToggleOptionValue(option, main.alwaysAnimateUndress)
	elseif option == setonlyUndressChest
		main.onlyUndressChest = !main.onlyUndressChest
		SetToggleOptionValue(option, main.onlyUndressChest)
	elseif option == setDomBar
		main.enableDomBar = !main.enableDomBar
		SetToggleOptionValue(option, main.enableDomBar)
	elseif option == setMisallignmentOption
		main.misallignmentProtection = !main.misallignmentProtection
		SetToggleOptionValue(option, main.misallignmentProtection)
	elseif option == setSubBar
		main.enableSubBar = !main.enableSubBar
		SetToggleOptionValue(option, main.enableSubBar)
	elseif option == setAutoHideBar
		main.autoHideBars = !main.autoHideBars
		SetToggleOptionValue(option, main.autoHideBars)
	elseif option == setSlowMoOrgasms
		main.slowMoOnOrgasm = !main.slowMoOnOrgasm
		SetToggleOptionValue(option, main.slowMoOnOrgasm)
	elseif option == setOrgasmBoostsRel
		main.orgasmIncreasesRelationship = !main.orgasmIncreasesRelationship
		SetToggleOptionValue(option, main.orgasmIncreasesRelationship)
	elseif option == setUseFades
		main.useFades = !main.useFades
		SetToggleOptionValue(option, main.useFades)
	elseif option == setOnlyLightInDark
		main.lowLightLevelLightsOnly = !main.lowLightLevelLightsOnly
		SetToggleOptionValue(option, main.lowLightLevelLightsOnly)
	endif
endevent

Event OnOptionHighlight(Int Option)
	;main.playTickSmall()
	if option == setEndOnOrgasm
		 SetInfoText("End the Osex scene automatically when the dominant actor (usually the male) orgasms")
	elseif option == setResetState
		SetInfoText("Click this if you keep getting a Scene Already Running type error")
	elseif option == setForceAIIfAttacked
		SetInfoText("If using manual mode by default, this will force automatic mode to activate if the player is the victim in an aggressive scene")
	elseif option == setForceAIIfAttacking
		SetInfoText("If using manual mode by default, this will force automatic mode to activate if the player is the attacker in an aggressive scene")
	elseif option == setForceAIInConsensualScenes
		SetInfoText("If using manual mode by default, this will force automatic mode to activate in consensual scenes")
	elseif option == setUseFades
		SetInfoText("Fade the screen to black when a scene starts/ends")
	elseif option == setUseCosaveWorkaround
		SetInfoText("Some users appear to have a broken SKSE co-save setup\n This manifests itself as full-auto mode not working, and keys not saving\nThis will fix the symptoms of the issue if you have it, but not the core cause")
	elseif option == setFreeCamFOV
		SetInfoText("The field of view of the camera when in freecam mode\nThis is incompatible with Improved Camera")
	elseif option == setUseRumble
		SetInfoText("Rumble a controller on thrust, if a controller is being used")
	elseif option == setEndAfterActorHit
		SetInfoText("End the scene after someone in the scene is hit\n Can misfire with certain other mods")
	elseif option == setForceFirstPerson
		SetInfoText("Return to first person after scene ends.\nFixes the hybrid-camera bug in Improved Camera")
	elseif option == setCustomTimescale
		SetInfoText("Changes the timescale during sex scenes, and reverts it back to what it was after the scene ends\nUseful if you don't want sex taking an entire day\n0 = this feature is disabled\nRequires ConsoleUtils")
	elseif option == setClipinglessFirstPerson
		 SetInfoText("REQUIRES: Improved Camera, my custom ini settings file\nExperience first person without any clipping")
	elseif option == setActorSpeedControl
		SetInfoText("Let actors increase the scene speed on their own when their Excitement gets high enough \nThis feature is experimental, disable if Osex behaves strangely on it's own")
	elseif option == setUndressIfneed
		SetInfoText("If actors' genitals are covered by clothes, this will auto-remove the clothes as soon as they need access to their genitals")
	elseif option == setBedSearchDistance
		SetInfoText("High values may increase animation start time")
	elseif option == setUseAutoFades
		SetInfoText("Fade to black in between animation transitions")
	elseif option == setFlipFix
		SetInfoText("Fix some third party animations being flipped 180 degrees")
	elseif option == setAlwaysUndressAtStart
		SetInfoText("Actors will always get undressed as a scene starts \nMods using this mod's API can force an undress to occur even if this isn't checked")
	elseif option == setAlwaysAnimateUndress
		SetInfoText("Always play Osex's undressing animations instead of just removing the clothes normally\nNote: that Auto-Remove clothes will never use Osex's undress animation\nFurther note: Mods using this mod's API can force an animation to occur even if this isn't checked")
	elseif option == setonlyUndressChest
		SetInfoText("Only remove the chest piece during undressing\nNote: due to bugginess with Osex, if using Undress Animation, only the chest piece is currently removed even with this not checked")
	elseif option == setDomBar
		SetInfoText("Enable the on-screen bar that track's the dominant actor's Excitement\nActor's orgasm when their Excitement maxes out")
	elseif option == setSubBar
		SetInfoText("Enable the on-screen bar that track's the second actor's Excitement\nActor's orgasm when their Excitement maxes out")
	elseif option == setMisallignmentOption
		SetInfoText("Enable automatic misalignment detection\nYou may want to disable this if you want to do some custom realigning.")
	elseif option == setEnableBeds
		SetInfoText("Actors will find the nearest bed to have sex on")
	elseif option == setAIControl
		SetInfoText("If enabled, scenes will play out on their own without user input via procedural generation\nNote: If you have only used Manual mode briefly or not at all, and never became adept with using it, I STRONGLY recommend you give manual mode a fair chance before using this")
	elseif option == setAutoHideBar
		SetInfoText("Automatically hide the bars during sex when not interacting with the UI")
	elseif option == setSlowMoOrgasms
		SetInfoText("Add in a few seconds of slowmotion right when the player orgasms\nUnrelated to this option, if sexlab is installed, cum effects and sound effects will be extracted and used from it as well\nA reinstall may be needed to detect sexlab if installed after this mod")
	elseif option == setOrgasmBoostsRel
		SetInfoText("Giving orgasms to actors you have a relationship rank of 0 with will increase them to rank 1, marking them as a friend\nThis may open up unique options in some mods")
	elseif (option == setdomlightmode)
		SetInfoText("Enable light on main actor at animation start")
	elseif (option == setMute)
		SetInfoText("Mute sounds coming from the OSA engine\nYou should probably only disable this if you have a soundpack installed")
	elseif (option == setSubLightMode)
		SetInfoText("Enable light on second actor at animation start")
	elseif (option == setCameraSpeed)
		SetInfoText("The speed of the freecam")
	elseif (option == setUseFreeCam)
		SetInfoText("Automatically switch to freecam when a scene starts\nRequires ConsoleUtils")
	elseif (option == setDefaultFOV)
		SetInfoText("The field of view to return to when a scene ends when using free cam")
	elseif (option == setDomLightBrightness)
		SetInfoText("Set main actor's light's brightness")
	elseif (option == setSubLightBrightness)
		SetInfoText("Set second actor's light's brightness")
	elseif (option == setControlToggle)
		SetInfoText("Press during an animation: switch between manual and full-auto control for the duration of that animation \n Press outside of animation: switch between manual and full-auto control permanently")
	elseif (option == setOnlyLightInDark)
		SetInfoText("Only use actor lights when the scene takes place in a dark area")
	elseif (option == setRebuildDatabase)
		SetInfoText("This will rebuild OStim's internal animation database.\n You only need to click this if you have installed or uninstalled an animation pack MID-playthrough\n The animation database is automatically built at the start of a new playthrough")
	elseif option == setsexExcitementMult
		SetInfoText("Multiply all the pleasure/second received by actors by this amount\nThis effectively lets you choose how long you want sex to last\n3.0 = 3 times shorter, 0.1 = 10 times longer")
	elseif option == setKeymap
		SetInfoText("Press this while looking at an actor to start OStim.\nStarting OSex through OSA will result in normal OSex instead\nOStim is intended to be played with mods that integrate it into the game instead of using this option")
	elseif option == setKeyUp
		SetInfoText("Increase speed during OStim scene\nThe default key (numpad +) conflicts with many mods, may need to remap")
	elseif option == setKeyDown
		SetInfoText("Decrease speed during OStim scene\nThe default key (numpad -) conflicts with many mods, may need to remap")
	elseif option == setUseScreenShake
		SetInfoText("Use extra screenshake on thrust\n This is not compatible with Improved Camera's first person") 
	elseif option == setBedReallignment
		SetInfoText("Move actors forward/back by this amount on a bed") 
	elseif option == setPullOut
		SetInfoText("Only usable in manual mode\nWhen pressed during a sexual animation, causes your character to immediately cancel and \"pull out\" of the current animation")
	elseif option == setThanks
		SetInfoText("Thank you for downloading OStim\nLeave a comment and also share it with others online if you enjoy it, to help others find it")
	endif
EndEvent

event OnOptionMenuOpen(int option)
	main.playTickBig()
	if (option == setdomlightmode)
		SetMenuDialogOptions(domlightmodelist)
		;SetMenuDialogStartIndex(difficultyIndex)
		;SetMenuDialogDefaultIndex(1)
	elseif (option == setSubLightMode)
		SetMenuDialogOptions(subLightModeList)

	elseif (option == setDomLightBrightness)
		SetMenuDialogOptions(domLightBrightList)

	elseif (option == setSubLightBrightness)
		SetMenuDialogOptions(subLightBrightList)
	endIf
endEvent

event OnOptionMenuAccept(int option, int index)
	main.playTickBig()
	if (option == setdomlightmode)
		main.domlightpos = index
		SetMenuOptionValue(setdomlightmode, domlightmodelist[index])
	elseif (option == setSubLightMode)
		main.sublightpos = index
		SetMenuOptionValue(option, sublightmodelist[index])

	elseif (option == setDomLightBrightness)
		main.domLightBrightness = index
		SetMenuOptionValue(option, domLightBrightList[index])

	elseif (option == setSubLightBrightness)
		main.subLightBrightness = index
		SetMenuOptionValue(option, subLightBrightList[index])

	endIf
endEvent

event OnOptionSliderOpen(int option)
	main.playTickBig()
	if (option == setsexExcitementMult)
		SetSliderDialogStartValue(main.sexExcitementMult)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 3.0)
		SetSliderDialogInterval(0.1)
	elseif (option == setBedSearchDistance)
		SetSliderDialogStartValue(main.bedSearchDistance)
		SetSliderDialogDefaultValue(15.0)
		SetSliderDialogRange(1, 30)
		SetSliderDialogInterval(1)
	elseif (option == setCustomTimescale)
		SetSliderDialogStartValue(main.customTimescale)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(0, 40)
		SetSliderDialogInterval(1)
	elseif (option == setFreeCamFOV)
		SetSliderDialogStartValue(main.freecamFOV)
		SetSliderDialogDefaultValue(45.0)
		SetSliderDialogRange(1, 120)
		SetSliderDialogInterval(1)
	elseif (option == setDefaultFOV)
		SetSliderDialogStartValue(main.defaultFOV)
		SetSliderDialogDefaultValue(85.0)
		SetSliderDialogRange(1, 120)
		SetSliderDialogInterval(1)
	elseif (option == setCameraSpeed)
		SetSliderDialogStartValue(main.freecamSpeed)
		SetSliderDialogDefaultValue(3.0)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	elseif (option == setBedReallignment)
		SetSliderDialogStartValue(main.bedReallignment)
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-250, 250)
		SetSliderDialogInterval(1)
	endIf
endEvent

event OnOptionSliderAccept(int option, float value)
	main.playTickBig()
	if (option == setsexExcitementMult)
		main.sexExcitementMult = value
		SetSliderOptionValue(setsexExcitementMult, value, "{2} x")
	elseif (option == setBedSearchDistance)
		main.bedSearchDistance = (value as int)
		SetSliderOptionValue(option, value, "{0} meters")
	elseif (option == setCustomTimescale)
		main.customTimescale = (value as int)
		SetSliderOptionValue(option, value, "{0}")
	elseif (option == setFreeCamFOV)
		main.freecamFOV = (value as int)
		SetSliderOptionValue(option, value, "{0}")
	elseif (option == setDefaultFOV)
		main.defaultFOV = (value as int)
		SetSliderOptionValue(option, value, "{0}")
	elseif (option == setCameraSpeed)
		main.freecamSpeed = (value as int)
		SetSliderOptionValue(option, value, "{0}")
	elseif (option == setBedReallignment)
		main.bedReallignment = (value as int)
		SetSliderOptionValue(option, value, "{0} units")
	endIf
endEvent


event OnOptionKeyMapChange(int option, int keyCode, string conflictControl, string conflictName)
	main.playTickBig()
	if (option == setkeymap)
		main.remapStartKey(keycode)
		SetKeyMapOptionValue(option, keycode)
	elseif (option == setKeyUp)
		main.remapSpeedUpKey(keycode)
		SetKeyMapOptionValue(option, keycode)
	elseif (option == setKeyDown)
		main.remapSpeedDownKey(keycode)
		SetKeyMapOptionValue(option, keycode)
	elseif (option == setPullOut)
		main.remapPulloutKey(keycode)
		SetKeyMapOptionValue(option, keycode)
	elseif (option == setControlToggle)
		main.remapControlToggleKey(keycode)
		SetKeyMapOptionValue(option, keycode)
	endIf
endEvent

event OnGameReload()
	
	parent.OnGameReload()
endEvent

bool color1
function addColoredHeader(string in)
	string blue = "#6699ff"
	string pink = "#ff3389"
	string color
	if color1
		color = pink
		color1 = false
	else
		color = blue
		color1 = true
	endif

	AddHeaderOption("<font color='" + color +"'>" + in)
EndFunction

