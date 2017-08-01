function RaF = UpdateRaF(XTrain,YTrain,nFeatoSample,RaF,idx)
% Please convert the label into 1:K.
[N,D] = size(XTrain);

rand('state',0)
randn('state',0)
nTrees=numel(idx);
model=RaF.Trees;

    for nT = 1:nTrees
      tree=model{idx(nT)}; 
      tree = UpdateObliqueTree(XTrain,YTrain,nFeatoSample,tree,0);
      model{idx(nT)} = tree;
        
    end


RaF.Trees = model;
end






