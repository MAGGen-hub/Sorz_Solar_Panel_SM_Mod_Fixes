SPController = class()
SPController.poseWeightCount = 1
SPController.DayBegin = 4
SPController.DayEnd = 19.5
SPController.maxParentCount = 17
SPController.maxChildCount = 255
SPController.connectionInput = sm.interactable.connectionType.logic + sm.interactable.connectionType.electricity
SPController.connectionOutput = sm.interactable.connectionType.none
SPController.amountPerHour = 1
SPController.period = 40*60
SPController.panel_id = sm.uuid.new("9646e3d9-275b-4dfc-8b73-77ed9b5e07d0")



local timer = 0	
local flag = true
local solar = 0

function SPController.setActive()
	if flag == true then 
		flag = false
		self.interactable:setPoseWeight( 0, 0 )
	elseif flag == false then
		flag = true
		self.interactable:setPoseWeight( 0, 1 )
	end		
end

function SPController.client_onInteract(self, character, state)
	if state == true then
		if flag == false then
			flag = true
			sm.audio.play("Lever on")
			self.interactable:setPoseWeight( 0, 0 )
			sm.gui.displayAlertText( "Energy Mining!", 2 )
		elseif flag == true then
			flag = false
			sm.audio.play("Lever off")
			self.interactable:setPoseWeight( 0, 1 )
			sm.gui.displayAlertText( "Stop Mining!", 2 )
		end
	end
end

function SPController.set_icon(self, value)
	self.interactable:setUvFrameIndex(value)
end

function SPController.server_onFixedUpdate( self )
	if flag == true then 
	timer = timer + 1
	end
	if timer > 100000 then
		timer = 0
	end 
	local obj_consumable_battery = sm.uuid.new("910a7f2c-52b0-46eb-8873-ad13255539af")
	
	if not self.interactable then return end
	
	local time = sm.game.getTimeOfDay()
	local CurrentTime = time * 24
	local panelAmount = 0	
	local num = 0
	local batteryContainer = nil
	
	if CurrentTime > self.DayBegin and CurrentTime < self.DayEnd then
		self.network:sendToClients( "set_icon", 0 )
		for id, gate in pairs(self.interactable:getParents()) do
			local gate_shape = gate:getShape()
			if gate_shape then	
				if tostring(gate_shape.uuid) ==  "9646e3d9-275b-4dfc-8b73-77ed9b5e07d0"  then
					num = num+1	
				end
				if tostring(gate_shape.uuid) ==  "da4833fd-f981-4e08-a9f7-48e630a7c146"  then
					if gate:hasOutputType( sm.interactable.connectionType.electricity) then
						batteryContainer = gate:getContainer(0)
					end	
							
				end
			end
		end			
		
		
		if num == 0 then
			solar = 15 * 2400 
		else
			solar = 15 * 2400 / num
		end
		if not batteryContainer then return end
		if timer > solar then
			timer = 0
	
			sm.container.beginTransaction()
			sm.container.collect( batteryContainer, obj_consumable_battery, 1, true)	
			if sm.container.endTransaction() then
				return true
			end					
		end	
		--print(timer,num,solar)
	else
		self.network:sendToClients( "set_icon", 1 )
	end
end

