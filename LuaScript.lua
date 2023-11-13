	local Mode = "Explorer Selection" 

	local TableSpoof = {}
	local Sources = {}

	local GroupToPublishToID = nil
	local UserToPublishToID = nil

	local CheckEachAnimationID = true
	local NumbersToCheck = 5
	local SpecificChecks = {}

	local ScriptToSpoofPath = nil
	local ScriptDirectoryToGoThrough = nil
	local RequireRBXASSETID = true




	if not ScriptDirectoryToGoThrough then
		ScriptDirectoryToGoThrough = game
	end

	for _,v in game:GetDescendants() do if v:IsA("PackageLink") then v:Destroy() end end

	local MarketplaceService = game:GetService("MarketplaceService")

	local function SendPOST(ids: {any})
		local success, result = pcall(function()
			return game:GetService("HttpService"):PostAsync("http://127.0.0.1:6969/", game:GetService("HttpService"):JSONEncode({["ids"]=ids, ["groupID"] = GroupToPublishToID and GroupToPublishToID or nil, ["sourcesToSpoof"] = Sources and Sources or nil}), Enum.HttpContentType.ApplicationJson, 99999)
		end)

		print(success, result)
	end


if Mode == "Explorer Selection" then 

local Type = "Animation"
local Selection = game:GetService("Selection")

local Table = {}

for i, v in game:GetDescendants() do
    if v:IsA(Type) then
        table.insert(Table, v)
    end
end

Selection:Set(Table) 

