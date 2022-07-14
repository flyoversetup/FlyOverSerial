
function [dblStimOn,dblStimOff]= FOS_customDraw(ptrWindow,intStimNr,sStimParams)
%FOS_customDraw
%version 27 June '22, Robin Haak

	%% get onset timestamp
    hTic = sStimParams.hTic;
    dblStimOn = toc(hTic);
	
    %% draw on screen
	%retrieve stimulus parameters
	sStim = sStimParams.sStims(intStimNr);
	
	%loop through frames
	dblStimY_pix = sStimParams.intScreenHeight_pix;
	dblStamp = Screen('Flip', ptrWindow);
	
	for intFrame = 1:sStim.intNumFrames
		vecBoundingRect = [sStim.dblStimX_pix-sStim.vecStimSize_pix(1)/2, dblStimY_pix, ...
			sStim.dblStimX_pix+sStim.vecStimSize_pix(1)/2, dblStimY_pix+sStim.vecStimSize_pix(2)];
		Screen('FillOval', ptrWindow, sStim.intStimulus, vecBoundingRect);
		dblStamp = Screen('Flip', ptrWindow, dblStamp+0.5/sStimParams.dblStimFrameRate);
		dblStimY_pix = dblStimY_pix-sStim.dblPixelsPerFrame;
	end
	
	Screen('Flip', ptrWindow, dblStamp+0.5/sStimParams.dblStimFrameRate);
	
	%% get offset timestamp
    dblStimOff = toc(hTic);
	
	%% save temp object
	%save object
	sObject = sStimParams;
    
	%add timestamps
	sObject.dblStimOnNI = dblStimOn;
	sObject.dblStimOffNI = dblStimOff;
	sObject.intStimType = 1;%  intStimType;
	save(fullfile(sStimParams.strTempObjectPath,['Object',num2str(intStimNr),'.mat']),'sObject');
end