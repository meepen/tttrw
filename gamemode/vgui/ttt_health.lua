
local PANEL = {}

function PANEL:Init()
	self:SetHTML [[
<!-- HEALTH -->
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
		img {
			padding: 0 13;
		}
		div {
			display: inline;
		}
		.tttrw_text {
			font-size: 145%;
			font-family: 'Lato', sans-serif;
			font-weight: bold;
			text-align: center;
			text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
			filter: drop-shadow(1px 1px 1px rgba(0, 0, 0, .7));
			letter-spacing: 0.085em;
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
<body>
	<img src="asset://garrysmod/materials/tttrw/heart.png" height="100%">
	<div>
		<svg class="shadow" id="resizeSVG" viewBox="0 0 100 100" preserveAspectRatio="none">
			<rect id="outlineRect" class="barRect" x="1" y="1" rx="3" ry="3" width="98" height="98"
				style="fill:black; stroke:#F7F7F7; fill-opacity:0.4" />
			<rect id="fillRect" class="barRect" x="3" y="3" rx="1" ry="1" width="94" height="94"
				style="fill:#39ac56; stroke:#39ac56; fill-opacity:1"/> 
			<text class="tttrw_text" id="healthText" x="50%" y="26" dominant-baseline="middle" fill="#F7F7F7" text-anchor="middle"></text>
		</svg>
	</div>

	<script>
		var text = document.querySelector("#healthText");
		
		var svg = document.querySelector("#resizeSVG");
		var outlineRect = svg.querySelector("#outlineRect");
		var fillRect = svg.querySelector("#fillRect");
		var div = document.querySelector("div");
		var img = document.querySelector("img");

		var hp = 100;
		var maxhp = 100;
		var pct = hp / maxhp;
		
		var width = fillRect.getAttributeNS(null, "width");
		
		function resize() {
			var w = window.innerWidth - img.clientWidth, h = window.innerHeight;
			if (w <= 0 || h <= 0) {	// Hacky fix
				return;
			}

			svg.setAttributeNS(null, "viewBox", "0 0 " + w + " " + h);
			svg.style.width = w - 2;
			svg.style.height = h - 2;
			outlineRect.setAttributeNS(null, "width", w - 2);
			outlineRect.setAttributeNS(null, "height", h - 2);
			width = w - 6;
			fillRect.setAttributeNS(null, "width", width);
			fillRect.setAttributeNS(null, "height", h - 6);
			text.setAttributeNS(null, "y", h / 2 + 1);
		}

		img.onload = resize;
		resize();
		window.onresize = resize;
		
		
		function changeBar()
		{
			pct = hp / maxhp;
			fillRect.setAttributeNS(null, "width", width * pct)
		}
		
		function setHealth(_hp)
		{
			hp = _hp;
			text.textContent = _hp + "/" + maxhp;
			changeBar();
		}
		
		function setMaxHealth(_maxhp)
		{
			maxhp = _maxhp;
			text.textContent = hp + "/" + _maxhp;
			changeBar();
		}
		
		function setText(_hp, _maxhp)
		{
			hp = _hp;
			maxhp = _maxhp;
			text.textContent = _hp + "/" + _maxhp;
			changeBar();
		}
	</script>
</body>
]]
	
	self.OldHealth = 0
	self.OldMaxHealth = 0
end

function PANEL:PerformLayout()
	self:SetPos(ScrW() * 0.04375, ScrH() * 0.8722)
	self:SetSize(ScrW() * 0.3, ScrH() * 0.045)

	local health = math.max(self:GetTarget():Health(), 0)
	
	self.OldHealth = health
	self.OldMaxHealth = self:GetTarget():GetMaxHealth()
	
	self:CallSafe([[setText(%d, %d);]], health, self.OldMaxHealth)
end

function PANEL:Paint()
	local hp = math.max(self:GetTarget():Health(), 0)
	if (self.OldHealth ~= hp) then
		self:CallSafe([[setHealth(%d);]], hp)
		self.OldHealth = hp
	end
	
	local maxhp = math.max(self:GetTarget():GetMaxHealth(), 1)
	if (self.OldMaxHealth ~= maxhp) then
		self:CallSafe([[setMaxHealth(%d);]], maxhp)
		self.OldMaxHealth = maxhp
	end
end

vgui.Register("ttt_health", PANEL, "ttt_html_base")