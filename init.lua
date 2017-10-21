bows = {}

minetest.register_entity("bows:newarrow", {
	physical = false,
	timer=0,
	visual = "mesh",
	textures = {"bows_entity.png"},
	mesh = "newer_arrow.b3d",
	lastpos={},
	visual_size = {x=4, y=4},
	collisionbox = {1,1,1,1,1,1},
	on_step = function(self, dtime)
	end,
})

minetest.register_entity("bows:arrow", {
	physical = false,
	timer=0,
	visual = "mesh",
	textures = {"bows_entity.png"},
	mesh = "newer_arrow.b3d",
	lastpos={},
	visual_size = {x=4, y=4},
	collisionbox = {0,0,0,0,0,0},
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		local pos = self.object:getpos()
		local node = minetest.get_node(pos)
	
		if self.timer>0.2 then
			local objs = minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)
			for k, obj in pairs(objs) do
				if obj:get_luaentity() ~= nil then
					if obj:get_luaentity().name ~= "bows:arrow" and obj:get_luaentity().name ~= "__builtin:item" then
						obj:punch(self.object, 1.0, {
							full_punch_interval=1.0,
							damage_groups={fleshy=3},
						}, nil)
						self.object:remove()
					end
				else
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=3},
					}, nil)
					self.object:remove()
				end
			end
		end
	
		if self.lastpos.x~=nil then
			if node.name ~= "air" then
				self.object:remove()
			end
		end
		self.lastpos={x=pos.x, y=pos.y, z=pos.z}
	end
})

function bows.fire_arrow(user, power)
	local pos = user:getpos()
	
	local obj = minetest.add_entity({x=pos.x,y=pos.y+1.5,z=pos.z}, "bows:arrow")
	local dir = user:get_look_dir()
	
	obj:setvelocity({x=dir.x*12*power, y=dir.y*12*power, z=dir.z*12*power})
	obj:setacceleration({x=dir.x*-3, y=-10, z=dir.z*-3})
	obj:setyaw(user:get_look_horizontal())
end

function bows.on_pull(user, power)
	minetest.after(0.5, function(user)
		controls = user:get_player_control()
		user:set_wielded_item("bows:bow3")
		if controls.LMB == true then
			if power < 4 then
				power = power + 1
			end
			bows.on_pull(user, power)
		else
			-- TODO: Detect if the player switches
			-- to a different item in the hotbar.
			user:set_wielded_item("bows:bow")
			if not minetest.setting_getbool("creative_mode") then
				user:get_inventory():remove_item("main", "bows:arrow")
			end
			
			bows.fire_arrow(user,power)
		end
	end,user)
end

minetest.register_craftitem("bows:arrow",{
	description = "Arrow",
	inventory_image = "bows_arrow.png",
})

minetest.register_craftitem("bows:bow",{
	description = "Bow",
	inventory_image = "bows_bow.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		controls = user:get_player_control()
		
		minetest.after(0.5, function(user)
			controls = user:get_player_control()
			user:set_wielded_item("bows:bow1")
			if controls.LMB == true then
				minetest.after(0.5, function(user)
					controls = user:get_player_control()
					user:set_wielded_item("bows:bow2")
					if controls.LMB == true then
						bows.on_pull(user,1)
					else
						user:set_wielded_item("bows:bow")
					end
				end,user)
			else
				user:set_wielded_item("bows:bow")
			end
		end,user)
	end,
})

minetest.register_craftitem("bows:bow1",{
	description = "You Hacker You!",
	inventory_image = "bows_bow_1.png",
	groups = {not_in_creative_inventory=1},
	on_use = function() -- Empty function prevents tool swinging.
	end,
})

minetest.register_craftitem("bows:bow2",{
	description = "You Hacker You!",
	inventory_image = "bows_bow_2.png",
	groups = {not_in_creative_inventory=1},
	on_use = function() -- Empty function prevents tool swinging.
	end,
})

minetest.register_craftitem("bows:bow3",{
	description = "You Hacker You!",
	inventory_image = "bows_bow_3.png",
	groups = {not_in_creative_inventory=1},
	on_use = function() -- Empty function prevents tool swinging.
	end,
})

-- Crafting Recipes

minetest.register_craft({
	output = "bows:bow",
	recipe = {
		{"","default:stick","farming:cotton"},
		{"default:stick","","farming:cotton"},
		{"","default:stick","farming:cotton"}
	}

})

minetest.register_craft({
	output = "bows:arrow 4",
	recipe = {
		{"default:flint"},
		{"default:stick"},
		{"default:stick"},
	}
})
