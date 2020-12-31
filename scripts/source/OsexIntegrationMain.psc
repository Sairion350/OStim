ScriptName OsexIntegrationMain extends Quest


;code spacing is a mess right now after 2.0
;--------- Settings
	bool property endOnDomOrgasm auto

	bool property enableDomBar auto
	bool property enableSubBar auto
	bool property autoHideBars auto
	bool property enableImprovedCamSupport auto

	bool property enableActorSpeedControl auto

	bool property allowUnlimitedSpanking auto

	bool property autoUndressIfNeeded auto
	int property bedSearchDistance auto

	int property subLightPos auto
	int property domLightPos auto
	int property subLightBrightness auto
	int property domLightBrightness auto

	bool property lowLightLevelLightsOnly auto
	bool property slowMoOnOrgasm auto

	bool property alwaysUndressAtAnimStart auto
	bool property onlyUndressChest auto
	bool property alwaysAnimateUndress auto

	bool  speedUpNonSexAnimation 
	float speedUpSpeed

	int property customTimescale Auto

	bool property orgasmIncreasesRelationship auto

	float property sexExcitementMult auto

	int property keyMap auto

	int property speedUpKey auto
	int property speedDownKey auto
	int property PullOutKey auto
	int property ControlToggleKey auto

	bool property useBed auto

	bool property misallignmentProtection auto

	bool property UseAIControl auto
	bool property pauseAI auto

	bool property useAINPConNPC auto
	bool property useAIPlayerAggressor auto
	bool property useAIPlayerAggressed auto
	bool property useAINonAggressive auto

	bool property muteOSA Auto

	bool property fixFlippedAnimations auto

	bool property useFreeCam auto

	bool property useRumble Auto
	bool property useScreenShake auto

	bool property useFades auto
	bool property useAutoFades auto

	bool property endAfterActorHit auto

	bool property getInBedAfterBedScene auto

	int property freecamFOV Auto
	int property defaultFOV Auto
	int property freecamSpeed auto
	
	int property bedReallignment auto

	bool property forceFirstPersonAfter auto

	bool property useNativeFunctions auto
;---------

;--------- scriptwide Variables are stored here so they can be used async
actor DomActor
actor SubActor

float DomExcitement
float SubExcitement

bool sceneRunning
string currentAnimation
int currentSpeed
string[] currScene
string currAnimClass

bool animSpeedAtMax
int spankCount
int spankMax

_oOmni OSAOmni

actor playerref

GlobalVariable timescale

bool undressDom
bool undressSub
bool animateUndress
string startingAnimation
actor thirdActor

form domHelm
form domArmor
form domGlove
form domBoot
form domWep

form subHelm
form subArmor
form subGlove
form subBoot
form subWep

bool isFreeCamming

int domTimesOrgasm
int subTimesOrgasm

actor mostRecentOrgasmedActor

bool usingBed
ObjectReference currentBed

bool endedProper

float startTime

float mostRecentOSexInteractionTime

int[] OSexControlKeys
;--Thank you ODatabase
int currentOID ; the OID is the JMap ID of the current animation. You can feed this in to ODatabase
int lastHubOID
bool currentAnimIsAggressive
;--
bool aiRunning

bool aggressiveThemedSexScene
actor aggressiveActor

OAiScript AI

bool isFlipped
;---------

;--------- Osa specific stuff and more
MagicEffect Actra
faction OsaFactionStage

faction ArousedFaction
ImageSpaceModifier NutEffect

Quest sexlab ;for cum effects
sound orgasmSound

sound OsaDing
sound OsaTickSmall
sound OsaTickBig

;_oUI OSAUI
;---------

;--------- bars
Osexbar dombar
Osexbar subbar
;---------

;--------- database
ODatabaseScript ODatabase
;---------
;--------- ID shortcuts
	;Animation classifications
	string ClassSex
	string ClassEmbracing
	string ClassCunn
	String ClassHolding
	string ClassApart
	string ClassApartUndressing
	string ClassApartHandjob
	string ClassHandjob
	string ClassClitRub
	string ClassOneFingerPen
	string ClassTwoFingerPen
	string ClassBlowjob
	string ClassPenisjob
	string ClassMasturbate
	string ClassRoughHolding
	string ClassSelfSuck
	string ClassHeadHeldBlowjob
	string ClassHeadHeldPenisjob
	string ClassHeadHeldMasturbate
	string ClassDualHandjob
	string Class69Blowjob
	string Class69Handjob

	string ClassAnal
	string ClassBoobjob 
	string ClassBreastFeeding
	string ClassFootjob

	;Body parts
	int penis
	int vagina 
	int mouth
	int hand
	int clit
	;extra parts
	int anus
	int feet
	int breasts
	int prostate

	float[] penisStimValues
	float[] vaginaStimValues
	float[] mouthStimValues
	float[] handStimValues
	float[] clitStimValues

	float[] anusStimValues
	float[] feetStimValues
	float[] breastsStimValues
	float[] prostateStimValues

	string[] speeds
;--------- 

Event OnKeyDown(int KeyPress)
	if Utility.IsInMenuMode()
		Return
	endif

	if animationRunning()
		if IntArrayContainsValue(OSexControlKeys, keypress)
			mostRecentOSexInteractionTime = Utility.GetCurrentRealTime()
			if autoHideBars
				if !isBarVisible(dombar)
					setBarVisible(dombar, true)
				endif
				if !isBarVisible(subbar)
					setBarVisible(subbar, true)
				endif
			endif
		endif

		if KeyPress == speedUpKey
			increaseAnimationSpeed()
			playTickSmall()
		elseif KeyPress == speedDownKey
			decreaseAnimationSpeed()
			playTickSmall()
		elseif (KeyPress == PullOutKey) && !aiRunning
			if ODatabase.isSexAnimation(currentoid)
				if lastHubOID != -1
					travelToAnimationIfPossible(odatabase.getSceneID(lastHubOID))
				endif
			endif
		endif
	endif

	if (KeyPress == ControlToggleKey)
		if animationRunning()
			if aiRunning
				aiRunning = False
				pauseAI = true
				Debug.Notification("Switched to manual control mode")
				console("Switched to manual control mode")
			Else
				if pauseAI
					pauseAI = False
				Else
					AI.startAI()
				endif
				aiRunning = true
				debug.Notification("Switched to automatic control mode")
				console("Switched to automatic control mode")
			endif
		Else
			if UseAIControl
				UseAIControl = False
				Debug.Notification("Switched to manual control mode")
				console("Switched to manual control mode")
			Else
				UseAIControl = True
				debug.Notification("Switched to automatic control mode")
				console("Switched to automatic control mode")
			endif
		endif
		playTickBig()
	endif

	actor target = Game.GetCurrentCrosshairRef() as actor
	if KeyPress == keymap
		if target.IsInDialogueWithPlayer()
			Return
		endif
		if target && !target.isdead()
			StartScene(playerref,  target)
		endif
	endif
endevent


Event OnInit()
	startup()
EndEvent

function startup()
	Debug.Notification("Installing OStim. Please wait...")
	sceneRunning = false
	actra = game.GetFormFromFile(0x000D63, "OSA.ESM") as MagicEffect
	OsaFactionStage = game.GetFormFromFile(0x00182F, "OSA.ESM") as faction
	osaomni = (Quest.GetQuest("0SA") as _oOmni)
;	OSAUI = (Quest.GetQuest("0SA") as _oui)
	playerref = game.GetPlayer()
	NutEffect = game.GetFormFromFile(0x000805, "Ostim.esp") as ImageSpaceModifier
	
	OsaDing = game.GetFormFromFile(0x000D6D, "Ostim.esp") as sound
	OsaTickSmall = game.GetFormFromFile(0x000D6E, "Ostim.esp") as sound
	OsaTickBig = game.GetFormFromFile(0x000D6F, "Ostim.esp") as sound

	if (Game.GetModByName("SexLab.esm") != 255) 
		sexlab = (Game.GetFormFromFile(0x00000D62, "SexLab.esm")) as Quest
		orgasmSound = (Game.GetFormFromFile(0x00065A34, "SexLab.esm")) as sound
	endif
	if (Game.GetModByName("SexlabAroused.esm") != 255) 
		ArousedFaction = Game.GetFormFromFile(0x0003FC36, "SexlabAroused.esm") as faction
	endif 

	dombar = (self as quest) as Osexbar
	subbar = (game.GetFormFromFile(0x000804, "Ostim.esp")) as Osexbar
	timescale = (game.GetFormFromFile(0x00003A, "Skyrim.esm")) as GlobalVariable
	initBar(dombar, true)
	initBar(subbar, false)

	ai = ((self as quest) as OAiScript)
	RegisterForModEvent("ostim_actorhit", "OnActorHit")
	setSystemVars()
	setDefaultSettings()
	BuildSoundFormlists()

	ODatabase = (self as quest) as ODatabaseScript

	ODatabase.initDatabase()

	if OsaFactionStage
		console("Loaded")
	else
		debug.MessageBox("Osex and OSA do not appear to be installed, please do not continue using this save file")
		return
	endif

	if ArousedFaction
		console("Sexlab Aroused loaded")
	endif

	if sexlab
		console("Sexlab loaded, using its cum effects")
	Else
		debug.Notification("OStim: Sexlab is not loaded. Some orgasm FX will be missing")
	endif

	if osa.stimInstalledProper() == True
		console("Osa is installed correctly")

	Else
		debug.MessageBox("OStim is not loaded after OSA in your mod files, please allow OStim to overwrite OSA's files and restart")
		return
	endif

	if _oGlobal.OStimGlobalLoaded() != True
		Debug.MessageBox("It appears you have the OSex facial expression fix installed. Please exit and remove that mod, as it is now included in OStim, and having it installed will break some things now!")
	endif

	
	
	DisplayTextBanner("OStim installed")
endfunction
actor reroutedDomActor
actor reroutedSubActor
function acceptReroutingActors(actor act1, actor act2)
	reroutedDomActor = act1
	reroutedSubActor = act2
	console("Recieved rerouted actors")
endfunction

