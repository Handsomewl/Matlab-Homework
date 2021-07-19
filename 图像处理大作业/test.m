clc;
A=Quan(:,1:8);
B=strings(8,8);
%{
for idx1=1:8
for idx2=1:8
    B(idx1,idx2)=mydec2bin(A(idx1,idx2));
end
end
%}
C=arrayfun(add1,A);


function str=getBinCode(sample)
bit_width=length(dec2bin(abs(sample)));
if sample>=0
    str=dec2bin(sample,bit_width);
else
    str=dec2bin(2^bit_width+sample-1,bit_width);
end
end

function str=mydec2bin(num)
str=blanks(8);
if num>=0
    str=dec2bin(num,8);
else
    str=dec2bin(-num,8);
    str(1,1)='1';
end
end

function b=add1(a)
b=a+1;
end

