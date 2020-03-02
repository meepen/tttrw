
if CLIENT then
	-- Is screenpos on screen?
	function IsOffScreen(scrpos)
		return not scrpos.visible or scrpos.x < 0 or scrpos.y < 0 or scrpos.x > ScrW() or scrpos.y > ScrH()
	end
end


function util.PaintDown(start, effname, ignore)
	local btr = util.TraceLine({start=start, endpos=(start + Vector(0,0,-256)), filter=ignore, mask=MASK_SOLID})

	util.Decal(effname, btr.HitPos+btr.HitNormal, btr.HitPos-btr.HitNormal)
end



if (CLIENT) then
	concommand.Add("extract_file", function(_, _, _, s)
		file.Write(s:gsub("/", "_") .. ".dat", file.Read(s, "GAME"))
		print(util.RelativePathToFull("data/" .. s:gsub("/", "_") .. ".dat"))
	end)
end