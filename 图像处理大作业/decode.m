close all;clear all;clc;
load snow.mat;
load jpegcodes.mat;
load Jpegcoeff.mat;

%解码
N=8;H=height/N;W=width/N;len=H*W; % len=315：[8,8]矩阵块的数量；
len1=strlength(DC_code);
len2=strlength(AC_code);
EOB='1010';
ZRL='11111111001';
DC=[];
AC=zeros(63,len);

cursor=1; % DC_code cursor
while cursor<=len1
    for idx=1:12
        huffman_len=DCTAB(idx,1);
        huffman_temp=num2str(DCTAB(idx,2:1+huffman_len));
        huffman_TAB=regexprep(huffman_temp,' +','');
        huffman_DC=DC_code(cursor:cursor+huffman_len-1);
        if huffman_TAB==huffman_DC
            cursor=cursor+huffman_len; % 更新游标
            category=idx-1;
            if category==0
                bin_len=1;             % bin code length
                dec=0;
            else
                bin_len=category;
                bin_code=DC_code(cursor:cursor+bin_len-1);
                dec=getdecnum(bin_code);
            end          
            cursor=cursor+bin_len;      % 更新游标
            DC=[DC,dec]; 
            break
        end        
    end
end

% Inverse differ
DC_origin=DC; %(1,315)
for idx1=2:len % 2:315
    DC_origin(1,idx1)=DC_origin(1,idx1-1)-DC(1,idx1);
end

Cursor=1;               % AC_code cursor
AC_temp=zeros(1,63);    % temp matrix
matrix_cursor=1;        % sub matrix cursor
matrix_idx=1;           % AC_code column index
while Cursor<len2
    if Cursor+3<=len2   % EOB check
        if strcmp(AC_code(Cursor:Cursor+3),EOB)
            matrix_cursor=1;            % reset matrix cursor = 1
            Cursor=Cursor+4;            % update cursor
            % If Cursor overflow,Cursor-1
            if Cursor>len2
                Cursor=Cursor-1;
            end
            AC(:,matrix_idx)=AC_temp';  % 填充完成一个列矢量；
            AC_temp=zeros(1,63);        % reset AC temp matrix
            matrix_idx=matrix_idx+1;    % add matrix index
        end
    end
    
    if Cursor+10<=len2  % ZRL check
        if strcmp(AC_code(Cursor:Cursor+10),ZRL)
            Cursor=Cursor+11;           % update cursor
            matrix_cursor=matrix_cursor+16;
            if Cursor>len2
                Cursor=Cursor-1;
            end
        end 
    end
    
    for idx3=1:160      % Check and read from ACTAB
        % Check overflow
        if Cursor>=len2
            break
        end       
        huffman_len=ACTAB(idx3,3);
        if Cursor+huffman_len-1>len2
            continue
        end
        huffman_temp=num2str(ACTAB(idx3,4:3+huffman_len));
        huffman_TAB=regexprep(huffman_temp,' +','');
        huffman_AC=AC_code(Cursor:Cursor+huffman_len-1);
        
        if huffman_TAB==huffman_AC
            Cursor=Cursor+huffman_len;  % update cursor
            if Cursor>len2
                Cursor=Cursor-1;
            end
            Run=ACTAB(idx3,1);
            Size=ACTAB(idx3,2);
            bin_code=AC_code(Cursor:Cursor+Size-1);
            Cursor=Cursor+Size;         % update cursor
            if Cursor>len2
                Cursor=Cursor-1;
            end
            dec=getdecnum(bin_code);
            matrix_cursor=matrix_cursor+Run;    % update matrix cursor
            AC_temp(1,matrix_cursor)=dec;
            matrix_cursor=matrix_cursor+1;      % update matrix cursor
            break
        end
    end  
end

% Get the max error
DC_error=max(max(abs(DC_origin-DC_data)));
AC_error=max(max(abs(AC-AC_data)));


% Joint DC_origin and AC : DA
DA=zeros(64,len); %(64,315)
DA(1,:)=DC_origin; %(1,315)
DA(2:64,:)=AC; %(63,315)

% Inverse zigzag
DA_izigzag=zeros(N,len*N); %(8,2520)
for idx=1:315
    DA_izigzag(:,(idx-1)*8+1:idx*8)=izigzag(DA(:,idx)');
end

% Inverse quantificat
DA_iquan=zeros(N,len*N); %(8,2520)
for idx=1:315
    DA_iquan(:,(idx-1)*8+1:idx*8)=DA_izigzag(:,(idx-1)*8+1:idx*8).*QTAB;
end

% IDCT
DA_idct=zeros(N,len*N); %(8,2520)
for idx=1:315
    DA_idct(:,(idx-1)*8+1:idx*8)=idct2(DA_iquan(:,(idx-1)*8+1:idx*8));
end

% Reshape 
Hallgray=zeros(height,width); %(120,168)
for idx=1:H % H=15
   Hallgray((idx-1)*N+1:idx*N,:)=DA_idct(:,(idx-1)*width+1:idx*width);
end

% Add 128 and double2uint8
Hallgray=uint8(Hallgray+128);

% PSNR
error_matrix=abs(snow-Hallgray);
error_sqrt=error_matrix.*error_matrix;
MSE=sum(sum(error_sqrt))/(height*width);
PSNR=10*log10(255^2/MSE);
% Plot and compare
figure;
subplot(1,2,1);imshow(snow);title("编码前");
subplot(1,2,2);imshow(Hallgray);title("解码后");
figure;


function B=izigzag(A) % Inverse zigzag function
% Input 1D array [1,64]
% Output 2D array [8,8]
B_temp=zeros(1,64);
zigzag=[1 2 9 17 10 3 4 11
        18 25 33 26 19 12 5 6
        13 20 27 34 41 49 42 35 
        28 21 14 7 8 15 22 29
        36 43 50 57 58 51 44 37
        30 23 16 24 31 38 45 52
        59 60 53 46 39 32 40 47
        54 61 62 55 48 56 63 64];
A_temp=reshape(A,[8,8])';
B_temp(zigzag)=A_temp;
B=reshape(B_temp,[8,8])';
end
    
function num=getdecnum(str)
len=strlength(str);
if str(1)=='0'
    for idx=1:len
        if str(idx)=='0'
            str(idx)='1';
        else
            str(idx)='0';
        end
    end
    num=-bin2dec(str);  
else
    num=bin2dec(str);
end
end
