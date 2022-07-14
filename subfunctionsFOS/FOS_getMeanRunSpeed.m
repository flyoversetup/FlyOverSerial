
function dblSpeed_mps = FOS_getMeanRunSpeed(vecData, vecTime, dblWin)

%FOS_getMeanRunSpeed, Robin Haak '22
%get average speed in window from running wheel encoder pulses
%
%input:
%-vecData           pulse count from encoder
%-vecTime           s, corresponding timestamps
%-dblWin            s, approximate window (e.g., last 1s) to determine speed
%
%output:
%-dblRunSpeed_mps   meter/s, average running speed in dblWin

%% define constants
dblWheelCircumference = 0.534055; %meter
dblPulsesPerCircumference = 1024; %pulses

%% determine running speed
%get values in window
indKeepVals = vecTime >= vecTime(end) - dblWin;
vecDataKeep = vecData(indKeepVals);
vecTimeKeep = vecTime(indKeepVals);

%get run speed
dblSpeed_pps = (vecData(end) - vecDataKeep(1)) / (vecTimeKeep(end) - vecTimeKeep(1)); %pulses/s
dblSpeed_mps = dblSpeed_pps * (dblWheelCircumference / dblPulsesPerCircumference); %meter/s

end



