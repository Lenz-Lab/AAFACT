# Automatic Anatomical Foot and Ankle Coordinate Toolbox

Use this toolbox to automatically assign a coordinate system to bone models.

## Publications
Please cite this paper if you use this code in your work:

Peterson, A. C., Kruger, K. M., Lenz, A. L. (2023). Automatic Anatomical Foot and Ankle Coordinate Toolbox, Frontiers in Bioengineering and Biotechnology, Oct 31:11:1255464. https://doi.org/10.3389/fbioe.2023.1255464.

## Funding
This work is supported by the following grant:

[R01: Post-Surgical Form and Function of Planovalgus Foot Deformities in Patients with Cerebral Palsy](https://reporter.nih.gov/search/79X6dVPEpUSj6H6npTrTdA/project-details/10779007)

R01AR083490 - A. Lenz (PI)
National Institutes of Health (NIH) - National Institute of Arthritis and Musculoskeletal and Skin Diseases (NIAMS)

05/15/2024-04/30/2029 - $3,265,005 total costs

Goals: Standardization of foot and ankle local coordinate systems and investigation of adult patients with cerebral palsy that have a history of foot deformity, whether it was surgically reconstructed or not in adolescence. The long-term goal is to better understand form and function for improved foot function into adulthood.

## Example anatomical coordinate systems

![Fig_CS_Manuscript_CoordinateSystems_v2](https://github.com/Lenz-Lab/AAFACT/assets/70289972/9beab321-2de5-40a1-9bb1-667924df24a9)

## Description

AAFACT takes 3D bone models as input (tibia, fibula, talus, calcaneus, navicular, cuboid, three cuneiforms, and the five metatarsals) and automatically assigns an anatomical coordinate system (ACS). Current supported input file types are: ".stl", ".k", ".particles", ".vtk", ".ply", and ".obj". The input file type currently supported is ".k", ".stl", ".particles", ".vtk", ".ply" and ".obj". The output file is an .xlsx file with the ACS in two different coordinate spaces. The first is the starting and ending points for all three axes, originating at the location where the user inputs the bone. The second is the starting and ending points for all three axes, originating at (0,0,0) in a normalized space. Visualization of the ACS on the bone is also included on MATLAB only.

## Coordinate system options

### Axis conventions
Every ACS has three orthogonal axes, reported in this order in the output:
* **AP axis**: positive points anterior (distal, for the metatarsals)
* **SI axis**: positive points superior (dorsal)
* **ML axis**: positive points medial on a left bone and lateral on a right bone. In both cases it points toward the subject's right, so the system stays right-handed for both sides.

Right bones are mirrored to the left side before processing and mirrored back afterward, so left and right bones get equivalent ACSs.

### Available coordinate systems per bone
Some bones have more than one ACS. Each ACS is written to its own sheet in the output .xlsx, and the sheet name gets the prefix shown below.

| Bone | Coordinate system(s) | Sheet prefix |
| --- | --- | --- |
| Tibia | Single ACS | – |
| Fibula | Single ACS | – |
| Talus | Talonavicular, Tibiotalar, Subtalar | `TN_`, `TT_`, `ST_` |
| Calcaneus | Calcaneocuboid, Subtalar | `CC_`, `ST_` |
| Navicular | Single ACS | – |
| Cuboid | Vertical, Radial | `V_`, `R_` |
| Medial and intermediate cuneiforms | Single ACS | – |
| Lateral cuneiform | Vertical, Radial | `V_`, `R_` |
| Metatarsals 1–5 | Vertical, Radial | `V_`, `R_` |

In MATLAB you can pick one or more options per bone. Standalone mode always computes all of them.

### Talus
* **Talonavicular (TN) ACS**: computed from the whole talus, head and neck included. The AP axis follows the long axis of the talus toward the talar head, so this ACS describes motion at the talonavicular joint.
* **Tibiotalar (TT) ACS**: computed from the talar body and trochlea (dome) only; the head and neck are excluded. The ACS lines up with the talar dome, so it describes motion at the ankle (tibiotalar) joint. Because the talar neck angles medially, the TT axes sit rotated in the transverse plane relative to the TN axes (about 24° for the template talus).
* **Subtalar (ST) ACS**: the TN and TT ACSs are computed separately and their axes averaged, then re-orthogonalized (see `AverageOrthogonalAxes.m`). This gives an orientation halfway between the talar head and the talar dome, for describing motion at the subtalar joint.

### Calcaneus
* **Calcaneocuboid (CC) ACS**: the AP axis follows the long axis of the calcaneus, from the tuberosity toward the calcaneocuboid joint.
* **Subtalar (ST) ACS**: the axes line up with the subtalar (posterior talar) articular surface instead of the long axis of the bone, for describing motion at the subtalar joint.

### Vertical vs. Radial (cuboid, lateral cuneiform, metatarsals)
These bones sit along the transverse arch of the foot, so their dorsal surfaces face different directions. AAFACT offers two ways to orient their SI and ML axes:
* **Vertical ACS**: the SI axis points straight up, perpendicular to the plantar (ground) plane, like the rest of the tarsal ACSs. Use it when comparing all bones in one common "foot-up" frame.
* **Radial ACS**: the SI and ML axes are rotated about the bone's long (AP) axis so the SI axis points outward from the curve of the transverse arch, perpendicular to the bone's own dorsal surface. Use it when each bone should be described relative to its own position in the arch.

The AP axis is the same in both options; only the rotation about it differs. On the template bones that rotation is small for the 1st metatarsal (~3°) and much larger toward the lateral column (~20–35° for the cuboid, lateral cuneiform, and 2nd–4th metatarsals, and ~70° for the 5th metatarsal).

### Origin location
By default the origin is placed at the center of the bone. In MATLAB you can move it to a joint surface instead:

| Bone | Origin options |
| --- | --- |
| Tibia | Center, Tibiotalar surface |
| Fibula | Center, Talofibular surface |
| Talus | Center, Talonavicular, Tibiotalar, or Subtalar surface |
| Calcaneus | Center, Calcaneocuboid or Subtalar surface |
| Navicular | Center, Talonavicular or Navicular-cuneiform surface |
| Cuboid | Center, Calcaneocuboid surface |
| Medial and lateral cuneiforms | Center, Navicular-cuneiform, Cuneiform-metatarsal, or Intercuneiform surface |
| Intermediate cuneiform | Center, Navicular-cuneiform, Cuneiform-metatarsal, Medial intercuneiform, or Lateral intercuneiform surface |
| Metatarsals | Center, Posterior (proximal) metatarsal surface |

Moving the origin only translates the ACS; the axis directions stay the same. The exception is the tibia and fibula: choosing the joint-surface origin also aligns the bone to a separate facet template (`Tibia_Template_Facet.stl` / `Fibula_Template_Facet.stl`), so the axes can differ slightly from the center-origin result.

## Getting Started
AAFACT can be run in 3 ways, depending on your needs.

### Option 1: Run in MATLAB (interactive)

#### Dependencies
* MATLAB R2020B or later
* Robotics System Toolbox
* Phased Array System Toolbox

#### How to run
1. Clone or download this repository
2. Open MATLAB and add the repository to your path
3. Run the script: Main_CS.m
4. Select the folder containing bone models
5. Follow on-screen prompts to:
     * select files
     * specify bone type and laterality (this can be avoided if it's included in the file name)
     * choose coordinate system options
     * select origin location
This mode provides full interactivity and visualization.

### Option 2: Run outside MATLAB (compiled standalone application)
This option allows users without MATLAB to run AAFACT using MATLAB Runtime (free) 

#### Dependencies
* MATLAB Runtime for 2023a (https://www.mathworks.com/products/compiler/matlab-runtime.html)

#### How to run
1. Download the compiled AAFACT package for your operating system from the GitHub Releases page
2. Install the MATLAB Runtime if not already installed
3. Run AAFACT from the command line:
      * Windows Example: AAFACT.exe "C:\path\bone_models"
      * Linux / macOS Example: ./AAFACT "/path/bone_models"

#### Behavior in standalone mode
* All supported bone files in the input folder are processed
* All available coordinate systems are computed for each bone
* Origin is placed at the center of the bone
* No interactive dialogs or plots are shown
* Results are written directly to the output folder
* Important: In standalone mode, bone name and laterality must be detectable from the file name.

### Option 3: Python wrapper (optional)
A lightweight Python interface can be used to call the compiled AAFACT application programmatically.
* Python does not re-implement the algorithms
* Python simply executes the compiled AAFACT binary and manages inputs/outputs
* This enables batch processing, pipelines, and integration with Python-based workflows

### File naming recommendations
To enable automatic detection of bone type and laterality (especially for non-interative use), filenames should include: <subject>_<bone>_<side>.<ext>

## Authors

* Andrew Peterson ([Github](https://github.com/AndrewCPeters0n), [Twitter](https://twitter.com/AndrewCPeters0n), andrew.c.peterson@utah.edu)

## License

This project is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives (CC BY-NC-ND).

## Acknowledgments

Inspiration, code snippets, etc.
* [awesome-readme](https://github.com/matiassingers/awesome-readme)
* [PurpleBooth](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2)
* [dbader](https://github.com/dbader/readme-template)
* [zenorocha](https://gist.github.com/zenorocha/4526327)
* [fvcproductions](https://gist.github.com/fvcproductions/1bfc2d4aecb01a834b46)

