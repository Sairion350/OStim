ScriptName OsexIntegrationMain Extends Quest


; -------------------------------------------------------------------------------------------------
; SETTINGS  ---------------------------------------------------------------------------------------


Bool Property EndOnDomOrgasm Auto

Bool Property EnableDomBar Auto
Bool Property EnableSubBar Auto
Bool Property AutoHideBars Auto
Bool Property EnableImprovedCamSupport Auto

Bool Property EnableActorSpeedControl Auto

Bool Property AllowUnlimitedSpanking Auto

Bool Property AutoUndressIfNeeded Auto
Int Property BedSearchDistance Auto

Int Property SubLightPos Auto
Int Property DomLightPos Auto
Int Property SubLightBrightness Auto
Int Property DomLightBrightness Auto

Bool Property LowLightLevelLightsOnly Auto
Bool Property SlowMoOnOrgasm Auto

Bool Property AlwaysUndressAtAnimStart Auto
Bool Property OnlyUndressChest Auto
Bool Property AlwaysAnimateUndress Auto

Bool  SpeedUpNonSexAnimation
Float SpeedUpSpeed

Int Property CustomTimescale Auto

Bool Property OrgasmIncreasesRelationship Auto

Float Property SexExcitementMult Auto

Int Property KeyMap Auto

Int Property SpeedUpKey Auto
Int Property SpeedDownKey Auto
Int Property PullOutKey Auto
Int Property ControlToggleKey Auto

Bool Property UseBed Auto

Bool Property MisallignmentProtection Auto

Bool Property UseAIControl Auto
Bool Property PauseAI Auto

Bool Property UseAINPConNPC Auto
Bool Property UseAIPlayerAggressor Auto
Bool Property UseAIPlayerAggressed Auto
Bool Property UseAINonAggressive Auto

Bool Property MuteOSA Auto

Bool Property FixFlippedAnimations Auto

Bool Property UseFreeCam Auto

Bool Property UseRumble Auto
Bool Property UseScreenShake Auto

Bool Property UseFades Auto
Bool Property UseAutoFades Auto

Bool Property EndAfterActorHit Auto

Bool Property GetInBedAfterBedScene Auto

Int Property FreecamFOV Auto
Int Property DefaultFOV Auto
Int Property FreecamSpeed Auto

Int Property BedReallignment Auto

Bool Property ForceFirstPersonAfter Auto

Bool Property UseNativeFunctions Auto
Bool Property BlockVRInstalls Auto

Bool Property UseAlternateBedSearch Auto


; -------------------------------------------------------------------------------------------------
; SCRIPTWIDE VARIABLES ----------------------------------------------------------------------------


Actor DomActor
Actor SubActor

Float DomExcitement
Float SubExcitement

Bool SceneRunning
String CurrentAnimation
Int CurrentSpeed
String[] CurrScene
String CurrAnimClass

Bool AnimSpeedAtMax
Int SpankCount
Int SpankMax

_oOmni OSAOmni

Actor PlayerRef

GlobalVariable Timescale

Bool UndressDom
Bool UndressSub
Bool AnimateUndress
String StartingAnimation
Actor ThirdActor

Form DomHelm
Form DomArmor
Form DomGlove
Form DomBoot
Form DomWep

Form SubHelm
Form SubArmor
Form SubGlove
Form SubBoot
Form SubWep

form ThirdHelm
form ThirdArmor
form ThirdGlove
form ThirdBoot
form ThirdWep

Bool IsFreeCamming

Int DomTimesOrgasm
Int SubTimesOrgasm

Actor MostRecentOrgasmedActor

Bool UsingBed
ObjectReference CurrentBed

Bool EndedProper

Float StartTime

Float MostRecentOSexInteractionTime

Int[] OSexControlKeys

;--Thank you ODatabase
Int CurrentOID ; the OID is the JMap ID of the current animation. You can feed this in to ODatabase
Int LastHubOID
Bool CurrentAnimIsAggressive
;--

Bool AIRunning

Bool AggressiveThemedSexScene
Actor AggressiveActor

OAiScript AI

Bool IsFlipped

; -------------------------------------------------------------------------------------------------
; OSA SPECIFIC  -----------------------------------------------------------------------------------

MagicEffect Actra
Faction OsaFactionStage

Faction ArousedFaction
ImageSpaceModifier NutEffect

Quest SexLab ; for cum effects
Sound OrgasmSound

Sound OSADing
Sound OSATickSmall
Sound OSATickBig

;_oUI OSAUI
;---------

;--------- bars
Osexbar DomBar
Osexbar SubBar
;---------

;--------- database
ODatabaseScript ODatabase
;---------
;--------- ID shortcuts
;Animation classifications
String ClassSex
String ClassEmbracing
String ClassCunn
String ClassHolding
String ClassApart
String ClassApartUndressing
String ClassApartHandjob
String ClassHandjob
String ClassClitRub
String ClassOneFingerPen
String ClassTwoFingerPen
String ClassBlowjob
String ClassPenisjob
String ClassMasturbate
String ClassRoughHolding
String ClassSelfSuck
String ClassHeadHeldBlowjob
String ClassHeadHeldPenisjob
String ClassHeadHeldMasturbate
String ClassDualHandjob
String Class69Blowjob
String Class69Handjob

String ClassAnal
String ClassBoobjob
String ClassBreastFeeding
String ClassFootjob

;Body parts
Int Penis
Int Vagina
Int Mouth
Int Hand
Int Clit
;extra parts
Int Anus
Int Feet
Int Breasts
Int Prostate

Float[] PenisStimValues
Float[] VaginaStimValues
Float[] MouthStimValues
Float[] HandStimValues
Float[] ClitStimValues

Float[] AnusStimValues
Float[] FeetStimValues
Float[] BreastsStimValues
Float[] ProstateStimValues

String[] Speeds

; -------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------

Event OnKeyDown(Int KeyPress)
	If (Utility.IsInMenuMode() || UI.IsMenuOpen("console"))
		Return
	EndIf

	If (AnimationRunning())
		If (IntArrayContainsValue(OSexControlKeys, KeyPress))
			MostRecentOSexInteractionTime = Utility.GetCurrentRealTime()
			If (AutoHideBars)
				If (!IsBarVisible(DomBar))
					SetBarVisible(DomBar, True)
				EndIf
				If (!IsBarVisible(SubBar))
					SetBarVisible(SubBar, True)
				EndIf
			EndIf
		EndIf

		If (KeyPress == SpeedUpKey)
			IncreaseAnimationSpeed()
			PlayTickSmall()
		ElseIf (KeyPress == SpeedDownKey)
			DecreaseAnimationSpeed()
			PlayTickSmall()
		ElseIf ((KeyPress == PullOutKey) && !AIRunning)
			If (ODatabase.IsSexAnimation(CurrentOID))
				If (LastHubOID != -1)
					TravelToAnimationIfPossible(ODatabase.GetSceneID(LastHubOID))
				EndIf
			EndIf
		EndIf
	EndIf

	If (KeyPress == ControlToggleKey)
		If (AnimationRunning())
			If (AIRunning)
				AIRunning = False
				PauseAI = True
				Debug.Notification("Switched to manual control mode")
				Console("Switched to manual control mode")
			Else
				If (PauseAI)
					PauseAI = False
				Else
					AI.StartAI()
				EndIf
				AIRunning = True
				Debug.Notification("Switched to automatic control mode")
				Console("Switched to automatic control mode")
			EndIf
		Else
			If (UseAIControl)
				UseAIControl = False
				Debug.Notification("Switched to manual control mode")
				Console("Switched to manual control mode")
			Else
				UseAIControl = True
				Debug.Notification("Switched to automatic control mode")
				Console("Switched to automatic control mode")
			EndIf
		EndIf
		PlayTickBig()
	EndIf

	Actor Target = Game.GetCurrentCrosshairRef() as Actor
	If (KeyPress == KeyMap)
		If (Target)
			If (Target.IsInDialogueWithPlayer())
				Return
			EndIf
			If (!Target.IsDead())
				StartScene(PlayerRef,  Target)
			EndIf
		EndIf
	EndIf
EndEvent

Event OnInit()
	Startup()
EndEvent

Function Startup()
	Debug.Notification("Installing OStim. Please wait...")
	SceneRunning = False
	Actra = Game.GetFormFromFile(0x000D63, "OSA.ESM") as MagicEffect
	OsaFactionStage = Game.GetFormFromFile(0x00182F, "OSA.ESM") as Faction
	OSAOmni = (Quest.GetQuest("0SA") as _oOmni)
;	OSAUI = (Quest.GetQuest("0SA") as _oui)
	PlayerRef = Game.GetPlayer()
	NutEffect = Game.GetFormFromFile(0x000805, "Ostim.esp") as ImageSpaceModifier

	OSADing = Game.GetFormFromFile(0x000D6D, "Ostim.esp") as Sound
	OSATickSmall = Game.GetFormFromFile(0x000D6E, "Ostim.esp") as Sound
	OSATickBig = Game.GetFormFromFile(0x000D6F, "Ostim.esp") as Sound

	If (Game.GetModByName("SexLab.esm") != 255)
		SexLab = (Game.GetFormFromFile(0x00000D62, "SexLab.esm")) as Quest
		OrgasmSound = (Game.GetFormFromFile(0x00065A34, "SexLab.esm")) as Sound
	EndIf

	If (Game.GetModByName("SexlabAroused.esm") != 255)
		ArousedFaction = Game.GetFormFromFile(0x0003FC36, "SexlabAroused.esm") as Faction
	EndIf

	DomBar = (Self as Quest) as Osexbar
	SubBar = (Game.GetFormFromFile(0x000804, "Ostim.esp")) as Osexbar
	Timescale = (Game.GetFormFromFile(0x00003A, "Skyrim.esm")) as GlobalVariable
	InitBar(dombar, True)
	InitBar(subbar, False)

	AI = ((Self as Quest) as OAiScript)
	RegisterForModEvent("ostim_actorhit", "OnActorHit")
	SetSystemVars()
	SetDefaultSettings()
	BuildSoundFormlists()

	if (BlockVRInstalls && GetGameIsVR())
		Debug.MessageBox("OStim: You appear to be using Skyrim VR. VR is not yet supported by OStim. See the OStim description for more details. If you are not using Skyrim VR by chance, update your papyrus Utilities")
		return
	endif

	if (SKSE.GetPluginVersion("JContainers64") == -1)
		Debug.MessageBox("OStim: JContainers is not installed, please exit and install it immediately")
		return
	endif

	ODatabase = (Self as Quest) as ODatabaseScript
	ODatabase.InitDatabase()

	If (OSAFactionStage)
		Console("Loaded")
	Else
		Debug.MessageBox("OSex and OSA do not appear to be installed, please do not continue using this save file")
		Return
	EndIf

	if (ODatabase.GetLengthOArray(ODatabase.GetDatabaseOArray()) < 1)
		Debug.Notification("OStim install failed")
		return
	Else
		ODatabase.Unload()
	EndIf

	If (ArousedFaction)
		Console("Sexlab Aroused loaded")
	EndIf

	if (SKSE.GetPluginVersion("ConsoleUtilSSE") == -1)
		Debug.Notification("OStim: ConsoleUtils is not installed, a few features may not work")
	endif

	If (SexLab)
		Console("SexLab loaded, using its cum effects")
	Else
		Debug.Notification("OStim: Sexlab is not loaded. Some orgasm FX will be missing")
	EndIf

	If (OSA.StimInstalledProper())
		Console("OSA is installed correctly")
	Else
		Debug.MessageBox("OStim is not loaded after OSA in your mod files, please allow OStim to overwrite OSA's files and restart")
		Return
	EndIf

	if (SKSE.GetPluginVersion("ImprovedCamera") == -1)
		Debug.Notification("OStim: Improved Camera is not installed. First person scenes will not be available")
		Debug.Notification("OStim: However, freecam will have extra features")
	EndIf

	If (!_oGlobal.OStimGlobalLoaded())
		Debug.MessageBox("It appears you have the OSex facial expression fix installed. Please exit and remove that mod, as it is now included in OStim, and having it installed will break some things now!")
		return
	EndIf
	OSAOmni.RebootScript()

	Utility.Wait(1)
	DisplayTextBanner("OStim installed")
