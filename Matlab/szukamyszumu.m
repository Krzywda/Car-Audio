clear all, close all, clc;
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

stem(widma(:,30),f);
