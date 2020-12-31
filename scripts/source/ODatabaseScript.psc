ScriptName ODatabaseScript extends Quest

OsexIntegrationMain OStim
string[] modules
int database

string[] property originalmodules auto
string savepath 
bool built = false
bool loaded = false

;for debugging
bool LoadInitialFromFile = false
bool dumpConsole = false


; Structures
; Due to limitations with papyrus arrays, this script uses the following JContainers objects.
;--------------------------
; OArray - a JArray. Used to store:
; OMap - a JMap (i.e. dictionary). 1 OMap = 1 Animation scene
;--------------------------
;

;OMap Animation data

; name - string
; sceneid - string 
; numactors - int
; positiondata - string
; sourcemodule - string
; animclass - string
; OAanimids - OArray
; istransitory - bool | "t="t""
; mainactor - int | speed a="1"
; minspeed - int
; maxspeed - int

; hasidlespeed - bool

; ishub - bool | has only one animation 
; isaggressive - bool


function initDatabase()
	originalmodules = new String[1]
	originalmodules[0] = "0MF"
	originalmodules = PapyrusUtil.PushString(originalmodules, "0M2F")
	originalmodules = PapyrusUtil.PushString(originalmodules, "BB")
	originalmodules = PapyrusUtil.PushString(originalmodules, "BG")
	originalmodules = PapyrusUtil.PushString(originalmodules, "EMF")
	originalmodules = PapyrusUtil.PushString(originalmodules, "WZH0")

	savepath = JContainers.userDirectory() + "ODatabase.json"
	built = False
	loaded = false

	ostim = (self as quest) as OsexIntegrationMain
	
	if LoadInitialFromFile
		load()
	else	
		if JContainers.fileExistsAtPath(savepath)
			console("Deleting old database file...")
			JContainers.removeFileAtPath(savepath)
		endif
		database = newOArray()
		jdb.setObj("OStim.ODatabase", database)

		build()
		console(getLengthOArray(database) + " OSex scenes installed")
	EndIf

	loaded = true

	saveToDisk()
	unload()
	built = true
EndFunction

int function getDatabaseOArray(); never cache this for more than a few seconds, it can be cleared from memory at any time
	if !loaded
		load()
	endif
	return database
EndFunction

function unload()

	jdb.setObj("OStim.ODatabase", 0)
	JValue.release(getDatabaseOArray())

	console("Unloaded database")

	loaded = false
EndFunction

function saveToDisk()
	if !loaded
		load()
	EndIf

	JValue.writeToFile(getDatabaseOArray(), savepath)

	console("Wrote database to disk")
endfunction

function load()
	if loaded
		Return
	endif
	if JContainers.fileExistsAtPath(savepath)
		database = JValue.readFromFile(savepath)
		jdb.setObj("OStim.ODatabase", database)
	else
		console("Error: Database not found at: " + savepath)

		database = newOArray()
		jdb.setObj("OStim.ODatabase", database)

		build()
		loaded = true

		saveToDisk()
	endif

	console("Loaded database")
	loaded = true
endfunction

bool function isbuilt()
	return built
EndFunction

;--------------------------------------------
;  	Retrieve Data from animation OMaps
;--------------------------------------------

string function getFullName(int animation)
	return getStringOMap(animation, "name")
endfunction

string function getAnimationClass(int animation)
	return getStringOMap(animation, "animclass")
endfunction

int function getAnimationIDOArray(int animation) ; returns an OArray of animation IDs
	return getObjOMap(animation, "OAanimids")
endfunction

int function getNumActors(int animation) 
	return getIntOMap(animation, "NumActors")
endfunction

string function getPositionData(int animation)
	return getStringOMap(animation, "positiondata")
endfunction

string function getSceneID(int animation)
	return getStringOMap(animation, "sceneid")
endfunction

string function getModule(int animation)
	return getStringOMap(animation, "sourcemodule")
endfunction

bool function isAggressive(int animation)
	return getBoolOMap(animation, "aggressive")
EndFunction

bool function isHubAnimation(int animation)
	return getBoolOMap(animation, "ishub")
EndFunction

bool function isTransitoryAnimation(int animation)
	return getBoolOMap(animation, "istransitory")
EndFunction

bool function isSexAnimation(int animation)
	return !isHubAnimation(animation) && !isTransitoryAnimation(animation)
EndFunction

