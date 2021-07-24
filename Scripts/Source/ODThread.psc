ScriptName ODThread extends BaseObject

odthreadmanager mother 

int id

int min
int max

string lookupKey

int jarrayObj

int intParam
string strParam
int boolParam

bool STRallowpartial 
bool STRNegativePartial

int lookupType

Function DoLookup(int obj, int objSize, int threadCount, string zkey, Int zIntParam = -100, String zStringParam = "", Int zBoolParam = -1, Bool AllowPartialStringResult = False, Bool NegativePartial = False)
	jarrayObj = obj 
	;jarrayObj = Jvalue.deepCopy(obj)
	lookupKey = zkey

	int sizePerThread = objSize / threadCount
	min = sizePerThread * (id)
	max = min + (sizePerThread)
	if max > objSize
		max = objSize
	endif 

	If (zIntParam > -100)
		intParam = zIntParam
		lookupType = 0 

	elseif (zStringParam != "")
		strparam = zStringParam
		lookupType = 1 

		STRallowpartial = AllowPartialStringResult
		STRNegativePartial = NegativePartial

	elseif (zBoolParam > -1)
		boolParam = zBoolParam
		lookupType = 2

	endif

	CallEvent("Run") 
EndFunction

Event Run()
	if lookupType == 0
		IntLookup()
	elseif lookupType == 2
		BoolLookup()
	ElseIf lookupType == 1
		if STRallowpartial
			if STRNegativePartial
				StringLookupNegPartial()
			else 
				StringLookupPartial()
			endif 
		else 
			StringLookup()
		endif 
	endif 
EndEvent

Function IntLookup()
	int parameter = intParam

	int ret = JArray.object()

	int animation  
	int elementValue

	int i = min
	while i < max
		Animation = JArray.GetObj(jarrayObj, i)
		elementValue = JMap.GetInt(Animation, lookupKey, Default = -10001)
		If (elementValue == parameter) && (elementValue != 10001)
			JArray.AddObj(Ret, Animation)
		EndIf

		i += 1
	endwhile

	mother.RecieveResult(ret, id)
EndFunction

Function BoolLookup()
	int parameter = boolParam

	int ret = JArray.object()

	int animation  
	bool elementValue

	int i = min
	while i < max
		Animation = JArray.GetObj(jarrayObj, i)
		elementValue = (JMap.getInt(Animation, lookupKey, Default = 0) as Bool)
		If (elementValue == BoolParam as Bool)
			JArray.AddObj(Ret, Animation)
		EndIf

		i += 1
	endwhile

	mother.RecieveResult(ret, id)
EndFunction

Function StringLookup()
	string parameter = strparam

	int ret = JArray.object()

	int animation  
	string elementValue

	int i = min
	while i < max
		Animation = JArray.GetObj(jarrayObj, i)
		elementValue = JMap.GetStr(Animation, lookupKey, Default = "")
		If (elementValue == parameter) && (elementValue != "")
			JArray.AddObj(Ret, Animation)
		EndIf

		i += 1
	endwhile

	mother.RecieveResult(ret, id)
EndFunction

Function StringLookupPartial()
	string parameter = strparam

	int ret = JArray.object()

	int animation  
	string elementValue

	int i = min
	while i < max
		Animation = JArray.GetObj(jarrayObj, i)
		elementValue = JMap.GetStr(Animation, lookupKey, Default = "")
		If (StringUtil.Find(elementValue, parameter) != -1)
			JArray.AddObj(Ret, Animation)
		EndIf

		i += 1
	endwhile

	mother.RecieveResult(ret, id)
EndFunction

Function StringLookupNegPartial()
	string parameter = strparam

	int ret = JArray.object()

	int animation  
	string elementValue

	int i = min
	while i < max
		Animation = JArray.GetObj(jarrayObj, i)
		elementValue = JMap.GetStr(Animation, lookupKey, Default = "")
		If !(StringUtil.Find(elementValue, parameter) != -1)
			JArray.AddObj(Ret, Animation)
		EndIf

		i += 1
	endwhile

	mother.RecieveResult(ret, id)
EndFunction





ODThread Function NewObject(int thread_id, odthreadmanager creator) Global
	ODThread obj = BaseObject.Construct("ODThread") as ODThread
	
	obj.Setup(thread_id, creator)
	return obj
EndFunction 

Function Setup(int thread_id, odthreadmanager creator)
	id = thread_id

	mother = creator
EndFunction
