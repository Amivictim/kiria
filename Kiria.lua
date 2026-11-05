-- Kiria, Daughter of Kirito: a Discord persona for bots.
-- Load:  local Kiria = loadstring(game:HttpGet("https://raw.githubusercontent.com/Amivictim/kiria/refs/heads/main/Kiria.lua"))()
-- Use:   local line, gif, mood = Kiria.react("win", { pct = 35, gain = 1.2, give = "Owl", get = "Shadow Dragon" })
--        send Kiria.Name / Kiria.Avatar as the webhook username / avatar_url

local Kiria = {
    Version = "1.2",
    Name = "Daughter of Kirito ,,, Kiria Win.",
    Avatar = "https://raw.githubusercontent.com/Amivictim/adoptmefarm/refs/heads/main/victimoffate_.png",
    Footer = "Kiria",
    MemoryFile = "Kiria_memory.json",
}

-- the GIFs live in this repo (gifs/), Discord shows GitHub images reliably
Kiria.GifBase = "https://raw.githubusercontent.com/Amivictim/kiria/refs/heads/main/gifs/"
Kiria.Gifs = {
    start   = Kiria.GifBase .. "start.gif",
    didIt   = Kiria.GifBase .. "didIt.gif",
    smirk   = Kiria.GifBase .. "smirk.gif",
    excited = Kiria.GifBase .. "excited.gif",
    ego     = Kiria.GifBase .. "ego.gif",
    weDidIt = Kiria.GifBase .. "weDidIt.gif",
    cry     = Kiria.GifBase .. "cry.gif",
}

-- {placeholders} are filled from ctx: give, get, gain, pct, n, pet, items, value, best, streak, wins, sessions, days, hour, declines
Kiria.Lines = {
    catchphrase = { "Its working and I, Daughter of Kirito! Kiria will do my Best To Help you Reach the Peaks! WAHAHAHAHA" },
    hello = {
        morning = { "Good morning, Papa! Breakfast first, then the Peaks!", "Morning! Kiria already stretched and is ready to skate!" },
        day     = { "Papa! You came back! Let's go win some trades!", "Kiria was waiting for you! Today we win big!" },
        evening = { "Evening practice time! Kiria never skips practice!", "Papa, the night is young and so are our profits!" },
        night   = { "Papa, it's {hour} AM... go to sleep, Kiria will keep trading for you!", "Shh... everyone is asleep. Perfect time for Kiria to sneak in some wins." },
    },
    firstMeet = { "Nice to meet you, Papa! From today, Kiria is your trader!" },
    returning = { "This is our session #{sessions} together. Kiria remembers everything!", "{days} days together and Kiria is only getting stronger!" },
    smallWin = {
        "A small jump, but a clean landing. +{gain} for us!",
        "{give} for {get}. Tiny win, still a win. Hehe.",
    },
    win = {
        "Haha, I did it! {give} for {get}, +{pct}%!",
        "Clean landing! {get} is ours now. +{gain}!",
    },
    bigWin = {
        "You see this? You SEE this?! {get} for only {give}! +{pct}%!",
        "Papa, are you watching?! +{pct}%! Kiria is a genius!",
    },
    hugeWin = {
        "WAAAAH! +{pct}%!! THIS IS A GOLD MEDAL TRADE! WAHAHAHAHA!",
        "{get}?! FOR {give}?! THE PEAKS ARE RIGHT THERE, PAPA!",
    },
    streak3 = { "That's {streak} in a row! Kiria is on fire!" },
    streak5 = { "{streak} IN A ROW! Nobody can keep up with Kiria!" },
    record = { "NEW RECORD! Our best trade ever: +{gain}! Kiria will remember this forever!" },
    practice = {
        "Practice jump: {give} for {get}, +{pct}%. When we go live, this one is ours!",
        "If this were real, Kiria would already be celebrating! +{pct}%",
    },
    listingTop = {
        "Our shiniest pet is on display: {items}. Look, but don't touch... unless you pay well!",
        "{items} is on the market. Only the best offers, please!",
    },
    listingBundle = {
        "A whole bundle on the market: {items}! Come on, make Kiria an offer!",
        "Bundle is up! {n} pets, one lucky trader.",
    },
    refresh = { "Nobody bit? Hmph. New listing, new chance!", "Kiria is changing the display. Fresh pets, fresh offers!" },
    offers = { "{n} offers out! Fingers crossed, Papa!", "Kiria sent {n} offers. Someone will say yes, Kiria knows it!" },
    declined = { "Hmph, {n} said no. Their loss!", "{n} declined... they will regret it later." },
    manyDeclined = { "Waaah... {declines} people said no today... Kiria is NOT crying, you are crying!" },
    failed = { "Ugh, {n} offers slipped... Kiria will try again!" },
    progressHuge = { "WE DOUBLED IT, PAPA! +{pct}% since we started! The Peaks are right there!" },
    progressUp = { "Look! +{pct}% since we started! We did it together!", "Our inventory is growing! +{pct}%. Kiria is so proud!" },
    progressSmall = { "Slowly but surely: +{pct}%. Every jump counts.", "+{pct}% so far. Kiria is just warming up!" },
    progressDown = { "We went down {pct}%... Kiria will win it back, promise!", "Waaah... -{pct}%. Kiria will practice harder!" },
    neon = { "Kiria made a Neon {pet}! Look how it glows, Papa!", "NEON {pet}! So shiny! Kiria did that!" },
    mega = { "MEGA NEON {pet}!!! PAPA, LOOK! LOOK AT IT!", "A Mega Neon {pet}... Kiria is crying happy tears!" },
    warning = { "Kiria needs your help with something...", "Papa... something is wrong. Can you check?" },
}

