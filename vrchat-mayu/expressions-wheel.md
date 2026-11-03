# Mayu Blue Expressions wheel

Open `Assets/Mayu Blue - Wheel.unity` in the Mayu Blue project. This Windows scene extends the recolored Tora with the compatible items from the models and assets download folder. The earlier `Assets/Mayu Blue.unity` scene is available separately.

## Where to find the controls

Open **Expressions** in VRChat. These paths were read from the merged menu during the Windows build. **Next** is a real page in the wheel. Each outfit submenu has controls for its individual pieces.

| Item | Path from Expressions |
| --- | --- |
| Emo Hair | Appearance → Hair → Emo Hair |
| Round Glasses | Clothes → Accessories → Glasses → On |
| Gothic Accessories | Clothes → Accessories → Goth |
| 9 Volt Battery | Items → Gothic → 9 Volt |
| Blu Shortshorts | Clothes → Next → ♡Blu♡ → Shortshorts → Toggle |
| Mayu HeadStrap | Clothes → Next → HeadStrap → Equipped |
| Thrift Clothes | Clothes → Next → Thrift Clothes |
| Soft Lounge | Clothes → Next → Soft Lounge |
| SoftBoy Fit | Clothes → Next → SoftBoy Fit |
| Comfy Sweatshirt outfit | Next → [SoapBlocc] → ComfyOutfit |
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
