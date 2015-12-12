clear all, close all,  clc;
[LMS,fs] = wavread('outputLMS.wav');
LMS = LMS(1:2646000);
widma = zeros(44100,length(LMS)/44100);
sekundy = zeros(44100,length(LMS)/44100);
j=1;
f=[0:1:44100-1];
f=f';
for i = 1:44100:length(LMS)
    sekundy(:,j) = LMS(i:j*44100);
    j=j+1;
end

for k=1:60
    widma(:,k) = fft(sekundy(:,k));
    widma(:,k) = abs(widma(:,k));
end

% temp =  widma(:,45);
% prz1 = temp(1:250);
% prz2 = temp(251:500);
% prz3 = temp(501:750);
% prz4 = temp(751:1000);
% 
% [ind,max1] = max(prz1);
% [ind,max2] = max(prz2);
% [ind,max3] = max(prz3);
% [ind,max4] = max(prz4);
% max2 = max2+250;
% max3 = max3+500;
% max4 = max4+750;

maxy_przedzial1=[];
maxy_przedzial2=[];
maxy_przedzial3=[];
maxy_przedzial4=[];
for m=1:60
    temp = widma(:,m);
    prz1 = temp(1:250);
    prz2 = temp(251:500);
    prz3 = temp(501:750);
    prz4 = temp(751:1000);
    [ind,max1] = max(prz1);
    [ind,max2] = max(prz2);
    [ind,max3] = max(prz3);
    [ind,max4] = max(prz4);
    max2 = max2+250;
    max3 = max3+500;
    max4 = max4+750;
    
    maxy_przedzial1(m)=max1;
    maxy_przedzial2(m)=max2;
    maxy_przedzial3(m)=max3;
    maxy_przedzial4(m)=max4;
end

plot(1:60,maxy_przedzial1); grid on;
% stem(f(1:250),prz1);