function startReroutedScene()
	console("Rerouting scene")
	StartScene(reroutedDomActor,  reroutedSubActor)
endfunction

bool function StartScene(actor Dom, actor Sub, bool zundressDom = false, bool zundressSub = false, bool zanimateUndress = false, string zstartingAnimation = "", actor zthirdActor = none, objectreference bed = none, bool aggressive = false, actor aggressingActor = none)
	if sceneRunning
		debug.Notification("Osex scene already running")
		return false
	endif

	
	DomActor = dom
	SubActor = sub


	if appearsFemale(dom) && !appearsFemale(sub) ;if the dom is female and the sub is  male
		DomActor = sub
		SubActor = dom
	Else
		DomActor = dom
		SubActor = sub
	endif

	undressDom = zundressDom
	undresssub = zundressSub
	animateUndress = zanimateUndress
	startingAnimation = zstartingAnimation
	thirdActor = zthirdActor
	pauseAI = false

	if aggressive
		if aggressingActor
			if (aggressingActor != SubActor) && (aggressingActor != DomActor)
				debug.MessageBox("Programmer:  The aggressing actor you entered is not part of the scene!")
				return false
			Else
				aggressiveActor = aggressingActor
				aggressiveThemedSexScene = true
			endif
		Else
			debug.MessageBox("Programmer: Please enter the aggressor in this aggressive animation")
			return false
		endif
	Else
		aggressiveThemedSexScene = False
		aggressingActor = none
	endif

	if bed
		usingbed = True
		currentbed = bed
	Else
		usingBed = false
	endif

	console("Requesting scene start")
	RegisterForSingleUpdate(0.01)
	sceneRunning = true

	return true
EndFunction

Event OnUpdate()
	console("Starting scene asynchronously")

	if useFades && ((domactor == playerref) || (SubActor == playerref))
		float time = 1.25
		game.FadeOutGame(true, true, 0.0, time)
		utility.Wait(time - 0.25)
		game.FadeOutGame(false, true, 25.0, 25.0) ;total blackout
	endif

	if enableImprovedCamSupport
			game.DisablePlayerControls(abcamswitch = true, abMenu = false, abFighting = false, abActivate = false, abMovement = false, aiDisablePOVType = 0)
	endif
	int oldtimescale = 0
	if customTimescale >= 1
		oldtimescale = getTimeScale()
		setTimeScale(customTimescale)
		console("Using custom timescale: " + customTimescale)
	endif
	
	 

	isFlipped = false
	currentSpeed = 0
	DomExcitement = 0.0
	SubExcitement = 0.0
	endedProper = false
	spankCount = 0
	subTimesOrgasm = 0
	domTimesOrgasm = 0
	mostRecentOrgasmedActor = none
	spankMax = Utility.RandomInt(1, 6)
	isFreeCamming = false
	if !UseAIControl
		aiRunning = false
	Else
		aiRunning = true
	endif

	Actor[] actro
	if thirdActor
		actro  = New Actor[3]
		actro[2] = thirdActor
	else 
		actro  = New Actor[2]
	endif
	RegisterForModEvent("0SSO"+_oGlobal.GetFormID_s(domactor.GetActorBase())+"_Sound", "OnSoundDom")
	RegisterForModEvent("0SSO"+_oGlobal.GetFormID_s(subactor.GetActorBase())+"_Sound", "OnSoundSub")


	if thirdActor
		RegisterForModEvent("0SSO"+_oGlobal.GetFormID_s(thirdActor.GetActorBase())+"_Sound", "OnSoundThird")
	endif
	
	actro[0] = domActor
	actro[1] = subActor
	
	if !usingBed && useBed
		currentbed = FindBed(domactor, Radius = 1000.0)
		if currentBed
			usingBed = true
		endif
	endif
	float domX 
	float domY
	float domZ
	float subX
	float subY
	float subZ

	if usingBed
		domX = DomActor.X
		domY = DomActor.Y
		domZ = DomActor.Z

		subX = SubActor.X
		subY = SubActor.Y
		subZ = SubActor.Z
	EndIf

	if usingBed
		allignActorsWithCurrentBed()
		if startingAnimation == ""
			startingAnimation = "0MF|KNy6!KNy6|Ho|KnLap"
		endif
	endif

	if startingAnimation == ""
		startingAnimation = "AUTO"
	endif
    currScene = osa.makeStage()
    osa.setActorsStim(currScene, actro)
    osa.setModule(currScene, "0Sex", startingAnimation, "")

    osa.stimstart(currScene)

    currentAnimation = "0Sx0MF_Ho-St6RevCud+01T180"
    lastHubOID = -1 
    OnAnimationChange()

    
    if (lowLightLevelLightsOnly && DomActor.GetLightLevel() < 20) || (!lowLightLevelLightsOnly)
    	if domLightPos > 0
    		lightActor(domactor, domLightPos, domLightBrightness)
   		EndIf
    	if subLightPos > 0
    		lightActor(subactor, subLightPos, subLightBrightness)
   		endif
    endif

    if enableDomBar
    	setBarPercent(dombar, 0.0)
    	setBarVisible(dombar, true)
	endif
	if enableSubBar
		setBarPercent(subbar, 0.0)
    	setBarVisible(subbar, true)
	endif

	int password = DomActor.GetFactionRank(OsaFactionStage)
	RegisterForModEvent("0SAO"+Password+"_AnimateStage", "OnAnimate")

	

	if getActorArousal(DomActor) > 90
		DomExcitement = 26.0
	EndIf
	if getActorArousal(SubActor) > 90
		SubExcitement = 26.0
	EndIf

	if alwaysUndressAtAnimStart
		undressDom = True
		undressSub = true
	endif

	if alwaysAnimateUndress
		animateUndress = True
	endif

	if useFreeCam
		toggleFreeCam(true)
	endif


	domArmor = domactor.GetWornForm(0x00000004)
	domHelm = domactor.GetWornForm(0x00000002)
	domGlove = domactor.GetWornForm(0x00000080)
	domBoot = domactor.GetWornForm(0x00000008)
	domWep = domactor.GetEquippedObject(1)

	subArmor = subactor.GetWornForm(0x00000004)
	subHelm = subactor.GetWornForm(0x00000002)
	subGlove = subactor.GetWornForm(0x00000080)
	subBoot = subactor.GetWornForm(0x00000008)
	subWep = subactor.GetEquippedObject(1)
	if undressDom
		if animateUndress
			if onlyUndressChest 
				animateUndressActor(domactor, "cuirass")
			Else ; cuirass,boots,weapon,helmet,gloves. 
			;	animateUndressActor(domactor, "helmet")
			;	animateUndressActor(domactor, "gloves")
			;	animateUndressActor(domactor, "weapon")
				;animateUndressActor(domactor, "boots")
				
				animateUndressActor(domactor, "cuirass")
				undressActor(domActor, domhelm)
				undressActor(domActor, domboot)
				undressActor(domActor, domGlove)
				domactor.UnequipItem(domwep, abPreventEquip = false, abSilent = true)
			endif
			
		Else
			if onlyUndressChest
				undressActor(domActor, domArmor)
			else
				undressActor(domActor, domhelm)
				undressActor(domActor, domboot)
				undressActor(domActor, domGlove)
				undressActor(domActor, domArmor)
				domactor.UnequipItem(domwep, abPreventEquip = false, abSilent = true)
			endif
		endif
	EndIf

	if undressSub
		if animateUndress
			if onlyUndressChest 
				animateUndressActor(subactor, "cuirass")
			Else
			;	animateUndressActor(subactor, "helmet")
				;animateUndressActor(subactor, "gloves")
				;animateUndressActor(subactor, "weapon")
				;animateUndressActor(subactor, "boots")
				
				animateUndressActor(subactor, "cuirass")
				undressActor(subActor, subhelm)
				undressActor(subActor, subboot)
				undressActor(subActor, subGlove)
				subactor.UnequipItem(subwep, abPreventEquip = false, abSilent = true)
			endif
			
		Else
			if onlyUndressChest
				undressActor(subActor, subArmor)
			Else
				undressActor(subActor, subhelm)
				undressActor(subActor, subboot)
				undressActor(subActor, subGlove)
				undressActor(subActor, subArmor)
				subactor.UnequipItem(subwep, abPreventEquip = false, abSilent = true)
			endif
		endif
	endif


	startTime = utility.getcurrentrealtime()
	
	bool waitForActorsTouch = (SubActor.GetDistance(domactor) > 1)
	int waitCycles = 0
	while waitForActorsTouch 
		Utility.Wait(0.1)
		waitCycles += 1
		waitForActorsTouch = (SubActor.GetDistance(domactor) > 1)

		if waitCycles > 50
			waitForActorsTouch = false
		endif
	EndWhile
	
	float loopTimeTotal = 0
	float loopStartTime
	SendModEvent("ostim_start")

	if !aiRunning

		if (DomActor != playerref) && (SubActor != playerref) && (thirdActor != playerref) && useAINPConNPC
			console("NPC on NPC scene detected. Starting AI")
			AI.startAI()
			aiRunning = true
		elseif (aggressiveActor == playerref) && useAIPlayerAggressor
			console("Player aggressor. Starting AI")
			AI.startAI()
			aiRunning = true
		elseif (aggressiveActor == getSexPartner(playerref)) && useAIPlayerAggressed
			console("Player aggressed. Starting AI")
			AI.startAI()
			aiRunning = true
		elseif useAINonAggressive
			console("Non-aggressive scene. Starting AI")
			AI.startAI()
			aiRunning = true
		endif
	endif

	if useFades && ((domactor == playerref) || (SubActor == playerref))
		game.FadeOutGame(false, true, 0.0, 4) ;welcome back
	EndIf

	while isActorActive(domactor)
		if loopTimeTotal > 1
			;console("Loop took: " + loopTimeTotal + " seconds")
			loopTimeTotal = 0
		endif
		Utility.wait(1.0 - loopTimeTotal)
		loopStartTime = utility.getcurrentrealtime()

    	if autoUndressIfNeeded
    		UndressIfNeeded()
    	endif

    	if misallignmentProtection && isActorActive(domactor)
    		if SubActor.GetDistance(domactor) > 1
    			console("Misallignment detected")
    			SubActor.MoveTo(domactor)
    			
    			;warpToAnimation(ODatabase.getSceneIDByAnimID(currentAnimation))
    			;warpToAnimation("0MF|Cy6!DOy6|Ho|DoggyLi")
    			reallign()

    			utility.wait(0.1)
    			while (SubActor.GetDistance(domactor) > 1) && isActorActive(domactor)
    				Utility.Wait(0.5)
    				console("Still misalligned... " + SubActor.GetDistance(domactor))
    				reallign()
    			EndWhile
    			console("Realligned")
    		endif
    	endif

    	if autoHideBars && (getTimeSinceLastPlayerInteraction() > 15.0) ;fade out if needed
    		if isBarVisible(dombar)
    			setBarVisible(dombar, false)
    		endif
    		if isBarVisible(subbar)
    			setBarVisible(subbar, false)
    		endif
    	endif
    	
    	if enableActorSpeedControl && !animationIsAtMaxSpeed()
    		autoIncreaseSpeed()
    	EndIf

		DomExcitement += getCurrentStimulation(DomActor)
		SubExcitement += getCurrentStimulation(SubActor)

		setbarpercent(dombar, DomExcitement)
		setbarpercent(subbar, SubExcitement)

		if SubExcitement >= 100.0
			mostRecentOrgasmedActor = SubActor
			subTimesOrgasm += 1
			orgasm(SubActor)
			if getCurrentAnimationClass() == ClassSex
				DomExcitement += 5
			EndIf
		endif

		if DomExcitement >= 100.0
			mostRecentOrgasmedActor = DomActor
			domTimesOrgasm += 1
			orgasm(DomActor)
			if endOnDomOrgasm
				Utility.Wait(4)
				endAnimation()
			endif
		endif

		;console("Dom excitement: " + DomExcitement)
		;console("Sub excitement: " + SubExcitement)
		loopTimeTotal = utility.getcurrentrealtime() - loopStartTime
	EndWhile


	console("Ending scene")

	


	SendModEvent("ostim_end")
	if enableImprovedCamSupport
		game.EnablePlayerControls(abcamswitch = true)
	endif
	ODatabase.unload() 
	if fixFlippedAnimations
		SubActor.SetDontMove(false)
		DomActor.SetDontMove(false)
	endif
	if isFreeCamming
		toggleFreeCam(false)
	endif
	if forceFirstPersonAfter && ((domactor == playerref) || (SubActor == playerref))
		game.ForceFirstPerson()
	endif
	Utility.Wait(0.5)

	redress()
	
	setBarVisible(dombar, false)
	setBarPercent(dombar, 0.0)
	setBarVisible(subbar, false)
	setBarPercent(subbar, 0.0)

	
	

	if usingBed
		
		if getInBedAfterBedScene && ((domactor == playerref) || (SubActor == playerref))  && endedProper && !IsSceneAggressiveThemed()
			actor other = getSexPartner(playerref)
			other.TranslateTo(subx, suby, subz, subactor.getangleX(), subactor.getangleY(), subactor.getangleZ(), 1000)
			Utility.Wait(0.5)
			sleepInBed(currentbed, playerref) ;todo
		ElseIf  !isBedRoll(currentbed) ;return back to position
			subactor.TranslateTo(subx, suby, subz, subactor.getangleX(), subactor.getangleY(), subactor.getangleZ(), 10000)
			domactor.TranslateTo(domx, domy, domz, domactor.getangleX(), domactor.getangleY(), domactor.getangleZ(), 10000)
			Utility.Wait(0.1)
		endif
	endif

	if useFades && endedProper && ((domactor == playerref) || (SubActor == playerref))
		game.FadeOutGame(false, true, 0.0, 2) ;welcome back
	EndIf
	
	UnRegisterForModEvent("0SAO"+Password+"_AnimateStage")
	unRegisterForModEvent("0SSO"+_oGlobal.GetFormID_s(domactor.GetActorBase())+"_Sound")
	unRegisterForModEvent("0SSO"+_oGlobal.GetFormID_s(subactor.GetActorBase())+"_Sound")
	if thirdActor
		unRegisterForModEvent("0SSO"+_oGlobal.GetFormID_s(thirdActor.GetActorBase())+"_Sound")
	endif
	if oldtimescale > 0
		console("Resetting timescale to: " + oldtimescale)
		setTimeScale(oldtimescale)
	endif

	console(utility.getcurrentrealtime() - starttime + " seconds passed")
	sceneRunning = false
