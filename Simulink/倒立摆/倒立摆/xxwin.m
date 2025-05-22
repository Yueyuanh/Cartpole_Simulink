function [sys,x0,str,ts] = xxwin(t,x,u,flag,RefBlock)
%xxwin S-function for making pendulum animation.
%
%   See also: PENDDEMO.

%   Copyright (c) 1990-1998 by The MathWorks, Inc. All Rights Reserved.
%   $Revision: 1.15 $

% Plots every major integration step, but has no states of its own
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(RefBlock);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%%%%%%
  % Unused flags %
  %%%%%%%%%%%%%%%%
  case { 1, 3, 4, 9 },
    sys = [];
    
  %%%%%%%%%%%%%%%
  % DeleteBlock %
  %%%%%%%%%%%%%%%
  case 'DeleteBlock',
    LocalDeleteBlock
    
  %%%%%%%%%%%%%%%
  % DeleteFigure %
  %%%%%%%%%%%%%%%
  case 'DeleteFigure',
    LocalDeleteFigure
  
  %%%%%%%%%%
  % Slider %
  %%%%%%%%%%
  case 'Slider',
    LocalSlider
  
  %%%%%%%%%%%%%%
  % Signal Gen %
  %%%%%%%%%%%%%%
  case 'Signal'
   LocalSignal
  
  %%%%%%%%%
  % Close %
  %%%%%%%%%
  case 'Close',
    LocalClose
  
  %%%%%%%%%%%%
  % Playback %
  %%%%%%%%%%%%
  case 'Playback',
    LocalPlayback
   
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end

% end xxwin

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(RefBlock)

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 3;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times, for the pendulum demo,
% the animation is updated every 0.1 seconds
%
ts  = [-1 0];

%
% create the figure, if necessary
%
LocalPendInit(RefBlock);

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Update the pendulum animation.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

fig = get_param(gcbh,'UserData');
if ishandle(fig),
  if strcmp(get(fig,'Visible'),'on'),
    ud = get(fig,'UserData');
    LocalPendSets(t,ud,u);
  end
end;
 
sys = [];

% end mdlUpdate

%
%=============================================================================
% LocalDeleteBlock
% The animation block is being deleted, delete the associated figure.
%=============================================================================
%
function LocalDeleteBlock

fig = get_param(gcbh,'UserData');
if ishandle(fig),
  delete(fig);
  set_param(gcbh,'UserData',-1)
end

% end LocalDeleteBlock

%
%=============================================================================
% LocalDeleteFigure
% The animation figure is being deleted, set the S-function UserData to -1.
%=============================================================================
%
function LocalDeleteFigure

ud = get(gcbf,'UserData');
set_param(ud.Block,'UserData',-1);
  
% end LocalDeleteFigure

%
%=============================================================================
% LocalSlider
% The callback function for the animation window slider uicontrol.  Change
% the reference block's value.
%=============================================================================
%
function LocalSlider

ud = get(gcbf,'UserData');
set_param(ud.RefBlock,'Value',num2str(get(gcbo,'Value')));

% end LocalSlider

%
%=============================================================================
%
%
%=============================================================================
%
function LocalSignal
ud=get(gcbf,'UserData');
%set_param(ud.,'Value',get(gcbo,'Value'));
%end LocalSignal

%
%=============================================================================
% LocalClose
% The callback function for the animation window close button.  Delete
% the animation figure window.
%=============================================================================
%
function LocalClose

delete(gcbf)

% end LocalClose

%
%=============================================================================
% LocalPlayback
% The callback function for the animation window playback button.  Playback
% the animation.
%=============================================================================
%
function LocalPlayback

%
% first find the animation data in the base workspace, issue an error
% if the information isn't there
%
t = evalin('base','t','[]');
y = evalin('base','y','[]');

if isempty(t) | isempty(y),
  errordlg(...
    ['You must first run the simulation before '...
     'playing back the animation.'],...
    'Animation Playback Error');
end

%
% playback the animation, note that the playback is wrapped in a try-catch
% because is it is possible for the figure and it's children to be deleted
% during the drawnow in LocalPendSets
%
try
  ud = get(gcbf,'UserData');
  for i=1:length(t),
    LocalPendSets(t(i),ud,y(i,:));
  end
end

% end LocalPlayback

%
%=============================================================================
% LocalPendSets
% Local function to set the position of the graphics objects in the
% inverted pendulum animation window.
%=============================================================================
%
function LocalPendSets(time,ud,u)
pend1_l  = 5;
%pend2_l  = 5;
XDelta   = 2;                      %Width of the Cart
PDelta   = 0.2;                    %Width of the pend 
%Theta2   = u(4);

XPend1Top = u(2) + pend1_l*sin(u(3));
YPend1Top = pend1_l*cos(u(3));
PDcosT1   = PDelta*cos(u(3));
PDsinT1   = -PDelta*sin(u(3));

