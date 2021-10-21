% script to test the various model configurations for running the FOSWEC
% Twin and Controller systems
clearvars; close all; clc;

% uncomment following line if wanting random waves with systemID
% and wanting to have the same waves for multiple runs (seed random
% generator with same number)
% rng('default')


% Example wecSimPath variable - use full path
% wecSimPath = 'D:\src\WEC-Sim\source';

% ADD FULL PATH TO WECSIM BELOW - FULL PATH LIKE ABOVE
wecSimPath = 'C:/Software/WEC-Sim/source';

if strcmp(wecSimPath, '')
    fprintf('Need to set the path to your WEC-Sim install at line 15 of initModels_GUI.m')
    return
end

addpath(genpath(wecSimPath));

%% === Base model settings ================================================
% If you don't have access to the realtime hardware, in the following three
% lines, uncomment 'NonRealTime' for the simulationType variable.
% simulationType = 'NonRealTime';
simulationType = 'SingleSpeedgoat';
%simulationType = 'TwoSpeedgoats';

% CHANGE STARTING PARAMS HERE
waveH = .136;
waveT = 2.61;
param1 = 10; % AFT DAMPING - IN DEFAULT CONTROL
param2 = 10; % BOW DAMPING - IN DEAULT CONTROL
param3 = 10; % NOT USED IN DEFAULT CONTROL - still needs to exist
param4 = 10; % NOT USED IN DEFAULT CONTROL - still needs to exist
stopTime = '60'; % seconds
% number of required in and out ports in new controller model
N_IN = 6;
N_OUT = 6;

% SWITCH COMMENTED LINE TO CHANGE WAVE TYPE
% waveType = 'regular';
waveType = 'irregular';

switch simulationType
    case 'NonRealTime'
        pTopModelName = 'FOSTWIN';  % the primary top level model
    case 'SingleSpeedgoat'
        pTopModelName = 'pTopModel';
end
sTopModelName = 'sTopModel';  % the secondary top level model

% SWITCH COMMENT FOR CONTROLLER
ctrlModelName = 'defaultCtrlModel';
%ctrlModelName = 'CONTROL_STARTER';

% SWITCH COMMENT FOR TWIN
twinType = 'WECSim';
% twinType = 'systemID';

% SET YOUR SPEEDGOAT TARGET NAME HERE

% pTg = Primary speedgoat used in SingleSpeedgoat option at line 28
% example : pTgName = 'EGIBaseline';
pTgName = 'baseline1';
sTgName = '';
iotIPaddr = '192.168.7.2';

if strcmp(pTgName, '')
    fprintf("Need to set your speedgoat target name in line 63");
    return
end

if strcmp(twinType, 'WECSim')
    switch waveType
        case 'regular'
            Ts = 1/1000;
        case 'irregular'
            Ts = 1/100;    % slower for the JONSWAP - avoid overflow
        otherwise
            fprintf('\nUnknown wave type selected... \n\nPlease choose regular vs irregular.');
            return
    end
else
    Ts = 1/1000;
end


solverRT = 'slrealtime.tlc';
solverNonRT = 'grt.tlc';


switch twinType
    case 'WECSim'
        twinModelName = 'FOSWEC_v2';
    case 'systemID'
        twinModelName = 'systemID';
    otherwise
        fprintf('Unknown Twin Model Name...\nUnable to compile...');
        return
end

% SystemID
admittanceModel = 'AdmittanceTF.mat';
excitationModel = 'ExcitationWAMIT.mat';

% =========================================================================
%% === IoT addresses ======================================================
iotLocalDataPort = 25001;
iotRemoteDataPort = 54321;
iotDataRate = 1*Ts; % need to fix this - should be able to use any rate

iotLocalMsgPort = 25002;
iotRemoteMsgPort = 54322;
iotMsgRate = 1*Ts; % need to fix this - should be able to use any rate

% UDP Recieve - need to add into this model still
iotLocalParamPort = 25003;
iotRemoteParamPort = 54323;
iotListenRate = 1 * Ts; 


