
function [sStims, sStimParams] = FOS_loadStimSet(sStimParams)

%% stimulus set selection
cellAvailSets = {'50_Discs', '50_Ellipses', '25_Discs_25_Ellipses', 'Discs, 25BF, 25FB', '50_Discs_W_BBG'}; %list of available stim sets, manually add new ones

%get user input
indSelected = listdlg('PromptString', {'Select a stimulus set'}, 'SelectionMode', 'single', 'ListString', cellAvailSets);
strSelected = cell2mat(cellAvailSets(indSelected));

%% 50 black discs
if strcmp(strSelected, '50_Discs')
    intTotalStims = 50;
    vecStimSize_deg = [4 4]; %deg
    dblVelocity_deg = 20; %deg/s
    dblStimX_deg = -10; %relative to middle of the screen
    dblStimulus = 0.5;
    intDirection = 0;

    %create stimulus struct
    sStims = struct;
    for intTrial = 1:(intTotalStims)
        sStims(intTrial).vecStimSize_deg = vecStimSize_deg;
        sStims(intTrial).dblVelocity_deg = dblVelocity_deg;
        sStims(intTrial).dblStimX_deg = dblStimX_deg;
        sStims(intTrial).dblStimulus = dblStimulus;
        sStims(intTrial).intStimulus = round(mean(sStims(intTrial).dblStimulus) * 255);
        sStims(intTrial).intDirection = intDirection;
    end

    %% 50 black ellipses
elseif strcmp(strSelected, '50_Ellipses')
    intTotalStims = 50;
    vecStimSize_deg = [4.5 1.5]; %deg
    dblVelocity_deg = 20; %deg/s
    dblStimX_deg = +20; %relative to middle of the screen
    dblStimulus = 0;
    intDirection = 0;

    %create stimulus struct
    sStims = struct;
    for intTrial = 1:(intTotalStims)
        sStims(intTrial).vecStimSize_deg = vecStimSize_deg;
        sStims(intTrial).dblVelocity_deg = dblVelocity_deg;
        sStims(intTrial).dblStimX_deg = dblStimX_deg;
        sStims(intTrial).dblStimulus = dblStimulus;
        sStims(intTrial).intStimulus = round(mean(sStims(intTrial).dblStimulus) * 255);
        sStims(intTrial).intDirection = intDirection;

    end

    %% 25  black discs, 25 black ellipses
elseif strcmp(strSelected, '25_Discs_25_Ellipses')
    intTotalStims = 50;
    vecStimSize_deg = [4 4]; %deg
    dblVelocity_deg = 20; %deg/s
    dblStimX_deg = -10; %relative to middle of the screen
    dblStimulus = 0;
    intDirection = 0;

    %get ellipse indices (random)
    indEllipse = randperm(intTotalStims); indEllipse = indEllipse(1 : round(intTotalStims / 2));

    %create stimulus struct
    sStims = struct;
    for intTrial = 1:(intTotalStims)
        sStims(intTrial).vecStimSize_deg = vecStimSize_deg;
        if ismember(intTrial, indEllipse)
            sStims(intTrial).vecStimSize_deg = [4.5 1.5];
        end
        sStims(intTrial).dblVelocity_deg = dblVelocity_deg;
        sStims(intTrial).dblStimX_deg = dblStimX_deg;
        sStims(intTrial).dblStimulus = dblStimulus;
        sStims(intTrial).intStimulus = round(mean(sStims(intTrial).dblStimulus) * 255);
        sStims(intTrial).intDirection = intDirection;

    end

elseif strcmp(strSelected, 'Discs, 25BF, 25FB')
    intTotalStims = 50;
    vecStimSize_deg = [4.5 1.5]; %deg
    dblVelocity_deg = 20; %deg/s
    dblStimX_deg = 0; %relative to middle of the screen
    dblStimulus = 0;
    intDirection = 0;

    %get BF indices (random)
    indBF = randperm(intTotalStims); indBF = indBF(1 : round(intTotalStims / 2));

    %create stimulus struct
    sStims = struct;
    for intTrial = 1:(intTotalStims)
        sStims(intTrial).vecStimSize_deg = vecStimSize_deg;
        sStims(intTrial).dblVelocity_deg = dblVelocity_deg;
        sStims(intTrial).dblStimX_deg = dblStimX_deg;
        sStims(intTrial).dblStimulus = dblStimulus;
        sStims(intTrial).intStimulus = round(mean(sStims(intTrial).dblStimulus) * 255);
        sStims(intTrial).intDirection = intDirection;
        if ismember(intTrial, indBF)
            sStims(intTrial).intDirection = 1;
        end
    end

elseif strcmp(strSelected, '50_Discs_W_BBG')
    intTotalStims = 50;
    vecStimSize_deg = [4 4]; %deg
    dblVelocity_deg = 20; %deg/s
    dblStimX_deg = -10; %relative to middle of the screen
    dblStimulus = 1;
    intDirection = 0;

    %create stimulus struct
    sStims = struct;
    for intTrial = 1:(intTotalStims)
        sStims(intTrial).vecStimSize_deg = vecStimSize_deg;
        sStims(intTrial).dblVelocity_deg = dblVelocity_deg;
        sStims(intTrial).dblStimX_deg = dblStimX_deg;
        sStims(intTrial).dblStimulus = dblStimulus;
        sStims(intTrial).intStimulus = round(mean(sStims(intTrial).dblStimulus) * 255);
        sStims(intTrial).intDirection = intDirection;
    end

    %black background
    sStimParams.dblBackground = 0;
    sStimParams.intBackground = 0;

elseif strcmp(strSelected, 'robin')
    intTotalStims = 50;
    vecStimSize_deg = [4.5 1.5]; %deg
    dblVelocity_deg = 20; %deg/s
    dblStimX_deg = +20; %relative to middle of the screen
    dblStimulus = 0;
    intDirection = 0;

    %get ellipse indices (random)
    indEllipse = randperm(intTotalStims); indEllipse = indEllipse(1 : round(intTotalStims / 2));

    %create stimulus struct
    sStims = struct;
    for intTrial = 1:(intTotalStims)
        sStims(intTrial).vecStimSize_deg = vecStimSize_deg;
        if ismember(intTrial, indEllipse)
            sStims(intTrial).vecStimSize_deg = [1.5 4.5];
        end
        sStims(intTrial).dblVelocity_deg = dblVelocity_deg;
        sStims(intTrial).dblStimX_deg = dblStimX_deg;
        sStims(intTrial).dblStimulus = dblStimulus;
        sStims(intTrial).intStimulus = round(mean(sStims(intTrial).dblStimulus) * 255);
        sStims(intTrial).intDirection = intDirection;

    end
end

