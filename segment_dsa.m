function [dsa, angio, avm] = segment_dsa(name_dsa, crd)

%% get a slice with and without contrast and set the pixel spacing to 1x1 mm
dsa_volume = dicomread(name_dsa); 
info = dicominfo(name_dsa);

dsa_slice = squeeze(dsa_volume);
dsa_slice2 = dsa_slice(:,:,19);
dsa_slice = dsa_slice(:,:,2);

pxl = info.PixelSpacing;
scl(1) = pxl(1)*length(dsa_slice(:,1));
scl(2) = pxl(2)*length(dsa_slice(1,:));

%% convolution and contrast enhancement

k = [1,1,1;1,0,1;1,1,1]/8;
avg = conv2(double(dsa_slice),k,'same');
minavg = min(avg(:));
maxavg = max(avg(:));
avg2 = avg/maxavg;
avg2 = imadjust(avg2);

%% find regions in the corners with the same intensities (background)

BW = grayconnected(avg2,15,15,0.01);
BW2 = grayconnected(avg2, 15, length(avg2(1,:))-15,0.01);
BW3 = grayconnected(avg2, length(avg2(1,:)) -15, length(avg2(1,:))-15,0.01);
BW4 = grayconnected(avg2, length(avg2(1,:))-15,15,0.01);

%% connect background masks.
mask = ones(size(BW));
mask(BW == 1) = 0;
mask(BW2 == 1) = 0;
mask(BW3 == 1) = 0;
mask(BW4 == 1) = 0;

% figure
% imshow(mask)

%% remove noise and select largest object. Also create image that only contains AVM.
mask =logical(mask);
se = strel('disk',20);
mask = imopen(mask,se);
dsa = bwareafilt(mask,1);

avm = zeros(size(dsa));
avm(crd(1),crd(2)) = 1;

seavm = strel('square',10);
avm = imdilate(avm,seavm);

imwrite(avm, 'avm_test.png')
imwrite(dsa_slice2, 'dstest.png')
dsa = imresize(dsa, scl); 
angio = imresize(dsa_slice2, scl);

avm = imresize(avm,scl, 'nearest');
% avm = imresize(avm,scl);
% dsa2 = edge(dsa);
% dsa = imdilate(dsa2,se);

end

