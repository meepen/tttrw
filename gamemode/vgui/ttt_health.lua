
local PANEL = {}

function PANEL:Init()
	self:SetHTML [[
		<head>
			<style>
				* {
				  -webkit-font-smoothing: antialiased;
				  -moz-osx-font-smoothing: grayscale;
				}

				svg {
					position: absolute;
					z-index: -1
				}
				.hp {
					font-size: 23px;
					font-family: 'Lato', sans-serif;
					font-weight: bold;
					text-align: center;
					text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
				}
				.shadow {
				  -webkit-filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				  filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				}
			</style>
		</head>
		<body>
			<img src="asset://garrysmod/materials/tttrw/heart.png" height="48">
			<svg id="svgBorder" class="shadow" width="390" height="48">
				<rect id="svgRect" x="10" y="5" rx="3" ry="3" width="377" height="36"
					style="fill:black; stroke:#F7F7F7; stroke-width:2; fill-opacity:0.4; stroke-opacity:1" />
			</svg>
			<svg id="svgHealth" width="390" height="48">
				<rect id="svgRect" x="12" y="7" rx="1" ry="1" width="250" height="32"
					style="fill:#39ac56; stroke:#39ac56; stroke-width:2; fill-opacity:1; stroke-opacity:1"/>
				<text id="svgText" class="hp" x="50%" y="26" dominant-baseline="middle" fill="#F7F7F7" text-anchor="middle"></text>
			</svg>
			
			<script>
				var svg = document.getElementById("svgHealth");
				var text = svg.getElementById("svgText");
				var rect = svg.getElementById("svgRect");
				
				var svgBorder = document.getElementById("svgBorder");
				var borderRect = svgBorder.getElementById("svgRect");
				
				var hp = 100;
				var maxhp = 100;
				var pct = hp / maxhp;
				
				
				var maxWidth = borderRect.getAttributeNS(null, "width") - 4;
				var width = maxWidth;
				
				function changeBar()
				{
					pct = hp / maxhp;
					width = maxWidth * pct
					rect.setAttributeNS(null, "width", width)
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
	
	local maxhp = self:GetTarget():GetMaxHealth()
	if (self.OldMaxHealth ~= maxhp) then
		self:CallSafe([[setMaxHealth(%d);]], maxhp)
		self.OldMaxHealth = maxhp
	end
end

vgui.Register("ttt_health", PANEL, "ttt_html_base")