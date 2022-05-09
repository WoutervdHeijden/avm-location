function [out_im, out_trns, log, out_avm]= coregister(fixed_image, moving_image, avm)

%% Define co-registration parameters
path = 'C:\Users\WRPva\OneDrive\Documents\Master TM\Stage Q3';
out_path = 'Results';
outfold = [pwd filesep out_path];  %create directory where results will be written
mkdir(outfold);
pfile = [pwd filesep 'pfiledsa.txt'];  % This file contains the parameters that are used by Elastix
verbose = 1; % Set to 0 if you don't want to display the logfile in your command window

%% Perform actual co-registration
[out_im, out_trns, log] = run_elastix(verbose, fixed_image, moving_image,outfold, pfile);
[out_avm, ~,~] = run_transformix(avm, out_trns, outfold);
end