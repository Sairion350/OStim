Scriptname _oUI_Lockwidget extends SKI_WidgetBase
{Lock symbol widget to indicate when OSA controls are locked.}

; code

Event OnWidgetReset()
    parent.OnWidgetReset()
EndEvent

String Function GetWidgetSource()
    Return "ostim/LockSymbolWidget.swf"
EndFunction

Bool Function GetVisible()
    Return Ui.GetBool(HUD_MENU, WidgetRoot + "._visible")
EndFunction

Bool Function SetVisible(bool IsVisible)
    UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", IsVisible)
    Return GetVisible()
EndFunction