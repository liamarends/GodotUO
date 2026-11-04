# Quest clothing fit investigation

## Status on 2026-11-04

The user asked to limit further Quest work and proceed to PC while preserving the current appearance. A separate Quest candidate is saved locally. It has not replaced the main Quest scene or been uploaded. Remaining cuff and shoulder overlap prevents calling this a complete clipping fix.

## Tested candidate

- SDK Android build succeeded.
- All 25 garment toggle round trips passed. Four top-and-pants combinations also passed independent switch checks.
- Original body vertex positions were preserved exactly in the sampled poses.
- Original 536 expression parameters and synced ordering were preserved. The build added two non-synced desktop-alignment placeholders.
- Skinned renderer count stayed at 54. Mesh triangles increased from 24,490 to 26,366 to restore some detail to heavily simplified garments.
- Garment-only corrections were limited to 12 mm across five sampled poses, with tighter limits near openings and waistbands. Material slots, shaders and source skin weights were preserved.
- Screen-space overlap flags fell from 705,418 to 248,810 across the sampled cases. These are diagnostic pixels and include false positives. They are not a count of visible defects or evidence that every garment is fixed.

## Findings

The original Comfy Pants action hides two existing body sections. Restoring both sections avoids some missing-skin regions, but exposes cuff overlap. A selective-restoration experiment was evaluated offline and provided negligible additional improvement, so it was not applied.

Visual comparison still shows cuff and shoulder clipping. Desktop albedo previews were used to inspect the Android bundle because its compiled mobile shaders cannot render directly in the Windows editor. Headset appearance remains unverified.

The original two PC pants were previously restored. PC work should start from that baseline and preserve the body silhouette, texture layout, waistline and clothing style. A successful SDK build alone is insufficient acceptance. Check front, rear and side views in neutral, crouched and raised-knee poses, then toggle clothing off and verify the original body returns without gaps.

## Local saved work

The workspace folder `Mayu patch verification/Quest clothing candidate 2026-11-04` holds the candidate scene, mesh assets, Android bundle, comparison image and validation report. Commercial assets remain local.
