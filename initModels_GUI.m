% script to test the various model configurations for running the FOSWEC
% Twin and Controller systems
clearvars; close all; clc;

% uncomment following line if wanting random waves with systemID
% and wanting to have the same waves for multiple runs (seed random
% generator with same number)
rng('default')

warning on verbose

% Example wecSimPath variable - use full path
wecSimPath = 'D:\src\wec-sim-5.0\source';
%wecSimPath = 'D:\src\WEC-Sim\source';

% ADD FULL PATH TO WECSIM BELOW - FULL PATH LIKE ABOVE
%wecSimPath = 'C:/Software/WEC-Sim/source';
    

if strcmp(wecSimPath, '')
    fprintf('Need to set the path to your WEC-Sim install at line 15 of initModels_GUI.m')
    return
end

addpath(genpath(wecSimPath));
% modifyWECSim_Lib_Frames  %% this needs to be run once when WEC-Sim is
% updated
%% === Base model settings ================================================
% If you don't have access to the realtime hardware, in the following three
% lines, uncomment 'NonRealTime' for the simulationType variable.
simulationType = 'NonRealTime';
% simulationType = 'SingleSpeedgoat';

% CHANGE STARTING PARAMS HERE
waveH = 0.136;
waveT = 2.61;
param1 = 5; % AFT DAMPING - IN DEFAULT CONTROL
param2 = 5  ; % BOW DAMPING - IN DEAULT CONTROL
param3 = 10; % NOT USED IN DEFAULT CONTROL - still needs to exist
param4 = 10; % NOT USED IN DEFAULT CONTROL - still needs to exist
stopTime = '180';  % seconds
% number of required in and out ports in new controller model 
N_IN = 2;
N_OUT = 2;
simu.paraview.option = 0;
simu.b2b = 1; % enable body-body (flap->flap) interactions % TODO - is this required?
% SWITCH COMMENTED LINE TO CHANGE WAVE TYPE
% waveType = 'regular';
waveType = 'irregular';

% SWITCH COMMENT FOR CONTROLLER
ctrlModelName = 'defaultCtrlModel';
% ctrlModelName = 'ctrlStarter'; 


% SWITCH COMMENT FOR TWIN
%twinType = 'WECSim';
twinType = 'systemID';

% SET YOUR SPEEDGOAT TARGET NAME HERE
% example : pTgName = 'EGIBaseline';
% pTgName = 'baseline1';
pTgName = 'EGIBaseline2';

if strcmp(pTgName, '')
    fprintf("Need to set your speedgoat target name in line 59");
    return
end

if strcmp(twinType, 'WECSim')
    switch waveType
        case 'regular'
            Ts = 1/200;
        case 'irregular'
            Ts = 1/200;    % slower for the JONSWAP - avoid overflow
        otherwise
            fprintf('\nUnknown wave type selected... \n\nPlease choose regular vs irregular.');
            return
    end
else
    Ts = 1/1000; 
end


switch simulationType
    case 'NonRealTime'
        pTopModelName = 'FOSTWIN';  % the primary top level model
        switch waveType
            case "regular"
                numPeriods = 5;
                numSteps = numPeriods*waveT*1/Ts;
                numSteps = cast(numSteps, 'int32');
            case "irregular"
                numPeriods = 60;
                numSteps = numPeriods*waveT*1/Ts;
                numSteps = cast(numSteps, 'int32');
            otherwise
                numPeriods = 60;
                numSteps = numPeriods*waveT*1/Ts;
                numSteps = cast(numSteps, 'int32');
        end
        
    case 'SingleSpeedgoat'
        pTopModelName = 'FOSTWIN';
        switch waveType
            case "regular"
                numPeriods = 5;
                numSteps = numPeriods*waveT*1/Ts;
                numSteps = cast(numSteps, 'int32');
            case "irregular"
                numPeriods = 60;
                numSteps = numPeriods*waveT*1/Ts;
                numSteps = cast(numSteps, 'int32');
            otherwise
                numPeriods = 60;
                numSteps = numPeriods*waveT*1/Ts;
                numSteps = cast(numSteps, 'int32');
        end
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

%% === define busses ======================================================
twin2CtrlStruct.posFlapAft = 0.0;
twin2CtrlStruct.posFlapBow = 0.0;

twin2CtrlBusInfo = Simulink.Bus.createObject(twin2CtrlStruct);
twin2CtrlBus = eval(twin2CtrlBusInfo.busName);

ctrl2TwinStruct.curAft = 0.0;
ctrl2TwinStruct.curBow = 0.0;
ctrl2TwinStruct.state = int32(0);

ctrl2TwinBusInfo = Simulink.Bus.createObject(ctrl2TwinStruct);
ctrl2TwinBus = eval(ctrl2TwinBusInfo.busName);

