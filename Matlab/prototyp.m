clear all;
%1. wczytuje pliki audio

[car,~] = audioread('uptown_v140_g50.wav'); % nagranie z samochodu
[org,Fs] = audioread('uptown_funk.wav'); % nagranie oryginalne
org = org(:,1); %wycinam jeden kana³ z oryginalnego pliku
car=car(1:60*Fs);
org=org(1:60*Fs);
%2. LMS

LMS = NLMS(0.002,40,car,org,1); %korzystam z filtru LMS i odfiltrowuje szum z sygna³u do outLMS
audiowrite('LMS.wav',LMS,Fs);
audiowrite('org.wav',org,Fs);
audiowrite('car.wav',car,Fs);

s = Fs*floor(length(LMS)/Fs);
LMS = LMS(1:s); %obciecie LMS do takiej ilosci probek zeby bylo wielokrotnoscia fs
widma = zeros(Fs,s/Fs); %deklaracja macierzy na widma
sekundy = zeros(Fs,s/Fs); %podzielenie nagrania po sekundzie
j=1; %licznik petli do dzielenia
f=[0:1:Fs-1];  %macierz czestotliwosci do stema
f=f';  
%podzial na sekundy
for i = 1:Fs:length(LMS)
    sekundy(:,j) = LMS(i:j*Fs);
    j=j+1;
end
%policzenie z kazdej sekundy abs(fft)
for k=1:60
    widma(:,k) = fft(sekundy(:,k));
    widma(:,k) = (abs(widma(:,k))).^2;
end


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

Wo=[mode(maxy_przedzial1)/(Fs/2),mode(maxy_przedzial2)/(Fs/2),mode(maxy_przedzial3)/(Fs/2),mode(maxy_przedzial4)/(Fs/2)];
%projektuje wyliczony filtr
N  = 2; %rz¹d filtru
G  = 15; % gain (jak obliczyæ gain?)
BW = 15/(Fs/2); %pasmo

%filtr 1
[SOS1,SV1] = iirparameq(N,G,Wo(1),BW); %SOS,SV - wspó³czynniki filtru
BQ1 = dsp.BiquadFilter('SOSMatrix',SOS1,'ScaleValues',SV1);

%filtr2
[SOS2,SV2] = iirparameq(N,G,Wo(2),BW); %SOS,SV - wspó³czynniki filtru
BQ2 = dsp.BiquadFilter('SOSMatrix',SOS2,'ScaleValues',SV2);


%filtr3
[SOS3,SV3] = iirparameq(N,G,Wo(3),BW); %SOS,SV - wspó³czynniki filtru
BQ3 = dsp.BiquadFilter('SOSMatrix',SOS3,'ScaleValues',SV3);


%filtr4
[SOS4,SV4] = iirparameq(N,G,Wo(4),BW); %SOS,SV - wspó³czynniki filtru
BQ4 = dsp.BiquadFilter('SOSMatrix',SOS4,'ScaleValues',SV4);

filtered=step(BQ1,org);
filtered=step(BQ2,filtered);
filtered=step(BQ3,filtered);
filtered=step(BQ4,filtered);

audiowrite('filtered.wav',filtered,Fs);

filteredcar=step(BQ1,car);
filteredcar=step(BQ2,filteredcar);
filteredcar=step(BQ3,filteredcar);
filteredcar=step(BQ4,filteredcar);
audiowrite('filteredcar.wav',filteredcar,Fs);