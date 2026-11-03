# Mayu Blue • Windows avatar setup

## Open the working project
Add the **Mayu Blue** folder as an existing project in VRChat Creator Companion. The project root contains `Assets`, `Packages`, and `ProjectSettings` side by side. The supplied Death Mayu 4.0 archive is a whole project. Dropping that folder inside another project's `Assets` makes Unity treat its embedded SDK, package sources and old Library as avatar content. The bundled `Assets/PLAY ME.mp4` shows the Creator Companion project-list workflow.

This copy targets Unity 2022.3.22f1 and Windows. Its embedded versions include VRChat Avatars/Base 3.10.3, Poiyomi Toon 9.3.64, VRCFury 1.1339.0, Modular Avatar 1.17.1, NDMF 1.13.1, Azuki prefabs 1.4.9, GoGo Loco 1.8.6 and Gesture Manager 3.9.8. These are the project's versions. Check VRChat's supported editor version before migrating. [VRChat Unity version](https://creators.vrchat.com/sdk/upgrade/current-unity-version/)

## Reproduce the blue Tora
The source scene is `Assets/OPEN ME!.unity`. The chosen model is **3.0 Tora Death Edit**. Its standard and oil body materials share `Tora_Base_color_1001.png`. The corresponding head materials use `Tora_Base_color_1002.png`. The maps live under `Assets/AzukiTiger/VRC Mayu Avatar Bundle/Avatar/Textures`. Preserve each map's .meta and alpha when editing a project copy. This keeps the material links intact through material swaps.

The reference palette used here is powder blue (#B9CDE6), ivory (#F5EDE2) and stripe blue (#749DD8). The recolor follows existing UV islands and preserves the texture shading and antialiased edges. Compare the forehead with hair hidden, then compare the chest spots, paws, back stripes and tail tip under both bright and dim lighting. The blue crown fading to ivory tips is a separate visual check when the layered hairstyle is available. Azuki also provides a Substance Painter workflow for edits to the shape of the markings. [Mayu texture resources](https://mayu.azuki.tech/avatar/texturing/substance-painter)

## Recover linked accessories
The supplied scene and Tora prefab reference a Soup prefab with GUID `c4f516285ab17404a9eb35d9785caf3e`. An older, similarly named prefab inside the archive has another GUID. The matching version was present in the separately installed package. Restore missing assets with their original .meta files and skip GUIDs already in the project. Check the prefab connections in Unity before adding anything to the hierarchy a second time.

## Test before uploading
Open the prepared single-avatar scene, select Mayu Blue in **VRChat SDK → Show Control Panel → Builder**, and resolve any blocking validation messages. For a new personal avatar, check that the Pipeline Manager blueprint ID is empty before its first upload. Use **Build & Test** and select the avatar from **SDK Test Avatars** in the Windows VRChat client. Check the view position, blink, visemes, gestures, clothing toggles, locomotion and tail physics. Check performance and upload size separately because local testing does not enforce the upload size limit. Upload from the SDK once those checks pass and select the intended visibility. [VRChat avatar testing](https://creators.vrchat.com/avatars/creating-your-first-avatar/) · [Avatar size limits](https://creators.vrchat.com/avatars/avatar-size-limits/)
