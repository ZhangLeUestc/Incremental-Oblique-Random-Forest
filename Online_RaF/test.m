clear
clc

% load mushroom
% dataY=2*dataY-3;

load magic
nFea=size(dataX,2);
nSam=size(dataY,1);
idx=randperm(nSam);
trainX=dataX(idx(1:round(0.7*nSam)),:);
trainY=dataY(idx(1:round(0.7*nSam)));
testX=dataX(idx(round(0.7*nSam)+1:end),:);
testY=dataY(idx(round(0.7*nSam)+1:end));
model=genRaF(trainX,trainY,200,round(sqrt(nFea)),0,0);
Y=predictFromRaF(model,testX);
acc_batch=length(find(Y==testY))/numel(testY)
model=ObliqueRF_train(trainX,trainY,'ntrees',200,'nvartosample',round(sqrt(nFea)),'oblique',1);
Y=ObliqueRF_predict(testX,model);
acc_batch1=length(find(Y==testY))/numel(testY)
N=500;
nTrain=numel(trainY);
idx=randperm(nTrain);
TrainX=trainX(idx(1:N),:);
TrainY=trainY(idx(1:N));
model1=genRaF(TrainX,TrainY,200,round(sqrt(nFea)),0,0);
Y=predictFromRaF(model1,testX);
acc=length(find(Y==testY))/numel(testY);
for i=N+1:N:nTrain
    i
    if i+N-1<=nTrain
    X=trainX(idx(i:i+N-1),:);
    Y=trainY(idx(i:i+N-1));
    else
     X=trainX(idx(i:nTrain),:);
    Y=trainY(idx(i:nTrain));
    end
    model1 = UpdateRaF(X,Y,model1,0);
    Y=predictFromRaF(model1,testX); 
    acc_temp=length(find(Y==testY))/numel(testY);
    acc=[acc,acc_temp];
    
    
    
end