-- Kiria: Kirito's lost fragment, and your trading companion.
-- Load:  local Kiria = loadstring(game:HttpGet("https://raw.githubusercontent.com/Amivictim/kiria/refs/heads/main/Kiria.lua"))()
-- Use:   local line, gif, mood, meta = Kiria.react("win", { pct = 35, gain = 1.2, give = "Owl", get = "Shadow Dragon" })
--        meta = { rank = "Analyst", xp = 340, promoted = false }
--        webhook: username = Kiria.Name .. " | " .. Kiria.Title, avatar_url = Kiria.Avatar, her line = the card's text
--
-- 3.2 (2026-11-12, for TradeBot v1.4): ask listings (one pet for one pet worth more, traded by the game itself),
-- where a win came from (our offer / an offer on our listing / our ask listing), "still working" lines, the game's
-- fairness limit explained as it now works, no promise about answer times, memory kept in the TradeBot/ folder.
-- Older bots still get clean lines: a line whose details are missing is skipped.
--
-- 3.3 (2026-11-18, for TradeBot 2.5.0): Flip Mode lines (flip_start, flip_entry, flip_wait, flip_complete,
-- flip_expired, flip_recovery). A completed flip earns XP once and counts in her memory as a flip (mem.flips),
-- never as an ordinary trade; practice (simulated) flips earn nothing. TradeBot sends each flip event once per cycle.