% =========================================================================
%% ========================UDP Recieve==================================
% still need to define this for the output data types to work
paramStruct.param1 = param1;
paramStruct.param2 = param2;
paramStruct.param3 = param3; % not used yet - developer will need to convert doubles to logical in their control 
paramStruct.param4 = param4;
paramStruct.param5 = waveH; % allow wave height changing if systemID - linear so can mult by height

% enum for param pkts
Simulink.defineIntEnumType('paramTypeEnum_Twin_v4', ... 
    {'undefined', 'setParam1','setParam2','setParam3', 'setParam4', 'setParam5'}, ...
    0:5, ... 
    'Description', 'Param Type', ...
    'DefaultValue', 'undefined', ...
    'HeaderFile', 'paramTypeEnum_Twin_v4.h', ...
    'DataScope', 'Exported', ...
    'AddClassNameToEnumNames', true, ...
    'StorageType', 'uint16');

myBus = Simulink.Bus.createObject(paramStruct);
myBusName = myBus.busName;

%% === define enums =======================================================
Simulink.defineIntEnumType('SimStateMsg', ... 
	{'undefined', 'eCATState', 'eCATErr', 'eCATLastErr', 'cpuTET'}, ...
	[0;1;2;3;4], ... 
	'Description', 'Simulink State Message', ...
	'DefaultValue', 'undefined', ...
	'HeaderFile', 'simStateMsg.h', ...
	'DataScope', 'Exported', ...
	'AddClassNameToEnumNames', true, ...
	'StorageType', 'uint8');

Simulink.defineIntEnumType('pcktID', ... 
	{'undefined', 'header', 'data','stateMsg',}, ...
	0:3, ... 
	'Description', 'packet ID', ...
	'DefaultValue', 'undefined', ...
	'HeaderFile', 'pcktID.h', ...
	'DataScope', 'Exported', ...
	'AddClassNameToEnumNames', true, ...
	'StorageType', 'uint8');


Simulink.defineIntEnumType('dataID_twin', ... 
	{'undefined', 'current_aft', 'current_bow', 'position_aft', 'position_bow'}, ...
	[0;11;22;33;44], ... 
	'Description', 'data ID FOSTWIN', ...
	'DefaultValue', 'undefined', ...
	'HeaderFile', 'dataID_twin.h', ... %c code name
	'DataScope', 'Exported', ...
	'AddClassNameToEnumNames', true, ...
	'StorageType', 'uint8');


Simulink.defineIntEnumType('control_id_twin4', ... 
	{'undefined', 'signal1', 'signal2', 'signal3', 'signal4', 'SimTime'}, ...
	[0;55;66;77;88;99], ... 
	'Description', 'controler data ID FOSTWIN', ...
	'DefaultValue', 'undefined', ...
	'HeaderFile', 'control_id_twin4.h', ... %c code name
	'DataScope', 'Exported', ...
	'AddClassNameToEnumNames', true, ...
	'StorageType', 'uint8');
%drawnow('update');

%% === definition of constants ============================================
Kt = 0.882355004501468;                     % taken from FOSWEC_params.mat Nm/A
N = 3.75;                                   % gear ratio between flap and motor
% =========================================================================
% Calculate excitation forces (used in SystemID twin)
switch twinType
    case 'WECSim'
        wecSimSetup;
        % data not used in wecsim so setting stop time to 1 to make pre-process a bit more quick
        [Fexin, FexAft, FexBow, admittance_ss] = SIDWaveGenerator(Ts,'1',admittanceModel,excitationModel,1,waveT, waveType);
    case 'systemID'
        [Fexin, FexAft, FexBow, admittance_ss] = SIDWaveGenerator(Ts,stopTime,admittanceModel,excitationModel,1,waveT, waveType); % always passing in 1 for waveH now - mult with gain
end





%% === Setting up the model parameters ====================================
load_system(twinModelName)

load_system(ctrlModelName)

load_system(pTopModelName)

