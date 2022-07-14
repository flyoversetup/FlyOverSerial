
%FOS_runLocomotionFeedback
%version 14 July 2022, Robin Haak

%% prepare
clear

%% set debug switchEes
boolDebug = false;
boolUseRunWheel = true;

%% input parameters
fprintf('Loading settings...\n');
if ~exist('sStimParamsSettings','var') || isempty(sStimParamsSettings)

    %general
    sStimParamsSettings = struct;
    sStimParamsSettings.strOutputPath = '\\vs03\VS03-CSF-1\Haak'; %'C:\_Data';
    sStimParamsSettings.strTempObjectPath = 'C:\_Temp';
    sStimParamsSettings.strProject = 'Innate_defense';
    sStimParamsSettings.strDataset = 'xx.xx.xx';
    sStimParamsSettings.strMouseID = 'xxxxxxx';
    sStimParamsSettings.intSessionNumber = 1;
    sStimParamsSettings.strCondition = '';
    sStimParamsSettings.strSetup = 'FlyOver_setup';
    sStimParamsSettings.strStimType = 'FlyOver';
    sStimParamsSettings.strInvestigator = 'Robin_Haak';
    sStimParamsSettings.strDate = getDate;

    %visual space parameters
    sStimParamsSettings.dblSubjectPosX_cm = 0; % cm; relative to center of screen
    sStimParamsSettings.dblSubjectPosY_cm = 0; % cm; relative to center of screen, not important for FlyOver stim
    sStimParamsSettings.dblScreenDistance_cm = 23; % cm; measure [23]

    %screen variables
    sStimParamsSettings.dblScreenWidth_cm = 51; % cm; measured [51]
    sStimParamsSettings.dblScreenHeight_cm = 29; % cm; measured [29]
    sStimParamsSettings.dblScreenWidth_deg = 2 * atand(sStimParamsSettings.dblScreenWidth_cm / (2 * sStimParamsSettings.dblScreenDistance_cm));
    sStimParamsSettings.dblScreenHeight_deg = 2 * atand(sStimParamsSettings.dblScreenHeight_cm / (2 * sStimParamsSettings.dblScreenDistance_cm));
    sStimParamsSettings.intUseScreen = 1; %which screen to use
    sStimParamsSettings.dblBackground = 0.5; %background intensity (dbl, [0 1])
    sStimParamsSettings.intBackground = round(mean(sStimParamsSettings.dblBackground) * 255);

    %stimulus trigger variables
    sStimParamsSettings.dblIntialBlank = 0; %s, duration of initial blank
    sStimParamsSettings.dblTrialInterval = 5; %s, minimal inter-trial interval
    sStimParamsSettings.dblRunThreshold = 0.2; %m/s, running speed threshold for triggering the stimulus
    sStimParamsSettings.dblRunThresholdTime = 5; %s, threshold should be exceeded for at least X seconds

    %serial
    sStimParamsSettings.strWheelComPort = 'COM7';
    sStimParamsSettings.strRPiComPort = 'COM3'; %COM3 % '', if not in use
    sStimParamsSettings.intBaudRate = 115200;

else
    % evaluate and assign pre-defined values to structure
    cellFields = fieldnames(sStimParamsSettings);
    for intField=1:numel(cellFields)
        try
            sStimParamsSettings.(cellFields{intField}) = eval(sStimParamsSettings.(cellFields{intField}));
        catch
            sStimParamsSettings.(cellFields{intField}) = sStimParamsSettings.(cellFields{intField});
        end
    end
end

%to keep stuff the same as at the npx
sStimParams = sStimParamsSettings;
if boolDebug == true
    sStimParams.intUseScreen = 0;
end

