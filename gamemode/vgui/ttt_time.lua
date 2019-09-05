
local PANEL = {}
local status_color = Color(154, 153, 153)

function PANEL:Init()
	self:AddFunction("ttt", "ready", function()
		self.Ready = true
		self:UpdateState()
	end)
	
	self:SetHTML [[
<head>
	<link href='http://fonts.googleapis.com/css?family=Lato:400,700' rel='stylesheet' type='text/css'>
	<style>
		* {
			margin: 0;
			padding: 0;
			-webkit-font-smoothing: antialiased;
			-moz-osx-font-smoothing: grayscale;
		}
		body {
			overflow:hidden;
		}
		svg {
			position: absolute;
		}
		.tttrw_text {
			font-size: 145%;
			font-family: 'Lato', sans-serif;
			font-weight: bold;
			text-align: center;
			text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
			filter: drop-shadow(1px 1px 1px rgba(0, 0, 0, .7));
		}
		.barRect {
			stroke-width: 2px;
			stroke-opacity: 1;
		}
		.shadow {
			-webkit-filter: drop-shadow(1px 1px 1px rgba(0, 0, 0, .7));
			filter: drop-shadow(1px 1px 1px rgba(0, 0, 0, .7));
		}
	</style>
</head>
<body onload="ttt.ready()">
	<div>
		<svg id="resizeSVG" class="shadow" viewBox="0 0 100 100" preserveAspectRatio="none">
			<rect id="outlineRect" class="barRect" width="98" height="98" x="1" y="1" rx="3" ry="3" style="fill:black; stroke:#F7F7F7; fill-opacity:0.4" />
			<rect id="fillRect" class="barRect" width="94" height="94" x="3" y="3" rx="1" ry="1" style="fill:#c91d1d; stroke:#c91d1d; fill-opacity:1"/>
		</svg>
		
		<svg >
			<text class="tttrw_text" id="roleText" x="30%" y="21" dominant-baseline="middle" fill="#F7F7F7" text-anchor="middle" />
			<text class="tttrw_text" id="timeText" x="70%" y="21" dominant-baseline="middle" fill="#F7F7F7" text-anchor="middle" />
		</svg>
	</div>
	
	<script>
		var text = document.querySelector("#roleText");
		var time = document.querySelector("#timeText");

		var svg = document.querySelector("#resizeSVG");
		var outlineRect = document.querySelector("#outlineRect");
		var fillRect = document.querySelector("#fillRect");
		
		var width = fillRect.getAttributeNS(null, "width");

		function resize() {
			var w = window.innerWidth, h = window.innerHeight;
			svg.setAttributeNS(null, "viewBox", "0 0 " + w + " " + h);
			svg.style.width = w - 2;
			svg.style.height = h - 2;
			outlineRect.setAttributeNS(null, "width", w - 2);
			outlineRect.setAttributeNS(null, "height", h - 2);
			width = w - 6;
			fillRect.setAttributeNS(null, "width", width);
			fillRect.setAttributeNS(null, "height", h - 6);
			var list = document.querySelectorAll("text");
			for (var i = 0; i < list.length; i++) {
				list[i].setAttributeNS(null, "y", h / 2 + 1);
			}
		}

		resize();
		window.onresize = resize;
		
		function setState(_state, _color)
		{
			text.textContent = _state;
			fillRect.style.fill = _color;
			fillRect.style.stroke = _color;
		}

		function setTime(_time, _pct)
		{
			time.textContent = _time;
			fillRect.setAttributeNS(null, "width", width * _pct);
		}
	</script>
</body>
]]
	
	self.StartTime = 0
	hook.Add("OnRoundStateChange", self, self.OnRoundStateChange)
	hook.Add("OnPlayerRoleChange", self, self.OnPlayerRoleChange)
end

function PANEL:OnRemove()
	timer.Destroy("ttt_DHTML_Time_Timer")
end

function PANEL:UpdateState()
	local color, text = status_color
	local state = self.State or ttt and ttt.GetRoundState and ttt.GetRoundState()
	if (not IsValid(LocalPlayer()) or not LocalPlayer().GetRole) then
		return
	end
	if (state == ttt.ROUNDSTATE_ACTIVE and self:GetTarget() == LocalPlayer()) then
		local data = ttt.roles[self.Role or LocalPlayer():GetRole()]
		text = data.Name

		color = data.Color
	else
		text = ttt.Enums.RoundState[state]
	end

	self:CallSafe([[setState("%s", "rgb(%d, %d, %d)");]], text, color.r, color.g, color.b)
end

function PANEL:OnRoundStateChange(old, new)
	self.State = new
	self:UpdateState()
end

function PANEL:OnPlayerRoleChange(ply, old, new)
	if (ply ~= LocalPlayer()) then
		return
	end
	self.Role = new
	self:UpdateState()
end

function PANEL:PerformLayout()
	local w = ScrW() * .2
	self:SetSize(w, ScrH() * 0.04)
	self:SetPos(ScrW() / 2 - w / 2, ScrH() * 0.03)
	
	timer.Create("ttt_DHTML_Time_Timer", 0.5, 0, function() self:Tick() end)
end

function PANEL:Tick()
	if (not self.Ready) then return end

	local ends = (LocalPlayer():GetRoleData().Evil and ttt.GetRealRoundEndTime or ttt.GetVisibleRoundEndTime)()
	local starts = ttt.GetRoundStateChangeTime()
	
	local pct = 1
	local other_text = string.FormattedTime(math.max(0, ends - CurTime()), "%i:%02i")
	if (ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE) then
		pct = math.Clamp(1 - ((CurTime() - starts) / (ends - starts)), 0, 1)
	end

	self:CallSafe([[setTime("%s", %f);]], other_text, pct)
end

vgui.Register("ttt_time", PANEL, "ttt_html_base")
