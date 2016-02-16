
function [] = Eyal_Rotem_Final_Project
close all
clear all
clc


project.CurrentSegment=0;
project.TestIndex=1;
cd(fileparts(mfilename('fullpath')));
%%%path of SDS dirctory %%%
project.path=cd;
%add folder and subfolder recursively to matlab path %
addpath(genpath(cd));

project.MainWindow=figure('units','pixels','position',[561,269,270,401],...
                                                    'name','Speaker Diar System By Eyal Lampel & Rotem Levi',...
                                                    'color','w','menubar','none');

centerfig(project.MainWindow);                                                
                                                
project.NameOfProjectHeadLine=uicontrol('style','text','position',...
                                                                                                           [21,355,237,33],'string',...
                                                                          'Speaker Diar System','fontsize',15,...
                                                                  'fontweight','bold','backgroundcolor','w');


project.SystemParametersPushButton=uicontrol('style','pushbutton','string',...
                                                                                                'Edit System Parametrs','position',...
                                                                                                                            [70 240 133 37],...
                                                                                                                                                'enable','off');
                                                                                                                                            
%#function DerFunction                                                                                                                                            
 project.DerPushButton=uicontrol('style','pushbutton','string',...
                                                                  'Record Conversation','position',...
                                                                   [38,50,193,37],'fontweight','bold','callback',...
                                                            {@DerFunction,project},'enable','on');                                                                                                                                                
                                                                                                                                            

   project.StartButtonPanel=uibuttongroup('units','pixels',...
                        'shadowcolor','w','position',[15,110,233,100],'backgroundcolor','w')   ;                                                     
                                                        
%#function StartDiazFunction                                                        
                                                        
 project.StartDiazPushButton=uicontrol('style','pushbutton','string',...
                                                                  'Start Seperating Wave Files','position',...
                                                                   [20,50,193,37],'fontweight','bold','callback',...
                                                            {@StartDiazFunction,project},'enable','off',...
                                                            'parent',project.StartButtonPanel);          
                                                        
project.StartRadioButton=uicontrol('style','radio','string',...
                                                                  'On Demand','position',...
                                                                   [-15,10,85,37],'fontweight','bold','enable','off',...
                                                            'parent',project.StartButtonPanel,'backgroundcolor','w');  
                                                        
                                                        
project.StartRadioButton2=uicontrol('style','radio','string',...
                                                                  'Online','position',...
                                                                   [70,10,55,37],'fontweight','bold','enable','off',...
                                                            'parent',project.StartButtonPanel,'backgroundcolor','w');                                                        
                                                        
project.StartRadioButton3=uicontrol('style','radio','string',...
                                                                  'Incremental','position',...
                                                                   [126,10,85,37],'fontweight','bold','enable','off',...
                                                            'parent',project.StartButtonPanel,'backgroundcolor','w');    
                                                        
project.StartRadioButton4=uicontrol('style','radio','string',...
                                                                  'Full','position',...
                                                                   [213,10,40,37],'fontweight','bold','enable','off',...
                                                            'parent',project.StartButtonPanel,'backgroundcolor','w');    
                                                   
                                                        
%#function LoadFilesFunction                                                        
project.LoadFilesPushButton=uicontrol('style','pushbutton','string',...
                                                                          'Load wave Files for diar','position',...
                                         [70 301 133 37],'callback',{@LoadFilesFunction,project});
                                     
                                     
set( project.StartRadioButton4,'value',1);                                    
                                     
%#function SystemParametersFunction
set(project.SystemParametersPushButton,'callback',...
                                                                                    {@SystemParametersFunction,project})                                  
                                     
                                     
                                     
                    function LoadFilesFunction(varargin)
                   % project=varargin{3};
                  
                    set(project.SystemParametersPushButton,'enable','on');

                    [FileName,PathName] = uigetfile({'*.wav';'*.sph'},'Select Conv Files',...
                            '..\','MultiSelect','on');
                     project. FileName=FileName; 
                     try
                        if iscell(FileName)
                            list =cellfun(@(t)fullfile(PathName,t),FileName,'UniformOutput',false);
                       
                            
                         %  [saveFileName,savePathName] = uiputfile('..\allLDC.txt','List File Save');

                            fid =fopen([project.path,'\SDAIS\allLDC.txt'],'w');%%%%change her to the value you want in your comp%%%

                            cellfun(@(t)fprintf(fid,'%s\n',t),list);
                                                        
                            fclose(fid);   
                            
                        else
%                          [saveFileName,savePathName] = uiputfile('..\allLDC.txt','List File Save');
                         fid =fopen([project.path,'\SDAIS\allLDC.txt'],'w');%%%%change her to the value you want in your comp%%%
                         fprintf(fid,'%s%s\n',PathName,FileName);
                          fclose(fid);  
                        end
                     catch
                         errordlg('Cant Write  allLDC.txt File in Use','Error Writing to file')
                         error('Cant write allLDC.txt')
                         end
                    end

                    function[]=SystemParametersFunction(varargin)
                    %project=varargin{3};
                     if project.TestIndex==1
                        project.TestIndex=project.TestIndex+1;
                    set(project.MainWindow,'Visible','off');
                    set(project.StartDiazPushButton,'enable','on');
                    set(project.StartRadioButton,'enable','on');
                    set(project.StartRadioButton2,'enable','on');
                    set(project.StartRadioButton3,'enable','on');
                    set(project.StartRadioButton4,'enable','on');                   
                    Pos=[1 1 1 1];

    
    
    
 project.MainWindowSystemParameters=figure('units','pixels',...
                                                                                              'name','Speaker Diar System By Eyal Lampel & Rotem Levi',...
                                                                                                'color','w','position',Pos,...
                                                                                                'resize', 'on','menubar','none');%[200,209,800,700])%)%c;%     'resize', 'off', 
                                                                                                                        

                                                                                          
                                                                                            

centerfig(project.MainWindowSystemParameters);

project.SystemParametersHeadLine=uicontrol('style','text','string',...
                                 'SystemParameters','position',[500,650,245,27],'fontsize',15,...
                                                                      'fontweight','bold','backgroundcolor','w');
                                                                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
