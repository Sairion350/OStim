ScriptName ODThreadManager extends BaseObject

ODatabaseScript odatabase 

Vector_Form threadlist
mutex threadlock

int threadCount = 8
int singleThreadedThresh = 80

int usingThreads

int[] results

bool clearToReturn


Int Function DatabaseKeyAndParameterLookup(Int zDatabase, String zKey, Int IntParam = -100, String StringParam = "", Int BoolParam = -1, Bool AllowPartialStringResult = False, Bool NegativePartial = False)
	int size = JArray.count(zDatabase)

	if size < singleThreadedThresh
		outils.Console("Thread count: single thread")
		return SingleThreadLookup(zDatabase, zKey, IntParam, StringParam, BoolParam, AllowPartialStringResult, NegativePartial)
	endif 

	threadlock.Lock()

	clearToReturn = false 
	
	database = zDatabase 
	lookupkey = zKey 
	intparameter = IntParam
	stringparameter = StringParam
	boolparameter = BoolParam
	allowpartialstr = AllowPartialStringResult
	negpartial = NegativePartial

	;usingThreads = threadCount
	
	usingThreads = ((size / 100) ) + 1
	if usingThreads > threadCount
		usingThreads = threadCount
	endif

	outils.Console("Thread count: " + usingThreads)

	results = PapyrusUtil.IntArray(usingThreads, -999)

	CallEvent("FireThreads")

	Utility.WaitMenuMode(0.01 * usingThreads)
	while !clearToReturn
		Utility.WaitMenuMode(0.01)
	EndWhile

	threadlock.Unlock()

	return odatabase.MergeOArrays(results)
EndFunction

int database 
string lookupkey 
int intparameter
string stringparameter
int boolparameter
bool allowpartialstr 
bool negpartial 

Event FireThreads()
	int size = Jarray.count(database)
	int i = 0 
	while i < usingThreads
		thread(i).DoLookup(database, size, usingThreads, lookupkey, intparameter, stringparameter, boolparameter, allowpartialstr, negpartial)

		i += 1
	endwhile
EndEvent

Function RecieveResult(int result, int id)
	;OUtils.Console("Thread manager recieved result")
	results[id] = result

	if results.Find(-999) == -1
		;outils.console("Clear to return")
		clearToReturn = true
	else 
		;outils.Console("Not clear to return: " + results.Find(-999))
		;outils.Console("Need: " + usingThreads)
	endif 

EndFunction


odthread function thread(int id)
	return threadlist.get(id) as odthread
EndFunction



Int Function SingleThreadLookup(Int zDatabase, String zKey, Int IntParam = -100, String StringParam = "", Int BoolParam = -1, Bool AllowPartialStringResult = False, Bool NegativePartial = False)

	Int Base = zDatabase
	Int Ret = JArray.object()

	Int i = 0
	Int L = JArray.Count(Base)

	Int Animation ;optimization
	Bool Parameter
	Int iOutput
	String sOutput

    If (IntParam > -100)
        while (i < L)
            Animation = JArray.GetObj(base, i)
            iOutput = JMap.GetInt(Animation, zKey, Default = -10001)
            If (iOutput == IntParam) && (iOutput != 10001)
				JArray.AddObj(Ret, Animation)
			EndIf
            i += 1
        endwhile
		Return Ret
    elseif (StringParam != "")
        If (!AllowPartialStringResult)
            while (i < L)
                Animation = JArray.GetObj(base, i)
                sOutput = JMap.GetStr(Animation, zKey, Default = "")
                If (sOutput == StringParam) && (sOutput != "")
					JArray.AddObj(Ret, Animation)
				EndIf
                i += 1
            endwhile
			Return Ret
        Else
            while (i < L)
                Animation = JArray.GetObj(base, i)
                sOutput = JMap.GetStr(Animation, zKey, Default = "")
                If (StringUtil.Find(sOutput, StringParam) != -1)
                    If (!NegativePartial)
                        JArray.AddObj(ret, Animation)
                    EndIf
                Else
                    If (NegativePartial)
                        JArray.AddObj(ret, Animation)
                    EndIf
                EndIf
                i += 1
            endwhile
			Return Ret
        endif
    ElseIf (BoolParam > -1)
        while (i < L)
            Animation = JArray.GetObj(base, i)
            If ((JMap.getInt(Animation, zKey, Default = 0) as Bool) == BoolParam as Bool)
                JArray.AddObj(Ret, Animation)
            EndIf
            i += 1
        endwhile
		Return Ret
    endif

	Return Ret
EndFunction



ODThreadManager Function NewObject() Global
	ODThreadManager obj = BaseObject.Construct("ODThreadManager") as ODThreadManager
	
	obj.Setup()
	return obj
EndFunction 

Event Destroy()
	threadlock.Destroy()
	threadlist.DestroyAll()
	Parent.Destroy()
EndEvent

Function Setup()
	odatabase = (OUtils.GetOStim() as form ) as ODatabaseScript

	clearToReturn = true

	threadlist = Vector_Form.NewObject()

	threadlock = mutex.NewObject()

	int i = 0
	while i < threadCount
		threadlist.Push_back(ODThread.NewObject(i, self))

		i += 1
	endwhile
EndFunction