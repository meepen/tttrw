util.AddNetworkString("BugReportSubmit")
util.AddNetworkString("BugReportResponse")

local webhook = CreateConVar("tttrw_bug_report_endpoint", "", {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "The URL Bug/Suggestion Requests are sent to.")
local auth = CreateConVar("tttrw_bug_report_auth", "", {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "The authentication sent with the Bug/Suggestion Request.")

net.Receive("BugReportSubmit", function(len, ply)
	if (IsValid(ply)) then
		if ((ply.NextBugReport or math.huge) < CurTime()) then
			net.Start("BugReportResponse")
				net.WriteString("too fast")
			net.Send(ply)
			return
		end

		ply.NextBugReport = CurTime() + 30

		local type = net.ReadBool()
		local title = net.ReadString()
		local msg = net.ReadString()

		local request = {
			success = function(c,response,h)
				print("[Bug Report] Success:")
				print(response)
				net.Start("BugReportResponse")
<<<<<<< HEAD
=======
					net.WriteString("success")
>>>>>>> limiter
				net.Send(ply)
			end,
			failed = function(response)
				if (response == "unsuccessful") then
					net.Start("BugReportResponse")
						net.WriteBool("success")
					net.Send(ply)
					return
				end

				print("[Bug Report] Failed:")
				print(ply, response)
				net.Start("BugReportResponse")
<<<<<<< HEAD
=======
					net.WriteString(response)
>>>>>>> limiter
				net.Send(ply)
			end,
			url = webhook:GetString(),
			method = "POST",
			parameters = {
				data = util.TableToJSON {
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
								},
								{
									name = "Server IP",
									value = game.GetIPAddress(),
								},
								{
									name = "Client Data",
									value = string.format("Resolution: %ix%i, OS: %s, Version: %s/%s", net.ReadUInt(32), net.ReadUInt(32), net.ReadString(), net.ReadString(), net.ReadString())
								},
								{
									name = "Commit",
									value = gmod.GetGamemode().InitialCommit or "n/a"
								}
							},
						}
					}
				}
			},
			headers = {
				["Content-Type"] = "application/json",
				Authentication = auth:GetString(),
			},
		}
		HTTP(request)
	end
end)