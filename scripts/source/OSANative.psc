ScriptName OSANative

; Build the json database
Function BuildDB() Global Native

; Find the nearest beds
; [CenterRef] ObjectReference as the origin for the search.
; [Radius]    Radius to search for beds.
; [SameFloor] Setting a value above 0 will set the tolerance threshold for the bed's height.
; Returns an array of beds from closest to farthest
ObjectReference[] Function FindBed(ObjectReference CenterRef, Float Radius = 1000.0, Float SameFloor = 0.0) Global Native