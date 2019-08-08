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

function hud.DrawTextOutlined(text, textcol, shadowcol, posx, posy, shadowsize)
	surface.SetTextColor(shadowcol)

	--render.PushFilterMin(TEXFILTER.NONE)
	--render.PushFilterMag(TEXFILTER.NONE)
	for x = -shadowsize, -1 do
		for y = -shadowsize, -1 do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end

	for x = 1, shadowsize do
		for y = -shadowsize, -1 do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end

	for x = -shadowsize, -1 do
		for y = 1, shadowsize do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end

	for x = 1, shadowsize do
		for y = 1, shadowsize do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end
	--render.PopFilterMag()
	--render.PopFilterMin()

	surface.SetTextColor(textcol)
	surface.SetTextPos(posx, posy)
	surface.DrawText(text)
end