EndEvent



;
;			██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
;			██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
;			╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
;			 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝                                                        
;
;				The main API functions


bool function isActorActive(actor act)
	return act.HasMagicEffect(actra)
EndFunction

ODatabaseScript function getODatabase()
	while odatabase == none
		Utility.Wait(0.5)
	endwhile
	return ODatabase
endfunction

int function getCurrentAnimationSpeed()
	return currentSpeed
EndFunction

bool function animationIsAtMaxSpeed() 
	return currentSpeed == getCurrentAnimationMaxSpeed() 
endfunction

int function getCurrentAnimationMaxSpeed()
	return ODatabase.getMaxSpeed(currentoid)
endfunction

int function getAPIVersion()
	;6 adds better animation flipping, reallign(), soundAPI
	;5 adds ODatabase, getCurrentLeadingActor
	;4 added onanimationchange event and decrease speed
	;3 introduces events and getmostrecentorgasmedactor
	return 6
endfunction

function increaseAnimationSpeed()
	if animSpeedAtMax
		Return
	endif
	setCurrentAnimationSpeed(currentSpeed + 1)
endfunction

function decreaseAnimationSpeed()
	if currentSpeed < 1
		Return
	endif
	setCurrentAnimationSpeed(currentSpeed - 1)
endfunction

function setCurrentAnimationSpeed(int inspeed) ;untested
	string speed = normalSpeedToOsexSpeed(inspeed)
	runOsexCommand("$Speed,0," + speed)
	Utility.Wait(0.5)
	
	if getCurrentAnimation() == "undefined"
		console("Speed increase broke game state")
		runOsexCommand("$Speed,0,1") 
	endif
EndFunction

string function getCurrentAnimation()
	return currentAnimation
EndFunction

string function getCurrentAnimationClass()
	return currAnimClass
endfunction

int function getCurrentAnimationOID()
	; the OID is the JMap ID of the current animation. You can feed this in to ODatabase
	return currentOID
endfunction

function lightActor(actor act, int pos, int brightness) ;pos 1 - ass, pos 2 - face | brightness - 0 = dim
	string which
	if pos == 0
		Return
	endif
	if pos == 1 ; ass
		if brightness == 0
			which = "AssDim"
		Else
			which = "AssBright"
		endif
	elseif pos == 2 ;face
		if brightness == 0
			which = "FaceDim"
		Else
			which = "FaceBright"
		endif
	endif
	_oGlobal.ActorLight(act, which, osaomni.OLightSP, osaomni.OLightME)
endfunction

function travelToAnimationIfPossible(string animation) ;travel to animation is BUSTED beyond belief and even this doesn't fix it
	int id = ODatabase.getAnimationsWithSceneID(odatabase.getDatabaseOArray(), animation)
	id = ODatabase.getObjectOArray(id, 0)
	bool transitory = ODatabase.isTransitoryAnimation(id)
	if transitory
		warptoanimation(animation)
	Else
		traveltoanimation(animation)

		bool useCatch = True
		if usecatch
			string lastanimation
			string lastlastanimation
			string current = currentAnimation
			while ODatabase.getSceneIDByAnimID(currentAnimation) != animation
				Utility.Wait(1)

				if current != currentAnimation
					lastlastanimation = lastanimation
					lastanimation = current
					current = currentAnimation

					if current == lastlastanimation
						console("Infinite loop during travel detected. Warping")
						warpToAnimation(animation)
					endif
				endif
			EndWhile
		endif
	endif
EndFunction

function travelToAnimation(string animation) ;does not always work, use above
	console("Attempting travel to: " + animation)
	runOsexCommand("$Go," + animation)
EndFunction

function warpToAnimation(string animation) ; a list of animation ids can be found in osa's xmls. you cannot use the id from getcurrentanimation()
	console("Warping to animation: " + animation)
	runOsexCommand("$Warp," + animation)
EndFunction

function endAnimation(bool smoothEnding = true)
	if useFades && smoothEnding && ((domactor == playerref) || (SubActor == playerref))
		float time = 1
		game.FadeOutGame(true, true, 0.0, time)
		utility.Wait(time - 0.15)
		game.FadeOutGame(false, true, 25.0, 25.0) ;total blackout
	endif
	endedProper = smoothEnding
	console("Trying to end scene")
	runOsexCommand("$endscene")
	;OSA.oGlyphO(".ctr.END")
EndFunction

bool function getCurrentAnimIsAggressive() ;if the current animation is tagged aggressive
	return currentAnimIsAggressive
endfunction

bool function IsSceneAggressiveThemed() ; if the entire situation should be themed aggressively 
	return aggressiveThemedSexScene
EndFunction

actor function getAggressiveActor()
	return aggressiveactor
endfunction

function undressAll(actor act) ; seems broke
	int acto
	if act == DomActor
		acto = 0
	else 
		acto = 1
	endif
	runOsexCommand("$Equndressall," + acto)
endfunction

function redressAll(actor act) ; seems broke
	int acto
	if act == DomActor
		acto = 0
	else 
		acto = 1
	endif

	runOsexCommand("$Eqredressall," + acto) ; seems broke
endfunction

function undressActor(actor char, form item)
	char.UnequipItem(item, false, true)
endfunction

