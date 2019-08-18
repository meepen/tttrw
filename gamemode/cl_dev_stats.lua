local Count, Avg
local DevStatsOn = false

concommand.Add("tttrw_hud_stats", function()
    DevStatsOn = not DevStatsOn
    if (DevStatsOn) then
        local curtime = SysTime()
        Count, Avg = 0, 0
        hook.Add("PreDrawHUD", "cl_dev_stats", function()
            if (gui.IsGameUIVisible()) then
                return
            end
            curtime = SysTime()
        end)
        hook.Add("PostDrawHUD", "cl_dev_stats", function()
            if (gui.IsGameUIVisible()) then
                return
            end
            Count = Count + 1
            Avg = Avg * ((Count - 1) / (Count)) + (SysTime() - curtime) / Count
        end)
    else
        printf("Samples: %i\nAverage: %.02fms\n", Count, Avg * 1000)
        hook.Remove("PreDrawHUD", "cl_dev_stats")
        hook.Remove("PostDrawHUD", "cl_dev_stats")
    end
end)