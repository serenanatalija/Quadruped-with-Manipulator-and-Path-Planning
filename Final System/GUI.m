function toggleButtonGUI()

% Define the size of the button matrix
numRows = 20;
numCols = 20;

% Define the size of each button in the matrix
btnWidth = 30;
btnHeight = 30;

% Create a new figure for the GUI
fig = figure('Position',[300 75 numRows*btnHeight+50 numCols*btnWidth+200]);



% Create a nested loop to create the buttons and position them in the GUI
for row = 1:numRows
    for col = 1:numCols
        % Create a new toggle button
        btn(row,col) = uicontrol('Style','togglebutton',...
                                 'Position',[col*btnWidth row*btnHeight btnWidth btnHeight]);
        % Set the button callback to the toggleState function
        set(btn(row,col),'Callback',@(src,event) toggleState(src,event));
    end
end

% Create a panel for the radio buttons
panel = uipanel('Title','Options','Position',[0.2 0.8 0.25 0.2]);

rbtnGroup = uibuttongroup('Parent', panel, 'Position', [0 0 1 1]);

closeBtn= uicontrol("Style","pushbutton","String",'Finish','Position',[ 300 700 100 30]);
set(closeBtn,'Callback',@(src,event) closeUi(src,event));

% Create the radio buttons
rbtn1 = uicontrol('Style','radio',...
                  'String','Add Start Position',...
                  'Position',[10 120 100 20],...
                  'Parent',rbtnGroup);
set(rbtn1,'Callback',@(src,event) radioButton(src,event));

rbtn2 = uicontrol('Style','radio',...
                  'String','Add End Position',...
                  'Position',[10 100 100 20],...
                  'Parent',rbtnGroup);
set(rbtn2,'Callback',@(src,event) radioButton(src,event));

rbtn3 = uicontrol('Style','radio',...
                  'String','Add Obstacle',...
                  'Position',[10 80 100 20],...
                  'Parent',rbtnGroup);
set(rbtn3,'Callback',@(src,event) radioButton(src,event));

rbtn4 = uicontrol('Style','radio',...
                  'String','Add Ball Location',...
                  'Position',[10 60 100 20],...
                  'Parent',rbtnGroup);
set(rbtn4,'Callback',@(src,event) radioButton(src,event));

% Initialize the selected radio button to 1
selectedRBtn = 1;

userMap=zeros(numRows,numCols);
startPosSet=0;
endPosSet=0;
ballPosSet=0;

function radioButton(src,event)
    switch src
        case rbtn1
            selectedRBtn = 1;
        case rbtn2
            selectedRBtn = 2;
        case rbtn3
            selectedRBtn = 3;
        case rbtn4
            selectedRBtn = 4;
    end
end



function toggleState(src,event)
    % Determine the row and column of the button that was clicked
    idx = find(btn==src);
    [row,col] = ind2sub(size(btn),idx);
    % Toggle the state of the button

    if get(src,'Value') == get(src,'Max')
    % Button is pressed
        switch selectedRBtn
            %add start position
            case 1
                if startPosSet~=0
                   [startRow,startCol]=find(userMap==1);
                   userMap(startRow,startCol)=0;
                   set(btn(startRow,startCol),'BackgroundColor','default','Value',0)
                end
                startPosSet=1;
                set(src,'BackgroundColor','g'); % Set background color to green
                if userMap(row,col)==2
                    endPosSet=0;
                elseif userMap(row,col)==4
                    ballPosSet=0;
                end
                userMap(row,col)=1;
            %add end position
            case 2
                if endPosSet~=0
                   [startRow,startCol]=find(userMap==2);
                   userMap(startRow,startCol)=0;
                   set(btn(startRow,startCol),'BackgroundColor','default','Value',0)
                end
                endPosSet=1;
                if userMap(row,col)==1
                    startPosSet=0;
                elseif userMap(row,col)==4
                    ballPosSet=0;
                end
                userMap(row,col)=2;
                set(src,'BackgroundColor','r'); % Set background color to red
            %add object
            case 3
                set(src,'BackgroundColor','black'); % Set background color to black
                if userMap(row,col)==1
                    startPosSet=0;
                elseif userMap(row,col)==2
                        endPosSet=0;
                elseif userMap(row,col)==4
                    ballPosSet=0;
                end
                userMap(row,col)=3;
            %add ball location
            case 4
                if ballPosSet~=0
                   [startRow,startCol]=find(userMap==4);
                   userMap(startRow,startCol)=0;
                   set(btn(startRow,startCol),'BackgroundColor','default','Value',0)
                end
                ballPosSet=1;
                set(src,'BackgroundColor','blue'); %Set background color to orange
                if userMap(row,col)==1
                    startPosSet=0;
                elseif userMap(row,col)==2
                    endPosSet=0;
                end
                userMap(row,col)=4;
            otherwise
                set(src,'BackgroundColor','black'); % Set background color to black
                if userMap(row,col)==1
                    startPosSet=0;
                elseif userMap(row,col)==2
                        endPosSet=0;
                end
                userMap(row,col)=3;
        end

    else
    % Button is released
        set(src,'BackgroundColor','default','Value',0); % Reset background color
        if userMap(row,col)==1
             startPosSet=0;
        elseif userMap(row,col)==2
             endPosSet=0;
        end
        userMap(row,col)=0;
    end

  


end

function closeUi(src,event)
       filename='userMap.mat';
       save(filename,'userMap');
       close(fig)
    end
end
