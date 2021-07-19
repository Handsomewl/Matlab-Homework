clear all;close all;clc
% train v
% 定位33张图片
v3=zeros(1,2^9);
v4=zeros(1,2^12);
v5=zeros(1,2^15);

for k=1:33
    filename=strcat('C:\Users\THU-EE-WL\Desktop\Matlab-Homework\图像处理大作业\图像处理所需资源\Faces\',int2str(k),'.bmp');
    RGB=double(imread(filename));
    [height,width,color]=size(RGB);
    R=RGB(:,:,1);
    G=RGB(:,:,2);
    B=RGB(:,:,3);
       
    for L=3:5
        Rtemp=dec2bin(floor(R/2^(8-L)),L);
        Gtemp=dec2bin(floor(G/2^(8-L)),L);
        Btemp=dec2bin(floor(B/2^(8-L)),L);
        RGBtemp=[Rtemp,Gtemp,Btemp];
        RGBtemp=bin2dec(RGBtemp)+1; %数组索引要求必须是正值
        [len,bit_len]=size(RGBtemp);             
        switch L
            case 3
                v3_temp=zeros(1,2^9);
                for idx=1:len
                    v3_temp(1,RGBtemp(idx,1))=v3_temp(1,RGBtemp(idx,1))+1;
                end
                v3=v3+v3_temp/len;
            case 4
                v4_temp=zeros(1,2^12);
                for idx=1:len
                    v4_temp(1,RGBtemp(idx,1))=v4_temp(1,RGBtemp(idx,1))+1;
                end
                v4=v4+v4_temp/len;
            case 5
                v5_temp=zeros(1,2^15);
                for idx=1:len
                    v5_temp(1,RGBtemp(idx,1))=v5_temp(1,RGBtemp(idx,1))+1;
                end
                v5=v5+v5_temp/len;
        end

    end        
end
v3=v3/33;
v4=v4/33;
v5=v5/33;

figure;
subplot(3,1,1);plot(v3);title('v3');
subplot(3,1,2);plot(v4);title('v4');
subplot(3,1,3);plot(v5);title('v5');

save('train.mat','v3','v4','v5');









