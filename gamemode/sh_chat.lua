if (SERVER) then
	util.AddNetworkString "tttrw_chat"

	function ttt.chat(...)
		net.Start "tttrw_chat"
			net.WriteUInt(select("#", ...), 8)
			for i = 1, select("#", ...) do
				local arg = select(i, ...)
				if (IsColor(arg)) then
					net.WriteBool(false)
					net.WriteColor(arg)
				else
					net.WriteBool(true)
					net.WriteString(tostring(arg))
				end
			end
		net.Broadcast()
	end

	FindMetaTable "Player".ChatPrint = function(self, ...)
		net.Start "tttrw_chat"
			net.WriteUInt(select("#", ...), 8)
			for i = 1, select("#", ...) do
				local arg = select(i, ...)
				if (IsColor(arg)) then
					net.WriteBool(false)
					net.WriteColor(arg)
				else
					net.WriteBool(true)
					net.WriteString(tostring(arg))
				end
			end
		net.Send(self)
	end
else
	net.Receive("tttrw_chat", function(len, cl)
		local stuff = {}
		for i = 1, net.ReadUInt(8) do
			if (net.ReadBool()) then
				stuff[i] = net.ReadString()
			else
				stuff[i] = net.ReadColor()
			end
		end

		table.insert(stuff, 1, white_text)

		chat.AddText(unpack(stuff))
	end)
end