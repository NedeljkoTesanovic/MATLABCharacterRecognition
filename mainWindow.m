function varargout = mainWindow(varargin)
global stepCells imgLoaded areLoaded
% MAINWINDOW MATLAB code for mainWindow.fig
%      MAINWINDOW, by itself, creates a new MAINWINDOW or raises the existing
%      singleton*.
%
%      H = MAINWINDOW returns the handle to a new MAINWINDOW or the handle to
%      the existing singleton*.
%
%      MAINWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINWINDOW.M with the given input arguments.
%
%      MAINWINDOW('Property','Value',...) creates a new MAINWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainWindow

% Last Modified by GUIDE v2.5 25-May-2021 22:30:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @mainWindow_OutputFcn, ...
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


% --- Executes just before mainWindow is made visible.
function mainWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainWindow (see VARARGIN)

% Choose default command line output for mainWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.radiobutton_Sharpen, 'Value', 1);
axes(handles.axes_Preview);
imshow('hehe.jpg');
clear all;
clc;
global areLoaded stepCells br imgLoaded
areLoaded = 0;
imgLoaded = 0;
br = 0;

% --- Outputs from this function are returned to the command line.
function varargout = mainWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
global stepCells

% --- Executes on button press in pushbutton_Browse.
function pushbutton_Browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img imgLoaded
try
    [fileName, folderPath] = uigetfile('*.jpg');
    fullPath = append(folderPath, fileName);
    img = imread(fullPath);
    axes(handles.axes_Preview);
    imshow(img)
    imgLoaded = 1;
catch e
    msgbox("No image loaded! Stack trace: " + newline + e.message);
end


% --- Executes on button press in pushbutton_Apply.
function pushbutton_Apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img imgLoaded
if imgLoaded == 1
    axes(handles.axes_Preview);
    if get(handles.radiobutton_Sharpen, 'Value') == 1
        try
            for i = 1:str2num(handles.edit_Passes.String)
                imgp = imsharpen(img);
            end
        imshow(imgp);
        if questdlg("Sharpening filter - Apply results?") == "Yes"
            img = imgp;
        end
        imshow(img);
        catch e
           msgbox("Error applying filter! Stack trace:"+newline+e.message);
       end 
    elseif get(handles.radiobutton_Median, 'Value') == 1 %Apply median filter
       try
           for i = 1:str2num(handles.edit_Passes.String)
                imgp = medfilt2(im2gray(img), [str2num(handles.edit_Param1.String) str2num(handles.edit_Param2.String)]);
           end
        imshow(imgp);
        if questdlg("Median filter - Apply results?") == "Yes"
            img = imgp;
        end
        imshow(img);
       catch e
           msgbox("Error applying filter! Stack trace:"+newline+e.message);
       end
    elseif get(handles.radiobutton_Wiener, 'Value') == 1
        try
            for i = 1:str2num(handles.edit_Passes.String)
                imgp = wiener2(im2gray(img), [str2num(handles.edit_Param1.String) str2num(handles.edit_Param2.String)]);
            end
            imshow(imgp);
            if questdlg("Wiener filter - Apply results?") == "Yes"
                img = imgp;
            end
            imshow(img);
        catch e
            msgbox("Error applying filter! Stack trace:"+newline+e.message);
        end
    elseif get(handles.radiobutton_Contrast, 'Value') == 1
        try
            imgp = histeq(img);
            imshow(imgp);
             if questdlg("Histogram equalization - Apply results?") == "Yes"
                img = imgp;
             end
             imshow(img);
        catch e
            msgbox("Error scaling contrast! Stack trace: " + newline + e.message);
        end
    elseif get(handles.radiobutton_Snp, 'Value') == 1
        try
            imgp = imnoise(img, 'salt & pepper');
            imshow(imgp);
             if questdlg("Salted and peppered - Apply results?") == "Yes"
                img = imgp;
             end
             imshow(img);
        catch e
            msgbox("Error salting or peppering! Stack trace: " + newline + e.message);
        end
    else
        try
            imgp = imnoise(img, 'gaussian');
            imshow(imgp);
             if questdlg("Gaussed - Apply results?") == "Yes"
                img = imgp;
             end
             imshow(img);
        catch e
            msgbox("Error gaussing the image! Stack trace: " + newline + e.message);
        end
    end
else
    msgbox("No image to modify! Load an image first!");
