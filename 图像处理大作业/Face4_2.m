clear all;close all;clc
load train.mat;
filename='C:\Users\THU-EE-WL\Desktop\TEST.jpg';

RGB=imread(filename);
%RGB=double(imrotate(imread(filename),-90));
%RGB=double(imadjust(RGB,[0.1 0.1 0.1;0.5 0.5 0.5],[])); %doc imadjust
%RGB=imresize(RGB,[height,2*width]);
%width=2*width;
[height,width,color]=size(RGB);
RGB=double(RGB);

LEN=16; % block length ���Ե����Ĳ�����

H=fix(height/LEN);
W=fix(width/LEN);
R=RGB(:,:,1);
G=RGB(:,:,2);
B=RGB(:,:,3);
mark=zeros(H,W); % mark matrix


L=4;v=v4;epsilon=0.695;
for idh=1:H
for idw=1:W
    target_r=R((idh-1)*LEN+1:idh*LEN,(idw-1)*LEN+1:idw*LEN);
    target_g=G((idh-1)*LEN+1:idh*LEN,(idw-1)*LEN+1:idw*LEN);
    target_b=B((idh-1)*LEN+1:idh*LEN,(idw-1)*LEN+1:idw*LEN);
    % ��ȡĿ���������ά��ɫ��������
    
    u=zeros(1,2^(3*L)); % Ƶ�ʷ�������
    for idx1=1:LEN
    for idx2=1:LEN
        r=target_r(idx1,idx2);
        g=target_g(idx1,idx2);
        b=target_b(idx1,idx2);
        kind=floor(r/(2^(8-L)))*2^(2*L)+floor(g/(2^(8-L)))*2^L+floor(b/(2^(8-L)));
        if kind>=0 && kind<2^(3*L)
            u(kind+1)=u(kind+1)+1;
        end
    end
    end
    u=u/(LEN^2);    % �õ�һ�������ɫƵ�ʷ�����
    
    % compute error and mark;
    err=1-sum(sqrt(v).*sqrt(u));
    if err<epsilon       % epsilon�ǿɵ�������
        mark(idh,idw)=1; % �������㹻С���ͱ�Ǹ�����
    end 
end
end

% �� mark matrix ������ֵ�˲� 3*3
for idx1=2:H-1
for idx2=2:W-1
    temp=mark(idx1-1:idx1+1,idx2-1:idx2+1);
    middle=mean(temp(1:9));
    mark(idx1,idx2)=round(middle); % 5��9��ֵ��
end
end

% ������ȡ
[L,n]=bwlabel(mark); %n����������ͨ������
coor=zeros(n,4);
for k=1:n
    [r,c]=find(L==k);
    coor(k,1)=min(r); %��ֱ������С
    coor(k,2)=max(r); %��ֱ�������
    coor(k,3)=min(c); %ˮƽ������С
    coor(k,4)=max(c); %ˮƽ�������
end
% �п��ܳ��ֵ����Ĵ�ֱ�߻���ˮƽ�ߣ�

% ��������
for k=1:n
    %if coor(k,1)~=coor(k,2) && coor(k,3)~=coor(k,4)
    a=(coor(k,1)-1)*LEN+1;
    b= coor(k,2)*LEN;
    c=(coor(k,3)-1)*LEN+1;
    d=coor(k,4)*LEN;
    for i=1:height
    for j=1:width
        % �߽��ж�������
        if(i>=a&&i<=b&&j>=c&&j<=d)
        if(i<=(a+2)||i>=(b-2)||j<=(c+2)||j>=(d-2))
            RGB(i,j,1)=255;
            RGB(i,j,2)=0;
            RGB(i,j,3)=0;
        end
        end
    end
    end
end

imshow(uint8(RGB));
imwrite(uint8(RGB),'TETS_check.png','png');





