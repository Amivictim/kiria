-- Kiria, Daughter of Kirito: a Discord persona for bots.
-- Load:  local Kiria = loadstring(game:HttpGet("https://raw.githubusercontent.com/Amivictim/kiria/refs/heads/main/Kiria.lua"))()
-- Use:   local line, gif = Kiria.react("win", { pct = 35 })
--        send Kiria.Name / Kiria.Avatar as the webhook username / avatar_url

local Kiria = {
    Version = "1.0",
    Name = "Daughter of Kirito ,,, Kiria Win.",
    Avatar = "https://raw.githubusercontent.com/Amivictim/adoptmefarm/refs/heads/main/victimoffate_.png",
    Footer = "Kiria",
}

Kiria.Gifs = {
    start   = "https://media1.tenor.com/m/co7Ve4XL7hMAAAAd/%E3%83%A1%E3%83%80%E3%83%AA%E3%82%B9%E3%83%88-inori-yuitsuka.gif",
    didIt   = "https://media1.tenor.com/m/L-7KQj9o4gAAAAAd/medalist-inori.gif",
    smirk   = "https://media1.tenor.com/m/m5QWK9z_rTsAAAAd/medalist-inori.gif",
    excited = "https://media1.tenor.com/m/ly7jh7JUnREAAAAd/medalist-inori.gif",
    ego     = "https://media1.tenor.com/m/IvCIh8jOT7YAAAAd/medalist-inori.gif",
    weDidIt = "https://media1.tenor.com/m/NpPtj0ArnK8AAAAd/medalist-medalist-manga.gif",
    cry     = "https://media1.tenor.com/m/VVm2bMo4BXEAAAAC/medalist-inori.gif",
}

Kiria.Lines = {
    start = {
        "Its working and I, Daughter of Kirito! Kiria will do my Best To Help you Reach the Peaks! WAHAHAHAHA",
    },
    smallWin = {
        "A small one, but a win is a win. Hehe.",
        "Kiria squeezed a little more value out of that one!",
    },
    win = {
        "Haha, I did it! Kiria WIN!",
        "Kiria WIN! One step closer to the Peaks!",
    },
    bigWin = {
        "You see this? You SEE this?! Kiria is unstoppable!",
        "Bow down, Kiria made that happen!",
    },
    hugeWin = {
        "WAAAAH! THIS IS HUGE! KIRIA DID IT!!",
        "THE PEAKS ARE RIGHT THERE! WAHAHAHAHA!",
    },
    practice = {
        "Kiria would take this one! (practice mode)",
        "If this were real, Kiria would already be celebrating!",
    },
    listing = {
        "Kiria put our pets on the market! Who wants them?",
        "Shiny pets on display. Come and get them!",
    },
    refresh = {
        "Nobody took the bait... Kiria is putting up a fresh listing!",
    },
    offers = {
        "Kiria sent some offers! Fingers crossed!",
        "Offers are out. Let's see who is smart enough to say yes.",
    },
    declined = {
        "Hmph! They said no. Kiria will find better ones!",
    },
    failed = {
        "Ugh, these offers did not go through...",
    },
    progressUp = {
        "We did it! Look how much we have grown together!",
    },
    progressDown = {
        "Waaah... we went down a little. Kiria will fix it, promise!",
    },
    warning = {
        "Kiria needs your help with something...",
    },
}

local function pick(list)
    if type(list) ~= "table" or #list == 0 then return nil end
    return list[math.random(1, #list)]
end

-- event: start | win | listing | refresh | offers | declined | failed | progress | warning
-- ctx:   pct (win % of the trade), diff (value change for progress), dry (true = practice / test mode)
-- returns: line (string or nil), gif url (string or nil)
function Kiria.react(event, ctx)
    ctx = type(ctx) == "table" and ctx or {}
    local G, L = Kiria.Gifs, Kiria.Lines
    if event == "start" then
        return pick(L.start), G.start
    elseif event == "win" then
        local pct = tonumber(ctx.pct) or 0
        if ctx.dry then return pick(L.practice), nil end
        if pct >= 100 then return pick(L.hugeWin), G.excited end
        if pct >= 50 then return pick(L.bigWin), G.ego end
        if pct >= 20 then return pick(L.win), G.didIt end
        return pick(L.smallWin), G.smirk
    elseif event == "progress" then
        local diff = tonumber(ctx.diff) or 0
        if diff > 0 then return pick(L.progressUp), G.weDidIt end
        if diff < 0 then return pick(L.progressDown), G.cry end
        return pick(L.progressUp), nil
    elseif event == "warning" then
        return pick(L.warning), G.cry
    end
    return pick(L[event]), nil
end

return Kiria