ctrlParamStruct.ctrlParam1 = 0.0;
ctrlParamStruct.ctrlParam2 = 0.0;
ctrlParamStruct.ctrlParam3 = 0.0;
ctrlParamStruct.ctrlParam4 = 0.0;

ctrlParamBusInfo = Simulink.Bus.createObject(ctrlParamStruct);
ctrlParamBus = eval(ctrlParamBusInfo.busName); 

ctrlSignalStruct.ctrlSignal1 = 0.0;
ctrlSignalStruct.ctrlSignal2 = 0.0;
ctrlSignalStruct.ctrlSignal3 = 0.0;
ctrlSignalStruct.ctrlSignal4 = 0.0;

ctrlSignalBusInfo = Simulink.Bus.createObject(ctrlSignalStruct);
ctrlSignalBus = eval(ctrlSignalBusInfo.busName); 

powerStruct.powerMechAft = 0.0;
powerStruct.powerMechBow = 0.0;
powerStruct.powerMechTotal = 0.0;
powerStruct.powerI2R = 0.0;
powerStruct.powerNet = 0.0;

powerBusInfo = Simulink.Bus.createObject(powerStruct);
powerBus = eval(powerBusInfo.busName);
% =========================================================================

%% === state enum definition ==============================================

Simulink.defineIntEnumType('fostwinStateEnum', ...
    {'undefined', ...               %00 a non state
    'init', ...                     %01 starting point
    'ctrlNormal',...                %02 normal operating state
    'ctrlStabilize',...             %03 allow control to stabilize after error event
    'ctrlSafe', ...                 %04 safe condition, with a default damping controller
    'ctrlFault'},...                %05 fault condition (after a number of ctrlSafe occurrences)
    0:5, ...
    'Description', 'FOSTWIN States', ...
	'DefaultValue', 'undefined', ...
	'HeaderFile', 'fostwinState.h', ...
	'DataScope', 'Exported', ...
	'AddClassNameToEnumNames', true, ...
	'StorageType', 'int32');
% =========================================================================


%% === definition of constants ============================================
Kt = 0.943;                                 % motor torque constant in Nm/A
N = 3.75;                                   % gear ratio between flap and motor
Rpn = 0.5275;                               % motor winding resistance phase-neutral
lpFreqCurrent = 50;                         % cut-off frequency for first order low pass applied to current (only for fault state transition checking, not in feedback path)
lpFreqVelocity = 50;                        % cut-off frequency for first order low pass applied to velocity signal (in default controller)
encCountsPerRev = 4096;                     % encoder counts per revolution (1024 lines with quadrature)
encNoisePower = 1e-8;                       % noise on encoder, based on experimental observations

% state machine related constants
maxCurrent = 15;                            % maximum permissible motor current
safeDamping = 2.5;                          % defines a level of damping where control is stable for a simple damping controller
initTime = 2;                               % time for initialization (represents boot-up for a real system)
stableTime = 3;                             % stabilize after error event
safeTime = 20;                              % time after which ctrlSafe transitions to ctrlNormal
maxFaultCount = 3;                          % maximum number of ctrlNormal -> ctrlSafe, ctrlFault after that
% =========================================================================

% Calculate excitation forces (used in SystemID twin)
% TODO - regular waves don't currenty work - regular doesn't return the
% wave argument
switch twinType
    case 'WECSim'
%         wecSimSetup;
        run('wecSimInputFile');
        clear simu waves body cable pto constraint ptosim mooring 

        runWecSimCML = 1;
        run('initializeWecSim');
        sim(simu.simMechanicsFile, [], simset('SrcWorkspace','parent'));
        % data not used in wecsim so setting stop time to 1 to make pre-process a bit more quick
        [FexAft, FexBow, wave, admittance_ss, Ef] = SIDWaveGenerator(Ts,'1',admittanceModel,excitationModel,1,waveT, waveType);
    case 'systemID'
        [FexAft, FexBow, wave, admittance_ss, Ef] = SIDWaveGenerator(Ts,stopTime,admittanceModel,excitationModel,1,waveT, waveType); % always passing in 1 for waveH now - mult with gain
end

% for inputs to workspace
FexAftTime = FexAft.Time;
FexAftData = squeeze(FexAft.Data);

FexBowTime = FexBow.Time;
FexBowData = squeeze(FexBow.Data);

%% === Setting up the model parameters ====================================
load_system(twinModelName)

load_system(ctrlModelName)

% load_system(fexInportsModelName)

load_system(pTopModelName)

%CHECKS THAT CONTROLLER HAS CORRECT NUMBER OF INPORTS AND OUTPORTS
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



