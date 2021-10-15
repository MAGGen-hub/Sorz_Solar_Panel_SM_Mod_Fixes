SpeenGen = class()
SpeenGen.poseWeightCount = 1
SpeenGen.maxChildCount = 1
SpeenGen.maxParentCount = 1
SpeenGen.connectionInput =  sm.interactable.connectionType.logic + sm.interactable.connectionType.electricity
SpeenGen.connectionOutput = sm.interactable.connectionType.all
SpeenGen.counter = 0
SpeenGen.storage = {}
SpeenGen.timer = 0
SpeenGen.forceMul = 1

-- acd2008e-828b-4b69-8aa8-c33e459f1456 --

function SpeenGen.server_onCreate( self )	
	self.sv = {}
	
	SpeenGen.counter = 0
end

function SpeenGen.sparks( self, data )
	self.state = data.state
	--print("EFFECT")
	self.electricEffect = sm.effect.createEffect( "Part - Electricity" )
	self.electricEffect:start()
	self.electricEffect:setPosition( self.shape.worldPosition + ( sm.shape.getAt( self.shape ) * 0.8 ) )
end

function SpeenGen.server_onFixedUpdate( self )
	local batteryContainer = nil
	local obj_consumable_battery = sm.uuid.new("910a7f2c-52b0-46eb-8873-ad13255539af")
	
	
	if not self.interactable then return end
	for id, gate in pairs(self.interactable:getParents()) do
		local gate_shape = gate:getShape()
		if gate_shape then	
			if tostring(gate_shape.uuid) ==  "da4833fd-f981-4e08-a9f7-48e630a7c146"  then
				if gate:hasOutputType( sm.interactable.connectionType.electricity) then
					batteryContainer = gate:getContainer(0)
				end				
			end
		end
	end			
		
	if not batteryContainer then return end
		
	local body = sm.shape.getBody( self.shape )
	if body == nil then
		return
	end
	if body:isStatic() then
		return
	end
		local mass = 1 + ( body:getMass() / 1000 )
		local direction = self:getDirection()	
		
			local Force = direction * ( math.abs( sm.body.getAngularVelocity( body ):dot( sm.shape.getAt( self.shape ) ) ) / 10 ) * self.forceMul * 0.5 * mass
			local all = math.max(Force.x,Force.y,Force.z)
			if all == 0 then return end
		if(all >= 2 and all <= 21.2) then
			self.counter = self.counter + all
		end
		if(all > 21.2) then
			self.counter = self.counter + ( all / ( 2 + all*2 ) )
			self.sv.storage = { state = self.state}
			
				self.network:sendToClients( "sparks", self.sv.storage )
			
		end
		if(all < 2) then
			self.counter = self.counter + (all/10)
		end
		if self.counter > 100000 / self.forceMul then
	
			sm.container.beginTransaction()
			sm.container.collect( batteryContainer, obj_consumable_battery, 1, true)	
			if sm.container.endTransaction() then
				self.counter = 0
				return true
			end					
		end	
		self.timer = self.timer+1
		if(self.timer >= 40) then
			self.timer = 0
		end 
		print(self.counter,all )
end


function SpeenGen.getDirection( self )
	local position = self.shape:getWorldPosition()
	local offsetposition = position + self.shape:getUp()	
	if offsetposition.z > position.z then
		self.updownchange = true
	else
		self.updownchange = false
	end
	if self.lastupdownchange ~= self.updownchange then
		self.lastupdownchange = self.updownchange
		offsetposition.z = position.z
		if sm.vec3.length( offsetposition ) > 0.01 then 
			if self.updownchange then
				self.movedirection = -sm.vec3.normalize( offsetposition - position ) 
			else
				if offsetposition - position ~= sm.vec3.new(0,0,0) then
					self.movedirection = sm.vec3.normalize( offsetposition - position ) 
				end
			end
		end
	end
	return self.movedirection
end

