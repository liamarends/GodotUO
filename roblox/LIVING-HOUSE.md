# Living-house playable slice

“You and your friends are movers. The house does not want to move on.”

This update builds on the existing generated house, authoritative carrying,
rescue/solo recovery, seven-minute loop and fair shop. It adds specific contracts,
family keepsakes, deliberate departure and readable house reactions. The Duvet
now wears a doorframe and mismatched quilt patches, with a two-knock/drag signature,
a two-second waking pause, existing attack windup, and 24 seconds between hunts.
Sound uses bundled engine files with pitch/timing variations, not uploaded assets.

## Controls and choices

- E/touch: grab an orange handle, open a memory door, hide or help a teammate.
- R/T: turn; U: toggle lift readiness (both movers must agree on heavy loads).
- G: put down; J: recover to a nearby clear position, at most 12 studs away.
- Q/touch on furniture: secure it for 30 seconds, closing a loose drawer.
- X/Tools: pings, free equipment, crew status, departure and accessibility.
- Z/N/M: Hold / Turn / Put down pings; 2s rate limit. Repeated pings disturb doors.
- V: use chosen equipment. Decoy redirects sound unless a mover is visible;
  wedge holds a nearby memory door open 45s; dolly passively improves solo drag.
  Exchange equipment at the truck; swapping never clears the existing cooldown.

The orange ground-floor boards are the short, creaky path. The longer teal carpet
route avoids their noise multiplier. Doors can be opened freely and wedged; their
slow swing stops near movers or furniture. There are no rearranging walls or paid
routes. House reactions have cooldowns and nearest-room light changes restore.

A first server contract teaches downstairs delivery with one object complication,
introduced after 40s. Subsequent contracts shuffle required item IDs and select
three complications across the house; no object gets multiple complications.
Prompts and floating labels name each countermeasure before it activates.

| Object | Behavior | Countermeasure |
|---|---|---|
| Rocker | Rocks and creaks when abandoned | Secure it or keep carrying |
| Music box | Plays when a lifted load pitches on stairs | Lower or secure it |
| Mirror | Amber glass warns of a nearby hunting silhouette | Watch the warning, break sight |
| Nightstand | Drawer slides open on rapid consecutive turns | Pause between turns or secure |
| Armchair | Returns home out of avatar sight | Watch it or secure for 30s |

The house may also return an unattended misplaced box out of avatar sight.
Observation uses server avatar-facing/line-of-sight checks; it does not pretend
to know the camera direction. The mirror is a stylized warning, not a real-time
reflection render. The dollies and gear are functional mechanics with part-based
placeholders; custom audio production and authored animations remain polish work.

## Contract and rewards

The start count still sets 4/6/8/10 deliveries, now particular named furniture.
Optional possessions reveal original family notes. Depart only when all remaining
movers are aboard and have individually approved in Tools; votes expire in 12s
and clear when leaving the bay. Partial early departure is a valid completed
attempt, with a reduced cosmetic payout. No one can accidentally end a shift by
walking into the truck. A downed teammate must be rescued first.

Qualifying participants receive one stamp per required delivery, two per optional
keepsake, and four for a completed contract. At 12 stamps, equip the free Memory
Keeper badge through Tools while at the lobby supply area. Stamps are cosmetic
only, recorded in the same idempotent completion transaction as free boost progress.
Wins, losses and early departures still require meaningful participation.

The existing two 3-use products and cosmetic pass are unchanged. Uses never
expire; one optional team boost, no stacking, server receipt grants, real price
lookup, IDs defaulting to zero and isolated Studio memory mode are preserved.
See [account setup](README.md) before enabling real commerce. There are no new
paid items, maps, roles, checkpoints or saves required to play.

## Presentation and limits

Tools includes subtitles, standard/brighter darkness, and OFF/LOW/FULL camera
shake (OFF initially). Important sound captions include relative direction and
distance. The touch controls are scrollable; the carry pose is procedural and
local, with no animation asset downloads. The report names team deliveries,
keepsakes, rescues, stamps and the loudest accident without blaming a teammate.
Crew status remains available to downed movers and late joiners.

Room rearrangements and additional houses are intentionally deferred until this
handcrafted slice has multiplayer playtest evidence, as requested by the brief.
No claim of “10 times better,” final balance, mobile performance or finished audio
quality is made from static checks.

## Verification

The exact checks and outstanding player scenarios are in [TESTING.md](TESTING.md).
Server interaction validation follows Roblox's [client-server boundary guidance](https://create.roblox.com/docs/scripting/security/client-server-boundary).
Furniture clearance checks use [WorldRoot spatial queries](https://create.roblox.com/docs/reference/engine/classes/WorldRoot).
