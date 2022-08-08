function dblSpeed_mps = FOS_getRunSpeed(vecData, dblSampRate, dblWin)

%FOS_getMeanRunSpeed, Robin Haak '22
%get average speed in window from running wheel encoder pulses
%
%input:
%-vecData           pulse count from encoder
%-dblSampRate       Hz, measured running wheel sampling rate
%-dblWin            s, window to calculate speed

%output:
%-dblRunSpeed_mps   meter/s, average running speed in dblWin

%% define constants
dblWheelCircumference = 0.534055; %meter
dblPulsesPerCircumference = 1024; %pulses

%% determine running speed

if length(vecData) > round(dblSampRate) * dblWin
    %get first and last count within window
    intCount_0 = vecData(end - (round(dblSampRate) * dblWin));
    intCount_1 = vecData(end);

    %get run speed
    dblSpeed_pps = (intCount_1  - intCount_0) / dblWin; %pulses/s
    dblSpeed_mps = dblSpeed_pps * (dblWheelCircumference / dblPulsesPerCircumference); %meter/s

else
    dblSpeed_mps = 0;
end

end
