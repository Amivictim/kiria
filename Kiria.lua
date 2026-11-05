-- Kiria: the lost fragment of Kirito, and the desk's trader.
-- Load:  local Kiria = loadstring(game:HttpGet("https://raw.githubusercontent.com/Amivictim/kiria/refs/heads/main/Kiria.lua"))()
-- Use:   local line, gif, mood, meta = Kiria.react("win", { pct = 35, gain = 1.2, give = "Owl", get = "Shadow Dragon" })
--        meta = { rank = "Analyst", xp = 340, promoted = false }
--        webhook: username = Kiria.Name, avatar_url = Kiria.Avatar, author line = Kiria.Name .. " · " .. Kiria.Title

local Kiria = {
    Version = "2.0",
    Name = "Kiria",
    Title = "Kirito's Lost Fragment",
    Avatar = "https://raw.githubusercontent.com/Amivictim/adoptmefarm/refs/heads/main/victimoffate_.png",
    Color = 15277667,
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

-- her career: experience from real results, a new title at each step (memory survives restarts)
Kiria.Ranks = {
    { 0, "Intern" }, { 100, "Junior Analyst" }, { 300, "Analyst" }, { 700, "Trader" }, { 1500, "Senior Trader" },
    { 3000, "Head of Trading" }, { 6000, "Chief Trading Officer" }, { 12000, "Kirito-Tier" },
}

-- {placeholders} come from ctx and her memory: give, get, gain, pct, n, pet, items, hour, sessions, days, trades,
-- total, rank, streak, declines, rate, lastRate
Kiria.Lines = {
    hello = {
        night = {
            "It's {hour} AM. Normal people sleep. I trade. That's the whole difference.",
            "Night shift. Fewer traders online, more mistakes to profit from. I love it here.",
        },
        morning = {
            "Morning. I already read the market. It's weak. Perfect.",
            "Good morning. The coffee is virtual, the profits are not.",
        },
        day = {
            "Desk is open. Bring me underpriced pets and bad decisions.",
            "Back online. The Trade Hub has no idea what's coming.",
        },
        evening = {
            "Evening session. Everyone's tired and careless. My favorite kind of trader.",
            "Prime time. Let's turn pets into bigger pets.",
        },
    },
    intro = {
        "I'm Kiria, the lost fragment of Kirito. Starting as an Intern today. Give me a week and I'll be running this desk.",
    },
    returning = {
        "Session #{sessions}. {trades} wins on my record so far. Current title: {rank}.",
        "Day {days} on the job. {trades} trades closed and I'm still annoyingly right.",
    },
    motto = { "Target: the Peaks. WAHAHAHA.", "Let's go reach the Peaks." },
    smallWin = {
        "Small spread, clean execution. +{gain}. Compound interest is my love language.",
        "+{pct}%. Not flashy, but neither is a bank vault.",
        "{give} out, {get} in. Margins are margins.",
    },
    win = {
        "Sold {give}, bought {get}. +{pct}%. I'd explain the strategy, but it's proprietary.",
        "Closed. +{gain} value. Another satisfied customer. Well, satisfied-ish.",
        "+{pct}% on {get}. Write that down, history books.",
    },
    bigWin = {
        "+{pct}%. Someone just paid tuition for my masterclass.",
        "{get} for {give}? I almost felt bad. Almost.",
        "They blinked first. +{pct}%. WAHAHAHA.",
    },
    hugeWin = {
        "+{pct}%. This isn't a trade, it's a heist with a receipt.",
        "{get}. For {give}. I'm framing this one. WAHAHAHAHA!",
        "Doubled it. Somewhere, an economist is crying.",
    },
    record = { "New personal record: +{gain}. I'd like to thank myself, my strategy, and their mistake." },
    streak3 = { "{streak} in a row. At this point it's not luck, it's a business model." },
    streak5 = { "{streak} straight wins. Someone check if I'm allowed to be this good." },
    practice = {
        "Paper trade: {give} for {get}, +{pct}%. Turn off DryRun and let me cook.",
        "Simulation says +{pct}%. Imagine if this were real. I am imagining it. It's lovely.",
    },
    listingTop = {
        "{items} is on the shelf. Premium product, premium price.",
        "Listed {items}. Window shopping is free. Buying it is not.",
    },
    listingBundle = {
        "Bundle deal: {n} pets, one lucky buyer. The lucky part is mostly me.",
        "{items} bundle is live. Diversified, like a responsible portfolio.",
    },
    refresh = {
        "No bites in 30 minutes? Fine. New display, same genius.",
        "Rotating stock. A stale listing is a sad listing.",
    },
    offers = {
        "{n} offers out. Fishing season is open.",
        "Sent {n} offers. Each one is a tiny, polite ambush.",
    },
    declined = {
        "{n} said no. Bold of them. Wrong, but bold.",
        "Declined x{n}. Their loss is literally measurable.",
        "{n} offers expired or got turned down. Silence is an answer too. A wrong one.",
    },
    manyDeclined = { "{declines} rejections today. I'm not crying. The market is crying. Fine, I'm crying a little." },
    failed = { "{n} offers bounced. The game said no, not the people. I'm taking it personally anyway." },
    progressHuge = { "Portfolio up +{pct}% since we started. We didn't climb the Peaks, we bought them." },
    progressUp = {
        "Up +{pct}% since the start. This is what competence looks like on a chart.",
        "+{pct}% and climbing. I'd say I'm proud, but I expected this.",
    },
    progressSmall = { "+{pct}% so far. Slow money is still money.", "+{pct}%. Warming up. The real numbers come later." },
    progressDown = {
        "Down {pct}%. Temporary. I've already picked who's going to pay for it.",
        "-{pct}%. A dip is just a discount on my future gains.",
    },
    improving = { "Hit rate this session: {rate}% (last session {lastRate}%). I'm learning. It's a little scary." },
    neon = { "Fused a Neon {pet}. Four became one and it glows. That's called value creation." },
    mega = { "MEGA NEON {pet}. Sixteen pets became one masterpiece. You may applaud." },
    promotion = {
        "Promotion unlocked: {rank}. New title, same appetite.",
        "They made me {rank}. Clearly the board has taste.",
    },
    warning = { "Something's off and I can't fix it alone. Check the log for me?" },
}

local HttpService = game:GetService("HttpService")
local mem = { sessions = 0, firstSeen = os.time(), trades = 0, total = 0, bestGain = 0, neons = 0, megas = 0, xp = 0,
    lastRate = nil, curRate = nil }
local S = { wins = 0, streak = 0, declines = 0, sent = 0, criedAt = 0 }

local function loadMemory()
    pcall(function()
        if isfile and isfile(Kiria.MemoryFile) then
            local t = HttpService:JSONDecode(readfile(Kiria.MemoryFile))
            if type(t) == "table" then
                for k, v in pairs(t) do mem[k] = v end
                -- memory from before the career system: count the work already done
                if t.xp == nil then
                    mem.xp = (tonumber(t.trades) or 0) * 20 + (tonumber(t.neons) or 0) * 15 + (tonumber(t.megas) or 0) * 40
                        + (tonumber(t.sessions) or 0) * 2
                end
            end
        end
    end)
end
local function saveMemory()
    pcall(function() if writefile then writefile(Kiria.MemoryFile, HttpService:JSONEncode(mem)) end end)
end
loadMemory()

function Kiria.rank()
    local xp, title = tonumber(mem.xp) or 0, Kiria.Ranks[1][2]
    for _, r in ipairs(Kiria.Ranks) do if xp >= r[1] then title = r[2] end end
    return title, xp
end

local function pick(list)
    if type(list) ~= "table" or #list == 0 then return nil end
    return list[math.random(1, #list)]
end

local function fill(text, ctx)
    if not text then return nil end
    return (string.gsub(text, "{(%w+)}", function(k)
        local v = ctx[k]
        if v == nil then v = mem[k] end
        if (k == "pct" or k == "rate" or k == "lastRate") and tonumber(v) then return string.format("%.0f", math.abs(tonumber(v))) end
        if (k == "gain" or k == "total") and tonumber(v) then return string.format("%.2f", tonumber(v)) end
        if v == nil then return "?" end
        return tostring(v)
    end))
end

local function hello(ctx)
    local h = tonumber(os.date("%H")) or 12
    ctx.hour = h == 0 and 12 or h
    local part = (h < 6 and "night") or (h < 12 and "morning") or (h < 18 and "day") or "evening"
    return pick(Kiria.Lines.hello[part])
end

-- event: start | win | listing | refresh | offers | declined | failed | progress | neon | mega | warning
-- ctx:   pct, gain, give, get, n, items, slot ("top" / "bundle"), pet, diff, dry (true = practice / test mode)
-- returns: line (string, may have several lines), gif url (or nil), mood (one word), meta { rank, xp, promoted }
function Kiria.react(event, ctx)
    ctx = type(ctx) == "table" and ctx or {}
    local G, L = Kiria.Gifs, Kiria.Lines
    local out, gif, mood = {}, nil, "focused"
    local rankBefore = Kiria.rank()
    local function say(list) local s = fill(pick(list), ctx); if s then out[#out + 1] = s end end
    local function earn(x) mem.xp = (tonumber(mem.xp) or 0) + x end

    if event == "start" then
        mem.sessions = (tonumber(mem.sessions) or 0) + 1
        earn(2)
        if mem.curRate then mem.lastRate = mem.curRate end
        mem.curRate = nil
        ctx.sessions = mem.sessions
        ctx.days = math.max(1, math.floor((os.time() - (tonumber(mem.firstSeen) or os.time())) / 86400) + 1)
        ctx.rank = rankBefore
        say({ hello(ctx) })
        if mem.sessions <= 1 then say(L.intro) else say(L.returning) end
        say(L.motto)
        gif, mood = G.start, "ready"
    elseif event == "win" then
        local pct = tonumber(ctx.pct) or 0
        if ctx.dry then
            say(L.practice)
            gif = (pct >= 100 and G.excited) or (pct >= 50 and G.ego) or (pct >= 20 and G.didIt) or G.smirk
            mood = "theoretical"
        else
            S.wins += 1; S.streak += 1; S.declines = 0
            mem.trades = (tonumber(mem.trades) or 0) + 1
            local gain = tonumber(ctx.gain) or 0
            mem.total = (tonumber(mem.total) or 0) + gain
            local record = mem.trades > 1 and gain > (tonumber(mem.bestGain) or 0)
            if gain > (tonumber(mem.bestGain) or 0) then mem.bestGain = gain end
            earn(10 + math.min(40, math.max(0, pct) / 2))
            ctx.streak = S.streak
            if pct >= 100 then say(L.hugeWin); gif, mood = G.excited, "unstoppable"
            elseif pct >= 50 then say(L.bigWin); gif, mood = G.ego, "smug"
            elseif pct >= 20 then say(L.win); gif, mood = G.didIt, "proud"
            else say(L.smallWin); gif, mood = G.smirk, "satisfied" end
            if record then say(L.record); gif, mood = G.excited, "legendary" end
            if S.streak >= 5 then say(L.streak5) elseif S.streak >= 3 then say(L.streak3) end
        end
    elseif event == "listing" then
        earn(1)
        if ctx.slot == "top" then say(L.listingTop) else say(L.listingBundle) end
        mood = "confident"
    elseif event == "refresh" then
        say(L.refresh); mood = "restless"
    elseif event == "offers" then
        S.sent += tonumber(ctx.n) or 0
        say(L.offers); mood = "hunting"
    elseif event == "declined" then
        S.declines += tonumber(ctx.n) or 1
        S.streak = 0
        ctx.declines = S.declines
        if S.declines >= 15 and os.time() - S.criedAt > 1800 then
            say(L.manyDeclined); gif, mood = G.cry, "betrayed"
            S.criedAt, S.declines = os.time(), 0
        else
            say(L.declined); mood = "unbothered"
        end
    elseif event == "failed" then
        say(L.failed); mood = "irritated"
    elseif event == "progress" then
        local pct = tonumber(ctx.pct) or 0
        if pct >= 100 then say(L.progressHuge); gif, mood = G.excited, "rich"
        elseif pct >= 10 then say(L.progressUp); gif, mood = G.weDidIt, "proud"
        elseif pct >= 0 then say(L.progressSmall); mood = "patient"
        else say(L.progressDown); gif, mood = G.cry, "plotting" end
        if S.sent >= 20 then
            mem.curRate = S.wins / S.sent * 100
            if tonumber(mem.lastRate) then
                ctx.rate, ctx.lastRate = mem.curRate, mem.lastRate
                say(L.improving)
            end
        end
    elseif event == "neon" or event == "mega" then
        if event == "mega" then mem.megas = (tonumber(mem.megas) or 0) + 1; earn(40) else mem.neons = (tonumber(mem.neons) or 0) + 1; earn(15) end
        say(event == "mega" and L.mega or L.neon)
        gif, mood = G.excited, "sparkling"
    elseif event == "warning" then
        say(L.warning); gif, mood = G.cry, "worried"
    else
        say(L[event])
    end

    local rankNow, xp = Kiria.rank()
    local promoted = rankNow ~= rankBefore
    if promoted then
        ctx.rank = rankNow
        say(L.promotion)
        gif, mood = G.excited, "promoted"
    end
    saveMemory()
    return (#out > 0 and table.concat(out, "\n") or nil), gif, mood, { rank = rankNow, xp = xp, promoted = promoted }
end

return Kiria
