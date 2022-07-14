% script to test the various model configurations for running the FOSWEC
% Twin and Controller systems
clearvars; close all; clc;

% uncomment following line if wanting random waves with systemID
% and wanting to have the same waves for multiple runs (seed random
% generator with same number)
rng('default')

% Example wecSimPath variable - use full path
wecSimPath = 'D:\src\wec-sim-5.0\source';

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
param1 = 2.5; % BOW DAMPING - IN DEFAULT CONTROL
param2 = 2.5; % AFT DAMPING - IN DEAULT CONTROL
param3 = 10; % NOT USED IN DEFAULT CONTROL - still needs to exist
param4 = 10; % NOT USED IN DEFAULT CONTROL - still needs to exist
stopTime = '1800';  % seconds
% number of required in and out ports in new controller model
N_IN = 6;
N_OUT = 6;
simu.paraview.option = 0;
% SWITCH COMMENTED LINE TO CHANGE WAVE TYPE
% waveType = 'regular';
waveType = 'irregular';

% SWITCH COMMENT FOR CONTROLLER
ctrlModelName = 'defaultCtrlModel';
%ctrlModelName = 'CONTROL_STARTER';

% SWITCH COMMENT FOR TWIN
twinType = 'WECSim';
%twinType = 'systemID';

% SET YOUR SPEEDGOAT TARGET NAME HERE
% example : pTgName = 'EGIBaseline';
pTgName = 'baseline1';

if strcmp(pTgName, '')
    fprintf("Need to set your speedgoat target name in line 62");
    return
end

if strcmp(twinType, 'WECSim')
    switch waveType
        case 'regular'
            Ts = 1/100;
        case 'irregular'
            Ts = 1/100;    % slower for the JONSWAP - avoid overflow
        otherwise
            fprintf('\nUnknown wave type selected... \n\nPlease choose regular vs irregular.');
            return
    end
else
    Ts = 1/100;
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
        pTopModelName = 'pTopModel';
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

%% === definition of constants ============================================
Kt = 0.882355004501468;                     % taken from FOSWEC_params.mat Nm/A
N = 3.75;                                   % gear ratio between flap and motor
% =========================================================================
% Calculate excitation forces (used in SystemID twin)
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
                % wecSimPost;
                stopWecSim;    
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
        
end