% CHECKS THAT CONTROLLER HAS CORRECT NUMBER OF INPORTS AND OUTPORTS
blks = find_system(ctrlModelName, 'Type', 'Block');
types = get_param(blks, 'BlockType');
in = 0;
out = 0;
for n=1:length(types)
    a = types(n);
    if strcmp(a, 'Inport')
        in = in + 1;
    end
    if strcmp(a, 'Outport')
        out = out + 1;
    end
end


if in < N_IN || out < N_OUT
    fprintf('Number of inports or outputs in uploaded control model are not correct.\n\n');
    fprintf('Expected %d Inports and %d Outports.  Found %d Inports and %d Outports.\n\n', N_IN, N_OUT, in, out);
    fprintf('Compilation Complete');
    return
    
end


% set the full path to the EtherCAT config files - for dual speegoat
% operation
current_dir = pwd;
secondary_eCat_init = strcat(current_dir, '\esi\FOSTWIN_Secondary1.xml');
set_param([pTopModelName, '/feedbackComs/twoSpeedgoats/EtherCAT Init'], 'config_file',secondary_eCat_init);

primary_eCat_init = strcat(current_dir, '\esi\FOSTWIN-Primary1.xml');
set_param([pTopModelName, '/setpointComs/twoSpeedgoats/EtherCAT Init'], 'config_file',primary_eCat_init);

twinActiveConfig = getActiveConfigSet(twinModelName);
ctrlActiveConfig = getActiveConfigSet(ctrlModelName);
pTopActiveConfig = getActiveConfigSet(pTopModelName);



set_param(twinActiveConfig,'StopTime',stopTime);
set_param(ctrlActiveConfig,'StopTime',stopTime);
set_param(pTopActiveConfig,'StopTime',stopTime);