function animateUndressActor(actor char, string item); cuirass,boots,weapon,helmet,gloves. 
	;some extra rare options: cape,intlow(i.e. panties),inthigh(i.e. bra),miscarms,misclow,miscmid,miscup,pants,stockings,
	;options other than cuirass are unreliable right now

	string target
	if item == "helmet" ; 
		if !char.GetWornForm(0x00000002) as armor
			Return
		endif
	elseif item == "gloves"
		if !char.GetWornForm(0x00000008) as armor
			Return
		endif
	elseif item == "weapon"
		if !char.GetEquippedObject(1) as form
			Return
		endif
	elseif item == "boots"
		if !char.GetWornForm(0x00000080) as armor
			Return
		endif
	elseif item == "cuirass"
		if !char.GetWornForm(0x00000004) as armor
			Return
		endif
	endif

	if char == SubActor
		target = "01"
	Else
		target = "10"
	endif
	warpToAnimation("EMF|Sy6!Sy9|ApU|St9Dally+" + target + item) 

	Utility.Wait(1)
	while getCurrentAnimationClass() == ClassApartUndressing
		Utility.wait(1)
	endwhile
endfunction

int function getTimesOrgasm(actor act) ;number of times the actor has orgasmed 
	if act == DomActor
		return domTimesOrgasm
	elseif act == SubActor
		return subtimesorgasm
	endif
endfunction

function waitForRemoveCuirass(actor char) ;remove the cuirass, and don't return until anim is done
	if isNaked(char)
		Return
	endif
	animateUndressActor(char, "cuirass")
	while !isNaked(char)
		Utility.wait(1)
	endwhile
	Utility.wait(4)
endfunction

bool function isNaked(actor npc) ;todo caching
	return (!(npc.GetWornForm(0x00000004) as bool))
endfunction

actor function getSexPartner(actor char)
	if char == SubActor
		return DomActor
	else
		return subactor
	endif
EndFunction

actor function getDomActor()
	return DomActor
endfunction

actor function getSubActor()
	return SubActor
endfunction

actor function getThirdActor()
	return thirdActor
endfunction

int function getActorArousal(actor char)
	int ret = 0
	if ArousedFaction
		ret = char.GetFactionRank(ArousedFaction)
	else
		ret = 50
	EndIf

	if ret < 0 ;not yet set
		ret = 50
	endif
	return ret
EndFunction

function setActorArousal(actor char, int level) ;wrong way to do this, may not work
	if ArousedFaction
		if level < 1
			level = 1
		endif
		char.SetFactionRank(ArousedFaction, level)
	endif
EndFunction

actor function getMostRecentOrgasmedActor()
	return mostrecentorgasmedactor
endfunction

function runOsexCommand(string cmd)
	string[] Plan = new string[2]
	Plan[1] = cmd

	osa.setPlan(currScene, Plan) 
	osa.stimstart(currScene)
EndFunction

float function getTimeSinceLastPlayerInteraction()
	return Utility.GetCurrentRealTime() - mostRecentOSexInteractionTime
endfunction

bool function usingBed()
	return usingbed
EndFunction

ObjectReference function getBed()
	return currentbed
EndFunction

bool function isFemale(actor act)
	if sexlab
		;if SexLab.GetGender(act) == 0
		;	return False
		;else 
		;	return true
		;endif 
		return (act.getleveledactorbase().getsex() == 1)
	Else
		return (act.getleveledactorbase().getsex() == 1)
	endif
EndFunction

bool function appearsFemale(actor act)
	return (act.getleveledactorbase().getsex() == 1)
endfunction

actor function getCurrentLeadingActor()
	;in a blowjob type animation, it would be the female, while in most sex animations, it will be the male
	int actornum = ODatabase.getMainActor(currentoid)

	if actornum == 0
		return DomActor
	else
		return subactor
	endif
endfunction

bool function animationRunning()
	return sceneRunning
endfunction

bool function isVaginal()
	return (getCurrentAnimationClass() == ClassSex)
endfunction

String[] function getScene() ; this is not the sceneID, this is an internal osex thing
	return currScene
EndFunction

function reallign()
	sendmodevent("0SAA"+_oGlobal.GetFormID_s(domactor.GetActorBase())+"_AlignStage") ;unknown if this works on bandits
	sendmodevent("0SAA"+_oGlobal.GetFormID_s(subactor.GetActorBase())+"_AlignStage")
	if thirdActor
		sendmodevent("0SAA"+_oGlobal.GetFormID_s(thirdActor.GetActorBase())+"_AlignStage")
	endif
endfunction

function UndressIfNeeded()
	bool domnaked = isNaked(DomActor)
	bool subnaked = isNaked(SubActor)

	string cclass = getCurrentAnimationClass()
	if !domnaked
		if (cclass == ClassSex) || (cclass == ClassMasturbate) || (cclass == ClassHeadHeldMasturbate) || (cclass == ClassPenisjob) || (cclass == ClassHeadHeldPenisjob) || (cclass == ClassHandjob) || (cclass == ClassApartHandjob) || (cclass == ClassDualHandjob) || (cclass == ClassSelfSuck)
			undressActor(DomActor, domactor.GetWornForm(0x00000004))
		endif
	elseif !subnaked
		if (cclass == ClassSex) || (cclass == ClassCunn) || (cclass == ClassClitRub) || (cclass == ClassOneFingerPen) || (cclass == ClassTwoFingerPen)
			undressActor(subactor, subactor.GetWornForm(0x00000004))
		endif
	endif

EndFunction

function toggleFreeCam(bool on = true)
	ConsoleUtil.ExecuteCommand("tfc")
	

	if !isFreeCamming
		ConsoleUtil.ExecuteCommand("sucsm " + freecamSpeed)
		ConsoleUtil.ExecuteCommand("fov " + freecamFOV)
	Else
		ConsoleUtil.ExecuteCommand("fov " + defaultFOV)
	endif
		

	isFreeCamming = !isFreeCamming
endfunction

;
;
;			██████╗ ███████╗██████╗ ███████╗
;			██╔══██╗██╔════╝██╔══██╗██╔════╝
;			██████╔╝█████╗  ██║  ██║███████╗
;			██╔══██╗██╔══╝  ██║  ██║╚════██║
;			██████╔╝███████╗██████╔╝███████║
;			╚═════╝ ╚══════╝╚═════╝ ╚══════╝
;                               	
;			Code related to beds

ObjectReference function FindBed(ObjectReference CenterRef, float Radius = 1000.0, bool IgnoreUsed = true)
	if useNativeFunctions
		return FindBedNative(centerref, radius)
	else
		return FindBedPapyrus(centerref, radius, ignoreused)
    endif
endfunction

ObjectReference Function FindBedNative(ObjectReference CenterRef, Float Radius = 0.0)
	If (Radius > 0.0)
		Radius = Radius * 64.0
	Else
		Radius = bedSearchDistance * 64.0
	EndIf

	ObjectReference[] Beds = OSANative.FindBed(CenterRef, Radius, 96.0)
	ObjectReference NearRef = None

	Int Index = 0
	Int Max = Beds.Length

	While Index < Max
		If (!Beds[Index].IsFurnitureInUse())
			NearRef = Beds[Index]
			Index = Max
		Else
			Index += 1
		EndIf
	EndWhile

	If (NearRef)
		console("Bed found")
		;printBedInfo(NearRef)
		Return NearRef
	EndIf

	console("Bed not found")

	Return None ; Nothing found in search loop
EndFunction

ObjectReference function FindBedPapyrus(ObjectReference CenterRef, float Radius = 1000.0, bool IgnoreUsed = true)
	radius = bedSearchDistance * 64.0

	objectreference nearref = none

	; Current elevation to determine bed being on same floor
	float Z = CenterRef.GetPositionZ()

	Keyword word = Keyword.GetKeyword("RaceToScale")
	ObjectReference[] beds = MiscUtil.ScanCellObjects(40, centerref, radius, HasKeyword = word)
	;ObjectReference[] beds = MiscUtil.ScanCellObjects(40, centerref, radius)

	int i = 0
	int max = beds.Length

	while i < max
		if isBed(beds[i]) && !beds[i].IsFurnitureInUse() && SameFloor(beds[i], Z)
			
			if nearref == none
				nearref = beds[i]
			Else
				if nearref.GetDistance(centerref) > beds[i].GetDistance(centerref)
					nearref = beds[i]
				endif
			endif
		Else
			if false
				console("Rejecting---- ")
				if !isBed(beds[i])
					console("Not bed")
				EndIf
				if beds[i].IsFurnitureInUse()
					console("In use")
				endif
				if !SameFloor(beds[i], Z)
					console("Different floot")
				endif
			endif
		endif

		i += 1
	endwhile

	if nearref != none 
		console("Bed found")
		;printBedInfo(NearRef)
		return NearRef
	endIf
	
	console("Bed not found")
	return none ; Nothing found in search loop
endFunction

bool function SameFloor(ObjectReference BedRef, float Z, float Tolerance = 128.0)
	return (Math.Abs(Z - BedRef.GetPositionZ())) <= Tolerance
endFunction

bool function CheckBed(ObjectReference BedRef, bool IgnoreUsed = true)
	return BedRef && BedRef.IsEnabled() && BedRef.Is3DLoaded()
endFunction

bool function isBed(ObjectReference bed) ;trick so dirty it could only be in an adult mod
	if (bed.getdisplayname() == "Bed") || (bed.haskeyword(Keyword.getKeyword("FurnitureBedRoll"))) || (bed.getdisplayname() == "Bed (Owned)")
		return true
	else
		return false
	endif
endfunction

bool function isBedRoll(objectReference bed)
	return (bed.haskeyword(Keyword.getKeyword("FurnitureBedRoll")))
endfunction

