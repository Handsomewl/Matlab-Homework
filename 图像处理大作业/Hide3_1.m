clear all;close all;clc
load hall.mat;
load JpegCoeff.mat;

info='Pass probability theory and random process randomly';
len=length(info);       % 信息字符串长度
bit_length=len*8;       % 比特流长度
ASCII=double(info);     % get ASCII code
Bin=dec2bin(ASCII,8);   % get binary code

% 用16位二进制码表示bit length,即最大的比特流长度为65536；
bin_code=dec2bin(bit_length,16);
for idx=1:len
    bin_code=strcat(bin_code,Bin(idx,:));
end
% replace least bit
[height,width]=size(hall_gray);
hall_temp=dec2bin(hall_gray,8);
for idx1=1:length(bin_code)
    hall_temp(idx1,8)=bin_code(idx1);
end
% get new hall matrix
hall=bin2dec(hall_temp);
hall=uint8(reshape(hall,[height,width]));
% Decode
hall_temp=dec2bin(hall,8); 
LEN='';
LEN=strcat(LEN,hall_temp(1:16,8))';
Bin_len=bin2dec(LEN);

Bin_rebuild='';
Bin_rebuild=strcat(Bin_rebuild,hall_temp(17:16+Bin_len,8))';
ASCII_reb=zeros(1,Bin_len/8);
for idx=1:Bin_len/8
    ASCII_reb(1,idx)=bin2dec(Bin_rebuild((idx-1)*8+1:idx*8));
end
info_rebuild=char(ASCII_reb);