int function getMainActor(int animation) ; the main actor is the one doing the most work. 0 - dom | 1 - sub
	if !isSexAnimation(animation)
		return -1
	endif
	return getIntOMap(animation, "mainActor")
EndFunction

int function getMaxSpeed(int animation)
	if !isSexAnimation(animation)
		return -1
	endif
	return getIntOMap(animation, "maxspeed")
EndFunction

int function getMinSpeed(int animation)
	if !isSexAnimation(animation)
		return -1
	endif
	return getIntOMap(animation, "minspeed")
EndFunction

bool function hasIdleSpeed(int animation) ;if the lowest speed on a sex animation is called "idle"
	if !isSexAnimation(animation)
		return -1
	endif
	return getBoolOMap(animation, "hasidlespeed")
EndFunction

; extras
string function getPositionDataForActorSlot(int animation, int slot)
	return stringutil.split(getPositionData(animation), "!")[slot]
endfunction

bool function hasPositionDataInSlot(int animation, int slot, string data) ; this supports partial data, ie "Kn" at slot 0 will tell you if a dom actor is kneeling on both knees
	string slotdata = getPositionDataForActorSlot(animation, slot)
	return !(StringUtil.Find(slotdata, data) == -1)
endfunction

bool function hasPositionData(int animation, string data) ; this supports partial data
	string slotdata = getpositiondata(animation)
	return !(StringUtil.Find(slotdata, data) == -1)
endfunction

;----------------------------------------------
;  	Retrieve OArray of animations from database
;-----------------------------------------------

int function databaseKeyAndParameterLookup(int zdatabase, string zkey, int integerParameter = -100, string stringParameter = "", int boolParameter = -1, bool allowPartialStringResult = false, bool negativePartial = false)
	int base = zdatabase
	int ret = newOArray()

	int i = 0
	int max = getLengthOArray(base)

	while i < max
		int animation = getObjectOArray(base, i)

		if integerParameter > -100
			int output = getIntOMap(animation, zkey)
			if (output == integerParameter) && (output != 10001)
				appendObjectOArray(ret, animation)
			endif
		elseif stringparameter != ""
			string output = getStringOMap(animation, zkey)

			
			if !allowPartialStringResult
				if (output == stringParameter) && (output != "")
						appendObjectOArray(ret, animation)
				endif
			Else
				if StringUtil.Find(output, stringParameter) != -1
					if !negativePartial
						appendObjectOArray(ret, animation)
					endif
				Else
					if negativePartial
						appendObjectOArray(ret, animation)
					endif
				endif
			endif
		elseif boolParameter > -1
			bool parameter = (boolParameter == 1)
			if getBoolOMap(animation, zkey) == parameter
				appendObjectOArray(ret, animation)
			endif
		endif

		i += 1
	endwhile
	return ret
endfunction


int function getAnimationWithAnimID(int zDatabase, string AnimID) ;returns OArray
	int base = zdatabase
	int ret = newOArray()

	int i = 0
	int max = getLengthOArray(base)


	while i < max
		int animation = getObjectOArray(base, i)

		int OAanimIDs = getAnimationIDOArray(animation)
		int i2 = 0
		int max2 = getLengthOArray(OAanimIDs)

		while i2 < max2
			if animid == getStringOArray(oaanimids, i2)
				appendObjectOArray(ret, animation)
				return ret ; short circuit out
			endif

			i2 += 1
		endwhile

		i += 1
	endwhile
	return ret
endfunction


int function getAnimationsWithSpecificPositionData(int zDatabase, string data, int slot = -1, bool has = true)  ; this supports partial data, ie "Kn" at slot 0 will tell you if a dom actor is kneeling on both knees
	; slot -1 = search all slots
	;has = false will give you animations that do not contain the data
	int base = zdatabase
	int ret = newOArray()

	int i = 0
	int max = getLengthOArray(base)

	while i < max
		int animation = getObjectOArray(base, i)

		if slot != -1
			if hasPositionDataInSlot(animation, slot, data)
				if has
					appendObjectOArray(ret, animation)
				endif
			Else
				if !has
					appendObjectOArray(ret, animation)
				endif
			endif
		Else
			if hasPositionData(animation, data)
				if has	
					appendObjectOArray(ret, animation)
				EndIf
			Else
				if !has
					appendObjectOArray(ret, animation)
				endif
			endif
		endif
		i += 1
	endwhile
	return ret
