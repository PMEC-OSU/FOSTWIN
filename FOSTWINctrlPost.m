
if exist('data','var')
    datar = data.output;
    output.FOSTWINctrl.time = data.tout;
    
    clear data
    
    output.FOSTWINctrl.bow.pos = datar.Data(:,1);
    output.FOSTWINctrl.aft.pos = datar.Data(:,2);
    
    output.FOSTWINctrl.bow.cur = datar.Data(:,3);
    output.FOSTWINctrl.aft.cur = datar.Data(:,4);
    
    output.FOSTWINctrl.ctrlSig1 = datar.Data(:,5);
    output.FOSTWINctrl.ctrlSig2 = datar.Data(:,6);
    output.FOSTWINctrl.ctrlSig3 = datar.Data(:,7);
    output.FOSTWINctrl.ctrlSig4 = datar.Data(:,8);
    
    output.FOSTWINctrl.wave.H = waveH;
    output.FOSTWINctrl.wave.T = waveT;
    % output.FOSTWINctrl.wave.type = wavetype
    output.FOSTWINctrl.Ts = Ts;
    save('simulation-data.mat','output');
end