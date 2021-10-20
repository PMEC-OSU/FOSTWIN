% script to put the workspace variable into a .mat file to allow the 
% developer to collect full resulution data and post-process on their own
if exist('logsout','var')
    datar = logsout.FileLogSignals{1}.Values.Data;
    output.FOSTWINctrl.time = logsout.FileLogSignals{1}.Values.Time;
    
    output.FOSTWINctrl.bow.pos = datar(:,1);
    output.FOSTWINctrl.aft.pos = datar(:,2);
    
    output.FOSTWINctrl.bow.cur = datar(:,3);
    output.FOSTWINctrl.aft.cur = datar(:,4);
    
    output.FOSTWINctrl.ctrlSig1 = datar(:,5);
    output.FOSTWINctrl.ctrlSig2 = datar(:,6);
    output.FOSTWINctrl.ctrlSig3 = datar(:,7);
    output.FOSTWINctrl.ctrlSig4 = datar(:,8);
    
    output.FOSTWINctrl.wave.H = waveH;
    output.FOSTWINctrl.wave.T = waveT;
    % data.wave.type = wavetype
    output.FOSTWINctrl.Ts = Ts;
save('simulation-data.mat','output');
end