%XPend2Top  = XPend1Top + pend2_l*sin(Theta2); % Will be zero
%YPend2Top  = YPend1Top+pend2_l*cos(Theta2);         % Will be 10
%PDcosT2    = PDelta*cos(Theta2);     % Will be 0.2
%PDsinT2    = -PDelta*sin(Theta2);    % Will be zero


set(ud.Cart,...
  'XData',ones(2,1)*[u(2)-XDelta u(2)+XDelta]);
set(ud.Pend1,...
  'XData',[XPend1Top-PDcosT1 XPend1Top+PDcosT1; u(2)-PDcosT1 u(2)+PDcosT1], ...
  'YData',[YPend1Top-PDsinT1 YPend1Top+PDsinT1; -PDsinT1 PDsinT1]);
%set(ud.Pend2,...
 % 'XData',[XPend2Top-PDcosT2 XPend2Top+PDcosT2; XPend1Top-PDcosT2 XPend1Top+PDcosT2], ...
 % 'YData',[YPend2Top-PDsinT2 YPend2Top+PDsinT2; YPend1Top-PDsinT2 YPend1Top+PDsinT2]);
set(ud.TimeField,...
  'String',num2str(time));
set(ud.RefMark,...
  'XData',u(1)+[-XDelta 0 XDelta]);

set(ud.XcartField,...
   'String',num2str(u(2)));
set(ud.RefMarkField,...
   'String',num2str(u(1)));


% Force plot to be drawn
pause(0)
drawnow

% end LocalPendSets

%
%=============================================================================
% LocalPendInit
% Local function to initialize the pendulum animation.  If the animation
% window already exists, it is brought to the front.  Otherwise, a new
% figure window is created.
%=============================================================================
%
function LocalPendInit(RefBlock)
%
% The name of the reference is derived from the name of the
% subsystem block that owns the pendulum animation S-function block.
% This subsystem is the current system and is assumed to be the same
% layer at which the reference block resides.
%
pend1_l=5;
%pend2_l=5;
sys = get_param(gcs,'Parent');

TimeClock = 0;
RefSignal = str2num(get_param([sys '/' RefBlock],'Value'));
XCart     = 0;
Theta     = 0;
Theta2    = 0;

XDelta    = 2;
PDelta    = 0.2;
XPend1Top  = XCart + pend1_l*sin(Theta); % Will be zero
YPend1Top  = pend1_l*cos(Theta);         % Will be 10
PDcosT1    = PDelta*cos(Theta);     % Will be 0.2
PDsinT1    = -PDelta*sin(Theta);    % Will be zero

%XPend2Top  = XPend1Top + pend2_l*sin(Theta2); % Will be zero
%YPend2Top  = YPend1Top+pend2_l*cos(Theta2);         % Will be 10
%PDcosT2    = PDelta*cos(Theta2);     % Will be 0.2
%PDsinT2    = -PDelta*sin(Theta2);    % Will be zero


%
% The animation figure handle is stored in the pendulum block's UserData.
% If it exists, initialize the reference mark, time, cart, and pendulum
% positions/strings/etc.
%
Fig = get_param(gcbh,'UserData');
if ishandle(Fig),
  FigUD = get(Fig,'UserData');
  set(FigUD.RefMark,...
      'XData',RefSignal+[-XDelta 0 XDelta]);
  set(FigUD.TimeField,...
      'String',num2str(TimeClock));
  set(FigUD.Cart,...
      'XData',ones(2,1)*[XCart-XDelta XCart+XDelta]);
  set(FigUD.Pend1,...
      'XData',[XPend1Top-PDcosT1 XPend1Top+PDcosT1; XCart-PDcosT1 XCart+PDcosT1],...
      'YData',[YPend1Top-PDsinT1 YPend1Top+PDsinT1; -PDsinT1 PDsinT1]);
  %set(FigUD.Pend2,...
  %    'XData',[XPend2Top-PDcosT2 XPend2Top+PDcosT2; XPend1Top-PDcosT2 XPend1Top+PDcosT2],...
 %     'YData',[YPend2Top-PDsinT2 YPend2Top+PDsinT2; YPend1Top-PDsinT2 YPend1Top+PDsinT2]);
  set(FigUD.XcartField,...
     'String',num2str(XCart));
  

  set(FigUD.RefMarkField,...
     'String',num2str(RefSignal));

   
  %
  % bring it to the front
  %
  figure(Fig);
  return
end

%
% the animation figure doesn't exist, create a new one and store its
% handle in the animation block's UserData
%
FigureName = '深圳元创兴科技有限公司';

Fig = figure(...
  'Units',           'pixel',...
  'Position',        [100 50 500 530],...
  'Name',            FigureName,...
  'NumberTitle',     'off',...
  'IntegerHandle',   'off',...
  'HandleVisibility','callback',...
  'Resize',          'off',...
  'DeleteFcn',       'xxwin([],[],[],''DeleteFigure'')',...
  'CloseRequestFcn', 'xxwin([],[],[],''Close'');');
uicontrol(...
   'Parent', Fig,...
   'style', 'text',...
   'units', 'norm',...
   'pos',   [0.1 0.9 0.8 0.1],...
   'string','一级倒立摆摆起控制演示系统',...
   'FontSize',20,...
   'ForegroundColor',[1 0 0]);