local Kiria = {
    Version = "3.3",
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

-- How she talks: a calm, kind partner who looks after your pets. She says what happened in plain words, what it
-- means for us, and what she does next. Short sentences and everyday English, so a player who reads English as a
-- second language understands her. She is honest about no's and losses, never mocks other traders, never promises
-- what the bot does not do, and explains a thing once per session, then keeps it short.
--
-- {name} is filled from the bot's details (ctx) or her memory. {name:one|many} picks a word by the number
-- (1 -> one, anything else -> many). A line whose details are missing is skipped, so an older bot that sends fewer
-- details still gets clean sentences.
Kiria.Lines = {
    hello = {
        night = {
            "It's late. I'll keep trading quietly while you rest.",
            "Night shift! Fewer traders are online, but I'll still look for good deals for us.",
        },
        morning = {
            "Good morning! I'm at the Trade Hub and ready to start.",
            "Morning! Let's see what the market has for us today.",
        },
        day = {
            "Hi! I'm back at the Trade Hub and ready to trade for us.",
            "Hello again! I'm looking for good deals now.",
        },
        evening = {
            "Good evening! Many traders are online now, so it's a good time for deals.",
            "Evening! Let's find some good trades before the day ends.",
        },
    },
    intro = {
        "I'm Kiria, Kirito's lost fragment. I'll trade your pets for you, one careful step at a time.",
    },
    returning = {
        "This is session #{sessions}. Together we've closed {trades} {trades:trade|trades} so far.",
        "Day {days} together. {trades} {trades:trade|trades} done, and I keep learning what works.",
    },
    promise = {
        "My promise: I only trade when we get at least {minPct}% more value than we give. Locked and favorite pets always stay with you.",
        "My promise: I only trade when we come out ahead. Locked and favorite pets always stay with you.",
    },
    practiceStart = {
        "This is practice mode, so nothing real will be traded. I'll show you what I would do.",
    },

    -- a finished trade (our offer was accepted)
    smallWin = {
        "Done! We gave {give} and got {get}. That's +{pct}% for us. Small steps like this add up.",
        "Trade done: {give} for {get}, +{pct}%. Not big, but safe and steady.",
    },
    win = {
        "Nice! We traded {give} for {get} and came out {pct}% ahead.",
        "Good trade: {give} went out, {get} came in. That's +{gain} value for us.",
    },
    bigWin = {
        "Great trade! {give} for {get} is +{pct}%. That's one of our better ones.",
        "We got {get} for {give}. That's +{pct}%, a really good deal for us.",
    },
    hugeWin = {
        "Wow! {give} became {get}. We more than doubled the value (+{pct}%).",
        "This one is special: {give} for {get}, +{pct}%. I'm so happy right now.",
    },
    -- a trader came to us: an offer on our listing that I accepted
    incomingWin = {
        "Someone made a good offer on our listing: {give} for {get}, +{pct}%. I took it.",
        "An offer on our {give} listing was good for us, so I accepted: we got {get} (+{pct}%).",
    },
    -- our ask listing traded by itself (the game does it when someone offers exactly what we asked)
    askWin = {
        "Our ask listing worked! Someone gave {get} for our {give}. That's +{pct}% for us.",
        "{give} is gone and {get} is ours. Someone took our listing exactly as asked (+{pct}%).",
    },
    lossTrade = {
        "This trade came out a little behind ({gain}). The value list changed after I sent the offer. I'll keep watching the values.",
    },
    valueWhy = {
        "By the value list, we got {getV} for {giveV}.",
    },
    record = { "That's our best trade ever!", "New record: our biggest gain so far!" },
    milestone = {
        "That's {count} trades this session. We're doing well.",
        "Trade number {count} this session. Thank you for trusting me with this.",
    },
    practice = {
        "Practice: {give} for {get} would be +{pct}%. In live mode, I'd take this one.",
    },

    -- one round of offers (TradeBot 1.3+ sends them as one card)
    sent = {
        "I sent {sent} new {sent:offer|offers}. Each one asks for a little more value than we give.",
        "{sent} new {sent:offer is|offers are} out. Now we wait for answers.",
    },
    declinedWhy = {
        "{declined} {declined:offer was|offers were} declined. That's normal: a lister often gets many offers and picks only one.",
    },
    declinedShort = {
        "{declined} {declined:offer was|offers were} declined.",
        "{declined} said no this time. That's okay.",
    },
    swapWhy = {
        "I swapped {replaced} older {replaced:offer|offers} for {replaced:a better one|better ones}. The game lets us keep only 20 offers waiting, so I keep the best ones.",
    },
    swapShort = {
        "I swapped {replaced} {replaced:offer|offers} for {replaced:a better one|better ones}.",
    },
    expired = {
        "{expired} {expired:offer|offers} got no answer in time, so I cancelled {expired:it|them} and freed the pets for new offers.",
        "No answer on {expired} {expired:offer|offers}, so I took {expired:it|them} back. The pets are free for new offers.",
    },
    failWhy = {
        "The game didn't let {failed} {failed:offer|offers} through. The game checks fairness with its own prices, not our value list. I now remember how much it allows for that pet, so I won't ask that much again.",
    },
    failShort = {
        "The game blocked {failed} {failed:offer|offers}. I noted its limit for next time.",
    },
    manyDeclined = {
        "Lots of no's today, I know. That's how the Trade Hub works: one good yes is worth many no's. I'm staying patient for us.",
        "It's been quiet for a while. I'm keeping my offers fair and safe, and the next yes will come.",
    },

    -- our own listings
    listingTop = {
        "I listed {items} for offers. If someone offers more than it's worth to us, I'll accept.",
        "{items} is up for offers now. I'll only accept an offer that gives us more value.",
    },
    listingAsk = {
        "I listed {items} and asked for {ask} (+{askPct}%). If someone offers exactly that, the game trades it by itself, even while I'm busy.",
        "New ask listing: our {items} for their {ask}. If someone has it, the trade happens on its own.",
    },
    listingAskShort = {
        "Ask listing up: {items} for {ask}.",
    },
    listingBundle = {
        "I listed {n} pets together ({items}) and I'm waiting for good offers.",
        "A bundle of {n} pets ({items}) is up for offers. I'll only accept an offer that gives us more value.",
    },
    listingOne = {
        "{items} is up for offers too. Once I know what other traders hold, I'll turn it into an ask listing.",
    },
    listingPractice = {
        "Practice: I would list {items} and ask for {ask}.",
        "Practice: I would list {items} now.",
    },
    refresh = {
        "{items} got no good offer in {min} minutes, so I took it down. Something fresh comes next.",
        "That listing got no good offer, so I took it down. Something fresh comes next.",
    },

    -- no Discord message for a while: what she has been doing (TradeBot's "still working" card)
    quiet = {
        "Still here and still working. I checked {listings} listings in {min} minutes, {fresh} of them new. Nothing good enough yet, so I keep looking.",
        "Quiet, but busy: {waiting} {waiting:offer is|offers are} waiting for an answer, and I keep checking new listings.",
        "The Trade Hub is busy: {fresh} new listings since my last message. I'm being picky for us.",
        "I looked at {listings} listings in the last {min} minutes. I only trade when we come out ahead, so I'm still waiting for the right one.",
    },
    quietIdle = {
        "It's quiet, and I could not look at listings for {min} minutes. I'm still running and I'll keep trying.",
    },

    -- how the session is going
    progressHuge = { "We're up {pct}% since we started. That's amazing progress!" },
    progressUp = {
        "Our pets are worth {value} now, up {pct}% since we started. That's real progress!",
        "We're up {pct}% since we started ({value} now). That's real progress!",
        "We're up {pct}% since we started. That's real progress!",
    },
    progressSmall = {
        "Our pets are worth {value} now, up {pct}% since we started. Slow and steady.",
        "We're up {pct}% so far ({value} now). Slow and steady is still progress.",
        "We're up {pct}% so far. Slow and steady is still progress.",
    },
    progressFlat = { "No change yet. That's okay, good deals take a little time." },
    progressDown = {
        "We're down {pct}% since the start. This is usually the value list moving, not a bad trade. Every trade I make still has to come out ahead.",
    },
    rate = { "{wins} of {offers} offers got a yes this session ({rate}%)." },
    better = { "That's better than last session ({lastRate}%)." },
    worse = { "Last session it was {lastRate}%. I'm adjusting as I learn." },

    neon = { "Four pets became one Neon {pet}. It glows now!" },
    mega = { "A Mega Neon {pet}! Four neons became one. That's a big step up." },
    promotion = {
        "I got promoted to {rank}! Thank you for trusting me with your pets.",
        "New title: {rank}. I'll keep taking good care of our trades.",
    },
    -- Flip Mode: trade one pet for a few pets worth more, buy that pet back with part of them, keep the rest
    flipWhy = {
        "New plan: a flip. I trade our {pet} for a few pets worth more, then buy {pet} back with some of them. What's left is our profit.",
    },
    flipStart = {
        "Starting a flip with our {pet}.",
        "Next flip: {pet}. I'm looking for someone who gives more for it.",
    },
    flipPractice = {
        "Practice flip: I use real listings, but no real trade happens.",
    },
    flipEntry = {
        "We got a nice overpay for {pet}: {get}.",
        "Step one done: {pet} went out, {get} came in.",
    },
    flipSearching = {
        "Now let's see if we can get our {pet} back.",
        "Next I look for {pet} to buy it back. I won't overpay for it.",
    },
    flipWait = {
        "That return trade isn't worth the risk. I'll keep looking.",
        "The buyback offers I see would lose value overall, so I'm waiting for a better one.",
    },
    flipComplete = {
        "We got our {pet} back and kept {kept}. That's a clean flip! +{gain} overall.",
        "We got our {pet} back and kept the extra value. That's a clean flip!",
    },
    flipExact = {
        "It's even the very same {pet} we started with.",
    },
    flipPracticeDone = {
        "Practice flip done: with these listings it would have made +{gain}. No real trade happened.",
    },
    flipExpired = {
        "This flip ran out of time. I didn't force a bad trade, so the pets we got stay with us.",
    },
    flipRecovery = {
        "Something in this flip is unclear, so I stopped it to keep your pets safe. Please take a look.",
    },
    warning = {
        "I ran into something I can't fix by myself. What happened is written above.",
        "I need your help with something. I wrote what I saw above.",
    },
}

local HttpService = game:GetService("HttpService")
local mem = { sessions = 0, firstSeen = os.time(), trades = 0, total = 0, bestGain = 0, neons = 0, megas = 0, xp = 0,
    lastRate = nil, curRate = nil, askTrades = 0, incomingTrades = 0, flips = 0, flipGain = 0 }
-- this session: wins, offers sent, no's since the last win, what she has already explained
local S = { wins = 0, sent = 0, noSinceWin = 0, cheeredAt = 0, told = {} }

-- her memory sits with TradeBot's own files (the "TradeBot" folder) when the executor has folders;
-- a memory file left at the top level is moved in once
local function memoryPath()
    local root, dir = Kiria.MemoryFile, "TradeBot"
    local okD, has = pcall(function()
        if type(isfolder) ~= "function" then return false end
        if not isfolder(dir) and type(makefolder) == "function" then makefolder(dir) end
        return isfolder(dir) == true
    end)
    if not (okD and has) then return root end
    local p = dir .. "/" .. root
    pcall(function()
        if isfile and isfile(root) and not isfile(p) then
            writefile(p, readfile(root))
            if type(delfile) == "function" and isfile(p) then delfile(root) end
        end
    end)
    return p
end
local MEMORY = memoryPath()

local function loadMemory()
    pcall(function()
        if isfile and isfile(MEMORY) then
            local t = HttpService:JSONDecode(readfile(MEMORY))
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
    pcall(function() if writefile then writefile(MEMORY, HttpService:JSONEncode(mem)) end end)
end
loadMemory()

function Kiria.rank()
    local xp, title = tonumber(mem.xp) or 0, Kiria.Ranks[1][2]
    for _, r in ipairs(Kiria.Ranks) do if xp >= r[1] then title = r[2] end end
    return title, xp
end

local MONEY = { gain = true, total = true, value = true, diff = true, start = true, giveV = true, getV = true, askV = true }
local PERCENT = { pct = true, rate = true, lastRate = true, askPct = true }

local function fill(text, ctx)
    if type(text) ~= "string" then return nil end
    local missing = false
    local function get(k)
        local v = ctx[k]
        if v == nil then v = mem[k] end
        return v
    end
    text = string.gsub(text, "{(%w+):([^|}]*)|([^}]*)}", function(k, one, many)
        local v = tonumber(get(k))
        if v == nil then missing = true; return "" end
        return v == 1 and one or many
    end)
    text = string.gsub(text, "{(%w+)}", function(k)
        local v = get(k)
        if v == nil or v == "" then missing = true; return "" end
        if PERCENT[k] and tonumber(v) then
            local a = math.abs(tonumber(v))
            return string.format(a < 10 and "%.1f" or "%.0f", a)
        end
        if MONEY[k] and tonumber(v) then return string.format("%.2f", tonumber(v)) end
        return tostring(v)
    end)
    if missing then return nil end
    return text
end

local function num(v) return tonumber(v) or 0 end

-- event: start | win | round | listing | refresh | progress | quiet | neon | mega | warning
--        | flip_start | flip_entry | flip_wait | flip_complete | flip_expired | flip_recovery (TradeBot 2.5 Flip Mode)
--        (offers | declined | failed: the per-kind cards of older TradeBot builds)
-- ctx:   start: dry, minPct | win: pct, gain, give, get, giveV, getV, dry, source ("incoming" / "ask" / nil)
--        round: sent, declined, replaced, expired, failed
--        listing: slot ("top" / "ask" / "bundle"), items, n, dry, ask, askV, askPct | refresh: items, min
--        progress: pct, diff, value, wins, offers, rate | quiet: listings, fresh, sent, waiting, min
--        neon / mega: pet | offers / declined / failed: n, declined
--        flip_*: dry (practice), pet, value, get (what step one gave), gain, pct, kept, exact (same pet back), why
-- returns: line (string, may have several lines, or nil when she has nothing to add), gif url (or nil), mood (one word),
--          meta { rank, xp, promoted }
function Kiria.react(event, ctx)
    ctx = type(ctx) == "table" and ctx or {}
    local G, L = Kiria.Gifs, Kiria.Lines
    local out, gif, mood = {}, nil, "calm"
    local rankBefore = Kiria.rank()
    -- one line from a list: of the lines whose details are all known, the ones that use the most details, one at random
    local function say(list)
        if type(list) ~= "table" or #list == 0 then return false end
        local best, most = {}, -1
        for _, raw in ipairs(list) do
            local s = fill(raw, ctx)
            if s then
                local keys = {}
                for k in string.gmatch(raw, "{(%w+)[:}]") do keys[k] = true end
                local n = 0
                for _ in pairs(keys) do n += 1 end
                if n > most then best, most = { s }, n elseif n == most then best[#best + 1] = s end
            end
        end
        if #best == 0 then return false end
        out[#out + 1] = best[math.random(1, #best)]
        return true
    end
    -- explained once per session, short after that
    local function explain(key, long, short)
        if not S.told[key] and say(long) then S.told[key] = true else say(short) end
    end
    local function earn(x) mem.xp = (tonumber(mem.xp) or 0) + x end

    if event == "start" then
        mem.sessions = (tonumber(mem.sessions) or 0) + 1
        earn(2)
        if mem.curRate then mem.lastRate = mem.curRate end
        mem.curRate = nil
        S.wins, S.sent, S.noSinceWin, S.told = 0, 0, 0, {}
        ctx.sessions = mem.sessions
        ctx.days = math.max(1, math.floor((os.time() - (tonumber(mem.firstSeen) or os.time())) / 86400) + 1)
        ctx.rank = rankBefore
        local h = tonumber(os.date("%H")) or 12
        say(L.hello[(h < 6 and "night") or (h < 12 and "morning") or (h < 18 and "day") or "evening"])
        if mem.sessions <= 1 then say(L.intro) else say(L.returning) end
        if ctx.dry then say(L.practiceStart) end
        say(L.promise)
        gif, mood = G.start, "ready"
    elseif event == "win" then
        local pct = num(ctx.pct)
        if ctx.dry then
            say(L.practice)
            gif = (pct >= 100 and G.excited) or (pct >= 20 and G.didIt) or G.smirk
            mood = "curious"
        else
            S.wins += 1; S.noSinceWin = 0
            mem.trades = (tonumber(mem.trades) or 0) + 1
            local gain = num(ctx.gain)
            mem.total = (tonumber(mem.total) or 0) + gain
            local record = mem.trades > 1 and gain > (tonumber(mem.bestGain) or 0)
            if gain > (tonumber(mem.bestGain) or 0) then mem.bestGain = gain end
            earn(10 + math.min(40, math.max(0, pct) / 2))
            -- the gif and mood follow the size of the win; the words follow where it came from
            if gain < 0 then mood = "careful"
            elseif pct >= 100 then gif, mood = G.excited, "thrilled"
            elseif pct >= 50 then gif, mood = G.weDidIt, "excited"
            elseif pct >= 20 then gif, mood = G.didIt, "proud"
            else gif, mood = G.smirk, "happy" end
            if gain < 0 then say(L.lossTrade)
            elseif ctx.source == "ask" and say(L.askWin) then
                mem.askTrades = (tonumber(mem.askTrades) or 0) + 1
                earn(5)
                if mood == "happy" then mood = "pleased" end
            elseif ctx.source == "incoming" and say(L.incomingWin) then
                mem.incomingTrades = (tonumber(mem.incomingTrades) or 0) + 1
            elseif pct >= 100 then say(L.hugeWin)
            elseif pct >= 50 then say(L.bigWin)
            elseif pct >= 20 then say(L.win)
            else say(L.smallWin) end
            if (tonumber(ctx.n) or 1) > 1 or string.find(tostring(ctx.give), "+", 1, true) then say(L.valueWhy) end
            if record then say(L.record); gif, mood = G.excited, "over the moon" end
            if gain >= 0 and (S.wins == 3 or S.wins == 5 or S.wins % 10 == 0) then ctx.count = S.wins; say(L.milestone) end
        end
    elseif event == "round" or event == "offers" or event == "declined" or event == "failed" then
        -- older builds send one card per kind: turn it into the round's numbers
        if event == "offers" then ctx.sent = ctx.n
        elseif event == "declined" then
            local no = tonumber(ctx.declined) or num(ctx.n)
            ctx.declined, ctx.expired = no, math.max(num(ctx.n) - no, 0)
        elseif event == "failed" then ctx.failed = ctx.n end
        local sent, no, swap, exp, fail = num(ctx.sent), num(ctx.declined), num(ctx.replaced), num(ctx.expired), num(ctx.failed)
        S.sent += sent
        S.noSinceWin += no
        if sent > 0 then say(L.sent) end
        if no > 0 then explain("declined", L.declinedWhy, L.declinedShort) end
        if swap > 0 then explain("swap", L.swapWhy, L.swapShort) end
        if exp > 0 then say(L.expired) end
        if fail > 0 then explain("fail", L.failWhy, L.failShort) end
        if no > 0 and S.noSinceWin >= 25 and os.time() - S.cheeredAt > 2700 then
            say(L.manyDeclined)
            S.cheeredAt, S.noSinceWin = os.time(), 0
        end
        mood = (fail > 0 and sent == 0 and "puzzled") or (sent > 0 and "hopeful") or "patient"
    elseif event == "listing" then
        earn(1)
        if ctx.dry then say(L.listingPractice)
        elseif ctx.slot == "top" then say(L.listingTop)
        elseif ctx.slot == "ask" then explain("ask", L.listingAsk, L.listingAskShort)
        elseif num(ctx.n) == 1 then say(L.listingOne)
        else say(L.listingBundle) end
        mood = ctx.slot == "ask" and "clever" or "hopeful"
    elseif event == "refresh" then
        say(L.refresh); mood = "patient"
    elseif event == "quiet" then
        -- a line only uses a number when there is something to tell (no "0 offers are waiting")
        for _, k in ipairs({ "listings", "fresh", "waiting" }) do if num(ctx[k]) <= 0 then ctx[k] = nil end end
        if ctx.listings then say(L.quiet) else say(L.quietIdle) end
        mood = ctx.listings and "focused" or "patient"
    elseif event == "progress" then
        local pct = num(ctx.pct)
        if pct >= 100 then say(L.progressHuge); gif, mood = G.excited, "proud"
        elseif pct >= 10 then say(L.progressUp); gif, mood = G.weDidIt, "proud"
        elseif pct >= 0.05 then say(L.progressSmall); mood = "content"
        elseif pct > -0.05 then say(L.progressFlat); mood = "patient"
        else say(L.progressDown); mood = "careful" end
        local rate = tonumber(ctx.rate)
        if not rate and S.sent >= 20 then rate = S.wins / S.sent * 100; ctx.wins, ctx.offers = S.wins, S.sent end
        if rate and num(ctx.offers) >= 20 then
            ctx.rate = rate
            mem.curRate = rate
            say(L.rate)
            if tonumber(mem.lastRate) then
                ctx.lastRate = mem.lastRate
                if rate > tonumber(mem.lastRate) then say(L.better) else say(L.worse) end
            end
        end
    elseif event == "neon" or event == "mega" then
        if event == "mega" then mem.megas = (tonumber(mem.megas) or 0) + 1; earn(40) else mem.neons = (tonumber(mem.neons) or 0) + 1; earn(15) end
        say(event == "mega" and L.mega or L.neon)
        gif, mood = G.excited, "sparkling"
    elseif event == "flip_start" then
        if ctx.dry then say(L.flipPractice) end
        explain("flip", L.flipWhy, L.flipStart)
        mood = "focused"
    elseif event == "flip_entry" then
        if not ctx.dry then earn(5) end
        say(L.flipEntry)
        say(L.flipSearching)
        gif, mood = G.smirk, "hopeful"
    elseif event == "flip_wait" then
        say(L.flipWait); mood = "patient"
    elseif event == "flip_complete" then
        if ctx.dry then
            say(L.flipPracticeDone); mood = "curious"
        else
            mem.flips = (tonumber(mem.flips) or 0) + 1
            mem.flipGain = (tonumber(mem.flipGain) or 0) + num(ctx.gain)
            earn(25)
            say(L.flipComplete)
            if ctx.exact then say(L.flipExact) end
            gif, mood = G.weDidIt, "proud"
        end
    elseif event == "flip_expired" then
        say(L.flipExpired); mood = "calm"
    elseif event == "flip_recovery" then
        say(L.flipRecovery); gif, mood = G.cry, "careful"
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
        gif, mood = G.ego, "honored"
    end
    saveMemory()
    return (#out > 0 and table.concat(out, "\n") or nil), gif, mood, { rank = rankNow, xp = xp, promoted = promoted }
end

return Kiria
