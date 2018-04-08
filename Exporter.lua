
_addon.name = 'Exporter'
_addon.author = 'Sebyg666'
_addon.version = '1.0.0.3'
_addon.commands = {'ex','exporter'}


require('tables')
require('lists')
require('strings')
require('logger')
require('pack')

DW_Gear = require('DW_Gear')
Unity_rank = require('Unity rank gear')
Unity_temp = require('Unity Temp')
Set_Bonus = require('Set_Bonuses')
Ripped_set_bonus = require('Set_Bonuses_ripped_from_resources')
ordered_sets = require("items rippes by set bonus string")
sets = require('set_ids')
full_sets = require('Full sets')

res = require('resources')
skills_from_resources = res.skills
Extdata = require("extdata")
texts = require('texts')
config = require('config')
files = require('files')
packets = require('packets')
bit = require('bit')

player = windower.ffxi.get_player()

windower.register_event('load', function()
	if player ~= nil then
		options_load()
	end
end)

function options_load()
	if windower.ffxi.get_player() then
		player = windower.ffxi.get_player()
		local this_file = files.new('data\\'..player.name..'_data.lua',true)
		
		if not files.exists('data\\'..player.name..'_data.lua') then
			this_file:create()
			local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','w+')
			f:write('return {\n}')
			f:close()
			print(player.name..'_data.lua created by GearInfo')
		end
	end
	--table.vprint(Unity_rank)
end

windower.register_event('addon command', function(command, ...)
	local args = {...}
    command = command and command:lower()
	
	if command then
        if command == 'parse' then
			log('Parsing all inventories to file')
			parse_inventory()
		 elseif command == 'unity' then
			log('Parsing unity file')
			parse_unity()
		elseif command == 'set' then
			log('Parsing Set_Bonuses file')
			parse_set()
		elseif command == 'set2' then
			log('Parsing Set_Bonuses2 file')
			parse_set2()
		elseif command == 'set3' then
			log('Parsing Set_Bonuses3 file')
			parse_set3()
		elseif command == 'set4' then
			log('Parsing Set_Bonuses4 file')
			parse_set4()
		elseif command == 'set5' then
			log('Parsing Set_Bonuses5 file')
			parse_set5()
		end
	end
end)


function save_table_to_file(item_table)
	
	local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','w+')
	--f:write(temp)
	-- Quick method
	f:write('return ' .. T(item_table):tovstring())
    f:close()
	notice('File finished')
end

