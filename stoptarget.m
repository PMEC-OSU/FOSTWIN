switch simulationType
    case 'SingleSpeedgoat'
        pTg.stop;
        tofile; % stores simulation data as simulation-data.mat (in pwd) 
    case 'TwoSpeedgoats'
        % stop primary
        pTg.stop;
        % stop secondary 
        sTg.stop;
        % TODO - when dual goats debugged - also have toFile.
end