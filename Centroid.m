function [centroids] = Centroid( photoPath )

%%Load images
Img=imread(photoPath);
imgBin = im2bw(Img, graythresh(Img)); %Convert image to binary image, based on threshold


%%Dilatation
se=strel('disk',4);
BW2=imdilate(imgBin,se);

 
%%Separation between cells according to size
 L=bwlabel(BW2,8);
 mask=zeros(size(BW2));
 
for i=1:max(max(L))
    M=zeros(size(BW2));
    M(L==i)=1;
 if Area_ob(i)> 167
     
   se = strel('disk',5);
   BWM = imerode(M,se);
 else
    se = strel('disk',1);
    BWM = imerode(M,se);
    
 end
 mask=mask+BWM;
end

maskBW=bwlabel(mask,8);


%%Specify the center of mass of the region
centroids = regionprops(maskBW, 'Centroid');

centroids = {centroids.Centroid};


%%Show the real dilated image along with the image of the centroids
imshow(BW2);

hold on;

[m,n] = size(centroids);

for i=1:n
   plot(centroids{i}(1), centroids{i}(2), 'b*');
end
 
end