%% query user for experiment metadata, set experiment output path, create json file
if boolDebug == false
    cellPrompt = {'strProject', 'strDatase (i.e., SD number)', 'strMouseID', 'intSessionNumber', 'strCondition'};
    strDlgTitle = 'PresentFlyover metedata';
    cellDefInput = {sStimParams.strProject, sStimParams.strDataset, sStimParams.strMouseID, num2str(sStimParams.intSessionNumber), sStimParams.strCondition};
    cellAnswer = inputdlg(cellPrompt,strDlgTitle,[1 50],cellDefInput);

    %update sStimParams
    sStimParams.strProject = cellAnswer{1};
    sStimParams.strDataset = cellAnswer{2};
    sStimParams.strMouseID = cellAnswer{3};
    sStimParams.intSessionNumber = str2double(cellAnswer{4});
    sStimParams.strCondition = cellAnswer{5};

    %set experiment-specific output path
    strExperimentName = [sStimParams.strMouseID '_' sStimParams.strDate '_' sprintf('%03d', sStimParams.intSessionNumber)];
    strSessionOutputPath = [sStimParams.strOutputPath filesep sStimParams.strProject filesep sStimParams.strDataset ...
        filesep sStimParams.strMouseID filesep strExperimentName];
    if ~exist(strSessionOutputPath, 'dir')
        mkdir(strSessionOutputPath);
        fprintf('Saving to: %s\n', strSessionOutputPath)
    else
        error('A folder with the name "%s" already exists', strSessionOutputPath); %so we don't overwrite data!
    end

    %for json file (saved later)
    sJson = struct;
    sJson.version = '1.0'; %not sure if this is necessary
    sJson.date = sStimParams.strDate;
    sJson.project = sStimParams.strProject;
    sJson.dataset = sStimParams.strDataset;
    sJson.subject = sStimParams.strMouseID;
    sJson.session = sStimParams.intSessionNumber;
    sJson.investigator = sStimParams.strInvestigator;
    sJson.setup = sStimParams.strSetup;
    sJson.stimulus = sStimParams.strStimType;
    sJson.condition = sStimParams.strCondition;
    sJson.logfile = [strExperimentName '.mat'];
end

%% select stimulus set
sStims = FOS_loadStimSet(sStimParams);

%add to sStimParams for memory mapping
sStimParams.sStims = sStims;

%get total number of trials & approx. trial duration
intNumTrials = length(sStims);
dblApproxStimDur = ceil((sStimParams.dblScreenHeight_deg+sStims(1).vecStimSize_deg(2))/sStims(1).dblVelocity_deg);

%% initialize serial communication with running wheel
if boolUseRunWheel == true
    fprintf('Initializing serial communication...\n')
    if exist('SerialWheelObj', 'var')
        clearvars SerialWheelObj;
    end
    SerialWheelObj = serialport(sStimParamsSettings.strWheelComPort, sStimParamsSettings.intBaudRate);
    configureTerminator(SerialWheelObj, 'CR/LF');

    %check if running wheel is working
    pause(2);
    write(SerialWheelObj, 0, "uint8");
    while isnan(str2double(readline(SerialWheelObj)))
        pause(0.1)
        write(SerialWheelObj, 0, "uint8");
    end
end

