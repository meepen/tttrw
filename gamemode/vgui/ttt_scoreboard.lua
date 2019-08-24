local bg_color = CreateMaterial("ttt_scoreboard_color" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 13 12 13 }",
	["$alpha"] = 0.92
})

local ttt_scoreboard_header = CreateMaterial("ttt_scoreboard_header" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 20 19 20 }",
	["$alpha"] = 0.92
})

local ttt_scoreboard_player_innocent = CreateMaterial("ttt_scoreboard_player_innocent" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 20 200 20 }",
	["$alpha"] = 0.8
})

local ttt_scoreboard_player_traitor = CreateMaterial("ttt_scoreboard_player_traitor" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 240 20 20 }",
	["$alpha"] = 0.8
})

local ttt_scoreboard_player_detective = CreateMaterial("ttt_scoreboard_player_detective" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 20 20 240 }",
	["$alpha"] = 0.8
})

local ttt_scoreboard_player_spectating = CreateMaterial("ttt_scoreboard_player_spectating" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 20 19 20 }",
	["$alpha"] = 0.8
})

surface.CreateFont("ttt_scoreboard_player", {
	font = 'Lato',
	size = ScrH() / 50,
	weight = 300,
})

surface.CreateFont("ttt_scoreboard_header", {
	font = 'Lato',
	size = ScrH() / 20,
	weight = 200
})

surface.CreateFont("ttt_scoreboard_group", {
	font = 'Lato',
	size = ScrH() / 50,
	weight = 200
})

local Padding = math.Round(ScrH() * 0.015)

local PANEL = {}

function PANEL:Init()
	self.Logo = self:Add("DLabel")
	self.Logo:SetFont("ttt_scoreboard_header")
	
	self:DockPadding(Padding, Padding, Padding, Padding)
end

function PANEL:PerformLayout(w, h)
	if (IsValid(self.Mesh)) then
		self.Mesh:Remove()
		self.Mesh = nil
	end

	self.Logo:SetText("TTT ReWritten")
	self.Logo:SizeToContents()
	self.Logo:SetPos(self:GetWide() / 2 - self.Logo:GetWide() / 2, (self:GetTall() - self.Logo:GetTall())/2)
	self:SetTall(100)
	
	self.Mesh = hud.BuildCurvedMesh(4, 0, 0, w, h)
end

function PANEL:Paint(w, h)
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(ttt_scoreboard_header)
		render.DrawScreenQuad()
	hud.EndStenciledMesh()
end

vgui.Register("ttt_scoreboard_header", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.Mat = ttt_scoreboard_player_innocent

	self:DockMargin(Padding * 2, 0, Padding * 2, 4)
	self:DockPadding(4, 4, 4, 4)
	self:Dock(TOP)
	self:SetTall(40)

	self.Avatar = self:Add("AvatarImage")
	self.Avatar:SetWide(32)
	self.Avatar:Dock(LEFT)

	self.Name = self:Add("DLabel")
	self.Name:SetFont("ttt_scoreboard_player")
	self.Name:DockMargin(10, 0, 0, 0)
	self.Name:SetText("Name")
	self.Name:SizeToContents()
	self.Name:Dock(LEFT)

	self.Ping = self:Add("DLabel")
	self.Ping:SetFont("ttt_scoreboard_player")
	self.Ping:DockMargin(0, 0, 10, 0)
	self.Ping:SetText("Ping")
	self.Ping:SizeToContents()
	self.Ping:Dock(RIGHT)

	self.Karma = self:Add("DLabel")
	self.Karma:SetFont("ttt_scoreboard_player")
	self.Karma:DockMargin(0, 0, Padding * 10, 0)
	self.Karma:SetText("Karma")
	self.Karma:SizeToContents()
	self.Karma:Dock(RIGHT)
end

function PANEL:PerformLayout(w, h)
	if (IsValid(self.Mesh)) then
		self.Mesh:Remove()
		self.Mesh = nil
	end

	self.Mesh = hud.BuildCurvedMesh(4, 0, 0, w, h)
end

function PANEL:Paint(w, h)
	if (IsValid(self.Player)) then
		self.Mat = ttt_scoreboard_player_innocent
		if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_PREPARING and self.Player:GetRole() ~= "Spectator"
			and IsValid(self.Player.HiddenState) and not self.Player.HiddenState:IsDormant()) then
				if (self.Player:GetRole() == "Detective") then
					self.Mat = ttt_scoreboard_player_detective
				elseif (self.Player:GetRole() == "Traitor") then
					self.Mat = ttt_scoreboard_player_traitor
				end
		end
		self.Ping:SetText(self.Player:Ping().."ms")
		self.Ping:SizeToContents()
		self.Ping:Dock(RIGHT)
	end
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(self.Mat)
		render.DrawScreenQuad()
	hud.EndStenciledMesh()
