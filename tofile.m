% script to put the workspace variable into a .mat file to allow the
% developer to collect full resulution data and post-process on their own

% ONLY NEEDED WHEN RUNNING THE CTRL IN REALTIME MODE ON A SPEEGOAT
if exist('logsout','var')
    data1 = logsout.FileLogSignals;
    numdatasets = numElements(data1);
    
    for i = 1:numdatasets
        signalNames = fieldnames(data1{i}.Values);
        for j = 1:length(signalNames)
            blockNameTot = data1{i}.BlockPath.getBlock(1);
            level = wildcardPattern + "/";
            pat = asManyOfPattern(level);
            blockName = extractAfter(blockNameTot,pat);
            signalName = char(signalNames(j));
            output.(blockName).(signalName) = data1{i}.Values.(signalName).Data;
            output.(blockName).time = data1{i}.Values.(signalName).Time;
        end
    end
    
output.Power.AveragePower = squeeze(output.Power.AveragePower);
output.ControlSignals.CaptureWidth = squeeze(output.ControlSignals.CaptureWidth);
output.ControlSignals.Control_Param4 = squeeze(output.ControlSignals.Control_Param4);

        output.Conditions.wave.H = waveH;
        output.Conditions.wave.T = waveT;
        output.Conditions.wavetype = waveType;
        output.Conditions.Ts = Ts;
    save('simulation-data.mat','output');
end