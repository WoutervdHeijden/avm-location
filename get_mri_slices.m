function [mr_sag, mr_cor] = get_mri_slices(path, name_dsa_sag, name_dsa_cor)
a = dir(path);
b = a(3:length(a));
c = struct2cell(b);

%% Find the right order of the separate DICOM files
for i = 1:length(b)
    filename = char(c(1,i));
    a = dicominfo(filename);
    f(i) = a.InstanceNumber;
end

disp(a)

%%
dicom2 = zeros(a.Width, a.Height, length(b));
disp(length(b))
disp(f)
%% Create one volume containing all DICOM's

for i = 1:length(b)
    filename = char(c(1,i));
    disp(filename)
    dicom2(:,:,f(i)) = dicomread(filename);
end

%% Rotate the image into the right coordinate system and set the pixel spacing to 1x1x1 mm
dicom3 = imrotate3(dicom2, 90, [0 0 1], 'loose');
g = a.PixelSpacing;
g(3) = a.SliceThickness;
h = size(dicom3);
factor(1) = g(1)*h(1);
factor(2) = g(2)*h(2);
factor(3) = g(3)*h(3);

%% Apply the new pixel size and save the original MRI as nifti file
dicom4 = imresize3(dicom3, factor);

dicom4 = flipdim(dicom4,1);
niftiwrite(dicom4, 'mri_original');

%% Extract the angles in which the sagittal angiography was performed.
infsag = dicominfo(name_dsa_sag);

angle1 = infsag.PositionerPrimaryAngle;
angle1 = (angle1 +90)*-1;

angle2 = infsag.PositionerSecondaryAngle;

%% Extract the angles in which the coronal angiography was performed.
infcor = dicominfo(char(name_dsa_cor));

angle3 = infcor.PositionerPrimaryAngle*-1;
angle4 = infcor.PositionerSecondaryAngle;


%% Turn the original MRI with the DSA angles to receive and save two new MRI's matching the coronal and sagittal DSA

mrisag = imrotate3(dicom4, angle1, [0 0 1],'loose');
mrisag = imrotate3(mrisag, angle2, [0 1 0], 'loose');

niftiwrite(mrisag, 'mrisag');

mricor = imrotate3(dicom4, angle3, [0 0 1],'loose');
mricor = imrotate3(mricor, angle4, [0 1 0], 'loose');

niftiwrite(mricor, 'mricor');

%% Find number of sagittal slice with largest tissue area.
s = size(mrisag);
slcsag0 = zeros(s(1),1);
for i = 1:s(1)
    idx = 0;
    idx=mrisag(i,:,:)>10;
    slcsag0(i) = sum(idx(:));
end
  
%%
[~,slcsag] = max(slcsag0);
mr_sag = squeeze(mrisag(slcsag,:,:));
mr_sag = imrotate(mr_sag, 90);

%% Find number of coronal slice with largest tissue area.
s = size(mricor);
slccor0 = zeros(s(2),1);
for i = 1:s(2)
    idx = 0;
    idx=mricor(:,i,:)>10;
    slccor0(i) = sum(idx(:));
end

%%
[~,slccor] = max(slccor0);
mr_cor = squeeze(mricor(:,slccor,:));
mr_cor = imrotate(mr_cor, 90);

end

