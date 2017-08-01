function param = estwarp_condens(frm, tmpl, param, opt, model, frameNum)

n = opt.numsample;
sz = opt.tmplsize ;
N = sz(1)*sz(2);
sz1=size(tmpl.mean);

param.param = repmat(affparam2geom(param.est(:)), [1,n]);

param.param = param.param + randn(6,n).*repmat(opt.affsig(:),[1,n]);

wimgs = warpimg(frm, affparam2mat(param.param), sz);
data=zeros(n,sz1(1)*sz1(2)*sz1(3));
for i=1:opt.numsample
 wimg = double(fhog(single(wimgs(:,:,i)) , 4, 9));
 wimg(:,:,end) = [];  


 data(i,:)=wimg(:);
end


[confidence,idx_temp]=get_RF_score(model,data);
%disp(max(confidence));
if max(confidence) < opt.updateThres || frameNum - param.lastUpdate >= 50
    param.update = true;
    param.lastUpdate = frameNum;
else
    param.update = false;
end
if max(confidence)<opt.retrainThres
    param.retrain=1;
else 
    param.retrain=0;
end
confidence = confidence - min(confidence);
param.conf = exp(double(confidence) ./opt.condenssig)';
param.conf = param.conf ./ sum(param.conf);
[maxprob,maxidx] = max(param.conf);
if maxprob == 0 || isnan(maxprob)
    error('overflow!');
end
param.est = affparam2mat(param.param(:,maxidx));
% param.wimg = reshape(data(:,maxidx), sz);
param.idx=idx_temp;
if exist('coef', 'var')
    param.bestCoef = coef(:,maxidx);
end