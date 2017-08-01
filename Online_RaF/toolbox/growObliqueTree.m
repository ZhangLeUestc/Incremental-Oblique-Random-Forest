function tree = growObliqueTree(XTrain,YTrain,nFeatoSample,depth)
% First do checks for whether we should immediately terminate
[N,D] = size(XTrain);
bStop = (N<2) || (depth>500)||numel(unique(YTrain))==1;
if bStop
    if depth>500
        fprintf('tree is too deep\n')
    end
    tree = setupLeaf(YTrain);
   if ~isfield(tree,'data')
    tree.data=XTrain;
    tree.label=YTrain;
   else
   data_temp=[tree.data;XTrain];
   tree.label=[tree.label;YTrain];
   tree.data=data_temp;
   clear data_temp
   end
  return
end
nu=100;
idx_temp=randperm(D);
iIn=idx_temp(1:nFeatoSample);
[w,gamma,EE_inverse,EDE, ~, ~, ~, ~]=psvm(XTrain(:,iIn),YTrain,0,nu,0,0);
tree.iIn=iIn;
tree.w=w;
tree.gamma=gamma;
tree.EE_inverse=EE_inverse;
tree.EDE=EDE;
X_temp=sign(XTrain(:,iIn)*w-gamma);
if numel(unique(X_temp(X_temp~=0)))<=1
 tree = setupLeaf(YTrain);
 tree.label=YTrain;
 tree.data=XTrain;
  return 
end 
bLessThanTrain = X_temp<=0;
treeLeft = growObliqueTree(XTrain(bLessThanTrain,:),YTrain(bLessThanTrain,:),nFeatoSample,depth+1);
treeRight = growObliqueTree(XTrain(~bLessThanTrain,:),YTrain(~bLessThanTrain,:),nFeatoSample,depth+1);
tree.bLeaf = false;
tree.lessthanChild = treeLeft;
tree.greaterthanChild = treeRight;

end

function tree = setupLeaf(YTrain)
% Update tree struct to make node a leaf
uY=unique(YTrain);
tree.bLeaf = true;
if numel(uY)>1
flag=YTrain==uY(1);
tree.labelClassId =(sum(flag==1)>sum(flag==0))*uY(1)+(sum(flag==1)<=sum(flag==0))*uY(2);
else
tree.labelClassId=uY(1);
end
end



