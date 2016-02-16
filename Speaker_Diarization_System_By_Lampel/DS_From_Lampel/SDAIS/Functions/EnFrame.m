function f=EnFrame(x,win,inc)
%EnFrame split signal up into (overlapping) frames: one per row. F=(X,win,inc)
%
%	F = EnFrame(X,win) splits the vector X(:) up into
%	frames. Each frame is of length win and occupies
%	one row of the output matrix. The last few frames of X
%	will be ignored if its length is not divisible by win.
%	It is an error if X is shorter than win.
%
%	F = EnFrame(X,win,inc) has frames beginning at increments of inc
%	The centre of frame I is X((I-1)*inc+(win+1)/2) for I=1,2,...
%	The number of frames is fix((length(X)-win+inc)/inc)
%
%	F = EnFrame(X,window) or EnFrame(X,window,inc) multiplies
%	each frame by window(:)


nx=length(x(:));
nwin=length(win);
if (nwin == 1)
   len = win;
else
   len = nwin;
end
if (nargin < 3)
   inc = len;
end
nf = fix((nx-len+inc)/inc);
f=zeros(nf,len);
indf= inc*(0:(nf-1)).';
inds = (1:len);
f(:) = x(indf(:,ones(1,len))+inds(ones(nf,1),:));
if (nwin > 1)
    w = win(:)';
    f = f .* w(ones(nf,1),:);
end


