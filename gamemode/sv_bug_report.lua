util.AddNetworkString("BugReportSubmit")
util.AddNetworkString("BugReportResponse")

local webhook = CreateConVar("tttrw_bug_report_endpoint", "", {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "The URL Bug/Suggestion Requests are sent to.")
local auth = CreateConVar("tttrw_bug_report_auth", "", {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "The authentication sent with the Bug/Suggestion Request.")

net.Receive("BugReportSubmit", function(len, ply)
	if (IsValid(ply)) then
		local type = net.ReadBool()
		local title = net.ReadString()
		local msg = net.ReadString()
		local json = util.TableToJSON({
			embeds = {
				{
					color = !type and 16711680 or 65280,
					timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000", os.time()),
					author = {
						name = "Submitted By: "..ply:Nick(),
						url = "https://steamcommunity.com/profiles/"..ply:SteamID64(),
					},
					title = "**"..title.."**",
					fields = {
						{
							name = "Details",
							value = msg,
						}
					},
				}
			}
		})
		local request = {
			success = function(c,response,h)
				print("[Bug Report] Success:")
				print(response)
				net.Start("BugReportResponse")
					net.WriteBool(true)
				net.Send(ply)
			end,
			failed = function(response)
				print("[Bug Report] Failed:")
				print(response)
				net.Start("BugReportResponse")
					net.WriteBool(false)
				net.Send(ply)
			end,
			url = webhook,
			method = "POST",
			body = json,
			headers = {
				Authentication = "Basic "..auth:GetString(),
			},
		}
		HTTP(request)
	end
end)