switch simulationType
    
    case 'NonRealTime'
        set_param(twinActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(ctrlActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(pTopActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        
        set_param([pTopModelName,'/ctrl'],'ModelName',ctrlModelName)
        set_param([pTopModelName,'/setpointComs'],'OverrideUsingVariant','nonRT');
        set_param([pTopModelName,'/feedbackComs'],'OverrideUsingVariant','nonRT');
        % set the twin
        set_param([pTopModelName,'/twin'],'OverrideUsingVariant',twinType)
        
        switchTarget(twinActiveConfig,solverNonRT,[]);
        switchTarget(ctrlActiveConfig,solverNonRT,[]);
        switchTarget(pTopActiveConfig,solverNonRT,[]);
        %         set_param([pTopModelName, '/param1'], 'Value', param1);
        %         set_param([pTopModelName, '/param2'], 'Value', param2);
        %         set_param([pTopModelName, '/param3'], 'Value', param3);
        %         set_param([pTopModelName, '/param4'], 'Value', param4);
        %         set_param([pTopModelName, '/waveH'], 'Value', waveH);
        % the order matters - save the top model last
        save_system(twinModelName)
        
        save_system(ctrlModelName)
        % save is what causes the refresh box
        Simulink.ModelReference.refresh('FOSTWIN/twin/WECSim'); % fix the refresh dialogue box
        Simulink.ModelReference.refresh('FOSTWIN/twin/systemID'); % fix the refresh dialogue box
        Simulink.ModelReference.refresh('FOSTWIN/ctrl'); % fix the refresh dialogue box box
        
        save_system(pTopModelName)
        
        
        open_system(pTopModelName)
        
        data = sim(pTopModelName);
        switch twinType
            case 'WECSim'
                wecSimPost;
            case 'systemID'
                FOSTWINctrlPost;
        end
    case 'SingleSpeedgoat'
        
        set_param(twinActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(ctrlActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(pTopActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        
        set_param([pTopModelName,'/ctrl'],'ModelName',ctrlModelName)
        set_param([pTopModelName,'/setpointComs'],'OverrideUsingVariant','singleSpeedgoat');
        set_param([pTopModelName,'/feedbackComs'],'OverrideUsingVariant','singleSpeedgoat');
        
        % change the twin
        set_param([pTopModelName,'/twin'],'OverrideUsingVariant',twinType)
        
        
        
        switchTarget(twinActiveConfig,solverRT,[]);
        switchTarget(ctrlActiveConfig,solverRT,[]);
        switchTarget(pTopActiveConfig,solverRT,[]);
        
        
        
        % the order matters - save the top model last
        save_system(twinModelName)
        save_system(ctrlModelName)
        
        % save is what causes the refresh box
        Simulink.ModelReference.refresh([pTopModelName,'/twin/WECSim']); % fix the refresh dialogue box
        Simulink.ModelReference.refresh([pTopModelName,'/twin/systemID']); % fix the refresh dialogue box
        Simulink.ModelReference.refresh([pTopModelName,'/ctrl']); % fix the refresh dialogue box
        
        save_system(pTopModelName)
        
        
        set_param(pTopModelName, 'RTWVerbose', 'off');
        fprintf('*** Build Simulink RT code (Single Speedgoat) ...\n\n')
        
        try
            slbuild(pTopModelName);
            app_object = slrealtime.Application(pTopModelName);
            updateRootLevelInportData(app_object);
        catch e
            if isa(e,'MSLException')
                fprintf('Error building model:\n  Identifier: %s \n  Message: %s\n  Report: %s\n', e.identifier, e.message, e.getReport)
                fprintf('Compilation Complete');
                
                return
            end
            if isa(e,'MException')
                fprintf('Matlab Exception. Error building model:\n  Identifier: %s \n  Message: %s\n  Report: %s\n', e.identifier, e.message, e.getReport)
                fprintf('Compilation Complete');
                
                return
                
            end
            fprintf('Unknown exception in building Simulink RT (Speedgoat) code...');
            fprintf('Compilation Complete');
            
            return
        end
        
        pTg = slrealtime(pTgName);
        
        try
            pTg.connect
        catch ME
            fprintf('\n*** Target %s not connected. Stopping program. Check connection.\n',pTg.TargetSettings.name)
            fprintf('\n*** Matlab error \n %s \n\n',ME.getReport)
            fprintf('Compilation Complete')
            
            return
        end
        
        if pTg.isConnected
            fprintf('\n*** Target %s is connected at IP address %s. Waiting for start command ...\n\n',pTg.TargetSettings.name,pTg.TargetSettings.address)
            fprintf('Compilation Complete')
            
        end

        
    case 'TwoSpeedgoats'
        load_system(sTopModelName)
        sTopActiveConfig = getActiveConfigSet(sTopModelName);
        
        set_param(sTopModelName,'StopTime',stopTime);
        
        set_param(twinActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(ctrlActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(pTopActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(sTopActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        
        
        set_param([pTopModelName,'/ctrl'],'ModelName',ctrlModelName)
        set_param([pTopModelName,'/setpointComs'],'OverrideUsingVariant','twoSpeedgoats');
        set_param([pTopModelName,'/feedbackComs'],'OverrideUsingVariant','twoSpeedgoats');
        
        
        
        set_param([sTopModelName, '/EtherCAT Init'], 'config_file',secondary_eCat_init);
        set_param([pTopModelName,'/twin'],'OverrideUsingVariant',twinType);
        
        
        switchTarget(twinActiveConfig,solverRT,[]);
        switchTarget(ctrlActiveConfig,solverRT,[]);
        switchTarget(pTopActiveConfig,solverRT,[]);
        switchTarget(sTopActiveConfig,solverRT,[]);
        
        
        % the order matters - save the top model last
        save_system(twinModelName)
        save_system(ctrlModelName)
        % save is what causes the refresh box
        Simulink.ModelReference.refresh('pTopModel/ctrl'); % refresh the new control model
        Simulink.ModelReference.refresh('pTopModel/twin'); % fix the refresh dialogue box
        Simulink.ModelReference.refresh('pTopModel/twin/WECSim'); % fix the refresh dialogue box
        Simulink.ModelReference.refresh('pTopModel/twin/systemID'); % fix the refresh dialogue box
        save_system(pTopModelName)
        Simulink.ModelReference.refresh('sTopModel/twin'); % fix the refresh dialogue box
        Simulink.ModelReference.refresh('sTopModel/twin/WECSim'); % fix the refresh dialogue box
        Simulink.ModelReference.refresh('sTopModel/twin/systemID'); % fix the refresh dialogue box
        save_system(sTopModelName)
        
        
        set_param(pTopModelName, 'RTWVerbose', 'off');
        set_param(sTopModelName, 'RTWVerbose', 'off');
        
        
        % build primary - Control
        fprintf('*** Build Simulink RT code for primary Speedgoat (control) ...\n\n')
        
        try
            slbuild(pTopModelName)
        catch e
            if isa(e,'MSLException')
                fprintf('Error building primary (control) model:\n  Identifier: %s \n  Message: %s\n  Report: %s\n', e.identifier, e.message, e.getReport)
                fprintf('Compilation Complete');
                
                return
            end
            if isa(e,'MException')
                fprintf('Matlab Exception. Error building primary (control) model:\n  Identifier: %s \n  Message: %s\n  Report: %s\n', e.identifier, e.message, e.getReport)
                fprintf('Compilation Complete');
                
                return
                
            end
            fprintf('Unknown exception in building Simulink RT (Speedgoat) code...');
            fprintf('Compilation Complete');
            
            return
        end
        
        % build secondary - twin
        fprintf('*** Build Simulink RT code for secondary Speedgoat (twin) ...\n\n')
        
        try
            slbuild(sTopModelName)
            app_object = slrealtime.Application(sTopModelName);
            updateRootLevelInportData(app_object);
        catch e
            if isa(e,'MSLException')
                fprintf('Error building secondary (twin) model:\n  Identifier: %s \n  Message: %s\n  Report: %s\n', e.identifier, e.message, e.getReport)
                fprintf('Compilation Complete');
                
                return
            end
            if isa(e,'MException')
                fprintf('Matlab Exception. Error building secondary (twin) model:\n  Identifier: %s \n  Message: %s\n  Report: %s\n', e.identifier, e.message, e.getReport)
                fprintf('Compilation Complete');
                
                return
                
            end
            fprintf('Unknown exception in building Simulink RT (Speedgoat) code...');
            fprintf('Compilation Complete');
            
            return
        end
        
        
        
        pTg = slrealtime(pTgName);
        try
            pTg.connect
        catch ME
            fprintf('\n*** Primary Target %s not connected. Stopping program. Check connection.\n',pTg.TargetSettings.name)
            fprintf('\n*** Matlab error \n %s \n\n',ME.getReport)
            fprintf('Compilation Complete')
            
            return
        end
        
        if pTg.isConnected
            fprintf('\n*** Primary Target %s is connected at IP address %s. Waiting for start command ...\n\n',pTg.TargetSettings.name,pTg.TargetSettings.address)
            
        end
        pTg.stop;
        pTg.load(pTopModelName);
        % pTg.start;
        
        
        sTg = slrealtime(sTgName);
        try
            sTg.connect
        catch ME
            fprintf('\n*** Secondary Target %s not connected. Stopping program. Check connection.\n',sTgName)
            fprintf('\n*** Matlab error \n %s \n\n',ME.getReport)
            fprintf('Compilation Complete')
            
            return
        end
        
        if sTg.isConnected
            fprintf('\n*** Secondary Target %s is connected at IP address %s. Waiting for start command ...\n\n',sTg.TargetSettings.name,sTg.TargetSettings.address)
            fprintf('Compilation Complete');
            
        end
        sTg.stop;
        sTg.load(sTopModelName);
        %         sTg.start;
        %         pTg.start;
        
    otherwise
        fprintf('Unknown simulation type: %s',simulationType);
        fprintf('Compilation Complete');
        
        
end



