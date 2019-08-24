
ttt.Notifications = ttt.Notifications or {}


if (SERVER) then
	util.AddNetworkString("ttt.Notifications")
	
	
	function PLAYER:Notify(msg)
		net.Start("ttt.Notifications")
			net.WriteString(msg)
		net.Send(self)
	end
else

	local textheight = math.Round(ScrH() / 80)
	surface.CreateFont("ttt_notifications", {
		font = 'Lato',
		size = textheight,
		weight = 200,
	})

	ttt.Notifications.NotificationList =  {}

	net.Receive("ttt.Notifications", function()
		ttt.Notifications.Add(net.ReadString())
	end)

	local lifetime = 8
	function ttt.Notifications.Add(msg)
		local notif = {}
		notif.msg = msg
		notif.birth = SysTime()
		notif.lifetime = lifetime
		notif.death = SysTime() + lifetime
		
		table.insert(ttt.Notifications.NotificationList, notif)
	end

	local bg_default = Color(0x0B, 0x0C, 0x0B, 0xE0)
	hook.Add("HUDPaint", "ttt.Notifications.HUDPaint", function()
		local w, h = textheight * 25, textheight * 1.5
		local pad = h + 10
		local x = ScrW() * 0.98 - w

		local to_remove = {}

		for i = #ttt.Notifications.NotificationList, 1, -1 do
			local notif = ttt.Notifications.NotificationList[i]

			if (notif.death <= SysTime()) then
				table.insert(to_remove, i)
			end
		end

		for k, notif in pairs(ttt.Notifications.NotificationList) do
			local y = ScrH() * 0.01 + pad * k


			local frac = (SysTime() - notif.birth) / notif.lifetime
			local alpha = 1
			if (frac > 0.75) then
				alpha = 1 - (frac - 0.75) * 4
			end
			alpha = Lerp(alpha, 0, 0xE0)
			local col = ColorAlpha(bg_default, alpha)

			draw.RoundedBox(4, x, y, w, h, col)
		
			draw.SimpleText(notif.msg, "ttt_notifications", x + w / 2, y + h / 2 - 1, Color(0xFE, 0xFE, 0xFE, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		for _, idx in pairs(to_remove) do
			table.remove(ttt.Notifications.NotificationList, idx)
		end
	end)
	
end
