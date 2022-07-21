
function [dblStimOn,dblStimOff]= FOS_customDraw(ptrWindow,intStimNr,sStimParams)
%FOS_customDraw
%version 21 July '22, Robin Haak

	%% get onset timestamp
    hTic = sStimParams.hTic;
    dblStimOn = toc(hTic);
	
    %% draw on screen
    %retrieve stimulus parameters
    sStim = sStimParams.sStims(intStimNr);

    if sStim.intDirection == 0 %front-to-bacl

        %loop through frames
        dblStimY_pix = sStimParams.intScreenHeight_pix;
        dblStamp = Screen('Flip', ptrWindow);

        for intFrame = 1:sStim.intNumFrames
            vecBoundingRect = [sStim.dblStimX_pix - sStim.vecStimSize_pix(1) / 2, dblStimY_pix, ...
                sStim.dblStimX_pix + sStim.vecStimSize_pix(1) / 2, dblStimY_pix + sStim.vecStimSize_pix(2)];
            Screen('FillOval', ptrWindow, sStim.intStimulus, vecBoundingRect);
            dblStamp = Screen('Flip', ptrWindow, dblStamp + 0.5 / sStimParams.dblStimFrameRate);
            dblStimY_pix = dblStimY_pix - sStim.dblPixelsPerFrame;
        end

    elseif sStim.intDirection == 1 %back-to-front

        %loop through frames
        dblStimY_pix = 0;
        dblStamp = Screen('Flip', ptrWindow);

        for intFrame = 1:sStim.intNumFrames
            vecBoundingRect = [sStim.dblStimX_pix - sStim.vecStimSize_pix(1) / 2, dblStimY_pix, ...
                sStim.dblStimX_pix + sStim.vecStimSize_pix(1) / 2, dblStimY_pix + sStim.vecStimSize_pix(2)];
            Screen('FillOval', ptrWindow, sStim.intStimulus, vecBoundingRect);
            dblStamp = Screen('Flip', ptrWindow, dblStamp + 0.5 / sStimParams.dblStimFrameRate);
            dblStimY_pix = dblStimY_pix + sStim.dblPixelsPerFrame;
        end
    end
    	Screen('Flip', ptrWindow, dblStamp + 0.5 / sStimParams.dblStimFrameRate);

    	%% get offset timestamp
        dblStimOff = toc(hTic);

	%% save temp object
	%save object
	sObject = sStimParams;
    
	%add timestamps
	sObject.dblStimOnNI = dblStimOn;
	sObject.dblStimOffNI = dblStimOff;
	sObject.intStimType = 1;%  intStimType;
	save(fullfile(sStimParams.strTempObjectPath,['Object', num2str(intStimNr), '.mat']), 'sObject');
end