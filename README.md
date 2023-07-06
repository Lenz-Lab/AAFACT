# Automatic Anatomical Foot and Ankle Coordinate Toolbox

Use this toolbox to automatically assign a coordinate system to bone models.

## Description

This code takes a bone model as an input, currently, the tibia, fibula, talus, calcaneus, navicular, cuboid, three cuneiforms, and the five metatarsals automatically assigns an anatomical coordinate system (ACS). The input file type currently supported is ".k", ".stl", ".particles", ".vtk", ".ply" and the output is an interactive figure displaying the ACS and a .xlsx file with the ACS in two different coordinate spaces. The first is the starting and ending points for all three axes, originating at the location where the user inputs the bone. The second is the starting and ending points for all three axes, originating at (0,0,0).

## Getting Started

### Dependencies

* MATLAB R2020B or later
* Robotics System Toolbox
* Phased Array System Toolbox

### Executing program

* Pull the main repository
* Execute the Matlab script 'MainCS.m'
* Select the folder where the bone models are located
* It is recommended to have the bone name and laterality in each file name, but it isn't necessary
* If the file name does not contain the name of the bone and/or the laterally, you will need to manually select both of those for each bone
* You will also be prompted to input which ACS you would like for the talus and calcaneus and the desired location of the ACS

## Authors

* Andrew Peterson ([acpeterson96](https://github.com/acpeterson96), andrew.c.peterson@utah.edu)

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the Creative Commons Zero License.

## Acknowledgments

Inspiration, code snippets, etc.
* [awesome-readme](https://github.com/matiassingers/awesome-readme)
* [PurpleBooth](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2)
* [dbader](https://github.com/dbader/readme-template)
* [zenorocha](https://gist.github.com/zenorocha/4526327)
* [fvcproductions](https://gist.github.com/fvcproductions/1bfc2d4aecb01a834b46)
