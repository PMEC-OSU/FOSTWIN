
switch simulationType
    % signal processing for realtime data
    case "SingleSpeedgoat"
        % IF RUNNING REALTIME LOCALLY - SET YOUR SPEEDOGOAT IP HERE
        speedgoatIP = '192.168.2.248';

        pTopModelName = 'FOSTWIN';
        % IF RUNNING REALTIME LOCALLY - SET A NEW DATA FOLDER HERE WITH
        % FOSTWIN AT THE END OF THE PATH
        loggingDataDir =  'D:\src\SANDIA-OSU\FOSTWIN-Data\FOSTWIN';
        %loggingDataDir =  'D:\log\FOSTWIN';
        mkdir(loggingDataDir);


        % CHANGE THE VLAUE AFTER THE "-pw" flag if you have a non-default
        % slrt password for ssh connections
        system(['pscp -pw slrt -r slrt@', speedgoatIP, ':/home/slrt/applications/', pTopModelName, '/* ' ,loggingDataDir])
        % get the Ts in this engine too
        if strcmp(twinType, 'WECSim')
            Ts = 1/200;
        else 
            Ts = 1/1000;
        end
        
        slrealtime.fileLogImport('Directory', loggingDataDir);

        
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
                    outputFT.(blockName).(signalName) = squeeze(data1{i}.Values.(signalName).Data);
                    outputFT.(blockName).time = data1{i}.Values.(signalName).Time;

                end
            end
            
            outputFT.Conditions.wave.H = waveH;
            outputFT.Conditions.wave.T = waveT;
            outputFT.Conditions.wavetype = waveType;
            outputFT.Conditions.Ts = Ts;
            outputFT.Conditions.simulationType = simulationType;

            if strcmp(twinType, 'WECSim')
                % add get WECSim post-processed data
                stopWecSim;
                % add WECSim post-processed data to the output that is stored
                outputFT.WECSim = output;
            end
            save('simulation-data.mat','outputFT');
        end
    case "NonRealTime"
        % non-realtime signal processing
        if exist('data','var')
    
            blockNames = {'ControlSignals','Power'}; % get(data);
            
            for i = 1:length(blockNames)
                signalNames = fieldnames(data.(blockNames{i}));
                for j = 1:length(signalNames)
                    outputFT.(blockNames{i}).(signalNames{j}) = squeeze(data.(blockNames{i}).(signalNames{j}).Data);
                    outputFT.(blockNames{i}).time = squeeze(data.(blockNames{i}).(signalNames{j}).Time);
                end
            end
                       
            outputFT.Conditions.wave.H = waveH;
            outputFT.Conditions.wave.T = waveT;
            outputFT.Conditions.wavetype = waveType;
            outputFT.Conditions.Ts = Ts;
            outputFT.Conditions.simulationType = simulationType;
            
            if strcmp(twinType, 'WECSim')
                % add get WECSim post-processed data
                stopWecSim;
                % add WECSim post-processed data to the output that is stored
                outputFT.WECSim = output;
            end
            save('simulation-data.mat','outputFT');
        end
    otherwise
        fprintf("Unable to post process, unknown simulation type selected...\n")
end

