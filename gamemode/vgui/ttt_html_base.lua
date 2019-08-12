local PANEL = {}

local BaseClass = FindMetaTable "Panel"

function PANEL:GetTarget()
	return ttt.GetHUDTarget()
end

function PANEL:CallSafe(s, ...)
	local args = {...}
	for i = 1, #args do
		args[i] = string.JavascriptSafe(tostring(args[i]))
	end
	
	self:Call(string.format(s, unpack(args)))
end

vgui.Register("ttt_html_base", PANEL, "DHTML")