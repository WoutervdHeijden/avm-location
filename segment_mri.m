function [avg8] = segment_mri(mri)

%% increase contrast
minavg = min(mri(:));
maxavg = max(mri(:));
avg2 = mri/maxavg;
avg2 = imadjust(avg2);

%% add background as mask
avg3s = imgaussfilt(avg2,5);
avg4s = avg3s;
avg4s(avg3s>0.09) =1 ;
avg4s(avg3s<0.09) = 0;
 
avg4ss = logical(avg4s);
sks = bwareafilt(avg4ss,1);
se = strel('disk',40);
sks = imclose(sks,se);

% figure
% imshow(sks)

se2 = strel('disk',10);
sks = imerode(sks,se2);
sksi = imcomplement(sks);

% figure
% imshow(sksi)


%% apply a simple threshold: this is the only segmentation step I actually perform for the MRI. The other steps are possible helps to segment the skull.
avg4 = avg2;
avg4(avg2<0.12) =1;
avg4(avg2>0.12) = 0;

avg8 = imcomplement(avg4);

figure
imshow(avg8)

%% Remove background
avg4 = logical(avg4);
avg4(sksi) = 0;

% figure
% imshow(avg4)

%% connect small parts by lines
for i = 0:15:180
    se = strel('line', 10, i);
    avg4 = imclose(avg4,se);
end

%     figure
%     imshow(avg4)

%% select only the parts of the mask that are larger than 100 pixels
avg4 = logical(avg4);
% avg5 = bwareaopen(avg4,10);

% figure
% imshow(avg5)

%% closing
se4 = strel('disk', 40);
seg = imclose(avg4, se4);

% figure
% imshow(seg)

%%
% avg7 = imcomplement(avg6);
% bg1 = bwareafilt(avg7,1);
% 
% avg8 = ones(size(avg5));
% avg8(bg1) = 0;
% figure
% imshow(avg8)

%% open
for i = [0,90]
    se = strel('line', 500, i);
    seg = imclose(seg,se);
end


end