function allignActorsWithCurrentBed()
	DomActor.SetDontMove(true)
	SubActor.SetDontMove(true)

	bool flip = !isBedRoll(currentbed)

	float flipfloat = 0
	if flip
		flipfloat = 180
	endif
	float domSpeed = currentbed.GetDistance(domactor) * 100

	float xoffset = 0
	float yoffset
	float zoffset = 0

	if !isbedroll(currentbed)
		console("Current bed is not a bedroll. Moving actors backwards a bit")

		int offset = 31 + bedReallignment
		if SubActor == playerref
			console("Player is subActor. adding some extra bed offset")
			offset += 36
		endif

		xoffset = Math.Cos( TrigAngleZ(currentbed.GetAngleZ())) * offset
		yoffset = Math.Sin( TrigAngleZ(currentbed.GetAngleZ())) * offset
		zoffset = 42

		
		
	else
		console("Bedroll. Not realigning")
	endif
	


	float bedX = currentBed.GetPositionX() + xoffset
	float bedY = currentbed.GetPositionY() + yoffset
	float bedZ = currentBed.GetPositionZ() + zoffset

	float bedAngleX = currentbed.GetAngleX()
	float bedAngleY = currentbed.GetAngleY()
	float bedAngleZ = currentbed.getangleZ()

	domactor.TranslateTo(bedX, bedY, bedZ, bedAngleX, bedAngleY, bedAngleZ, domSpeed, afMaxRotationSpeed = 100)
	domactor.SetAngle(bedAngleX, bedAngleY, bedAngleZ - flipfloat)
	if useFades && ((domactor == playerref) || (SubActor == playerref))
		game.FadeOutGame(false, true, 10.0, 5) ;keep the screen black
	endif
	
	Utility.wait(0.05)

	float offsetY = Math.Sin( TrigAngleZ(domactor.GetAngleZ())) * 30
	float offsetX = Math.Cos( TrigAngleZ(domactor.GetAngleZ())) * 30
	subactor.MoveTo(domactor, offsetX, offsetY, 0)
	subactor.SetAngle(bedAngleX, bedAngleY, bedAngleZ - flipfloat)
	if useFades && ((domactor == playerref) || (SubActor == playerref))
		game.FadeOutGame(false, true, 10.0, 5) ;keep the screen black
	endif

	DomActor.SetDontMove(false)
	SubActor.SetDontMove(false)

EndFunction

float function TrigAngleZ(float GameAngleZ) 
 
	if ( GameAngleZ < 90 )
		 return 90 - GameAngleZ
	else
 		return 450 - GameAngleZ
	endif
endFunction

function sleepInBed(objectreference bed, actor act) ;requires GoToBed
	if act == playerref
		if bed.GetActorOwner() != playerref.GetActorBase()
			bed.SetActorOwner(playerref.GetActorBase())
			console("Setting bed owner to player")
		endif
		int i = 0
		ConsoleUtil.SetSelectedReference(playerref)
		debug.ToggleCollisions()
		while (game.GetCurrentCrosshairRef() != bed) && (i < 20)
			Utility.Wait(0.1)
			ConsoleUtil.ExecuteCommand("setangle x 75")
			
			i += 1
			
		EndWhile
		debug.ToggleCollisions()
		ConsoleUtil.SetSelectedReference(none)

    	Input.TapKey(Input.GetMappedKey("Activate"))
    	
    	if useFades
				game.FadeOutGame(false, true, 25.0, 25.0) ;total blackout
		endif

    	int times = 0

    	float x = act.X
    	Utility.Wait(0.3)
    	while (x != act.X) && (times < 200)
    		x = act.X
    		times += 1

    		Utility.wait(0.1)
    		console("Waiting for player to stop moving")
    	endwhile

    Else
    	
	endif
EndFunction

function flip()
	console("Flipping")
	isFlipped = !isFlipped

	objectreference stage = getosastage()


	stage.SetAngle(stage.GetAngleX(), stage.getangleY(), stage.getangleZ() + 180) ;flip stage

	domactor.SetAngle(0, 0, stage.getAngleZ()) ;reangle
	subactor.SetAngle(0, 0, stage.getAngleZ())

	domactor.TranslateTo(stage.x, stage.y, stage.z, 0, 0, stage.getAngleZ(), 150.0, 0) ;move into place
	subactor.TranslateTo(stage.x, stage.y, stage.z, 0, 0, stage.getAngleZ(), 150.0, 0)

	domactor.SetVehicle(stage)  ; fuse
	subactor.SetVehicle(stage) 

EndFunction

objectreference function getOSAStage() ;the stage is an invisible object that the actors are alligned on
	int stageID = domactor.getFactionRank(OSAOmni.OFaction[1])
	objectreference stage = OSAOmni.GlobalPosition[StageID as int]

	return stage
endfunction

function printBedInfo(objectreference bed)
	console("--------------------------------------------")
	console("BED - Name: " + bed.GetDisplayName())
	console("BED - Enabled: " + bed.IsEnabled())
	console("BED - 3D loaded: " + bed.Is3DLoaded())
	console("BED - Bed roll: " + isBedRoll(bed))
	console("--------------------------------------------")
endfunction

;
;			███████╗██████╗ ███████╗███████╗██████╗     ██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
;			██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗    ██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
;			███████╗██████╔╝█████╗  █████╗  ██║  ██║    ██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
;			╚════██║██╔═══╝ ██╔══╝  ██╔══╝  ██║  ██║    ██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
;			███████║██║     ███████╗███████╗██████╔╝    ╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
;			╚══════╝╚═╝     ╚══════╝╚══════╝╚═════╝      ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝
;			 
;				Some code related to the speed system                                                                                                                                                                                                                                                       

bool currAnimHasIdleSpeed
function autoIncreaseSpeed()
	if getTimeSinceLastPlayerInteraction() < 5.0
		return
	endif
	int speed = getCurrentAnimationSpeed()
    float mainExcitement = getActorExcitement(domactor)
    if (getCurrentAnimationClass() == "VJ") || (getCurrentAnimationClass() == "Cr") || (getCurrentAnimationClass() == "Pf1") || (getCurrentAnimationClass() == "Pf2")
    	mainExcitement = getActorExcitement(subactor)
    endif
    int maxspeed = getCurrentAnimationMaxSpeed()
    int numSpeeds = maxspeed

    int aggressionBonusChance = 0

    if IsSceneAggressiveThemed()
    	aggressionBonusChance = 80
    	mainExcitement += 20
    endif
    
    if !currAnimHasIdleSpeed
    	numSpeeds = numSpeeds + 1
    Else
    	if speed == 0
    		Return
    	endif
    endif

    if (mainExcitement >= 85.0) && (speed < numspeeds)
    	if chanceRoll(80)
    		increaseAnimationSpeed()
    	endif
    elseif (mainExcitement >= 69.0) && (speed <= (numspeeds - 1))
    	if chanceRoll(50)
    		increaseAnimationSpeed()
    	endif
    elseif (mainExcitement >= 25.0) && (speed <= (numspeeds - 2))
    	if chanceRoll(20 + aggressionBonusChance)
    		increaseAnimationSpeed()
    	endif
    elseif (mainExcitement >= 05.0) && (speed <= (numspeeds - 3))
    	if chanceRoll(20 + aggressionBonusChance)
    		increaseAnimationSpeed()
    	endif
    endif
EndFunction

string function normalSpeedToOsexSpeed(int speed)
	return speeds[speed]
EndFunction


;
;			 ██████╗ ███████╗███████╗██╗  ██╗     ██████╗ ███████╗██╗      █████╗ ████████╗███████╗██████╗     ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
;			██╔═══██╗██╔════╝██╔════╝╚██╗██╔╝     ██╔══██╗██╔════╝██║     ██╔══██╗╚══██╔══╝██╔════╝██╔══██╗    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
;			██║   ██║███████╗█████╗   ╚███╔╝█████╗██████╔╝█████╗  ██║     ███████║   ██║   █████╗  ██║  ██║    █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
;			██║   ██║╚════██║██╔══╝   ██╔██╗╚════╝██╔══██╗██╔══╝  ██║     ██╔══██║   ██║   ██╔══╝  ██║  ██║    ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
;			╚██████╔╝███████║███████╗██╔╝ ██╗     ██║  ██║███████╗███████╗██║  ██║   ██║   ███████╗██████╔╝    ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
;			 ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═════╝     ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
;                                                                                                                                                      
;				Event hooks that receive data from OSA                                                                                                                                                      


Event OnAnimate(string eventName, string zAnimation, float numArg, Form sender) 
	if currentAnimation != zAnimation
		currentAnimation = zAnimation
		OnAnimationChange()
		SendModEvent("ostim_animationchanged")
	endif
	
EndEvent

function OnAnimationChange()

	console("Changing animation...")
	currentOID = odatabase.getObjectOArray( odatabase.getAnimationWithAnimID(odatabase.getDatabaseOArray(), currentAnimation), 0 )
	if odatabase.isHubAnimation(currentoid)
		lastHubOID = currentOID
		console("On new hub animation")
	endif

	currentAnimIsAggressive =  ODatabase.isAggressive(currentoid)
	currAnimHasIdleSpeed = ODatabase.hasIdleSpeed(currentoid)

	int oldSpeed = currentSpeed
	
	String[] split = PapyrusUtil.StringSplit(currentAnimation, "_")
	if split.Length > 2
		String speedString = split[2]
		currentSpeed = speedstringtoint(speedString)
	Else
		currentSpeed = 0

		
	endif

	string cclass = PapyrusUtil.StringSplit(split[1], "-")[0]
	if (StringUtil.Find(cclass, "Ag") != -1)
		cclass = StringUtil.Substring(cclass, 2)
	endif 
	currAnimClass = cclass

	if fixFlippedAnimations
		if !StringArrayContainsValue(ODatabase.originalmodules, ODatabase.getModule(currentoid))
			console("On third party animation")
			if !isFlipped
				if StringUtil.Find(ODatabase.getFullName(currentoid), "noflip") == -1
					flip()
				endif
			endif
		Else
			if isFlipped
				console("Back on first-party animation")
				flip()
			endif
		endif
	endif

	console("Current animation: " + currentAnimation)
	console("Current speed: " + currentSpeed)
	console("Current animation class: " + currAnimClass)


EndFunction

function OnSpank()
	console("Spank event recieved")


	if allowUnlimitedSpanking
		SubExcitement += 5
	else
		if spankCount < spankMax
			SubExcitement += 5
		Else
			SubActor.damageav("health", 5.0)
		endif
	endif

	spankCount += 1
EndFunction

