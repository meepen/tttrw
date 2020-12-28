ttt.QuickChat = {
	yes = "Yes.",
	no = "No.",
	help = "Help!",
	imwith = "I'm with {target}",
	see = "I see {target}",
	suspect = "{target} acts suspicious.",
	traitor = "{target} is a Traitor!",
	innocent = "{target} is innocent.",
	check = "Anyone still alive?",
}

ttt.QuickChat_Order = {
	"yes",
	"no",
	"help",
	"imwith",
	"see",
	"suspect",
	"traitor",
	"innocent",
	"check",
}

function GM:FormatQuickChat(sender, str)
	return hook.Run("FormatPlayerText", sender, str) or str
end

if (SERVER) then
	concommand.Add("_ttt_radio_send", function(ply, cmd, args)
		if ((ply.NextRadioCommand or -math.huge) > CurTime() or not ply:Alive()) then
			return
		end
		local str = args[1]
		local chat = ttt.QuickChat[str]
		if (chat) then
			ply.NextRadioCommand = CurTime() + 1
			ply.InRadioChat = true
			ply:Say(chat)
			ply.InRadioChat = nil
		end
	end)
else
	concommand.Add("ttt_radio", function(ply, cmd, args)
		local str = args[1]
		if (ttt.QuickChat[str]) then
			RunConsoleCommand("_ttt_radio_send", str)
			ply.NextRadioCommand = CurTime() + 1
		elseif ((ply.NextRadioCommand or -math.huge) <= CurTime() and LocalPlayer():Alive()) then
			if (IsValid(ttt.radio_menu)) then
				ttt.radio_menu:Remove()
				return
			end

			ttt.radio_menu = vgui.Create "ttt_radio_menu"
			ttt.radio_menu:SetActiveTime(CurTime())
		end
	end)

	for k in pairs(ttt.QuickChat) do
		concommand.Add("ttt_radio_" .. k, function()
			RunConsoleCommand("_ttt_radio_send", k)
		end)
	end

	hook.Add("ShowQuickChat", "quickchat", function(ply, pressed)
		if (pressed) then
			RunConsoleCommand "ttt_radio"
		end
		return true
	end)
end