EndFunction

;-----------


int function getAnimationsWithActorCount(int zDatabase, int num) ;returns OArray
	return databaseKeyAndParameterLookup(zdatabase, "NumActors", integerParameter = num)
endfunction

int function getAnimationsWithName(int zDatabase, string name, bool allowPartialResult = false, bool negative = false) ;returns OArray
	return databaseKeyAndParameterLookup(zdatabase, "name", stringparameter = name, allowpartialstringresult = allowPartialResult, negativePartial = negative)
endfunction

int function getAnimationsWithAnimationClass(int zDatabase, string zclass) ;returns OArray
	return databaseKeyAndParameterLookup(zdatabase, "animclass", stringparameter = zclass)
endfunction

int function getAnimationsWithPositionData(int zDatabase, string pos) ;returns OArray
	return databaseKeyAndParameterLookup(zdatabase, "positiondata", stringparameter = pos)
endfunction

int function getAnimationsWithSceneID(int zDatabase, string sceneid) ;returns OArray
	return databaseKeyAndParameterLookup(zdatabase, "sceneid", stringparameter = sceneid)
endfunction

int function getAnimationsFromModule(int zDatabase, string module) ;returns OArray
	return databaseKeyAndParameterLookup(zdatabase, "sourcemodule", stringparameter = module)
endfunction

int function getAnimationsByAggression(int zDatabase, bool isaggressive) ;returns OArray
	int send = 0
	if isAggressive
		send = 1
	Else
		send = 0
	endif
	return databaseKeyAndParameterLookup(zdatabase, "aggressive", boolParameter = send)
endfunction

int function getHubAnimations(int zDatabase, bool ishub) ;returns OArray
	int send = 0
	if ishub
		send = 1
	Else
		send = 0
	endif
	return databaseKeyAndParameterLookup(zdatabase, "ishub", boolParameter = send)
endfunction

int function getTransitoryAnimations(int zDatabase, bool istransitory) ;returns OArray
	int send = 0
	if istransitory
		send = 1
	Else
		send = 0
	endif
	return databaseKeyAndParameterLookup(zdatabase, "istransitory", boolParameter = send)
endfunction

int function getSexAnimations(int zDatabase, bool istransitory) ;returns OArray
	; returns all sexual animations, for intercourse animations only, use the animation class "Sx" as a lookup instead
	int a = getHubAnimations(zdatabase, false)
	return getTransitoryAnimations(a, false)
endfunction

int function getAnimationsByMainActor(int zDatabase, int mainActor) ;returns OArray
	; 0 - dom, 1 - sub
	return databaseKeyAndParameterLookup(zdatabase, "mainActor", integerParameter = mainactor)
endfunction

int function getAnimationsByMaxSpeed(int zDatabase, int speed) ;returns OArray
	return databaseKeyAndParameterLookup(zdatabase, "maxspeed", integerParameter = speed)
endfunction

int function getAnimationsByMinSpeed(int zDatabase, int speed) ;returns OArray
	return databaseKeyAndParameterLookup(zdatabase, "minspeed", integerParameter = speed)
endfunction

int function getAnimationsWithIdleSpeed(int zDatabase, bool zidle) ;returns OArray
	return databaseKeyAndParameterLookup(zdatabase, "hasidlespeed", boolParameter = zidle as int)
endfunction

;--- auxiliary functions

string function getSceneIDByAnimID(string animID)
	int OManim = getobjectoarray( getAnimationWithAnimID(getDatabaseOArray(), animID) , 0  ) 
	return getSceneID(OManim)
endfunction




;----------------------
;  	Building
;----------------------
function checkForModules()
	string path = "data/meshes/0SA/mod/0Sex/scene"
	modules = MiscUtil.FoldersInFolder(path)
	int i = 0
	int numModules = modules.Length
	console("Modules found: " + numModules)
	if numModules == 0
		debug.MessageBox("OStim: ERROR - Your version of PapyrusUtils is out of date - this is ALMOST CERTAINLY because OSA's packaged in (and out of date) PapyrusUtils is overwriting a more recent downloaded version. Please exit without saving, and move PapyrusUtils lower in your mod organizer, or install the latest version if it is not installed so that OStim can function. ")
	endif
	while i < numModules
		if !ostim.StringArrayContainsValue(originalmodules, modules[i])
			Debug.Notification("OStim - loaded third-party animation pack: " + modules[i])
		endif
		i += 1
	EndWhile