end

function PANEL:SetPlayer(ply)
	if not IsValid(ply) then return end
	self.Player = ply
	self.Avatar:SetPlayer(ply)

	self.Name:SetText(ply:Nick())
	self.Name:SizeToContents()
	self.Name:Dock(LEFT)

	self.Karma:SetText("1000")
	self.Karma:SizeToContents()
	self.Karma:Dock(RIGHT)
end

vgui.Register("ttt_scoreboard_player", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.Plys = {}
	self.Text = self:Add("DLabel")
	self.Text:SetFont("ttt_scoreboard_group")
	self:Dock(TOP)
	self:DockMargin(Padding, Padding/2, Padding, Padding/2)
end

function PANEL:PerformLayout(w, h)
	if (IsValid(self.Mesh)) then
		self.Mesh:Remove()
		self.Mesh = nil
	end

	self.Mesh = hud.BuildCurvedMesh(4, 0, 0, w, h)
end

function PANEL:Paint(w, h)
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(self.Mat)
		render.DrawScreenQuad()
	hud.EndStenciledMesh()
end

function PANEL:SetColor(col)
	self.Mat = CreateMaterial("ttt_scoreboard_group" .. math.random(0, 0x8000), "UnlitGeneric", {
		["$basetexture"] = "color/white",
		["$color"] = string.format("{ %i %i %i }", col.r, col.g, col.b),
		["$alpha"] = 0.8
	})
end

function PANEL:SetText(txt)
	self.Text:SetText(txt)
	self.Text:SizeToContents()
	self:SetTall(self.Text:GetTall()+1)
	self:DockPadding(20, 0, 0, 2)
	self.Text:Dock(LEFT)
end

function PANEL:SetPlayers(plys)
	if (table.Count(plys) <= 0) then return end
	for k,v in pairs(plys) do
		if (v:IsValid() and v:IsPlayer()) then
			local i = table.insert(self.Plys, self:GetParent():Add("ttt_scoreboard_player"))
			self.Plys[i]:SetPlayer(v)
		end
	end
end

vgui.Register("ttt_scoreboard_group", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self:SetWide(ScrW()-ScrW()/3)
	self:SetTall(1000)

	self.Contents = {}

	self.Header = self:Add("ttt_scoreboard_header")
	self.Header:Dock(TOP)

	self.Guide = self:Add("ttt_scoreboard_player")
	self.Guide.Mat = ttt_scoreboard_header
	self.Guide:DockMargin(Padding * 2, 10, Padding * 2, Padding/4)
	self.Guide.Karma:DockMargin(0, 0, Padding * 10 - 11, 0)
	self.Guide.Name:DockMargin(42, 0, 0, 0)
	self.Guide.Avatar:Remove()

	if ((LocalPlayer():GetTeam() == "traitor" and ttt.GetRoundState() ~= ttt.ROUNDSTATE_PREPARING) or ttt.GetRoundState() == ttt.ROUNDSTATE_ENDED) then
		self:AddGroup("Living", Color(50, 200, 100), function()
			local t = {}
			for k,v in pairs(player.GetAll()) do
				if (v:Alive()) then
					table.insert(t, v)
				end
			end
			return t
		end)
		self:AddGroup("Unidentified Bodies", Color(150, 50, 50), function() 
			return {}
		end)
	else
		self:AddGroup("Living", Color(50, 200, 100), function()
			local t = {}
			for k,v in pairs(player.GetAll()) do
				if (v:Alive()) then
					table.insert(t, v)
				end
			end
			return t
		end)
	end
	self:AddGroup("Dead", Color(200, 50, 50), function() 
		local t = {}
		for k,v in pairs(player.GetAll()) do
			if (not v:Alive()) then
				table.insert(t, v)
			end
		end
		return t
	end)
	self:InvalidateLayout()
	--self:SizeToChildren(false, true)
	self:SetPos((ScrW()-self:GetWide())/2,(ScrH()-self:GetTall())/2)
end

function PANEL:PerformLayout(w, h)
    if (IsValid(self.Mesh)) then
        self.Mesh:Remove()
        self.Mesh = nil
    end

    self.Mesh = hud.BuildCurvedMesh(4, 0, 0, w, h)
end

function PANEL:Paint(w, h)
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(bg_color)
		render.DrawScreenQuad()
	hud.EndStenciledMesh()
end

function PANEL:AddGroup(name, color, plys)
	local i = table.insert(self.Contents, self:Add("ttt_scoreboard_group"))
	self.Contents[i]:SetColor(color)
	self.Contents[i]:SetText(name)
	self.Contents[i]:SetPlayers(plys())
	self.Contents[i]:Dock(TOP)
end

vgui.Register("ttt_scoreboard", PANEL, "EditablePanel")