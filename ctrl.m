function [error] = ctrl(portName, value)
%CTRL - wrapper to set params while running a realtime simulation

error = "";
pTopModelName = evalin('base','pTopModelName');
pTg = evalin('base','pTg');
allowed_ports = ['ParamIn1' 'ParamIn2' 'ParamIn3' 'ParamIn4' 'waveH'];

if ismember(portName, allowed_ports) == 0
   error = sprintf('portName argument not accepted.\nExpected: param1, param2, param3, param4, waveH\nRecieved: %s', portName);
   return
end

try 
%     pTg.setparam([pTopModelName, '/', portName], 'Value', value);
    pTg.setparam(['pTopModel/Receive Control UDP /',portName],'Value',value);
catch e
    error = e;
end

end