endfunction


int function GetAllAnimationFiles() 
	; returns an oarray of all file paths to all files
	string path = "data/meshes/0SA/mod/0Sex/scene"
	int ret = newOArray()

	modules = MiscUtil.FoldersInFolder(path)

	int i = 0
	int numModules = modules.Length
	console("Modules found: " + numModules)

	if numModules == 0
		debug.MessageBox("OStim: ERROR - Your version of PapyrusUtils is out of date - this is ALMOST CERTAINLY because OSA's packaged in (and out of date) PapyrusUtils is overwriting a more recent downloaded version. Please exit without saving, and move PapyrusUtils lower in your mod organizer, or install the latest version if it is not installed so that OStim can function. ")
	endif
	while i < numModules
		if !ostim.StringArrayContainsValue(originalmodules, modules[i])
			Debug.Notification("OStim - loaded third-party animation pack: " + modules[i])
		endif
		string[] positions = MiscUtil.FoldersInFolder(path + "/" + modules[i])

		int i2 = 0
		int numPositions = positions.Length

		while i2 < numPositions
			if positions[i2] == "_TOG"
				;ignore
			Else
				string[] classes = MiscUtil.FoldersInFolder(path + "/" + modules[i] + "/" + positions[i2])

				int i3 = 0
				int numClasses = classes.Length

				while i3 < numClasses
					string[] files = MiscUtil.FilesInFolder(path + "/" + modules[i] + "/" + positions[i2] + "/" + classes[i3])

					int i4 = 0
					int numFiles = files.Length

					while i4 < numfiles
						string fileLocation = path + "/" + modules[i] + "/" + positions[i2] + "/" + classes[i3] + "/" + files[i4]

						if (StringUtil.Find(files[i4], ".xml") != -1) || (StringUtil.Find(files[i4], ".XML") != -1)
							appendStringOArray(ret, fileLocation)
							console("Animation data found: " + fileLocation)
							JValue.retain(ret)
						Else
							console("Skipping non-XML file: " + files[i4])
						endif
						
						i4 += 1
					EndWhile

					i3 += 1
				EndWhile
			endif
			i2 += 1
		EndWhile

		i += 1
	EndWhile

	return ret
EndFunction

string function getFileContents(string file)
	return MiscUtil.ReadFromFile(file)
EndFunction

bool function build()
	if ostim.useNativeFunctions
		console("Using native build function")
		return buildNative()
	Else	
		console("Using papyrus build function")
		return buildPapyrus()
	endif
endfunction

bool function buildNative()
 	OSANative.BuildDB()

 	load()
	checkForModules()
	console("ODatabase built using native function")
	return true
endfunction

bool function buildPapyrus() ;papyrus implementation of the odatabase builder - slow
	int OAfiles = GetAllAnimationFiles()

	int loop = 0
	int max = getLengthOArray(OAfiles)

	while loop < max
		string contents = getFileContents(getStringOArray(OAfiles, loop))
		int OMAnimation = newOMap()

			appendStringOMap(OMAnimation, "name", XMLGetName(contents))
			appendStringOMap(OMAnimation, "sceneid", XMLGetSceneID(contents))
			appendIntOMap(OMAnimation, "numactors", XMLGetNumActors(contents))
			appendStringOMap(OMAnimation, "positiondata", XMLGetPosData(OMAnimation))
			appendStringOMap(OMAnimation, "sourcemodule", XMLGetSourceModule(getStringOArray(OAfiles, loop)))
			appendStringOMap(OMAnimation, "animclass", XMLGetAnimClass(getStringOArray(OAfiles, loop)))
			appendObjectOMap(OMAnimation, "OAanimids", XMLGetAnimIDs(contents))
			appendBoolOMap(OMAnimation, "aggressive", xmlisaggressive(OMAnimation))

			bool transitory = XMLIsTransitory(contents)
			appendBoolOMap(OMAnimation, "istransitory", transitory)
			bool ishub = xmlishub(contents, OMAnimation)
			appendBoolOMap(OMAnimation, "ishub", ishub)

			if (!transitory) && (!ishub)
				int mainactor = XMLMainActor(contents)
				appendIntOMap(OMAnimation, "mainactor", mainactor)
				appendIntOMap(OMAnimation, "minspeed", XMLMinSpeed(contents, mainActor))
				appendIntOMap(OMAnimation, "maxspeed", XMLMaxSpeed(contents))
				appendBoolOMap(OMAnimation, "hasidlespeed", XMLHasIdleSpeed(contents))
				
			endif

			appendObjectOArray(database, OMAnimation)
			JValue.retain(OAfiles)
			console("-------------------------------------------------------------------------")
		loop += 1
	endwhile
