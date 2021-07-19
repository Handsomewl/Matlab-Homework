clear all,close all,clc;
load('hall.mat'),load('JpegCoeff.mat');

%预处理
hall=double(hall_gray(9:16,9:16)-128);
test1=dct2(hall);

%手动实现dct2
N=8;
D=zeros(N,N);
D(1,:)=sqrt(2/N)*sqrt(1/2);
for i=2:N
    for j=1:N
        D(i,j)=sqrt(2/N)*cos((2*j-1)*(i-1)*pi/(2*N));
    end
end
test2=D*hall*D';
error=max(max(abs(test1-test2)));

len=80;
image_sample=hall_gray(1:len,1:len);
image_array=double(image_sample-128);
DCT=dct2(image_array);
DCT_right0=DCT,DCT_right0(:,len-3:len)=0;
DCT_left0=DCT,DCT_left0(:,1:4)=0;
image_right=uint8(idct2(DCT_right0)+128);
image_left=uint8(idct2(DCT_left0)+128);
%figure,imshow(image_sample);
%figure,imshow(image_right);
%figure,imshow(image_left);

DCT_T=DCT';
DCT_90=rot90(DCT);
DCT_180=rot90(DCT,2);
image_t=uint8(idct2(DCT_T)+128);
image_90=uint8(idct2(DCT_90)+128);
image_180=uint8(idct2(DCT_180)+128);
figure,imshow(image_t),title('dct-t');
figure,imshow(image_90),title('dct-90');
figure,imshow(image_180),title('dct-180');






        


