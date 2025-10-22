# freeRoamMP
A BeamMP `Client mod <=> Server plugin` pair enabling a stock freeroam gamemode on your BeamMP server!

## Mission and scenario points of interests including
- a run for life
- bus routes
- collection
- crash test
- crawl
- delivery
- derby
- drag
- drift and drift zones
- evade
- fuel stations
- garage to garage
- offroad
- police
- rally
- street races
- stunts
- time trials
- and even more appear to be unlockable with progression (base game tracking system)

## Under the hood
- traffic count balancing **(new!)**
- MP UI app injection into missions and scenarios **(improved!)**
- traffic light sync
- red light / speed trap broadcasts
- syncing prefab loading and collision across clients
- syncing the active states (shown or hidden) of vehicles
- nametag visibility and switch-to supression for many spawnables including traffic to limit spam and facilitate tabbing through vehicles more easily

## Requirement
- your server will need a very high MaxCars setting, I recommend **at least 75-100**
  - A plugin to manage MaxCars may be useful if you are concerned; some missions can spawn many, many objects

## Notes
- while most things sync (primarily vehicles and collidables), you will find that some things for other players like the checkpoints and item pickups are not processed, most are unnecessary, but some are of interest to get working (like the drag tree ) which I hope to one day refine
- this does not (yet?) have a party system, and things like drag races and ai races will be against computer opponents while on the server, time sheet comparison hopefully coming soon
- you can do drift zones, rally, bus routes, time trials, missions and races pretty smoothly if you coordinate with friends, especially with staggered starts
- you'll probably find that you need to keep an eye out as the world changes more now, someone else's obstacles can show up suddenly
- this mod is not very friendly to low performance computers, but I try to keep the impact as minimal as possible

Install is simple, grab a [release](https://github.com/StanleyDudek/freeRoamMP/releases) .zip, place it next to your BeamMP Server executable, and unpack it.

<img width="2552" height="1348" alt="image" src="https://github.com/user-attachments/assets/93367c9c-e2bf-452a-bac5-c2467ac27a22" />

###### Proudly made without AI, ever.
