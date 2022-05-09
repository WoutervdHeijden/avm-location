function AVM = visualize_avm(cor_line,sag_line)

%% Load the files with the projections of the AVM in the MRI
cor = niftiread(cor_line);
sag = niftiread(sag_line);
%% Reduce the thickness of these lines to 1 voxel

cor = logical(cor);
sag = logical(sag);

sum = bwskel(cor)+bwskel(sag);
sum = im2double(sum);
niftiwrite(sum, 'sum.nii')

%% See if the lines intersect (CC.NumObjects = 1) or not (CC.NumObjects = 2)
suma = logical(sum);

CC = bwconncomp(suma);
if CC.NumObjects == 2
reg=regionprops(suma,'PixelList');

%% Find the minimum distance between both lines
[D,I1] = pdist2(reg.PixelList,'euclidean','Smallest',1);
[minDistance,I2]=min(D);
 
xy=[reg(1).PixelList(I1(I2),:);reg(2).PixelList(I2,:)],1;

midx = round(xy(1,1) + ((xy(2,1)-xy(1,1))/2))
midy = round(xy(1,2) + ((xy(2,2)-xy(1,2))/2))
midz = round(xy(1,3) + ((xy(2,3)-xy(1,3))/2))


else
%% find where the two lines intersect    
 [mxv,idx] = max(sum(:));
 [midx,midy,midz] = ind2sub(size(sum),idx);

end

%% Create a sphere at the location of the AVM and save it.
AVM = zeros(size(suma));
AVM(midy, midx,midz) = 1;

AVM = logical(AVM);
se = strel('sphere',8);
AVM = imdilate(AVM,se);

AVM = im2double(AVM);
niftiwrite(AVM, 'AVM')
end