EndFunction

Actor ReroutedDomActor
Actor ReroutedSubActor
Function AcceptReroutingActors(Actor Act1, Actor Act2)
	ReroutedDomActor = Act1
	ReroutedSubActor = Act2
	Console("Recieved rerouted actors")
EndFunction

Function StartReroutedScene()
	Console("Rerouting scene")
	StartScene(ReroutedDomActor,  ReroutedSubActor)
EndFunction

Bool Function StartScene(Actor Dom, Actor Sub, Bool zUndressDom = False, Bool zUndressSub = False, Bool zAnimateUndress = False, String zStartingAnimation = "", Actor zThirdActor = None, ObjectReference Bed = None, Bool Aggressive = False, Actor AggressingActor = None)
	If (SceneRunning)
		Debug.Notification("Osex scene already running")
		Return False
	EndIf
	If IsActorActive(dom) || IsActorActive(sub)
		Debug.Notification("One of the actors is already in a OSA scene")
		Return False
	EndIf

	DomActor = Dom
	SubActor = Sub
	If (AppearsFemale(Dom) && !AppearsFemale(Sub)) ; if the dom is female and the sub is male
		DomActor = Sub
		SubActor = Dom
	Else
		DomActor = Dom
		SubActor = Sub
	EndIf

	UndressDom = zUndressDom
	UndressSub = zUndressSub
	AnimateUndress = zAnimateUndress
	StartingAnimation = zStartingAnimation
	ThirdActor = zThirdActor
	PauseAI = False

	If (Aggressive)
		If (AggressingActor)
			If ((AggressingActor != SubActor) && (AggressingActor != DomActor))
				debug.MessageBox("Programmer:  The aggressing Actor you entered is not part of the scene!")
				Return False
			Else
				AggressiveActor = AggressingActor
				AggressiveThemedSexScene = True
			EndIf
		Else
			Debug.MessageBox("Programmer: Please enter the aggressor in this aggressive animation")
			Return False
		EndIf
	Else
		AggressiveThemedSexScene = False
		AggressingActor = None
	EndIf

	If (Bed)
		UsingBed = True
		Currentbed = Bed
	Else
		UsingBed = False
	EndIf

	Console("Requesting scene start")
	RegisterForSingleUpdate(0.01)
	SceneRunning = True

	Return True
EndFunction

