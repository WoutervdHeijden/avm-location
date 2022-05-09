# avmlocation
Matlab code for the visualisation of arteriovenous malformation (which is visible on DSA) on MRI. Requires a coronal and sagittal DSA and a T1-weighted MRI as input.

This code can be used to find the 3D-location of arteriovenous malformations that can only be detected in 2D DSA images.
First, the coordinates of the AVM on DSA need to be assessed by a radiologist or neurosurgeon. 
These coordinates are needed as input, together with the path to the directory containing all DICOM slices of the MRI, and the path to the coronal and sagittal DSA.
These inputs can be written in line 5 to 9 of the main script 'main_avm.m'. 
The co-registration function uses the Elastix toolbox, which needs the Elastix software needs to be installed: https://elastix.lumc.nl/download.php
The software tool yields a mean error of 13 mm. It can't be used yet in the diagnostics or treatment planning. 
Questions about this code can be directed to w.r.p.vanderheijden@student.tudelft.nl
