clear all,close all,clc;
load('hall.mat');
imwrite(hall_color,'color.png');
imfinfo('color.png');
height=120;
width=168;
half_h=height/2,half_w=width/2;
r=min(height,width)/2;
color_matrix1=hall_color;
color_matrix2=hall_color;
for idx_h=1:height
    for idx_w=1:width
        if (half_h-idx_h)^2+(half_w-idx_w)^2<=r^2
            color_matrix1(idx_h,idx_w,1)=255;
            color_matrix1(idx_h,idx_w,2)=0;
            color_matrix1(idx_h,idx_w,3)=0;
        end;
    end
end

len=gcd(height,width);
for idx_h=1:height
    for idx_w=1:width
        if mod((floor(idx_h/len)+floor(idx_w/len)),2)==0
            color_matrix2(idx_h,idx_w,1)=0;
            color_matrix2(idx_h,idx_w,2)=0;
            color_matrix2(idx_h,idx_w,3)=0;
        end;
    end
end

figure,imshow(hall_color);
figure,imshow(color_matrix1);   
figure,imshow(color_matrix2);
            
        


