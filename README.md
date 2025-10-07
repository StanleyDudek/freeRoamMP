# freeRoamMP
A BeamMP `Client mod <=> Server plugin` pair enabling a stock freeroam gamemode on your BeamMP server!

## Missions and scenarios including
- delivery
- police
- stunts
- timetrials
- garage2garage
- fuel stations
- bus routes
- drift zones
- 1-Player vs ai street races
- 1-Player vs ai drag races
- pretty much all other map points of interests

## Under the hood
- traffic light sync **(new!)**
- red light / speed trap broadcasts **(new!)**
- syncing prefab loading and collision across clients
- syncing the active states (shown or hidden) of vehicles
- nametag visibility supression for many spawnables including traffic to limit spam

## Notes
- your server will need a very high MaxCars setting, I recommend **at least 75-100**, and a plugin to manage this if you are concerned, some missions can spawn many, many objects
- while most things sync (primarily vehicles and collidables), you will find that some things for other players like the checkpoints and item pickups and drag scoreboard are not processed, most are unnecessary, but some are of interest to get working (like the drag scoreboard / drag tree) which I hope to one day refine
- while this does not yet have a party system, and things like drag races and ai races will be against computer opponents while on the server, despite not being able to race head to head you can compare your drag time sheets, et cetera
- you can do drift zones and some missions and races pretty smoothly with friends, especially with staggered starts
- you'll probably find that you need to keep an eye out as the world changes more now, someone else's obstacles can show up suddenly
- this mod is not very friendly to low performance computers

Install is simple, grab a [release](https://github.com/StanleyDudek/freeRoamMP/releases) .zip, place it next to your BeamMP Server executable, and unpack it.

<img width="2552" height="1348" alt="image" src="https://github.com/user-attachments/assets/93367c9c-e2bf-452a-bac5-c2467ac27a22" />

###### Proudly made without AI, ever.
