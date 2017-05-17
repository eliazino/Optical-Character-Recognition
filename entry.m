function varargout = entry(varargin)
% ENTRY MATLAB code for entry.fig
%      ENTRY, by itself, creates a new ENTRY or raises the existing
%      singleton*.
%
%      H = ENTRY returns the handle to a new ENTRY or the handle to
%      the existing singleton*.
%
%      ENTRY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENTRY.M with the given input arguments.
%
%      ENTRY('Property','Value',...) creates a new ENTRY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before entry_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to entry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help entry

% Last Modified by GUIDE v2.5 30-Jan-2016 04:04:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @entry_OpeningFcn, ...
                   'gui_OutputFcn',  @entry_OutputFcn, ...
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


% --- Executes just before entry is made visible.
function entry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to entry (see VARARGIN)

% Choose default command line output for entry
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global activity;
activity = 0;
global imagetype;
imagetype = 0;
global image;
image = 0;
global word;
word = '';

% UIWAIT makes entry wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = entry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global activity;
global image;
[fn, pn] = uigetfile('*.jpg; *.png;', 'Please select an image');
imna = [pn, fn];
if isequal(imna,0) || isempty(imna) || ~ischar(imna)
    msgbox('Operation was cancelled by user! This usually is the consequence of pressing the cancel key on the dialogue, you can try that again','Import canceled','Error','modal');
    if(activity == 0)
        set(handles.edit2, 'string','Process aborted...');
        activity = activity + 1;
    else
        %str = get(handles.edit1,'string');
        nstr = 'Process aborted...';
         set(handles.edit2, 'string',nstr);
    end
else
    if(activity == 0)
        set(handles.edit2, 'string',['Image loaded from ', imna, ' LOCFI']);
        activity = activity + 1;
    else
        %str = get(handles.edit1,'string');
        nstr = ['Image loaded from ', imna, ' LOCFI'];
         set(handles.edit2, 'string',nstr);
    end
    axes(handles.axes1);
    imshow(imna);
    image = imread(imna);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global image;
global word;
if isequal (image,0)
    msgbox('The Image might not have been loaded, the image is either absent or not readable','ImageError','Error','Modal');
else
   %warning off %#ok<WNOFF>
imagen=image;
% Show image
% Convert to gray scale
if size(imagen,3)==3 %RGB image
    imagen=rgb2gray(imagen);
end
% Convert to BW
threshold = graythresh(imagen);
imagen =~im2bw(imagen,threshold);
% Remove all object containing fewer than 30 pixels
imagen = bwareaopen(imagen,30);
%Storage matrix word from image
word=[ ];
re=imagen;
%Opens text.txt as file for write
% Load templates
load templates
global templates
% Compute the number of letters in template file
num_letras=size(templates,2);
while 1
    %Fcn 'lines' separate lines in text
    [fl re]=lines(re);
    imgn=fl;
    %Uncomment line below to see lines one by one
    %imshow(fl);pause(0.5)    
    %-----------------------------------------------------------------     
    % Label and count connected components
    [L Ne] = bwlabel(imgn);    
    for n=1:Ne
        [r,c] = find(L==n);
        % Extract letter
        n1=imgn(min(r):max(r),min(c):max(c));  
        % Resize letter (same size of template)
        img_r=imresize(n1,[42 24]);
        %Uncomment line below to see letters one by one
         %imshow(img_r);pause(0.5)
        %-------------------------------------------------------------------
        % Call fcn to convert image to text
        letter=read_letter(img_r,num_letras);
        % Letter concatenation
        word=[word letter];
        set(handles.text2,'string',word);
    end
    %fprintf(fid,'%s\n',lower(word));%Write 'word' in text file (lower)
    %Write 'word' in text file (upper)
    % Clear 'word' variable
   % word=[ ];
    %*When the sentences finish, breaks the loop
    if isempty(re)  %See variable 're' in Fcn 'lines'
        break
    end
end
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global word;
if(isempty(word))
    msgbox('Nothing to write, the image might not have been decoded, Please try again','EmptyClip Error','Error','Modal');
else
   fid = fopen('text.txt', 'wt');
fprintf(fid,'%s\n',word);
fclose(fid);
%Open 'text.txt' file
winopen('text.txt')
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