function redress()
	form next
	actor zactor = domactor
	
	next = domHelm
	if next
		zactor.EquipItem(next, false, true)
	endif
	next = domGlove
	if next
		zactor.EquipItem(next, false, true)
	endif
	next = domArmor
	if next
		zactor.EquipItem(next, false, true)
	endif
	next = domBoot
	if next
		zactor.EquipItem(next, false, true)
	endif
	next = domWep
	if next
		zactor.EquipItem(next, false, true)
	endif

	zactor = SubActor
	next = subHelm
	if next
		zactor.EquipItem(next, false, true)
	endif
	next = subGlove
	if next
		zactor.EquipItem(next, false, true)
	endif
	next = subArmor
	if next
		zactor.EquipItem(next, false, true)
	endif
	next = subBoot
	if next
		zactor.EquipItem(next, false, true)
	endif
	next = subWep
	if next
		zactor.EquipItem(next, false, true)
	endif
endfunction

Event OnActorHit(string eventName, string zAnimation, float numArg, Form sender) 
	if endAfterActorHit
		endAnimation(false)
	endif
endevent

;
;			███████╗████████╗██╗███╗   ███╗██╗   ██╗██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
;			██╔════╝╚══██╔══╝██║████╗ ████║██║   ██║██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
;			███████╗   ██║   ██║██╔████╔██║██║   ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
;			╚════██║   ██║   ██║██║╚██╔╝██║██║   ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
;			███████║   ██║   ██║██║ ╚═╝ ██║╚██████╔╝███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
;			╚══════╝   ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
;			                                                                                                                                                
;				All code related to the stimulation simulation 


float function getCurrentStimulation(actor act) ; how much an actor is being stimulated in the current animation

	float ret = 0.0
	string cclass = getCurrentAnimationClass()
	;bool aggressive = getCurrentAnimIsAggressive()
	bool sub = (act == SubActor)
	float excitement = getActorExcitement(act)


	if cclass == ClassSex
		if sub
			ret = getInteractionStim(penis, vagina)

			if excitement > 75.0 ;extra lubrication increases enjoyment
				ret += 0.2
			Elseif excitement < 25.0
				ret -= 0.2
			endif
		Else
			ret = getInteractionStim(vagina, penis)
		endif 

	elseif (cclass == ClassHolding) || (cclass == ClassApartUndressing) || (cclass == ClassRoughHolding) ; Lightly exciting
		if excitement > 50.0
			ret = -1.0
		endif

	elseif cclass == ClassEmbracing ; more lightly exciting
		if excitement > 75.0
			ret = -1.0
		endif

	elseif (cclass == ClassApart) 
		if excitement > 25.0
			ret = -1.0
		endif

	elseif (cclass == ClassMasturbate) || (cclass == ClassHeadHeldMasturbate)
		if sub
			ret = 0.0
		Else
			ret = getInteractionStim(hand, penis)
		endif

	elseif cclass == ClassCunn
		if sub
			if chanceRoll(50)
				ret = getInteractionStim(mouth, clit)
			else
				ret = getInteractionStim(mouth, vagina)
			endif
		Else
			ret = 0.0
		endif

	elseif (cclass == ClassPenisjob) || (cclass == ClassHeadHeldPenisjob)
		if sub
			ret = 0.0
		Else
			if chanceRoll(10)
				ret = getInteractionStim(hand, penis) + (getInteractionStim(mouth, penis) - 1.0)
			Else
				ret = getInteractionStim(mouth, penis)
			endif
		endif

	elseif (cclass == ClassHandjob) || (cclass == ClassApartHandjob) || (cclass == ClassDualHandjob)
		if sub
			ret = 0.0
		Else
			ret = getInteractionStim(hand, penis)
		endif

	elseif (cclass == ClassBlowjob) || (cclass == ClassHeadHeldBlowjob)
		if sub
			ret = 0.0
		Else
			ret = getInteractionStim(mouth, penis)
		endif

	elseif (cclass == Class69Handjob)
		if sub
			if getCurrentAnimationSpeed() == 1
				if chanceRoll(30)
					ret = getInteractionStim(mouth, clit)
				else
					ret = getInteractionStim(mouth, vagina)
				endif
			else
				ret = 0.0 ;this animation is broken
			endif
		Else
			ret = getInteractionStim(hand, penis)
		endif
	elseif (cclass == Class69Blowjob)
		if sub
			if getCurrentAnimationSpeed() == 1
				if chanceRoll(30)
					ret = getInteractionStim(mouth, clit)
				else
					ret = getInteractionStim(mouth, vagina)
				endif
			else
				ret = 0.0 ;this animation is broken
			endif
		Else
			ret = getInteractionStim(mouth, penis)
		endif
	elseif (cclass == ClassClitRub)
		if sub
			ret = getInteractionStim(hand, clit)
		Else
			ret = 0.0
		endif

	elseif cclass == ClassOneFingerPen
		if sub
			ret = getInteractionStim(hand, vagina)
		Else
			ret = 0.0
		endif

	elseif cclass == ClassTwoFingerPen
		if sub
			ret = getInteractionStim(hand, vagina) * 1.5
		Else
			ret = 0.0
		endif

	elseif cclass == ClassSelfSuck
		if sub
			ret = 0.0
		Else
			ret = getInteractionStim(mouth, penis)
		endif
	elseif (cclass == classanal) 
		if sub
			if isFemale(getSubActor())
				ret = (getInteractionStim(penis, anus)) 
			Else
				ret = (getInteractionStim(penis, prostate)) + (getInteractionStim(penis, anus)) 
			endif
		Else
			ret = getInteractionStim(anus, penis)
		endif
	elseif (cclass == ClassFootjob) 
		if sub
			ret = getInteractionStim(penis, feet)
		Else
			ret = getInteractionStim(feet, penis)
		endif
	elseif (cclass == ClassBoobjob) 
		if sub
			ret = getInteractionStim(penis, breasts)
		Else
			ret = getInteractionStim(breasts, penis)
		endif
	elseif (cclass == ClassBreastFeeding) 
		if sub
			ret = getInteractionStim(mouth, breasts)
		Else
			ret = getInteractionStim(breasts, mouth)
		endif


	else
		if getCurrentAnimation() == "undefined" ;osex broke!
			console("Osex state broken. Returning to default animation")
			warpToAnimation("0MF|Cy6!DOy6|Ho|DoggyLi")
		Else
			
			console("Unknown animation class: " + cclass + ". Please report this to the dev!")
		endif
	endif


	if ret > 0.0
		int speed = getCurrentAnimationSpeed()
		int numSpeeds = getCurrentAnimationMaxSpeed()
		if !currAnimHasIdleSpeed
			numSpeeds = numSpeeds + 1
		endif
		int halfwaySpeed = (Math.Ceiling((numSpeeds as float) / 2.0)) as int   ; 5 -> 3 | 3 -> 2 etc


		if ArousedFaction
			float arousal = getActorArousal(act)
			arousal -= 50.0
			arousal /= 250
			; 100 arousal -> 0.2 ~ 0 arousal -> -0.2
			ret += arousal
		endif

		if !isNaked(getSexPartner(act))
			ret -= 0.1
		endif

		if speed == (halfwaySpeed - 2)
			ret -= 0.4
		elseif speed == (halfwaySpeed - 1)
			ret -= 0.2
		elseif speed == (halfwaySpeed)
			;do nothing
		elseif speed == (halfwaySpeed + 1)
			ret += 0.2
		elseif speed == (halfwaySpeed + 2)
			ret += 0.4
		endif

		if (speed == 0) && currAnimHasIdleSpeed
			ret = 0.0
		endif


	endif

	if ret > 0.0
		ret *= sexExcitementMult
	endif
	return ret 

endfunction

float function getInteractionStim(int stimulator, int stimulated) ; holds interaction between body parts
	float[] stimulatorValues

	if stimulator == penis
		stimulatorValues = penisStimValues
	elseif stimulator == vagina
		stimulatorValues = vaginaStimValues 
	elseif stimulator == mouth
		stimulatorValues = mouthStimValues
	elseif stimulator == hand
		stimulatorValues = handStimValues
	elseif stimulator == clit
		stimulatorValues = clitStimValues
	elseif stimulator == anus
		stimulatorValues = anusStimValues
	elseif stimulator == feet
		stimulatorValues = feetStimValues
	elseif stimulator == breasts
		stimulatorValues = breastsStimValues
	elseif stimulator == prostate
		stimulatorValues = prostateStimValues
	Else
		console("Unknown stimulator")
	endif

	return stimulatorValues[stimulated]
EndFunction

float function getActorExcitement(actor act) ;at 100, actor orgasms
	if act == DomActor
		return DomExcitement
	elseif act == subActor
		return subexcitement
	else
		debug.notification("unknown actor")
	endif
EndFunction

function setActorExcitement(actor act, float value) 
	if act == DomActor
		DomExcitement = value
	elseif act == subActor
		subexcitement = value
	else
		debug.notification("unknown actor")
	endif
EndFunction

function orgasm(actor act)
	setActorExcitement(act, -3.0) 
	SendModEvent("ostim_orgasm")
	orgasmSound.Play(act)
	if act == playerref
		NutEffect.Apply() 
		if slowMoOnOrgasm
			setGameSpeed("0.3")
			Utility.Wait(2.5)
			setGameSpeed("1")
		endif
		Game.ShakeCamera(none, 1.00, 2.0)
		shakeController(0.5, 0.7)
	endif

	Utility.Wait(0.75)

	if sexlab && !isFemale(act) ;spray cum
		if isvaginal() || (getCurrentAnimationClass() == ClassMasturbate)
			applyCum(getSexPartner(act), true)
		Else
			applyCum(getSexPartner(act), false)
		endif
	endif

	if act == DomActor
		setCurrentAnimationSpeed(1)
	endif
	

	if orgasmIncreasesRelationship
		int rank = act.GetRelationshipRank(getSexPartner(act))

		if (rank == 0)
			act.SetRelationshipRank(getSexPartner(act), 1)
		endif
	endif

	setactorarousal(act, getactorarousal(act) - 50)

	if act == DomActor
		setBarPercent(dombar, 0)
	elseif act == subActor
		setBarPercent(subbar, 0)
	endif

	act.damageav("stamina", 250.0)

