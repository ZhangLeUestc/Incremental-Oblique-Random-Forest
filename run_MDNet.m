
function results=run_MDNet(seq, res_path, bSaveImage)


close all
idx=strfind(seq.name,'_');
idx=idx(end);
name=seq.name(1:idx-1);

conf = genConfig('otb',name);
% conf = genConfig('vot2015','ball1');

switch(conf.dataset)
    case 'otb'
        net = fullfile('models','mdnet_vot-otb.mat');
    case 'vot2014'
        net = fullfile('models','mdnet_otb-vot14.mat');
    case 'vot2015'
        net = fullfile('models','mdnet_otb-vot15.mat');
end

[result,fps] = mdnet_run(conf.imgList, conf.gt(1,:),net,seq);
results.res = result;
results.len = seq.endFrame-seq.startFrame+1;
results.startFrame = seq.startFrame;
results.endFrame=seq.endFrame;
results.type = 'rect';
results.fps=fps;

end

% 
% function results=run_MEEM(seq, res_path, bSaveImage)
% 
% close all;
% results = MEEMTrack(seq.path, seq.ext, 0, seq.init_rect, seq.startFrame,seq.endFrame);
% end