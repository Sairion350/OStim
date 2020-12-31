ScriptName OAiScript extends Quest


; modules & other goodies
OsexIntegrationMain OStim
ODatabaseScript ODatabase
actor playerref

;actor stuff
actor agent
bool femDom
bool maledom

bool gay
bool lesbian

int numactors
string[] property foreplayClasses auto
string[] property blowjobClasses auto
string[] property femaleCentricClasses auto
string[] property maleCentricClasses auto
string[] property mainSexClasses auto

Event OnInit()
	;startup()
	ostim = (self as quest) as OsexIntegrationMain
	ODatabase = ostim.getODatabase()
	playerref = game.GetPlayer()
	RegisterFormodevent("ostim_start", "Ostim_start")
	RegisterFormodevent("ostim_start_ai", "AI_Thread")

	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "VJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "ApHJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "HJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "Cr")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "Pf1")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "Pf2")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "BJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "ApPJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "HhPJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "HhBJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "VBJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "VHJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "BJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "BoJ")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "BoF")
	foreplayClasses = PapyrusUtil.PushString(foreplayClasses, "FJ")

	blowjobClasses = PapyrusUtil.PushString(blowjobClasses, "BJ")
	blowjobClasses = PapyrusUtil.PushString(blowjobClasses, "ApHJ")
	blowjobClasses = PapyrusUtil.PushString(blowjobClasses, "HJ")
	blowjobClasses = PapyrusUtil.PushString(blowjobClasses, "ApPJ")
	blowjobClasses = PapyrusUtil.PushString(blowjobClasses, "VBJ")
	blowjobClasses = PapyrusUtil.PushString(blowjobClasses, "HhPJ")
	blowjobClasses = PapyrusUtil.PushString(blowjobClasses, "HhBJ")

	femaleCentricClasses = PapyrusUtil.PushString(femaleCentricClasses, "VBJ") 
	femaleCentricClasses = PapyrusUtil.PushString(femaleCentricClasses, "Cr") 
	femaleCentricClasses = PapyrusUtil.PushString(femaleCentricClasses, "Pf1") 
	femaleCentricClasses = PapyrusUtil.PushString(femaleCentricClasses, "Pf2") 
	femaleCentricClasses = PapyrusUtil.PushString(femaleCentricClasses, "VHJ")
	femaleCentricClasses = PapyrusUtil.PushString(femaleCentricClasses, "VJ")

	maleCentricClasses = blowjobClasses
	maleCentricClasses = PapyrusUtil.PushString(maleCentricClasses, "An")

	mainSexClasses = PapyrusUtil.PushString(mainSexClasses, "Sx")
	mainSexClasses = PapyrusUtil.PushString(mainSexClasses, "An")

EndEvent

Event Ostim_start(string eventName, string strArg, float numArg, Form sender)
	if !ostim.UseAIControl
		Return
	endif
	startAI()
endevent

