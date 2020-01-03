clearvars; 
close all
delete(instrfind);

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



N = 200;

% Setup radar with the parameters from the configuration file
configFile = "D:\steve\Chromdownloads\profile.cfg";
[DATA_sphandle,UART_sphandle, ConfigParameters] = radarSetup18XX(configFile);

%% Initialize the figure
figure;
set(gcf, 'Position', get(0, 'Screensize'));
H = uicontrol('Style', 'PushButton', ...
                    'String', 'Stop', ...
                    'Callback', 'stopVal = 1','Position',[100 600 100 30]);
h = scatter([],[],'filled');
axis([-0.5,0.5,0,1.5]);
% axis([-0.5,0.5,0,0.9]);
xlabel('X (m)'); ylabel('Y (m)');
grid minor

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%                   MAIN   LOOP              %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&%%%%%%%%%%%%%%%%%%%%%%%%%

myInd = 1;
lastreadTime = 0;
dataOk = 0;
stopVal = 0;
prevSeparation = -0.3;
previousTime = 0;
prevCentroidPos = nan(1,6);
shoeSize = 26.5/100; % 26.5 cm

tic
while (myInd <= N)
    dataOk = 0;
    timeNow = toc;
    elapsedTime = timeNow - lastreadTime;
    
    % Read the data from the radar:
    [dataOk, frameNumber, detObj] = readAndParseData18XX(DATA_sphandle, ConfigParameters);
    lastreadTime = timeNow;
    
    if dataOk == 1    
        
        % Store all the data from the radar
        frame{myInd} = detObj;
        
        % Plot the radar points
        h.XData = -detObj.x;
        h.YData = detObj.y;
        drawnow limitrate;
        pause(0.05);
        if (detObj.numObj>1)
            invoke(deviceObj,'beep')
        end
        myInd = myInd + 1;     
    end
    
    if stopVal == 1
        stopVal = 0;
        break;
    end
        
end
fprintf(UART_sphandle, 'sensorStop');
delete(instrfind);
disconnect(deviceObj);
close all
        



















