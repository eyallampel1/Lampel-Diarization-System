[FileName,PathName] = uigetfile('*.cpp');
functionName = ['''' PathName FileName ''''];
eval(['mex -I''C:\Program Files\Intel\ComposerXE-2011\mkl\include\'' -L''C:\Program Files\Intel\ComposerXE-2011\mkl\tools\builder'' -lmkl_custom ' functionName]);