event AI_Thread(string eventName, string strArg, float numArg, Form sender)


	console("Starting OAi")

	femdom = false
	maledom = false
	if ostim.IsSceneAggressiveThemed()
		if (ostim.isFemale(ostim.getAggressiveActor())) && !(ostim.isFemale(ostim.getSexPartner(ostim.getAggressiveActor()))) ; if the aggressive actor is female and their partner is not
			console("Starting femdom scene")
			femDom = true		
		Else
			console("Starting maledom scene")
			maledom = true	
		endif
	else
		if ostim.isActorActive(playerref)
			agent = ostim.getSexPartner(playerref)
		else
			console("Player is not active")
			agent = ostim.getDomActor()
		endif
	EndIf

	lesbian = False
	gay = false
	if ostim.isFemale(ostim.getDomActor()) && ostim.isFemale(ostim.getSubActor())
		lesbian = true
	elseif !ostim.isFemale(ostim.getDomActor()) && !ostim.isFemale(ostim.getSubActor())
		gay = true
	endif

	if ostim.isActorActive(playerref)
		agent = ostim.getSexPartner(playerref)
	else
		console("Player is not active")
		agent = ostim.getDomActor()
	endif

	if ostim.getThirdActor() != None
		numactors = 3
	Else
		numactors = 2
	endif

	int pulloutChance
	if ostim.IsSceneAggressiveThemed()
		pulloutChance = 0
	Else
		int rel = agent.GetRelationshipRank(ostim.getSexPartner(agent))
		if rel == 0
			pulloutChance = 75
		Else
			pulloutChance = 10
		endif
	endif
	int foreplayChangeChance = 4
	float foreplayEndThreshold
	if ostim.IsSceneAggressiveThemed()
		foreplayEndThreshold = Utility.RandomFloat(15.0, 105.0)
	Else
		int rel = agent.GetRelationshipRank(ostim.getSexPartner(agent))
		if rel == 0
			if chanceroll(50)
				foreplayEndThreshold = 125.0
			Else
				foreplayEndThreshold = Utility.RandomFloat(10.0, 35.0)
			endif
		Else
			if ostim.chanceRoll(90)
				foreplayEndThreshold = Utility.RandomFloat(10.0, 35.0)
			Else
				foreplayEndThreshold = 125.0
			endif
		endif
	endif
	int SexChangeChance = 2
	int foreplayChance
	if ostim.IsSceneAggressiveThemed()
		foreplaychance = 20
	Else
		foreplaychance = 80
	endif

	console("Pullout chance: " + pulloutChance)
	console("foreplay chance: " + foreplayChance)
	console("foreplay change chance: " + foreplayChangeChance)
	console("foreplay end thresh : " + foreplayEndThreshold)
	console("sex change anim chance: " + SexChangeChance)


	int stage
	if chanceroll(foreplaychance)
		stage = 1 ;foreplay
	Else
		stage = 2 ; main
	endif

	actor centralActor

	

	bool changeAnimation = True
	while ostim.animationRunning()
		
			
		if ostim.StringArrayContainsValue(femaleCentricClasses, ostim.getCurrentAnimationClass())
			centralActor = ostim.getSubActor()
		Else
			centralActor = ostim.getDomActor()
		endif

		

		if ostim.getActorExcitement(ostim.getDomActor()) > 95
			if chanceroll(pulloutChance)
				changeToPulledOutVersion()
			endif
			stage = 3
		endif

		if stage == 1
			if !changeAnimation
				changeAnimation = ostim.chanceRoll(foreplayChangeChance) 
			endif

			

			if changeAnimation

				changeAnimation = False

				console("Changing to other foreplay animation")
					
				string animation2 = getRandomForeplayAnimation(maleCentric = maledom, femaleCentric = femDom, aggressive = ostim.IsSceneAggressiveThemed())
				if animation2 != ""
					warp(animation2)
				endif
			endif

			if ostim.getActorExcitement(centralActor) > foreplayEndThreshold
				changeAnimation = true
				console("Changing to sex animation")
				stage = 2
		
			endif

		elseif stage == 2
			if !changeAnimation
				changeAnimation = ostim.chanceRoll(SexChangeChance) 
			endif

			if changeAnimation

				changeAnimation = False

				console("Changing to other sex animation")
				string animation = getRandomSexAnimation(maleCentric = maledom, femaleCentric = femDom, aggressive = ostim.IsSceneAggressiveThemed())
				if animation != ""
					warp(animation)
				endif

			endif

			

		endif
		Utility.Wait(2)

		While ostim.pauseAI && ostim.animationRunning() 
			Utility.Wait(1)
		endwhile
	EndWhile

	console("Closed AI thread")
endevent

function startAI()
	console("Firing off AI thread")
	SendModEvent("ostim_start_ai")
endfunction

string function getRandomForeplayAnimation(bool maleCentric = false, bool femaleCentric = false, bool aggressive = false)
	int animations = getAllSexualAnimations()
	animations = filterOutAggressiveAnimations(animations, aggressive)
	
	if aggressive
		if femDom
			animations = ODatabase.getAnimationsByMainActor(animations, 1)
		Else
			animations = ODatabase.getAnimationsByMainActor(animations, 0)
		endif
	endif

	int numAnimations = ODatabase.getLengthOArray(animations)
	if numAnimations < 1
		console("No foreplay animations with these parameters")
	endif

	int i = 0
	int max = 50

	while (i < 50) 
		int animation = ODatabase.getObjectOArray(animations, utility.RandomInt(0, numAnimations))
		console("Trying animation: " + ODatabase.getFullName(animation))

		if ostim.StringArrayContainsValue(foreplayClasses, (ODatabase.getAnimationClass(animation)))
			if maleCentric
				if ostim.StringArrayContainsValue(maleCentricClasses, (ODatabase.getAnimationClass(animation)))
					return odatabase.getSceneID(animation)
				endif
			Elseif femaleCentric
				if ostim.StringArrayContainsValue(femaleCentricClasses, (ODatabase.getAnimationClass(animation)))
					return odatabase.getSceneID(animation)
				endif
			Else
				return odatabase.getSceneID(animation)
			endif

		EndIf

		i += 1
	endwhile

	console("No sex animations with these parameters")
	animations = getAllSexualAnimations()
	i = 0

	while (i < 50) 
		int animation = ODatabase.getObjectOArray(animations, utility.RandomInt(0, numAnimations))
		console("Trying animation: " + ODatabase.getFullName(animation))

		if ostim.StringArrayContainsValue(mainSexClasses, (ODatabase.getAnimationClass(animation)))
			return odatabase.getSceneID(animation)
		EndIf

		i += 1
	endwhile


	return ""
endfunction

