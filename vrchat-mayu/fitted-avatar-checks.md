# Fitted Mayu checks

These notes describe the Windows build of the fitted Mayu scene. The Unity editor's scene visibility settings only affect the editor preview. To check what other users can see, load the exported avatar and exercise its FX animator with the expression parameters from its generated wheel.

## An unequipped muzzle

The head strap uses blendshapes to hide its strap and muzzle guard. In the earlier export its skinned renderer was enabled with both controls off. Gate the renderer on the logical OR of the existing Equipped and Muzzle Guard controls. Check five states in the exported avatar: neither, equipped only, both, guard only, then neither again. The renderer should be off, on, on, on, off. This tests the attachment itself; a screenshot alone cannot establish the identity of every floating object.

## Cake PB during a jump

On the fitted avatar the original main momentum was 0.964, the secondary inertia momentum was 0.9, and both pulls were 0.05. The fitted scene uses main pull/momentum/stiffness of 0.35/0.34/0.32 and secondary values of 0.40/0.22/0.40. Both use world-motion damping at 1. The main stretch and squish limits are 0.08 and 0.15.

In an isolated Unity Play Mode comparison, two copies of the same avatar went through the same half-meter jump. We tracked 24 transforms on each rig. The maximum displacement relative to the avatar was 0.0848 m with the original settings and 0.00020 m with the fitted settings. This checks a vertical jump, not every possible IK pose or contact. World-motion damping targets locomotion while retaining motion from the skeleton. [VRChat PhysBones documentation](https://creators.vrchat.com/common-components/physbones/)

## Earrings and handheld props

Fit accessory anchors to the surface and skeleton that actually ship on the avatar. A single ear joint passed an earlier hierarchy check but placed the earrings incorrectly in VRChat. For each cross and stud group, sample the weights and bind poses at its own ear-rim attachment point. Use the same coordinate frame as the body renderer. Rotate the actual ear bones and measure how far the jewelry mount moves relative to that point. In the fitted Unity scene the maximum measured separation change was under 0.5 mm. Inspect the front, side, and tilted views as a separate check of placement. Choose a point on the glass neck for the handheld prop, then solve the parent-constraint offset separately for each palm. Validate both sources in the export by rotating each wrist and checking that the grip follows it.

## Inner-thigh clearance

Measure each garment separately. Include shorts, because their exposed skin must still be visible below the hem. Skin both meshes in the same coordinate system and compare the body surface to the fabric along rays from the corresponding leg. A skin-colored pixel in front of pants is not sufficient evidence of clipping: the nearer leg may legitimately hide part of the farther garment.

The normal body has a separate correction for Comfy Pants, AD Nightwear Shorts, DNO Tech Pants, Blu Shortshorts, Thrift Baggy Pants, Soft Lounge Shorts, and SoftBoy Baggy Sweats. Check against standing and crouched poses. Also verify each control on the actual exported FX controller: an edit to a nested prefab's managed-reference list can appear correct in the editor but fail to drive the correction in a build.


A centerline clearance test missed inner-thigh clipping visible in VRChat. For the Windows normal body, use a separate UV coverage channel for each garment, driven by its wheel control. Compare the body and fabric from multiple angles at two elevations, reject hits from the opposite leg, and sample again after hiding the first layer of exposed skin. Check the mask with the normal and oil body materials because the FX controller can swap materials after a rebind. The desktop shader is specific to the Windows build.

## Wheel switches that stay on

The fitted Windows build submitted before the November 4 fix switched Baggy Sweats on but left its mesh visible when the expression parameter returned to zero. The same issue affected Emo Hair, piercings, glasses, material swaps, and other wheel items. Inspect the finished controller, including layers added after VRCFury processes the avatar. The existing states used Write Defaults on, while the custom head-strap states used Write Defaults off. Match the custom states to the controller and give garment visibility an explicit off clip. [VRCFury's Write Defaults guide](https://vrcfury.com/broken-wd/)

Verify each wheel switch on the exported avatar by recording the original state, switching on, switching off, then comparing against the original. The corrected PC build restored all 117 switches that produced a measurable change in the FX test. Three bong switches had animated exits and passed when allowed to finish. The sweep also encountered 54 controls with no observable change or a zero-valued selector and 54 outside the FX controller. Those need an appropriate input, playable layer, or in-client test.

The coverage mask must also have a physical boundary on the body mesh. A painted texture alone hid parts of the waist and toes on Baggy Sweats. Store thigh eligibility per vertex and use it in the clothing shader before sampling the garment mask. In the corrected PC build, four full-body on/off comparisons found no removed pixels above the hip or below the knee. Remaining close body/fabric intersections in the inner-thigh diagnostic are a separate fit check.
