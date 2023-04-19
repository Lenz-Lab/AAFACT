# AutoCoordinateSystem

Use this code to automatically assign a coordinate system to bone models.

## Description

This code takes a bone model, currently the tibia, fibula, talus, calcaneus, navicular, cuboid and the three cuneiforms, and automatically assigns a coordinate system. The input file type currently supported is ".k", ".stl", ".particles", ".vtk", ".ply" and the output is an .xlsx file with two different coordinate systems. The first is the starting and ending points for all three axes with the origin at the location that the user input the bone. The second is the starting and ending points for all three axes with the origin at (0,0,0).

## Getting Started

### Dependencies

* MATLAB R2020A or later
* Robotics System Toolbox
* Phased Array System Toolbox

### Installing

* How/where to download your program
* Any modifications needed to be made to files/folders

### Executing program

* Create a new folder in 'C:' drive called 'AutoCoordinateSystem'
* Execute the matlab script 'MainCS.m'
* Select an individual bone model or a folder including the bone models
* Ensure that folder names do not contain spaces
* If the folder name or the file name does not contains the name of the bone and/or the laterally, you will need to manually select both of those for each bone

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
