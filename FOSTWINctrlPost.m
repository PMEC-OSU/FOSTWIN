
if exist('data','var')
    
    blockNames = {'ControlSignals','Power'}; % get(data);
    
    for i = 1:length(blockNames)
        signalNames = fieldnames(data.(blockNames{i}));
        for j = 1:length(signalNames)
            output.(blockNames{i}).(signalNames{j}) = data.(blockNames{i}).(signalNames{j}).Data;
            output.(blockNames{i}).time = data.(blockNames{i}).(signalNames{j}).Time;
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