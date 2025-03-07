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

This code takes a bone model as an input (tibia, fibula, talus, calcaneus, navicular, cuboid, three cuneiforms, and the five metatarsals) and automatically assigns an anatomical coordinate system (ACS). The input file type currently supported is ".k", ".stl", ".particles", ".vtk", ".ply" and the output is an interactive figure displaying the ACS and a .xlsx file with the ACS in two different coordinate spaces. The first is the starting and ending points for all three axes, originating at the location where the user inputs the bone. The second is the starting and ending points for all three axes, originating at (0,0,0).

## Getting Started

### Dependencies

If you want to run it in MATLAB:
* MATLAB R2020B or later
* Robotics System Toolbox
* Phased Array System Toolbox

If you want to run it outside of MATLAB:
* No dependencies

### Executing program

If you want to run it in MATLAB:
* Pull the main repository
* Execute the Matlab script 'MainCS.m'
* Select the folder where the bone models are located
* It is recommended to have the bone name and laterality in each file name, but it isn't necessary
* If the file name does not contain the name of the bone and/or the laterally, you will need to manually select both of those for each bone
* You will also be prompted to input which ACS you would like for the talus and calcaneus and the desired location of the ACS

If you want to run it outside of MATLAB:
* Navigate to "AAFACT_App" folder on GitHub repository
* Download "AAFACT_Install.exe"
* Follow install instructions (this will take a bit the first time, every future application update should be faster)
* Once installed, navigate to the the install location (typically this is in your program files directory, where other applications are)
* Within "application", run AAFACT application
* Select the folder where the bone models are located
* It is recommended to have the bone name and laterality in each file name, but it isn't necessary
* If the file name does not contain the name of the bone and/or the laterally, you will need to manually select both of those for each bone
* You will also be prompted to input which ACS you would like for the talus and calcaneus and the desired location of the ACS

## Authors

* Andrew Peterson ([Github](https://github.com/AndrewCPeters0n), [Twitter](https://twitter.com/AndrewCPeters0n), andrew.c.peterson@utah.edu)

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives (CC BY-NC-ND).

## Acknowledgments

Inspiration, code snippets, etc.
* [awesome-readme](https://github.com/matiassingers/awesome-readme)
* [PurpleBooth](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2)
* [dbader](https://github.com/dbader/readme-template)
* [zenorocha](https://gist.github.com/zenorocha/4526327)
* [fvcproductions](https://gist.github.com/fvcproductions/1bfc2d4aecb01a834b46)
