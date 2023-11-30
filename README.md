# Automatic Anatomical Foot and Ankle Coordinate Toolbox

Use this toolbox to automatically assign a coordinate system to bone models.

## Example anatomical coordinate systems

![Fig_CS_Manuscript_CoordinateSystems_v2](https://github.com/Lenz-Lab/AAFACT/assets/70289972/9beab321-2de5-40a1-9bb1-667924df24a9)

## Description

This code takes a bone model as an input, currently, the tibia, fibula, talus, calcaneus, navicular, cuboid, three cuneiforms, and the five metatarsals automatically assigns an anatomical coordinate system (ACS). The input file type currently supported is ".k", ".stl", ".particles", ".vtk", ".ply" and the output is an interactive figure displaying the ACS and a .xlsx file with the ACS in two different coordinate spaces. The first is the starting and ending points for all three axes, originating at the location where the user inputs the bone. The second is the starting and ending points for all three axes, originating at (0,0,0).

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
