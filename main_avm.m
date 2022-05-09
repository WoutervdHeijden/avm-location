close all
clear all
clc
%% fill in these parameters to start localisation
% path = 'path to mri'
% name_dsa_sag = 'path to sagittal dsa';
% name_dsa_cor = 'path to coronal dsa';
% crd_cor = [y coordinate of AVM on coronal DSA, x coordinate of AVM on coronal DSA];
% crd_sag = [y coordinate of AVM on sagittal DSA, x coordinate of AVM on sagittal DSA];


%% Put together the DICOM-slices in the directory 'path'. The MRI's undergo a rotation to match the DSA-angle
[sag,cor] = get_mri_slices(path, name_dsa_sag, name_dsa_cor);

%% Uncomment to visualise the MRI-slices that are used 
% figure
% imshow(sag)
% figure
% imshow(cor)
%% Segmentation of the MRI and DSA. MRI is segmented with a threshold based method. The DSA is segmented with a region-growing algorithm
[mri_sag]  = segment_mri(sag);
[mri_cor] = segment_mri(cor);
[dsa_sag, a, avm_sag] = segment_dsa(name_dsa_sag, crd_sag);
[dsa_cor, b, avm_cor] = segment_dsa(name_dsa_cor, crd_cor);

%% Save the new images on your disk
%the angio's are representable slices of the DSA containing contrast
imwrite(im2double(a), 'angio_sag.png') 
imwrite(im2double(b), 'angio_cor.png')
%the segmentation of the head on MRI in coronal and sagittal directions
imwrite(mri_cor, 'coronal_mri.png') 
imwrite(mri_sag, 'sagittal_mri.png')
%the segmentations of the head on DSA in coronal and sagittal direction
imwrite(dsa_cor, 'coronal_dsa.png')
imwrite(dsa_sag, 'sagittal_dsa.png')
%blank images containing only the location of the AVM
imwrite(avm_cor, 'coronal_avm.png')
imwrite(avm_sag, 'sagittal_avm.png')

%% Load the images back into the workspace
cormri = 'coronal_mri.png';
sagmri = 'sagittal_mri.png';
cordsa =  'coronal_dsa.png';
sagdsa = 'sagittal_dsa.png';
coravm = 'coronal_avm.png';
sagavm = 'sagittal_avm.png';

%% Co-registration of the coronal/sagittal DSA on the MRI using the Elastix Toolbox
[out_sag, sag_trns, logsag, avm_sag] = coregister(sagmri, sagdsa, sagavm);
[out_cor, cor_trns, logcor, avm_cor] = coregister(cormri, cordsa, coravm);

%% Find the intersection of the lines through the skull projecting the AVM and create an image visualising the AVM
[cor_line, sag_line] = locate_avm(avm_cor, avm_sag);
AVM = visualize_avm(cor_line,sag_line);