string function getRandomSexAnimation(bool maleCentric = false, bool femaleCentric = false, bool aggressive = false)
	int animations = getAllSexualAnimations()
	animations = filterOutAggressiveAnimations(animations, aggressive)

	if aggressive
		if femDom
			animations = ODatabase.getAnimationsByMainActor(animations, 1) 

			int cowgirlAnims = getAllSexualAnimations()
			cowgirlAnims = ODatabase.getAnimationsWithName(cowgirlAnims, "cow",  allowPartialResult = true)	

			int[] merge = new Int[2]
			merge[0] = animations
			merge[1] = cowgirlAnims

			animations = ODatabase.mergeOArrays(merge)
		Else
			animations = ODatabase.getAnimationsByMainActor(animations, 0)
		endif
	endif

	int numAnimations = ODatabase.getLengthOArray(animations)
	if numAnimations < 1
		console("No sex animations with these parameters")
		animations = getAllSexualAnimations()
	endif
	int i = 0
	int max = 50

	while (i < 50) 
		int animation = ODatabase.getObjectOArray(animations, utility.RandomInt(0, numAnimations))
		console("Trying animation: " + ODatabase.getFullName(animation))

		if ostim.StringArrayContainsValue(mainSexClasses, (ODatabase.getAnimationClass(animation)))
			return odatabase.getSceneID(animation)
		EndIf

		i += 1
	endwhile

	console("No sex animations with these parameters")
	animations = getAllSexualAnimations()
	i = 0

	while (i < 50) 
		int animation = ODatabase.getObjectOArray(animations, utility.RandomInt(0, numAnimations))
		console("Trying animation: " + ODatabase.getFullName(animation))

		if ostim.StringArrayContainsValue(mainSexClasses, (ODatabase.getAnimationClass(animation)))
			return odatabase.getSceneID(animation)
		EndIf

		i += 1
	endwhile


	return ""
endfunction

function changeToPulledOutVersion()
	console("trying pullout")
	string pos = ODatabase.getPositionData(ostim.getCurrentAnimationOID())

	int animations = ODatabase.getAnimationsWithPositionData(getAllSexualAnimations(), pos)
	animations = ODatabase.getAnimationsWithAnimationClass(animations, "Po")

	if ODatabase.getLengthOArray(animations) > 0
		int animation = ODatabase.getObjectOArray(animations, 0)
		ostim.travelToAnimation(ODatabase.getSceneID(animation))

		ostim.setCurrentAnimationSpeed(ODatabase.getMaxSpeed(animation))
	endif
EndFunction


int function getAllSexualAnimations()
	int animations
	animations = odatabase.getAnimationsWithActorCount(ODatabase.getDatabaseOArray(), numactors)
	animations = odatabase.getHubAnimations(animations, false)
	animations = odatabase.getTransitoryAnimations(animations, false)

	if ostim.usingBed()
		animations = removeStandingAnimations(animations)
	endif

	if !gay
		animations = ODatabase.getAnimationsWithName(animations, "Gay",  allowPartialResult = true, negative = true)
	endif

	if !lesbian
		animations = ODatabase.getAnimationsWithName(animations, "Lesbian",  allowPartialResult = true, negative = true)
	endif
	return animations
endfunction

int function filterOutAggressiveAnimations(int animations, bool allow = false)
	return ODatabase.getAnimationsByAggression(animations, allow)
endfunction

int function removeStandingAnimations(int animations)
	console("filtering standing animations")
	int i = 0
	int max = ODatabase.getLengthOArray(animations)

	int ret = ODatabase.newOArray()
	while i < max
		string pos = ODatabase.getPositionData(ODatabase.getObjectOArray(animations, i))

		if StringUtil.Find(pos, "S") == -1
			ODatabase.appendObjectOArray(ret, ODatabase.getObjectOArray(animations, i))
		endif

		i += 1
	EndWhile

	return ret
endfunction

function warp(string ascene)
	if ostim.useAutoFades && ostim.isActorActive(playerref)
		float time = 1.00
		game.FadeOutGame(true, true, 0.0, time)
		utility.Wait(time - 0.15)
		game.FadeOutGame(false, true, 25.0, 25.0) ;total blackout
	endif

	ostim.warpToAnimation(ascene)

	if ostim.useAutoFades && ostim.isActorActive(playerref)
		Utility.Wait(0.55)
		game.FadeOutGame(false, true, 0.0, 1) ;welcome back
	EndIf
endfunction

function console(string in) 
	OsexIntegrationMain.console(in)
EndFunction

bool function chanceroll(int chance)
	return ostim.chanceroll(chance)
endfunction

function OnGameLoad()
	Console("Fixing AI thread")
	RegisterFormodevent("ostim_start", "Ostim_start")
	RegisterFormodevent("ostim_start_ai", "AI_Thread")
endfunction