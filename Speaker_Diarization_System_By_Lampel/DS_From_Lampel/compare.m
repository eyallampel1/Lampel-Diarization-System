function compare(varargin)

fig=openfig('compare.fig');
project=guihandles(fig);
movegui(fig,'center');
Listt=findobj('tag','List');
UserSelected=get(Listt,'value');
path=varargin{3}.path;
try
    [x,y,z]=fileparts(varargin{3}.FileName);
catch
[x,y,z]=fileparts(varargin{3}.FileName{UserSelected});
end
y=[y,'.txt'];


SystemResultsPath=fullfile(get(varargin{3}.SystemParametersEditText23,'string'),y);
ManualResultsPath=fullfile(cd,...
    'LDC_Callhome','Segmentations',y);

SystemResultsFile=fopen(SystemResultsPath,'r');
ManualResultsFile=fopen(ManualResultsPath,'r');
SystemScannedFile=textscan(SystemResultsFile,'%s %s %s',[3,1]);
SystemScannedFile=[SystemScannedFile{1},...
    SystemScannedFile{2},...
    SystemScannedFile{3}];
ManualScannedFile=textscan(ManualResultsFile,'%s %s %s',[3,1]);
ManualScannedFile=[ManualScannedFile{1},...
    ManualScannedFile{2},...
    ManualScannedFile{3}];
Rows=round(length(SystemScannedFile));
Rows2=round(length(ManualScannedFile));
Rows=max(Rows,Rows2);


set(project.Slider,'max',Rows,'sliderstep',[1/Rows,10/Rows],...
    'value',Rows);
set(project.Next_Segment_push,'callback',{@Next,project,1});
set(project.Previous_Segment_push,'callback',{@Prev,project,1});
set(project.Slider,'callback',{@Slider,project});

CurrentHighLightedRow=1;
index=0;

for k=1:2
    for i=1:10
        for j=1:3
            index=index+1;
            if k==1
                project.text{index}=uicontrol('units','normalized',...
                    'parent',project.uipanel,'style','text',...
                    'position',[0.017+0.165*(j-1),0.86-0.0935*(i-1),0.1153,0.0514],'string',...
                    ManualScannedFile(i,j),...
                    'backgroundcolor','w','fontsize',13,...
                    'buttondownfcn',{@KeyPress},'value',i);
            else
                project.text{index}=uicontrol('units','normalized',...
                    'parent',project.uipanel,'style','text',...
                    'position',[0.537+0.165*(j-1),0.86-0.0935*(i-1),0.1153,0.0514],'string',...
                    SystemScannedFile(i,j),...
                    'backgroundcolor','w','fontsize',13,...
                    'buttondownfcn',{@KeyPress},'value',i);
            end
        end
    end
