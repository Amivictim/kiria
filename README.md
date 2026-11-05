# Kiria

Kiria, Daughter of Kirito, is a Discord persona for bots. She brings a name, a profile picture, a line for each event, and an Inori (Medalist) GIF that matches the mood.

## Use

```lua
local Kiria = loadstring(game:HttpGet("https://raw.githubusercontent.com/Amivictim/kiria/refs/heads/main/Kiria.lua"))()

local line, gif = Kiria.react("win", { pct = 35 })
-- webhook body: { username = Kiria.Name, avatar_url = Kiria.Avatar, embeds = { ... line ..., { image = { url = gif } } } }
```

## Events

| event      | ctx                 | GIF                                                     |
|------------|---------------------|---------------------------------------------------------|
| `start`    |                     | start                                                   |
| `win`      | `pct`, `dry`        | under 20%: smirk, 20%+: didIt, 50%+: ego, 100%+: excited. In test mode (`dry`) there is no GIF |
| `progress` | `diff`              | up: weDidIt, down: cry                                  |
| `warning`  |                     | cry                                                     |
| `listing`, `refresh`, `offers`, `declined`, `failed` | | none (line only)                |

To change her name, picture, lines or GIFs, edit `Kiria.lua` and push. Every bot that loads her picks up the change on its next start.
