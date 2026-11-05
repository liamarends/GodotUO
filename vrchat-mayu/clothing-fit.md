# Clothing fit on Kai’s Mayu

The fitted PC scene uses separate meshes for its seven pants and shorts. Each garment’s wheel switch also drives a body blendshape that makes room under the fabric. All seven body transparency masks and the Comfy Pants coverage decal channel are clear. This matters for short hems and for saved outfits with more than one switch enabled.

## Diagnose the symptom

- **Floor or wall visible through a thigh:** Turn the garment off and inspect the body alone. If the skin disappears when a material parameter changes, inspect the alpha mask. A mask shared across a UV island can remove visible skin well beyond the hem.
- **Skin shows through intact fabric:** Compare a standing view with a crouch and an asymmetric knee lift. A defect at rest calls for a garment shape adjustment. A defect that grows with joint angle also calls for checking the weights on each side of the seam.
- **Skin visible through a designed opening:** Inspect the garment’s original texture and silhouette. A cutout in the fabric and a tail visible between the legs can both look like clipping in a front view.

## Reproduce the fit

1. Load a known PC export, drive the pants through their actual wheel parameters, and isolate one garment at a time on the normal body. Verify the source renderer’s triangle order and bind vertices match the exported garment before applying vertex changes.
2. Check the rig before editing the surface. Armature Link attaches corresponding clothing bones to the avatar. Each mesh still has its own weights and bind poses. For an outfit with matching authored body shape keys, Blendshape Link can keep the garment key in step with the body control. [VRCFury Armature Link](https://vrcfury.com/components/armature-link/) · [VRCFury Blendshape Link](https://vrcfury.com/components/other/#blendshape-link)
3. Compare the body and fabric in the same coordinate system at each pose. Unity can bake a snapshot of a skinned renderer. For this fit, record the bone matrices as well, so a millimetre of correction in a posed thigh can be mapped back to the right garment vertex regardless of import scale. [Unity BakeMesh](https://docs.unity3d.com/2022.3/Documentation/ScriptReference/SkinnedMeshRenderer.BakeMesh.html) · [Unity bind poses](https://docs.unity3d.com/2022.3/Documentation/ScriptReference/Mesh-bindposes.html)
4. For close-fitting fabric, sample the surface triangle underneath it. Interpolate the body weights at that point and test whether those weights improve the garment’s motion on its existing skeleton. Retain the authored weights where they work better. Use a small outward adjustment for fabric that still penetrates. Blend corrections across neighboring vertices and coincident UV-seam vertices. Preserve material slots, UVs, and four normalized influences per fitted vertex. [Blender Shrinkwrap](https://docs.blender.org/manual/sr/4.5/modeling/modifiers/deform/shrinkwrap.html) · [Unity mesh weights](https://docs.unity3d.com/2022.3/Documentation/ScriptReference/Mesh.SetBoneWeights.html)
5. Where fabric still crosses skin, correct the body only while that garment is worn. The fitted body keeps all 364 existing shape names. Its base vertex stream and triangle indices match the previous normal body byte for byte. Retain the original waistband and outer-leg contours when adjusting the inner panels of long pants. The three shorts kept their original cut and weights. DNO Tech also kept its original garment fit because reshaping it made its inner-thigh result worse.
6. Save the fitted meshes as Unity assets, assign them in the fitted scene, and repeat the checks on an SDK export. The fitted assets are under `Assets/Mayu Wheel Fit/Garments` in the local Unity project. The local measurement and fitting scripts are under `Tools/GarmentFit`. The saved meshes work independently of the measurement cache.

## Validation

The test compares eleven poses, including standing, crouching, crossing and spreading the legs, lifting either knee, and taking asymmetric strides. It samples eight camera angles per garment and pose. The contour refinement used eight poses. The two asymmetric strides and the shallow squat were reserved from that refinement to check how the fit transfers to different movements.

The before/after check counts **suspected visible inner-thigh poke-through pixels**, summed across all views at a fixed 150 × 180 resolution. A flagged pixel requires fabric on the same side of the avatar, visible skin 1–25 mm in front of that fabric, and compatible surface directions. This geometric test cannot identify a transparent opening painted into a garment’s texture. Inspect original-material previews alongside it. The counts express how often the sampled views flag an overlap. They cannot establish a universal clipping rate in VRChat.

| Garment | Previous PC export | Final PC export | Reserved poses, previous → final |
| --- | ---: | ---: | ---: |
| AD Nightwear Shorts | 352 | 6 | 108 → 6 |
| Comfy Pants | 4,204 | 55 | 12 → 53 |
| Blu Shortshorts | 3,153 | 2 | 204 → 0 |
| DNO Tech Pants | 185 | 41 | 37 → 37 |
| Soft Lounge Shorts | 7,069 | 10 | 393 → 6 |
| SoftBoy Baggy Sweats | 8,922 | 23 | 666 → 5 |
| Thrift Baggy Pants | 4,141 | 8 | 9 → 0 |
| **Total** | **28,026** | **145** | **1,429 → 107** |

Across 616 garment/pose/view combinations, the final PC export had 99.48% fewer flags. All seven garments recorded zero flags in the standing pose. A second check that allowed up to 50 mm of depth separation counted 30,941 flags before and 740 after. Comfy Pants still recorded 53 flags across the three reserved poses, up from 12, despite the large reduction across all eleven poses. In the full-material comparison, the loose Comfy waistband also shows a little space at the sides.

The final export passed the clothing wheel on/off checks. The motion tests use the normal Windows avatar. Live IK, standalone Quest, overlapping outfits, and every possible body slider combination remain outside these measurements. For an in-client check, take a stride and a shallow squat in Comfy Pants, then try Baggy Sweats with one knee lifted. Compare the inner seams and the shorts hems from front and three-quarter views.

## Waist silhouette correction

The earlier fit in the table above produced pinches visible above the Blu shorts, Baggy Sweats and Comfy Pants. The combined clothing shape moved some waist vertices by approximately 10–12 cm. Looking only at pixels where skin appeared through cloth had rewarded an unnatural waist.

The current fitted PC scene keeps the original waist and upper hip positions when a clothing toggle switches on. The influence fades into the inner thigh below the hip joints. Each individual garment’s total neutral-pose adjustment is capped at 12 mm, including the older fit baked into its shape. All seven shapes in the exported mesh measured 0 mm movement in the protected region. The clothing wheel round-trip test passed. A front and elevated-view comparison against the PC bundle built just before the reported screenshots showed the waist filling the bands again.

This changes the clipping tradeoff. The same 616 geometric comparisons now flag 19,372 inner-thigh pixel samples, compared with 28,026 in the original baseline and 145 in the superseded, over-compressed fit. Bent poses can still show skin through fabric. The current change affects the normal body fit only. The shorts retain their original pale distressed edge. A separate simulation of up to 4 mm of garment-panel expansion offered a modest improvement and was left out of the saved scene.

The linked tutorial’s pants section starts at 3:47, with the clipping demonstration at 4:32 and a pose test at 5:05. For Mayu, verify both the clothed leg and the exposed waist while cycling the relevant switch. [Rexouium clothing tutorial, pants clipping chapter](https://www.youtube.com/watch?v=RQRJN5fGFjs&t=272s)

## Original Comfy Pants and SoftBoy Baggy Sweats — restoration baseline

Before the conservative correction below, the fitted scene used the original `[S]OutfitFBX.fbx` Pants mesh and `softboymayu.fbx` Baggy Sweats mesh. The two wheel switches still control garment visibility. Their two custom body-fit shapes have zero vertex displacement. The earlier clipping measurements for these garments describe superseded versions. Existing clipping in an original garment can still occur when it is worn. The other 362 body shapes and the five other garment mesh assignments matched the pre-restore backup.

## Final conservative PC clothing repair, 2026-11-04

The tested candidate has been promoted into `Assets/Mayu Blue - Wheel Fitted.unity`. The prior disk scene, unsaved editor scene, and Windows bundle were backed up before promotion. The existing avatar blueprint and private listing were preserved. The SDK Builder is open for the user's manual **Build & Publish**; this repair has not been uploaded.

Eleven garment meshes received small corrections. The exported body measured **0 mm change** across all 25 garment cases and five poses per case. Maximum garment movement was 6.00005 mm, within floating-point tolerance of the **6 mm cap**. The eleven saved garment meshes retain their triangle indices and skinning matrices. Original-material previews show the front inner-thigh patches cleared on Comfy Pants and SoftBoy Baggy Sweats in the sampled view. The body shape and overall clothing silhouette were preserved.

The SDK build, all 25 garment on/off round trips, and four independent top/pants combinations passed. Source validation initially required the SDK's Read/Write, Legacy Blendshape Normals, and Streaming Mip Maps import fixes. Import metadata was backed up before those SDK-provided fixes were applied; validation and the rebuilt export then passed. The normals import changed the unmodified Thrift CropTop's vertex deduplication from 5,450 to 5,432 vertices. Comparing canonicalized triangle corners verified the same triangle surfaces and skinning matrices in all five poses, despite changed index ordering.

### Correction to the cuff diagnosis

The previously reported Comfy Pants cuff patch is an opening in the **original mesh**, not a new hole from the fitting corrections. Ray tests at the visible patch found no covering fabric triangle; boundary inspection confirmed all six original boundary loops and identical original/candidate triangle indices. Those original openings were retained to preserve the garment design. A separate cuff-weight-transfer experiment was visually tested and discarded; it is not in the promoted scene.

### Limits and publishing state

These tests cover five poses per clothing case, the exported toggle round trips, and four independent outfit combinations. They do not prove zero clipping for every live IK movement, overlapping outfit, or body-slider combination. The SDK still reports Very Poor performance and PhysBone cyclic-dependency warnings; the Build & Publish button is enabled. The clothing repair does not address those separate warnings.

Local evidence is under `Mayu patch verification/PC clothing candidate 2026-11-04`, including exported geometry verification, toggle/photo logs, the actual-material comparison, the tested bundle, and pre-promotion backups. The fitted scene and Windows bundle hashes match the verified candidate copies.

Quest work remains set aside at the user's request. Its saved candidate was not promoted or uploaded.


## Paw palette, alternate speech, and fur shading — 2026-11-04

The fitted PC scene now uses dusty pink `#D58FA8` hand/foot pads and warm ivory `#E9DDC7` claws. Poiyomi's RGBA color masking reuses the avatar's existing Shine map (red: pads, green: claws). The original blue-and-cream albedo texture was not repainted. Preserve the alpha-channel normal-map configuration when adding these masks, and refresh texture keywords before compiling a locked material.

The alternate body has a dedicated 15-state FX speech controller driven by VRChat's global `Viseme` integer. Every state writes all 15 mouth shapes, and Unity Playables tests passed all states plus returns to silence. The expression-link renderer reference was also checked and explicitly serialized. An SDK export containing the speech/color changes passed before the final material-only shading correction. Live microphone behavior still needs an in-client check.

The hard exterior fur patch came from sampling the shadow maps at the tiny constant-color UV swatch. An added UV channel projects the normal body's shadow coordinates onto the alternate patch while leaving geometry, skinning, base albedo UVs, and detail-color UVs unchanged. The mirrored atlas needs a consistent UV half to avoid interpolation across unrelated islands. The adjacent detail material uses those same shadow coordinates while retaining its original color texture and UV channel.

A material clone must be saved as an asset before unlocking/recompiling its optimized shader. An unsaved clone can retain the source's compiled constants even when its displayed properties change. Explicitly checking unlock success and recompiling the saved material removed the remaining pale border in the same-lighting preview. The normal and alternate body previews now show the same blue-and-cream palette. Their different geometry still produces different natural shadows.

Backups, source helper, speech verification and before/after previews are saved locally under `Mayu patch verification/Pink pads and speech`. The earlier test bundle predates the final material correction; rebuild from the saved fitted scene for upload. No upload was performed.
