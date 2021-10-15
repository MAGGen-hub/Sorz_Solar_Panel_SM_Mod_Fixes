if Solar_Panel then return end 
Solar_Panel = class()
Solar_Panel.maxChildCount = 1
Solar_Panel.maxParentCount = 0
Solar_Panel.connectionInput = sm.interactable.connectionType.none
Solar_Panel.connectionOutput = sm.interactable.connectionType.logic
Solar_Panel.colorNormal = sm.color.new(0xbd5cacff)
Solar_Panel.colorHighlight = sm.color.new(0xf075dbff)