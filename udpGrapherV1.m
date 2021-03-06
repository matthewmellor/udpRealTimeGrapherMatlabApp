function varargout = udpGrapherV1(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @udpGrapherV1_OpeningFcn, ...
                   'gui_OutputFcn',  @udpGrapherV1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Outputs from this function are returned to the command line.
function varargout = udpGrapherV1_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes just before udpGrapherV1 is made visible.
function udpGrapherV1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to udpGrapherV1 (see VARARGIN)
    global xlimit;
    global numDataSetsInPacket;
    global xcounter;
    global countToClearBuffer;
    global secondsBetweenFlushes;
    global startBeenPressed;
    global everStarted;
    global stopBeenPressed;
    global checkBox1Visible;
    global checkBox2Visible;
    global checkBox3Visible;
    global checkBox4Visible;
    global checkBox5Visible;
    global checkBox6Visible;
    global exportSensor1Array;
    global exportSensor2Array;
    global exportSensor3Array;
    global exportSensor4Array;
    global exportSensor5Array;
    global exportSensor6Array;
    global exportContainer1;
    global exportContainer2;
    global exportContainer3;
    global exportContainer4;
    global exportContainer5;
    global exportContainer6;
    global numExportDataDumps;
    global dataCurrentlyExporting;
    global dataBeenExported;
    global graphingHasOccured;
    global numFuncCalls;
  
    xlimit = 50000;
    numDataSetsInPacket = 45; %Change this value if needed = # sets of data in a packet
    xcounter = 0;
    countToClearBuffer = 0;    
    secondsBetweenFlushes = 20;
    startBeenPressed = false;
    everStarted = false;
    stopBeenPressed = false;
    checkBox1Visible = 'on';
    checkBox2Visible = 'on';
    checkBox3Visible = 'on';
    checkBox4Visible = 'on';
    checkBox5Visible = 'on';
    checkBox6Visible = 'on';
    exportSensor1Array = [];
    exportSensor2Array = [];
    exportSensor3Array = [];
    exportSensor4Array = [];
    exportSensor5Array = [];
    exportSensor6Array = [];
    exportContainer1 = {};
    exportContainer2 = {};
    exportContainer3 = {};
    exportContainer4 = {};
    exportContainer5 = {};
    exportContainer6 = {};
    numExportDataDumps = 1;
    dataCurrentlyExporting = false;
    dataBeenExported = false;
    graphingHasOccured = false;
    numFuncCalls = 0;
    
    % Choose default command line output for udpGrapherV1
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes udpGrapherV1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

%-------------------Vitial Callback Function UDP----------------------
function localReadAndPlot(udpClient,~,uPlotSensor1,uPlotSensor2,uPlotSensor3,uPlotSensor4,uPlotSensor5,uPlotSensor6, bytesToRead)
    global xcounter;
    global xlimit;
    global numDataSetsInPacket;
    global countToClearBuffer;
    global t1;
    global secondsBetweenFlushes;
    global userVerifiedFunction; 
    global exportSensor1Array;
    global exportSensor2Array;
    global exportSensor3Array;
    global exportSensor4Array;
    global exportSensor5Array;
    global exportSensor6Array;
    global autoStop;
    global startBeenPressed;
    global stopBeenPressed;
    global exportContainer1;
    global exportContainer2;
    global exportContainer3;
    global exportContainer4;
    global exportContainer5;
    global exportContainer6;
    global numExportDataDumps;
    global numFuncCalls;
    
    data = fread(udpClient,bytesToRead);
    dataStr = char(data(1:end-2)'); %Convert to an array
    autoStopPressed = false; %This is perfect...
    
    if (length(dataStr) == bytesToRead -2) 
        if xcounter >= xlimit 
            if(autoStop) %Where has this been set to true by default?
               if(startBeenPressed)
                    startBeenPressed = false;
                    stopBeenPressed = true;
                    xcounter = 0;
                    flushinput(udpClient);
                    fclose(udpClient);
                    delete(udpClient);
                    clear udpClient;
                    autoStopPressed = true; %Where does this get set back to false?
                end
            else
                xcounter = 0;
                clearpoints(uPlotSensor1);
                clearpoints(uPlotSensor2);
                clearpoints(uPlotSensor3);
                clearpoints(uPlotSensor4);
                clearpoints(uPlotSensor5);
                clearpoints(uPlotSensor6);
            end
        end
        
        if(~autoStopPressed)
            %Convert to an array of numbers
            dataNum = sscanf(dataStr, '%d,', bytesToRead);
            if(length(dataNum) == (numDataSetsInPacket * 6)) 
                dataNum2 = reshape(dataNum,[6,numDataSetsInPacket]);
                sensor1Data = userVerifiedFunction(dataNum2(1,:));
                sensor2Data = userVerifiedFunction(dataNum2(2,:));
                sensor3Data = userVerifiedFunction(dataNum2(3,:));
                sensor4Data = userVerifiedFunction(dataNum2(4,:));
                sensor5Data = userVerifiedFunction(dataNum2(5,:));
                sensor6Data = userVerifiedFunction(dataNum2(6,:));

                xData = xcounter+1:(xcounter+numDataSetsInPacket);

                addpoints(uPlotSensor1, xData, sensor1Data);
                addpoints(uPlotSensor2, xData, sensor2Data);
                addpoints(uPlotSensor3, xData, sensor3Data);
                addpoints(uPlotSensor4, xData, sensor4Data);
                addpoints(uPlotSensor5, xData, sensor5Data);
                addpoints(uPlotSensor6, xData, sensor6Data);
                xcounter = xcounter + numDataSetsInPacket;
               
                if(numFuncCalls == 1)
                    drawnow;
                    numFuncCalls = 0;
                end
                numFuncCalls = numFuncCalls + 1;
                
                exportSensor1Array = [exportSensor1Array, sensor1Data]; 
                exportSensor2Array = [exportSensor2Array, sensor2Data];
                exportSensor3Array = [exportSensor3Array, sensor3Data];
                exportSensor4Array = [exportSensor4Array, sensor4Data];
                exportSensor5Array = [exportSensor5Array, sensor5Data];
                exportSensor6Array = [exportSensor6Array, sensor6Data];

                if(length(exportSensor1Array) >= 10000) %Limiting the length of exportSensorArrays allows for a consistent runtime
                       %Dump the data into the global cell Array
                    exportContainer1{1,numExportDataDumps} = exportSensor1Array;
                    exportContainer2{1,numExportDataDumps} = exportSensor2Array;
                    exportContainer3{1,numExportDataDumps} = exportSensor3Array;
                    exportContainer4{1,numExportDataDumps} = exportSensor4Array;
                    exportContainer5{1,numExportDataDumps} = exportSensor5Array;
                    exportContainer6{1,numExportDataDumps} = exportSensor6Array;
                    exportSensor1Array = [];
                    exportSensor2Array = [];
                    exportSensor3Array = [];
                    exportSensor4Array = [];
                    exportSensor5Array = [];
                    exportSensor6Array = [];
                    numExportDataDumps = numExportDataDumps + 1;
                end
            end
        end
    end
    
    if(~autoStopPressed && startBeenPressed) %Add a catch for excel export stopping
        t2 = clock;
        if (etime(t2,t1) > secondsBetweenFlushes) %Every so often flush the input data to keep the graph from becoming laggy
            flushinput(udpClient); 
            t1 = clock;
        end 
    end
    countToClearBuffer = countToClearBuffer + 1;
end

%------------------ Program Control code -----------------------------

% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
%This is the start button so we want to do alot here....
    global t1;
    global xlimit;
    global numDataSetsInPacket;
    global udpClient;
    global uPlotSensor1;
    global uPlotSensor2;
    global uPlotSensor3;
    global uPlotSensor4;
    global uPlotSensor5;
    global uPlotSensor6;
    global startBeenPressed;
    global everStarted;
    global stopBeenPressed;
    global checkBox1Visible;
    global checkBox2Visible;
    global checkBox3Visible;
    global checkBox4Visible;
    global checkBox5Visible;
    global checkBox6Visible;
    global remoteHostName;
    global remotePort;
    global localPort;
    global validIP;
    global IPEditField;
    global dataCurrentlyExporting;
    global dataBeenExported;
    global exportContainer1;
    global exportContainer2;
    global exportContainer3;
    global exportContainer4;
    global exportContainer5;
    global exportContainer6;
    global numExportDataDumps;
    global dataSetsPerPacket;
    
    validIP = true;
    
    if(~startBeenPressed && ~dataCurrentlyExporting) %Nothing will happen if data is currently exporting
        if(stopBeenPressed)
            %Clear the axes...
            %How to clear the axes
            stopBeenPressed = false;
            clearpoints(uPlotSensor1);
            clearpoints(uPlotSensor2);
            clearpoints(uPlotSensor3);
            clearpoints(uPlotSensor4);
            clearpoints(uPlotSensor5);
            clearpoints(uPlotSensor6);
        end
        
        startBeenPressed = true;
        everStarted = true;
        numDataSetsInPacket = dataSetsPerPacket; %only gets changed when start pressed
        
        if(dataBeenExported || stopBeenPressed)
           %Clear the exportData 
            exportContainer1 = {};
            exportContainer2 = {};
            exportContainer3 = {};
            exportContainer4 = {};
            exportContainer5 = {};
            exportContainer6 = {};
            numExportDataDumps = 1;
        end
        
        udpClient = udp(remoteHostName, remotePort, 'LocalPort', localPort);
        
       %Add more plots here to window if necessary
        uPlotSensor1 = animatedline('Color','g', 'MaximumNumPoints', xlimit, 'Visible', checkBox1Visible);
        uPlotSensor2 = animatedline('Color','r', 'MaximumNumPoints', xlimit, 'Visible', checkBox2Visible);
        uPlotSensor3 = animatedline('Color','b', 'MaximumNumPoints', xlimit, 'Visible', checkBox3Visible);
        uPlotSensor4 = animatedline('Color','y', 'MaximumNumPoints', xlimit, 'Visible', checkBox4Visible);
        uPlotSensor5 = animatedline('Color','m', 'MaximumNumPoints', xlimit, 'Visible', checkBox5Visible);
        uPlotSensor6 = animatedline('Color','w', 'MaximumNumPoints', xlimit, 'Visible', checkBox6Visible);

        bytesToRead = (numDataSetsInPacket -1) * 30 + (32); %Reflects length of message recieved may need to be changed
        udpClient.BytesAvailableFcn = {@localReadAndPlot,uPlotSensor1, uPlotSensor2,uPlotSensor3,uPlotSensor4,uPlotSensor5,uPlotSensor6,bytesToRead};
        udpClient.BytesAvailableFcnMode = 'byte';
        udpClient.BytesAvailableFcnCount = bytesToRead;
        udpClient.InputBufferSize = 1000000;

        t1 = clock; %Get the first clock value
        
        try
           fopen(udpClient); 
        catch
           fclose(udpClient);
           delete(udpClient);
           clear udpClient;
           validIP = false;
           startBeenPressed = false;
           set(IPEditField, 'BackgroundColor', [1 0.9 0.9]);
        end
        
        if(validIP)
          set(IPEditField, 'BackgroundColor', 'white');
          fprintf(udpClient, 'Connection made.');
          pause(3);
        end
    end
end

% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
    global udpClient;
    global xcounter;
    global startBeenPressed;
    global stopBeenPressed;
    if(startBeenPressed)
        startBeenPressed = false;
        stopBeenPressed = true;
        xcounter = 0;
        flushinput(udpClient);
        fclose(udpClient);
        delete(udpClient);
        clear udpClient;
    end
end

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
    global udpClient;
    global startBeenPressed;
    global everStarted;
    if(startBeenPressed && everStarted) %TODO Add try catch 
        flushinput(udpClient);
        fclose(udpClient);
        delete(udpClient);
        clear udpClient;
        clear all;
        fclose(instrfindall);
    end
end

% --- Executes on button press in autoStop.
function autoStop_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of autoStop
     global autoStop;
     if(get(hObject, 'Value') == 0)
        autoStop = false;
     else
         autoStop = true;
     end
end

% --- Executes during object creation, after setting all properties.
function autoStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    global autoStop;
    autoStop = true;
end

%%-------------CheckBox Code/ Graph Toggling ------------------------------

% --- Executes during object creation, after setting all properties.
function checkbox1_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
    set(hObject,'Value',1);
end

% --- Executes during object creation, after setting all properties.
function checkbox2_CreateFcn(hObject, eventdata, handles) %#ok<*DEFNU>
    set(hObject,'Value',1);
end

% --- Executes during object creation, after setting all properties.
function checkbox3_CreateFcn(hObject, eventdata, handles)
    set(hObject,'Value',1);
end

% --- Executes during object creation, after setting all properties.
function checkbox4_CreateFcn(hObject, eventdata, handles)
    set(hObject,'Value',1);
end

% --- Executes during object creation, after setting all properties.
function checkbox5_CreateFcn(hObject, eventdata, handles)
    set(hObject,'Value',1);
end

% --- Executes during object creation, after setting all properties.
function checkbox6_CreateFcn(hObject, eventdata, handles)
    set(hObject,'Value',1);
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
    global uPlotSensor1;
    global startBeenPressed;
    global checkBox1Visible; %making the value of the checkbox global allows us to access in the initial setup
    checkbox1 = get(hObject, 'Value');
    if(checkbox1 == 0)
        checkBox1Visible = 'off';
    else
        checkBox1Visible = 'on';
    end
    
    if(startBeenPressed) %At runtime
        if(checkbox1 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor1,'Visible','off');
        else
            %we received a one
            set(uPlotSensor1, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    global uPlotSensor2;
    global startBeenPressed;
    global checkBox2Visible; 
    checkBox2 = get(hObject, 'Value');
    
    if(checkBox2 == 0)
        checkBox2Visible = 'off';
    else
        checkBox2Visible = 'on';
    end
    
    if(startBeenPressed)
        if(checkBox2 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor2,'Visible','off');
        else
            %we received a one
            set(uPlotSensor2, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
    global startBeenPressed;
    global uPlotSensor3;
    global checkBox3Visible; 
    checkBox3 = get(hObject, 'Value');
    
    if(checkBox3 == 0)
        checkBox3Visible = 'off';
    else
        checkBox3Visible = 'on';
    end
    
    if(startBeenPressed)
        if(checkBox3 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor3,'Visible','off');
        else
            %we received a one
            set(uPlotSensor3, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
    global uPlotSensor4;
    global startBeenPressed;
    global checkBox4Visible; 
    checkBox4 = get(hObject, 'Value');
    
    if(checkBox4 == 0)
        checkBox4Visible = 'off';
    else
        checkBox4Visible = 'on';
    end
    
    if(startBeenPressed)
        if(checkBox4 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor4,'Visible','off');
        else
            %we received a one
            set(uPlotSensor4, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
    global uPlotSensor5;
    global startBeenPressed;
    global checkBox5Visible; 
    checkBox5 = get(hObject, 'Value');
    
    if(checkBox5 == 0)
        checkBox5Visible = 'off';
    else
        checkBox5Visible = 'on';
    end
    if(startBeenPressed)
        if(checkBox5 == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor5,'Visible','off');
        else
            %we received a one
            set(uPlotSensor5, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
    global uPlotSensor6;
    global startBeenPressed;
    global checkBox6Visible; 
    checkBox6 = get(hObject, 'Value');
    
    if(checkBox6 == 0)  %This to update the state so start callback will be accurate
        checkBox6Visible = 'off';
    else
        checkBox6Visible = 'on';
    end
    
    if(startBeenPressed)
            if(checkBox6 == 0)
              %Set plot 1 to be invisible
              set(uPlotSensor6,'Visible','off');
            else
                %we received a one
                set(uPlotSensor6, 'Visible', 'on');
            end
    end
end

%----------------------Tool Bar Code --------------------------

function file_menu_Callback(hObject, eventdata, handles)
end

function udp_properties_menu_Callback(hObject, eventdata, handles)
end

function graph_properties_menu_Callback(hObject, eventdata, handles)
end

function properties_menu_Callback(hObject, eventdata, handles)
end

function excel_export_Callback(hObject, eventdata, handles)
    global exportContainer1;
    global exportContainer2;
    global exportContainer3;
    global exportContainer4;
    global exportContainer5;
    global exportContainer6;
    global dataBeenExported;
    global dataCurrentlyExporting;
    global exportSensor1Array;
    global exportSensor2Array;
    global exportSensor3Array;
    global exportSensor4Array;
    global exportSensor5Array;
    global exportSensor6Array;
    global udpClient;
    global xcounter;
    global startBeenPressed;
    global stopBeenPressed;
    
    if(startBeenPressed) %Stop graphing if still graphing
        startBeenPressed = false;
        stopBeenPressed = true;
        xcounter = 0;
        fclose(udpClient);
        delete(udpClient);
        clear udpClient;
    end
   
    dataBeenExported = false;
    dataCurrentlyExporting = true;

    %Add Any data that hasn't been addedTo exportContainers
    index1 = length(exportContainer1) + 1; %It shouldn't matter if export pressed repeatedly bc of this
    index2 = length(exportContainer2) + 1;
    index3 = length(exportContainer3) + 1;
    index4 = length(exportContainer4) + 1;
    index5 = length(exportContainer5) + 1;
    index6 = length(exportContainer6) + 1;
        
    exportContainer1{1,index1} = exportSensor1Array; %There will be no repeated data...
    exportContainer2{1,index2} = exportSensor2Array; %BC exportSensorXArray = []
    exportContainer3{1,index3} = exportSensor3Array; %After the first time the data is added
    exportContainer4{1,index4} = exportSensor4Array;
    exportContainer5{1,index5} = exportSensor5Array;
    exportContainer6{1,index6} = exportSensor6Array;
        
    s1 = transpose([exportContainer1{:}]);
    s2 = transpose([exportContainer2{:}]);
    s3 = transpose([exportContainer3{:}]);
    s4 = transpose([exportContainer4{:}]);
    s5 = transpose([exportContainer5{:}]);
    s6 = transpose([exportContainer6{:}]);

    prompt = {'  Enter the desired filename (Do not include .xlsx)  '};
    dlg_title = 'Excel Export';
    num_lines = 1;
    defaultans = {'foot_sensor_data_1'};
    answer = inputdlg(prompt, dlg_title,num_lines, defaultans);
    success = true;
        
    if(~isempty(answer) && ~isempty(s1))
        filename = answer{1,1};
           
        try
            xlswrite(filename,s1,1,'A1'); %If you press it too soon it causes an error
            xlswrite(filename,s2,1,'B1');
            xlswrite(filename,s3,1,'C1');
            xlswrite(filename,s4,1,'D1');
            xlswrite(filename,s5,1,'E1');
            xlswrite(filename,s6,1,'F1');
        catch
            success = false;
        end
        
        if(success)
            msgbox('Export Completed.');
        else 
            msgbox('Export Failed');
        end
        
        dataBeenExported = true; 
        dataCurrentlyExporting = false;
    end 
        
    exportSensor1Array = []; 
    exportSensor2Array = []; 
    exportSensor3Array = [];
    exportSensor4Array = [];
    exportSensor5Array = [];
    exportSensor6Array = [];
end

function help_Callback(hObject, eventdata, handles)

    %TODO Add a long message here to help people debug why their program
    %isn't working...
    h1 = sprintf('Common issues \n1.Nothing is graphing');
    h2 = sprintf('   Check the following:');
    h3 = sprintf('       A. Udp Connection');
    h4 = sprintf('       B. Graph Limits too small');
    h5 = sprintf('');
    h6 = sprintf('   UDP Connection Issues:');
    h7 = sprintf('      1. Double Check');
    h8 = sprintf('              Remote Server IP Address/Hostname');
    h9 = sprintf('              Remote Port');
    h10 = sprintf('              Local Port');
    h11 = sprintf('      2. Data Packets');
    h12 = sprintf('             Is your remote server packaging the data correctly?');
    h13 = sprintf('             Convention used is 6 comma seperated values per data set');
    h14 = sprintf('             Last data set must terminate in newline character');
    h15 = sprintf('             and not a comma');
    h = msgbox({h1,h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15},'Help');
    
end

%----------------UDP Parameters Code ------------------------------------

% --- Executes during object creation, after setting all properties.
function HostIPEditField_CreateFcn(hObject, eventdata, handles)
    global remoteHostName;
    global IPEditField;
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    remoteHostName = get(hObject,'String');
    IPEditField = hObject;
end

% --- Executes during object creation, after setting all properties.
function RemotePortEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    global remotePort;
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    remotePort = str2double(get(hObject,'String'));
end

% --- Executes during object creation, after setting all properties.
function LocalPortEdit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    global localPort;
    localPort = str2double(get(hObject,'String'));
end

function RemotePortEdit_Callback(hObject, eventdata, handles)
    global remotePort;
    remotePort = str2double(get(hObject,'String'));
end

function LocalPortEdit_Callback(hObject, eventdata, handles)
    global localPort; %Get the value of the local port
    localPort = str2double(get(hObject,'String'));
end

function HostIPEditField_Callback(hObject, eventdata, handles)
    global remoteHostName; %Get the value of the hostname
    remoteHostName = get(hObject,'String');
end

function setButton_Callback(hObject, eventdata, handles)
    %Left blank on purpose
    %This may be changed in future iterations
end

function data_sets_per_package_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of data_sets_per_package as text
%        str2double(get(hObject,'String')) returns contents of data_sets_per_package as a double

    global dataSetsPerPacket;
    dataSetsPerPacket = str2double(get(hObject, 'String'));
end

% --- Executes during object creation, after setting all properties.
function data_sets_per_package_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    global dataSetsPerPacket;
    dataSetsPerPacket = 45;
    
end

%-------------------USER EQUATION INPUT CODE -----------------------------

function edit_equation_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    %Set the initial equation to be applied to the graph
    global userVerifiedFunction;
    global userDefinedAFunction;
    userDefinedAFunction = false;
    userVerifiedFunction = str2func('@(x) x');
    %This will always be x...which will be the always be acceptable
    %input/the default
end

function edit_equation_Callback(hObject, eventdata, handles)
    global userUnVerifiedFunction;
    global userDefinedAFunction;
    global userFunctionFieldHandle;
    global userEQString;
    userDefinedAFunction = true;
    userFunctionFieldHandle = hObject;
    userEQString = get(hObject, 'String');
    userUnVerifiedFunction = str2func(['@(x)' vectorize(userEQString)]);
    %There is a potential TODO here... parse the input to make it not
    %accept plot
end

function applyEquation_Callback(hObject, eventdata, handles)
    global userUnVerifiedFunction;
    global userVerifiedFunction;
    global userDefinedAFunction;
    global userFunctionFieldHandle; 
    global userEQString;
    x = [1,2,3];
    equationWasValid = true;
    if(userDefinedAFunction) %In the event user pressed apply without having inputted an equation.
        try
           y = userUnVerifiedFunction(x);
        catch
           set(userFunctionFieldHandle, 'BackgroundColor', [1 0.9 0.9]);
           equationWasValid = false;
        end
        if(equationWasValid)
            if(length(y) == 3)
                userVerifiedFunction = userUnVerifiedFunction;
                set(userFunctionFieldHandle, 'BackgroundColor', 'white');
            else
                userVerifiedFunction = str2func(strcat('@(x)',userEQString,'*ones(1,length(x))'));
            end
        end
    end
end

% --- Executes on button press in reset_equation.
function reset_equation_Callback(hObject, eventdata, handles)
    global userVerifiedFunction;
    global userFunctionFieldHandle;
    global userUnVerifiedFunction;
    userVerifiedFunction = str2func('@(x) x');
    userUnVerifiedFunction = userVerifiedFunction;
    set(userFunctionFieldHandle, 'String', 'x');
    set(userFunctionFieldHandle, 'BackgroundColor', 'white');
end

% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
    %TODO bring up popup about syntax
    h = msgbox('Correct Syntax for the equation box includes any valid matlab function that utilizes x', 'Help');
end

%-------------------Graph Parameters Code ----------------------------

function x_axis_edit_length_Callback(hObject, eventdata, handles)
% hObject    handle to x_axis_edit_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_axis_edit_length as text
%        str2double(get(hObject,'String')) returns contents of x_axis_edit_length as a double
     global xAxisLength;
     global xAxisLengthValueHandle;
     xAxisLength = get(hObject, 'String');
     xAxisLengthValueHandle = hObject;
end

% --- Executes during object creation, after setting all properties.
function x_axis_edit_length_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
     global xAxisLength;
     global xAxisLengthValueHandle;
     xAxisLength = get(hObject, 'String');
     xAxisLengthValueHandle = hObject;

end

function y_axis_edit_legth_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of y_axis_edit_legth as text
%        str2double(get(hObject,'String')) returns contents of y_axis_edit_legth as a double
    global yAxisLength;
    global yAxisLengthValueHandle;
    yAxisLength = (get(hObject,'String')); %Need to check if this isn't a number...
    yAxisLengthValueHandle = hObject; %So you can change the color if it is wrong...

end

% --- Executes during object creation, after setting all properties.
function y_axis_edit_legth_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    global yAxisLength;
    global yAxisLengthValueHandle;
    yAxisLength = (get(hObject,'String')); %Need to check if this isn't a number...
    yAxisLengthValueHandle = hObject; 
end

function edit_graph_title_Callback(hObject, eventdata, handles)
% hObject    handle to edit_graph_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_graph_title as text
%        str2double(get(hObject,'String')) returns contents of edit_graph_title as a double
    global graphTitle;
    graphTitle = get(hObject, 'String');

end

% --- Executes during object creation, after setting all properties.
function edit_graph_title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_graph_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    global graphTitle;
    graphTitle = 'Sensor Values Vs. Number of Samples';
end

function edit_y_axis_Callback(hObject, eventdata, handles)
% hObject    handle to edit_y_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_y_axis as text
%        str2double(get(hObject,'String')) returns contents of edit_y_axis as a double
    global yAxisLabel;
    yAxisLabel = get(hObject, 'String');
end

% --- Executes during object creation, after setting all properties.
function edit_y_axis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_y_axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    global yAxisLabel;
    yAxisLabel = 'Sensor Values';
end

function xAxisLabelEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xAxisLabelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xAxisLabelEdit as text
%        str2double(get(hObject,'String')) returns contents of xAxisLabelEdit as a double
    global xAxisLabel;
    xAxisLabel = get(hObject, 'String');
end

% --- Executes during object creation, after setting all properties.
function xAxisLabelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xAxisLabelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    global xAxisLabel;
    xAxisLabel = 'Number of Samples';

end

% --- Executes on button press in apply_graph_button.
function apply_graph_button_Callback(hObject, eventdata, handles)
% hObject    handle to apply_graph_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%First add the condition that this will only work if start is off
global startBeenPressed;
global graphTitle;
global yAxisLabel;
global yAxisLength;
global yAxisLengthValueHandle;
global xAxisLabel;
global xAxisLength;
global xAxisLengthValueHandle;
global axesHandle;
global xlimit;
global graphLabelHandle;
global editXAxisLabelHandle;
    if(~startBeenPressed)
        set(graphLabelHandle,'String', graphTitle);
        axesHandle.YLabel.String = yAxisLabel;
        set(editXAxisLabelHandle, 'String', xAxisLabel);
       
        if(isempty(regexp(yAxisLength, '\D', 'ONCE')))
           yAxisVal = str2double(yAxisLength);
           if(yAxisVal ~= 0)
               axesHandle.YLim = [0 yAxisVal]; %what happens if this is neg?
               set(yAxisLengthValueHandle, 'BackgroundColor', [1 1 1]);
           end
        else
            set(yAxisLengthValueHandle, 'BackgroundColor', [1 0.9 0.9]);
        end
        
        if(isempty(regexp(xAxisLength, '\D', 'ONCE')) )
            xAxisVal = str2double(xAxisLength);
            if(xAxisVal ~= 0)
                xlimit = xAxisVal; 
                axesHandle.XLim = [0 xlimit];
                set(xAxisLengthValueHandle, 'BackgroundColor', [1 1 1]);
            end
        else 
            set(xAxisLengthValueHandle, 'BackgroundColor', [1 0.9 0.9]);
        end
    end
end

% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes4
     global axesHandle;
     axesHandle = hObject;
     axesHandle.YLabel.String = 'Sensor Values';
end

% --- Executes during object creation, after setting all properties.
function editXAxisLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editXAxisLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    global editXAxisLabelHandle;
    editXAxisLabelHandle = hObject;
end

% --- Executes during object creation, after setting all properties.
function text18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    global graphLabelHandle;
    graphLabelHandle = hObject;
end