end
% --- Executes on button press in pushbutton_Read.
function pushbutton_Read_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stepCells img br imgLoaded
br = 0;
set(handles.pushbutton_Next, 'visible', 'off');
set(handles.pushbutton_Prev, 'visible', 'off');
try
    if imgLoaded == 1
        handles.text_Working.String = "PLEASE WAIT";
        guidata(hObject, handles);

        if handles.checkbox_autoBin.Value
            threshold = "-1"
        else
            threshold = handles.edit_BinT.String
        end
        %imshow(img)
        [retVal, steps] = readFromImage(img, threshold, handles.edit_RoiT.String, handles.edit_CharT.String, handles.edit_UndesirableT.String);    
        stepCells = steps;
        axes(handles.axes_Result);
        cla(handles.axes_Result, 'reset');
        imshow(stepCells{1,1});
        handles.text_Explanation.String = stepCells{1,2};
        br = 1;
        set(handles.pushbutton_Next, 'visible', 'on');
        set(handles.text_Explanation, 'visible', 'on');
        handles.text_Result.String = retVal;
        handles.text_Working.String = "";
        guidata(hObject, handles);
else
    msgbox("No image loaded! Load an image first!");
    end
catch e
    msgbox("Error reading image! Stack Trace: " + e.message);
end    
% --- Executes when selected object is changed in uibuttongroup_Modification.
function uibuttongroup_Modification_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_Modification 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switchTag = get(eventdata.NewValue,'tag') 
if switchTag == "radiobutton_Sharpen"   
        set(handles.edit_Passes, 'string', 1);
        set(handles.edit_Passes, 'visible','on');
        set(handles.text_Passes, 'visible', 'on');
        set(handles.edit_Param1,'visible','off');
        set(handles.text_Param1,'visible','off');
        set(handles.edit_Param2,'visible','off');
        set(handles.text_Param2,'visible','off');
     set(handles.text_Gray, 'visible', 'off');
    elseif switchTag == "radiobutton_Contrast" || switchTag == "radiobutton_Snp" || switchTag == "radiobutton_Gaussian"
        set(handles.edit_Passes, 'visible','off');
        set(handles.text_Passes, 'visible', 'off');
        set(handles.edit_Param1,'visible','off');
        set(handles.text_Param1,'visible','off');
        set(handles.edit_Param2,'visible','off');
        set(handles.text_Param2,'visible','off');
        set(handles.text_Gray, 'visible', 'off');
    else
        set(handles.edit_Passes, 'visible','on');
        set(handles.text_Passes, 'visible', 'on');
        set(handles.edit_Passes, 'string', 1)
        set(handles.edit_Param1, 'string', 3);
        set(handles.edit_Param1,'visible','on');
        set(handles.text_Param1,'string', "Mask width");
        set(handles.text_Param1,'visible','on');
        set(handles.edit_Param2, 'string', 3);
        set(handles.edit_Param2,'visible','on');
        set(handles.text_Param2,'string', "Mask height");
        set(handles.text_Param2,'visible','on');
       set(handles.text_Gray, 'visible', 'on');
end