% make sure the variant sub-system for udp send/recieve and fileLogging is
% set to local - NO UDP
set_param([pTopModelName, '/params'], 'OverrideUsingVariant', 'Local');
set_param([pTopModelName, '/ouput'], 'OverrideUsingVariant', 'Local');

% swtich subsystem for control params between realtime and non-realtime 
% realtime has 1's for the contant block values, non-realtime takes the
% workspace variables - allows starttarget and ctrl functions to work
set_param([pTopModelName, '/params', '/Local', '/ControlParams'], 'OverrideUsingVariant', simulationType);




twinActiveConfig = getActiveConfigSet(twinModelName);
ctrlActiveConfig = getActiveConfigSet(ctrlModelName);
pTopActiveConfig = getActiveConfigSet(pTopModelName);
%fexInportsConfig = getActiveConfigSet(fexInportsModelName);


set_param(twinActiveConfig,'StopTime',stopTime);
set_param(ctrlActiveConfig,'StopTime',stopTime);
set_param(pTopActiveConfig,'StopTime',stopTime);


switch simulationType
    
    case 'NonRealTime'
        set_param(twinActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(ctrlActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(pTopActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        % handle different user - developed control names
        switch ctrlModelName
            case "defaultCtrlModel"
                set_param([pTopModelName, '/ctrl'], 'OverrideUsingVariant', ctrlModelName);
            otherwise
                % if other name - set that as the model name loaded into
                % variant subsystem - under the userCtrlModel subsystem
                set_param([pTopModelName,'/ctrl/userCtrlModel'],'ModelName',ctrlModelName);
                set_param([pTopModelName, '/ctrl'], 'OverrideUsingVariant', 'userCtrlModel');
        end
   
        set_param([pTopModelName,'/setpointComs'],'OverrideUsingVariant','nonRT');
        set_param([pTopModelName,'/feedbackComs'],'OverrideUsingVariant','nonRT');
        % set the twin
        set_param([pTopModelName,'/twin'],'OverrideUsingVariant',twinType)
        
        switchTarget(twinActiveConfig,solverNonRT,[]);
        switchTarget(ctrlActiveConfig,solverNonRT,[]);
        switchTarget(pTopActiveConfig,solverNonRT,[]);
        
        % the order matters - save the top model last
        save_system(twinModelName)
        
        save_system(ctrlModelName)
        % save is what causes the refresh box
        Simulink.ModelReference.refresh('FOSTWIN/twin/WECSim'); % fix the refresh dialogue box
        Simulink.ModelReference.refresh('FOSTWIN/twin/systemID'); % fix the refresh dialogue box
        Simulink.ModelReference.refresh('FOSTWIN/ctrl/userCtrlModel'); % fix the refresh dialogue box box
        Simulink.ModelReference.refresh('FOSTWIN/ctrl/defaultCtrlModel'); % fix the refresh dialogue box box
        
        save_system(pTopModelName)
        
        open_system(pTopModelName)
        
        data = sim(pTopModelName);
        switch twinType
            case 'WECSim'
                %wecSimPost; % TODO - Bret - is this required?
                %stopWecSim;    
            case 'systemID'
                FOSTWINctrlPost;
        end
    case 'SingleSpeedgoat'
        
        set_param(twinActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        set_param(ctrlActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
%        set_param(fexInportsConfig, 'SolverType', 'Fixed-step', 'FixedStep', 'Ts');
        set_param(pTopActiveConfig,'SolverType','Fixed-step','FixedStep','Ts');
        
        
       % handle different user - developed control names
        switch ctrlModelName
            case "defaultCtrlModel"
                set_param([pTopModelName, '/ctrl'], 'OverrideUsingVariant', ctrlModelName);
            otherwise
                % if other name - set that as the model name loaded into
                % variant subsystem - under the userCtrlModel subsystem
                set_param([pTopModelName,'/ctrl/userCtrlModel'],'ModelName',ctrlModelName);
                set_param([pTopModelName, '/ctrl'], 'OverrideUsingVariant', 'userCtrlModel');
        end

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
        Simulink.ModelReference.refresh([pTopModelName, '/ctrl/userCtrlModel']); % fix the refresh dialogue box 
        Simulink.ModelReference.refresh([pTopModelName, '/ctrl/defaultCtrlModel']); % fix the refresh dialogue box

        save_system(pTopModelName)
        
        set_param(pTopModelName, 'RTWVerbose', 'off');
        fprintf('*** Build Simulink RT code (Single Speedgoat) ...\n\n')
        
        try
            slbuild(pTopModelName);
%             app_object = slrealtime.Application(pTopModelName);
%             updateRootLevelInportData(app_object);

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
        
end