AxesH = axes(...
  'Parent',  Fig,...
  'Units',   'pixel',...
  'Position',[50 110 400 250],...
  'CLim',    [1 64], ...
  'Xlim',    [-12 12],...
  'Ylim',    [-10 10],...
  'Color', [0 0 0],...
  'Project','perspective',...
  'Visible', 'on');
Cart = surface(...
  'Parent',   AxesH,...
  'XData',    ones(2,1)*[XCart-XDelta XCart+XDelta],...
  'YData',    [0 0; -2 -2],...
  'ZData',    zeros(2),...
  'CData',    ones(2),...
  'EraseMode','xor');
Pend1= surface(...
  'Parent',   AxesH,...
  'XData',    [XPend1Top-PDcosT1 XPend1Top+PDcosT1; XCart-PDcosT1 XCart+PDcosT1],...
  'YData',    [YPend1Top-PDsinT1 YPend1Top+PDsinT1; -PDsinT1 PDsinT1],...
  'ZData',    zeros(2),...
  'CData',    11*ones(2),...
  'FaceColor',[1 0 0],...
  'EraseMode','xor');
%Pend2= surface(...
%  'Parent',   AxesH,...
 % 'XData',    [XPend2Top-PDcosT2 XPend2Top+PDcosT2; XPend1Top-PDcosT2 XPend1Top+PDcosT2],...
%  'YData',    [YPend2Top-PDsinT2 YPend2Top+PDsinT2; YPend1Top-PDsinT2 YPend1Top+PDsinT2],...
 % 'ZData',    zeros(2),...
 % 'CData',    11*ones(2),...
 % 'FaceColor',[0 0 1],...
 % 'EraseMode','xor');

 RefMark = patch(...
   'Parent',   AxesH,...
   'XData',    RefSignal+[-XDelta 0 XDelta],...
   'YData',    [-2 0 -2],...
   'FaceColor',[0 1 0],...
   'CData',    22);
 patch(...
   'Parent',   AxesH,...
   'XData',    [-10 -10 10 10],...
   'YData',    [-2.5 -2 -2 -2.5],...
   'FaceColor',[1 0.62 0.40],...
   'CData',    22,...
   'DiffuseStrength',0.5,...
   'SpecularStrength',1);

uicontrol(...
  'Parent',  Fig,...
  'Style',   'text',...
  'Units',   'pixel',...
  'Position',[0 0 500 110]);
uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel',...
  'Position',           [280 30 100 25], ...
  'HorizontalAlignment','right',...
  'String',             '仿真时间(秒): ');
TimeField = uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel', ...
  'Position',           [280 20 100 20],...
  'HorizontalAlignment','right',...
  'String',             num2str(TimeClock));
SlideControl = uicontrol(...
  'Parent',   Fig,...
  'Style',    'slider',...
  'Units',    'pixel', ...
  'Position', [100 80 300 22],...
  'Min',      -7,...
  'Max',      7,...
  'Value',    RefSignal,...
  'Callback', 'xxwin([],[],[],''Slider'');');
uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel',...
  'Position',           [220 30 80 25], ...
  'HorizontalAlignment','left',...
  'String',             '小车位移(米): ');
XcartField=uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel', ...
  'Position',           [220 20 50 20],...
  'HorizontalAlignment','right',...
  'String',             num2str(XCart));

uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel',...
  'Position',           [120 30 80 25], ...
  'HorizontalAlignment','left',...
  'String',             '三角块位置(米):');
RefMarkField=uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel', ...
  'Position',           [120 20 80 20],...
  'HorizontalAlignment','center',...
  'String',             num2str(RefSignal));


uicontrol(...
  'Parent',  Fig,...
  'Style',   'pushbutton',...
  'Position',[415 15 70 20],...
  'String',  '退  出', ...
  'FontSize', 12,...
 'Callback','xxwin([],[],[],''Close'');');
uicontrol(...
  'Parent',  Fig,...
  'Style',   'pushbutton',...
  'Position',[15 15 70 20],...
  'String',  '回放', ...
  'FontSize', 12,...
  'Callback','xxwin([],[],[],''Playback'');',...
  'Interruptible','off',...
  'BusyAction','cancel');
set(RefMark,'EraseMode','xor');

%
% all the HG objects are created, store them into the Figure's UserData
%
FigUD.Cart         = Cart;
FigUD.Pend1        = Pend1;
%FigUD.Pend2        = Pend2; 
FigUD.TimeField    = TimeField;
FigUD.SlideControl = SlideControl;
FigUD.RefMark      = RefMark;
FigUD.Block        = get_param(gcbh,'Handle');
FigUD.RefBlock     = get_param([sys '/' RefBlock],'Handle');

FigUD.XcartField    = XcartField;
FigUD.RefMarkField    = RefMarkField;



set(Fig,'UserData',FigUD);

drawnow

%
% store the figure handle in the animation block's UserData
%
set_param(gcbh,'UserData',Fig);

% end LocalPendInit
