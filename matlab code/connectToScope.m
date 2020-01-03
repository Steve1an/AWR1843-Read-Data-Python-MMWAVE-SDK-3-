ip='129.31.139.76';
% Create a TCPIP object.
interfaceObj = instrfind('Type', 'tcpip', 'RemoteHost', ip, 'RemotePort', 1861, 'Tag', '');

% Create the TCPIP object if it does not exist
% otherwise use the object that was found.
if isempty(interfaceObj)
    interfaceObj = tcpip(ip, 1861);
else
    fclose(interfaceObj);
    interfaceObj = interfaceObj(1);
end

deviceObj = icdevice('lecroy_basic_driver.mdd', interfaceObj);
connect(deviceObj);
invoke(deviceObj,'beep')