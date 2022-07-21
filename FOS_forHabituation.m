
%% GREY BACKGROUND RUNNING for habituation to the setup

%% prepare
clear; close all; Screen('CloseAll');
warning('off','all');
addpath(genpath('C:\Users\setup_1\Documents\GitHub\PresentFlyover'));
addpath(genpath('C:\Users\setup_1\Documents\MonitorGamma'));

%% open screen
intUseScreen = 1; %which screen to use
dblBackgroundIntensity = 0.5; %background intensity (dbl, [0 1]) 
intBackgroundIntensity = round(mean(dblBackgroundIntensity)*255);
Screen('Preference', 'SkipSyncTests', 1);
[ptrWindow, vecRect] = Screen('OpenWindow', intUseScreen, intBackgroundIntensity, []);
load("gammaTable_new.mat");
Screen('LoadNormalizedGammaTable', ptrWindow, gammaTable_new * [1 1 1]);

%% running data

%intiate serial
strSerialPort = 'COM7'; %running wheel port
intBaudRate = 115200; %baudrate
SerialObj = serialport(strSerialPort, intBaudRate);
configureTerminator(SerialObj, 'CR/LF')

%gather data
intSampleRate = 30; %Hz
RateObj = rateControl(intSampleRate);
intTimeToRecord_s = 3600; %s, duration of recording
dblWheelCircumference_m = 0.534055; %m
intPulsesPerCircumference = 1024; %encoder pulses
dblMeterPerPulse = dblWheelCircumference_m/intPulsesPerCircumference;
dblRunningThreshold = 0.2; %m/s

fprintf('\n\n\nStarted @%s\n', getTime);
fprintf('\nGathering data for %.1f minutes...', intTimeToRecord_s/60);

%loop
intSample = 0;
vecPulseCount = zeros(intSampleRate * intTimeToRecord_s, 1);
vecTimeStamps_s = zeros(intSampleRate * intTimeToRecord_s, 1);
hTic = tic;
while intSample < intSampleRate * intTimeToRecord_s + 1
    write(SerialObj, 0, "uint8");
    intSample = intSample + 1;
    vecTimeStamps_s(intSample) = toc(hTic);
    vecPulseCount(intSample) = -(str2double(readline(SerialObj)));
    waitfor(RateObj);
end

fprintf('Done!\n')

%calculate running speed
vecRunningSpeed_ms = (diff(vecPulseCount) ./ diff(vecTimeStamps_s)) * dblMeterPerPulse;
vecRunningTimeStamps_s = (vecTimeStamps_s(2:end));

%plot
plot(vecRunningTimeStamps_s, vecRunningSpeed_ms);
xlim([min(vecRunningTimeStamps_s) max(vecRunningTimeStamps_s)]);
xlabel('Time(s)'); ylabel('Running speed (m/s)');
yline(dblRunningThreshold, 'r--');
fixfig

%rough calculation of %running in session
dblPercentageRunning = (sum(vecRunningSpeed_ms>dblRunningThreshold) / (intSample-1)) * 100;
fprintf('\n\n\n> > > %.1f percent of the time spent running\N', dblPercentageRunning);
fprintf('\n> > > %.3f seconds between samples\n', mean(diff(vecRunningTimeStamps_s)));

%%
pause
Screen('CloseAll');

