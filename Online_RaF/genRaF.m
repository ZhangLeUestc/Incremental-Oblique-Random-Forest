function RaF = genRaF(XTrain,YTrain,nTrees,nFeatoSample,UseParallel,Bagging)
% Please convert the label into -1:1.
% rand('state',0)
% randn('state',0)
[N,D] = size(XTrain);

nOut = nargout;


forest = cell(1,nTrees);


if ~exist('UseParallel','var') 
    fprintf('do not specify the option for parallel traning,use default mode(non-parallel)\n ')
    UseParallel=0;
end
if ~exist('nFeatoSample','var') 
    fprintf('do not specify the number of features used in each node, use default mode(square root)\n ')
    nFeatoSample=round(sqrt(D));
end
if ~exist('nTrees','var') 
    fprintf('do not specify the number of trees, use default mode(200)\n ')
    nTrees=200;
end
if ~exist('Bagging','var') 
    fprintf('do not specify the option for bagging, use default mode(non-bagging)\n ')
    Bagging=0;
end
if UseParallel == true    
    parfor nT = 1:nTrees
              
        tree = genObliqueTree(XTrain,YTrain,nFeatoSample,Bagging);
        
            forest{nT} = tree;
               
             
    end
else
    for nT = 1:nTrees
      %  tree = genObliqueTree(XTrain,YTrain,optionsFor,iFeatureNum,N);  
        tree = genObliqueTree(XTrain,YTrain,nFeatoSample,Bagging);
        
            forest{nT} = tree;
           
       
    end
end

RaF.Trees = forest;





end

function tree = genObliqueTree(XTrain,YTrain,nFeatoSample,Bagging)
% A sub-function is used so that it can be shared between the for and
% parfor loops
N=size(XTrain,1);
if Bagging
    iTrainThis = datasample(1:N,N);
else
    iTrainThis = 1:N;
end

XTrainBag = XTrain(iTrainThis,:);
YTrainBag = YTrain(iTrainThis,:);
tree = growObliqueTree(XTrainBag,YTrainBag,nFeatoSample,0);
end