%% start experiment
try
    %% prepare
    hTic = tic;
    sStimParams.hTic = hTic; %for memory mapping

    %memory mapping
    mmapSignal = FOS_InitMemMap('dataswitch', [0 0]);
    mmapParams = FOS_InitMemMap('sStimParams', sStimParams); %#ok<NASGU>
    clear mmapParams;

    %initialize/pre-allocate
    intStimNumber = 0;
    intRunSample = 0;
    vecRunData = [];
    vecRunTime = [];
    dblLastStim = 0;
    dblWheelSampRate = 185; %Hz; measured
    vecRunSpeed = zeros(sStimParams.dblRunThresholdTime * dblWheelSampRate, 1);
    intRunTemp = 1;

    %% wait for other matlab to join memory map
    fprintf('Preparation complete. Waiting for PTB matlab to join the memory map...\n');
    while mmapSignal.Data(2) == 0
        pause(0.1);
    end

    %% run until escape button is pressed or all stimuli are shown
    while intStimNumber <= intNumTrials && ~CheckEsc()

        %request encoder update
        if boolUseRunWheel == true
            write(SerialWheelObj, 0, "uint8");
        end

        %check if there are still stimuli to show
        if intStimNumber == intNumTrials && toc(hTic) > (dblLastStim + sStimParams.dblTrialInterval) %assuming that ITI > stim duration
            break
        end

        %get encoder data
        if boolUseRunWheel == true
            intRunSample = intRunSample + 1;
            vecRunData(intRunSample) = -(str2double(readline(SerialWheelObj))); %#ok<SAGROW>
            vecRunTime(intRunSample) = toc(hTic); %#ok<SAGROW>


            %convert to speed and check if running threshold is crossed
            dblRunSpeed = FOS_getMeanRunSpeed(vecRunData, vecRunTime, 1); %get mean speed over the last second
        else
            dblRunSpeed = 2;
        end

        if intRunTemp >= length(vecRunSpeed)
            intRunTemp = 1;
        end

        vecRunSpeed(intRunTemp) = dblRunSpeed;
        intRunTemp = intRunTemp + 1;
        boolRunThresholdCrossed = sum(vecRunSpeed > sStimParams.dblRunThreshold) > 0.95 * length(vecRunSpeed);

        %show next stim when all conditions are met
        if intStimNumber < intNumTrials && boolRunThresholdCrossed && (toc(hTic) > (dblLastStim + dblApproxStimDur + sStimParams.dblTrialInterval))

            %increment trial & log timestamp
            intStimNumber = intStimNumber + 1;
            dblLastStim = toc(hTic);
            fprintf('Stim %d started at %s (run speed was %.3f)\n', intStimNumber, getTime, dblRunSpeed);

            %start stimulus
            mmapSignal.Data(1) = intStimNumber;
            % 			mmapSignal.Data(2) = intStimType;
        end
    end

    %signal end
    mmapSignal.Data(1) = -1;
    % 	mmapSignal.Data(2) = -1;

    %% wait for other matlab to join the memory map
    fprintf('Experiment complete. Waiting for PTB matlab to send data...\n');
    while ~all(mmapSignal.Data == -2)
        pause(0.1);
    end
    fprintf('Data received! Sending exit signal to PTB matlab and & saving data.\n');

    %% retrieve trial data
    mmapData = FOS_JoinMemMap('sTrialData','struct');
    sTrialData = mmapData.Data;

    %save stim-based data
    structEP.TrialNumber = sTrialData.TrialNumber;
    structEP.ActStimType = sTrialData.ActStimType;
    structEP.ActOn = sTrialData.ActOn;
    structEP.ActOff = sTrialData.ActOff;

    %add sStims struct to structEP
    structEP.sStimParamsTrial = sStims;
    sStimParams = rmfield(sStimParams, 'sStims'); %remove field from 'sStimParams', was only used for memory mapping

    %save running data
    structWheel.vecRunData = vecRunData;
    structWheel.vecRunTime = vecRunTime;

    %signal retrieval
    mmapSignal.Data(1) = -3;
    mmapSignal.Data(2) = -3;

    %% save data
    %save data
    if boolDebug == false
        structEP.sStimParams = sStimParams;
        save(fullfile(strSessionOutputPath, 'structEP'), 'structEP');
        structRun.sStimParams = sStimParams;
        save(fullfile(strSessionOutputPath, 'structWheel'), 'structWheel', '-v7.3');

        %create .json file
        strJsonFullName = [strSessionOutputPath filesep strExperimentName '_session.json'];
        savejson('', sJson, strJsonFullName);
    end

    %clean up
    fprintf('\nExperiment is finished at [%s], closing down and cleaning up...\n',getTime);

catch ME
    %% catch me and throw me
    fprintf('\n\n\nError occurred! Trying to save data and clean up...\n\n\n');
    
    if boolDebug == false
        structEP.sStimParams = sStimParams;
        save(fullfile(strSessionOutputPath, 'structEP'), 'structEP');
        structRun.sStimParams = sStimParams;
        save(fullfile(strSessionOutputPath, 'structWheel'), 'structWheel', '-v7.3');

        %create .json file
        strJsonFullName = [strSessionOutputPath filesep strExperimentName '_session.json'];
        savejson('', sJson, strJsonFullName);
    end

    %% show error
    rethrow(ME);
end