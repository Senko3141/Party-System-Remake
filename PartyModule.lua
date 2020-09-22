-- Party Core

local m = {};
m.__index = m  

local rankNames = {
	['Top Executive/Captain'] = true,
	['Top Executive/Vice Captain'] = true,
	['Top Executive'] = true,
	['Executive'] = true,
	['None'] = true,
};

local Cooldowns = {};

--[[
	Rank Orders
	
	God
	Top Executive/Captain
	Top Executive/Vice-Captain
	Top Executive
	Executive
	None -- lowest rank

]]--

function m.Init(plr) -- create party
	if Cooldowns[plr.UserId] then
		-- notify
		warn("Wait 5 seconds before you can create another party")
		return
	end
	
	local self = setmetatable(
		{
			Owner = plr.Name,
			
			Members  = {},
			PendingInvites = {},
			--[[
				Members = {
					['PlayerName'] = 'RankName', -- Ex. Captain, Executive, etc.
				}
			]]
			
		}
		, m)
	
	warn("Successfully created ".. self.Owner.."'s party")
	
	return self 
end

function m:Disband()
	-- are you sure you want to disband | Notify
	-- notify all MEMBERS that party has been disbanded
	
	warn("Successfully disbanded ".. self.Owner.. "'s party")
	
	local Player = game.Players[self.Owner]
	
	if Player then
		coroutine.resume(coroutine.create(function()
			Cooldowns[Player.UserId] = true
			wait(5)
			Cooldowns[Player.UserId] = nil
		end))
	end
	
	self = nil
end

function m:Invite(target) -- invite people
	if target.Name == self.Owner then
		-- send notif, "You can not invite yourself to your own party."
		return
	end
	
	if self.Members[target.Name] then
		-- send notif, "You can not invite yourself to a party."
		return
	end
	
	if not self.PendingInvites[target.Name] then
		local PendingInvites = self.PendingInvites
		
		PendingInvites[target.Name] = {
			TillExpire = 20,
			HasAccepted = false,
		};
		
		-- fire the client for sending invite :FireClient(target, ...)
		
		coroutine.resume(coroutine.create(function()
			local TillExpire = PendingInvites[target.Name].TillExpire
			local HasAccepted = PendingInvites[target.Name].HasAccepted
			
			warn("20 seconds until ".. target.Name.. " 's party invitation will expire")
			
			for i = TillExpire,0,-1 do
				if HasAccepted == true then
					PendingInvites[target.Name] = nil
					self.Members[target.Name] = 'None'
					warn(target.Name.. ' has accepted your party request. Current Rank: '.. self.Members[target.Name])
					-- fire client for both players :FireClient(players, ...)
					break
				end
				
				TillExpire = TillExpire - 1
				wait(1)
			end
			-- expired
			PendingInvites[target.Name] = nil
			warn("Party invite for ".. target.Name.. ' has expired')
			
			-- fire client for player who sent invite :FireClient(plr, ...)
		end))
		
	else
		-- send notif, "You are currently inviting this player."
	end
end

function m:Kick(target)
	local Members = self.Members
	
	if Members[target.Name] then 
		-- are you sure you want to kick <target.Name> | Notify
		Members[target.Name] = nil
		-- notify <target.Name> that he has been kicked out
	end
end

-- promoting commands

function m:Promote(target, ...)
	local Member = self.Members[target.Name]
	
	local rankName = ...
	if rankNames[rankName] then
		-- promote player
		
		Member = rankName
		warn("Successfully promoted/demoted ".. target.Name.. ' to '.. rankName)
	end
	
end

return m 
