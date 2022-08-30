nonRealTimeAftBlock = [pTopModelName, '/FexAftWorkspace'];
nonRealTimeBowBlock = [pTopModelName, '/FexBowWorkspace'];
realTimeBlock = [pTopModelName, '/FexRealtime'];


% try/ catch - if line already deleted or added - throws errs

switch simulationType
    case "NonRealTime"
        %port 1 on realtime inports is AFT
        try
            delete_line(pTopModelName, 'FexRealtime/1', 'FexAftMult/1');
        catch
        end
        %port 2 on realtime is BOW
        try
            delete_line(pTopModelName, 'FexRealtime/2', 'FexBowMult/1');
        catch
        end
        % comment out realtime with root level inports
        set_param(realTimeBlock, 'commented', 'on');
        % un-comment from workspace blocks
        set_param(nonRealTimeAftBlock, 'commented', 'off');
        set_param(nonRealTimeBowBlock, 'commented', 'off');
        % add lines from workspace to mult blocks 
        try
            add_line(pTopModelName, 'FexAftWorkspace/1', 'FexAftMult/1', 'autorouting', 'on');
        catch
        end
        try
            add_line(pTopModelName, 'FexBowWorkspace/1', 'FexBowMult/1', 'autorouting', 'on');
        catch
        end
    case "SingleSpeedgoat"
         % delete lines from workspace to mult blocks 
        try
            delete_line(pTopModelName, 'FexAftWorkspace/1', 'FexAftMult/1');
        catch
        end
        try
            delete_line(pTopModelName, 'FexBowWorkspace/1', 'FexBowMult/1');
        catch
        end
        % un-comment realtime with root level inports
        set_param(realTimeBlock, 'commented', 'off');
        % comment out from workspace blocks
        set_param(nonRealTimeAftBlock, 'commented', 'on');
        set_param(nonRealTimeBowBlock, 'commented', 'on');
        % add lines
        %port 1 on realtime inports is AFT 
        try
            add_line(pTopModelName, 'FexRealtime/1', 'FexAftMult/1', 'autorouting', 'on');
        catch
        end
        %port 2 on realtime is BOW
        try
            add_line(pTopModelName, 'FexRealtime/2', 'FexBowMult/1', 'autorouting', 'on');
        catch
        end
end