function parse_inventory()
	
	local items_in_bag = T{}
	local full_gear_table_rw = T{}
	for k,v in pairs(res.bags) do
		for i,n in pairs(windower.ffxi.get_items(v.id)) do
			items_in_bag[#items_in_bag +1] = n
		end
	end
	for k,v in pairs(items_in_bag) do
		if v ~= nil and type(v) == 'table' then
			if v.id ~= 0 then
				local this_item = find_all_values(v)
				if this_item ~= nil then
					full_gear_table_rw[#full_gear_table_rw +1] = this_item
				end
			end
		end	
	end
	
	-- local full_gear_table_rw = T{}
	
	-- for k, v in pairs(res.items) do
		-- if k > 28281 and k < 28283 then
			-- -- notice(k)
			-- -- table.vprint(v)
			-- local this_item = find_all_values(v)
			-- full_gear_table_rw[#full_gear_table_rw +1] = this_item
		-- end
	-- end
	save_table_to_file(full_gear_table_rw)

end

function parse_set5()
	local temp_table = {}
	temp_table = full_sets
	save_table_to_file(temp_table)
end

function parse_set4()
	
	local temp_table = {}
	
	for i, j in pairs(sets) do
	
		if temp_table[j['set id']] then
			temp_table[j['set id']][i] = {id=i,en=j.en,enl=j.enl , ["Set Bonus"] = j["Set Bonus"], bonus = '', ['minimum peices'] = 2 }
		else
			temp_table[j['set id']]= {}
			temp_table[j['set id']][i]= {id=i,en=j.en,enl=j.enl , ["Set Bonus"] = j["Set Bonus"], bonus = '', ['minimum peices'] = 2 }
		end
	end
	
	save_table_to_file(temp_table)
end

function parse_set3()
	local temp_table = {}
	local set_number = 1
	-- for i, j in pairs(ordered_sets) do
		-- -- i = set bonus string
		-- -- j = item
		-- pattern = "(^%w+)"
		-- for key  in j.enl:gmatch(pattern) do
			-- ordered_sets[i][j.id]['set id'] = set_number
			-- ordered_sets[i][j.id]['bonus'] = {[1] = '', [2] = '', [3] = '',[4] = '',[5]}
		-- end
	-- end
	for i, j in pairs(Ripped_set_bonus) do
		pattern = "^%a+"
		key = j.enl:match(pattern)
		--notice(key)
			for k, v in pairs(Ripped_set_bonus) do
				if v.enl:contains(key) and Ripped_set_bonus[k]['set id'] == nil and j['Set Bonus'] == v['Set Bonus']  then
					Ripped_set_bonus[k]['set id'] = set_number
				end
			end
		set_number = set_number +1
	end

	save_table_to_file(Ripped_set_bonus)
end

function parse_set2()
	
	local string_table = {}
	
	for i, j in pairs(Ripped_set_bonus) do
		-- pattern = "(^%w+)"
		-- for key  in j.enl:gmatch(pattern) do
			-- string_table[key] = {set=key,['Set Bonus']=j['Set Bonus'], [i] ={id=i,en=j.en,enl=j.enl} }
		-- end
	
	
	
		if string_table[j['Set Bonus']] then
			string_table[j['Set Bonus']][i] = {id=i,en=j.en,enl=j.enl}
		else
			string_table[j['Set Bonus']]= {}
			string_table[j['Set Bonus']][i]= {id=i,en=j.en,enl=j.enl}
		end
	end
	
	save_table_to_file(string_table)
end

function parse_set()
	
	local string_table = {}
	
	for i, j in pairs(Set_Bonus) do
		local discription_string = string.gsub(j.en, '\n', ' ') 
		
		if discription_string:contains('Set: ') then
			str_table = discription_string:psplit("Set: ")
			discription_string = str_table[2]
		end
		string_table[i] = {id=i,en=res.items:with('id', i).en,enl=res.items:with('id', i).enl,['Set Bonus'] = discription_string}
	end
	
	save_table_to_file(string_table)
end

function parse_unity()

	local valid_strings = L{'DEF','HP','MP','STR','DEX','VIT','AGI','INT','MND','CHR',
								'Accuracy','Acc.','Attack','Atk.',
								'Ranged_accuracy', 'Ranged_attack',
								'Magic_accuracy', 'Magic Atk. Bonus',
								'Haste','\"Slow\"','\"Store TP\"','\"Dual Wield\"','\"Fast Cast\"',
								'DMG','Emnity','Critical hit rate','Evasion',
								"Hand-to-Hand skill", "Dagger skill", "Sword skill", "Great sword skill", "Axe skill", "Great axe skill",  "Scythe skill", "Polearm skill", 
								"Katana skill", "Great katana skill", "Club skill",  "Staff skill", "Archery skill", "Marksmanship skill" , "Throwing skill",
								'\"Rapid Shot\"','\"Subtle Blow\"','\"Conserve MP\"','\"Cure\" potency','Double_attack','Triple_attack','\"Refresh\"','MP recovered while healing',
								}
	
	local temp_table = T{}
	local temp_key = { 
		["Acc."] = "Accuracy",
		["Atk."] = 'Attack',
		['\"Slow\"'] = 'Slow',
		['\"Store TP\"'] = 'Store TP', 
		['\"Rapid Shot\"'] = "Rapid Shot",
		['\"Subtle Blow\"'] = "Subtle Blow",
		['\"Cure\" potency'] = 'Cure potency',
		['\"Refresh\"'] = 'Refresh',
		['\"Dual Wield\"'] = 'Dual Wield' ,
		['\"Fast Cast\"'] = 'Fast Cast' ,
		["Double_attack"] = 'Double Attack',
		["Triple_attack"] = 'Triple Attack',
		['Magic_accuracy'] = 'Magic Accuracy' , 
		['Ranged_accuracy'] =  'Ranged Accuracy' ,
		['Ranged_attack'] =  'Ranged Attack' ,
		['Magic_evasion'] = 'Magic Evasion',
		["Great axe skill"] = "Great Axe skill" ,
		["Great katana skill"] = "Great Katana skill",
		["Great sword skill"] = "Great Sword skill",
		['\"Conserve MP\"'] = 'Conserve MP',
	}
	
	local string_table = {}
	
	for i, j in pairs(Unity_temp) do
	
		discription_string = string.gsub(j.en, '\n', ' ') 
		-- string that need modifying to stop clashing
		discription_string = string.gsub(discription_string, 'Ranged Accuracy%s?', 'Ranged_accuracy') 
		discription_string = string.gsub(discription_string, 'Rng.%s?Acc.%s?', 'Ranged_accuracy')  
		discription_string = string.gsub(discription_string, 'Ranged Attack%s?', 'Ranged_attack') 
		discription_string = string.gsub(discription_string, 'Rng.%s?Atk.%s?', 'Ranged_attack') 
		
		discription_string = string.gsub(discription_string, 'Magic Accuracy%s?', 'Magic_accuracy')
		discription_string = string.gsub(discription_string, 'Mag.%s?Acc.%s?', 'Magic_accuracy') 	
		discription_string = string.gsub(discription_string, 'Magic Acc.%s?', 'Magic_accuracy') 
		
		discription_string = string.gsub(discription_string, '\"Magic Atk. Bonus\"', 'Magic Atk. Bonus' )
		discription_string = string.gsub(discription_string, '\"Mag.%s?Atk.%s?Bns.\"', 'Magic Atk. Bonus' ) 
		
		discription_string = string.gsub(discription_string, 'Magic Evasion', 'Magic_evasion' )
		
		discription_string = string.gsub(discription_string, '\"Double Attack\"', 'Double_attack' )
		discription_string = string.gsub(discription_string, '\"Triple Attack\"', 'Triple_attack' )
		
		discription_string = string.gsub(discription_string,  "Great Axe skill",  "Great axe skill")
		discription_string = string.gsub(discription_string,  "Great Katana skill",  "Great katana skill")
		discription_string = string.gsub(discription_string,  "Great Sword skill",  "Great sword skill")
	
		if discription_string:contains('Pet:') then
			str_table = discription_string:psplit("Pet:")
			discription_string = str_table[1]
		elseif discription_string:contains('Wyvern:') then
			str_table = discription_string:psplit("Wyvern:")
			discription_string = str_table[1]
		elseif discription_string:contains('Avatar:') then
			str_table = discription_string:psplit("Avatar:")
			discription_string = str_table[1]
		elseif discription_string:contains('Latent effect:') then
			str_table = discription_string:psplit("Latent effect:")
			discription_string = str_table[1]
		elseif discription_string:contains('Rainy weather:') then
			str_table = discription_string:psplit("Rainy weather:")
			discription_string = str_table[1]
		end		
		
		for k, v in pairs(valid_strings) do
			-- v = DEF etc
			pattern = "Unity Ranking:%s?("..v.."):?%s?([+-]?%d+)～(%d+)"
			for key , val, val2 in j.en:gmatch(pattern) do
				if temp_key[key] then
					temp_table[temp_key[key]] = {min = tonumber(val), max = tonumber(val2)}
					string_table[i] = {id=i,en=res.items:with('id', i).en,['Unity Ranking'] = temp_key[key], rank = temp_table[temp_key[key]]}
				else
					temp_table[key] = {min = tonumber(val), max = tonumber(val2)}
					string_table[i] = {id=i,en=res.items:with('id', i).en,['Unity Ranking'] = key, rank = temp_table[key]}
				end			
			end
		end
	end
	save_table_to_file(string_table)
end

function find_all_values(item)
	-- notice(item.id)
	local temp = check_for_augments(item)
	local augs = Extdata.decode(item).augments
	
	local item = res.items:with('id', item.id)

	if item.flags:contains('Equippable') then
	
		if res.item_descriptions[item.id] then
			item.discription = string.gsub(res.item_descriptions:with('id', item.id ).en, '\n', ' ') 
		else
			item.discription = 'none'
		end
		
		descript_table = T{}
		descript_table = desypher_description(item.discription)
		
		item.defined_job = T{}
		
		for k, v in pairs(item.jobs) do
			item.defined_job[k] = res.jobs:with('id', k ).ens	
		end
		
		item.defined_slots = T{}
		for k, v in pairs(item.slots) do
			item.defined_slots[k] = res.slots:with('id', k ).en	
		end
		
		local edited_item = T{en=item.en, id=item.id, category=item.category , discription = item.discription, jobs = item.defined_job, slots = item.defined_slots}
		
		if augs then edited_item.augments = augs end
		
		for k, v in pairs(descript_table) do
			edited_item[k] = v
		end
		
		-- Check "Enhances \"Dual Wield\" effect" Gear for value
		for k, v in pairs(DW_Gear) do
			if item.id == k then
				if  edited_item['Dual Wield'] then
					edited_item['Dual Wield'] = edited_item['Dual Wield'] + v["Dual Wield"]
				else
					edited_item['Dual Wield'] = v["Dual Wield"]
				end
			end
		end
		
		-- Check Unity gear for stat and value.
		for k, v in pairs(Unity_rank) do
			if item.id == k then
				if edited_item[v['Unity Ranking']] then
					-- edited_item[v['Unity Ranking']] = edited_item[v['Unity Ranking']] + v.rank[settings.rank]
					edited_item[v['Unity Ranking']] = edited_item[v['Unity Ranking']] + v.rank[1]
				else
					-- edited_item[v['Unity Ranking']] = v.rank[settings.rank]
					edited_item[v['Unity Ranking']] = v.rank[1]
				end
			end
		end
		
		if item.category == 'Weapon' then
			for k,v in pairs(item) do
				if k == 'delay' then	
					edited_item[k] = tonumber(v)
				end
				if k == 'skill' then
					local skill = res.skills:with('id', v ).en
					edited_item[k] = skill
				end
			end
		end
		
		if temp then
			local temp_augments = T{}
			for k, v in pairs(temp) do
				temp_augments[k] = v
			end
			
			for k, v in pairs(temp_augments) do
				if edited_item[k] then
					edited_item[k] = edited_item[k] + v
				else
					edited_item[k] = v
				end
			end
		end

		return edited_item
	end
		
end

function check_for_augments(item)
	
	local augs = Extdata.decode(item).augments
	local item_t = res.items:with('id', item.id)
	local temp = T{}
	if augs then
		for k,v in pairs(augs) do
			
			if v:contains('Pet:') or v:contains('Wyvern:') or v:contains('Avatar:') then
				break
			end
			for i, j in pairs(desypher_description(v, item_t)) do
				if temp[i] then
					temp[i] = temp[i] + j
				else
					temp[i] = j
				end
			end
		end
		return temp
	else
		return nil
	end
	
end

function desypher_description(discription_string, item_t)
	
	-- string that need modifying to stop clashing
	discription_string = string.gsub(discription_string, 'Ranged Accuracy%s?', 'Ranged_accuracy') 
	discription_string = string.gsub(discription_string, 'Rng.%s?Acc.%s?', 'Ranged_accuracy')  
	discription_string = string.gsub(discription_string, 'Ranged Attack%s?', 'Ranged_attack') 
	discription_string = string.gsub(discription_string, 'Rng.%s?Atk.%s?', 'Ranged_attack') 
	
	discription_string = string.gsub(discription_string, 'Magic Accuracy%s?', 'Magic_accuracy')
	discription_string = string.gsub(discription_string, 'Mag.%s?Acc.%s?', 'Magic_accuracy') 	
	discription_string = string.gsub(discription_string, 'Magic Acc.%s?', 'Magic_accuracy') 
	
	discription_string = string.gsub(discription_string, '\"Magic Atk. Bonus\"', 'Magic Atk. Bonus' )
	discription_string = string.gsub(discription_string, '\"Mag.%s?Atk.%s?Bns.\"', 'Magic Atk. Bonus' ) 
	
	discription_string = string.gsub(discription_string, 'Magic Evasion', 'Magic_evasion' )
	
	discription_string = string.gsub(discription_string,  "Great Axe skill",  "Great axe skill")
	discription_string = string.gsub(discription_string,  "Great Katana skill",  "Great katana skill")
	discription_string = string.gsub(discription_string,  "Great Sword skill",  "Great sword skill")
	
	local str_table = ''
	
	if discription_string:contains('Pet:') then
		str_table = discription_string:psplit("Pet:")
		discription_string = str_table[1]
	elseif discription_string:contains('Wyvern:') then
		str_table = discription_string:psplit("Wyvern:")
		discription_string = str_table[1]
	elseif discription_string:contains('Avatar:') then
		str_table = discription_string:psplit("Avatar:")
		discription_string = str_table[1]
	elseif discription_string:contains('Unity Ranking:') then
		str_table = discription_string:psplit("Unity Ranking:")
		discription_string = str_table[1]
	elseif discription_string:contains('Latent effect:') then
		str_table = discription_string:psplit("Latent effect:")
		discription_string = str_table[1]
	elseif discription_string:contains('Rainy weather:') then
		str_table = discription_string:psplit("Rainy weather:")
		discription_string = str_table[1]
	end

	local valid_strings = L{'DEF','HP','MP','STR','DEX','VIT','AGI','INT','MND','CHR',
								'Accuracy','Acc.','Attack','Atk.',
								'Ranged_accuracy', 'Ranged_attack',
								'Magic_accuracy', 'Magic Atk. Bonus',
								'Haste','\"Slow\"','\"Store TP\"','\"Dual Wield\"','\"Fast Cast\"',
								'DMG',
								"Hand-to-Hand skill", "Dagger skill", "Sword skill", "Great sword skill", "Axe skill", "Great axe skill",  "Scythe skill", "Polearm skill", 
								"Katana skill", "Great katana skill", "Club skill",  "Staff skill", "Archery skill", "Marksmanship skill" , "Throwing skill"
								}
	
	local temp_table = T{}
	local temp_key = { 
		["Acc."] = "Accuracy",
		["Atk."] = 'Attack',
		['\"Slow\"'] = 'Slow',
		['\"Store TP\"'] = 'Store TP', 
		['\"Dual Wield\"'] = 'Dual Wield' ,
		['\"Fast Cast\"'] = 'Fast Cast' ,
		['Magic_accuracy'] = 'Magic Accuracy' , 
		['Ranged_accuracy'] =  'Ranged Accuracy' ,
		['Ranged_attack'] =  'Ranged Attack' ,
		['Magic_evasion'] = 'Magic Evasion',
		["Great axe skill"] = "Great Axe skill" ,
		["Great katana skill"] = "Great Katana skill",
		["Great sword skill"] = "Great Sword skill",
	}
	
	for k, v in pairs(valid_strings) do
		-- v = DEF etc
		pattern = "("..v.."):?%s?([+-]?%d+)"
		for key , val in discription_string:gmatch(pattern) do
			
			if temp_key[key] then
				temp_table[temp_key[key]] = tonumber(val)
			else
				temp_table[key] = tonumber(val)	
			end
			-- if item_t then
				-- if item_t.id == 25643 then
					-- notice('('..discription_string .. ') '..key .. ' ' ..val)
				-- end
			-- end
		end
	end
	return temp_table
end

