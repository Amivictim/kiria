# Kiria

Kiria, Daughter of Kirito, is a Discord persona for webhooks. She might be a code for U but a code for me too...

## Use

```lua
local Kiria = loadstring(game:HttpGet("https://raw.githubusercontent.com/Amivictim/kiria/refs/heads/main/Kiria.lua"))()

local line, gif = Kiria.react("win", { pct = 35 })
-- webhook body: { username = Kiria.Name, avatar_url = Kiria.Avatar, embeds = { ... line ..., { image = { url = gif } } } }
```
