function [score,idx]=get_RF_score(model,patterns)
[~,treePredictions] = predictFromRaF(model,patterns,0);
nSam=size(patterns,1);
nTrees=size(treePredictions,2);
score=zeros(nSam,1);
for i=1:nSam
 score(i)=numel(find(treePredictions(i,:)==1))/nTrees ;
end
[~,idx_temp]=max(score);
idx=find(treePredictions(idx_temp,:)~=1);
end