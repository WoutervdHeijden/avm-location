
function [cor_line, sag_line] = locate_avm(avm_cor, avm_sag)
%% Load the empty image with the AVM

co_cor = load_nii(avm_cor);
avmcor = co_cor.img;

%% Find the x,y-location of the AVM in this image 
[rowc, colc] = find(ismember(avmcor, max(avmcor(:))));

%% Enlarge and project the AVM from the coronal coordinates into all the MRI slices.

mricor = niftiread('mricor.nii');
trnd_mric = zeros(size(mricor));

rowc = length(avmcor(:,1)) - rowc;
% colc = length(avmcor(1,:)) -colc;

for  i = 1:length(mricor(1,:,1))
    trnd_mric(rowc-5:rowc+5,i, colc-5:colc+5) = 1;
end

% trnd_mric = flipdim(trnd_mric,2);
niftiwrite(trnd_mric, 'turn_cor');
% niftiwrite(mricor, 'testwrite')

fixedc = 'mri_original.nii';
movingc = 'mricor.nii';

%% Apply the same steps for the sagittal MRI and DSA

co_sag = load_nii(avm_sag);
avmsag = co_sag.img;

%%
[rows, cols] = find(ismember(avmsag, max(avmsag(:))));
rows = length(avmsag(:,1)) - rows;

mrisag = niftiread('mrisag.nii');

trnd_mris = zeros(size(mrisag));
for i = 1:length(mrisag(:,1,1))
    trnd_mris(i, rows-5:rows+5, cols-5:cols+5) = 1;
end

niftiwrite(trnd_mris, 'turn_sag');
niftiwrite(mrisag, 'testwrite')

fixeds = 'mri_original.nii';
movings = 'mrisag.nii';

%% Turn the rotated MRI's back to the original MRI. The projections of the AVM undergo the same transformation.

path = 'C:\Users\WRPva\OneDrive\Documents\Master TM\Stage Q3';
out_path = 'Results';
outfold = [pwd filesep out_path];  %create directory where results will be written
pfile = 'pfiledsa.txt';
[rtrndc, trnsc, log] = run_elastix(1, fixedc, movingc, outfold, pfile);
[cor_line, ~,~] = run_transformix('turn_cor.nii', trnsc, outfold);
[rtrnds, trnss, log] = run_elastix(1, fixeds, movings, outfold, pfile);
[sag_line, ~,~] = run_transformix('turn_sag.nii', trnss, outfold);

end
