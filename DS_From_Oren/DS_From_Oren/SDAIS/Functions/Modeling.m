function [Models Weights]= Modeling( PM, Models, Type, Opts, Verbose )

% USAGE : RArgs.Models = Modeling( PM, Models, Type, Opts)
%
% INPUT :   PM - preModels
%           Models - previously trained models (initial conditions)
%           Type - model type, som, gmm
%
% OUTPUT : Models

if(Verbose == 1)
    fprintf('\tModeling - %s', Type);
    tic;
end


switch Type
    case 'som'
        
        if(isempty(Models))
            clear Models;     
            
%             load('SDSUBM/SOM_UBM.mat');
            
            for i = 1 : size(PM,2)
                
                % Set number of iterations
                IK=size(PM(i).PM,1);
                m=size(PM(i).PM,2);
                
                % Choose the number of nuerons
                M1=Opts.SomLen; M2=Opts.SomWid; M=M1*M2;
                
                % Make a matrix of neurons coordinates
                [X,Y]=meshgrid(1:M1,1:M2); P=[X(:)';Y(:)'];
                
                % Initial values
                W=rand(m,M);             
                
                %First stage of training
                [Models(i).Model Weights(i).Weights]= ...
                   Kohonen(PM(i).PM',...
                  W, P, IK, 0.8 ,0.1 , 10 , 1 );
                
                % Second stage of training
                [Models(i).Model Weights(i).Weights]= Kohonen(PM(i).PM',...
                    Models(i).Model, P, IK, 0.1 , 0.0 , 1.0 , 0.1 );
            end
        else
            for i = 1 : size(PM,2)
                % Set number of iterations
                IK=size(PM(i).PM,1);
                m=size(PM(i).PM,2);
                
                % Choose the number of nuerons
                M1=Opts.SomLen; M2=Opts.SomWid; M=M1*M2;
                
                % Make a matrix of neurons coordinates
                [X,Y]=meshgrid(1:M1,1:M2); P=[X(:)';Y(:)'];
                
                [Models(i).Model Weights(i).Weights]= Kohonen(PM(i).PM',...
                    Models(i).Model, P, IK, 0.1 , 0.0 , 1.0 , 0.1 );
            end
        end
        
    case 'gmm'
        load('SDSUBM/GMM_UBM')
        if(isempty(Models))
            clear Models;
           
            for i = 1 : size(PM,2)
                [Models(i).Prior Models(i).Model Models(i).Cov] = ...
                    EmGmm(PM(i).PM', UBM_S.Prior, UBM_S.Mean, UBM_S.Cov, 1, [16 16 16], 0, 0, 0);
            end
            
        else
            
            for i = 1 : size(PM,2)
                [Models(i).Prior Models(i).Model Models(i).Cov] = ...
                    EmGmm(PM(i).PM', Models(i).Prior, Models(i).Model, Models(i).Cov, 1, [16 16 16], 0, 0, 0);
            end
            
        end
            
end

if(Verbose == 1)
    Time = toc;
    fprintf(' - %3.2f Sec\n',Time);
end
