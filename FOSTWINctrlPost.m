
switch simulationType
    % signal processing for realtime data
    case "SingleSpeedgoat"
        % IF RUNNING REALTIME LOCALLY - SET YOUR SPEEDOGOAT IP HERE
        speedgoatIP = '192.168.2.248';

        pTopModelName = 'FOSTWIN';
        % IF RUNNING REALTIME LOCALLY - SET A NEW DATA FOLDER HERE WITH
        % FOSTWIN AT THE END OF THE PATH
        loggingDataDir =  'D:\src\SANDIA-OSU\FOSTWIN-Data\FOSTWIN';


        % CHANGE THE VLAUE AFTER THE "-pw" flag if you have a non-default
        % slrt password for ssh connections
        system(['pscp -pw slrt -r slrt@', speedgoatIP, ':/home/slrt/applications/', pTopModelName, '/* ' ,loggingDataDir])
        % get the Ts in this engine too
        if strcmp(twinType, 'WECSim')
            switch waveType
                case 'regular'
                    Ts = 1/100; 
                case 'irregular'
                    Ts = 1/100;    
            end
        else 
            Ts = 1/1000;
        end
        
%         slrealtime.fileLogImport('Directory', loggingDataDir);
         importLogData(loggingDataDir)

        
        
        % Get data from speedgoat
        runIDs = Simulink.sdi.getAllRunIDs; % get run ID
        runID = runIDs(end);
        
        rtRun = Simulink.sdi.getRun(runID); % get data for last run
        SignalData = rtRun.export;
      
        if exist('SignalData', 'var')
            data1 = SignalData;
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

            outputSimulation.Power.powerMechAverage = squeeze(outputSimulation.Power.powerMechAverage);
            outputSimulation.ControlSignals.CaptureWidth = squeeze(outputSimulation.ControlSignals.CaptureWidth);
            outputSimulation.ControlSignals.ctrlParam1 = squeeze(outputSimulation.ControlSignals.ctrlParam1);
            outputSimulation.ControlSignals.ctrlParam2 = squeeze(outputSimulation.ControlSignals.ctrlParam2);
            outputSimulation.ControlSignals.ctrlParam3 = squeeze(outputSimulation.ControlSignals.ctrlParam3);
            outputSimulation.ControlSignals.ctrlParam4 = squeeze(outputSimulation.ControlSignals.ctrlParam4);
            
%             outputSimulation.Conditions.wave.H = waveH;
%             outputSimulation.Conditions.wave.T = waveT;
%             outputSimulation.Conditions.wavetype = waveType;
%             outputSimulation.Conditions.Ts = Ts;
%             outputSimulation.Conditions.simulationType = simulationType;

            % TODO - when wecsim is working again - make sure post process
            % works 
            if strcmp(twinType, 'WECSim')
                % add get WECSim post-processed data
                stopWecSim;
                % add WECSim post-processed data to the output that is stored
                outputSimulation.WECSim = output;
            end
            save('simulation-data.mat','outputSimulation');
        end
    case "NonRealTime"
        % non-realtime signal processing
        if exist('data','var')
    
            blockNames = {'ControlSignals','Power'}; % get(data);
            
            for i = 1:length(blockNames)
                signalNames = fieldnames(data.(blockNames{i}));
                for j = 1:length(signalNames)
                    output.(blockNames{i}).(signalNames{j}) = data.(blockNames{i}).(signalNames{j}).Data;
                    output.(blockNames{i}).time = data.(blockNames{i}).(signalNames{j}).Time;
                end
            end
            
            output.Power.powerMechAverage = squeeze(output.Power.powerMechAverage);
            output.ControlSignals.CaptureWidth = squeeze(output.ControlSignals.CaptureWidth);
            output.ControlSignals.ctrlParam1 = squeeze(output.ControlSignals.ctrlParam1);
            output.ControlSignals.ctrlParam2 = squeeze(output.ControlSignals.ctrlParam2);
            output.ControlSignals.ctrlParam3 = squeeze(output.ControlSignals.ctrlParam3);
            output.ControlSignals.ctrlParam4 = squeeze(output.ControlSignals.ctrlParam4);
            
            output.Conditions.wave.H = waveH;
            output.Conditions.wave.T = waveT;
            output.Conditions.wavetype = waveType;
            output.Conditions.Ts = Ts;
            output.Conditions.simulationType = simulationType;
            
            save('simulation-data.mat','output');
        end
    otherwise
        fprintf("Unable to post process, unknown simulation type selected...\n")
end

