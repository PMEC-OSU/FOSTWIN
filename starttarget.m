% uncomment following lines (3 through 7) to change params when starting/ re-starting
% simulation
% waveHNew = .136;
% param1New = 10;
% param2New = 10;
% param3New = 5;
% param4New = 5;

% UNCOMMENT FOLLOWING LINES IF RUNNING FROM UI BUT DON'T WANT TO MODIFY ANY
% PARAMS
waveHNew = waveH;
param1New = param1;
param2New = param2;
param3New = param3;
param4New = param4;

clear logsout; % when restarting - clear previous data file

% with wecsim - cannot change any wave parameters without a re-compile  
if strcmp(twinModelName, 'WECSim')
    waveHNew = waveH;
end

waveH = waveHNew;
param1 = param1New;
param2 = param2New;
param3 = param3New;
param4 = param4New; 

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
pTg.setparam([pTopModelName, '/params', '/Local', '/param1'], "Value", (param1));
pTg.setparam([pTopModelName, '/params', '/Local', '/param2'], "Value", (param2));
pTg.setparam([pTopModelName, '/params', '/Local', '/param3'], "Value", (param3));
pTg.setparam([pTopModelName, '/params', '/Local', '/param4'], "Value", (param4));
pTg.setparam([pTopModelName, '/params', '/Local', '/waveH'], "Value", (waveH));

% pTg.setparam('pTopModel/param1','Value',(param1));
% pTg.setparam('pTopModel/param2',"Value",(param2));
% pTg.setparam('pTopModel/param3',"Value",(param3));
% pTg.setparam('pTopModel/param4',"Value",(param4));
% pTg.setparam('pTopModel/waveH',"Value",(waveH));
 

% start the target
switch simulationType
    case 'SingleSpeedgoat'
        pTg.start;
end