clear all,close all,clc;
load('hall.mat'),load('JpegCoeff.mat');
sample_matrix=double(hall_gray(1:8,1:8));
test1=sample_matrix-128;
temp=dct2(ones(8,8)*128);
test2=dct2(sample_matrix);
test2(1,1)=test2(1,1)-temp(1,1);
test2=idct2(test2);
error=max(max(abs(test1-test2)));