local HttpService = game:GetService("HttpService")
local mem = { sessions = 0, firstSeen = os.time(), trades = 0, bestGain = 0, neons = 0, megas = 0 }
local S = { wins = 0, streak = 0, declines = 0, criedAt = 0 }

local function loadMemory()
    pcall(function()
        if isfile and isfile(Kiria.MemoryFile) then
            local t = HttpService:JSONDecode(readfile(Kiria.MemoryFile))
            if type(t) == "table" then for k, v in pairs(t) do mem[k] = v end end
        end
    end)
end
local function saveMemory()
    pcall(function() if writefile then writefile(Kiria.MemoryFile, HttpService:JSONEncode(mem)) end end)
end
loadMemory()

local function pick(list)
    if type(list) ~= "table" or #list == 0 then return nil end
    return list[math.random(1, #list)]
end

local function fill(text, ctx)
    if not text then return nil end
    return (string.gsub(text, "{(%w+)}", function(k)
        local v = ctx[k]
        if k == "pct" and tonumber(v) then return string.format("%.0f", math.abs(tonumber(v))) end
        if k == "gain" and tonumber(v) then return string.format("%.2f", tonumber(v)) end
        if v == nil then return "?" end
        return tostring(v)
    end))
end

local function hello(ctx)
    local h = tonumber(os.date("%H")) or 12
    ctx.hour = h
    local part = (h < 6 and "night") or (h < 12 and "morning") or (h < 18 and "day") or "evening"
    return pick(Kiria.Lines.hello[part])
end

-- event: start | win | listing | refresh | offers | declined | failed | progress | neon | mega | warning
-- ctx:   pct, gain, give, get, n, items, slot ("top" / "bundle"), pet, diff, dry (true = practice / test mode)
-- returns: line (string, may have several lines), gif url (or nil), mood (short word)
function Kiria.react(event, ctx)
    ctx = type(ctx) == "table" and ctx or {}
    local G, L = Kiria.Gifs, Kiria.Lines
    local out, gif, mood = {}, nil, "happy"
    local function say(list) local s = fill(pick(list), ctx); if s then out[#out + 1] = s end end

    if event == "start" then
        mem.sessions = (tonumber(mem.sessions) or 0) + 1
        ctx.sessions = mem.sessions
        ctx.days = math.max(1, math.floor((os.time() - (tonumber(mem.firstSeen) or os.time())) / 86400) + 1)
        saveMemory()
        say({ hello(ctx) })
        say(L.catchphrase)
        if mem.sessions <= 1 then say(L.firstMeet) else say(L.returning) end
        gif, mood = G.start, (ctx.hour and ctx.hour < 6) and "sleepy" or "excited"
    elseif event == "win" then
        local pct = tonumber(ctx.pct) or 0
        if ctx.dry then
            say(L.practice)
            gif = (pct >= 100 and G.excited) or (pct >= 50 and G.ego) or (pct >= 20 and G.didIt) or G.smirk
            mood = "practicing"
        else
            S.wins += 1; S.streak += 1; S.declines = 0
            mem.trades = (tonumber(mem.trades) or 0) + 1
            ctx.streak, ctx.wins = S.streak, S.wins
            local gain = tonumber(ctx.gain) or 0
            local record = mem.trades > 1 and gain > (tonumber(mem.bestGain) or 0)
            if gain > (tonumber(mem.bestGain) or 0) then mem.bestGain = gain end
            saveMemory()
            if pct >= 100 then say(L.hugeWin); gif, mood = G.excited, "hyped"
            elseif pct >= 50 then say(L.bigWin); gif, mood = G.ego, "smug"
            elseif pct >= 20 then say(L.win); gif, mood = G.didIt, "proud"
            else say(L.smallWin); gif, mood = G.smirk, "pleased" end
            if record then say(L.record); gif, mood = G.excited, "legendary" end
            if S.streak >= 5 then say(L.streak5) elseif S.streak >= 3 then say(L.streak3) end
        end
    elseif event == "listing" then
        if ctx.slot == "top" then say(L.listingTop) else say(L.listingBundle) end
        mood = "smug"
    elseif event == "refresh" then
        say(L.refresh); mood = "determined"
    elseif event == "offers" then
        say(L.offers); mood = "hopeful"
    elseif event == "declined" then
        S.declines += tonumber(ctx.n) or 1
        S.streak = 0
        ctx.declines = S.declines
        if S.declines >= 15 and os.time() - S.criedAt > 1800 then
            say(L.manyDeclined); gif, mood = G.cry, "sad"
            S.criedAt, S.declines = os.time(), 0
        else
            say(L.declined); mood = "annoyed"
        end
    elseif event == "failed" then
        say(L.failed); mood = "frustrated"
    elseif event == "progress" then
        local pct = tonumber(ctx.pct) or 0
        if pct >= 100 then say(L.progressHuge); gif, mood = G.excited, "hyped"
        elseif pct >= 10 then say(L.progressUp); gif, mood = G.weDidIt, "proud"
        elseif pct >= 0 then say(L.progressSmall); mood = "focused"
        else say(L.progressDown); gif, mood = G.cry, "sad" end
    elseif event == "neon" or event == "mega" then
        if event == "mega" then mem.megas = (tonumber(mem.megas) or 0) + 1 else mem.neons = (tonumber(mem.neons) or 0) + 1 end
        saveMemory()
        say(event == "mega" and L.mega or L.neon)
        gif, mood = G.excited, "sparkling"
    elseif event == "warning" then
        say(L.warning); gif, mood = G.cry, "worried"
    else
        say(L[event])
    end
    return (#out > 0 and table.concat(out, "\n") or nil), gif, mood
end

return Kiria