project.SystemParametersButtonPanel=uibuttongroup('units','pixels',...
                                                           'position',[50,420,300,200],'backgroundcolor','w')   ;                                                                         

                                                       

 project.SystemParametersHeadLine2=uicontrol('style','text','string',...
                         'Voice activity detection','position',[45,170,207,20],'fontsize',11,...
                                                        'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel);                                                       

project.SystemParametersStaticText=uicontrol('style','text','string',...
                     'Non Speech Window Length:','position',[4.5,140,207,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel)   ;                                                        
                                                    

project.SystemParametersEditText=uicontrol('style','edit','string',...
            '0.1','position',[215,140,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel);


project.SystemParametersStaticText2=uicontrol('style','text','string',...
                             'Non Speech Thresh Hold1:','position',[4.5,90,207,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText2=uicontrol('style','edit','string',...
             '0.01','position',[215,90,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel); 
 
 
 project.SystemParametersHeadLine3=uicontrol('style','text','string',...
                         'None Speech Type','position',[45,50,207,20],'fontsize',11,...
                                                        'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel);  
                                                    
project.SystemParametersRadioButton=uicontrol('style','radio','string',...
                             'energy','position',[4.5,20,80,20],'fontsize',11,...
      'backgroundcolor','w','parent',project.SystemParametersButtonPanel); 
  
project.SystemParametersRadioButton2=uicontrol('style','radio','string',...
                             'bigauss','position',[100,20,80,20],'fontsize',11,...
      'backgroundcolor','w','parent',project.SystemParametersButtonPanel);   
  
 project.SystemParametersRadioButton3=uicontrol('style','radio','string',...
             'vadsohn','position',[205,20,80,20],'backgroundcolor','w',...
             'parent',project.SystemParametersButtonPanel,'fontsize',11);
  
         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
         
        
project.SystemParametersButtonPanel2=uibuttongroup('units','pixels',...
                                                           'position',[51,105,300,200],'backgroundcolor','w')   ;                                                                         

                                                       

 project.SystemParametersHeadLine4=uicontrol('style','text','string',...
                         'Overlapped speech detection','position',[45,170,207,20],'fontsize',11,...
                                                        'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel2);                                                       

project.SystemParametersStaticText3=uicontrol('style','text','string',...
                     'Overlapped Window Length:','position',[4.5,140,207,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel2)   ;                                                        
                                                    

project.SystemParametersEditText3=uicontrol('style','edit','string',...
            '0.1','position',[215,140,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel2);


project.SystemParametersStaticText4=uicontrol('style','text','string',...
                             'Overlapped Thresh Hold:','position',[4.5,90,207,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel2,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText4=uicontrol('style','edit','string',...
             '0','position',[215,90,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel2); 
 
 
 project.SystemParametersHeadLine5=uicontrol('style','text','string',...
                         'Overlapped Speech  Type','position',[45,50,207,20],'fontsize',11,...
                                                        'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel2);  
                                                    
project.SystemParametersRadioButton4=uicontrol('style','radio','string',...
                             'entropy','position',[45,20,80,20],'fontsize',11,...
      'backgroundcolor','w','parent',project.SystemParametersButtonPanel2); 
  
   
 project.SystemParametersRadioButton5=uicontrol('style','radio','string',...
             'none','position',[180,20,80,20],'backgroundcolor','w',...
             'parent',project.SystemParametersButtonPanel2,'fontsize',11,'value',1);         
         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
project.SystemParametersButtonPanel3=uibuttongroup('units','pixels',...
                                                           'position',[380,320,395,300],'backgroundcolor','w')   ;                                                                         

                                                       

 project.SystemParametersHeadLine6=uicontrol('style','text','string',...
                         'Feature Extraction','position',[85,270,207,20],'fontsize',11,...
                                                        'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel3);                                                       

project.SystemParametersStaticText5=uicontrol('style','text','string',...
                     'Feature Extraction order:','position',[44.5,240,207,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel3)   ;                                                        
                                                    

project.SystemParametersEditText5=uicontrol('style','edit','string',...
            '12','position',[255,240,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel3);


project.SystemParametersStaticText6=uicontrol('style','text','string',...
                             'Feature Extraction energy:','position',[44.5,190,207,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel3,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText6=uicontrol('style','edit','string',...
             '0','position',[255,190,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel3); 
 
project.SystemParametersStaticText7=uicontrol('style','text','string',...
                             'Extraction Window Length:','position',[44.5,140,207,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel3,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText7=uicontrol('style','edit','string',...
             '0.02','position',[255,140,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel3); 
        
 project.SystemParametersStaticText8=uicontrol('style','text','string',...
                             'Extraction Window Icremental:','position',[44.5,90,207,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel3,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText8=uicontrol('style','edit','string',...
             '0.01','position',[255,90,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel3);        
        
 project.SystemParametersHeadLine7=uicontrol('style','text','string',...
                         'Feature normalization Type','position',[85,50,207,20],'fontsize',11,...
                                                        'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel3);  
                                                  
project.SystemParametersRadioButton6=uicontrol('style','radio','string',...
                             'none','position',[4.5,20,80,20],'fontsize',11,...
      'backgroundcolor','w','parent',project.SystemParametersButtonPanel3); 
  
project.SystemParametersRadioButton7=uicontrol('style','radio','string',...
                             'cms','position',[100,20,80,20],'fontsize',11,...
      'backgroundcolor','w','parent',project.SystemParametersButtonPanel3);   
  
 project.SystemParametersRadioButton8=uicontrol('style','radio','string',...
             'cmsvar','position',[205,20,80,20],'backgroundcolor','w',...
             'parent',project.SystemParametersButtonPanel3,'fontsize',11);
           
 project.SystemParametersRadioButton9=uicontrol('style','radio','string',...
             'warp','position',[310,20,80,20],'backgroundcolor','w',...
             'parent',project.SystemParametersButtonPanel3,'fontsize',11);
         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

project.SystemParametersButtonPanel4=uibuttongroup('units','pixels',...
                                                           'position',[800,105,425,200],'backgroundcolor','w')   ;                                                                         

                                                       

 project.SystemParametersHeadLine8=uicontrol('style','text','string',...
                         'Modeling','position',[105,170,207,20],'fontsize',11,...
                                                        'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel4);                                                       

project.SystemParametersStaticText9=uicontrol('style','text','string',...
                     'Model Type:','position',[1,140,90,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel4)   ;                                                        
                                                    

project.SystemParametersRadioButton10=uicontrol('style','radio','string',...
            'som','position',[130,140,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel4);


 project.SystemParametersRadioButton11=uicontrol('style','radio','string',...
            'gmm','position',[275,140,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel4);       
        
project.SystemParametersStaticText10=uicontrol('style','text','string',...
                             'Som Length:','position',[1,110,90,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel4,'backgroundcolor','w');        
        
  
project.SystemParametersEditText10=uicontrol('style','edit','string',...
             '6','position',[90,110,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel4); 
 

project.SystemParametersStaticText11=uicontrol('style','text','string',...
                             'Som width:','position',[240,110,90,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel4,'backgroundcolor','w');        
        
  
project.SystemParametersEditText11=uicontrol('style','edit','string',...
             '10','position',[323,110,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel4);         
        

project.SystemParametersStaticText12=uicontrol('style','text','string',...
                             'Gmm Order:','position',[1,70,90,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel4,'backgroundcolor','w');        
        
  
project.SystemParametersEditText12=uicontrol('style','edit','string',...
             '60','position',[90,70,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel4); 
 

project.SystemParametersStaticText13=uicontrol('style','text','string',...
                             'Gmm Max Iteration:','position',[195,70,130,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel4,'backgroundcolor','w');        
        
  
project.SystemParametersEditText13=uicontrol('style','edit','string',...
             '100','position',[323,70,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel4);                 
 
project.SystemParametersStaticText14=uicontrol('style','text','string',...
                     'Gmm Train:','position',[1,40,90,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel4)   ;                                                        
                                                    

project.SystemParametersButtonPanel5=uibuttongroup('units','pixels',...
                                                           'position',[0,0,240,0.1],'backgroundcolor','w',...
                                               'parent',project.SystemParametersButtonPanel4,...
                                               'shadowcolor','w'); 

project.SystemParametersRadioButton12=uicontrol('style','radio','string',...
            'Full','position',[105,40,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel5);


 project.SystemParametersRadioButton13=uicontrol('style','radio','string',...
            'Diag','position',[225,40,60,20],'fontweight','bold','backgroundcolor','w',...
            'value',1,'parent',project.SystemParametersButtonPanel5);        
        
 project.SystemParametersRadioButton14=uicontrol('style','radio','string',...
            'map','position',[345,40,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel5);        

project.SystemParametersButtonPanel6=uibuttongroup('units','pixels',...
                                                           'position',[-10,-30,240,0.1],'backgroundcolor','w',...
                                               'parent',project.SystemParametersButtonPanel4,...
                                               'shadowcolor','w');         
 
project.SystemParametersStaticText15=uicontrol('style','text','string',...
                     'Gmm init:','position',[10,40,75,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel6)   ;                                           
                                           
 project.SystemParametersRadioButton15=uicontrol('style','radio','string',...
            'kmeans','position',[140,40,70,20],'fontweight','bold','backgroundcolor','w',...
            'value',1,'parent',project.SystemParametersButtonPanel6);        
        
 project.SystemParametersRadioButton16=uicontrol('style','radio','string',...
            'random','position',[285,40,70,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel6);                                                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

project.SystemParametersButtonPanel7=uibuttongroup('units','pixels',...
                                                           'position',[800,450,425,170],'backgroundcolor','w')   ;                                                                         

                                                       

 project.SystemParametersHeadLine9=uicontrol('style','text','string',...
                         'Diarization system parameters ','position',[105,140,207,20],'fontsize',...              
                                                        11,'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel7);                                                       

project.SystemParametersStaticText16=uicontrol('style','text','string',...
                     'Diar Iteration:','position',[20,100,100,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel7)   ;                                                        
                                                    

project.SystemParametersEditText14=uicontrol('style','edit','string',...
            '12','position',[115,100,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel7);


project.SystemParametersStaticText17=uicontrol('style','text','string',...
                             'Number of Clusters:','position',[180,100,140,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel7,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText15=uicontrol('style','edit','string',...
             '2','position',[320,100,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel7); 
 
project.SystemParametersStaticText18=uicontrol('style','text','string',...
                             'TrainNS:','position',[45,70,80,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel7,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText16=uicontrol('style','edit','string',...
             '1','position',[115,70,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel7); 
        

project.SystemParametersStaticText19=uicontrol('style','text','string',...
                             'Save Data:','position',[238,70,80,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel7,'backgroundcolor','w');        
        

 
project.SystemParametersEditText17=uicontrol('style','edit','string',...
             '1','position',[320,70,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel7);        
        
        
 project.SystemParametersHeadLine10=uicontrol('style','text','string',...
                         'Init','position',[105,40,207,20],'fontsize',11,...
                                                        'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel7);  
   
                                             
project.SystemParametersRadioButton17=uicontrol('style','radio','string',...
                             'random','position',[4.5,10,80,20],'fontsize',11,...
      'backgroundcolor','w','parent',project.SystemParametersButtonPanel7); 
  
project.SystemParametersRadioButton18=uicontrol('style','radio','string',...
                             ' srandom','position',[80,10,80,20],'fontsize',11,...
      'backgroundcolor','w','parent',project.SystemParametersButtonPanel7);   
  
 project.SystemParametersRadioButton19=uicontrol('style','radio','string',...
             'kmeans','position',[170,10,80,20],'backgroundcolor','w',...
             'parent',project.SystemParametersButtonPanel7,'fontsize',11);
           
 project.SystemParametersRadioButton20=uicontrol('style','radio','string',...
             'skmeans','position',[245,10,80,20],'backgroundcolor','w',...
             'parent',project.SystemParametersButtonPanel7,'fontsize',11);

   project.SystemParametersRadioButton21=uicontrol('style','radio','string',...
             'wskmeans','position',[330,10,90,20],'backgroundcolor','w',...
             'parent',project.SystemParametersButtonPanel7,...
             'fontsize',11,'value',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
project.SystemParametersButtonPanel8=uibuttongroup('units','pixels',...
                                                           'position',[800,320,425,125],'backgroundcolor','w')   ;                                                                         

                                                       

 project.SystemParametersHeadLine11=uicontrol('style','text','string',...
      'Online Diarization system parameters ','position',[105,100,207,20],'fontsize',...              
                                                        11,'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel8);                                                       

project.SystemParametersStaticText20=uicontrol('style','text','string',...
                     'Init seg:','position',[20,70,100,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel8)   ;                                                        
                                                    

project.SystemParametersEditText18=uicontrol('style','edit','string',...
            '120','position',[115,70,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel8);


project.SystemParametersStaticText21=uicontrol('style','text','string',...
                             'Update seg:','position',[180,70,140,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel8,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText19=uicontrol('style','edit','string',...
             '10','position',[320,70,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel8); 
 
project.SystemParametersStaticText22=uicontrol('style','text','string',...
                             'Update iter:','position',[125,25,80,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel8,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText20=uicontrol('style','edit','string',...
             '5','position',[220,25,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel8); 
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  project.SystemParametersButtonPanel9=uibuttongroup('units','pixels',...
                                                           'position',[50,320,300,90],'backgroundcolor','w')   ;                                                                         

                                                       

 project.SystemParametersHeadLine12=uicontrol('style','text','string',...
      'Time series clustering ','position',[50,65,207,20],'fontsize',...              
                                                        11,'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel9);                                                       

project.SystemParametersStaticText23=uicontrol('style','text','string',...
                     'Minimum Duration:','position',[60,40,140,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel9)   ;                                                        
                                                    

project.SystemParametersEditText21=uicontrol('style','edit','string',...
            '0.5','position',[200,40,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel9);


project.SystemParametersStaticText24=uicontrol('style','text','string',...
                             'Post Minimum Duration:','position',[30,10,170,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel9,'backgroundcolor','w');        
        
  
 
project.SystemParametersEditText22=uicontrol('style','edit','string',...
             '0.1','position',[200,10,60,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel9); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  project.SystemParametersButtonPanel10=uibuttongroup('units','pixels',...
                                                           'position',[381,105,395,200],'backgroundcolor','w')   ;                                                                         

                                                       

 project.SystemParametersHeadLine13=uicontrol('style','text','string',...
      'Results  ','position',[100,165,207,20],'fontsize',...              
                                                        14,'fontweight','bold','backgroundcolor','w' ,'parent',...
                                                        project.SystemParametersButtonPanel10);                                                       

project.SystemParametersStaticText24=uicontrol('style','text','string',...
                     'Destination directory:','position',[0,140,140,20],'fontsize',11,...
'backgroundcolor','w', 'parent',project.SystemParametersButtonPanel10)   ;                                                        
                                                    

project.SystemParametersEditText23=uicontrol('style','edit','string',...
           cd ,'position',[140,140,150,20],'fontweight','bold','backgroundcolor','w',...
            'parent',project.SystemParametersButtonPanel10);

set(project.DerPushButton,'callback',...
                                                            {@DerFunction,project});        
        

project.SystemParametersPushButton2=uicontrol('style','pushbutton','string',...
            'Browse','position',[300,140,90,20],'fontweight','bold',...
            'parent',project.SystemParametersButtonPanel10);   
        
 %#function SystemParametersReSetSubFunction
project.SystemParametersPushButton3=uicontrol('style','pushbutton','string',...
                             'ReSet Default Parameters','position',[110,90,190,20],'fontsize',11,...
     'parent',project.SystemParametersButtonPanel10,...
     'callback',{@SystemParametersReSetSubFunction,project});        
        
  
 %#function SystemParametersSetSubFunction
project.SystemParametersPushButton4=uicontrol('style','pushbutton','string',...
             'Set System Parameters','position',[50,40,300,20],'fontweight','bold',...
            'parent',project.SystemParametersButtonPanel10,'fontsize',13,...
            'callback',{@SystemParametersSetSubFunction,project})  ;  
 
  
                            screen=get(0,'screensize');
                    b=sum(screen);
                    switch b
                        case  sum([1 1 1600 900])
                        Pos=[145  105  1284   693];
                    case sum([1 1 1680 1050])
                        Pos=[183,145,1287,735];
                        case sum([1 1 1440 900])
                            Pos=[ 100 ,104 ,1283 ,702];
                            case sum([1 1 1024 768])
                                  %  set(0,'ScreenPixelsPerInch',60);
                                  case sum([1  1  1152   864])
                                    Pos=[ 20 ,94 ,1117 ,689];
                                    case sum([1  1  800   600])      
                                        
                        case  sum([1  1  1280   1024])
                            Pos=[15,198,1254,682];
                            
                                        
                                    %    set(0,'screenpixelsperinch',60);
     %errordlg('please set a higher screen resolution')
                               %     Pos=[ 20 ,94 ,1117 ,689];                                       
                                    otherwise
                                    Pos=[screen(1),screen(2),screen(3)/1.1,screen(4)/1.1];
                    end
        set(project.MainWindowSystemParameters,...
            'position',Pos);
        
        
        
        

        
        
        
set(project.SystemParametersPushButton2,...
                           'callback',{@SystemParametersLoadSubFunction,project});             
 
                      
                       a=findall(gcf);
                       for i=1:length(a)
                           if strcmp(get(a(i),'type'),'uimenu')~=1
                           set(a(i),'units','characters');
                         
                           end
                       end
                                          
                       
                     else 
                         set(project.MainWindowSystemParameters,'Visible','on');                                               
                     end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
                        function[]=SystemParametersReSetSubFunction(varargin)                        
                            set(project.SystemParametersEditText,'string','0.1')
                            set(project.SystemParametersEditText2,'string','0.01')
                            set(project.SystemParametersEditText3,'string','0.1')
                            set(project.SystemParametersEditText4,'string','0')
                            set(project.SystemParametersEditText5,'string','12')
                            set(project.SystemParametersEditText6,'string','0')
                            set(project.SystemParametersEditText7,'string','0.02')
                            set(project.SystemParametersEditText8,'string','0.01')
                            set(project.SystemParametersEditText10,'string','6')
                            set(project.SystemParametersEditText11,'string','10')
                            set(project.SystemParametersEditText12,'string','60')
                            set(project.SystemParametersEditText13,'string','100')
                            set(project.SystemParametersEditText14,'string','12')
                            set(project.SystemParametersEditText15,'string','2')
                            set(project.SystemParametersEditText16,'string','1')
                            set(project.SystemParametersEditText17,'string','1')
                            set(project.SystemParametersEditText18,'string','120')
                            set(project.SystemParametersEditText19,'string','10')
                            set(project.SystemParametersEditText20,'string','5')
                            set(project.SystemParametersEditText21,'string','0.5')
                            set(project.SystemParametersEditText22,'string','0.1')
                            set(project.SystemParametersEditText23,'string',cd)
                            set(project.SystemParametersRadioButton,'value',1)
                            set(project.SystemParametersRadioButton5,'value',1)
                            set(project.SystemParametersRadioButton6,'value',1)
                            set(project.SystemParametersRadioButton10,'value',1)
                            set(project.SystemParametersRadioButton13,'value',1)
                            set(project.SystemParametersRadioButton15,'value',1)
                            set(project.SystemParametersRadioButton21,'value',1)
                        
                        end
                     
                     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        function[]=SystemParametersLoadSubFunction(varargin)
                        project=varargin{3};
                        folder_name = uigetdir;
                        set(project.SystemParametersEditText23,'string',folder_name);
                        end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                         function[]=SystemParametersSetSubFunction(varargin)
                        project=varargin{3};
                      
                        
                        if get(project.SystemParametersRadioButton,'value')==1
                            NonspType=get(project.SystemParametersRadioButton,'string');
                        else if get(project.SystemParametersRadioButton2,'value')==1
                                NonspType=get(project.SystemParametersRadioButton2,'string');
                            else
                                NonspType=get(project.SystemParametersRadioButton3,'string');
                            end
                        end
                    
                        if get(project.SystemParametersRadioButton4,'value')==1
                            OvspType=get(project.SystemParametersRadioButton4,'string');

                        else
                            OvspType=get(project.SystemParametersRadioButton5,'string');
                        end
                        
                        if get(project.SystemParametersRadioButton6,'value')==1
                        FeatNormType=get(project.SystemParametersRadioButton6,'string');
                                else if get(project.SystemParametersRadioButton7,'value')==1
                                FeatNormType=get(project.SystemParametersRadioButton7,'string');
                                          else if get(project.SystemParametersRadioButton8,'value')==1
                                          FeatNormType=get(project.SystemParametersRadioButton8,'string');
                                              else
                                              FeatNormType=get(project.SystemParametersRadioButton9,'string');
                                              end
                                    end
                        end
                       
                       if get(project.SystemParametersRadioButton10,'value')==1
                            Mod=get(project.SystemParametersRadioButton10,'string');

                        else
                            Mod=get(project.SystemParametersRadioButton11,'string');
                       end 
                       
                       
                      if get(project.SystemParametersRadioButton12,'value')==1
                            GmmTrain=get(project.SystemParametersRadioButton12,'string');
                        else if get(project.SystemParametersRadioButton13,'value')==1
                                GmmTrain=get(project.SystemParametersRadioButton13,'string');
                            else
                                GmmTrain=get(project.SystemParametersRadioButton14,'string');
                            end
                      end  
                    
                        
                      if get(project.SystemParametersRadioButton4,'value')==1
                            GmmInit=get(project.SystemParametersRadioButton15,'string');

                        else
                            GmmInit=get(project.SystemParametersRadioButton16,'string');
                      end
                      
                     
                      if get(project.SystemParametersRadioButton17,'value')==1
                          SdInit=get(project.SystemParametersRadioButton17,'string');
                      else if get(project.SystemParametersRadioButton18,'value')==1
                              SdInit=get(project.SystemParametersRadioButton18,'string');
                          else if get(project.SystemParametersRadioButton19,'value')==1
                                  SdInit=get(project.SystemParametersRadioButton19,'string');
                              else if get(project.SystemParametersRadioButton20,'value')==1
                                      SdInit=get(project.SystemParametersRadioButton20,'string');
                                  else
                                      SdInit=get(project.SystemParametersRadioButton21,'string');
                                  end
                              end
                          end
                      end
                      
                      
                 try
                       file =fopen([project.path,'\SDSArgs.txt'],'w');
                       fprintf(file,'Verbose, N,  1,\n');
                       fprintf(file,'NonspType, S, %s,\n', NonspType);
                       fprintf(file,'NonspWinLen, N, %s,\n', ...
                                                get(project.SystemParametersEditText,'string'));
                       fprintf(file,'NonspThresh, N, %s,\n', ...
                                                get(project.SystemParametersEditText2,'string'));                  
                       fprintf(file,'OvspType, S, %s,\n',OvspType);
                       fprintf(file,'OvspWinLen, N, %s,\n',   ...
                                                get(project.SystemParametersEditText3,'string')) ;                   
                       fprintf(file,'OvspThresh, N, %s,\n',     ...
                                                get(project.SystemParametersEditText4,'string'))  ;                  
                       fprintf(file,'PreProcType, S, preemph,\n') ;  
                       fprintf(file,'FeatType, S, mfcc,\n');
                       fprintf(file,'FeatAnaOrd, N, %s,\n', ...
                                               get(project.SystemParametersEditText5,'string')) ;
                       fprintf(file,'FeatEnergy, N, %s,\n', ...
                                                get(project.SystemParametersEditText6,'string')) ;
                       fprintf(file,'FeatDel,N, 0,\n');
                       fprintf(file,'FeatDelDel, N, 0,\n');
                       fprintf(file,'FeatWinLen, N, %s,\n',...
                                               get(project.SystemParametersEditText7,'string'));
                       fprintf(file,'FeatWinInc, N, %s,\n',...
                                               get(project.SystemParametersEditText8,'string'))  ;                     
                       fprintf(file,'FeatNormType, S, %s,\n',FeatNormType);
                       fprintf(file,'Mod, S, %s,\n',Mod);
                       fprintf(file,'SomLen, N, %s,\n',...
                                               get(project.SystemParametersEditText10,'string'));
                       fprintf(file,'SomWid, N, %s,\n',...
                                               get(project.SystemParametersEditText11,'string')) ;               
                       fprintf(file,'GmmOrder, N, %s,\n',...
                                               get(project.SystemParametersEditText12,'string')) ;      
                       fprintf(file,'GmmTrain, S, %s,\n',GmmTrain);
                       fprintf(file,'GmmInit, S, %s,\n',GmmInit);
                       fprintf(file,'GmmMaxIter, N, %s,\n',...
                                               get(project.SystemParametersEditText13,'string')) ;    
                       fprintf(file,'SdInit, S, %s,\n',SdInit) ;              
                       fprintf(file,'SdDiarIter, N, %s,\n',...
                                               get(project.SystemParametersEditText14,'string'))    ;            
                       fprintf(file,'SdDiarIterFinal, N, 0,\n')  ;                                                                               
                       fprintf(file,'SdNumClust, N, %s,\n',...
                                               get(project.SystemParametersEditText15,'string')); 
                       fprintf(file,'SdTrainNS, N, %s,\n',...
                                               get(project.SystemParametersEditText16,'string'))  ;             
                       fprintf(file,'SdSubDir, N, 0,\n') ;
                       fprintf(file,'SdSaveData, N, %s,\n',...
                                               get(project.SystemParametersEditText17,'string'));
                       fprintf(file,'SdSaveEachIter, N, 0,\n');       
                       fprintf(file,'SdOlInitSeg, N, %s,\n',...
                                               get(project.SystemParametersEditText18,'string'));
                       fprintf(file,'SdOlUpdateSeg, N, %s,\n',...
                                               get(project.SystemParametersEditText19,'string'));             
                       fprintf(file,'SdOlUpdateIter, N, %s,\n',...
                                               get(project.SystemParametersEditText20,'string'));            
                       fprintf(file,'SdVitMinDur, N, %s,\n',...
                                               get(project.SystemParametersEditText21,'string'));            
                       fprintf(file,'SdPostVitMimDur, N, %s,\n',...
                                               get(project.SystemParametersEditText22,'string'));            
                       fprintf(file,'SdAdaptTransMat, N, 0,\n');    
                       fprintf(file,'SdAdaptTransMatIter, N, 0,\n');           
                       fprintf(file,'SdResDir, S, %s,\n',...
                                            get(project.SystemParametersEditText23,'string')) ;         
                                           fclose(file);  
                                          
                                            set(gcf,'Visible','off');
                                            set(project.MainWindow,'Visible','on');
               
                     catch
                         errordlg('Cant Write  SDSArgs.txt File in Use','Error Writing to file')
                         error('Cant write SDSArgs.txt')
                 
                         end
                                            
                                            
                             %  
%                               set(project.MainWindow,'Visible','on');              
                                  %set(project.MainWindow,'Visible','on');          
                                                
                         
                         end
                    end
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                   
    function StartDiazFunction(varargin)
      project.ShowResultsIndex=0;        
        set(project.MainWindow,'Visible','off');
        commandwindow;
       if get(project.StartRadioButton,'value')==1
                        SDSType=get(project.StartRadioButton,'string');
                                else if get(project.StartRadioButton2,'value')==1
                                SDSType=get(project.StartRadioButton2,'string');
                                          else if get(project.StartRadioButton3,'value')==1
                                          SDSType=get(project.StartRadioButton3,'string');
                                              else
                                              SDSType=get(project.StartRadioButton4,'string');
                                              end
                                    end
       end 
        
                        try
       project.file =fopen([project.path,'\SDAIS\allLDC.txt'],'r');%%%%change her to the value you want in your comp%%%
        project.ScannedFile=textscan(project.file,'%s');
        project.LengthOfScannedFile=cellfun(@length,project.ScannedFile);
                        catch
                            errordlg(['Cant Find ',project.path,'\SDAIS\allLDC.txt, File is Missing'])
                            error('cant read File allLDC.txt')
                        end
                            
      
                       try 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        for i=1:project.LengthOfScannedFile                          
        project.ListOfScannedFile(i,:)=project.ScannedFile{1}{i,1};%%?
        end     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
                       catch
                           errordlg(['Please Rename ',cd,' without spaces'])
                       end
       
                        switch SDSType
                            case 'On Demand'
                       fprintf(2,'Segmention Method is OnDemand\n')
                                
                                
                                InitialTrainingTime=str2double(get(project.SystemParametersEditText18,'string'));  % %%%uncomm
                                %InitialTrainingTime=120;%delete this
                                
                                %Read user input in update seg,Online diarization Block
                                GetDerTimes=str2double(get(project.SystemParametersEditText19,'string')) ;  %%%uncomm
                                
                                
                                for i=1:size(project.ListOfScannedFile,1)
                                    [Data{i},Fs{i}]=wavread(  project.ListOfScannedFile(i,:)  );
                                    Time{i}=( 1:length(Data{i}))/Fs{i};
                                    ConversationDuration{i}=length(Time{i})/Fs{i};
                                    %Stop on error
                                    if InitialTrainingTime>ConversationDuration{i}||...
                                            GetDerTimes>ConversationDuration{i}
                                        error('Input Parameters is bigger then Conversation Duration')
                                    end
                                end
                                
                                project.ConversationDuration=ConversationDuration;
                                Sections=floor((ConversationDuration{1}-InitialTrainingTime)./...
                                    GetDerTimes);

                               try
                                   for i=1:length(Data)
                               project.DER{i}=SDS_ondemand(InitialTrainingTime,GetDerTimes,Sections,project);
                                   end
                                 %  project.DER=[project.DER2,project.DER];
                                   
                               catch
                                   fprintf(2,'Manual Diarization not found');
                               end
clear Data Fs Time

                            case 'Online'
                                fprintf(2,'Segmention Method is Online\n')
                                 
                                InitialTrainingTime=str2double(get(project.SystemParametersEditText18,'string'));  % %%%uncomm
                                %InitialTrainingTime=120;%delete this
                                
                                %Read user input in update seg,Online diarization Block
                                GetDerTimes=str2double(get(project.SystemParametersEditText19,'string')) ;  %%%uncomm
                                
                                
                                for i=1:size(project.ListOfScannedFile,1)
                                    [Data{i},Fs{i}]=wavread(  project.ListOfScannedFile(i,:)  );
                                    Time{i}=( 1:length(Data{i}))/Fs{i};
                                    ConversationDuration{i}=length(Time{i})/Fs{i};
                                    %Stop on error
                                    if InitialTrainingTime>ConversationDuration{i}||...
                                            GetDerTimes>ConversationDuration{i}
                                        error('Input Parameters is bigger then Conversation Duration')
                                    end
                                end
                                
                                project.ConversationDuration=ConversationDuration;
                                Sections=floor((ConversationDuration{1}-InitialTrainingTime)./...
                                    GetDerTimes);

                               try
                                   for i=1:length(Data)
                              [ project.DER{i},project.Time2{i}]=SDS_OnLine(InitialTrainingTime,GetDerTimes,Sections,project);
                                   end
                               catch
                                   fprintf(2,'Manual Diarization not found');
                               end                                
                                
                                clear Data Fs Time
                                
                                

                            case 'Incremental'
                                fprintf(2,'Segmention Method is Incremental\n')
                                
                                
                                InitialTrainingTime=str2double(get(project.SystemParametersEditText18,'string'));  % %%%uncomm
                                %InitialTrainingTime=120;%delete this
                                
                                %Read user input in update seg,Online diarization Block
                                GetDerTimes=str2double(get(project.SystemParametersEditText19,'string')) ;  %%%uncomm
                                
                                
                                for i=1:size(project.ListOfScannedFile,1)
                                    [Data{i},Fs{i}]=wavread(  project.ListOfScannedFile(i,:)  );
                                    Time{i}=( 1:length(Data{i}))/Fs{i};
                                    ConversationDuration{i}=length(Time{i})/Fs{i};
                                    %Stop on error
                                    if InitialTrainingTime>ConversationDuration{i}||...
                                            GetDerTimes>ConversationDuration{i}
                                        error('Input Parameters is bigger then Conversation Duration')
                                    end
                                end
                                
                                project.ConversationDuration=ConversationDuration;
                                Sections=floor((ConversationDuration{1}-InitialTrainingTime)./...
                                    GetDerTimes);

                               try
                                   for i=1:length(Data)
                               project.DER{i}=SDS_ondemand(InitialTrainingTime,GetDerTimes,Sections,project);
                                   end
                               catch
                                   fprintf(2,'Manual Diarization not found');
                               end
                                
clear Data Fs Time                                
                                
                                
                            case 'Full'
                                fprintf(2,'Segmention Method is Full (Offline)\n')
                                h = waitbar(0,'Wave To Data Please Wait...');
                                steps = 1000;
                                for step = 1:steps
                                    if step==400
                                      SDS
                                           %SDS_ondemand
                                    else
                                        waitbar(step / steps)
                                    end
                                end
                                close(h)

                        end
        
        
        
clear Data Fs Time 
     
       % set(project.MainWindow,'Visible','on');
       set(project.DerPushButton,'enable','on');
       screen=get(0,'screensize');
       if sum(screen==[1 1 1680 1050])==4
           screen=[239  210  1001  718];
       else if sum(screen==[1 1 1440 900])==4
               screen=[235   111   971   702];
           else if sum(screen==[1    1   1024  768])==4
                   screen=[36   36   947   698];
               else if sum(screen==[1    1   1600  900])==4
                       screen=[ 336    92   955   708  ];
                   else if sum(screen==[1    1   1280  1024])==4
                           screen=[ 185 155 945 720  ];
                           
                           
                       else
                           screen=[screen(1),screen(2),screen(3)/1.4,screen(4)/1.1];
                       end
                   end
               end
           end
       end
        project.Results=figure('color','w','position',screen,...
            'resize','on');%,'MenuBar','none');
        centerfig( project.Results);
                          
           
        
        
        project.ResultsHeadLine=uicontrol('style','text','backgroundcolor','w',...
            'string','System Results','position',...
            [300,660,270,30],'fontweight','bold','fontsize',15);
       
        project.ResultsStaticText=uicontrol('style','text','backgroundcolor','w',...
            'string','Loaded Files','position',...
            [450,620,104,30],'fontweight','bold','fontsize',13);
        
        project.ResultsStaticText2=uicontrol('style','text','backgroundcolor','w',...
            'string','Results','position',...
            [120,625,104,25],'fontweight','bold','fontsize',13);
        
        project.ResultsPushButton=uicontrol('position',[450,470,104,30],'string',...
            'Show Results','callback',{@ShowResultsFunction,project});
        
   project.CompareResultsPushButton=uicontrol('position',[450,447,104,20],'string',...
            'Compare Results','callback',{@compare,project});
            
            
        project.ListOfFiles=uicontrol('style','listbox','position',[348,504,322,119],...
            'string',{project.ListOfScannedFile},'backgroundcolor','w','tag','List');
         
    
    project.ResultsLegend=uibuttongroup('units','pixels',...
                                                           'position',[348,325,322,119],'backgroundcolor','w') ;
                                                       
     project.ResultsStaticText3=uicontrol('parent',project.ResultsLegend,...
       'string','Legend','style','text','fontweight','bold','fontsize',15,...
       'position',[104,90,80,24],'backgroundcolor','w');
                                                       
   project.ResultsStaticText4=uicontrol('parent',project.ResultsLegend,...
       'string','Value','style','text','fontweight','bold','fontsize',13,...
       'position',[20,80,60,20],'backgroundcolor','w');
   
      project.ResultsStaticText5=uicontrol('parent',project.ResultsLegend,...
       'string','Description','style','text','fontweight','bold','fontsize',13,...
       'position',[180,80,100,20],'backgroundcolor','w');
    
   project.ResultsStaticText6=uicontrol('parent',project.ResultsLegend,...
       'string','0','style','text','fontweight','bold','fontsize',13,...
       'position',[20,59,60,18],'backgroundcolor','w');
   
      project.ResultsStaticText7=uicontrol('parent',project.ResultsLegend,...
       'string','1','style','text','fontweight','bold','fontsize',13,...
       'position',[20,42,60,18],'backgroundcolor','w');
   
      project.ResultsStaticText8=uicontrol('parent',project.ResultsLegend,...
       'string','2','style','text','fontweight','bold','fontsize',13,...
       'position',[20,24,60,18],'backgroundcolor','w');
   
      project.ResultsStaticText9=uicontrol('parent',project.ResultsLegend,...
       'string','3','style','text','fontweight','bold','fontsize',13,...
       'position',[20,5,60,18],'backgroundcolor','w');
   
   
     project.ResultsStaticText10=uicontrol('parent',project.ResultsLegend,...
       'string','None Voice','style','text','fontsize',11,...
       'position',[180,60,100,20],'backgroundcolor','w');
   
   project.ResultsStaticText11=uicontrol('parent',project.ResultsLegend,...
       'string','Speaker A','style','text','fontsize',11,...
       'position',[180,40,100,20],'backgroundcolor','w');
   
     project.ResultsStaticText12=uicontrol('parent',project.ResultsLegend,...
       'string','Speaker B','style','text','fontsize',11,...
       'position',[180,20,100,20],'backgroundcolor','w');
   
     project.ResultsStaticText13=uicontrol('parent',project.ResultsLegend,...
       'string','Over Lap Speech','style','text','fontsize',11,...
       'position',[180,01,100,20],'backgroundcolor','w');
   
     project.ResultsPushButton2=uicontrol('position',[280 10 310 30],'string',...
            'Return To Main Window','callback',{@ReturnSubFunction,project});
        
  
        
%==================================================================
                                                %Initialize Axes Buttongroup
          
        
project.ResultsPlotButtonGroup=uibuttongroup('unit','pixels','position',...
    [25,80,900,225],'backgroundcolor','w');      
project.ResultsPlot=axes('Units', 'pixels','position', ...
     [35,80,600,120],'box','on','parent',project.ResultsPlotButtonGroup);
 
 %X axis
 project.ResultsPlotStaticText=uicontrol('style','text','string',...
     'X axis:','position',[640 173 35 20],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);
 
   project.ResultsPlotEditText=uicontrol('style','edit','string',...
     '0','position',[680 177 40 20],'parent',project.ResultsPlotButtonGroup,...
     'backgroundcolor','w');
 
 project.ResultsPlotStaticText2=uicontrol('style','text','string',...
     'to','position',[722 173 20 20],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);
 
    project.ResultsPlotEditText2=uicontrol('style','edit','string',...
     '120','position',[745 177 40 20],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);       
  
 %Y axis    
  project.ResultsPlotStaticText3=uicontrol('style','text','string',...
     'Y axis:','position',[640 143 35 20],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);
 
   project.ResultsPlotEditText3=uicontrol('style','edit','string',...
     '-0.5','position',[680 147 40 20],'parent',project.ResultsPlotButtonGroup,...
     'backgroundcolor','w');
 
 project.ResultsPlotStaticText4=uicontrol('style','text','string',...
     'to','position',[722 143 20 20],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);
 
    project.ResultsPlotEditText4=uicontrol('style','edit','string',...
     '0.5','position',[745 147 40 20],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);    

 %Play from x to y
  project.ResultsPlotStaticText5=uicontrol('style','text','string',...
     'From:','position',[640 105 35 20],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);
 
   project.ResultsPlotEditText5=uicontrol('style','edit','string',...
     '0','position',[680 107 40 20],'parent',project.ResultsPlotButtonGroup,...
     'backgroundcolor','w');
 
 project.ResultsPlotStaticText6=uicontrol('style','text','string',...
     'to','position',[722 103 20 20],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);
 
    project.ResultsPlotEditText6=uicontrol('style','edit','string',...
     '120','position',[745 107 40 20],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);    
 
 
 %#function SetAxisSubFunction
  % Buttons
     project.ResultsPlotButton=uicontrol('style','pushbutton','string',...
     'Set  Axis','position',[800 177 80 20],...
     'parent',project.ResultsPlotButtonGroup,...
     'callback',{@SetAxisSubFunction,project});  
 
      project.ResultsPlotButton2=uicontrol('style','pushbutton','string',...
     'Play','position',[800 107 80 20],...
     'parent',project.ResultsPlotButtonGroup,...
     'callback',{@PlaySoundSubFunction,project});  
 
       project.ResultsPlotButton2=uicontrol('style','pushbutton','string',...
     'Stop','position',[800 87 80 20],...
     'parent',project.ResultsPlotButtonGroup,...
     'callback',{@StopPlaySoundSubFunction});  
 
 
 % display
   project.ResultsPlotStaticText7=uicontrol('style','text','string',...
     'Display:','position',[815 55 40 13],'backgroundcolor','w',...
     'parent',project.ResultsPlotButtonGroup);
 
       project.ResultsPlotPopUpMenu=uicontrol('style','popupmenu','string',...
     {'Time Sequance','spectrogram'},'position',[790 35 95 20],...
     'backgroundcolor','w','parent',project.ResultsPlotButtonGroup,...
     'callback',{@ChangeDisplay,project});  
 
 %%next and previous
       project.ResultsPlotButton3=uicontrol('style','pushbutton','string',...
     'Next Segment ------>>','position',[350 15 160 25],...
     'fontweight','bold','parent',project.ResultsPlotButtonGroup,...
     'callback',{@NextSegment,'project',1,'TimeSequance'});  
 
        project.ResultsPlotButton4=uicontrol('style','pushbutton','string',...
     '<<------  Previous Segment','position',[150 15 160 25],...
     'fontweight','bold','parent',project.ResultsPlotButtonGroup,...
     'callback',{@NextSegment,'project',2,'TimeSequance'});  
        
   %%   Der buttongroup
           project.ResultsDerButtongroup=uibuttongroup('units','pixels','position',...
            [693,325,230,300],'backgroundcolor','w');
        
          project.ResultsDerStaticText=uicontrol('parent',...
            project.ResultsDerButtongroup,...
            'backgroundcolor','w','position',[0 260 80 20],'string','Start (Sec)','style','text',...
           'fontsize',9,'fontweight','bold' );

            project.ResultsDerStaticText2=uicontrol('parent',...
            project.ResultsDerButtongroup,...
            'backgroundcolor','w','position',[80 260 70 20],'string','End (Sec)','style','text',...
            'fontsize',9,'fontweight','bold' );
        
            project.ResultsDerStaticText3=uicontrol('parent',...
            project.ResultsDerButtongroup,...
            'backgroundcolor','w','position',[155 260 47 20],'string','DER %','style','text',...
            'fontsize',9,'fontweight','bold' );
        
        
           project.ResultsDerHeadline=uicontrol('style','text','backgroundcolor','w',...
            'string','DER Results','position',...
            [750,625,104,25],'fontweight','bold','fontsize',13);
   
   
        project.ResultsOutPutWindowButtongroup=uibuttongroup('units','pixels','position',...
            [25,325,300,300],'backgroundcolor','w');
        
        project.ResultsOutPutWindowTitle=uicontrol('parent',...
            project.ResultsOutPutWindowButtongroup,...
            'backgroundcolor','w','position',[10 260 80 20],'string','Start (Sec)','style','text',...
           'fontsize',11,'fontweight','bold' );
       
               project.ResultsOutPutWindowTitle2=uicontrol('parent',...
                   project.ResultsOutPutWindowButtongroup,...
            'backgroundcolor','w','position',[110 260 70 20],'string','End (Sec)','style','text',...
           'fontsize',11,'fontweight','bold' );
       
                      project.ResultsOutPutWindowTitle3=uicontrol('parent',...
                          project.ResultsOutPutWindowButtongroup,...
            'backgroundcolor','w','position',[215 260 50 20],'string','Value','style','text',...
           'fontsize',11,'fontweight','bold' );
       
        
       project.ResultsOutPutWindowButtongroup2=uibuttongroup('units','pixels','position',...
            [20,16,235,243],'backgroundcolor','w','shadowcolor','w','parent',...
            project.ResultsOutPutWindowButtongroup);
               
        
        
   project.NumberOfLoadedFiles=size(project.ListOfScannedFile);
   project.NumberOfLoadedFiles=project.NumberOfLoadedFiles(1);
        for i=1:project.NumberOfLoadedFiles
        ListOfTextFile(i,:)= [project.ListOfScannedFile(i,1:length(project.ListOfScannedFile)-3),'txt'];
        end
    
         
        try
            UserSelected=get(project.ListOfFiles,'value');
            [x,name,ext]=fileparts(ListOfTextFile(...
                UserSelected,:));
            path=get(project.SystemParametersEditText23,'string');
            fullpath=[path,'\',name,ext];
  file4=fopen( fullpath,'r');
  ScannedFile= textscan( file4,'%s %s %s',[3 1]);
  ScannedFile=  [ ScannedFile{1},ScannedFile{2},ScannedFile{3}];
         catch
                            errordlg(['Cant Find ',ListOfTextFile,' File is Missing'])
                            error(['cant read ', ListOfTextFile])
                        end
                            
        
        project.ResultsOutPutWindowSlider=uicontrol('parent',...
            project.ResultsOutPutWindowButtongroup,'max',...
            length(ScannedFile)-1,'min',0,'value',length(ScannedFile)-1,...
           'style','slider','position',[265,10,20,250],'backgroundcolor','w',...
           'sliderstep',[1/(length(ScannedFile)-1),0.1]);
%        
try
                     project.ResultsOutPutWindowSlider2=uicontrol('parent',...
            project.ResultsDerButtongroup,'max',...
           length(project.DER{1}(:)),'min',1,'value',length(project.DER{1}(:)),...
           'style','slider','position',[206,10,20,250],'backgroundcolor','w',...
           'sliderstep',[1/(length(project.DER{1}(:))),0.1],'callback',{@DerSlider,project});  
    catch
end
warning off all
       ShowResultsFunction(2);
    
   %WaveFilePath='C:\DS_From_Lampel\LDC_Callhome\Conversations\en_0638.wav';
%TextFileName='C:\DS_From_Lampel\LDC_Callhome\Segmentations\en_0638.txt';
%destination='d:\';
%   fullpath

           
  
    end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
        function ReturnSubFunction(varargin)
            project=varargin{3};
            set(project.Results,'visible','off');
            set(project.MainWindow,'visible','on')  ;
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ShowResultsFunction(varargin)
       project.indexxx=0; 
   if nargin==1 
       set( project.ListOfFiles,'value',project.NumberOfLoadedFiles);      
   end      
        
        project.ShowResultsIndex=project.ShowResultsIndex+1;
 UserSelectedFile=get( project.ListOfFiles,'value');
      project.SelectedFileForResults=get(project.ListOfFiles,'value'); 
      
      
        for i=1:project.NumberOfLoadedFiles
          [x,name,ext]=fileparts(project.ListOfScannedFile(i,:) );         
          ListOfTextFile(i,:)=[name,'.txt'];
        end
     path=get(project.SystemParametersEditText23,'string');   
          
%         for i=1:project.NumberOfLoadedFiles
%         ListOfTextFile(i,:)= [project.ListOfScannedFile(i,1:length(project.ListOfScannedFile)-3),'txt'];
%         end
%         
        try
               file4=fopen([path,'\',ListOfTextFile(project.SelectedFileForResults,:)],'r');
       
      ScannedFile= textscan( file4,'%s %s %s',[3 1]);
  ScannedFile=  [ ScannedFile{1},ScannedFile{2},ScannedFile{3}];
  %set(project.ResultsOutPutWindowSlider,'max',length(ScannedFile)-1);
  catch
                         errordlg(['Cant Read ' ,...
                             ListOfTextFile(project.SelectedFileForResults,:)],...
                             'Error Reading File')
                         error(['Cant Read ',...
                             ListOfTextFile(project.SelectedFileForResults,:)])
                         end
  
  
  if  project.ShowResultsIndex<2
      for i=1:12%12 Rows
          for j=1:3%3 Colums
              project.ResultsPlotScannedText{i+12*(j-1)}=uicontrol('style','text','string', ScannedFile(i,j),'fontsize',11,...
                  'position',[100*(j-1),240-20*i,40,16],'backgroundcolor','w',...
                  'parent',project.ResultsOutPutWindowButtongroup2);
          end
      end
  end

   set(project.ResultsOutPutWindowSlider,'callback',...
            {@SliderFunction,project,ScannedFile});
   
       
        
    if project.ShowResultsIndex==1
                for i=1:size(project.ListOfScannedFile,1)
                        [Data{i},Fs{i}]=wavread(  project.ListOfScannedFile(i,:)  );    
                        Time{i}=( 1:length(Data{i}))/Fs{i};
                end
    
                
                       
                %axes(project.ResultsPlot)
                %cla(project.ResultsPlot,'reset')
               
                plot( Time{UserSelectedFile}(1:Fs{UserSelectedFile}*20), ...
                          Data{UserSelectedFile}(1:Fs{UserSelectedFile}*20) )
                      drawnow()
                      Name=project.ScannedFile{1}(UserSelectedFile);
                      [x,name,ext]=fileparts(Name{1});
                      title([name,ext],'interpreter','none');                 
                      
    xlabel('Time(Sec)'); 
   
    end
        
   %====Der Calculation in Future put in a function=====%
   
   try
       warning off all
       fclose all;
   rmdir([cd,'\System_Results'],'s');
   rmdir([cd,'\Manual_Seg'],'s');
   
   catch
       errordlg(['Could Not Delete ',cd,'\System_Results'],...
           'Error Deleting Folder')
 
       
   end
   
   
    mkdir(cd,'System_Results');
   mkdir(cd,'Manual_Seg');
   
   SystemResultsSource=[path,'\',ListOfTextFile(UserSelectedFile,:)];
   SystemResultsDestination=[cd,'\System_Results'];
   copyfile(SystemResultsSource,SystemResultsDestination,'f'); 
   
   ManualResultsSource=[cd,'\LDC_Callhome\Segmentations\',ListOfTextFile(UserSelectedFile,:)];
   ManualResultsDestination=[cd,'\Manual_Seg\',ListOfTextFile(UserSelectedFile,:)];

   try
      copyfile(ManualResultsSource,ManualResultsDestination,'f') ;
         [DER,ClusterAB]=SegScore2S([cd,'\Manual_Seg'],SystemResultsDestination,...
       0,0,0,1);
   end
   
   try
       for i=1:project.NumberOfLoadedFiles
           if nargin==1
               wavefilepath=project.ScannedFile{1}{i,1};
               try
                       fclose all;
   rmdir([cd,'\System_Results'],'s');
   rmdir([cd,'\Manual_Seg'],'s');
   catch
       errordlg(['Could Not Delete ',cd,'\System_Results'],...
           'Error Deleting Folder')
 
       
               end
   
   try
   
    mkdir(cd,'System_Results');
   mkdir(cd,'Manual_Seg');
   
   SystemResultsSource=[path,'\',ListOfTextFile(i,:)];
   SystemResultsDestination=[cd,'\System_Results'];
   copyfile(SystemResultsSource,SystemResultsDestination,'f'); 
   
   ManualResultsSource=[cd,'\LDC_Callhome\Segmentations\',ListOfTextFile(i,:)];
   ManualResultsDestination=[cd,'\Manual_Seg\',ListOfTextFile(i,:)];

   
      copyfile(ManualResultsSource,ManualResultsDestination,'f') ;
         [DER,ClusterAB]=SegScore2S([cd,'\Manual_Seg'],SystemResultsDestination,...
       0,0,0,1);
   catch
       errordlg('cant creat folder');
   end
   
       
    UserSelected=get(project.ListOfFiles,'value');
            [x,name,ext]=fileparts(ListOfTextFile(...
                i,:));
            path=get(project.SystemParametersEditText23,'string');
            fullpath=[path,'\',name,ext];
           
    %   ListOfTextFile3=ListOfTextFile;
      % [xxx,yyy,zzz]=fileparts(ListOfTextFile3);
       [xxx2,yyy2,zzz2]=fileparts(fullpath);      
      % if nargin==1
   Creat3Wave(project.ScannedFile{1}{i,1},fullpath,[xxx2,'\'],ClusterAB,DER);
       end  
  % catch
     %    errordlg(['Cant Create Wave Files']);
     end
            
            
            
   
    project.DER2=DER;
fprintf(2,['DER Results For: ',ListOfTextFile(UserSelectedFile,:),...
                            ' is: ',num2str(DER),'%%','\n'])

       UserSelectedOffline=get(project.StartRadioButton4,'value');
UserSelectedIncremental=get(project.StartRadioButton3,'value');
       UserSelectedOnLine=get(project.StartRadioButton2,'value');
UserSelectedOnDemand=get(project.StartRadioButton,'value');


%display Results in buttongroup and disable slider
       if UserSelectedOffline==1% || UserSelectedIncremental==1 %delete thia later
                           project.ResultsDerStaticText3=uicontrol('parent',...
            project.ResultsDerButtongroup,...
            'backgroundcolor','w','position',[60 220 90 30],'string',[num2str(DER),'%'],'style','text',...
           'fontsize',12);
       
           project.ResultsDerStaticText4=uicontrol('parent',...
               project.ResultsDerButtongroup,...
               'backgroundcolor','w','position',[0 260 200 20],'string','Diarization Error Is:','style','text',...
               'fontsize',12,'fontweight','bold' );
%            
%            set(project.ResultsOutPutWindowSlider2,...
%                'visible','off');
           
       else if UserSelectedOnDemand==1 %
              project.DER=[project.DER, project.DER2];
            InitialTrainingTime=str2double(get(project.SystemParametersEditText18,'string'));                            
            GetDerTimes=str2double(get(project.SystemParametersEditText19,'string')) ;                 
             ConversationDuration=project.ConversationDuration{UserSelectedFile};
             
               for k=1:length(project.DER{UserSelectedFile})
%                      set(project.ResultsOutPutWindowSlider2,...
%                'visible','off');
             project.ResultsDerStaticText3=uicontrol('parent',...
            project.ResultsDerButtongroup,...
            'backgroundcolor','w','position',[150 240-20*k 55 25],'string',[num2str(project.DER{UserSelectedFile}{k})],...
            'style','text',...
           'fontsize',12);
       
                    project.ResultsDerStaticText4=uicontrol('parent',...
            project.ResultsDerButtongroup,...
            'backgroundcolor','w','position',[10 240-20*k 55 25],'string','0','style','text',...
           'fontsize',12);
       
     
       
       if k~=length(project.DER{UserSelectedFile})+1
           
       if k~= length(project.DER{UserSelectedFile})   
                           project.ResultsDerStaticText5=uicontrol('parent',...
            project.ResultsDerButtongroup,...
            'backgroundcolor','w','position',[80 240-20*k 55 25],'string',num2str(InitialTrainingTime+GetDerTimes*(k-1)),...
            'style','text',...
           'fontsize',12);
       else
               project.ResultsDerStaticText5=uicontrol('parent',...
            project.ResultsDerButtongroup,...
            'backgroundcolor','w','position',[80 240-20*k 55 25],'string',num2str(ConversationDuration(UserSelectedFile)),...
            'style','text',...
           'fontsize',12);
           
       end
       
       
       else
                          project.ResultsDerStaticText5=uicontrol('parent',...
            project.ResultsDerButtongroup,...
            'backgroundcolor','w','position',[80 240-20*k 55 25],'string',num2str(ConversationDuration),...
            'style','text',...
           'fontsize',12);  
       end
               end
       
           else if UserSelectedOnLine==1
                   project.Time2{UserSelectedFile}.StartTime{1}='0';
                   

       if length(project.DER{:})<12
           indexx=length(project.DER{UserSelectedFile});
            set(project.ResultsOutPutWindowSlider2,...
            'visible','off');
       else
           indexx=11;
       end
                   for k=1:indexx

                       
                                   project.ResultsDerStaticText33{k}=uicontrol('parent',...
            project.ResultsDerButtongroup,'tag','DerSlider',...
            'backgroundcolor','w','position',[150 240-20*k 55 25],'string',[num2str(project.DER{UserSelectedFile}{k})],...
            'style','text',...
           'fontsize',12);
                       
                       
                       project.ResultsDerStaticText44{k}=uicontrol('parent',...
                           project.ResultsDerButtongroup,'tag','DerSlider',...
                           'backgroundcolor','w','position',[80 240-20*k 55 25],'string',project.Time2{UserSelectedFile}.EndTime(k),...
                           'style','text',...
                           'fontsize',12);
                       
                       project.ResultsDerStaticText55{k}=uicontrol('parent',...
                           project.ResultsDerButtongroup,'tag','DerSlider',...
                           'backgroundcolor','w','position',[10 240-20*k 55 25],'string',project.Time2{UserSelectedFile}.StartTime(k),'style','text',...
                           'fontsize',12);
                   end
               end
       clear Data Fs Time
           
           end
       end

                        
   catch
     %  errordlg('No Manual Der File C''ant Show Der Results','Error');
              ErrorTitle=uicontrol('parent',...
            project.ResultsDerButtongroup,'string',...
            'There is no Manual Diarization for this File','style','text',...
            'backgroundcolor','w','position',...
            [25,120,150,60],'fontsize',13,'FontWeight','bold');
   end
      
      
 

       

       

          %%
    end
   
        
        
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SliderFunction(varargin)
    project.CurrentSegment=0;   
    
        ScannedFile=varargin{4};
       
         project.indexxx= project.indexxx+1;
          
        
        
        try     
            if  project.indexxx==1; 
set(project.ResultsOutPutWindowSlider,'value', length(ScannedFile)-1);
            end
             set(project.ResultsOutPutWindowSlider,'max',...
            length(ScannedFile)-1,'min',0)          
        catch
            
        end
        
        
        
        
        
        
        
        
        if project.ShowResultsIndex~=0
            SliderIndex=round(get(project.ResultsOutPutWindowSlider,'value'));
            for i=1:36
            delete(project.ResultsPlotScannedText{i})            
            end
     clear project.ResultsPlotScannedText     
            
          for i=1:12 %12 visible rows
      for j=1:3
                 if SliderIndex-12>=0
       project.ResultsPlotScannedText{i+12*(j-1)}=uicontrol('style','text','string',...
           ScannedFile(abs(length(ScannedFile)-SliderIndex)+i-1,j),'fontsize',11,...
           'position',[100*(j-1),240-20*i,40,16],'backgroundcolor','w',...
           'parent',project.ResultsOutPutWindowButtongroup2);
                 else
                     project.ResultsPlotScannedText{i+12*(j-1)}=uicontrol('style','text','string',...
           ScannedFile(abs(length(ScannedFile)-SliderIndex)+i-12,j),'fontsize',11,...
           'position',[100*(j-1),240-20*i,40,16],'backgroundcolor','w',...
           'parent',project.ResultsOutPutWindowButtongroup2);

                 end       
      end
          end
            
  
          
        else
            
        end
             
    end

%==================Set Axis=======================================
    function SetAxisSubFunction(varargin)
Xstart=str2double(get(project.ResultsPlotEditText,'string'));
Xend=str2double(get(project.ResultsPlotEditText2,'string'));
Ystart=str2double(get(project.ResultsPlotEditText3,'string'));
Yend=str2double(get(project.ResultsPlotEditText4,'string'));
axis([Xstart,Xend,Ystart,Yend]);
    end
%================================================================


%==================Play sound=====================================
    function PlaySoundSubFunction(varargin)
         
        StartTime=str2double(get(project.ResultsPlotEditText5,'string'));
        if  StartTime==0
             StartTime= StartTime+0.0001;
        end
        EndTime=str2double(get(project.ResultsPlotEditText6,'string'));
        
        UserSelectedFile=get( project.ListOfFiles,'value');
       [Data,Fs]=wavread(project.ScannedFile{1}{UserSelectedFile});
        
        sound(  Data(StartTime*Fs :EndTime*Fs));



    end
%================================================================

%=================Stop Sound======================================
    function StopPlaySoundSubFunction(varargin)
        clear playsnd
    end
  %================================================================
  
  
   %===============Privious\Next====================================
    function NextSegment(varargin)
        switch varargin{4}
            case 1
                project.CurrentSegment=project.CurrentSegment+1;
         if project.CurrentSegment==13
             project.CurrentSegment=1;
         end
            case 2
                if project.CurrentSegment==0
                    project.CurrentSegment=1;
                end
                
                if project.CurrentSegment==1
                    project.CurrentSegment=13;
                end
                
                project.CurrentSegment=project.CurrentSegment-1;
        end
        LastSegment=str2double(get(project.ResultsPlotScannedText{24},...
            'string'));
   FirstSegment=str2double(get(project.ResultsPlotScannedText{1},...
       'string'));
  if FirstSegment==0
      FirstSegment=FirstSegment+0.001;
  end
  for i=1:size(project.ListOfScannedFile,1)
      [Data{i},Fs{i}]=wavread(project.ListOfScannedFile(i,:));
      Time{i}=(1:length(Data{i}))/Fs{i};
  end
  
  if strcmp(varargin{5},'TimeSequance')
  UserSelected=get(project.ListOfFiles,'value');
  plot(Time{UserSelected}(Fs{UserSelected}*FirstSegment:Fs{UserSelected}*LastSegment),...
      Data{UserSelected}(Fs{UserSelected}*FirstSegment:Fs{UserSelected}*LastSegment))
  xlabel('Time(Sec)')
  Name=project.ScannedFile{1}(UserSelected);
  [x, name, ext]=fileparts(Name{1});
  title([name,ext],'interpreter','none');
  xlim([Time{UserSelected}(FirstSegment*Fs{UserSelected}),...
      Time{UserSelected}(LastSegment*Fs{UserSelected})]);
      
  hold on
  HighLightPlotStartTime=str2double(get(project.ResultsPlotScannedText{project.CurrentSegment},'string'));
   HighLightPlotEndTime=str2double(get(project.ResultsPlotScannedText{project.CurrentSegment+1},'string'));   
    if HighLightPlotStartTime==0
        HighLightPlotStartTime=HighLightPlotStartTime+0.001;
    end
    if project.CurrentSegment==12
        HighLightPlotEndTime=LastSegment;
    end
      plot(Time{UserSelected}(Fs{UserSelected}*HighLightPlotStartTime:Fs{UserSelected}*HighLightPlotEndTime),...
      Data{UserSelected}(Fs{UserSelected}*HighLightPlotStartTime:Fs{UserSelected}*HighLightPlotEndTime),'r');
  hold off
  set(project.ResultsPlotEditText,'string',num2str(HighLightPlotStartTime));
  set(project.ResultsPlotEditText2,'string',num2str(HighLightPlotEndTime));
  set(project.ResultsPlotEditText5,'string',num2str(HighLightPlotStartTime));
  set(project.ResultsPlotEditText6,'string',num2str(HighLightPlotEndTime));
  end
  
  if varargin{4}==1
      
      switch project.CurrentSegment
          case 1
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+12},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+24},'backgroundcolor','r');
                set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+11},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+23},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+35},'backgroundcolor','w');
          otherwise
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment-1},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+11},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+23},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+12},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+24},'backgroundcolor','r');
      end
      
  else
              switch project.CurrentSegment
          case 1
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+1},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+13},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+25},'backgroundcolor','w');
                set(project.ResultsPlotScannedText{...
                  project.CurrentSegment},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+12},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+24},'backgroundcolor','r');
              
                        case 12
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+12},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+24},'backgroundcolor','r');
                set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+1},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+13},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment-11},'backgroundcolor','w');
              
          otherwise
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+12},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+24},'backgroundcolor','r');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+1},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+13},'backgroundcolor','w');
              set(project.ResultsPlotScannedText{...
                  project.CurrentSegment+25},'backgroundcolor','w');
              end          
  end
  
       
                        
    end    
      
  %================================================================
  
  %================Change Display================================
    function ChangeDisplay(varargin)
  %value=1 -Time sequance
  %value=2 -Spectrum
  %value=3 -Spectogram
  
  %==============Read Wave File And Creat Time Axis================
  for i=1:size(project.ListOfScannedFile,1)
[Data{i},Fs{i}]=wavread(  project.ListOfScannedFile(i,:)  );
Time{i}=( 1:length(Data{i}))/Fs{i};
  end
  
  %==============Point Out The Wave File User Has Selected==========
  UserSelectedFile=get(project.ListOfFiles,'value');
  %=====Point Out The Display  User Has Selected(value 1 ,2 ,3)==========
  Stat=get(project.ResultsPlotPopUpMenu,'value');
  switch Stat
   %=================Plot Time=================%
      case 1
            set(project.ResultsPlotButton3,'enable','on');
            set(project.ResultsPlotButton4,'enable','on');
            plot( Time{UserSelectedFile}(1:Fs{UserSelectedFile}*20), ...
            Data{UserSelectedFile}(1:Fs{UserSelectedFile}*20) )
     %=================Plot Spectrum============%
      case 3
            set(project.ResultsPlotButton3,'enable','off');
            set(project.ResultsPlotButton4,'enable','off');
  f=linspace(-Fs{UserSelectedFile},Fs{UserSelectedFile},...
      length(Data{UserSelectedFile}));
  yf=fftshift(abs(fft(Data{UserSelectedFile})))./length(Data{UserSelectedFile});
    Name=project.ScannedFile{1}(UserSelectedFile);
            [x, name, ext]=fileparts(Name{1});              
  plot(f,abs(yf));
title(['Spectrum Of: ',name,ext],'interpreter','none');
  xlim([-Fs{UserSelectedFile}/6,Fs{UserSelectedFile}/6]);
  xlabel('Frequancy in Hz');
  ylabel('Power');
     %=================Plot Spectrogram=========%
      case 2
          screen=get(0,'screensize');
          Spectrogram=figure('color','w','position',[screen(1),screen(2),screen(3)/2,screen(4)/1.2],...
              'resize','on');
         % SpectrogramPlot=axes();
          centerfig(Spectrogram);
         
            set(project.ResultsPlotButton3,'enable','off');
            set(project.ResultsPlotButton4,'enable','off');
            %%%%%%%%%%%%copy%%%%%%%%%%%%%
            LastSegment=str2double(get(project.ResultsPlotScannedText{24},...
                'string'));
            FirstSegment=str2double(get(project.ResultsPlotScannedText{1},...
                'string'));
            if FirstSegment==0
                FirstSegment=FirstSegment+0.001;
            end
            
           % axes(SpectrogramPlot)
            spectrogram(Data{UserSelectedFile}...
                (FirstSegment*Fs{UserSelectedFile}:...
                LastSegment*Fs{UserSelectedFile}),...
            32,30,32,Fs{UserSelectedFile},'yaxis');
            
            colorbar('ytick',[-140,-100,-60],...
                'yticklabel',{'Silence','None Voice','Voice'});
            Name=project.ScannedFile{1}(UserSelectedFile);
            [x, name, ext]=fileparts(Name{1});
               title(['Spectrogram Of: ',name,ext],'interpreter','none');
             
             axis square
  xlabel('Time (Sec)');
  ylabel('Frequancy in Hz');
  
  
  
            SpectrogramNextButton= uicontrol('style','pushbutton','string',...
     'Next Segment ------>>','position',[390 15 160 30],...
     'fontweight','bold','parent',Spectrogram,...
     'callback',{@NextSegment,'project',1,'Spectrogram'});  
 
        SpectrogramPreviousButton=uicontrol('style','pushbutton','string',...
     '<<------  Previous Segment','position',[80 15 160 30],...
     'fontweight','bold','parent',Spectrogram,...
     'callback',{@NextSegment,'project',2,'Spectrogram'});  
  end
    end

  %================================================================
  function DerSlider(varargin)
  %project=varargin{3};
  indexx=11;
  j=length(varargin{3}.DER{1}(:))-round(get(varargin{1},'value'))+1;
  UserSelectedFile=get(varargin{3}.ListOfFiles,'value');
  delete(findobj(gcf,'tag','DerSlider'));
  try    
        for k=1:indexx

                       
                                   varargin{3}.ResultsDerStaticText33{k}=uicontrol('parent',...
            varargin{3}.ResultsDerButtongroup,'tag','DerSlider',...
            'backgroundcolor','w','position',[150 240-20*k 55 25],'string',[num2str(varargin{3}.DER{UserSelectedFile}{j})],...
            'style','text',...
           'fontsize',12);
                       
                       
                       varargin{3}.ResultsDerStaticText44{k}=uicontrol('parent',...
                           varargin{3}.ResultsDerButtongroup,'tag','DerSlider',...
                           'backgroundcolor','w','position',[80 240-20*k 55 25],'string',varargin{3}.Time2{UserSelectedFile}.EndTime(j),...
                           'style','text',...
                           'fontsize',12);
                       if j~=1
                           string=varargin{3}.Time2{UserSelectedFile}.StartTime(j);
                       else
                           string='0';
                       end
                       varargin{3}.ResultsDerStaticText55{k}=uicontrol('parent',...
                           varargin{3}.ResultsDerButtongroup,'tag','DerSlider',...
                           'backgroundcolor','w','position',[10 240-20*k 55 25],'string',string,'style','text',...
                           'fontsize',12);
                       j=j+1;
                   end 
  catch
  end
      
      
  end
    %================================================================




  %================================================================
  
    function DerFunction(varargin)
     
        record;
       
%         set(project.MainWindow,'Visible','off');
%        SegScore2S('C:\Users\Lampel_Acer\Desktop\DS_From_Oren\Out',...
%                                            'C:\Users\Lampel_Acer\Desktop\DS_From_Oren\SDAIS',1,1,1,2) 
        


       
           
    end

        
end




