# Mayu Blue Expressions wheel

Open `Assets/Mayu Blue - Wheel.unity` in the Mayu Blue project. This Windows scene extends the recolored Tora with the compatible items from the models and assets download folder. The earlier `Assets/Mayu Blue.unity` scene is available separately.

## Where to find the controls

Open **Expressions** in VRChat. These paths were read from the merged menu during the Windows build. **Next** is a real page in the wheel. Each outfit submenu has controls for its individual pieces.

| Item | Path from Expressions |
| --- | --- |
| Emo Hair | Emo Hair (first item on the main page) |
| Round Glasses | Clothes → Accessories → Glasses → On |
| Gothic Accessories | Clothes → Accessories → Goth |
| 9 Volt Battery | Items → Gothic → 9 Volt |
| Blu Shortshorts | Clothes → Next → ♡Blu♡ → Shortshorts → Toggle |
| Mayu HeadStrap | Clothes → Next → HeadStrap → Equipped |
| Thrift Clothes | Clothes → Next → Thrift Clothes |
| Soft Lounge | Clothes → Next → Soft Lounge |
| SoftBoy Fit | Clothes → Next → SoftBoy Fit |
| Comfy Sweatshirt outfit | Clothes → Fishbone Sweatshirt / Comfy Pants / Comfy Cat Print |
| Ripper Claw-X, both arms | Next → Cyber Arm → Equip Ripper Claws |
| GhostStep Mk.IV | Next → Cyber Legs → Equip GhostStep |
| The Cheshire | Next → TheChesh → Chesh On |
| Vio prop | Next → Vio → Bong → Toggle |

## How the setup works

1. Choose one compatible prefab per item. This scene uses the PC Mayu prop, the regular Soft Lounge rig and the two-arm Ripper Claw variant. Keep the maker's VRCFury armature links, controllers, material switches and expression submenus together. The existing project provides VRCFury.
2. For a wearable with an existing equip action, use that action. For a prop that only has appearance controls, create a VRCFury toggle, give it a slash-separated menu path and add an **Object Toggle** action for the objects it should show. The new hair control starts off. It follows the head bone. The cyber-limb switches also drive matching hide blendshapes on the Tora body. The creators provide body alpha masks for more precise coverage if an extreme pose exposes clipping. [VRCFury toggle guide](https://vrcfury.com/components/toggle/)
3. Start with the SDK's Windows build, then inspect the menu after VRCFury has merged it. VRChat allows eight entries per menu. This build's audit traversed the submenu tree, recorded 356 leaf controls, found no page over eight entries and found no unresolved named primary control parameter. Saved toggle values can persist across avatar changes, so test both on and off states. [VRChat Expressions Menu and Controls](https://creators.vrchat.com/avatars/expression-menu-and-controls/)
4. Wear the local test avatar and check glasses alignment, hair during head turns, each outfit during crouches, and each cyber limb independently. Check the hand-held prop and its interactions in the client. The editor menu audit checks control wiring; these movement checks require a wear test.

## Version-specific exception

Mayu Adult 0.9 is an FBX patch. Its creator specifies a clean Mayu 2.0 or 2.0.1 source. The active Tora Death Edit is a different, modified model, so that patch was omitted. The Cheshire is a separate prefab with its own menu control.

## Windows build result

The VRChat SDK completed the build. The UnityFS bundle measures 70,835,955 bytes on disk and 346,321,432 bytes of uncompressed block data. The local test copy was verified by SHA-256 against the build. In the PC client, open **Avatars → SDK Test Avatars → Mayu Blue - Wheel**, then open **Expressions**. The compiled FX controller's Ripper Claws action activates the arms mesh and the wrist and elbow hide shapes. The GhostStep action activates the legs and screen meshes and the knee and leg-fluff hide shapes. In-client interaction, fit through the full range of motion, and publication remain untested. [VRChat local avatar testing](https://creators.vrchat.com/avatars/creating-your-first-avatar/)
## Fitted wheel revision

Open `Assets/Mayu Blue - Wheel Fitted.unity` for the fitted version. The PC local test entry **Mayu Blue - Wheel** now points to this build. The earlier wheel scene is also available.

The original Mayu Tora PC prefab supplied the target hip contour. Matching the corresponding UV surface samples preserves the edited Tora’s rig and blendshapes. At 0.67 m above the avatar origin the earlier rear contour was 0.1586 m behind the origin. Both the stock mesh and the fitted export measure approximately 0.1377 m there. The glasses were moved 0.061 m back along the avatar’s forward axis through a head-mounted offset so their existing control can still move them relative to the new position.

The Ripper Claws and GhostStep equip actions drive separate alpha cutouts using the creators’ masks. Front renders of the exported body verified arms only, legs only, both on and both off. Outfit geometry was inspected at rest and with the head, elbows and knees rotated. A live VRChat wear test is still needed for tracking, PhysBones and interactive prop constraints.

## Clothing repair and first-page hair

The Windows update was verified on the existing private listing, version 7. In the fitted avatar, **Emo Hair** is the first control in Expressions. **Clothes** contains independent **Fishbone Sweatshirt** and **Comfy Pants** switches, plus **Comfy Cat Print**. The original outfit imported an FX controller with animation paths rooted at `[S]OutfitFBX`; the fitted avatar uses `[S]OutfitPrefab`. A menu label alone could not establish that its animations reached the correct renderers. The repaired visibility controls reference the actual shirt and pants objects. Both start off.

The pants switch also controls a mask projected from the Mayu body mesh onto its UV atlas. Its blue channel hides the clothed inner-thigh area below the waistband and above the cuffs. The red and green channels still handle the cyber arms and legs independently. Check the packed avatar, including a bent-leg pose, before publishing an outfit repair.
