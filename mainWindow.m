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

% Last Modified by GUIDE v2.5 15-May-2021 21:46:24

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


% --- Executes on button press in pushbutton_Filter.
function pushbutton_Filter_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Filter (see GCBO)
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
% --- Executes on button press in pushbutton_Start.
function pushbutton_Start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in uibuttongroup_Modification.
function uibuttongroup_Modification_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_Modification 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
