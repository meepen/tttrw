hud = hud or {}

function hud.DrawTextShadowed(text, textcol, shadowcol, posx, posy, shadoww, shadowh)
	surface.SetTextColor(shadowcol)

	for x = 1, shadoww do
		for y = 1, shadowh do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end

	surface.SetTextColor(textcol)
	surface.SetTextPos(posx, posy)
	surface.DrawText(text)
end