Event OnUpdate()
	Console("Starting scene asynchronously")

	If (UseFades && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Float Time = 1.25
		Game.FadeOutGame(True, True, 0.0, Time)
		Utility.Wait(Time - 0.25)
		Game.FadeOutGame(False, True, 25.0, 25.0) ; total blackout
	EndIf

	If (EnableImprovedCamSupport)
		Game.DisablePlayerControls(abCamswitch = True, abMenu = False, abFighting = False, abActivate = False, abMovement = False, aiDisablePOVType = 0)
	EndIf

	Int OldTimescale = 0
	If (CustomTimescale >= 1)
		OldTimescale = GetTimeScale()
		SetTimeScale(CustomTimescale)
		Console("Using custom Timescale: " + CustomTimescale)
	EndIf

	IsFlipped = False
	CurrentSpeed = 0
	DomExcitement = 0.0
	SubExcitement = 0.0
	EndedProper = False
	SpankCount = 0
	SubTimesOrgasm = 0
	DomTimesOrgasm = 0
	MostRecentOrgasmedActor = None
	SpankMax = Utility.RandomInt(1, 6)
	IsFreeCamming = False

	If (!UseAIControl)
		AIRunning = False
	Else
		AIRunning = True
	EndIf

	Actor[] actro
	If (ThirdActor)
		Actro  = New Actor[3]
		Actro[2] = ThirdActor
	Else
		Actro  = New Actor[2]
	EndIf

	RegisterForModEvent("0SSO" + _oGlobal.GetFormID_S(DomActor.GetActorBase()) + "_Sound", "OnSoundDom")
	RegisterForModEvent("0SSO" + _oGlobal.GetFormID_S(SubActor.GetActorBase()) + "_Sound", "OnSoundSub")

	If (ThirdActor)
		RegisterForModEvent("0SSO" + _oGlobal.GetFormID_S(thirdActor.GetActorBase()) + "_Sound", "OnSoundThird")
	EndIf

	Actro[0] = DomActor
	Actro[1] = SubActor

	If (!UsingBed && UseBed)
		Currentbed = FindBed(DomActor)
		If (CurrentBed)
			UsingBed = True
		EndIf
	EndIf

	Float DomX
	Float DomY
	Float DomZ
	Float SubX
	Float SubY
	Float SubZ

	If (UsingBed)
		DomX = DomActor.X
		DomY = DomActor.Y
		DomZ = DomActor.Z

		SubX = SubActor.X
		SubY = SubActor.Y
		SubZ = SubActor.Z

		AllignActorsWithCurrentBed()
		If (StartingAnimation == "")
			StartingAnimation = "0MF|KNy6!KNy6|Ho|KnLap"
		EndIf
	EndIf

	If (StartingAnimation == "")
		StartingAnimation = "AUTO"
	EndIf

    CurrScene = OSA.MakeStage()
    OSA.SetActorsStim(currScene, Actro)
    OSA.SetModule(CurrScene, "0Sex", StartingAnimation, "")
    OSA.StimStart(CurrScene)

    CurrentAnimation = "0Sx0MF_Ho-St6RevCud+01T180"
    LastHubOID = -1
    OnAnimationChange()

    If (LowLightLevelLightsOnly && DomActor.GetLightLevel() < 20) || (!LowLightLevelLightsOnly)
    	If (DomLightPos > 0)
    		lightActor(DomActor, DomLightPos, DomLightBrightness)
   		EndIf
    	If (SubLightPos > 0)
    		lightActor(SubActor, SubLightPos, SubLightBrightness)
   		EndIf
    EndIf

    If (EnableDomBar)
    	SetBarPercent(DomBar, 0.0)
    	SetBarVisible(DomBar, True)
	EndIf

	If (EnableSubBar)
		SetBarPercent(SubBar, 0.0)
    	SetBarVisible(SubBar, True)
	EndIf

	Int Password = DomActor.GetFactionRank(OsaFactionStage)
	RegisterForModEvent("0SAO" + Password + "_AnimateStage", "OnAnimate")

	If (GetActorArousal(DomActor) > 90)
		DomExcitement = 26.0
	EndIf

	If (GetActorArousal(SubActor) > 90)
		SubExcitement = 26.0
	EndIf

	If (AlwaysUndressAtAnimStart)
		UndressDom = True
		UndressSub = True
	EndIf

	If (AlwaysAnimateUndress)
		AnimateUndress = True
	EndIf

	DomArmor = DomActor.GetWornForm(0x00000004)
	DomHelm = DomActor.GetWornForm(0x00000002)
	DomGlove = DomActor.GetWornForm(0x00000080)
	DomBoot = DomActor.GetWornForm(0x00000008)
	DomWep = DomActor.GetEquippedObject(1)

	SubArmor = SubActor.GetWornForm(0x00000004)
	SubHelm = SubActor.GetWornForm(0x00000002)
	SubGlove = SubActor.GetWornForm(0x00000080)
	SubBoot = SubActor.GetWornForm(0x00000008)
	SubWep = SubActor.GetEquippedObject(1)

	If (UndressDom)
		If (AnimateUndress)
			If (OnlyUndressChest)
				AnimateUndressActor(DomActor, "cuirass")
			Else ; cuirass,boots,weapon,helmet,gloves.
				;/
				AnimateUndressActor(DomActor, "helmet")
				AnimateUndressActor(DomActor, "gloves")
				AnimateUndressActor(DomActor, "weapon")
				AnimateUndressActor(DomActor, "boots")
				/;
				AnimateUndressActor(DomActor, "cuirass")
				UndressActor(DomActor, DomHelm)
				UndressActor(DomActor, DomBoot)
				UndressActor(DomActor, DomGlove)
				DomActor.UnequipItem(DomWep, abPreventEquip = False, abSilent = True)
			EndIf
		Else
			If (OnlyUndressChest)
				UndressActor(DomActor, DomArmor)
			Else
				UndressActor(DomActor, DomHelm)
				UndressActor(DomActor, DomBoot)
				UndressActor(DomActor, DomGlove)
				UndressActor(DomActor, DomArmor)
				DomActor.UnequipItem(DomWep, abPreventEquip = False, abSilent = True)
			EndIf
		EndIf
	EndIf

	If (UndressSub)
		If (AnimateUndress)
			If (OnlyUndressChest)
				AnimateUndressActor(SubActor, "cuirass")
			Else
				;animateUndressActor(SubActor, "helmet")
				;animateUndressActor(SubActor, "gloves")
				;animateUndressActor(SubActor, "weapon")
				;animateUndressActor(SubActor, "boots")

				AnimateUndressActor(SubActor, "cuirass")
				UndressActor(SubActor, SubHelm)
				UndressActor(SubActor, SubBoot)
				UndressActor(SubActor, SubGlove)
				SubActor.UnequipItem(subwep, abPreventEquip = False, abSilent = True)
			EndIf
		Else
			If (OnlyUndressChest)
				UndressActor(SubActor, SubArmor)
			Else
				UndressActor(SubActor, SubHelm)
				UndressActor(SubActor, SubBoot)
				UndressActor(SubActor, SubGlove)
				UndressActor(SubActor, SubArmor)
				SubActor.UnequipItem(SubWep, abPreventEquip = False, abSilent = True)
			EndIf
		EndIf
	EndIf
	
	; Assume if sub is to be undressed, third actor should also be provided ThirdActor exists.
	if (UndressSub == True && ThirdActor != None)
		; undressing really needs to be its own function.
		ThirdArmor = ThirdActor.GetWornForm(0x00000004)
		ThirdHelm = ThirdActor.GetWornForm(0x00000002)
		ThirdGlove = ThirdActor.GetWornForm(0x00000080)
		ThirdBoot = ThirdActor.GetWornForm(0x00000008)
		ThirdWep = ThirdActor.GetEquippedObject(1)
		if (AnimateUndress)
			if (OnlyUndressChest)
				AnimateUndressActor(ThirdActor, "cuirass")
			Else
				;animateUndressActor(ThirdActor, "helmet")
				;animateUndressActor(ThirdActor, "gloves")
				;animateUndressActor(ThirdActor, "weapon")
				;animateUndressActor(ThirdActor, "boots")

				AnimateUndressActor(ThirdActor, "cuirass")
				UndressActor(ThirdActor, ThirdHelm)
				UndressActor(ThirdActor, ThirdBoot)
				UndressActor(ThirdActor, ThirdGlove)
				ThirdActor.UnequipItem(ThirdWep, abPreventEquip = False, abSilent = True)
			endif
			
		Else
			if (OnlyUndressChest)
				undressActor(ThirdActor, ThirdArmor)
			Else
				UndressActor(ThirdActor, ThirdHelm)
				UndressActor(ThirdActor, ThirdBoot)
				UndressActor(ThirdActor, ThirdGlove)
				UndressActor(ThirdActor, ThirdArmor)
				ThirdActor.UnequipItem(ThirdWep, abPreventEquip = False, abSilent = True)
			endif
		endif
	endIf

	StartTime = Utility.GetCurrentRealTime()

	Bool WaitForActorsTouch = (SubActor.GetDistance(DomActor) > 1)
	Int WaitCycles = 0
	While (WaitForActorsTouch)
		Utility.Wait(0.1)
		WaitCycles += 1
		WaitForActorsTouch = (SubActor.GetDistance(DomActor) > 1)

		If (WaitCycles > 50)
			WaitForActorsTouch = False
		EndIf
	EndWhile

	If (UseFreeCam)
		ToggleFreeCam(True)
	EndIf
	
	Float LoopTimeTotal = 0
	Float LoopStartTime
	SendModEvent("ostim_start")

	If (!AIRunning)
		If ((DomActor != PlayerRef) && (SubActor != PlayerRef) && (ThirdActor != PlayerRef) && UseAINPConNPC)
			Console("NPC on NPC scene detected. Starting AI")
			AI.StartAI()
			AIRunning = True
		ElseIf ((AggressiveActor == PlayerRef) && UseAIPlayerAggressor)
			Console("Player aggressor. Starting AI")
			AI.StartAI()
			AIRunning = True
		ElseIf ((AggressiveActor == getSexPartner(PlayerRef)) && UseAIPlayerAggressed)
			Console("Player aggressed. Starting AI")
			AI.StartAI()
			AIRunning = True
		ElseIf (UseAINonAggressive)
			Console("Non-aggressive scene. Starting AI")
			AI.StartAI()
			AIRunning = True
		EndIf
	EndIf

	If (UseFades && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Game.FadeOutGame(False, True, 0.0, 4) ;welcome back
	EndIf

	While (IsActorActive(DomActor))
		If (LoopTimeTotal > 1)
			;Console("Loop took: " + loopTimeTotal + " seconds")
			LoopTimeTotal = 0
		EndIf

		Utility.Wait(1.0 - LoopTimeTotal)
		LoopStartTime = Utility.GetCurrentRealTime()

    	If (AutoUndressIfNeeded)
    		UndressIfNeeded()
    	EndIf

    	If (MisallignmentProtection && IsActorActive(DomActor))
    		If (SubActor.GetDistance(DomActor) > 1)
    			Console("Misallignment detected")
    			SubActor.MoveTo(DomActor)

    			;WarpToAnimation(ODatabase.GetSceneIDByAnimID(CurrentAnimation))
    			;WarpToAnimation("0MF|Cy6!DOy6|Ho|DoggyLi")
    			Reallign()

    			Utility.Wait(0.1)
    			While ((SubActor.GetDistance(DomActor) > 1) && IsActorActive(DomActor))
    				Utility.Wait(0.5)
    				Console("Still misalligned... " + SubActor.GetDistance(DomActor))
    				Reallign()
    			EndWhile
    			Console("Realligned")
    		EndIf
    	EndIf

    	If (AutoHideBars && (GetTimeSinceLastPlayerInteraction() > 15.0)) ; fade out if needed
    		If (IsBarVisible(DomBar))
    			SetBarVisible(DomBar, False)
    		EndIf
    		If (IsBarVisible(SubBar))
    			SetBarVisible(SubBar, False)
    		EndIf
    	EndIf

    	If (EnableActorSpeedControl && !AnimationIsAtMaxSpeed())
    		AutoIncreaseSpeed()
    	EndIf

		DomExcitement += GetCurrentStimulation(DomActor)
		SubExcitement += GetCurrentStimulation(SubActor)
		SetBarPercent(DomBar, DomExcitement)
		SetBarPercent(SubBar, SubExcitement)

		If (SubExcitement >= 100.0)
			MostRecentOrgasmedActor = SubActor
			SubTimesOrgasm += 1
			Orgasm(SubActor)
			If (GetCurrentAnimationClass() == ClassSex)
				DomExcitement += 5
			EndIf
		EndIf

		If (DomExcitement >= 100.0)
			MostRecentOrgasmedActor = DomActor
			DomTimesOrgasm += 1
			Orgasm(DomActor)
			If (EndOnDomOrgasm)
				Utility.Wait(4)
				EndAnimation()
			EndIf
		EndIf

		;Console("Dom excitement: " + DomExcitement)
		;Console("Sub excitement: " + SubExcitement)
		LoopTimeTotal = Utility.GetCurrentRealTime() - LoopStartTime
	EndWhile

	Console("Ending scene")

	SendModEvent("ostim_end")
	If (EnableImprovedCamSupport)
		Game.EnablePlayerControls(abCamSwitch = True)
	EndIf

	ODatabase.Unload()

	If (FixFlippedAnimations)
		SubActor.SetDontMove(False)
		DomActor.SetDontMove(False)
	EndIf

	If (IsFreeCamming)
		ToggleFreeCam(False)
	EndIf

	If (ForceFirstPersonAfter && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Game.ForceFirstPerson()
	EndIf

	Utility.Wait(0.5)

	Redress()

	SetBarVisible(DomBar, False)
	SetBarPercent(DomBar, 0.0)
	SetBarVisible(SubBar, False)
	SetBarPercent(SubBar, 0.0)

	If (UsingBed)
		If (GetInBedAfterBedScene && ((DomActor == PlayerRef) || (SubActor == PlayerRef))  && EndedProper && !IsSceneAggressiveThemed())
			Actor Other = GetSexPartner(PlayerRef)
			Other.TranslateTo(SubX, SubY, SubZ, SubActor.GetAngleX(), SubActor.GetAngleY(), SubActor.GetAngleZ(), 1000)
			Utility.Wait(0.5)
			SleepInBed(Currentbed, PlayerRef) ; todo
		ElseIf (!IsBedRoll(Currentbed)) ; return back to position
			SubActor.TranslateTo(SubX, SubY, SubZ, SubActor.GetAngleX(), SubActor.GetAngleY(), SubActor.GetAngleZ(), 10000)
			DomActor.TranslateTo(DomX, DomY, DomZ, DomActor.GetAngleX(), DomActor.GetAngleY(), DomActor.GetAngleZ(), 10000)
			Utility.Wait(0.1)
		EndIf
	EndIf

	If (UseFades && EndedProper && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Game.FadeOutGame(False, True, 0.0, 2) ; welcome back
	EndIf

	UnRegisterForModEvent("0SAO" + Password + "_AnimateStage")
	UnRegisterForModEvent("0SSO" + _oGlobal.GetFormID_S(DomActor.GetActorBase()) + "_Sound")
	UnRegisterForModEvent("0SSO" + _oGlobal.GetFormID_S(SubActor.GetActorBase()) + "_Sound")

	If (ThirdActor)
		UnRegisterForModEvent("0SSO" + _oGlobal.GetFormID_S(ThirdActor.GetActorBase()) + "_Sound")
	EndIf

	If (OldTimescale > 0)
		Console("Resetting Timescale to: " + OldTimescale)
		SetTimeScale(OldTimescale)
	EndIf

	Console(Utility.GetCurrentRealTime() - StartTime + " seconds passed")
	SceneRunning = False
EndEvent


;
;			██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
;			██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
;			██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
;			╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
;			 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝
;
; 				The main API functions


Bool Function IsActorActive(Actor Act)
	Return Act.HasMagicEffect(Actra)
EndFunction

ODatabaseScript Function GetODatabase()
	While (!ODatabase)
		Utility.Wait(0.5)
	Endwhile
	Return ODatabase
EndFunction

Int Function GetCurrentAnimationSpeed()
	Return CurrentSpeed
EndFunction

Bool Function AnimationIsAtMaxSpeed()
	Return CurrentSpeed == GetCurrentAnimationMaxSpeed()
EndFunction

Int Function GetCurrentAnimationMaxSpeed()
	Return ODatabase.GetMaxSpeed(CurrentOID)
EndFunction

Int Function GetAPIVersion()
	;6 adds better animation flipping, reallign(), soundAPI
	;5 adds ODatabase, getCurrentLeadingActor
	;4 added onanimationchange event and decrease speed
	;3 introduces events and getmostrecentorgasmedactor
	Return 6
EndFunction

Function IncreaseAnimationSpeed()
	If (AnimSpeedAtMax)
		Return
	EndIf
	AdjustAnimationSpeed(1)
EndFunction

Function DecreaseAnimationSpeed()
	If (CurrentSpeed < 1)
		Return
	EndIf
	AdjustAnimationSpeed(-1)
EndFunction

Function AdjustAnimationSpeed(float amount)
	If amount < 0
		int times = math.abs((amount / 0.5)) as int
		While times > 0
			UI.Invokefloat("HUD Menu", "_root.WidgetContainer."+OSAOmni.Glyph+".widget.hud.NavMenu.beaconSpeed.m.dia.scena.speedAdjust", -0.5)
			times -= 1
		EndWhile
	Else
		UI.Invokefloat("HUD Menu", "_root.WidgetContainer."+OSAOmni.Glyph+".widget.hud.NavMenu.beaconSpeed.m.dia.scena.speedAdjust", amount)
	EndIf
EndFunction

Function SetCurrentAnimationSpeed(Int InSpeed) 
	AdjustAnimationSpeed(inspeed - CurrentSpeed)
EndFunction

String Function GetCurrentAnimation()
	Return CurrentAnimation
EndFunction

String Function GetCurrentAnimationClass()
	Return CurrAnimClass
EndFunction

Int Function GetCurrentAnimationOID()
	; the OID is the JMap ID of the current animation. You can feed this in to ODatabase
	Return CurrentOID
EndFunction

Function LightActor(Actor Act, Int Pos, Int Brightness) ; pos 1 - ass, pos 2 - face | brightness - 0 = dim
	If (Pos == 0)
		Return
	EndIf

	String Which
	If (Pos == 1) ; ass
		If (Brightness == 0)
			Which = "AssDim"
		Else
			Which = "AssBright"
		EndIf
	ElseIf (Pos == 2) ;face
		If (Brightness == 0)
			Which = "FaceDim"
		Else
			Which = "FaceBright"
		EndIf
	EndIf

	_oGlobal.ActorLight(Act, Which, OSAOmni.OLightSP, OSAOmni.OLightME)
EndFunction

Function TravelToAnimationIfPossible(String Animation) ; travel to animation is BUSTED beyond belief and even this doesn't fix it
	Int ID = ODatabase.GetAnimationsWithSceneID(ODatabase.GetDatabaseOArray(), Animation)
	ID = ODatabase.GetObjectOArray(ID, 0)
	Bool Transitory = ODatabase.IsTransitoryAnimation(ID)
	If (Transitory)
		WarpToAnimation(Animation)
	Else
		TravelToAnimation(Animation)
		If (True) ; Catch
			String Lastanimation
			String Lastlastanimation
			String Current = CurrentAnimation
			While (ODatabase.GetSceneIDByAnimID(CurrentAnimation) != Animation)
				Utility.Wait(1)
				If (Current != CurrentAnimation)
					LastLastAnimation = Lastanimation
					LastAnimation = Current
					Current = CurrentAnimation

					If (Current == LastLastAnimation)
						Console("Infinite loop during travel detected. Warping")
						WarpToAnimation(Animation)
					EndIf
				EndIf
			EndWhile
		EndIf
	EndIf
EndFunction

Function TravelToAnimation(String Animation) ; does not always work, use above
	Console("Attempting travel to: " + Animation)
	RunOsexCommand("$Go," + Animation)
EndFunction

Function WarpToAnimation(String Animation) ; a list of animation ids can be found in osa's xmls. you cannot use the id from getcurrentanimation()
	Console("Warping to animation: " + Animation)
	RunOsexCommand("$Warp," + Animation)
EndFunction

Function EndAnimation(Bool SmoothEnding = True)
	If (UseFades && SmoothEnding && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Float Time = 1
		Game.FadeOutGame(True, True, 0.0, Time)
		Utility.Wait(Time - 0.15)
		Game.FadeOutGame(False, True, 25.0, 25.0) ; total blackout
	EndIf
	EndedProper = SmoothEnding
	Console("Trying to end scene")
	RunOsexCommand("$endscene")
	;OSA.OGlyphO(".ctr.END")
EndFunction

Bool Function GetCurrentAnimIsAggressive() ; if the current animation is tagged aggressive
	Return CurrentAnimIsAggressive
EndFunction

Bool Function IsSceneAggressiveThemed() ; if the entire situation should be themed aggressively
	Return AggressiveThemedSexScene
EndFunction

Actor Function GetAggressiveActor()
	Return AggressiveActor
EndFunction

Function UndressAll(Actor Act) ; seems broke
	Int Acto = 0
	If (Act == SubActor)
		Acto = 1
	EndIf
	RunOsexCommand("$Equndressall," + Acto)
EndFunction

Function RedressAll(Actor Act) ; seems broke
	Int Acto = 0
	If (Act == SubActor)
		Acto = 1
	EndIf
	RunOsexCommand("$Eqredressall," + acto) ; seems broke
EndFunction

Function UndressActor(Actor Char, Form Item)
	Char.UnequipItem(Item, False, True)
EndFunction

Function AnimateUndressActor(Actor Char, String Item)
	; cuirass, boots, weapon, helmet, gloves.
	; some extra rare options: cape, intlow(i.e. panties), inthigh(i.e. bra), miscarms, misclow, miscmid, miscup, pants, stockings,
	; options other than cuirass are unreliable right now

	If (Item == "helmet")
		If !Char.GetWornForm(0x00000002) as Armor
			Return
		EndIf
	ElseIf (Item == "gloves")
		If (!Char.GetWornForm(0x00000008) as Armor)
			Return
		EndIf
	ElseIf (Item == "weapon")
		If (!Char.GetEquippedObject(1) as Form)
			Return
		EndIf
	ElseIf (Item == "boots")
		If (!Char.GetWornForm(0x00000080) as Armor)
			Return
		EndIf
	ElseIf (Item == "cuirass")
		If (!Char.GetWornForm(0x00000004) as Armor)
			Return
		EndIf
	EndIf

	String Target = "10"
	If (Char == SubActor)
		Target = "01"
	EndIf

	WarpToAnimation("EMF|Sy6!Sy9|ApU|St9Dally+" + Target + Item)

	Utility.Wait(1)
	While (GetCurrentAnimationClass() == ClassApartUndressing)
		Utility.Wait(1)
	Endwhile
EndFunction

Int Function GetTimesOrgasm(Actor Act) ; number of times the Actor has orgasmed
	If (Act == DomActor)
		Return DomTimesOrgasm
	ElseIf (Act == SubActor)
		Return SubTimesOrgasm
	EndIf
EndFunction

Function WaitForRemoveCuirass(Actor Char) ; remove the cuirass, and don't return until anim is done
	If (IsNaked(Char))
		Return
	EndIf
	AnimateUndressActor(Char, "cuirass")
	While (!IsNaked(Char))
		Utility.Wait(1)
	Endwhile
	Utility.wait(4)
EndFunction

Bool Function IsNaked(Actor NPC) ; todo caching
	Return (!(NPC.GetWornForm(0x00000004) as Bool))
EndFunction

Actor Function GetSexPartner(Actor Char)
	If (Char == SubActor)
		Return DomActor
	EndIf
	Return SubActor
EndFunction

Actor Function GetDomActor()
	Return DomActor
EndFunction

Actor Function GetSubActor()
	Return SubActor
EndFunction

Actor Function GetThirdActor()
	Return ThirdActor
EndFunction

Int Function GetActorArousal(Actor Char)
	Int Ret = 50
	If (ArousedFaction)
		Ret = Char.GetFactionRank(ArousedFaction)
	EndIf

	If (Ret < 0) ; not yet set
		Ret = 50
	EndIf
	Return Ret
EndFunction

Function SetActorArousal(Actor Char, Int Level) ; wrong way to do this, may not work
	If (ArousedFaction)
		If (Level < 1)
			Level = 1
		EndIf
		Char.SetFactionRank(ArousedFaction, Level)
	EndIf
EndFunction

Actor Function GetMostRecentOrgasmedActor()
	Return MostRecentOrgasmedActor
EndFunction

Function RunOsexCommand(String CMD)
	String[] Plan = new String[2]
	Plan[1] = CMD

	OSA.SetPlan(CurrScene, Plan)
	OSA.StimStart(CurrScene)
EndFunction

Float Function GetTimeSinceLastPlayerInteraction()
	Return Utility.GetCurrentRealTime() - MostRecentOSexInteractionTime
EndFunction

Bool Function UsingBed()
	Return Usingbed
EndFunction

ObjectReference Function GetBed()
	Return Currentbed
EndFunction

Bool Function IsFemale(Actor Act)
	If (Sexlab)
		;If (SexLab.GetGender(Act) == 0)
		;	Return False
		;Else
		;	Return True
		;EndIf
	EndIf
	Return (Act.GetLeveledActorBase().GetSex() == 1)
EndFunction

Bool Function AppearsFemale(Actor Act)
	Return (Act.GetLeveledActorBase().GetSex() == 1)
EndFunction

Actor Function GetCurrentLeadingActor()
	; in a blowjob type animation, it would be the female, while in most sex animations, it will be the male
	Int ActorNum = ODatabase.GetMainActor(CurrentOID)
	If (ActorNum == 0)
		Return DomActor
	EndIf
	Return SubActor
EndFunction

Bool Function AnimationRunning()
	Return SceneRunning
EndFunction

Bool Function IsVaginal()
	Return (GetCurrentAnimationClass() == ClassSex)
EndFunction

String[] Function GetScene() ; this is not the sceneID, this is an internal osex thing
	Return CurrScene
EndFunction

Function Reallign()
	SendModEvent("0SAA" + _oGlobal.GetFormID_S(DomActor.GetActorBase()) + "_AlignStage") ; unknown if this works on bandits
	SendModEvent("0SAA" + _oGlobal.GetFormID_S(SubActor.GetActorBase()) + "_AlignStage")
	If (ThirdActor)
		SendModEvent("0SAA" + _oGlobal.GetFormID_S(ThirdActor.GetActorBase()) + "_AlignStage")
	EndIf
EndFunction

Function UndressIfNeeded()
	Bool DomNaked = IsNaked(DomActor)
	Bool SubNaked = IsNaked(SubActor)
	Bool ThirdNaked = true
	if ThirdActor
		ThirdNaked = IsNaked(ThirdActor)
	endif
	String CClass = GetCurrentAnimationClass()
	If (!DomNaked)
		If (CClass == ClassSex) || (CClass == ClassMasturbate) || (CClass == ClassHeadHeldMasturbate) || (CClass == ClassPenisjob) || (CClass == ClassHeadHeldPenisjob) || (CClass == ClassHandjob) || (CClass == ClassApartHandjob) || (CClass == ClassDualHandjob) || (CClass == ClassSelfSuck)
			UndressAllItems(domactor)
		EndIf
	ElseIf (!SubNaked)
		If (CClass == ClassSex) || (CClass == ClassCunn) || (CClass == ClassClitRub) || (CClass == ClassOneFingerPen) || (CClass == ClassTwoFingerPen)
			UndressAllItems(subactor)
		EndIf
	ElseIf (!ThirdNaked)
		If (CClass == ClassSex) || (CClass == ClassCunn) || (CClass == ClassClitRub) || (CClass == ClassOneFingerPen) || (CClass == ClassTwoFingerPen)
			UndressAllItems(ThirdActor)
		EndIf
	EndIf
EndFunction

Function UndressAllItems(Actor Act) ; will be moved to a different script in a later version so do not call!
	bool DidToggle = False
	If IsFreeCamming
		DidToggle = True
		ToggleFreeCam()
	EndIf

	form zArmor = Act.GetWornForm(0x00000004)
	form zHelm = Act.GetWornForm(0x00000002)
	form zGlove = Act.GetWornForm(0x00000080)
	form zBoot = Act.GetWornForm(0x00000008)
	form zWep = Act.GetEquippedObject(1)
	
	UndressActor(Act, zHelm)
	UndressActor(Act, zBoot)
	UndressActor(Act, zGlove)
	UndressActor(Act, zArmor)
	Act.UnequipItem(zWep, abPreventEquip = False, abSilent = True)

	If DidToggle
		ToggleFreeCam()
	EndIf	
	Console("Doing mid-animation strip")
Endfunction

Function ToggleFreeCam(Bool On = True)
	ConsoleUtil.ExecuteCommand("tfc")
	If (!IsFreeCamming)
		ConsoleUtil.ExecuteCommand("sucsm " + FreecamSpeed)
		ConsoleUtil.ExecuteCommand("fov " + FreecamFOV)
	Else
		ConsoleUtil.ExecuteCommand("fov " + DefaultFOV)
	EndIf
	IsFreeCamming = !IsFreeCamming
EndFunction

Function HideNavMenu() ;only works during SEX animations
	UI.Invoke("HUD Menu", "_root.WidgetContainer."+OSAomni.glyph+".widget.hud.NavMenu.dim") 
EndFunction

Function ShowNavMenu() ;only works during SEX animations
	UI.Invoke("HUD Menu", "_root.WidgetContainer."+OSAomni.glyph+".widget.hud.NavMenu.light") 
EndFunction

bool function GetGameIsVR()
	return (PapyrusUtil.GetScriptVersion() == 36) ;obviously this no guarantee but it's the best we've got for now
endfunction


;
;			██████╗ ███████╗██████╗ ███████╗
;			██╔══██╗██╔════╝██╔══██╗██╔════╝
;			██████╔╝█████╗  ██║  ██║███████╗
;			██╔══██╗██╔══╝  ██║  ██║╚════██║
;			██████╔╝███████╗██████╔╝███████║
;			╚═════╝ ╚══════╝╚═════╝ ╚══════╝
;
;				Code related to beds


ObjectReference Function FindBed(ObjectReference CenterRef, Float Radius = 0.0)
	If !(Radius > 0.0)
		Radius = BedSearchDistance * 64.0
	EndIf

	ObjectReference[] Beds
	If (!UseAlternateBedSearch) && (UseNativeFunctions)
		Console("Using native bed search")
		Beds = OSANative.FindBed(CenterRef, Radius, 96.0)
	Else
		Console("Using papyrus bed search")
		Beds = MiscUtil.ScanCellObjects(40, CenterRef, Radius, Keyword.GetKeyword("RaceToScale"))
	EndIf

	ObjectReference NearRef = None

	Int i = 0
	Int L = Beds.Length
	If (!UseAlternateBedSearch) && (UseNativeFunctions)
		While (i < L)
			ObjectReference Bed = Beds[i]
			If (!Bed.IsFurnitureInUse())
				NearRef = Bed
				i = L
			Else
				i += 1
			EndIf
		EndWhile
	Else
		Float Z = CenterRef.GetPositionZ()
		While (i < L)
			ObjectReference Bed = Beds[i]
			If (IsBed(Bed) && !Bed.IsFurnitureInUse() && SameFloor(Bed, Z))
				If (!NearRef)
					NearRef = Bed
				Else
					If (NearRef.GetDistance(CenterRef) > Bed.GetDistance(CenterRef))
						NearRef = Bed
					EndIf
				EndIf
			EndIf
			i += 1
		EndWhile
	EndIf

	If (NearRef)
		Console("Bed found")
		;PrintBedInfo(NearRef)
		Return NearRef
	EndIf

	Console("Bed not found")
	Return None ; Nothing found in search loop
EndFunction

Bool Function SameFloor(ObjectReference BedRef, Float Z, Float Tolerance = 128.0)
	Return (Math.Abs(Z - BedRef.GetPositionZ())) <= Tolerance
EndFunction

Bool Function CheckBed(ObjectReference BedRef, Bool IgnoreUsed = True)
	Return BedRef && BedRef.IsEnabled() && BedRef.Is3DLoaded()
EndFunction

Bool Function IsBed(ObjectReference Bed) ; trick so dirty it could only be in an adult mod
	If (Bed.GetDisplayName() == "Bed") || (Bed.Haskeyword(Keyword.GetKeyword("FurnitureBedRoll"))) || (Bed.GetDisplayname() == "Bed (Owned)")
		Return True
	EndIf
	Return False
EndFunction

Bool Function IsBedRoll(objectReference Bed)
	Return (Bed.Haskeyword(Keyword.GetKeyword("FurnitureBedRoll")))
EndFunction

Function AllignActorsWithCurrentBed()
	DomActor.SetDontMove(True)
	SubActor.SetDontMove(True)
	if ThirdActor
		thirdActor.SetDontMove(true)
	endif

	Bool BedRoll = IsBedRoll(Currentbed)
	Bool Flip = !BedRoll

	Float FlipFloat = 0
	If (Flip)
		FlipFloat = 180
	EndIf

	Float DomSpeed = CurrentBed.GetDistance(DomActor) * 100
	Float BedOffsetX = 0
	Float BedOffsetY = 0
	Float BedOffsetZ = 0

	If (!BedRoll)
		Console("Current bed is not a bedroll. Moving actors backwards a bit")

		Int Offset = 31 + BedReallignment
		If (SubActor == PlayerRef)
			Console("Player is SubActor. Adding some extra bed offset")
			Offset += 36
		EndIf

		BedOffsetX = Math.Cos(TrigAngleZ(CurrentBed.GetAngleZ())) * Offset
		BedOffsetY = Math.Sin(TrigAngleZ(CurrentBed.GetAngleZ())) * Offset
		BedOffsetZ = 42
	Else
		Console("Bedroll. Not realigning")
	EndIf

	Float BedX = CurrentBed.GetPositionX() + BedOffsetX
	Float BedY = Currentbed.GetPositionY() + BedOffsetY
	Float BedZ = CurrentBed.GetPositionZ() + BedOffsetZ
	Float BedAngleX = Currentbed.GetAngleX()
	Float BedAngleY = Currentbed.GetAngleY()
	Float BedAngleZ = Currentbed.GetAngleZ()

	DomActor.TranslateTo(BedX, BedY, BedZ, BedAngleX, BedAngleY, BedAngleZ, DomSpeed, afMaxRotationSpeed = 100)
	DomActor.SetAngle(BedAngleX, BedAngleY, BedAngleZ - FlipFloat)
	If (UseFades && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Game.FadeOutGame(False, True, 10.0, 5) ; keep the screen black
	EndIf

	Utility.Wait(0.05)

	Float OffsetY = Math.Sin(TrigAngleZ(DomActor.GetAngleZ())) * 30
	Float OffsetX = Math.Cos(TrigAngleZ(DomActor.GetAngleZ())) * 30

	SubActor.MoveTo(DomActor, OffsetX, OffsetY, 0)
	SubActor.SetAngle(BedAngleX, BedAngleY, BedAngleZ - FlipFloat)

	If (UseFades && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Game.FadeOutGame(False, True, 10.0, 5) ; keep the screen black
	EndIf

	if ThirdActor
		Utility.Wait(0.05)

		OffsetY = Math.Sin(TrigAngleZ(DomActor.GetAngleZ())) * 30
		OffsetX = Math.Cos(TrigAngleZ(DomActor.GetAngleZ())) * 30

		ThirdActor.MoveTo(DomActor, OffsetX, OffsetY, 0)
		ThirdActor.SetAngle(BedAngleX, BedAngleY, BedAngleZ - FlipFloat)

		ThirdActor.SetDontMove(false)
	endif

	DomActor.SetDontMove(False)
	SubActor.SetDontMove(False)
EndFunction

Float Function TrigAngleZ(Float GameAngleZ)
	If (GameAngleZ < 90)
		 Return (90 - GameAngleZ)
	EndIf
 	Return (450 - GameAngleZ)
EndFunction

Function SleepInBed(ObjectReference Bed, Actor Act) ; requires GoToBed
	If (Act == PlayerRef)
		ActorBase ActBase = PlayerRef.GetActorBase()
		If (Bed.GetActorOwner() != ActBase)
			Bed.SetActorOwner(ActBase)
			Console("Setting bed owner to player")
		EndIf

		ConsoleUtil.SetSelectedReference(PlayerRef)
		Debug.ToggleCollisions()

		Int i = 0
		While ((Game.GetCurrentCrosshairRef() != Bed) && (i < 20))
			Utility.Wait(0.1)
			ConsoleUtil.ExecuteCommand("setangle x 75")
			i += 1
		EndWhile

		Debug.ToggleCollisions()
		ConsoleUtil.SetSelectedReference(None)
    	Input.TapKey(Input.GetMappedKey("Activate"))

    	If (UseFades)
			Game.FadeOutGame(False, True, 25.0, 25.0) ; total blackout
		EndIf

    	Float x = Act.X
		Utility.Wait(0.3)

    	i = 0
		While ((x != Act.X) && (i < 200))
			i += 1
    		x = Act.X

    		Utility.Wait(0.1)
    		Console("Waiting for player to stop moving")
    	EndWhile
	EndIf
EndFunction

Function Flip()
	Console("Flipping")
	IsFlipped = !IsFlipped

	ObjectReference Stage = GetOSAStage()

	Stage.SetAngle(Stage.GetAngleX(), Stage.GetAngleY(), Stage.GetAngleZ() + 180) ; flip stage

	DomActor.SetAngle(0, 0, Stage.GetAngleZ()) ; reangle
	SubActor.SetAngle(0, 0, Stage.GetAngleZ())

	DomActor.TranslateTo(Stage.x, Stage.y, Stage.z, 0, 0, Stage.GetAngleZ(), 150.0, 0) ; move into place
	SubActor.TranslateTo(Stage.x, Stage.y, Stage.z, 0, 0, Stage.GetAngleZ(), 150.0, 0)

	DomActor.SetVehicle(Stage)  ; fuse
	SubActor.SetVehicle(Stage)
EndFunction

ObjectReference Function GetOSAStage() ; the stage is an invisible object that the actors are alligned on
	Int StageID = DomActor.GetFactionRank(OSAOmni.OFaction[1])
	ObjectReference stage = OSAOmni.GlobalPosition[StageID as Int]
	Return Stage
EndFunction

Function PrintBedInfo(ObjectReference Bed)
	Console("--------------------------------------------")
	Console("BED - Name: " + Bed.GetDisplayName())
	Console("BED - Enabled: " + Bed.IsEnabled())
	Console("BED - 3D loaded: " + Bed.Is3DLoaded())
	Console("BED - Bed roll: " + IsBedRoll(Bed))
	Console("--------------------------------------------")
EndFunction


;
;			███████╗██████╗ ███████╗███████╗██████╗     ██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
;			██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗    ██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
;			███████╗██████╔╝█████╗  █████╗  ██║  ██║    ██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
;			╚════██║██╔═══╝ ██╔══╝  ██╔══╝  ██║  ██║    ██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
;			███████║██║     ███████╗███████╗██████╔╝    ╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
;			╚══════╝╚═╝     ╚══════╝╚══════╝╚═════╝      ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝
;
;				Some code related to the speed system


Bool CurrAnimHasIdleSpeed
Function AutoIncreaseSpeed()
	If (GetTimeSinceLastPlayerInteraction() < 5.0)
		Return
	EndIf

	String CClass = GetCurrentAnimationClass()
    Float MainExcitement = GetActorExcitement(DomActor)
    If (CClass == "VJ") || (CClass == "Cr") || (CClass == "Pf1") || (CClass == "Pf2")
    	MainExcitement = GetActorExcitement(SubActor)
	EndIf

    Int MaxSpeed = GetCurrentAnimationMaxSpeed()
	Int NumSpeeds = MaxSpeed

    Int AggressionBonusChance = 0
    If (IsSceneAggressiveThemed())
    	AggressionBonusChance = 80
    	MainExcitement += 20
    EndIf

	Int Speed = GetCurrentAnimationSpeed()
    If (!CurrAnimHasIdleSpeed)
    	NumSpeeds += 1
    ElseIf (Speed == 0)
    	Return
    EndIf

    If ((MainExcitement >= 85.0) && (Speed < NumSpeeds))
    	If (ChanceRoll(80))
    		IncreaseAnimationSpeed()
    	EndIf
    ElseIf (MainExcitement >= 69.0) && (Speed <= (NumSpeeds - 1))
    	If (ChanceRoll(50))
    		IncreaseAnimationSpeed()
    	EndIf
    ElseIf (MainExcitement >= 25.0) && (Speed <= (NumSpeeds - 2))
    	If (ChanceRoll(20 + AggressionBonusChance))
    		IncreaseAnimationSpeed()
    	EndIf
    ElseIf (MainExcitement >= 05.0) && (Speed <= (NumSpeeds - 3))
    	If (ChanceRoll(20 + AggressionBonusChance))
    		IncreaseAnimationSpeed()
    	EndIf
    EndIf
EndFunction

String Function NormalSpeedToOsexSpeed(Int Speed)
	Return Speeds[Speed]
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


Event OnAnimate(String EventName, String zAnimation, Float NumArg, Form Sender)
	If (CurrentAnimation != zAnimation)
		CurrentAnimation = zAnimation
		OnAnimationChange()
		SendModEvent("ostim_animationchanged")
	EndIf
EndEvent

Function OnAnimationChange()
	Console("Changing animation...")

	CurrentOID = ODatabase.GetObjectOArray(ODatabase.GetAnimationWithAnimID(ODatabase.GetDatabaseOArray(), CurrentAnimation), 0)
	If (ODatabase.IsHubAnimation(CurrentOID))
		LastHubOID = CurrentOID
		Console("On new hub animation")
	EndIf

	CurrentAnimIsAggressive = ODatabase.IsAggressive(CurrentOID)
	CurrAnimHasIdleSpeed = ODatabase.HasIdleSpeed(CurrentOID)

	String[] Split = PapyrusUtil.StringSplit(CurrentAnimation, "_")
	If (Split.Length > 2)
		String SpeedString = Split[2]
		CurrentSpeed = SpeedStringToInt(SpeedString)
	Else
		CurrentSpeed = 0
	EndIf

	String CClass = PapyrusUtil.StringSplit(Split[1], "-")[0]
	If (StringUtil.Find(CClass, "Ag") != -1)
		CClass = StringUtil.Substring(CClass, 2)
	EndIf

	CurrAnimClass = CClass

	If (FixFlippedAnimations)
		If (!StringArrayContainsValue(ODatabase.OriginalModules, ODatabase.GetModule(CurrentOID)))
			Console("On third party animation")
			If (!IsFlipped)
				If (StringUtil.Find(ODatabase.getFullName(CurrentOID), "noflip") == -1)
					Flip()
				EndIf
			EndIf
		Else
			If (IsFlipped)
				Console("Back on first-party animation")
				Flip()
			EndIf
		EndIf
	EndIf

	int CorrectActorCount = ODatabase.GetNumActors(currentoid)

	If !ThirdActor && (CorrectActorCount == 3) ; no third actor, but there should be
		Console("Third actor has joined scene ")

		actor[] nearbyActors = MiscUtil.ScanCellNPCs(domactor, radius = 64.0) ;epic hackjob time
		int max = nearbyActors.Length
		int i = 0

		while i < max
			actor act = nearbyActors[i]

			if (act != DomActor) && (act != SubActor) && (IsActorActive(act))
				ThirdActor = act
				i = max
			endif
			i += 1
		EndWhile

		If ThirdActor
			Console("Third actor: + " + ThirdActor.GetDisplayName() + " has joined the scene")

			If AlwaysUndressAtAnimStart
				UndressAllItems(ThirdActor)
			EndIf
		Else
			Console("Warning - Third Actor not found")
		endif

	ElseIf ThirdActor && (CorrectActorCount == 2) ; third actor, but there should not be.
		Console("Third actor has left the scene")
		ThirdActor = none
	EndIf

	Console("Current animation: " + CurrentAnimation)
	Console("Current speed: " + CurrentSpeed)
	Console("Current animation class: " + CurrAnimClass)
EndFunction

Function OnSpank()
	Console("Spank event recieved")

	If (AllowUnlimitedSpanking)
		SubExcitement += 5
	Else
		If (SpankCount < SpankMax)
			SubExcitement += 5
		Else
			SubActor.DamageAV("health", 5.0)
		EndIf
	EndIf

	SpankCount += 1
EndFunction

Function Redress()
	If (DomHelm)
		DomActor.EquipItem(DomHelm, False, True)
	EndIf
	If (DomGlove)
		DomActor.EquipItem(DomGlove, False, True)
	EndIf
	If (DomArmor)
		DomActor.EquipItem(DomArmor, False, True)
	EndIf
	If (DomBoot)
		DomActor.EquipItem(DomBoot, False, True)
	EndIf
	If (DomWep)
		DomActor.EquipItem(DomWep, False, True)
	EndIf
	If (SubHelm)
		SubActor.EquipItem(SubHelm, False, True)
	EndIf
	If (SubGlove)
		SubActor.EquipItem(SubGlove, False, True)
	EndIf
	If (SubArmor)
		SubActor.EquipItem(SubArmor, False, True)
	EndIf
	If (SubBoot)
		SubActor.EquipItem(SubBoot, False, True)
	EndIf
	If (SubWep)
		SubActor.EquipItem(SubWep, False, True)
	EndIf
	If (ThirdHelm)
		ThirdActor.EquipItem(ThirdHelm, False, True)
	EndIf
	If (ThirdGlove)
		ThirdActor.EquipItem(ThirdGlove, False, True)
	EndIf
	If (ThirdArmor)
		ThirdActor.EquipItem(ThirdArmor, False, True)
	EndIf
	If (ThirdBoot)
		ThirdActor.EquipItem(ThirdBoot, False, True)
	EndIf
	If (ThirdWep)
		ThirdActor.EquipItem(ThirdWep, False, True)
	EndIf
	; This can't possibly be the best way to do this.
EndFunction

Event OnActorHit(String EventName, String zAnimation, Float NumArg, Form Sender)
	If (EndAfterActorHit)
		EndAnimation(False)
	EndIf
EndEvent

;
;			███████╗████████╗██╗███╗   ███╗██╗   ██╗██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
;			██╔════╝╚══██╔══╝██║████╗ ████║██║   ██║██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
;			███████╗   ██║   ██║██╔████╔██║██║   ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
;			╚════██║   ██║   ██║██║╚██╔╝██║██║   ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
;			███████║   ██║   ██║██║ ╚═╝ ██║╚██████╔╝███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
;			╚══════╝   ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
;
;				All code related to the stimulation simulation


Float Function GetCurrentStimulation(Actor Act) ; how much an Actor is being stimulated in the current animation
	Float Ret = 0.0
	String CClass = GetCurrentAnimationClass()
	;Bool Aggressive = GetCurrentAnimIsAggressive()
	Bool Sub = (Act == SubActor)
	Float Excitement = GetActorExcitement(Act)

	If (CClass == ClassSex)
		If (Sub)
			Ret = GetInteractionStim(Penis, Vagina)
			If (Excitement > 75.0) ; extra lubrication increases enjoyment
				Ret += 0.2
			Elseif (Excitement < 25.0)
				Ret -= 0.2
			EndIf
		Else
			Ret = GetInteractionStim(Vagina, Penis)
		EndIf
	ElseIf ((CClass == ClassHolding) || (CClass == ClassApartUndressing) || (CClass == ClassRoughHolding)) ; Lightly exciting
		If (Excitement > 50.0)
			Ret = -1.0
		EndIf
	ElseIf (CClass == ClassEmbracing) ; more lightly exciting
		If (Excitement > 75.0)
			Ret = -1.0
		EndIf
	ElseIf (CClass == ClassApart)
		If (Excitement > 25.0)
			Ret = -1.0
		EndIf
	ElseIf ((CClass == ClassMasturbate) || (CClass == ClassHeadHeldMasturbate))
		If (Sub)
			Ret = 0.0
		Else
			Ret = GetInteractionStim(Hand, Penis)
		EndIf
	ElseIf (CClass == ClassCunn)
		If (Sub)
			If (ChanceRoll(50))
				Ret = GetInteractionStim(Mouth, Clit)
			Else
				Ret = GetInteractionStim(Mouth, Vagina)
			EndIf
		Else
			Ret = 0.0
		EndIf
	ElseIf ((CClass == ClassPenisjob) || (CClass == ClassHeadHeldPenisjob))
		If (Sub)
			Ret = 0.0
		Else
			If (ChanceRoll(10))
				Ret = GetInteractionStim(Hand, Penis) + (GetInteractionStim(Mouth, Penis) - 1.0)
			Else
				Ret = GetInteractionStim(Mouth, Penis)
			EndIf
		EndIf
	ElseIf (CClass == ClassHandjob) || (CClass == ClassApartHandjob) || (CClass == ClassDualHandjob)
		If (Sub)
			Ret = 0.0
		Else
			Ret = GetInteractionStim(Hand, Penis)
		EndIf
	ElseIf (CClass == ClassBlowjob) || (CClass == ClassHeadHeldBlowjob)
		If (Sub)
			Ret = 0.0
		Else
			Ret = GetInteractionStim(Mouth, Penis)
		EndIf
	ElseIf (CClass == Class69Handjob)
		If (Sub)
			If GetCurrentAnimationSpeed() == 1
				If chanceRoll(30)
					Ret = GetInteractionStim(Mouth, Clit)
				Else
					Ret = GetInteractionStim(Mouth, Vagina)
				EndIf
			Else
				Ret = 0.0 ;this animation is broken
			EndIf
		Else
			Ret = GetInteractionStim(Hand, Penis)
		EndIf
	ElseIf (CClass == Class69Blowjob)
		If (Sub)
			If (GetCurrentAnimationSpeed() == 1)
				If (ChanceRoll(30))
					Ret = GetInteractionStim(Mouth, Clit)
				Else
					Ret = GetInteractionStim(Mouth, Vagina)
				EndIf
			Else
				Ret = 0.0 ;this animation is broken
			EndIf
		Else
			Ret = GetInteractionStim(Mouth, Penis)
		EndIf
	ElseIf (CClass == ClassClitRub)
		If (Sub)
			Ret = GetInteractionStim(Hand, Clit)
		Else
			Ret = 0.0
		EndIf
	ElseIf (CClass == ClassOneFingerPen)
		If (Sub)
			Ret = GetInteractionStim(Hand, Vagina)
		Else
			Ret = 0.0
		EndIf
	ElseIf (CClass == ClassTwoFingerPen)
		If (Sub)
			Ret = GetInteractionStim(Hand, Vagina) * 1.5
		Else
			Ret = 0.0
		EndIf
	ElseIf (CClass == ClassSelfSuck)
		If (Sub)
			Ret = 0.0
		Else
			Ret = GetInteractionStim(Mouth, Penis)
		EndIf
	ElseIf (CClass == ClassAnal)
		If (Sub)
			If (IsFemale(GetSubActor()))
				Ret = (GetInteractionStim(Penis, Anus))
			Else
				Ret = (GetInteractionStim(Penis, Prostate)) + (GetInteractionStim(Penis, Anus))
			EndIf
		Else
			Ret = GetInteractionStim(Anus, Penis)
		EndIf
	ElseIf (CClass == ClassFootjob)
		If (Sub)
			Ret = GetInteractionStim(Penis, Feet)
		Else
			Ret = GetInteractionStim(Feet, Penis)
		EndIf
	ElseIf (CClass == ClassBoobjob)
		If (Sub)
			Ret = GetInteractionStim(Penis, Breasts)
		Else
			Ret = GetInteractionStim(Breasts, Penis)
		EndIf
	ElseIf (CClass == ClassBreastFeeding)
		If (Sub)
			Ret = GetInteractionStim(Mouth, Breasts)
		Else
			Ret = GetInteractionStim(Breasts, Mouth)
		EndIf
	Else
		If (GetCurrentAnimation() == "undefined") ;osex broke!
			Console("Osex state broken. Returning to default animation")
			WarpToAnimation("0MF|Cy6!DOy6|Ho|DoggyLi")
		Else
			Console("Unknown animation class: " + CClass + ". Please report this to the dev!")
		EndIf
	EndIf

	If (Ret > 0.0)
		Int Speed = GetCurrentAnimationSpeed()
		Int NumSpeeds = GetCurrentAnimationMaxSpeed()

		If (!CurrAnimHasIdleSpeed)
			NumSpeeds += 1
		EndIf

		If (ArousedFaction)
			Float Arousal = GetActorArousal(Act)
			Arousal -= 50.0
			Arousal /= 250
			; 100 arousal -> 0.2 ~ 0 arousal -> -0.2
			Ret += Arousal
		EndIf

		If (!IsNaked(GetSexPartner(Act)))
			Ret -= 0.1
		EndIf

		Int HalfwaySpeed = (Math.Ceiling((NumSpeeds as Float) / 2.0)) as Int ; 5 -> 3 | 3 -> 2 etc
		If (Speed == (HalfwaySpeed - 2))
			Ret -= 0.4
		ElseIf (Speed == (HalfwaySpeed - 1))
			Ret -= 0.2
		ElseIf (Speed == (HalfwaySpeed))
			;do nothing
		ElseIf (Speed == (HalfwaySpeed + 1))
			Ret += 0.2
		ElseIf (Speed == (HalfwaySpeed + 2))
			Ret += 0.4
		EndIf

		If ((Speed == 0) && CurrAnimHasIdleSpeed)
			Ret = 0.0
		EndIf
	EndIf

	If (Ret > 0.0)
		Ret *= SexExcitementMult
	EndIf

	Return Ret
EndFunction

Float Function GetInteractionStim(Int Stimulator, Int Stimulated) ; holds interaction between body parts
	Float[] StimulatorValues

	If (Stimulator == Penis)
		StimulatorValues = PenisStimValues
	ElseIf (Stimulator == Vagina)
		StimulatorValues = VaginaStimValues
	ElseIf (Stimulator == Mouth)
		StimulatorValues = MouthStimValues
	ElseIf (Stimulator == Hand)
		StimulatorValues = HandStimValues
	ElseIf (Stimulator == Clit)
		StimulatorValues = ClitStimValues
	ElseIf (Stimulator == Anus)
		StimulatorValues = AnusStimValues
	ElseIf (Stimulator == Feet)
		StimulatorValues = FeetStimValues
	ElseIf (Stimulator == Breasts)
		StimulatorValues = BreastsStimValues
	ElseIf (Stimulator == Prostate)
		StimulatorValues = ProstateStimValues
	Else
		Console("Unknown Stimulator")
	EndIf

	Return StimulatorValues[Stimulated]
EndFunction

Float Function GetActorExcitement(Actor Act) ; at 100, Actor orgasms
	If (Act == DomActor)
		Return DomExcitement
	ElseIf (Act == SubActor)
		Return SubExcitement
	Else
		Debug.Notification("Unknown Actor")
	EndIf
EndFunction

Function SetActorExcitement(Actor Act, Float Value)
	If (Act == DomActor)
		DomExcitement = Value
	ElseIf Act == SubActor
		SubExcitement = Value
	Else
		Debug.Notification("Unknown Actor")
	EndIf
EndFunction

Function Orgasm(Actor Act)
	SetActorExcitement(Act, -3.0)
	SendModEvent("ostim_orgasm")
	OrgasmSound.Play(Act)
	If (Act == PlayerRef)
		NutEffect.Apply()
		If (SlowMoOnOrgasm)
			SetGameSpeed("0.3")
			Utility.Wait(2.5)
			SetGameSpeed("1")
		EndIf
		Game.ShakeCamera(None, 1.00, 2.0)
		ShakeController(0.5, 0.7)
	EndIf

	Utility.Wait(0.75)

	If (SexLab && !IsFemale(Act)) ; spray cum
		If (IsVaginal() || (GetCurrentAnimationClass() == ClassMasturbate))
			ApplyCum(GetSexPartner(Act), True)
		Else
			ApplyCum(GetSexPartner(Act), False)
		EndIf
	EndIf

	If (Act == DomActor)
		SetCurrentAnimationSpeed(1)
	EndIf

	If (OrgasmIncreasesRelationship)
		Actor Partner = GetSexPartner(Act)
		Int Rank = Act.GetRelationshipRank(Partner)
		If (Rank == 0)
			Act.SetRelationshipRank(Partner, 1)
		EndIf
	EndIf

	SetActorArousal(Act, GetActorArousal(Act) - 50)

	If (Act == DomActor)
		SetBarPercent(DomBar, 0)
	ElseIf (Act == SubActor)
		SetBarPercent(SubBar, 0)
	EndIf

	Act.DamageAV("stamina", 250.0)
EndFunction

Function ApplyCum(Actor Act, Bool Vaginal)
	Spell Vaginal1 = (Game.GetFormFromFile(0x0008D679, "SexLab.esm")) as Spell
	Spell Oral1 = (Game.GetFormFromFile(0x0008D67D, "SexLab.esm")) as Spell

	If (Vaginal)
		Vaginal1.Cast(Act)
	Else
		Oral1.Cast(Act)
	EndIf
EndFunction

;Function HideOSexMenu()
;	Console("hide")
;	Int Glyph = OSAOmni.Glyph
;	UI.Invoke("HUD Menu", "_root.WidgetContainer." + Glyph + ".widget.ctr.sceneMenuDirect")
;EndFunction

;Function ShowOSexMenu()
;	UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", False)
;EndFunction


;			███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗
;			██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗
;			███████╗██║   ██║██║   ██║██╔██╗ ██║██║  ██║
;			╚════██║██║   ██║██║   ██║██║╚██╗██║██║  ██║
;			███████║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
;			╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝
;
;				Code related to Sound

Function PlayDing()
	OSADing.Play(PlayerRef)
EndFunction

Function PlayTickSmall()
	OSATickSmall.Play(PlayerRef)
EndFunction

Function playTickBig()
	OSATickBig.Play(PlayerRef)
EndFunction

Event OnSoundDom(String EventName, String Fi, Float Ix, Form Sender)
	OnSound(DomActor, (Fi as Int), Ix as Int)
EndEvent

Event OnSoundSub(String EventName, String Fi, Float Ix, Form Sender)
	OnSound(SubActor, (Fi as Int), Ix as Int)
EndEvent

Event OnSoundThird(String EventName, String Fi, Float Ix, Form Sender)
	OnSound(ThirdActor, (Fi as Int), Ix as Int)
EndEvent

; Below is an event you can easily copy paste into your code to receive sound data
;/
RegisterForModEvent("ostim_osasound", "OnOSASound")
Event OnOSASound(String EventName, String Args, Float Nothing, Form Sender)
	String[] Argz = new String[3]
	Argz = StringUtil.Split(Args, "")

	Actor Char
	If (Argz[0] == "dom")
		Char = OStim.GetDomActor()
	ElseIf (Argz[0] == "sub")
		Char = OStim.Getsubactor()
	ElseIf (Argz[0] == "third")
		Char = OStim.GetThirdActor()
	EndIf
	Int FormID = Argz[1] as Int
	Int SoundID = Argz[2] as Int

	OsexIntegrationMain.Console("Actor: " + Char.GetDisplayName() + " FormID: " + formID + " SoundID: " + Argz[2])
EndEvent
/;

Function OnSound(Actor Act, Int SoundID, Int FormNumber)
	Int FormID = FormNumber
	If (AppearsFemale(Act))
		If ((FormNumber == 50) || (FormNumber == 60))
			FormID = FormNumber
		Else
			FormID = FormNumber + 5
		EndIf
	EndIf

	If (!MuteOSA)
		PlayOSASound(Act, Formid, Soundid)
	EndIf

	If (FormNumber == 60)
		OnSpank()
		ShakeController(0.3)
		ShakeCamera(0.5)
	EndIf

	If (FormNumber == 50)
		ShakeCamera(0.5)
		ShakeController(0.1)
	EndIf

	String Arg = "third"
	If (Act == DomActor)
		Arg = "dom"
	ElseIf (Act == SubActor)
		Arg = "sub"
	EndIf

	Arg += "," + FormId
	Arg += "," + SoundId
	SendModEvent("ostim_osasound", StrArg = Arg)
EndFunction

Event OnFormBind(String EventName, String zMod, Float IxID, Form Sender)
	Int Ix = StringUtil.Substring(IxID, 0, 2) as Int
	Int Fo = StringUtil.Substring(IxID, 2) as Int
	;OFormSuite[Ix] = Game.GetFormFromFile(Fo, zMod) as FormList
	Console("System requesting form: " + Fo + " be placed in to slot " + Ix)
	If (zMod != "OSA.esm")
		Console(zMod)
	EndIf

	Console(Game.GetFormFromFile(fo, "OSA.esm").GetName())
EndEvent

Function PlayOSASound(Actor Act, Int FormlistID, Int SoundID)
	PlaySound(Act, SoundFormlists[FormlistID].GetAt(SoundID) as Sound)
	;Console("Playing sound " + soundid + " in form " + formlistID)
EndFunction

Function PlaySound(Actor Act, Sound Snd)
	Int S = (Snd).Play(Act)
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

FormList[] SoundFormLists
Function BuildSoundFormLists()
	SoundFormLists = new FormList[100]
	String Plugin = "OSA.esm"

	SoundFormLists[10] = Game.GetFormFromFile(10483, Plugin) as FormList ;0Guy_ivo
	SoundFormLists[15] = Game.GetFormFromFile(8986, Plugin) as FormList ;0Gal_ivo

	SoundFormLists[11] = Game.GetFormFromFile(8986, Plugin) as FormList ;0Gal_ivo | wtf? female voice on male?
	SoundFormLists[16] = Game.GetFormFromFile(8987, Plugin) as FormList ;0Gal_ivos

	SoundFormLists[20] = Game.GetFormFromFile(17595, Plugin) as FormList ;0Guy_vo
	SoundFormLists[25] = Game.GetFormFromFile(17570, Plugin) as FormList ;0Gal_vo

	SoundFormLists[80] = Game.GetFormFromFile(13409, Plugin) as FormList ;0guy_wvo
	SoundFormLists[85] = Game.GetFormFromFile(13400, Plugin) as FormList ;FEvenTone_wvo

	SoundFormLists[50] = Game.GetFormFromFile(11972, Plugin) as FormList ;0bod_ibo

	SoundFormLists[60] = Game.GetFormFromFile(9037, Plugin) as FormList ;0spank_spank
EndFunction

FormList[] Function GetSoundFormLists()
	Return SoundFormLists
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



Function InitBar(Osexbar Bar, Bool DomsBar)
	Bar.HAnchor = "left"
	Bar.VAnchor = "bottom"
	Bar.X = 200
	Bar.Alpha = 0.0
	Bar.SetPercent(0.0)
	Bar.FillDirection = "Right"

	If (DomsBar)
		Bar.Y = 692
		Bar.SetColors(0xb0b0b0, 0xADD8E6, 0xffffff)
	Else
		Bar.Y = 647
		Bar.SetColors(0xb0b0b0, 0xffb6c1, 0xffffff)
	EndIf

	SetBarVisible(Bar, False)
EndFunction

Function SetBarVisible(Osexbar Bar, Bool Visible)
	If (Visible)
		Bar.FadeTo(100.0, 1.0)
		Bar.FadedOut = False
	Else
		Bar.FadeTo(0.0, 1.0)
		Bar.FadedOut = True
	EndIf
EndFunction

Bool Function IsBarVisible(Osexbar Bar)
	Return (!Bar.FadedOut)
EndFunction

Function SetBarPercent(Osexbar Bar, Float Percent)
	Bar.SetPercent(Percent / 100.0)
	Float zPercent = Percent / 100.0
	If (zPercent >= 1.0)
		FlashBar(Bar)
	EndIf
EndFunction

Function FlashBar(Osexbar Bar)
	Bar.ForceFlash()
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


Function Console(String In) Global
	MiscUtil.PrintConsole("OStim: " + In)
EndFunction

Function SetGameSpeed(String In)
	ConsoleUtil.ExecuteCommand("sgtm " + In)
EndFunction

Bool Function ChanceRoll(Int Chance) ; input 60: 60% of returning true
	Int Roll = Utility.RandomInt(1, 100)
	If (Roll <= Chance)
		Return True
	EndIf
	Return False
EndFunction

Int Function SpeedStringToInt(String In) ; casting does not work so...
	If (In == "s0")
		Return 0
	ElseIf (In == "s1")
		Return 1
	ElseIf (In == "s2")
		Return 2
	ElseIf (In == "s3")
		Return 3
	ElseIf (In == "s4")
		Return 4
	ElseIf (In == "s5")
		Return 5
	ElseIf (In == "s6")
		Return 6
	ElseIf (In == "s7")
		Return 7
	ElseIf (In == "s8")
		Return 8
	ElseIf (In == "s9")
		Return 9
	EndIf
EndFunction

Function ShakeCamera(Float Power, Float Duration = 0.1)
	If (UseScreenShake && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Game.ShakeCamera(PlayerRef, Power, Duration)
	EndIf
EndFunction

Function ShakeController(Float Power, Float Duration = 0.1)
	If (UseRumble && ((DomActor == PlayerRef) || (SubActor == PlayerRef)))
		Game.ShakeController(Power, Power, Duration)
	EndIf
EndFunction

Bool Function IntArrayContainsValue(Int[] Arr, Int Val)
	Int i = 0
	Int L = Arr.Length
	While (i < L)
		If (Arr[i] == Val)
			Return True
		EndIf
		i += 1
	EndWhile
	Return False
EndFunction

Bool Function StringArrayContainsValue(String[] Arr, String Val)
	Int i = 0
	Int L = Arr.Length
	While (i < L)
		If (Arr[i] == Val)
			Return True
		EndIf
		i += 1
	EndWhile
	Return False
EndFunction

Int Function GetTimeScale()
	Return Timescale.GetValue() as Int
EndFunction

Int Function SetTimeScale(Int Time)
	Timescale.SetValue(Time as Float)
EndFunction

Function SetSystemVars()
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

	Penis = 0
	Vagina = 1
	Mouth = 2
	Hand = 3
	Clit = 4
	;extra
	Anus = 5
	Feet = 6
	Breasts = 7
	Prostate = 8

	PenisStimValues = new Float[9]
	VaginaStimValues = new Float[9]
	MouthStimValues = new Float[9]
	HandStimValues = new Float[9]
	ClitStimValues = new Float[9]

	AnusStimValues = new Float[9]
	FeetStimValues = new Float[9]
	BreastsStimValues = new Float[9]
	ProstateStimValues = new Float[9]

	PenisStimValues[Penis] = 0.4
	PenisStimValues[Vagina] = 0.8
	PenisStimValues[Mouth] = 0.0
	PenisStimValues[Hand] = 0.0
	PenisStimValues[Clit] = 0.85
	PenisStimValues[Anus] = 0.2
	PenisStimValues[Feet] = 0.0
	PenisStimValues[Breasts] = 0
	PenisStimValues[Prostate] = 0.6

	VaginaStimValues[Penis] = 1.0
	VaginaStimValues[Vagina] = 0.6
	VaginaStimValues[Mouth] = 0.0
	VaginaStimValues[Hand] = 0.0
	VaginaStimValues[Clit] = 1.0
	VaginaStimValues[Anus] = 0.0
	VaginaStimValues[Feet] = 0.0
	VaginaStimValues[Breasts] = 0.0
	VaginaStimValues[Prostate] = 0.0

	MouthStimValues[Penis] = 1.4
	MouthStimValues[Vagina] = 1.0
	MouthStimValues[Mouth] = 0.1
	MouthStimValues[Hand] = 0.0
	MouthStimValues[Clit] = 2.0
	MouthStimValues[Anus] = 0.1
	MouthStimValues[Feet] = 0.0
	MouthStimValues[Breasts] = 0.1
	MouthStimValues[Prostate] = 0.0

	HandStimValues[Penis] = 0.9
	HandStimValues[Vagina] = 0.6
	HandStimValues[Mouth] = 0.0
	HandStimValues[Hand] = 0.0
	HandStimValues[Clit] = 1.3
	HandStimValues[Anus] = 0.1
	HandStimValues[Feet] = 0.0
	HandStimValues[Breasts] = 0.0
	HandStimValues[Prostate] = 0.5

	ClitStimValues[Penis] = 0.2
	ClitStimValues[Vagina] = 0.1
	ClitStimValues[Mouth] = 0.0
	ClitStimValues[Hand] = 0.0
	ClitStimValues[Clit] = 1.1
	ClitStimValues[Anus] = 0.0
	ClitStimValues[Feet] = 0.0
	ClitStimValues[Breasts] = 0.0
	ClitStimValues[Prostate] = 0.0

	AnusStimValues[Penis] = 1.2
	AnusStimValues[Vagina] = 0.2
	AnusStimValues[Mouth] = 0.0
	AnusStimValues[Hand] = 0.0
	AnusStimValues[Clit] = 0.5
	AnusStimValues[Anus] = 0.0
	AnusStimValues[Feet] = 0.0
	AnusStimValues[Breasts] = 0.0
	AnusStimValues[Prostate] = 0.0

	FeetStimValues[Penis] = 0.7
	FeetStimValues[Vagina] = 0.6
	FeetStimValues[Mouth] = 0.0
	FeetStimValues[Hand] = 0.0
	FeetStimValues[Clit] = 0.8
	FeetStimValues[Anus] = 0.1
	FeetStimValues[Feet] = 0.0
	FeetStimValues[Breasts] = 0.0
	FeetStimValues[Prostate] = 0.3

	BreastsStimValues[Penis] = 0.8
	BreastsStimValues[Vagina] = 0.3
	BreastsStimValues[Mouth] = 0.0
	BreastsStimValues[Hand] = 0.0
	BreastsStimValues[Clit] = 1.0
	BreastsStimValues[Anus] = 0.0
	BreastsStimValues[Feet] = 0.0
	BreastsStimValues[Breasts] = 0.1
	BreastsStimValues[Prostate] = 0.0

	ProstateStimValues[Penis] = 1.2
	ProstateStimValues[Vagina] = 0.2
	ProstateStimValues[Mouth] = 0.0
	ProstateStimValues[Hand] = 0.0
	ProstateStimValues[Clit] = 0.5
	ProstateStimValues[Anus] = 0.0
	ProstateStimValues[Feet] = 0.0
	ProstateStimValues[Breasts] = 0.0
	ProstateStimValues[Prostate] = 0.0

	Speeds = new String[9] ;this is the most fucked up progression i have ever seen
	Speeds[0] = "-1"
	Speeds[1] = "0.5"
	Speeds[2] = "1.5"
	Speeds[3] = "2"
	Speeds[4] = "3"
	Speeds[5] = "4"
	Speeds[6] = "4.5"
	Speeds[7] = "5"
	Speeds[8] =  "6"
EndFunction

Function SetDefaultSettings()
	EndOnDomOrgasm = True
	EnableSubBar = True
	EnableDomBar = True
	EnableActorSpeedControl = True
	AllowUnlimitedSpanking = False
	AutoUndressIfNeeded = True

	EndAfterActorHit = False

	DomLightBrightness = 0
	SubLightBrightness = 1
	SubLightPos = 0
	DomLightPos = 0

	CustomTimescale = 0
	AlwaysUndressAtAnimStart = True
	OnlyUndressChest = False ; currently only chest can be removed with animation
	AlwaysAnimateUndress = False

	LowLightLevelLightsOnly = False

	SexExcitementMult = 1.0

	EnableImprovedCamSupport = (SKSE.GetPluginVersion("ImprovedCamera") != -1)

	SpeedUpNonSexAnimation = False ;game pauses if anim finished early
	SpeedUpSpeed = 1.5

	Usebed = True
	BedSearchDistance = 15
	MisallignmentProtection = True

	FixFlippedAnimations = False
	OrgasmIncreasesRelationship = False
	SlowMoOnOrgasm = True

	UseAIControl = False
	PauseAI = False
	AutoHideBars = False

	GetInBedAfterBedScene = False
	UseAINPConNPC = True
	UseAIPlayerAggressor = True
	UseAIPlayerAggressed = True
	UseAINonAggressive = False

	Forcefirstpersonafter = True

	UseFreeCam = !(SKSE.GetPluginVersion("ImprovedCamera") != -1)

	BedReallignment = 0

	UseRumble = Game.UsingGamepad()
	UseScreenShake = False

	UseFades = True
	UseAutoFades = True
	BlockVRInstalls = true

	KeyMap = 200
	SpeedUpKey = 78
	SpeedDownKey = 74
	PullOutKey = 79
	ControlToggleKey = 82

	MuteOSA = False

	FreecamFOV = 45
	DefaultFOV = 85
	FreecamSpeed = 3

	UseNativeFunctions = (SKSE.GetPluginVersion("OSA") != -1)
	If (!UseNativeFunctions)
		Console("Native function DLL failed to load. Falling back to papyrus implementations")
	EndIf
	UseAlternateBedSearch = !UseNativeFunctions
	;UseAlternateBedSearch = true

	UseBrokenCosaveWorkaround = true
	RemapStartKey(Keymap)
	RemapSpeedDownKey(SpeedDownKey)
	RemapSpeedUpKey(SpeedUpKey)
	RemapPullOutKey(PullOutKey)
	RemapControlToggleKey(ControlToggleKey)
EndFunction

Function RegisterOSexControlKey(Int zKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, zKey)
	RegisterForKey(zKey)
EndFunction

Function LoadOSexControlKeys()
	OSexControlKeys = new Int[1]
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, SpeedUpKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, SpeedDownKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, PullOutKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, ControlToggleKey)
	OSexControlKeys = PapyrusUtil.PushInt(OSexControlKeys, KeyMap)

	RegisterOSexControlKey(83)
	RegisterOSexControlKey(156)
	RegisterOSexControlKey(72)
	RegisterOSexControlKey(76)
	RegisterOSexControlKey(75)
	RegisterOSexControlKey(77)
	RegisterOSexControlKey(73)
	RegisterOSexControlKey(71)
	RegisterOSexControlKey(79)
	RegisterOSexControlKey(209)
EndFunction

Function DisplayTextBanner(String Txt)
	UI.InvokeString("HUD Menu", "_root.HUDMovieBaseInstance.QuestUpdateBaseInstance.ShowNotification", Txt)
EndFunction

Function ResetState()
	Console("Resetting thread state")
	SceneRunning = False
	Debug.MessageBox("Reset state.")
EndFunction

Function RemapStartKey(Int zKey)
	UnregisterForKey(KeyMap)
	RegisterForKey(zKey)
	KeyMap = zKey
EndFunction

Function RemapControlToggleKey(Int zKey)
	UnregisterForKey(ControlToggleKey)
	RegisterForKey(zKey)
	ControlToggleKey = zKey
	LoadOSexControlKeys()
EndFunction

Function RemapSpeedUpKey(Int zKey)
	UnregisterForKey(SpeedUpKey)
	RegisterForKey(zKey)
	speedUpKey = zKey
	LoadOSexControlKeys()
EndFunction

Function RemapSpeedDownKey(Int zKey)
	UnregisterForKey(SpeedDownKey)
	RegisterForKey(zKey)
	speedDownKey = zKey
	LoadOSexControlKeys()
EndFunction

Function RemapPullOutKey(Int zKey)
	UnregisterForKey(PullOutKey)
	RegisterForKey(zKey)
	PullOutKey = zKey
	LoadOSexControlKeys()
EndFunction

Float ProfileTime
Function Profile(String Name = "")
	If (Name == "")
		ProfileTime = Game.GetRealHoursPassed() * 60 * 60
	Else
		Console(Name + ": " + ((Game.GetRealHoursPassed() * 60 * 60) - ProfileTime) + " seconds")
	EndIf
EndFunction

; TODO - support for ABOMB animation

Bool Property UseBrokenCosaveWorkaround Auto
Function OnLoadGame()
	If (UseBrokenCosaveWorkaround)
		Console("Using cosave fix")

		RegisterForModEvent("ostim_actorhit", "OnActorHit")
		LoadOSexControlKeys()
		RegisterForKey(SpeedUpKey)
		RegisterForKey(SpeedDownKey)
		RegisterForKey(PullOutKey)
		RegisterForKey(ControlToggleKey)
		RegisterForKey(KeyMap)

		; DEBUG
		;RegisterForKey(26) ; [
		;RegisterForKey(27) ; ]
		; DEBUG

		AI.OnGameLoad()
	EndIf
EndFunction
