# Kitchen Arrange

## Overview

This is the top-level repo for our dishwasher-loading data collection effort.

The current structure:
- This repo contains text scene data under `data`
- There are instructions below for downloading the binary scene data (mostly GLBs) into the same local `data` folder.
- Our Habitat-sim [arrange_recorder2](https://github.com/eundersander/habitat-sim/tree/eundersander/arrange_recorder2) branch contains the C++ arrangement functionality (e.g. `src/esp/arrange/Arranger.cpp`).
- That branch also includes the C++ GUI application (`src/utils/arrange_recorder/arrange_recorder.cpp`)

Going forward:
- Users should create their own branch of this repo so they can iterate on the scene data.
- Users should create their own branch of Habitat-sim based on [arrange_recorder2](https://github.com/eundersander/habitat-sim/tree/eundersander/arrange_recorder2) so they can iterate on the C++ arrangement functionality.
- Later, we'll use this repo to build the Javascript web-app version of `arrange_recorder`. (See [hab_vr_mephisto](https://github.com/eundersander/hab_vr_mephisto) as a reference Habitat web app.)
- Users should consider embedding their Habitat-sim branch as a git submodule of this repo (`kitchen_arrange/habitat-sim`), to simplify joint development of the C++ code, scene data, and eventual Javascript code.

## Facebook-internal Lighthouse and ReplicaCAD datasets

This project uses a subset of both Lighthouse and ReplicaCAD dataset assets. Neither dataset has been publicly-released yet, so don't share this data outside Facebook. For more info:
- https://fb.workplace.com/notes/221595716185290
- https://drive.google.com/drive/u/1/folders/1EkmA5aBX5j081q9FiZr1t-9vS7cYwPmK
- https://drive.google.com/drive/folders/1i_6lIQZxh2rmRwsLk0Iloji4xStWRoKB?usp=sharing

## Building and running `arrange_recorder`

1. Download [data_v2.zip](todo: insert link) and extract into the existing `kitchen_arrange/data` folder: `unzip data_v2.zip -d data`
1. Clone the Habitat-sim [arrange_recorder2](https://github.com/eundersander/habitat-sim/tree/eundersander/arrange_recorder2) branch. This can live outside this `kitchen_arrange` repo. Or, consider adding it as a git submodule to this repo.
1. Build Habitat-sim [from source](https://github.com/facebookresearch/habitat-sim/blob/master/BUILD_FROM_SOURCE.md) (do *not* install via Conda or Docker). You should build with the following flags: `build.sh --bullet`
2. Look for the binary executable at `habitat-sim/build/utils/arrange_recorder/arrange_recorder`
3. Set `PATH_TO_ARRANGE_RECORDER` to this executable, as an environment variable or shell variable inside `kitchen_arrange.sh`
4. From the `kitchen_arrange` working directory, run `kitchen_arrange.sh data/lighthouse_kitchen_dataset/scenes/scene0_unloaded.scene_instance.json` to start a recording session for a given scene.

## Mouse and keyboard controls

Basic controls:
- Mouse-over a small object and notice a red circle; left-click to grab and hold the object.
- Mouse-over a door or drawer and notice an orange circle; left-click to open/close.
- CTRL+Z to undo your last action
- `C/V` to change the camera (cameras are specified in `default.arrange_config.json`)
- `F5` to reload/reset the scene.

While holding an object:
- `F` to rotate the object
- Left-click to place the object
- CTRL+Z to cancel
- `Z/X` to raise/lower the drop height

While a URDF link is moving:
- `F` to skip the rest of the movement (use this if the link gets stuck)

While the scene is settling due to physics
- `F` to skip and just freeze the scene as-is (you can also adjust `physicsDeactivationTime` in `default.arrange_config.json`)

Movement and camera controls:
- Right-click and drag to look around. You can also look around with the arrow keys.
- Use `Z` and `X` to adjust your height up and down.
- Use `WASD` to move around.

## Scene data overview

`data/lighthouse_kitchen_dataset/lighthouse_kitchen.scene_dataset_config.json`
The top-level scene dataset file. We specify the locations of objects, stages, URDFs, and scenes.

`data/replicacad/kitchen_objects`
ReplicaCAD rigid objects including cups and plates. The `object_config.json` metadata files are handy here for changing the scale or mass of objects. See `configs_convex/frl_apartment_bowl_07_small.object_config.json` as an example of creating a smaller variant of an existing object.

`data/lighthouse_kitchen_dataset/objects`
Lighthouse rigid objects including counters and a few clutter items. 

`data/lighthouse_kitchen_dataset/urdf`
URDF models including an oven and dishwasher. Most URDF links will have an associated GLB model file; these GLB files are also in this folder.

`data/lighthouse_kitchen_dataset/stages`
Stages are background models. Our only stage is a cropped version of the full Lighthouse Replica Apt0 scene: `apartment_0_f0_stage_only_kitchen_aligned`

`data/lighthouse_kitchen_dataset/scenes`
A scene combines objects, URDFs, and a stage. Each scene in here has a `scene_instance.json` file that specifies the scene contents. However, we don't currently specify the poses of the objects/URDFs here. Instead, we use a separate, similarly-named `physics_keyframe.json` file. 

## Interactive authoring mode

You can use `arrange_recorder` to interactively author a scene.

1. Run `kitchen_arrange.sh data/lighthouse_kitchen_dataset/scenes/scene0_unloaded.scene_instance.json --authoring-mode`
2. Edit your scene's `physics_keyframe.json` file in any text editor. For example, edit object positions or rotations or URDF joint positions.
3. In the tool, hit `F5` to reload your scene with the new changes.
4. Now, edit your scene in the tool: click to move objects to new locations.
5. Hit `CTRL+S` and observe that your `physics_keyframe.json` file is updated.
6. Open `data/default.arrange_config.json` in a text editor and consider tuning the variables here. To understand their usage, see `habitat-sim/src/esp/arrange/Arranger.cpp`. Changes on disk are immediately reloaded and reflected in the running app. 

Note that the workflow in step 2 is useful for all scene elements including kinematic furniture and URDF bases. Step 4 only works for dynamic objects and URDF links.

To create a new scene:
1. Make copies of an existing scene's `scene_instance.json` and `physics_keyframe.json` files.
2. Edit the `scene_instance.json` to add or remove instances of objects and URDFs.
3. Use the authoring workflows above to adjust object/URDF poses.

## Recording an arrangement session

1. Run `kitchen_arrange.sh data/lighthouse_kitchen_dataset/scenes/scene0_unloaded.scene_instance.json`
2. Move objects.
3. Observe that a new `session.json` file is created at `data/session`. It is updated after every user action.
4. Optionally, use `CTRL+Z` to undo an action. The final saved session won't include actions that were undone.

## Loading a recorded session in Python

`arrange_session_viewer.py` is a simple example of using session data. It reloads the scene and uses recorded keyframes in your session file to replay the session, including posing rigid objects and URDF articulated objects. The result is saved to a video.

1. Ensure that your Python is configured to load your locally-built version of Habitat. See [Build From Source](https://github.com/facebookresearch/habitat-sim/blob/master/BUILD_FROM_SOURCE.md) including instructions for setting `PYTHONPATH`.
2. Run `habitat-sim/tools/arrange_session_viewer.py --session data/sessions/your_session.session.json --output-folder data/videos`