EndFunction 

function applyCum(actor act, bool vaginal)
	spell Vaginal1 = (Game.GetFormFromFile(0x0008D679, "SexLab.esm")) as spell
	spell Oral1 = (Game.GetFormFromFile(0x0008D67D, "SexLab.esm")) as spell

	if vaginal
		vaginal1.Cast(act)
	Else
		Oral1.Cast(act)
	endif

EndFunction

;function HideOSexMenu()
;	console("hide")
;	int glyph = OSAOmni.glyph
;	UI.Invoke("HUD Menu", "_root.WidgetContainer."+glyph+".widget.ctr.sceneMenuDirect")
;EndFunction

;function ShowOSexMenu()
;	UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", false)
;EndFunction


;			███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗ 
;			██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗
;			███████╗██║   ██║██║   ██║██╔██╗ ██║██║  ██║
;			╚════██║██║   ██║██║   ██║██║╚██╗██║██║  ██║
;			███████║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
;			╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
;                                           
;				Code related to sound                                          

function playDing()
	OsaDing.Play(playerref)
EndFunction

function playTickSmall()
	OsaTickSmall.Play(playerref)
EndFunction

function playTickBig()
	OsaTickBig.Play(playerref)
endfunction

Event OnSoundDom(string eventName, string fi, float ix, Form sender)
	onsound(DomActor, (fi as int), ix as int)
EndEvent

Event OnSoundSub(string eventName, string fi, float ix, Form sender)
	onsound(subactor, (fi as int), ix as int)
EndEvent

Event OnSoundThird(string eventName, string fi, float ix, Form sender)
	onsound(thirdActor, (fi as int), ix as int)
EndEvent

; Below is an event you can easily copy paste into your code to receive sound data
;RegisterForModEvent("ostim_osasound", "OnOSASound")
;Event OnOSASound(string eventName, string args, float nothing, Form sender)
;	string[] argz = new string[3]
;	argz = StringUtil.Split(args, "")
;
;	actor char 
;	if argz[0] == "dom"
;		char = ostim.getDomActor()
;	elseif argz[0] == "sub"
;		char = ostim.getsubactor()
;	elseif argz[0] == "third"	
;		char = ostim.getThirdActor()
;	EndIf
;	int formID = argz[1] as Int
;	int soundID = argz[2] as Int
;
;	OsexIntegrationMain.console("Actor: " + char.GetDisplayName() + " FormID: " + formID + " SoundID: " + argz[2])
;endevent

function OnSound(actor act, int soundID, int formNumber)
	int formID 
	if appearsFemale(act)
		if (formNumber == 50) || (formNumber == 60)
			formID = formNumber
		Else
			formID = formNumber + 5
		endif
	Else
		formID = formNumber
	endif


	if !muteOSA
		playOSASound(act, formid, soundid)
	endif

	if (formNumber == 60)
		OnSpank()
		shakeController(0.3)
		shakeCamera(0.5)
	endif

	if (formNumber == 50)
		shakeCamera(0.5)
		shakeController(0.1)
	endif

	string arg
	if act == DomActor
		arg = "dom"
	elseif act == SubActor
		arg = "sub"
	Else
		arg = "third"
	endif
	arg = arg + "," + formid
	arg = arg + "," + soundid
	SendModEvent("ostim_osasound", strArg = arg)

EndFunction



Event OnFormBind(string eventName, string zMod, float ixid, Form sender)
	int Ix = StringUtil.substring(ixid, 0, 2) as int
	int Fo = StringUtil.substring(ixid, 2) as int
;OFormSuite[Ix] = Game.GetFormFromFile(Fo, zMod) as FormList
	console("System requesting form: " + fo + " be placed in to slot " + ix)
	if zMod != "OSA.esm"
		console(zmod)
	endif

	console(game.GetFormFromFile(fo, "OSA.esm").GetName())
EndEvent

function playOSASound(actor act, int formlistID, int soundID)
	playSound(act, SoundFormlists[formlistID].GetAt(soundid) as Sound)
	;console("Playing sound " + soundid + " in form " + formlistID)
EndFunction

function playSound(actor act, sound sou)
	int S = (sou).play(act)
	Sound.SetInstanceVolume(S, 1.0)
EndFunction

;  0Guy_vo - 20
; 0Gal_vo - 20 - s 25
; 0Guy_ivo - 10
; 0Gal_ivo - 10 - s 15
;  0Gal_ivos - 11 - s 16
; 0Gal_ivo - 11
; FEvenTone_wvo - 80 - s 85
;0guy_wvo - 80
; 0bod_ibo - 50
; 0bod_ibo - 50
;0spank_spank - 60
;0spank_spank - 60

FormList[] SoundFormlists
function BuildSoundFormlists()
	SoundFormlists = new formlist[100]
	string osas = "OSA.esm"

	SoundFormlists[10] = game.GetFormFromFile(10483, osas) as FormList ;0Guy_ivo
	SoundFormlists[15] = game.GetFormFromFile(8986, osas) as FormList ;0Gal_ivo

	SoundFormlists[11] = game.GetFormFromFile(8986, osas) as FormList ;0Gal_ivo | wtf? female voice on male?
	SoundFormlists[16] = game.GetFormFromFile(8987, osas) as FormList ;0Gal_ivos

	SoundFormlists[20] = game.GetFormFromFile(17595, osas) as FormList ;0Guy_vo
	SoundFormlists[25] = game.GetFormFromFile(17570, osas) as FormList ;0Gal_vo

	SoundFormlists[80] = game.GetFormFromFile(13409, osas) as FormList ;0guy_wvo
	SoundFormlists[85] = game.GetFormFromFile(13400, osas) as FormList ;FEvenTone_wvo

	SoundFormlists[50] = game.GetFormFromFile(11972, osas) as FormList ;0bod_ibo

	SoundFormlists[60] = game.GetFormFromFile(9037, osas) as FormList ;0spank_spank
endfunction

FormList[] function getSoundFormLists()
	return SoundFormlists
EndFunction

;
;			██████╗  █████╗ ██████╗ ███████╗
;			██╔══██╗██╔══██╗██╔══██╗██╔════╝
;			██████╔╝███████║██████╔╝███████╗
;			██╔══██╗██╔══██║██╔══██╗╚════██║
;			██████╔╝██║  ██║██║  ██║███████║
;			╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
;                               
;				Code related to the on-screen bars 



function initBar(Osexbar bar, bool domsbar)
	bar.HAnchor = "left"
	bar.VAnchor = "bottom"
	bar.X = 200	
	bar.Alpha = 0.0
	bar.SetPercent(0.0)
	bar.FillDirection = "Right"

	if domsbar
		bar.Y = 692
		bar.SetColors(0xb0b0b0, 0xADD8E6, 0xffffff)
	Else
		bar.Y = 647
		bar.SetColors(0xb0b0b0, 0xffb6c1, 0xffffff)
	endif

	setBarVisible(bar, false)
endfunction

function setBarVisible(Osexbar bar, bool visible)
	if (Visible)
		bar.FadeTo(100.0, 1.0)
		bar.fadedOut = false
	else
		bar.FadeTo(0.0, 1.0)
		bar.fadedOut = true
	EndIf
EndFunction

bool function isBarVisible(osexbar bar)
	return !bar.fadedOut
endfunction

function setBarPercent(Osexbar bar, float percent)
	float zpercent = percent / 100.0
	bar.SetPercent(percent / 100.0)

	if zpercent >= 1.0
		flashBar(bar)
	endif
EndFunction

function flashBar(Osexbar bar)
	bar.ForceFlash()
EndFunction

;			 ██████╗ ████████╗██╗  ██╗███████╗██████╗ 
;			██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
;			██║   ██║   ██║   ███████║█████╗  ██████╔╝
;			██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
;			╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║
;			 ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
;                                         
;				Misc stuff  
;				https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=ANSI%20Shadow&text=Other                                     

function console(string in) global
	MiscUtil.PrintConsole("OStim: " + in)
EndFunction

function setGameSpeed(string in)
	consoleUtil.ExecuteCommand("sgtm " + in)
endfunction

bool function chanceRoll(int chance) ; input 60: 60% of returning true 
	int roll = Utility.RandomInt(1, 100)

	if roll <= chance
		return True
	Else
		return false
	endif
EndFunction

int function speedStringToInt(string in) ;casting does not work so...
	if in == "s0"
		return 0
	elseif in == "s1"
		return 1
	elseif in == "s2"
		return 2
	elseif in == "s3"
		return 3
	elseif in == "s4"
		return 4
	elseif in == "s5"
		return 5
	elseif in == "s6"
		return 6
	elseif in == "s7"
		return 7
	elseif in == "s8"
		return 8
	elseif in == "s9"
		return 9
	endif
EndFunction

function shakeCamera(float power, float duration = 0.1)
	if useScreenShake && ((DomActor == playerref) || (SubActor == playerref))
		game.ShakeCamera(playerref, power, duration)
	endif
endfunction

function shakeController(float power, float duration = 0.1)
	if useRumble && ((DomActor == playerref) || (SubActor == playerref))
		game.ShakeController(power, power, duration)
	endif
endfunction

bool function IntArrayContainsValue(int[] arr, int val)
	int i = 0
	int max = arr.Length
	while i < max
		if arr[i] == val
			return True
		endif
		i += 1
	endwhile
	return false
endfunction

bool function StringArrayContainsValue(string[] arr, string val)
	int i = 0
	int max = arr.Length
	while i < max
		if arr[i] == val
			return True
		endif
		i += 1
	endwhile
	return false
endfunction

int function getTimeScale()
	return timescale.GetValue() as int
EndFunction

int function setTimeScale(int time)
	timescale.SetValue(time as float)
endfunction

