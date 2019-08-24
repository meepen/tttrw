AddCSLuaFile()

ENT.Base = "ttt_point_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Player State"
ENT.Author = "Meepen"
ENT.Contact = "meepdarknessmeep@gmail.com"

function ENT:NetworkVarNotifyCallback(name, old, new)
	local parent = self:GetParent()
	printf("Player(%i) [%s] %s::%s: %s -> %s (seen as %s)", IsValid(parent) and parent:UserID() or -1, IsValid(parent) and parent:Nick() or "NULL", self:GetClass(), name, old, new, self["Get" .. name](self))
	timer.Simple(0, function()
		-- NW2Vars are late??
		if (not IsValid(self)) then
			return
		end
		hook.Run("OnPlayer"..name.."Change", self:GetParent(), old, new)
	end)
end

function ENT:SetupDataTables()
	local vars = {}
	hook.Run("TTTGetHiddenPlayerVariables", vars)

	for _, var in ipairs(vars) do
		-- blocked by issue https://github.com/Facepunch/garrysmod-requests/issues/324
		--[[
		if (not types[var.Type]) then
			types[var.Type] = 0
		end
		]]

		printf("Registering variable %s (type %s)", var.Name, var.Type)
		--self:NetworkVar(var.Type, types[var.Type], var.Name)
		if (SERVER and var.Default) then
			--self["Set"..var.Name](self, var.Default)
			self["SetNW"..var.Type](self, var.Default)
		end

		local nw2getter = "GetNW"..var.Type
		local nw2setter = "SetNW"..var.Type
		self["Get"..var.Name] = function(_)
			return self[nw2getter](self, var.Name, var.Default)
		end
		self["Set"..var.Name] = function(_, value)
			self[nw2setter](self, var.Name, value)
		end

		self:SetNWVarProxy(var.Name, self.NetworkVarNotifyCallback)

		--types[var.Type] = types[var.Type] + 1
	end
end

function ENT:IsVisibleTo(ply)
	local own = self:GetParent()
	if (own == ply) then
		return true
	end

	local roundstate = ttt.GetRoundState()

	if (not own:Alive() and IsValid(own.DeadState)) then
		return own.DeadState:IsVisibleTo(ply)
	end

	if (roundstate == ttt.ROUNDSTATE_ACTIVE) then
		return ttt.CanPlayerSeePlayersRole(ply, own)
	end

	return roundstate ~= ttt.ROUNDSTATE_PREPARING
end

function ENT:OnRoundStateChange(old, new)
	self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
end

function ENT:Initialize()
	BaseClass.Initialize(self)
	if (SERVER) then
		hook.Add("OnRoundStateChange", self, self.OnRoundStateChange)
		self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
	end


	self:GetParent().HiddenState = self
end

hook.Add("Initialize", "InitializeHiddenPlayerVariables", function()
	local vars = {}
	hook.Run("TTTGetHiddenPlayerVariables", vars)

	local PLAYER = FindMetaTable "Player"

	for _, var in ipairs(vars) do
		local set, get = "Set"..var.Name, "Get"..var.Name

		PLAYER[set] = function(self, value)
			self.HiddenState[set](self.HiddenState, value)
		end
		PLAYER[get] = function(self)
			if (not IsValid(self.HiddenState) or self.HiddenState:IsDormant()) then
				return var.Default
			end
			return self.HiddenState[get](self.HiddenState)
		end
	end
end)

hook.Add("TTTAddPermanentEntities", "ttt_hidden_info", function(list)
	table.insert(list, "ttt_hidden_info")
end)