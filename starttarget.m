% uncomment following lines to test changing parameters without re-compile
% uncomment through line 11 - WHEN RUNNING FROM MATLAB UI
% waveTypeNew = 'regular';
% waveTNew = 2.5;
% waveHNew = .136;
% param1New = 10;
% param2New = 10;
% param3New = 5;
% param4New = 5;

% UNCOMMENT FOLLOWING LINES IF RUNNING FROM UI BUT DON'T WANT TO MODIFY ANY
% PARAMS
% waveTypeNew = waveType;
% waveTNew = waveT;
% waveHNew = waveH;
% param1New = param1;
% param2New = param2;
% param3New = param3;
% param4New = param4;

clear logsout; % when restarting - clear previous data file

% with wecsim - cannot change any wave parameters without a re-compile  
% if strcmp(twinModelName, 'WECSim')
%     waveHNew = waveH;
%     waveTypeNew = waveType;
%     waveTNew = waveT;
% end


% check if we need to recalculate the wave info
% [recalc, reload] = checkReCalc(waveTypeNew, waveTNew, waveHNew, param1New, param2New, param3New, param4New);



% waveType = waveTypeNew;
% waveT = waveTNew;
% waveH = waveHNew;
% stopTime = stopTimeNew;
% param1 = param1New;
% param2 = param2New;
% param3 = param3New;
% param4 = param4New; 

% load_system(pTopModelName);


  

% make sure previous was stopped then load the model
switch simulationType
    case 'SingleSpeedgoat'
        pTg.stop;
        % needs to be loaded to modify the inport data
        pTg.load(pTopModelName);
    case 'TwoSpeedgoats'
       %TODO 
end


%change the constant bock parameters that initialize the control params 
pTg.setparam('pTopModel/Receive Control UDP /ParamIn1','Value',(param1));
pTg.setparam('pTopModel/Receive Control UDP /ParamIn2',"Value",(param2));
pTg.setparam('pTopModel/Receive Control UDP /ParamIn3',"Value",(param3));
pTg.setparam('pTopModel/Receive Control UDP /ParamIn4',"Value",(param4));
pTg.setparam('pTopModel/Receive Control UDP /ParamIn5',"Value",(waveH));

% recalc waves if needed - still better than a recompile
% only recalc for systemID - inports can be updated 
% if recalc == true
%     [Fexin, busInfo, admittance_ss] = SIDWaveGenerator(Ts,stopTime,admittanceModel,excitationModel,1,waveT, waveType); % waveH is 1 now
% end
% 
% if reload == true
%     stop(pTg.Stimulation, 'all'); %stop inport stimulation - have to stop them all to reset any 
%     
%     reloadData(pTg.Stimulation,... 
%     'Aft', get(Fexin, 'FexAft'),... 
%     'Bow', get(Fexin, 'FexBow'));
% 
%     start(pTg.Stimulation, 'all'); % restart the inport stimulation
%   
% end 

% start the target
switch simulationType
    case 'SingleSpeedgoat'
        pTg.start;
    case 'TwoSpeedgoats'
        % start primary
        pTg.stop;
        pTg.load(pTopModelName);
        pTg.start;
        % start secondary 
        sTg.stop;
        sTg.load(sTopModelName);
        sTg.start;
    
end