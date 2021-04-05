ScriptName OSANative


; ██████╗  █████╗ ████████╗ █████╗ ██████╗  █████╗ ███████╗███████╗
; ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝
; ██║  ██║███████║   ██║   ███████║██████╔╝███████║███████╗█████╗
; ██║  ██║██╔══██║   ██║   ██╔══██║██╔══██╗██╔══██║╚════██║██╔══╝
; ██████╔╝██║  ██║   ██║   ██║  ██║██████╔╝██║  ██║███████║███████╗
; ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝


; Build the json database
Function BuildDB() Global Native


;  ██████╗ ██████╗      ██╗███████╗ ██████╗████████╗
; ██╔═══██╗██╔══██╗     ██║██╔════╝██╔════╝╚══██╔══╝
; ██║   ██║██████╔╝     ██║█████╗  ██║        ██║
; ██║   ██║██╔══██╗██   ██║██╔══╝  ██║        ██║
; ╚██████╔╝██████╔╝╚█████╔╝███████╗╚██████╗   ██║
;  ╚═════╝ ╚═════╝  ╚════╝ ╚══════╝ ╚═════╝   ╚═╝


; Find the nearest beds
; [CenterRef] ObjectReference as the origin for the search.
; [Radius]    Radius to search for beds.
; [SameFloor] Setting a value above 0 will set the tolerance threshold for the bed's height.
; Returns an array of beds from closest to farthest
ObjectReference[] Function FindBed(ObjectReference CenterRef, Float Radius = 1000.0, Float SameFloor = 0.0) Global Native


;  ██████╗ █████╗ ███╗   ███╗███████╗██████╗  █████╗
; ██╔════╝██╔══██╗████╗ ████║██╔════╝██╔══██╗██╔══██╗
; ██║     ███████║██╔████╔██║█████╗  ██████╔╝███████║
; ██║     ██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗██╔══██║
; ╚██████╗██║  ██║██║ ╚═╝ ██║███████╗██║  ██║██║  ██║
;  ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝


; Is FreeCam enabled
Bool Function IsFreeCam() Global Native

; Enable/Disable FreeCam
Function EnableFreeCam(Bool StopTime = False) Global Native
Function DisableFreeCam() Global Native

; Set FreeCam speed (default: 10.0)
Function SetFreeCamSpeed(Float Speed = 10.0) Global Native

; Set FOV
Function SetFOV(Float Value, Bool FirstPerson = False) Global Native


; ███████╗ █████╗  ██████╗███████╗
; ██╔════╝██╔══██╗██╔════╝██╔════╝
; █████╗  ███████║██║     █████╗
; ██╔══╝  ██╔══██║██║     ██╔══╝
; ██║     ██║  ██║╚██████╗███████╗
; ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝


Bool Function SetFace(Actor Act, Int Mode, Int ID, Int Value) Global Native
Int Function GetFace(Actor Act, Int Mode, Int ID) Global Native

; Does not reset Expression
Bool Function ResetFace(Actor Act) Global
	Return SetFace(Act, -1, 0, 0)
EndFunction

; Set Phoneme/Modifier
Bool Function SetFacePhoneme(Actor Act, Int ID, Int Value) Global
	Return SetFace(Act, 0, ID, Value)
EndFunction
Bool Function SetFaceModifier(Actor Act, Int ID, Int Value) Global
	Return SetFace(Act, 1, ID, Value)
EndFunction

; Get Phoneme/Modifier/Expression
Int Function GetFacePhoneme(Actor Act, Int ID) Global
	Return GetFace(Act, 0, ID)
EndFunction
Int Function GetFaceModifier(Actor Act, Int ID) Global
	Return GetFace(Act, 1, ID)
EndFunction
Int Function GetFaceExpression(Actor Act) Global
	Return GetFace(Act, 2, 0)
EndFunction

; Get Expression ID
Int Function GetFaceExpressionID(Actor Act) Global
	Return GetFace(Act, 3, 0)
EndFunction
