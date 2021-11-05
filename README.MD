# Kitchen Arrange

![dishwasher](https://user-images.githubusercontent.com/6557808/123658480-9eb45380-d7e6-11eb-9519-51d7cc0e2cc7.png)

## Updates

11/01/21 - added `batch_arrange` tool, rebased habitat-sim to latest `main`, and updated some data (see `data_v3.zip`)

## Overview

This is the top-level repo for our dishwasher-loading data collection effort.

The current structure:
- This repo contains text scene data under `data`
- There are instructions below for downloading the binary scene data (mostly GLBs) into the same local `data` folder.
- Our Habitat-sim branch (below) contains the C++ arrangement functionality (e.g. `src/esp/arrange/Arranger.cpp`).
- That branch also includes the C++ GUI application (`src/utils/arrange_recorder/arrange_recorder.cpp`) and the C++ command-line tool (`src/utils/batch_arrange/BatchArrange.cpp`)

Going forward:
- Users should create their own branch of this repo so they can iterate on the scene data.
- Users should create their own branch of Habitat-sim based on our branch below so they can iterate on the C++ arrangement functionality.
- Later, we can use this repo to build a Javascript web-app version of `arrange_recorder` to collect demonstrations at large scale. (See [hab_vr_mephisto](https://github.com/eundersander/hab_vr_mephisto) as a reference Habitat web app.)
- Users should consider embedding their Habitat-sim branch as a git submodule of this repo (`kitchen_arrange/habitat-sim`), to simplify joint development of the C++ code, scene data, and eventual Javascript code.

## Facebook-internal Lighthouse and ReplicaCAD datasets

This project uses a subset of both the Lighthouse and ReplicaCAD dataset, namely GLB model files. These are included in the (restricted-access) `data_v3.zip` download below. Lighthouse hasn't been publicly-released yet, so don't share these GLB files outside Facebook. For more info on these datasets:
- https://aihabitat.org/datasets/replica_cad/
- https://fb.workplace.com/notes/221595716185290
- https://drive.google.com/drive/u/1/folders/1EkmA5aBX5j081q9FiZr1t-9vS7cYwPmK
- https://drive.google.com/drive/folders/1i_6lIQZxh2rmRwsLk0Iloji4xStWRoKB?usp=sharing

## Building and running `arrange_recorder`

1. Download `data_v3.zip` from [here](https://drive.google.com/drive/folders/1A24fBE077AFecZVRe9YPgTdu6fDA0EaC) and extract into the existing `kitchen_arrange/data` folder: `unzip data_v3.zip -d data`
1. Clone the Habitat-sim [batch_arrange2](https://github.com/eundersander/habitat-sim/tree/eundersander/batch_arrange2) branch. This can live outside this `kitchen_arrange` repo. Or, consider adding it as a git submodule to this repo.
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
- Mouse-wheel to zoom.

While holding an object:
- `F` to rotate the object
- Left-click to place the object
- CTRL+Z to cancel
- `Z/X` to raise/lower the drop height

While a URDF link is moving:
- `F` to skip the rest of the movement (use this if the link gets stuck)

While the scene is settling due to physics
- `F` to skip and just freeze the scene as-is (you can also adjust `physicsDeactivationTime` in `default.arrange_config.json`)

## Scene data overview

#### `data/lighthouse_kitchen_dataset/lighthouse_kitchen.scene_dataset_config.json`
The top-level scene dataset file. We specify the file locations of objects, stages, URDFs, and scenes.

#### `data/replicacad/kitchen_objects`
ReplicaCAD rigid objects including cups and plates. The `object_config.json` metadata files are handy here for changing the scale or mass of objects. See `configs_convex/frl_apartment_bowl_07_small.object_config.json` as an example of creating a smaller variant of an existing object.

#### `data/lighthouse_kitchen_dataset/objects`
Lighthouse rigid objects including counters and a few clutter items. 

#### `data/lighthouse_kitchen_dataset/urdf`
URDF models including an oven and dishwasher. Most URDF links will have an associated GLB model file; these GLB files are also in this folder.

#### `data/lighthouse_kitchen_dataset/stages`
"Stages" are background models. Our only stage for this project is a special cropped version of the Lighthouse Replica Apt0 floor-0 stage: `apartment_0_f0_stage_only_kitchen_aligned`

#### `data/lighthouse_kitchen_dataset/scenes`
A scene combines objects, URDFs, and a stage. Each scene in here has a `scene_instance.json` file that specifies the scene contents. However, we don't currently specify the poses of the objects/URDFs here. Instead, we use a separate, similarly-named `physics_keyframe.json` file. 

## Interactive authoring mode

You can use `arrange_recorder` to interactively author a scene.

1. Run `kitchen_arrange.sh data/lighthouse_kitchen_dataset/scenes/scene0_unloaded.scene_instance.json --authoring-mode`
2. Edit your scene's `physics_keyframe.json` file in any text editor. For example, edit object positions or rotations or URDF joint positions.
3. In the tool, hit `F5` to reload your scene with the new changes.
4. Now, edit your scene in the tool: click to move objects to new locations.
5. Hit `CTRL+S` and observe that your `physics_keyframe.json` file is updated.

Note that the workflow in step 2 is useful for all scene elements including kinematic furniture and URDF bases. Step 4 only works for dynamic objects and URDF links.

To create a new scene:
1. Make copies of an existing scene's `scene_instance.json` and `physics_keyframe.json` files.
2. Edit the `scene_instance.json` to add or remove instances of objects and URDFs.
3. Use the authoring workflows above to adjust object/URDF poses.

You can also use authoring mode to edit the app's config variables:
1. Run `kitchen_arrange` in authoring-mode.
1. Open `data/default.arrange_config.json` in a text editor and edit the variables.
2. To understand the meaning of the variables here, see their use `habitat-sim/src/esp/arrange/Arranger.cpp`.
3. Changes on disk are immediately reloaded and reflected in the running app. 


## Recording an arrangement session

1. Run `kitchen_arrange.sh data/lighthouse_kitchen_dataset/scenes/scene0_unloaded.scene_instance.json`
2. Move objects.
3. Observe that a new `session.json` file is created at `data/sessions`. It is updated after every user action.
4. Optionally, use `CTRL+Z` to undo an action. The final saved session won't include actions that were undone.

## Loading a recorded session in Python

`arrange_session_viewer.py` is a simple example of using session data. It reloads the scene and uses recorded keyframes in your session file to replay the session, including posing rigid objects and URDF articulated objects. The result is saved to a video.

1. Ensure that your Python is configured to load your locally-built version of Habitat. See [Build From Source](https://github.com/facebookresearch/habitat-sim/blob/master/BUILD_FROM_SOURCE.md) including instructions for setting `PYTHONPATH`.
2. Run `habitat-sim/tools/arrange_session_viewer.py --session data/sessions/your_session.session.json --output-folder data/videos`

## `batch_arrange` tool overview

`batch_arrange` is an alternatve to the interactive C++ GUI app that procedurally generates random arrangement sessions. See `src/utils/batch_arrange/BatchArrange.cpp` `BatchArrange::generateRandomSession()` to understand and customize the generation logic. While this is C++ code (for now), this function is essentially a script that generates a random arrangement session by calling into the `Arranger` headless API, namely `tryMoveRigidObject` and `moveArticulatedLink`. Going forward, we might want to make this function more data-driven (e.g. load `minObjectsUpperRack` from a config file), or we might want to implement Python bindings for the `Arranger` headless API so that `generateRandomSession` can be ported to Python. 

## Building and running `batch_arrange`
1. After building habitat-sim using the earlier instructions, look for the binary executable at `habitat-sim/build/utils/batch_arrange/batch_arrange`. Consider setting an env var `PATH_TO_BATCH_ARRANGE`.
2. Set your working directory to `kitchen_arrange`.
3. `PATH_TO_BATCH_ARRANGE --scene data/lighthouse_kitchen_dataset/scenes/scene0_unloaded.scene_instance.json --dataset data/lighthouse_kitchen_dataset/lighthouse_kitchen.scene_dataset_config.json --arrange-config data/batch_arrange.arrange_config.json --num-sessions 5 --random-seed 2`
4. Watch the terminal output. The tool generates and saves one or more `session.json` files that can be viewed with `arrange_session_viewer.py`.
5. In the steps above, notice we use `batch_arrange.arrange_config.json` instead of `default.arrange_config.json` used earlier. You may wish to inspect this file, edit it, or create a new `arrange_config.json` file.

## Tuning spatial config data for `batch_arrange`

The `BatchArrange::getRandomDropPositionForRack` function is meant to get a random position in the upper or lower dishwasher rack. The spatial extent data is pulled from two `debugLineLists` in `data/batch_arrange.arrange_config.json`. This kind of spatial data is easiest to author and tune visually. To do this, run the interactive `arrange_recorder` in authoring mode, specifying `data/batch_arrange.arrange_config.json` (you may need to modify `kitchen_arrange.sh`). The interactive viewer will display all debug line lists in pink. Edit the vertices in a text editor and the line lists will be hot-reloaded.

## Known issues

Mouse-picking on the Macbook built-in display is broken. This is due to how our code (mis)handles OS DPI window-scaling. A fix for the same issue in `habitat-sim`'s `viewer.cpp` is [here](https://github.com/facebookresearch/habitat-sim/pull/1415) and should be ported to `habitat-sim/src/utils/arrange_recorder/arrange_recorder.cpp`.