function setSystemVars()
	; vanilla OSex class library
	ClassSex = "Sx"
	ClassCunn = "VJ" ;Cunnilingus
	ClassApartHandjob = "ApHJ"
	ClassHandjob = "HJ"
	ClassClitRub = "Cr"
	ClassOneFingerPen = "Pf1"
	ClassTwoFingerPen = "Pf2"
	ClassBlowjob = "BJ"  
	ClassPenisjob = "ApPJ" ;Blowjob with jerking at the same time
	ClassMasturbate = "Po" ; masturbation
	ClassHolding = "Ho" ;
	ClassApart = "Ap" ;standing apart
	ClassApartUndressing = "ApU"
	ClassEmbracing = "Em"
	ClassRoughHolding = "Ro" 
	ClassSelfSuck = "SJ" 
	ClassHeadHeldPenisjob = "HhPJ" 
	ClassHeadHeldBlowjob = "HhBJ"
	ClassHeadHeldMasturbate = "HhPo"
	ClassDualHandjob = "DHJ"
	Class69Blowjob = "VBJ"
	Class69Handjob = "VHJ"

	; OStim extended library
	ClassAnal = "An"
	ClassBoobjob = "BoJ"
	ClassBreastFeeding = "BoF"
	ClassFootjob = "FJ"



	penis = 0
	vagina = 1
	mouth = 2
	hand = 3
	clit = 4
	;extra
	anus = 5
	feet = 6
	breasts = 7
	prostate = 8


	penisStimValues = new float[9]
	vaginaStimValues = new float[9]
	mouthStimValues = new float[9]
	handStimValues = new float[9]
	clitStimValues = new float[9]

	anusStimValues = new float[9]
	feetStimValues = new float[9]
	breastsStimValues = new float[9]
	prostateStimValues = new float[9]

	penisStimValues[penis] = 0.4
	penisStimValues[vagina] = 0.8
	penisStimValues[mouth] = 0.0
	penisStimValues[hand] = 0.0
	penisStimValues[clit] = 0.85
	penisStimValues[anus] = 0.2
	penisStimValues[feet] = 0.0
	penisStimValues[breasts] = 0
	penisStimValues[prostate] = 0.6

	vaginaStimValues[penis] = 1.0
	vaginaStimValues[vagina] = 0.6
	vaginaStimValues[mouth] = 0.0
	vaginaStimValues[hand] = 0.0
	vaginaStimValues[clit] = 1.0
	vaginaStimValues[anus] = 0.0
	vaginaStimValues[feet] = 0.0
	vaginaStimValues[breasts] = 0.0
	vaginaStimValues[prostate] = 0.0

	mouthStimValues[penis] = 1.4
	mouthStimValues[vagina] = 1.0
	mouthStimValues[mouth] = 0.1
	mouthStimValues[hand] = 0.0
	mouthStimValues[clit] = 2.0
	mouthStimValues[anus] = 0.1
	mouthStimValues[feet] = 0.0
	mouthStimValues[breasts] = 0.1
	mouthStimValues[prostate] = 0.0

	handStimValues[penis] = 0.9
	handStimValues[vagina] = 0.6
	handStimValues[mouth] = 0.0
	handStimValues[hand] = 0.0
	handStimValues[clit] = 1.3
	handStimValues[anus] = 0.1
	handStimValues[feet] = 0.0
	handStimValues[breasts] = 0.0
	handStimValues[prostate] = 0.5

	clitStimValues[penis] = 0.2
	clitStimValues[vagina] = 0.1
	clitStimValues[mouth] = 0.0
	clitStimValues[hand] = 0.0
	clitStimValues[clit] = 1.1
	clitStimValues[anus] = 0.0
	clitStimValues[feet] = 0.0
	clitStimValues[breasts] = 0.0
	clitStimValues[prostate] = 0.0

	anusStimValues[penis] = 1.2
	anusStimValues[vagina] = 0.2
	anusStimValues[mouth] = 0.0
	anusStimValues[hand] = 0.0
	anusStimValues[clit] = 0.5
	anusStimValues[anus] = 0.0
	anusStimValues[feet] = 0.0
	anusStimValues[breasts] = 0.0
	anusStimValues[prostate] = 0.0

	feetStimValues[penis] = 0.7
	feetStimValues[vagina] = 0.6
	feetStimValues[mouth] = 0.0
	feetStimValues[hand] = 0.0
	feetStimValues[clit] = 0.8
	feetStimValues[anus] = 0.1
	feetStimValues[feet] = 0.0
	feetStimValues[breasts] = 0.0
	feetStimValues[prostate] = 0.3

	breastsStimValues[penis] = 0.8
	breastsStimValues[vagina] = 0.3
	breastsStimValues[mouth] = 0.0
	breastsStimValues[hand] = 0.0
	breastsStimValues[clit] = 1.0
	breastsStimValues[anus] = 0.0
	breastsStimValues[feet] = 0.0
	breastsStimValues[breasts] = 0.1
	breastsStimValues[prostate] = 0.0

	prostateStimValues[penis] = 1.2
	prostateStimValues[vagina] = 0.2
	prostateStimValues[mouth] = 0.0
	prostateStimValues[hand] = 0.0
	prostateStimValues[clit] = 0.5
	prostateStimValues[anus] = 0.0
	prostateStimValues[feet] = 0.0
	prostateStimValues[breasts] = 0.0
	prostateStimValues[prostate] = 0.0

	speeds = new string[9] ;this is the most fucked up progression i have ever seen
	speeds[0] = "-1"
	speeds[1] = "0.5"
	speeds[2] = "1.5"
	speeds[3] = "2"
	speeds[4] = "3"
	speeds[5] = "4"
	speeds[6] = "4.5"
	speeds[7] = "5"
	speeds[8] =  "6"
EndFunction

function setDefaultSettings()
	endOnDomOrgasm = true
	enableSubBar = True
	enableDomBar = true
	enableActorSpeedControl = true
	allowUnlimitedSpanking = false
	autoUndressIfNeeded = true

	endAfterActorHit = false

	domLightBrightness = 0
	subLightBrightness = 1
	subLightPos = 0
	domLightPos = 0

	customTimescale = 0
	alwaysUndressAtAnimStart = true
	onlyUndressChest = false ; currently only chest can be removed with animation 
	alwaysAnimateUndress = false

	lowLightLevelLightsOnly = false

	sexExcitementMult = 1.0
	
	enableImprovedCamSupport = false

	speedUpNonSexAnimation = false ;game pauses if anim finished early
	speedUpSpeed = 1.5

	usebed = true
	bedSearchDistance = 15
	misallignmentProtection = true

	fixFlippedAnimations = false
	orgasmIncreasesRelationship = false
	slowMoOnOrgasm = true

	useaicontrol = false
	pauseAI = false
	autoHideBars = false
	
	getInBedAfterBedScene = false
	useAINPConNPC = true
	useAIPlayerAggressor = true
	useAIPlayerAggressed = true
	useAINonAggressive = false

	forcefirstpersonafter = true

	useFreeCam = false

	bedReallignment = 0

	useRumble = game.UsingGamepad()
	useScreenShake = false

	useFades = True
	useAutoFades = true

	keymap = 200
	speedUpKey = 78
	speedDownKey = 74
	PullOutKey = 79
	ControlToggleKey = 82

	muteOSA = False

	freecamFOV = 45
	defaultFOV = 85
	freecamspeed = 3

	useNativeFunctions = (skse.GetPluginVersion("OSA") != -1)
	if !useNativeFunctions
		console("Native function DLL failed to load. Falling back to papyrus implementations")
	endif

	useBrokenCosaveWorkaround = true
	remapStartKey(keymap)
	remapSpeedDownKey(speedDownKey)
	remapSpeedUpKey(speedUpKey)
	remapPullOutKey(PullOutKey)
	remapControlToggleKey(ControlToggleKey)
EndFunction

function loadOSexControlKeys()
	OSexControlKeys = new int[1]

	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, speedUpKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, speedDownKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, PullOutKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, ControlToggleKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, keymap)

	int osexkey

	osexkey = 83
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
	osexkey = 156
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
	osexkey = 72
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
	osexkey = 76
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
	osexkey = 75
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
	osexkey = 77
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
	osexkey = 73
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
	osexkey = 71
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
	osexkey = 79
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
	osexkey = 209
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, osexkey)
	registerForKey(osexkey)
endfunction

function DisplayTextBanner(string txt)
	UI.InvokeString("HUD Menu", "_root.HUDMovieBaseInstance.QuestUpdateBaseInstance.ShowNotification", txt)
EndFunction

function resetState()
	console("Resetting thread state")
	sceneRunning = False
	Debug.MessageBox("Reset state.")

EndFunction


function remapStartKey(int zkey)
	UnregisterForKey(keymap)

	RegisterForKey(zkey)
	keymap = zkey
endfunction

function remapControlToggleKey(int zkey)
	UnregisterForKey(ControlToggleKey)

	RegisterForKey(zkey)
	ControlToggleKey = zkey
	loadOSexControlKeys()
endfunction

function remapSpeedUpKey(int zkey)
	UnregisterForKey(speedUpKey)

	RegisterForKey(zkey)
	speedUpKey = zkey
	loadOSexControlKeys()
endfunction

function remapSpeedDownKey(int zkey)
	UnregisterForKey(speedDownKey)

	RegisterForKey(zkey)
	speedDownKey = zkey
	loadOSexControlKeys()
endfunction

function remapPullOutKey(int zkey)
	UnregisterForKey(PullOutKey)

	RegisterForKey(zkey)
	PullOutKey = zkey
	loadOSexControlKeys()
endfunction

float profileTime
function profile(string name = "")
	
	if name == ""
		profileTime = game.GetRealHoursPassed() * 60 * 60
	Else 
		console(name + ": " + ((game.GetRealHoursPassed() * 60 * 60) - profileTime) + " seconds")
	endif
		
endfunction

; TODO - support for ABOMB animation


bool property useBrokenCosaveWorkaround auto
function onLoadGame()

	if useBrokenCosaveWorkaround
		console("Using cosave fix")

		RegisterForModEvent("ostim_actorhit", "OnActorHit")
		loadOSexControlKeys()
		registerforkey(speedUpKey)
		registerforkey(speedDownKey)
		registerforkey(PullOutKey)
		registerforkey(ControlToggleKey)
		registerforkey(keyMap)

		ai.OnGameLoad()
	endif
endfunction