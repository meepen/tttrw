
ttt.Notifications = ttt.Notifications or {}


if (SERVER) then
	util.AddNetworkString("ttt.Notifications")
	
	
	function PLAYER:Notify(msg)
		net.Start("ttt.Notifications")
			net.WriteString(msg)
		net.Send(self)
	end
else
	surface.CreateFont("ttt_notifications", {
		font = 'Lato',
		size = ScrH() / 40,
		weight = 200,
	})

	ttt.Notifications.NotificationList =  {}

	net.Receive("ttt.Notifications", function()
		ttt.Notifications.Add(net.ReadString())
	end)

	local lifetime = 3
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
		local w, h = ScrW() * 0.275, 30
		local pad = h + 10
		local x = ScrW() * 0.98 - w
		
		local to_remove = {}
	
		for k, notif in pairs(ttt.Notifications.NotificationList) do
			print(notif.birth, notif.death, SysTime(), SysTime() - notif.birth, notif.death - SysTime(), (SysTime() - notif.birth)/(notif.death - SysTime()))
			local y = ScrH() * 0.01 + pad * k
			
			if (notif.death <= SysTime()) then
				table.insert(to_remove, k)
				continue
			end
			
			local col = bg_default
			if (notif.death < SysTime() + notif.lifetime / 3) then
				col = Color(0x0B, 0x0C, 0x0B, Lerp((SysTime() + 10) / notif.death, 0xE0, 0))
			end
			
			
			
			
			draw.RoundedBox(4, x, y, w, h, col)
		
			draw.SimpleText(notif.msg, "ttt_notifications", x + w/2, y + h/2 - 1, Color(0xFE, 0xFE, 0xFE), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		
		for _, idx in pairs(to_remove) do
			table.remove(ttt.Notifications.NotificationList, idx)
		end
	end)
	
end
