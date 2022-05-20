% script to put the workspace variable into a .mat file to allow the
% developer to collect full resulution data and post-process on their own

% ONLY NEEDED WHEN RUNNING THE CTRL IN REALTIME MODE ON A SPEEGOAT
if exist('logsout','var')
    data1 = logsout;
    numdatasets = numElements(data1);
    
    for i = 1:numdatasets
        signalNames = fieldnames(data1{i}.Values);
        for j = 1:length(signalNames)
            blockNameTot = data1{i}.BlockPath.getBlock(1);
            level = wildcardPattern + "/";
            pat = asManyOfPattern(level);
            blockName = extractAfter(blockNameTot,pat);
            signalName = char(signalNames(j));
            outputSimulation.(blockName).(signalName) = data1{i}.Values.(signalName).Data;
            outputSimulation.(blockName).time = data1{i}.Values.(signalName).Time;
        end
    end
    
    outputSimulation.Power.AveragePower = squeeze(outputSimulation.Power.AveragePower);
    outputSimulation.ControlSignals.CaptureWidth = squeeze(outputSimulation.ControlSignals.CaptureWidth);
    outputSimulation.ControlSignals.Control_Param1 = squeeze(outputSimulation.ControlSignals.Control_Param1);
    outputSimulation.ControlSignals.Control_Param2 = squeeze(outputSimulation.ControlSignals.Control_Param2);
    outputSimulation.ControlSignals.Control_Param3 = squeeze(outputSimulation.ControlSignals.Control_Param3);
    outputSimulation.ControlSignals.Control_Param4 = squeeze(outputSimulation.ControlSignals.Control_Param4);
    outputSimulation.ControlSignals.waveH_rt = squeeze(outputSimulation.ControlSignals.waveH_rt);
    outputSimulation.Conditions.wave.H = waveH;
    outputSimulation.Conditions.wave.T = waveT;
    outputSimulation.Conditions.wavetype = waveType;
    outputSimulation.Conditions.Ts = Ts;
if strcmp(twinType, 'WECSim')
    % add get WECSim post-processed data
    stopWecSim;
    % add WECSim post-processed data to the output that is stored
    outputSimulation.WECSim = output;
end
    save('simulation-data.mat','outputSimulation');
end