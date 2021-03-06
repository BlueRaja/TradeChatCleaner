--[[--------------------------------------------------------------------
	Trade Chat Cleaner
	Removes spam and irrelevant chatter from Trade chat.
	Copyright (c) 2013-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info23178-TradeChatCleaner.html
	http://www.curse.com/addons/wow/tradechatcleaner
	https://github.com/Phanx/TradeChatCleaner
----------------------------------------------------------------------]]

local _, L = ...

ChatCleanerWhitelist = {
	"|h", -- links
	"^wt[bst]",
	"^lf[gm%d%s]",
	"dps",
	"ffa",
	"flex",
	"free ?roll",
	"kaufe", -- de
	"gall?e?o?n?",
	"he[ai]l",
	"heroic",
	"mog run",
	"nala?k?",
	"oond?a?s?t?a?",
	"reserve",
	"s[cz]ena?r?i?o?", -- en/de
	"transmog",
	"%f[%a]vk%f[%A]", -- de
	"%f[%a]sha%f[%A]",
	"tank",
}

ChatCleanerBlacklist = {
	-- real spam
	"%.c0m%f[%L]",
	"%d%s?eur%f[%L]",
	"%d%s?usd%f[%L]",
	"account",
	"boost",
	"diablo",
	"elite gear",
	"game ?time",
	"g0ld",
	"name change",
	"paypal",
	"qq",
	"ranking",
	"realm",
	"server",
	"share",
	"s%A*k%A*y%A*p%Ae", -- spammers love to obfuscate "skype"
	"transfer",
	"wow gold",
	-- pvp
	"%f[%d][235]s%f[%L]", -- 2s, 3s, 5s
	"[235]v[235]",
	"%f[%a]arena", -- arenacap, arenamate, arenapoints
	"%f[%l]carry%f[%L]",
	"conqu?e?s?t? cap",
	"conqu?e?s?t? points",
	"for %ds",
	"lf %ds",
	"low mmr",
	"points cap",
	"punktecap", -- DE
	"pusc?h", -- DE
	"rbg",
	"season",
	"weekly cap",
	-- junk
	"a?m[eu]rican?", -- america, american, murica
	"an[au][ls]e?r?%f[%L]", -- anal, anus, -e/er/es/en
	"argument",
	-- "aus[st]?[ir]?[ea]?l?i?a?n?%f[%L]", -- aus, aussie, australia, australian -- "aus" is problematic in DE
	"bacon",
	"bewbs",
	"boobs",
	"chuck ?norris",
	"girl",
	"kiss",
	"mad ?bro",
	"nigg[ae]r?",
	"obama",
	"pussy",
	"sexy?",
	"shut ?up",
	"tits",
	"twitch%.tv",
	"webcam",
	"wts.+guild",
	"xbox",
	"youtu%.?be",
}

WhitelistAllNumberedChannels = true

local TRADE = L.Trade
local reqLatin = not strmatch(GetLocale(), "^[rkz][uoh]")

local strfind, strlower, type = string.find, string.lower, type

local prevID, result
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(_, _, message, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, ...)
	if lineID == prevID then
		return result
	end
	prevID, result = lineID, nil

	--Support for the TradeForwarder plugin
	if strfind(channelName, "TCForwarder") then
		--TradeForwarder "commands" begin with "^LFW" and should be ignored
		if strfind(message, "^LFW") then
			return
		end
	-- Don't filter custom channels
	elseif channelID == 0 or type(channelID) ~= "number" then
		return
	end

	local search = strlower(message)

	-- Hide ASCII crap.
	if reqLatin and not strfind(search, "[a-z]") then
		-- print("No letters.")
		result = true
		return true
	end

	local blacklist = ChatCleanerBlacklist
	for i = 1, #blacklist do
		if strfind(search, blacklist[i]) then
			-- print("Blacklisted.")
			result = true
			return true
		end
	end
	
	-- Don't apply the whitelist to non-Trade channels if WhitelistAllNumberedChannels is false
	if not WhitelistAllNumberedChannels and not strfind(channelName, TRADE) then
		return
	end
	
	-- Check for whitelisted words
	local hasWhitelistedWord = false
	local whitelist = ChatCleanerWhitelist
	for i = 1, #whitelist do
		if strfind(search, whitelist[i]) then
			-- print("Whitelisted:", whitelist[i])
			hasWhitelistedWord = true
		end
	end
	
	-- If the whitelist is empty, treat everything as whitelisted
	if hasWhitelistedWord or #whitelist == 0 then
		-- Remove extra spaces
		message = strtrim(gsub(message, "%s%s+", " "))
		return false, message, sender, arg3, arg4, arg5, flag, channelID, arg8, channelName, arg10, lineID, ...
	end

	-- print("Other.")
	result = true
	return true
end)