EndFunction

; Extracting data from XML input

string function ToolExtractFirstString(string in, string element)
	string xmlpart = element + "\""
	string ret
	int partLength = StringUtil.GetLength(xmlpart)

	int	start = StringUtil.Find(in, xmlpart)
	if start == -1
		return ""
	endif

	string substring = StringUtil.Substring(in, start + partLength, len = 0) ; we now just have to cut off the end

	ret = StringUtil.Split(substring, "\"")[0]

	return ret
endfunction

string function ToolExtractNthString(string in, string element, int nth)
	string xmlpart = element + "\""
	string ret
	int partLength = StringUtil.GetLength(xmlpart)

	int end = 0 
	int i = 0
	while i < nth
		end = StringUtil.Find(in, xmlpart, end) + partLength
		i += 1
	endwhile

	string substring = StringUtil.Substring(in, end, len = 0) ; we now just have to cut off the end
	ret = StringUtil.Split(substring, "\"")[0]

	return ret
endfunction

int function ToolSingleDigitStringnumberToInt(string in)
	return ostim.speedStringToInt("s" + in)
endfunction

string function ToolExtractNthFolderPathFolder(string path, int part)
	string[] splitpath = StringUtil.Split(path, "/")
	return splitpath[part]
endfunction

string function XMLGetName(string in)
	string ret = toolextractfirststring(in, "<info name=")

	console("	Name: " + ret)
	return ret
endfunction

string function XMLGetSceneID(string in)
	string ret = toolextractfirststring(in, "<scene id=")

	console("	Scene ID: " + ret)
	return ret
endfunction

int function XMLGetNumActors(string in)
	int ret = ToolSingleDigitStringnumberToInt(toolextractfirststring(in, "actors="))

	console("	Number of actors: " + ret)
	return ret
endfunction

string function XMLGetPosData(int OMAnim)
	string ret = stringutil.split(getSceneID(OMAnim), "|")[1]

	console("	Position Data: " + ret)
	return ret
EndFunction

string function XMLGetSourceModule(string path)
	string ret = ToolExtractNthFolderPathFolder(path, 6)

	console("	Source Module: " + ret)
	return ret
EndFunction

string function XMLGetAnimClass(string path)
	string ret = ToolExtractNthFolderPathFolder(path, 8)

	console("	Animation Class: " + ret)
	return ret
EndFunction

int function XMLGetAnimIDs(string in) 
	string[] ret

	if ToolExtractNthString(in, "<anim id=", 2) != "="
		int number = 2
		ret = Utility.CreateStringArray(1, ToolExtractNthString(in, "<anim id=", number))
		string last = ret[0]

		while last != "=" ;assuming "=" marks end of file
			number += 1
			last = ToolExtractNthString(in, "<anim id=", number)

			if last != "="
				ret = PapyrusUtil.PushString(ret, last)
			endif
		EndWhile
	else
		ret = Utility.CreateStringArray(1, ToolExtractNthString(in, "<anim id=", 1))
	endif

	int i = 0
	int len = ret.length
		
	while i < len
		console("		Animation ID " + i + ": " + ret[i])
		i += 1
	endwhile

	return JArray.ObjectWithStrings(ret)
endfunction

bool function XMLIsTransitory(string in)
	bool ret = (toolextractfirststring(in, "t=") == "T")

	console("	Is Transitory Animation: " + ret)
	return ret
endfunction

int function XMLMainActor(string in)
	int ret = ToolSingleDigitStringnumberToInt(toolextractfirststring(in, "<speed a="))

	console("	Main controlling actor: " + ret)
	return ret
endfunction

int function XMLMinSpeed(string in, int mainActor)
	int ret = ToolSingleDigitStringnumberToInt(toolextractfirststring(in, "<speed a=\""+ mainactor + "\" min="))

	console("	Minimum Speed: " + ret)
	return ret 
endfunction