end
Slider

    function Next(varargin)
        switch varargin{4}
            case 1
                project.Index=1;
            otherwise
                project.Index=varargin{4};
        end
        
        for i=1:60
            try
                set(project.text{i},'backgroundcolor','w');
            catch
            end
        end
        if project.Index==31
            project.Index=1;
        end
        try
            set(project.text{project.Index},'backgroundcolor','r');
            set(project.text{project.Index+1},'backgroundcolor','r');
            set(project.text{project.Index+2},'backgroundcolor','r');
        catch
        end
        try
            set(project.text{project.Index+30},'backgroundcolor','r');
            set(project.text{project.Index+31},'backgroundcolor','r');
            set(project.text{project.Index+32},'backgroundcolor','r');
        catch
        end
        project.Index=project.Index+3;
        set(project.Next_Segment_push,'callback',{@Next,project,project.Index});
        set(project.Previous_Segment_push,'callback',{@Prev,project,project.Index-6});
        
    end



    function Prev(varargin)
        
        project.Index=varargin{4};
        if varargin{4}==1
            
            project.Index=1;
            
        end
        
        for i=1:60
            try
                set(project.text{i},'backgroundcolor','w');
            catch
            end
        end
        if project.Index==-2
            project.Index=28;
        end
        try
            set(project.text{project.Index},'backgroundcolor','r');
            set(project.text{project.Index+1},'backgroundcolor','r');
            set(project.text{project.Index+2},'backgroundcolor','r');
        catch
        end
        try
            set(project.text{project.Index+30},'backgroundcolor','r');
            set(project.text{project.Index+31},'backgroundcolor','r');
            set(project.text{project.Index+32},'backgroundcolor','r');
        catch
        end
        project.Index=project.Index-3;
        set(project.Next_Segment_push,'callback',{@Next,project,project.Index+6});
        set(project.Previous_Segment_push,'callback',{@Prev,project,project.Index});
    end

    function Slider(varargin)
        
        UserPressedManual=get(project.ManualSlider,'value');
        UserPressedSystem=get(project.SystemSlider,'value');
        UserPressedBoth=get(project.BothSlider,'value');
        if UserPressedBoth==1
            
            set(project.Next_Segment_push,'callback',{@Next,project,1});
            set(project.Previous_Segment_push,'callback',{@Prev,project,1});
            
            
            for i=1:60
                try
                    delete(project.text{i});
                catch
                end
            end
            
            SliderValue=round(get(project.Slider,'value'));
            index=0;
            
            for k=1:2
                for i=1:10
                    for j=1:3
                        index=index+1;
                        if k==1
                            try
                                project.text{index}=uicontrol('units','normalized',...
                                    'parent',project.uipanel,'style','text',...
                                    'position',[0.017+0.165*(j-1),0.86-0.0935*(i-1),0.1153,0.0514],'string',...
                                    ManualScannedFile(Rows-SliderValue+i,j),...
                                    'backgroundcolor','w','fontsize',13,...
                                    'buttondownfcn',{@KeyPress},'value',i);
                            catch
                            end
                        else
                            try
                                project.text{index}=uicontrol('units','normalized',...
                                    'parent',project.uipanel,'style','text',...
                                    'position',[0.537+0.165*(j-1),0.86-0.0935*(i-1),0.1153,0.0514],'string',...
                                    SystemScannedFile(Rows-SliderValue+i,j),...
                                    'backgroundcolor','w','fontsize',13,...
                                    'buttondownfcn',{@KeyPress},'value',i);
                            catch
                            end
                        end
                    end
                end
            end
        else if UserPressedManual==1
                for i=1:30
                    try
                        delete(project.text{i});
                    catch
                    end
                end
                SliderValue=round(get(project.Slider,'value'));
                index=0;
                
                
                for i=1:10
                    for j=1:3
                        index=index+1;
                        try
                            project.text{index}=uicontrol('units','normalized',...
                                'parent',project.uipanel,'style','text',...
                                'position',[0.017+0.165*(j-1),0.86-0.0935*(i-1),0.1153,0.0514],'string',...
                                ManualScannedFile(Rows-SliderValue+i,j),...
                                'backgroundcolor','w','fontsize',13,...
                                'buttondownfcn',{@KeyPress},'value',i);
                        catch
                        end
                    end
                end
                
            else
                for i=31:60
                    try
                        delete(project.text{i});
                    catch
                    end
                end
                SliderValue=round(get(project.Slider,'value'));
                index=30;
                for i=1:10
                    for j=1:3
                        index=index+1;
                        try
                            project.text{index}=uicontrol('units','normalized',...
                                'parent',project.uipanel,'style','text',...
                                'position',[0.537+0.165*(j-1),0.86-0.0935*(i-1),0.1153,0.0514],'string',...
                                SystemScannedFile(Rows-SliderValue+i,j),...
                                'backgroundcolor','w','fontsize',13,...
                                'buttondownfcn',{@KeyPress},'value',i);
                        catch
                        end
                    end
                end
            end
        end
        
        
        function KeyPress(varargin)
            for i=1:60
                try
                    set(project.text{i},'backgroundcolor','w');
                catch
                end
            end
            
            h=gco;
            PressedNumber=get(h,'value');
            try
                set(project.text{PressedNumber*3-2},'backgroundcolor','r');
                set(project.text{PressedNumber*3-1},'backgroundcolor','r');
                set(project.text{PressedNumber*3},'backgroundcolor','r');
            catch
            end
            try
                set(project.text{PressedNumber*3+28},'backgroundcolor','r');
                set(project.text{PressedNumber*3+29},'backgroundcolor','r');
                set(project.text{PressedNumber*3+30},'backgroundcolor','r');
            catch
            end
            
            
            set(project.Next_Segment_push,'callback',{@Next,project,PressedNumber*3+1});
            set(project.Previous_Segment_push,'callback',{@Prev,project,PressedNumber*3-5});
            
            
        end
    end
end
