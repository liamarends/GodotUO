# Mayu Blue • Windows avatar setup

## Open the working project
Add the **Mayu Blue** folder as an existing project in VRChat Creator Companion. The project root contains `Assets`, `Packages`, and `ProjectSettings` side by side. The supplied Death Mayu 4.0 archive is a whole project. Dropping that folder inside another project's `Assets` makes Unity treat its embedded SDK, package sources and old Library as avatar content. The bundled `Assets/PLAY ME.mp4` shows the Creator Companion project-list workflow.

This copy targets Unity 2022.3.22f1 and Windows. Its embedded versions include VRChat Avatars/Base 3.10.3, Poiyomi Toon 9.3.64, VRCFury 1.1339.0, Modular Avatar 1.17.1, NDMF 1.13.1, Azuki prefabs 1.4.9, GoGo Loco 1.8.6 and Gesture Manager 3.9.8. These are the project's versions. Check VRChat's supported editor version before migrating. [VRChat Unity version](https://creators.vrchat.com/sdk/upgrade/current-unity-version/)

## Reproduce the blue Tora
The source scene is `Assets/OPEN ME!.unity`. The chosen model is **3.0 Tora Death Edit**. Its standard and oil body materials share `Tora_Base_color_1001.png`. The corresponding head materials use `Tora_Base_color_1002.png`. The maps live under `Assets/AzukiTiger/VRC Mayu Avatar Bundle/Avatar/Textures`. Preserve each map's .meta and alpha when editing a project copy. This keeps the material links intact through material swaps.

The reference palette used here is powder blue (#B9CDE6), ivory (#F5EDE2) and stripe blue (#749DD8). The recolor follows existing UV islands and preserves the texture shading and antialiased edges. Compare the exposed forehead, then compare the chest spots, paws, back stripes and tail tip under both bright and dim lighting. Azuki also provides a Substance Painter workflow for edits to the shape of the markings. [Mayu texture resources](https://mayu.azuki.tech/avatar/texturing/substance-painter)

## Recover linked accessories
The supplied scene and Tora prefab reference a Soup prefab with GUID `c4f516285ab17404a9eb35d9785caf3e`. Unity reassigned this prefab's ID and the VRChat SDK DLL's ID when the entire archived project was imported inside another project's Assets folder. In that state the model could appear in Unity while the SDK detected zero avatar descriptors. Restoring the original Assets, Packages and ProjectSettings from the archive, including their original .meta files, fixed both references. The working scene then loaded all four source descriptors and enabled only Mayu Blue. The original Soup prefab is already linked, so keep a single copy. If Unity crashes on its first FBX import, this project also shipped a Library cache built with the same editor version. Reusing its Artifacts, ArtifactDB and SourceAssetDB allowed that import to finish.

## Test before uploading
Open the prepared single-avatar scene, select Mayu Blue in **VRChat SDK → Show Control Panel → Builder**, and resolve any blocking validation messages. For a new personal avatar, check that the Pipeline Manager blueprint ID is empty before its first upload. Use **Build & Test** and select the avatar from **SDK Test Avatars** in the Windows VRChat client. Check the view position, blink, visemes, gestures, clothing toggles, locomotion and tail physics. Check performance and upload size separately because local testing does not enforce the upload size limit. Upload from the SDK once those checks pass and select the intended visibility. [VRChat avatar testing](https://creators.vrchat.com/avatars/creating-your-first-avatar/) · [Avatar size limits](https://creators.vrchat.com/avatars/avatar-size-limits/)

## Finished Windows scene

Open `Assets/Mayu Blue.unity` in the **Mayu Blue** project. Select **Mayu Blue** in the SDK Builder. The regular Tora is the active avatar. Its saved scene has a cleared blueprint ID and the source clothing meshes initially hidden under `Clothes Updated`.

The body map adds blue wrist markings, paired chest spots and ivory lower feet. To place the spots accurately, bake the body in its rest pose and project the paint through the body material's triangle UVs. Check the result on the mesh. Mirrored UV islands and texture gutters can affect both paws. The body uses the Tora stripe shapes. The default head uses one pair of Tora ears. Both ear styles have blue outer fur, dusty-pink interiors and ivory tufts. To isolate the ear colors on the shared head atlases, paint the UV islands for the outer shell, inner bowl and furnishings separately. Check the front, side and back in Unity because the inner bowl faces sideways. The scene uses the hairless base head. The head bone is available for the owner's future hairstyle.

## Verified build

Unity 2022.3.22f1 and VRChat Avatars SDK 3.10.3 completed the Windows build and SDK validation. In batch mode the SDK performance tables needed `AvatarPerformanceStats.Initialize()` before validation. Two outfit materials, Underwear and Cute Hoodie V2, needed Poiyomi locking before export.

The verified output is `Builds/Windows/Mayu Blue.vrca`. It contains 40,893,309 bytes on disk and 216,903,804 bytes of uncompressed UnityFS block data. Both are below the published PC limits. A byte-identical copy was installed in VRChat's local test-avatar folder under the name **Mayu Blue**. In-client motion, expressions and outfit toggles still need a wear test. Online publication is a separate step. [VRChat avatar size limits](https://creators.vrchat.com/avatars/avatar-size-limits/)

## Add-on wheel

The separate `Assets/Mayu Blue - Wheel.unity` scene includes the fitted accessories, outfits, optional hair and props. The guide lists their menu locations, including automatically generated **Next** pages. [Expressions wheel setup and item paths](expressions-wheel.md)
