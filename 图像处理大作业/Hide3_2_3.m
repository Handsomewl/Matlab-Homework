clear all;close all;clc;
load 'hall.mat';
load 'JpegCoeff.mat';

info='Pass random process randomly';

Bin_code=dec2bin(length(info)*8,16);    % 前16位用来表示有效长度；
ASCII=double(info);                 % get ASCII code
Bin=dec2bin(ASCII,8);               % get binary code
for idx=1:length(info)
    Bin_code=strcat(Bin_code,Bin(idx,:));
end
Info=zeros(1,length(Bin_code));
for idx=1:length(Bin_code)
    Info(idx)=2*bin2dec(Bin_code(idx))-1;
end


% Gray minus 128
hall=double(hall_gray)-128;
[height,width]=size(hall); % [120,168]
N=8;H=height/N;W=width/N;len=H*W; % len=315

% Reshape Hall
A=zeros(N,len*N);
for idx=1:H % H=15
   A(:,(idx-1)*width+1:idx*width)=hall((idx-1)*N+1:idx*N,:);
end

% DCT
DCT=zeros(N,len*N); %[8,2520]
for idx=1:len
    DCT(:,(idx-1)*N+1:idx*N)=dct2(A(:,(idx-1)*N+1:idx*N));
end


% Quantificat
Quan=zeros(N,len*N); %[8,2520]
for idx=1:len
    Quan(:,(idx-1)*N+1:idx*N)=round(DCT(:,(idx-1)*N+1:idx*N)./QTAB);
end


% Zigzag
Zig=zeros(N*N,len); %[64,315]
for idx=1:len
    Zig(:,idx)=zigzag(Quan(:,(idx-1)*N+1:idx*N))';
end

% Replace method3
Hide=Zig; %[64,315]
for idx=1:length(Info)
    END=64;
    if Hide(END,idx)~=0
        Hide(END,idx)=Info(idx);
        continue;
    end
    while Hide(END,idx)==0 && END>=1
        END=END-1;
    end
    Hide(END+1,idx)=Info(idx);
end




% Encode DC and AC
DC_data=Hide(1,:); %(1,315) 
DC_differ=DC_data; 
for idx=2:315
    DC_differ(1,idx)=DC_data(1,idx-1)-DC_data(1,idx);
end

DC_code=''; % create empty string
for idx1=1:len % len=315
    category=ceil(log2(abs(DC_differ(1,idx1))+1));
    bin_code=getBinCode(DC_differ(1,idx1));
    huffman_code=readFromDCTAB(category); 
    DC_code=strcat(DC_code,huffman_code,bin_code);
end

AC_data=Hide(2:64,:);
AC_code=''; % create empty string
ZRL='11111111001';
EOB='1010';

for idx2=1:len % len=315
    AC_subdata=AC_data(:,idx2)'; % [1,63] 按照习惯转换成行矩阵进行处理；
    Cursor=1;END=63;Run=0;
    
    while AC_subdata(1,END)==0 && END>=2
        END=END-1;       
    end
    if END==1 && AC_subdata(1,1)==0 % 对应63个0的情况；
        AC_code=strcat(AC_code,EOB);
        continue
    end
    
    while Cursor<=END
        if AC_subdata(1,Cursor)==0
            if Run==15
                AC_code=strcat(AC_code,ZRL);
                Run=0;Cursor=Cursor+1;
            else
                Run=Run+1;Cursor=Cursor+1;                
            end            
        else
            Size=ceil(log2(abs(AC_subdata(1,Cursor))+1)); % 对应category
            huffman_code=readFromACTAB(Run,Size);
            bin_code=getBinCode(AC_subdata(1,Cursor));
            AC_code=strcat(AC_code,huffman_code,bin_code);
            Cursor=Cursor+1; Run=0;
        end        
    end
    AC_code=strcat(AC_code,EOB);        
end

% Save vars
save('jpegcodes.mat','DC_code','AC_code','height','width','DC_data','AC_data');

% Compute Ratio
Input_length=height*width*8;
Output_length=strlength(DC_code)+strlength(AC_code);
ratio=Input_length/Output_length;


function str=getBinCode(sample)
bit_width=length(dec2bin(abs(sample)));
if sample>=0
    str=dec2bin(sample,bit_width);
else
    str=dec2bin(2^bit_width+sample-1,bit_width);
end
end

function str=readFromDCTAB(category)
load JpegCoeff.mat;
idx=category+1;
len=DCTAB(idx,1);
bindata=DCTAB(idx,2:1+len);
str_temp=num2str(bindata);
str=regexprep(str_temp,' +',''); %去掉字符串中的空格；
end

function str=readFromACTAB(Run,Size)
load JpegCoeff.mat;
for idx=1:160
    if ACTAB(idx,1)==Run && ACTAB(idx,2)==Size
        len=ACTAB(idx,3);
        bindata=ACTAB(idx,4:3+len);
        str_temp=num2str(bindata);
        % https://www.mathworks.com/matlabcentral/answers/104340-removing-multiple-blanks-for-a-string
        str=regexprep(str_temp,' +',''); %去掉空格； doc regexprep;
        break
    end
end
end

function B=zigzag(A)
[H,W]=size(A);
if H~=8 && W~=8
    error('Input array is not 8×8');
end
zigzag=[1 2 9 17 10 3 4 11
        18 25 33 26 19 12 5 6
        13 20 27 34 41 49 42 35 
        28 21 14 7 8 15 22 29
        36 43 50 57 58 51 44 37
        30 23 16 24 31 38 45 52
        59 60 53 46 39 32 40 47
        54 61 62 55 48 56 63 64];
A_temp=reshape(A',[1,64]);
B_temp=A_temp(zigzag);
B=reshape(B_temp',[1,64]);
end

