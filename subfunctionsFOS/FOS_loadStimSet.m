
function sStims = FOS_loadStimSet(sStimParams)

%% stimulus set selection
cellAvailSets = {'20D'}; %list of available stim sets, manually add new ones

%get user input
indSelected = listdlg('PromptString', {'Select a stimulus set'}, 'SelectionMode', 'single', 'ListString', cellAvailSets);
strSelected = cell2mat(cellAvailSets(indSelected));

%% create stimulus set based on UI
if strcmp(strSelected, '20D')
    %20 black discs
    intTotalStims = 4;
    vecStimSize_deg = [4 4]; %deg
    dblVelocity_deg = 20; %deg/s
    dblStimX_deg = -40; %relative to middle of the screen
    dblStimulus = 0;

    %create stimulus struct
    sStims = struct;
    for intTrial = 1:(intTotalStims)
        sStims(intTrial).vecStimSize_deg = vecStimSize_deg;
        sStims(intTrial).dblVelocity_deg = dblVelocity_deg;
        sStims(intTrial).dblStimX_deg = dblStimX_deg;
        sStims(intTrial).dblStimulus = dblStimulus;
        sStims(intTrial).intStimulus = round(mean(sStims(intTrial).dblStimulus) * 255);
    end

end

