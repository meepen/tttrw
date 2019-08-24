function GM:ScoreboardShow()
	if (IsValid(ttt.Scoreboard)) then
		ttt.Scoreboard:Remove()
	end
	ttt.Scoreboard = vgui.Create "ttt_scoreboard"
	ttt.Scoreboard:SetSize(ScrW() * 0.8, ScrH() / 2)
	ttt.Scoreboard:Center()
	ttt.Scoreboard:MakePopup()
	ttt.Scoreboard:SetKeyboardInputEnabled(false)
end

function GM:ScoreboardHide()
	if (IsValid(ttt.Scoreboard)) then
		ttt.Scoreboard:Remove()
	end
end