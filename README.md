# esx_collectables
Enable collectable items on an ESX-enabled FiveM server. 

![Demo Image 1](https://i.imgur.com/f1nD7Ap.gif)

## Features
* Enable hidden collectables from the single player experience (Letter Scraps, Spaceship Parts, etc)
* Enable players to earn money for finding and completing collectables
* Menu to track progress of quests
* Allow players to reset quest progress
* Add your own custom collectables

## Requirements

* [es_extended](https://github.com/ESX-Org/es_extended)

## Download & Installation

* Download and extract the package: https://github.com/Mobius1/esx_collectables/archive/master.zip
* Rename the `esx_collectables-master` directory to `esx_collectables`
* Drop the `esx_collectables` directory into the `[esx]` directory on your server
* Import `esx_collectables.sql` into to your database
* Add `start esx_collectables` in your `server.cfg`
* Edit `config.lua` to your liking
* Start your server and rejoice!

Collectables are spawned locally so are only visible to the local player. This means that all players can have their own collectable hunt.

## Placing Collectables
By default, the resource places the collectable prop on the ground properly. If you want the prop to be set at it's z-coord defined in `config.lua` then set `Config.PlaceCollectables` to `false`.

## Rewarding Players
Players can be rewarded with cash for finding each collectable and for finding all collectables in a group. Just add the `Rewards` table to the group's config in `config.lua`:

```lua
Config.Collectables = {
    LetterScraps = {
        Enabled = true,
        ID = 'letter_scraps',
        Prop = 'prop_ld_scrap',      
        Rewards = {
            PerItem = 50,           -- Cash reward per item found
            Completed = 50000        -- Cash reward for all items found
        },
        ...
    }
    ...
}
```

## Available Server Events

```lua
AddEventHandler('esx_collectables:itemCollected', function(xPlayer, collectable, group)
    -- do something when player picks up collectable
end)

AddEventHandler('esx_collectables:completed', function(xPlayer, collectable, group)
    -- do something when player has found all collectables in the group
end)
```

Both events have 3 parameters:
* `Xplayer` -  the current ESX player
* `collectable` - the item last picked up:
```lua
{
    ID = string / integer       -- the item ID defined in the config
    Collected = boolean,        -- Has the item been collected?
    InRange = boolean,          -- Is the item in range for the player?
    Spawned = boolean,          -- Is the item spawned?
    Entity = string,            -- The entity
    Pos = vector3               -- The item position
}
```
* `group` - the group the item belongs to:
```lua
{
    Items = {},                             -- The collectable items
    Collected = {}                          -- A list of collected item IDs
}
```


## Adding Custom Collectables
As well as the collectables from the single player experience, you have the option to add your own custom collectables.

Say we want to add some lost spanners to find. We need to add the data in `config.lua` and a column in your MySQL database to save the player's progress.

* The config table should use the `PascalCase` format and the db column should use the `snake_case` format, i.e `LostSpanners` and `lost_spanners`
* Add the database column:
```mysql
ALTER TABLE user_collectables ADD lost_spanners TEXT NOT NULL;
```
* Add the config data to `Config.Collectables`:
```lua
LostSpanners = {
    Enabled = true,                                     -- enable / disable the collectables
    ID = 'lost_spanners',                               -- the ID used for the MySQL database column
    Prop = 'prop_tool_adjspanner',                      -- the prop to spawn for the player to collect
    Rewards = {
        PerItem = 50,                                   -- Cash reward per item found
        Completed = 5000                                -- Cash reward for all items found
    },
    Blip = {
        ID = 402,                                       -- debug blip ID
        Color = 50,                                     -- debug blip color ID
        Scale = 1.0,                                    -- debug blip scale / size
    },
    Items = {                                           -- Collectable items list
        {
            ID = "Lost Spanner 1",                      -- Collectable ID / name
            Pos = vector3(502.10, 5604.22, 98.88)       -- Collectable coordinates
        },
        {
            ID = "Lost Spanner 2",
            Pos = vector3(2658.65,-1361.24,-20.50)
        },
        ...
    }  
}
```

* Each collectable needs an `ID` and `Pos`
* The `ID` can be any `string` or `integer`, but must be unique to that collectable

A list of Blip IDs can be found [here](https://wiki.gtanet.work/index.php?title=Blips) and a list of props [here](https://pastebin.com/2BdvLA4R).

## Performance
To reduce load, the package only renders the collectable and performs any logic on it when it is in range of the player. You can adjust the range with `Config.DrawDistance` in `config.lua`. Default is `50`. NOTE: If you have the draw distance set at a high value then items may not spawn on the surface they're supposed to on due to collisions not being loaded at great distances.

## Development Options
Setting `Config.Debug` to `true` renders blips to show the location of collectables and render some debug text to the screen to help with development. The package is written to allow it to be restarted properly with `restart esx_collectables` in the console.

##### Debug Data:
![Demo Image 2](https://i.imgur.com/oaqJkTJ.jpg)

##### Debug Blips:
![Demo Image 3](https://i.imgur.com/w3HRRPn.jpg)

## Videos

* Coming soon...

## Contributing
Pull requests welcome.

## To Do
* Add UI menu to allow players to check progress of collectables

## Legal

### License

esx_collectables - Enable collectable items on an ESX-enabled FiveM server

Copyright (C) 2020 Karl Saunders

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.