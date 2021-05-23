function varargout = mainWindow(varargin)
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

% Last Modified by GUIDE v2.5 22-May-2021 23:18:55

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

set(handles.radiobutton_Sharpen, 'Value', 1);

% UIWAIT makes mainWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mainWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_Browse.
function pushbutton_Browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img
try
    [fileName, folderPath] = uigetfile('*.jpg')
    fullPath = append(folderPath, fileName);
    img = imread(fullPath);
    axes(handles.axes_Preview);
    img = im2gray(img);
    imshow(img);
catch
    msgbox("No image loaded!");
end


% --- Executes on button press in pushbutton_Apply.
function pushbutton_Apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img
if get(handles.radiobutton_Sharpen, 'Value') == 1
    try
    imgp = imsharpen(img);
    axes(handles.axes_Preview);
    imshowpair(img, imgp);
    if questdlg("Apply results?") == "Yes"
        img = imgp;
    end
    imshow(img);
   catch
       msgbox("Error applying filter!");
   end 
else %Apply median filter
   try
    imgp = medfilt2(img);
    axes(handles.axes_Preview);
    imshowpair(img, imgp);
    if questdlg("Apply results?") == "Yes"
        img = imgp;
    end
    imshow(img);
   catch
       msgbox("Error applying filter!");
   end 
end
% --- Executes on button press in pushbutton_Read.
function pushbutton_Read_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Read (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in uibuttongroup_Modification.
function uibuttongroup_Modification_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_Modification 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'tag') 
    case 'radiobutton_Sharpen'   
        set(handles.edit_Passes, 'string', 1);
        set(handles.edit_Param1, 'string', 1);
        set(handles.edit_Param1,'visible','on');
        set(handles.text_Param1, 'string', "Radius");
        set(handles.text_Param1,'visible','on');
        set(handles.edit_Param2, 'string', 0.8)
        set(handles.edit_Param2,'visible','on');
        set(handles.text_Param2,'string',"Amount");
        set(handles.text_Param2,'visible','on');
        set(handles.edit_Param3,'string',1);
        set(handles.edit_Param3,'visible','on');
        set(handles.text_Param3,'string', "Threshold");
        set(handles.text_Param3,'visible','on');
    case 'radiobutton_Median'     
        set(handles.edit_Passes, 'string', 1)
        set(handles.edit_Param1, 'string', 3);
        set(handles.edit_Param1,'visible','on');
        set(handles.text_Param1,'string', "Mask width");
        set(handles.text_Param1,'visible','on');
        set(handles.edit_Param2, 'string', 3);
        set(handles.edit_Param2,'visible','on');
        set(handles.text_Param2,'string', "Mask height");
        set(handles.text_Param2,'visible','on');
        set(handles.edit_Param3,'visible','off');
        set(handles.text_Param3,'visible','off');
   case 'radiobutton_Wiener'    
        set(handles.edit_Passes, 'string', 1)
        set(handles.edit_Param1, 'string', 3);
        set(handles.edit_Param1,'visible','on');
        set(handles.text_Param1,'string', "Mask width");
        set(handles.text_Param1,'visible','on');
        set(handles.edit_Param2, 'string', 3);
        set(handles.edit_Param2,'visible','on');
        set(handles.text_Param2,'string', "Mask height");
        set(handles.text_Param2,'visible','on');
        set(handles.edit_Param3,'visible','off');
        set(handles.text_Param3,'visible','off');
    case 'radiobutton_Contrast'
        set(handles.edit_Passes, 'string', 1)
        set(handles.edit_Param1, 'string', 0);
        set(handles.edit_Param1,'visible','on');
        set(handles.text_Param1,'string', "Threshold");
        set(handles.text_Param1,'visible','on');
        set(handles.edit_Param1, 'string', 255);
        set(handles.edit_Param2,'visible','on');
        set(handles.text_Param2,'string', "Upper boundary");
        set(handles.text_Param2,'visible','on');
        set(handles.edit_Param3,'string', 256);
        set(handles.edit_Param3,'visible','on');
        set(handles.text_Param3, 'string', "Resolution")
        set(handles.text_Param3,'visible','on');
    case 'radiobutton_Gaussian'
        set(handles.edit_Passes, 'string', 1)
        set(handles.edit_Param1, 'string', 3);
        set(handles.edit_Param1,'visible','on');
        set(handles.text_Param1,'string', "Mask width");
        set(handles.text_Param1,'visible','on');
        set(handles.edit_Param2, 'string', 3);
        set(handles.edit_Param2,'visible','on');
        set(handles.text_Param2,'string', "Mask height");
        set(handles.text_Param2,'visible','on');
        set(handles.edit_Param3,'visible','off');
        set(handles.text_Param3,'visible','off');
    otherwise %Salt and pepper noise selected
        set(handles.edit_Passes, 'string', 1)
        set(handles.edit_Param1,'visible','on');
        set(handles.text_Param1,'string', "Mask width");
        set(handles.text_Param1,'visible','on');
        set(handles.edit_Param2,'visible','on');
        set(handles.text_Param2,'string', "Mask height");
        set(handles.text_Param2,'visible','on');
        set(handles.edit_Param3,'visible','off');
        set(handles.text_Param3,'visible','off');
            
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


% --- Executes on button press in pushbutton_Prev.
function pushbutton_Prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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