int function XMLMaxSpeed(string in)
	int ret = ToolSingleDigitStringnumberToInt(toolextractfirststring(in, " max="))

	console("	Maximum Speed: " + ret)
	return ret 
endfunction

bool function XMLHasIdleSpeed(string in)
	bool ret = toolextractfirststring(in, "<sp mtx=") == "^idle"

	console("	Has Idle Speed: " + ret)
	return ret 
endfunction

bool function XMLIsHub(string in, int OMAnim) 
	bool ret
	if toolextractfirststring(in, " max=") == ""

		if isTransitoryAnimation(OMAnim)
			ret = false
		else 
			ret = true
		endif
	Else
		ret = False
	endif
	console("	Is Hub Animation: " + ret)
	return ret
endfunction

bool function XMLIsAggressive(int OMAnimation)
	bool ret = false
	string aclass = getAnimationClass(OMAnimation)
	string module = getmodule(OMAnimation)

	If (aclass == "Ro") || (aclass == "HhPJ") || (aclass == "HhBJ") || (aclass == "HhPo") || (aclass == "SJ")
		ret = True
	Elseif (module == "BG") || (module == "BB")
		ret = True
	else
		int	start = StringUtil.Find(aclass, "Ag")
		if start != -1
			ret = true
		endif
	EndIf
	console("	Is Aggressive: " + ret)
	return ret
endfunction

;----------------------
;  OArray Manipulation
;----------------------

int function newOArray()
	return JArray.object()
endfunction

function appendIntOArray(int OArray, int append)
	JArray.addInt(oarray, append)
EndFunction

function appendObjectOArray(int OArray, int append)
	JArray.addObj(oarray, append)
EndFunction

function appendStringOArray(int OArray, string append)
	JArray.addStr(oarray, append)
EndFunction

int function getIntOArray(int OArray, int index)
	return JArray.getInt(OArray, index, default = -10001)
EndFunction

int function getObjectOArray(int OArray, int index)
	return JArray.getObj(OArray, index)
EndFunction

string function getStringOArray(int OArray, int index)
	return JArray.getStr(OArray, index, default = "")
EndFunction

int function getLengthOArray(int OArray) ;number of items total
	return JArray.count(OArray)
EndFunction

int function mergeOArrays(int[] arrays) ;may only work if arrays are full of omap or oarray objects
	int ret = newOArray()

	int i = 0
	int max = arrays.length

	while i < max
		int array = arrays[i]

		int i2 = 0
		int max2 = getLengthOArray(array)

		while i2 < max2
			appendObjectOArray(ret, getObjectOArray(array, i2))
			i2 += 1
		endwhile

		i += 1
	EndWhile

	return ret
endfunction
;----------------------
;  OMap Manipulation
;----------------------

int function newOMap()
	return JMap.object()
endfunction

function appendStringOMap(int OMap, string zkey, string append)
	JMap.setStr(OMap, zkey, append)
EndFunction

function appendIntOMap(int OMap, string zkey, int append)
	JMap.setint(OMap, zkey, append)
EndFunction

function appendObjectOMap(int OMap, string zkey, int append)
	JMap.setobj(OMap, zkey, append)
EndFunction

function appendBoolOMap(int OMap, string zkey, bool zappend)
	int append
	if zappend
		append = 1
	Else
		append = 0
	endif
	JMap.setInt(OMap, zkey, append)
EndFunction

string function getStringOMap(int OMap, string zkey)
	return JMap.getStr(OMap, zkey, default = "")
EndFunction

int function getIntOMap(int OMap, string zkey)
	return JMap.getInt(OMap, zkey, default = -10001)
EndFunction

int function getObjOMap(int OMap, string zkey)
	return JMap.getObj(OMap, zkey)
EndFunction

bool function getBoolOMap(int OMap, string zkey)
	int a = JMap.getInt(OMap, zkey, default = 0)
	if a == 1
		return true
	else
		return false
	endif
EndFunction

;----------------------------------
; 			Other
;----------------------------------
function console(string in) 
	OsexIntegrationMain.console(in)
	if dumpConsole
		dumpString(in + "\n")
	endif
EndFunction

function dumpString(string in)
	MiscUtil.WriteToFile("data/ostimdump.txt", in, timestamp = false)
EndFunction

function dumpOmap(int OMap)
	JValue.writeToFile(OMap, "data/ostimdump.txt")
	console("Dumped")
EndFunction