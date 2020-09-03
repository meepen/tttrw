if (SERVER) then
	util.AddNetworkString "tttrw_chat"

	local function WriteNetwork(...)
		for i = 1, select("#", ...) do
			local args = {(select(i, ...))}

			local mt = debug.getmetatable(args[1])

			if (mt and mt.__colorprint) then
				args = mt.__colorprint(args[1])
			end

			for _, data in ipairs(args) do
				net.WriteBool(true)
				if (IsColor(data)) then
					net.WriteBool(false)
					net.WriteColor(data)
				else
					net.WriteBool(true)
					net.WriteString(tostring(data))
				end
			end
		end
		net.WriteBool(false)
	end

	function ttt.chat(...)
		net.Start "tttrw_chat"
			WriteNetwork(...)
		net.Broadcast()
	end

	FindMetaTable "Player".ChatPrint = function(self, ...)
		net.Start "tttrw_chat"
			WriteNetwork(...)
		net.Send(self)
	end
else
	net.Receive("tttrw_chat", function(len, cl)
		local stuff = {white_text}

		while (net.ReadBool()) do
			local data
			if (net.ReadBool()) then
				data = net.ReadString()
			else
				data = net.ReadColor()
			end

			stuff[#stuff + 1] = data
		end

		chat.AddText(unpack(stuff))
	end)

	hook.Add("OnPlayerChat", "OnTeamChat", function(ply, text, team, dead)
		if not team then return end

		chat.AddText(ply:GetRoleData().Color, "(TEAM) " .. ply:Name(), white_text, ": " .. text)
		return true
	end)
end