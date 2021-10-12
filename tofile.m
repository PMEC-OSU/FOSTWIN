% script to put the workspace variable into a .mat file to allow the 
% developer to collect full resulution data and post-process on their own
if exist('logsout','var')
    datar = logsout.FileLogSignals{1}.Values.Data;
    data.time = logsout.FileLogSignals{1}.Values.Time;
    
    data.bow.pos = datar(:,1);
    data.aft.pos = datar(:,2);
    
    data.bow.cur = datar(:,3);
    data.aft.cur = datar(:,4);
    
    data.ctrlSig1 = datar(:,5);
    data.ctrlSig2 = datar(:,6);
    data.ctrlSig3 = datar(:,7);
    data.ctrlSig4 = datar(:,8);
    
    data.wave.H = waveH;
    data.wave.T = waveT;
    % data.wave.type = wavetype
    data.Ts = Ts;
save('simulation-data.mat','data');
end