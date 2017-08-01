% function [w,gamma,EE_inverse,EDE]=psvm(A,D,nu)
% [m,n]=size(A);
% e=ones(m,1);
% H=D*[A,-e];
% r=sum(H)';
% r=(speye(n+1)/nu+H'*H)\r;
% u=nu*(1-(H*r));
% s=D*u;
% w=(s'*A)';
% gamma=-sum(s);
% EE_inverse=(speye(n+1)/nu+H'*H)\speye(n+1);
% EDE=H'*D*e;
% 
% end



function [w,gamma,EE_inverse,EDE, trainCorr, testCorr, cpu_time, nu]=psvm(A,d,k,nu,output,bal)
% version 1.1
% last revision: 01/24/03
%===============================================================================
% Usage:    [w,gamma,trainCorr, testCorr,cpu_time,nu]=psvm(A,d,k,nu,output,bal)
%
% A and d are both required, everything else has a default
% An example: [w gamma train test time nu] = psvm(A,d,10);
%
% Input:
% A is a matrix containing m data in n dimensions each.
% d is a m dimensional vector of 1's or -1's containing
% the corresponding labels for each example in A.
% k is k-fold for correctness purpose
% nu - the weighting factor.
%                       -1 - easy estimation
%                       0  - hard estimation
%                       any other value - used as nu by the algorithm
%                       default - 0
% output - indicates whether you want output
%
% If the input parameter bal is 1
% the algorithm weighs the classes depending on the
% number of points in each class and balance them. 
% It is useful when  the number of point in each class
% is very unbalanced.
%
% Output:
% w,gamma are the values defining the separating
% Hyperplane w'x-gamma=0 such that:
%
% w'x-gamma>0 => x belongs to A+
% w'x-gamma<0  => x belongs to A-
% w'x-gamma=0 => x can belongs to both classes
% nu - the estimated or specified value of nu
%
% For details refer to the paper:
% "Proximal Support Vector Machine Classifiers"
% available at: www.cs.wisc.edu/~gfung
% For questions or suggestions, please email:
% Glenn Fung, gfung@cs.wisc.edu
% Sept 2001.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
A=full(A);
[m,n]=size(A);
r=randperm(size(d,1));d=d(r,:);A=A(r,:);    % random permutation

%move one point in A a little if perfectly balanced
AA=A;dd=d;
ma=A(find(d==1),:); mb=A(find(d==-1),:);
[s1 s2]=size(ma);
     c1=sum(ma)/s1;
[s1 s2]=size(mb);
     c2=sum(mb)/s1;
% if (c1==c2)
%      nu=1;
%      A(3,:)=A(3,:)+0.01*norm(A(3,:)-c1,inf)*ones(1,n);
% end

% default values for input parameters
if nargin<6
   bal=0;
end 

if nargin<5
   output=0;
end

if (nargin<4)
    nu=0;  % default is hard estimation
end

if (nargin<3)
     k=0;
end

    [H,v]=HV(A,d,bal);  % calculate H and v

trainCorr = 0;
testCorr = 0;

if (nu==0)
  nu = EstNuLong(H,d,m);
elseif nu==-1  % easy estimation
  nu = EstNuShort(H,d);
end

% if k=0 no correctness is calculated, just run the algorithm
if k==0
  [w, gamma] = core(H,v,nu,n);
 % EE_inverse=(speye(n+1)/nu+H'*H)\speye(n+1);
 EE_inverse=pinv(speye(n+1)/nu+H'*H);
  EDE=v;
cpu_time = toc;
  return
end

%if k==1 only training set correctness is calculated
if k==1
  [w, gamma] = core(H,v,nu,n);
  trainCorr = correctness(AA,dd,w,gamma);
  cpu_time = toc;
  if output == 1
  fprintf(1,'\nTraining set correctness: %3.2f%% \n',trainCorr);
  fprintf(1,'\nElapse time: %10.2f\n',toc);
  end
  return
end

  [sm sn]=size(A);
accuIter = 0;
lastToc=0;    % used for calculating time
indx = [0:k];
indx = floor(sm*indx/k);    %last row numbers for all 'segments'
% split trainining set from test set
tic;
for i = 1:k
Ctest = []; dtest = [];Ctrain = []; dtrain = [];

Ctest = A((indx(i)+1:indx(i+1)),:);
dtest = d(indx(i)+1:indx(i+1));

Ctrain = A(1:indx(i),:);
Ctrain = [Ctrain;A(indx(i+1)+1:sm,:)];
dtrain = [d(1:indx(i));d(indx(i+1)+1:sm,:)];

   [H, v] = HV(Ctrain,dtrain,bal);
   [w, gamma] = core(H,v,nu,n);

   tmpTrainCorr = correctness(Ctrain,dtrain,w,gamma);
   trainCorr = trainCorr + tmpTrainCorr;
   tmpTestCorr = correctness(Ctest,dtest,w,gamma);
   testCorr = testCorr + tmpTestCorr;

 if output==1
 fprintf(1,'________________________________________________\n');
 fprintf(1,'Fold %d\n',i);
 fprintf(1,'Training set correctness: %3.2f%%\n',tmpTrainCorr);
 fprintf(1,'Testing set correctness: %3.2f%%\n',tmpTestCorr);    
 fprintf(1,'Elapse time: %10.2f\n',toc);
 end

 end % 

 trainCorr = trainCorr/k;
 testCorr = testCorr/k;
 cpu_time = toc/k;

if output == 1
  fprintf(1,'___________________________________________________\n');
  fprintf(1,'\nTraining set correctness: %3.2f%% \n',trainCorr);
  fprintf(1,'\nTesting set correctness: %3.2f%% \n',testCorr);
  fprintf(1,'\nAverage CPU time is: %3.2f \n',cpu_time);
end

%y=spdiags(d,0,m,m)*((A*w-gamma)-ones(m,1));

return

%%%%%%%%%%%%%%%% core function to calcuate w and gamma %%%%%%%%
function [w, gamma]=core(H,v,nu,n)

v=(speye(n+1)/nu+H'*H)\v;
w=v(1:n);gamma=v(n+1);

return

%%%%%%%%%%%%%%% correctness calculation %%%%%%%%%%%%%%%%%%%%
function corr = correctness(AA,dd,w,gamma)

p=sign(AA*w-gamma);
corr=length(find(p==dd))/size(AA,1)*100;

return

%%%%%%%%%%%%%       EstNuLong     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use to estimate nu
function lamda=EstNuLong(H,d,m)

if m<201
H2=H;d2=d;
else
r=rand(m,1);
 [s1,s2]=sort(r);
 H2=H(s2(1:200),:);
 d2=d(s2(1:200));
end

lamda=1;
[vu,u]=eig(H2*H2');u=diag(u);p=length(u);
yt=d2'*vu;  
lamdaO=lamda+1;

cnt=0;
while (abs(lamdaO-lamda)>10e-4)&(cnt<100)
   cnt=cnt+1;
   nu1=0;pr=0;ee=0;waw=0;
   lamdaO=lamda;   
   for i=1:p
     nu1= nu1 + lamda/(u(i)+lamda);
     pr= pr + u(i)/(u(i)+lamda)^2;
     ee= ee + u(i)*yt(i)^2/(u(i)+lamda)^3;
     waw= waw + lamda^2*yt(i)^2/(u(i)+lamda)^2;
   end
   lamda=nu1*ee/(pr*waw);
end

value=lamda;
if cnt==100
    value=1;
end

%%%%%%%%%%%%%%%%%EstNuShort%%%%%%%%%%%%%%%%%%%%%%%

% easy way to estimate nu if not specified by the user
function value = EstNuShort(C,d)

value = 1/(sum(sum(C.^2))/size(C,2));
return

%%% function to calculate H and v %%%%%%%%%%%%%
function [H,v]=HV(A,d,bal);

[m,n]=size(A);e=ones(m,1);

if (bal==0)
     H=[A -e];
     
     v=(d'*H)';
else
     H=[A -e];
     mm=e;
     m1=find(d==-1);
     mm(m1)=(1/length(m1));
     m2=find(d==1);
     mm(m2)=(1/length(m2));
     mm=sqrt(mm);
     N=spdiags(mm,0,m,m);
     H=N*H;
    %keyboard
    v=(d'*N*H)';
end








