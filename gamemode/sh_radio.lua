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

if (SERVER) then
	concommand.Add("_ttt_radio_send", function(ply, cmd, args, str)
		print(str)
	end)
else
	concommand.Add("ttt_radio", function(ply, cmd, args, str)
		print(type(str), str)
	end)
end