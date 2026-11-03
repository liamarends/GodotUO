# Vale House environment pass

An original family home belonging to Mara, Elias and June Vale. The move stopped
in 1987 at 6:17. Their next-house paperwork, June's drawing, packed belongings,
clock and retained upstairs portrait connect the rooms. The house keeps objects
because the family never said goodbye. No licensed photos, model packs, uploaded
meshes or fabricated asset IDs are used.

## Asset replacement checklist

| Group | Implementation |
|---|---|
| Exterior | Two pitched slate roof planes, roof seams, chimney, cornices, porch posts/canopy/deck, framed windows and curtains |
| Interior shell | Reused collision envelope, wainscoting, wallpaper motifs, water stains, bedroom partitions and signs |
| Movable collection | Twelve ID-specific models: pleated lamp, labeled box, upholstered armchair, carved-bird music box, tufted sofa, set dining table, strapped suitcase, drawer cabinet, framed mirror, segmented rocker, quilt-toned couch, inlaid writing desk |
| Interactive surfaces | Existing CarryBounds, two handles, LooseDrawer and MemoryGlass retained; movable models retain original pivots and dimensions |
| Entry | Coat stand, stopped clock and original silhouette family portrait |
| Living | Brick fireplace, cold ash, television with slow interference |
| Kitchen/utility | Cabinets, counters, sink/tap, icebox, patterned tile, radiator, service lamps and rear exit |
| Bedrooms | Bed frames, mattresses, pillows, quilts, June's handmade toys/drawing and retained-family alcove |
| Basement | Sunken floor, broad stairs, numbered storage shelves, workbench, boiler and pipes |
| Garden | Gravel loop, irregular pickets, overgrowth, mailbox, shed and streetlight pole |
| Moving company | Cab windows/windshield/bumper, cargo stripes/hubs/worklights, dispatch desk/manifest, supplies display, dolly and wearable lamp housing |
| Entity | Original quilt/doorframe design retained, stitch/tassel details added, Motor6D breathing and hunt motion; no uploaded animation IDs |
| Environmental reactions | Clean furniture footprints; a hidden family note/photo revealed when the armchair leaves; existing reactive portraits and furniture complications |

These are procedural Roblox part models, not externally authored meshes. Future
sculpted upholstery, bespoke texture maps and original recorded audio would need
external authoring. Current positional sound cues reuse the game's bundled Roblox
sounds and include location/direction subtitles; they are not custom recordings.

## Layout and collision contract

The core house remains 64 by 48 studs, floor surfaces at Y=1 and Y=14. The rear
service wing extends from Z=-24 to -60. Its cellar floor is Y=-11; sixteen shallow
steps descend in an 11-stud-wide shaft at X=26. The west outdoor return runs at
X=-43, connecting the back garden and front porch. The front entrance is 14 studs
wide; internal carry openings retain at least 10 studs of width. Large furniture
must turn for the stairs. The sealed upstairs family room opens during hunts
and closes on reset; its portraits and inscription explain the family's absence.

`EnvironmentArt` contains noncolliding, nonqueryable decoration. Walls and cover
remain under `WallsAndCover`; floors and stairs remain under `WalkableSurfaces`.
Carry movement and line-of-sight queries retain their existing filters. Decorative
pieces must not be moved into those collision folders. Existing room geometry is
retained deliberately to preserve contract positions and route choices.

Lights are localized; five original ceiling lamps cast shadows, while added
service, moon and truck lighting does not. Reduced flashing defaults on and
maintains stable illumination; subtitles still describe lamp incidents. Camera
shake remains off by default. Curtains and television animation update at 10 Hz,
with curtain distance culling.

## Builds and verification

Normal place: `rojo build roblox/default.project.json -o build/vale-house.rbxlx`.
The server constructs the property when Play starts; edit-mode emptiness is expected.

Isolated engine audit:

```text
python roblox/tests/build_studio_audit.py --rojo PATH_TO_ROJO
```

Open `build/house-audit.rbxlx`, press Play, and inspect Output for `AUDIT COMPLETE`.
This separate place injects `StudioAudit` and a test entry point; neither ships in
the normal Rojo mapping. It checks decorative collision flags, scene budgets,
all item spawn bounds, sampled furniture routes, engine pathfinding and selected
round transitions. It deliberately repositions objects/characters and shortens
deadlines. These are engine fixtures, not proof that player input, two-person
carrying, frame rate or a complete natural round works. See [TESTING](TESTING.md)
for actual outcomes and outstanding interactive checks.

Material choices follow the [Roblox material enum](https://create.roblox.com/docs/reference/engine/enums/Material).
Navigation checks use [Roblox pathfinding](https://create.roblox.com/docs/characters/pathfinding).
