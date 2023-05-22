%% cleanup of simscape model
load_system("full_Model.slx");
load('EnvironmentData.mat')
try
    find_system(transferNames(1));
    for i=1:length(objx)
            delete_line('full_Model/Sensors',startPos);
            delete_line('full_Model/Sensors',transConnectNames(i),blockConnectNames(i))
            delete_block(transferNames(i));
            delete_block(blockNames(i));
    end
catch
end

%% Run GUI

GUI
uiwait

load('userMap.mat')

[starty,startx]=find(userMap==1);
[endy,endx]=find(userMap==2);
[objy,objx]=find(userMap==3);
[bally,ballx]=find(userMap==4);

objPos=[objx,objy];
ballPos=[ballx,bally,0.54];
boxPos=[];
%load_system("quad_new_leg_raibert_strategy_v2");
%load_system('simscape');
subsys_handle = get_param('full_Model/Sensors', 'Handle');
%solverConfigPath=find_system('NavigationGUI/Sensors');
lineStart= get_param('full_Model/Sensors/Ground Transform','PortConnectivity');
startPos=lineStart.Position;
startPos=[startPos(1)-25,startPos(2)-2];
blockNames=strings;
transferNames=strings;
transConnectNames=strings;
blockConnectNames=strings;

%% Creation of environment from GUI data
for i=1:length(objx)
    centrex=objx(i)-0.5;
    centrey=objy(i)-0.5;
    translation=simscape.Value([centrex centrey 1],'m');
    body='obstacle'+string(i);
    transform='['+string(centrex)+' '+string(centrey)+' 1]';
    transformName='transform'+string(i);
    tranfDest='full_Model/Sensors/'+transformName;
    destination='full_Model/Sensors/'+body;
    blockNames(i)=destination;
    transferNames(i)=tranfDest;
    blockConnectNames(i)=body+'/Rconn1';
    transConnectNames(i)=transformName+'/RConn1';
    add_block('sm_lib/Body Elements/Brick Solid',destination,'MakeNameUnique','on');
    add_block('sm_lib/Frames and Transforms/Rigid Transform',tranfDest,'MakeNameUnique','on');
    set_param(destination,'GraphicDiffuseColor','[1 0 0]');
    set_param(tranfDest,'TranslationMethod','Cartesian','TranslationCartesianOffset',transform);
    add_line('full_Model/Sensors',transformName+'/RConn1',body+'/Rconn1');
    lineEnd = get_param(tranfDest,'PortConnectivity');
    endPos=lineEnd.Position;
    linePos=[endPos;startPos];
    add_line('full_Model/Sensors',linePos);
end

courselayout=userMap;
courselayout(courselayout==1)=0;
courselayout(courselayout==2)=0;
courselayout(courselayout==3)=1;
courselayout(courselayout==4)=0;

courselayout=rot90(courselayout);
courselayout=rot90(courselayout);
courselayout=flip(courselayout,2);
map = binaryOccupancyMap(courselayout);
figure(1)

floorl=20;
floorw=20;

%% creation of pathfinding algorithm

% Set start and goal poses
start = [startx,starty,0];
goal = [ballx-0.6,bally,0];
%show(map)

% Show start and goal positions of robot.

figure(1)
show(map)
hold on
plot(start(1),start(2),'ro')
plot(goal(1),goal(2),'mo')

% Show start and goal headings.
r = 0.5;
plot([start(1),start(1) + r*cos(start(3))],[start(2),start(2) + r*sin(start(3))],'r-')
plot([goal(1),goal(1) + r*cos(goal(3))],[goal(2),goal(2) + r*sin(goal(3))],'m-')
hold off
inflate(map,1)

bounds = [map.XWorldLimits; map.YWorldLimits; [-pi pi]];

ss = stateSpaceDubins(bounds);
ss.MinTurningRadius = 0.4;

stateValidator = validatorOccupancyMap(ss); 
stateValidator.Map = map;
stateValidator.ValidationDistance = 0.05;

planner = plannerRRTStar(ss,stateValidator);
planner.MaxConnectionDistance = 2.0;
planner.MaxIterations = 30000;

planner.GoalReachedFcn = @exampleHelperCheckIfGoal;

rng default
%% pathfind to ball
[pthObj, solnInfo] = plan(planner,start,goal);

figure(2)
show(map)
hold on

% Plot entire search tree.
plot(solnInfo.TreeData(:,1),solnInfo.TreeData(:,2),'.-');

% Interpolate and plot path.
%interpolate(pthObj,300)
plot(pthObj.States(:,1),pthObj.States(:,2),'r-','LineWidth',2)

% Show start and goal in grid map.
plot(start(1),start(2),'ro')
plot(goal(1),goal(2),'mo')
hold off

%target=[transpose(linspace(1,30,300)),pthObj.States(:,1),pthObj.States(:,2)];
target1=[pthObj.States(:,1),pthObj.States(:,2)];
tar1Len=length(target1);

%% pathfind to end
start = [ballx-0.6,bally,0];
goal = [endx-0.6,endy,0];
[pthObj, solnInfo] = plan(planner,start,goal);

figure(3)
show(map)
hold on

% Plot entire search tree.
plot(solnInfo.TreeData(:,1),solnInfo.TreeData(:,2),'.-');

% Interpolate and plot path.
%interpolate(pthObj,300)
plot(pthObj.States(:,1),pthObj.States(:,2),'r-','LineWidth',2)

% Show start and goal in grid map.
plot(start(1),start(2),'ro')
plot(goal(1),goal(2),'mo')
hold off

%target=[transpose(linspace(1,30,300)),pthObj.States(:,1),pthObj.States(:,2)];
target2=[pthObj.States(:,1),pthObj.States(:,2)];
tar2Len=length(target2);
target=cat(1,target1,target2)
tarLen=length(target);


save('EnvironmentData','ballPos','ballx','bally','endPos','endx','endy',...
    'floorl','floorw','startPos','startx','starty','target','tar1Len','objx',...
    'transConnectNames','blockConnectNames','transferNames','blockNames','tarLen')
clear 
load('EnvironmentData');

save_system('full_Model');
sim('full_Model',400);
% smwritevideo('full_Model','movingBall','tile',4);
% pause(100);
% VideoPlayer




%% Display of video
% VideoPlayer

%% function for pathplanner
function isReached = exampleHelperCheckIfGoal(planner, goalState, newState)
    isReached = false;
    threshold = 0.1;
    if planner.StateSpace.distance(newState, goalState) < threshold
        isReached = true;
    end
end