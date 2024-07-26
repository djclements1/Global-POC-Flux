# Global-POC-Flux
Code and data nessecary to create the flux output for Clements et al. 2024 "Modeling the Diel Vertical Migration and Active Carbon Transport of zooplankton"

Included are the needed functions to run each of the scripts. They are located in the folder denoted "functions"

Some of the needed data files are included here. The rest are available as notated below: 

**Biovolume and slope observations**
These gridded observations are included as part of the data output located on BCO-DMO. 
The file is named "Global_POC_Export_2024" 

**Predictors_3D**
The predictors file is uploaded to BCO-DMO as a . mat file. 
File is large ~3.6 GB

**Etopo2.nc**
This data is stored by NOAA, thus not uploaded here or on the BCO-DMO repository. 
Data can be accessed following the link below: 
https://sos.noaa.gov/catalog/datasets/etopo2-bathymetry/


# Instructions 
Scripts should be run in the following order
1. Make predictions
    This will generate predictions of the Biovolume and Slope 
2. Calc_3D_psd
     This will generate a matrix with size specific abundances
3. Linear_int_flux
     This will generate a mean export flux with varying vertical sinking carbon profiles.


# Contact
If you need more information or help, contact Daniel Clements (dclements@bigelow.org) or Daniele Bianchi (dbianchi@atmos.ucla.edu)

# How to cite
Please cite the future manuscript and this repository DOI [![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.12976820.svg)](http://dx.doi.org/110.5281/zenodo.12976820)

# License
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Copyright 2024 © Daniel Clements.
