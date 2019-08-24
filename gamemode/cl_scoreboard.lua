function GM:ScoreboardShow()
	if (IsValid(ttt.Scoreboard)) then
		ttt.Scoreboard:Remove()
	end
	ttt.Scoreboard = vgui.Create "ttt_scoreboard"
	ttt.Scoreboard:MakePopup()
	ttt.Scoreboard:SetKeyboardInputEnabled(false)
end

function GM:ScoreboardHide()
	if (IsValid(ttt.Scoreboard)) then
		ttt.Scoreboard:Remove()
	end
end