end 

	local function GetAsync()
		local response = nil

		while not response do
			local success, result = pcall(function()
				return game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("http://127.0.0.1:6969/"))
			end)
			if success then
				response = result
			end
			task.wait(2)
		end

		return response
	end

	local function BeginReupload(ids: {any})
		game:GetService("HttpService"):PostAsync("http://127.0.0.1:6970/", game:GetService("HttpService"):JSONEncode({["ids"]=ids, ["groupID"] = GroupToPublishToID and GroupToPublishToID or nil}))

		task.wait(1)

		local response

		while not response and task.wait(4) do
			response = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("http://127.0.0.1:6970/"))
		end

		local newID = response 

		for _,v in newID do
			if v then
				newID = v
			end
		end

		return newID
	end

	local Modes = {
		Help = "Returns this help guide!",
		Normal = "Begins stealing all animations with no filter whatsoever.",
		SAS = "Steals all animations inside scripts, reuploads them and changes the old IDs for the new ones in the scripts themselves",
		SSS = "Steals all animations in a specific script, reuploads them and changes the old IDs for the new ones in the script itself",
		["Explorer Selection"] = "Only steals animations that are selected in the Roblox Studio's Explorer.",
		["Table Spoof"] = "Only steals animations IDs that you put in the \"TableSpoof\" variable",
		["Table Spoof and Return 1"] = "Only steals animations IDs that you put in the \"TableSpoof\" variable, and returns a table with the IDs without actually changing them in-game (DOESN'T return with rbxassetid://)",
		["Table Spoof and Return 2"] = "Only steals animations IDs that you put in the \"TableSpoof\" variable, and returns a table with the IDs without actually changing them in-game (DOES return with rbxassetid://)",
	}



	game:GetService("HttpService").HttpEnabled = true

	local function ReturnUUID(): {any}
		return tostring(game:GetService("HttpService"):GenerateGUID())
	end

	local CorrectNumbers 
	local CorrectLength

	local ids = {}

	local function GetCorrectNumbers(anim)
		local success, err = pcall(function()
			return MarketplaceService:GetProductInfo(anim.AnimationId:match("%d+"), Enum.InfoType.Asset)
		end)
		
		if not success then return end

		local mpsInfo = MarketplaceService:GetProductInfo(anim.AnimationId:match("%d+"), Enum.InfoType.Asset)

		if mpsInfo.AssetTypeId ~= Enum.AssetType.Animation.Value then return end

		local newID

		if Mode == "Table Spoof and Return 1" or Mode == "Table Spoof and Return 2" then
			newID = BeginReupload({[index] = anim.AnimationId:match("%d+")}) 
		else
			newID = BeginReupload({[anim.Name..ReturnUUID()] = anim.AnimationId:match("%d+")})
		end

		if not newID or type(newID) ~= "string" then return end

		CorrectNumbers = string.sub(string.match(newID, "%d+"), 1, NumbersToCheck)
		CorrectLength = string.len(string.match(newID, "%d+"))
	end

	local function SpoofTable(Table)
		local i = 0

		for index,v in Table do
			local anim = v

			if type(v) == "number" or type(v) == "string" then
				anim = {AnimationId = tostring(v), Name = index}
			elseif anim.ClassName then
				if not anim:IsA("Animation") then
					continue
				end
			end

			if not anim or tonumber(anim.AnimationId:match("%d+")) == nil or string.len(anim.AnimationId:match("%d+")) <= 6 then continue end

			local foundAnimInTable = false

			for _,x in ids do
				if x == anim.AnimationId:match("%d+") then
					foundAnimInTable = true
				end
			end	

			if foundAnimInTable == true then continue end

			i += 1

			if not CorrectNumbers then
				GetCorrectNumbers(anim)
				continue
			end
			
			if CheckEachAnimationID == true and (CorrectNumbers and string.sub(anim.AnimationId:match("%d+"), 1, NumbersToCheck) == CorrectNumbers) then continue end

			local Skip = false

			for _,num in SpecificChecks do
				if string.sub(anim.AnimationId:match("%d+"), 1, string.len(num)) == num then
					Skip = true
				end
			end

			if Skip == true then continue end

			if Mode == "Table Spoof and Return 1" or Mode == "Table Spoof and Return 2" then
				ids[index] = anim.AnimationId:match("%d+")
			else
				ids[anim.Name..ReturnUUID()] = anim.AnimationId:match("%d+")
			end
		end

		return ids
	end

	local function SpoofScript(Path)
		local anims = {}

		if Path and Mode == "SSS" then
			local Source = Path.Source
			Sources[Path:GetFullName()] = Source

			if not Source then warn("Script path invalid") return end

			local tableSource = {}

			for word in Source:gmatch("%S+") do
				table.insert(tableSource, word)
			end

			for _, v in tableSource do
				if v and string.match(v, "%d+") and string.len(string.match(v, "%d+")) > 7 and (RequireRBXASSETID == true and string.find(v, "rbxassetid://")) then
					local animId = ""

					for i,th in string.split(v, "") do
						if string.match(th, "%d") then
							animId = animId..th
						end
					end

					animId = tonumber(animId)

					if not anims[animId] then

						if not anims[animId] then
							local success, err = pcall(function()
								local mpsInfo = MarketplaceService:GetProductInfo(animId, Enum.InfoType.Asset)

								if not mpsInfo then return false end

								if mpsInfo.AssetTypeId ~= Enum.AssetType.Animation.Value then return false end
								if GroupToPublishToID and mpsInfo.Creator.CreatorTargetId == GroupToPublishToID or mpsInfo.Creator.CreatorTargetId == UserToPublishToID then return false end

								return true
							end)
							
							if not success then
								if string.find(err, "429") then
									print("REACHED RATE LIMIT")
									break
								else
									continue
								end
							end

							local Skip = false

							for _,num in SpecificChecks do
								if string.sub(anim.AnimationId:match("%d+"), 1, string.len(num)) == num then
									Skip = true
								end
							end

							if Skip == true then continue end

							print("EXPORTING ANIMATIONS...")

							anims[animId] = animId
						end
					end
				end
			end
		else
			local Break = false
			local sizeInKB = 0

			for _,scriptt in ScriptDirectoryToGoThrough:GetDescendants() do
				if scriptt:IsA("LuaSourceContainer") then

					local Source = scriptt.Source
					local GotAnAnim = false

					if not Source then continue end
					if sizeInKB + string.len(Source) / 1024 > 812 then warn("Reached "..sizeInKB.."/812 KB limit") break end

					local tableSource = {}

					for word in Source:gmatch("%S+") do
						table.insert(tableSource, word)
					end

					local i = 0

					for _, v in tableSource do
						if v and string.match(v, "%d+") and string.len(string.match(v, "%d+")) > 6 and (RequireRBXASSETID == true and string.find(v, "rbxassetid://")) then
							local animId = ""

							for i,th in string.split(v, "") do
								if string.match(th, "%d") then
									animId = animId..th
								end
							end

							animId = tonumber(animId)

							if not anims[animId] then	
								local success, err = pcall(function()
									local mpsInfo = MarketplaceService:GetProductInfo(animId, Enum.InfoType.Asset)

									if not mpsInfo then return false end

									if mpsInfo.AssetTypeId ~= 24 then return false end
									if GroupToPublishToID and mpsInfo.Creator.CreatorTargetId == GroupToPublishToID or mpsInfo.Creator.CreatorTargetId == UserToPublishToID then return false end

									return true
								end)

								if success == false then
									if string.find(err, "429") then
										print("REACHED RATE LIMIT")
										Break = true
										break
									else
										continue
									end
								end

								print("EXPORTING ANIMATIONS...")

								anims[animId] = animId
								GotAnAnim = true
							end
						end
					end

					if GotAnAnim == true then
						sizeInKB += string.len(Source) / 1024
						Sources[scriptt:GetFullName()] = Source
					end 
				end

				if Break == true then
					break
				end
			end
		end

		return anims
	end

	local function GenerateIDList(): {any}
		local ids = {}

		if Mode == "Normal" then
			ids = SpoofTable(ScriptDirectoryToGoThrough:GetDescendants())

		elseif Mode == "Explorer Selection" then
			ids = SpoofTable(game.Selection:Get())

		elseif Mode == "Table Spoof" then
			if not TableSpoof then warn("TableSpoof doesn't exist") return end

			ids = SpoofTable(TableSpoof)

		elseif Mode == "Table Spoof and Return 1" then
			if not TableSpoof then warn("TableSpoof doesn't exist") return end

			ids = SpoofTable(TableSpoof)

		elseif Mode == "Table Spoof and Return 2" then
			if not TableSpoof then warn("TableSpoof doesn't exist") return end

			ids = SpoofTable(TableSpoof)

		elseif Mode == "SAS" then
			ids = SpoofScript()

		elseif Mode == "SSS" then
			if not ScriptToSpoofPath then warn("Please insert the path to the script in the \"ScriptToSpoofPath\" variable") return end

			ids = SpoofScript(ScriptToSpoofPath)
		end

		return ids
	end

	if Mode == "Help" then
		for mod,desc in Modes do
			print(mod.." - "..desc)
		end

		return
	end

	local idsToGet = GenerateIDList()
	SendPOST(idsToGet)

	local newIDList = GetAsync()

	if Mode == "Table Spoof and Return 2" then
		for i,v in newIDList do
			newIDList[i] = "rbxassetid://"..v
		end
	end

	if Mode == "Table Spoof and Return 1" or Mode == "Table Spoof and Return 2" then
		print(newIDList)
		return
	end

	print("CHANGING ANIMATIONS IN ROBLOX...")

	for oldID,newID in newIDList do
		for _,thing in game:GetDescendants() do
			if not thing:IsA("Animation") or not string.match(thing.AnimationId, "%d+") then continue end
			if string.find(string.match(thing.AnimationId, "%d+"), oldID) then
				thing.AnimationId = "rbxassetid://"..tostring(newID)
			end
		end
		task.wait()
	end



	print("FINISHED CHANGING ANIMATIONS IN ROBLOX!")