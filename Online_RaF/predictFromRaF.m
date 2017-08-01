function [forestPredicts,treePredictions] = predictFromRaF(RaF,X,UseParallel)
%predictFromRaF predicts class using trained forest
%
% [prediction, countsLeaf] = predictFromRaF(RaF,X)
%
% Inputs:                 RaF = output from genRaF.  This is a structure
%                               with a field Trees, giving a cell array of
%                               tree structures, and options which is an
%                               object of type optionsClassRaF
%                           X = input features, each row should be a 
%                               seperate data point
% Outputs:  forestPredictions = Vector of numeric predictions corresponding to
%                               the class label
%                 forestProbs = Assigned probability to each class
%             treePredictions = Individual tree predictions
%    cumulativeForestPredicts = Predictions of forest cumaltive with adding
%                               trees
%
% 14/06/15

nTrees = numel(RaF.Trees);
treePredictions = NaN(size(X,1),nTrees);
if ~exist('UseParallel','var') 
    UseParallel=0;
end
if UseParallel
    parfor n=1:nTrees
    treePredictions(:,n) = predictFromObliqueTree(RaF.Trees{n},X);
    end
else
for n=1:nTrees
    treePredictions(:,n) = predictFromObliqueTree(RaF.Trees{n},X);
end

end
        [nSam,~]=size(treePredictions);
        forestPredicts=zeros(nSam,1);
        uY=unique(treePredictions);
        N=numel(uY);
 for i=1:nSam
     count=zeros(N,1);
     for j=1:N
     count(j)=numel(find(treePredictions(i,:)==uY(j)));
    
     end
     [~,idx]=max(count);
     forestPredicts(i)=uY(idx);
 end
end