% --- Executes on button press in radiobutton_Median.
function radiobutton_Median_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Median (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Median


% --- Executes on button press in radiobutton_Gaussian.
function radiobutton_Gaussian_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Gaussian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Gaussian


% --- Executes on button press in radiobutton_Sharpen.
function radiobutton_Sharpen_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Sharpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Sharpen



function textbox_mod_Callback(hObject, eventdata, handles)
% hObject    handle to textbox_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textbox_mod as text
%        str2double(get(hObject,'String')) returns contents of textbox_mod as a double


% --- Executes during object creation, after setting all properties.
function textbox_mod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textbox_mod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_Passes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Passes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Passes as text
%        str2double(get(hObject,'String')) returns contents of edit_Passes as a double


% --- Executes during object creation, after setting all properties.
function edit_Passes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Passes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Param1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Param1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Param1 as text
%        str2double(get(hObject,'String')) returns contents of edit_Param1 as a double


% --- Executes during object creation, after setting all properties.
function edit_Param1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Param1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Param2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Param2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Param2 as text
%        str2double(get(hObject,'String')) returns contents of edit_Param2 as a double


% --- Executes during object creation, after setting all properties.
function edit_Param2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Param2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Param3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Param3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Param3 as text
%        str2double(get(hObject,'String')) returns contents of edit_Param3 as a double


% --- Executes during object creation, after setting all properties.
function edit_Param3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Param3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Next.
function pushbutton_Next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stepCells br
if br < size(stepCells,1)
    cla(handles.axes_Result, 'reset');
    set(handles.pushbutton_Prev, 'visible', 'on');
    br = br + 1;
    axes(handles.axes_Result)
    if stepCells{br,3} == 1
        plot(stepCells{br,1});
        axis tight;
        xlabel(stepCells{br,4});
        ylabel(stepCells{br,5});
        if stepCells{br,6} == 1
            hold on;
            plot(stepCells{br,7});
            legend(stepCells{br,8}, stepCells{br,9});
        end
    elseif stepCells{br,3} == 2
        imshow(stepCells{br,1});
        hold on;
        plot(stepCells{br,4},'r');
        axis tight;
        legend("White count by column");
    elseif stepCells{br,3} == 4
        plot(stepCells{br,1});
        axis tight;
        xticklabels(stepCells{br,4});
        xticks(1:length(stepCells{br,4}));
        xlim([1 length(stepCells{br,4})]);
        grid on;
    else
        imshow(stepCells{br,1});
    end
    set(handles.text_Explanation, 'String', stepCells{br, 2});
    if br == size(stepCells,1)
        set(handles.pushbutton_Next,'visible',"off");
    end
    guidata(hObject, handles);
end
% --- Executes on button press in pushbutton_Prev.
function pushbutton_Prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global stepCells br
if br > 1
    set(handles.pushbutton_Next, 'visible', 'on');
    cla(handles.axes_Result, 'reset');
    br = br - 1;
    axes(handles.axes_Result)
    if stepCells{br,3} == 1
        plot(stepCells{br,1});
        axis tight;
        xlabel(stepCells{br,4});
        ylabel(stepCells{br,5});
        if stepCells{br,6} == 1
            hold on;
            plot(stepCells{br,7});
            legend(stepCells{br,8}, stepCells{br,9});
        end
    elseif stepCells{br,3} == 2
        imshow(stepCells{br,1});
        hold on;
        plot(stepCells{br,4},'r');
        axis tight;
        legend("White count by column");
    elseif stepCells{br,3} == 4
        plot(stepCells{br,1});
        axis tight;
        xticklabels(stepCells{br,4});
        xticks(1:length(stepCells{br,4}));
        xlim([1 length(stepCells{br,4})]);
        grid on;
    else
        imshow(stepCells{br,1});
    end
    set(handles.text_Explanation, 'String', stepCells{br, 2});
    if br == 1
        set(handles.pushbutton_Prev, 'visible', 'off');
    end
    guidata(hObject, handles);
end

function edit_Param4_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Param4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Param4 as text
%        str2double(get(hObject,'String')) returns contents of edit_Param4 as a double


% --- Executes during object creation, after setting all properties.
function edit_Param4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Param4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Param5_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Param5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Param5 as text
%        str2double(get(hObject,'String')) returns contents of edit_Param5 as a double


% --- Executes during object creation, after setting all properties.
function edit_Param5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Param5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Param6_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Param6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Param6 as text
%        str2double(get(hObject,'String')) returns contents of edit_Param6 as a double


% --- Executes during object creation, after setting all properties.
function edit_Param6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Param6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uibuttongroup_Modification_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup_Modification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit_BinT_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BinT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BinT as text
%        str2double(get(hObject,'String')) returns contents of edit_BinT as a double


% --- Executes during object creation, after setting all properties.
function edit_BinT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_BinT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_autoBin.
function checkbox_autoBin_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_autoBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_autoBin



function edit_RoiT_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RoiT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RoiT as text
%        str2double(get(hObject,'String')) returns contents of edit_RoiT as a double


% --- Executes during object creation, after setting all properties.
function edit_RoiT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RoiT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_CharT_Callback(hObject, eventdata, handles)
% hObject    handle to edit_CharT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_CharT as text
%        str2double(get(hObject,'String')) returns contents of edit_CharT as a double


% --- Executes during object creation, after setting all properties.
function edit_CharT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_CharT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Panika.
function pushbutton_Panika_Callback(hObject, eventdata, handles)
clear all;
close all;
clc;
% hObject    handle to pushbutton_Panika (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_ROI.
function pushbutton_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img imgLoaded
if imgLoaded == 1
    [ROIy,ROIx] = ginput(2);

    if ROIx(1) == ROIx(2) || ROIy(1) == ROIy(2)
        msgbox("Invalid input, ROI too small!")
    else
        try
            if ROIx(1)>ROIx(2) %Correct orientation
                ROIx(3) = ROIx(1);
                ROIx(1) = ROIx(2);
                ROIx(2) = ROIx(3);
            end
            if ROIy(1)>ROIy(2)
                ROIy(3) = ROIy(1);
                ROIy(1) = ROIy(2);
                ROIy(2) = ROIy(3);
            end
                imgp = img(ROIx(1):ROIx(2), ROIy(1):ROIy(2), :);
                axes(handles.axes_Preview);
                imshow(imgp);
                if questdlg("Apply trim?") == "Yes"
                    img = imgp;
                end
                imshow(img);
        catch e
                msgbox("Invalid input! Input must contain two points from the preview image! Stack trace: " + newline + e.message);
        end
    end
else
    msgbox("No image loaded! Load the image first!");
end


function edit_UndesirableT_Callback(hObject, eventdata, handles)
% hObject    handle to edit_UndesirableT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_UndesirableT as text
%        str2double(get(hObject,'String')) returns contents of edit_UndesirableT as a double


% --- Executes during object creation, after setting all properties.
function edit_UndesirableT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_UndesirableT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
