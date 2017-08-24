
function results=run_RaF(seq, res_path, bSaveImage)
close all
    rand('state',0);  randn('state',0);
    if isfield(seq, 'opt')
        opt = seq.opt;
        paraConfig_RaF
    else
        paraConfig_RaF
    end
    rect=seq.init_rect;
    p = [rect(1)+rect(3)/2, rect(2)+rect(4)/2, rect(3), rect(4), 0];
    frame = imread(seq.s_frames{1});
    if size(frame,3)==3
        frame = double(rgb2gray(frame));
    end
    
    scaleHeight = size(frame, 1) / opt.normalHeight;
    scaleWidth = size(frame, 2) / opt.normalWidth;
    p(1) = p(1) / scaleWidth;
    p(3) = p(3) / scaleWidth;
    p(2) = p(2) / scaleHeight;
    p(4) = p(4) / scaleHeight;
    frame = imresize(frame, [opt.normalHeight, opt.normalWidth]);
    frame = double(frame) / 255;
    
    
    paramOld = [p(1), p(2), p(3)/opt.tmplsize(2), p(5), p(4) /p(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
    param0 = affparam2mat(paramOld);
    
    
    if ~exist('opt','var')  opt = [];  end
    reportRes = [];
   % save temp frame param0 opt
    tmpl.mean = warpimg(frame, param0, opt.tmplsize);
    tmpl.mean = double(fhog(single(tmpl.mean) , 4, 9));
    tmpl.mean(:,:,end) = [];
    tmpl.basis = [];
    % Sample 10 positive templates for initialization
    for i = 1 : opt.maxbasis / 10
        tmpl.basis(:, (i - 1) * 10 + 1 : i * 10) = samplePos(frame, param0, opt.tmplsize);
    end
    % Sample 100 negative templates for initialization
    p0 = paramOld(5);
    tmpl.basis(:, opt.maxbasis + 1 : 100 + opt.maxbasis) = sampleNeg(frame, param0, opt.tmplsize, 100, opt, 8);

    param.est = param0;
    param.lastUpdate = 1;

    wimgs = [];

%    draw initial track window
 %  drawopt = drawtrackresult([], 0, frame, tmpl, param, []);
% drawopt = drawtrackresult([], 0, frame, param, []);
   %drawopt = drawtrackresult([], 1, frame, opt.tmplsize, param.est');
   drawopt.showcondens = 0;  drawopt.thcondens = 1/opt.numsample;
   if (bSaveImage)
       imwrite(frame2im(getframe(gcf)),sprintf('%s0000.jpg',res_path));    
   end
    
    % track the sequence from frame 2 onward
  %  duration = 0; tic;
    if (exist('dispstr','var'))  dispstr='';  end
    L = [ones(opt.maxbasis, 1); (-1) * ones(100, 1)];
    nTrees=100;
    nFeatoSample=round(sqrt(size(tmpl.basis,1)));
    RaF_tracker = genRaF(tmpl.basis', L,nTrees,nFeatoSample,0,0);
    duration = 0; tic;
    for f = 1:size(seq.s_frames,1)  
      frame = imread(seq.s_frames{f});
      if size(frame,3)==3
        frame = double(rgb2gray(frame));
      end  
      frame = imresize(frame, [opt.normalHeight, opt.normalWidth]);
      frame = double(frame) / 255;

      % do tracking
       param = estwarp_condens(frame, tmpl, param, opt, RaF_tracker, f);

      % do update

      temp = warpimg(frame, param.est', opt.tmplsize);
      temp= double(fhog(single( temp) , 4, 9));
      temp(:,:,end) = [];
      if param.retrain
          nFea=size(temp,1)*size(temp,2)*size(temp,3);
          pos=zeros(nFea,opt.maxbasis/5);
           for i = 1 : opt.maxbasis / 50
            pos(:, (i - 1) * 10 + 1 : i * 10) = samplePos(frame, param.est', opt.tmplsize);
           end
          pos=[pos,temp(:)];
          % Sample two set of negative samples at different range.
          neg = sampleNeg(frame, param.est', opt.tmplsize, 10, opt, 8);
          neg = [neg sampleNeg(frame, param.est', opt.tmplsize, 10, opt, 4)];
          data2update=[pos neg]';
          label2update=[ones(opt.maxbasis/5+ 1, 1); -1*ones(20, 1)];
          RaF_tracker = genRaF(data2update, label2update,nTrees,nFeatoSample,0,0);
      else if  param.update
          nFea=size(temp,1)*size(temp,2)*size(temp,3);
          pos=zeros(nFea,opt.maxbasis/5);
          % for i = 1 : opt.maxbasis / 50
            for i = 1 : 3
            pos(:, (i - 1) * 10 + 1 : i * 10) = samplePos(frame, param.est', opt.tmplsize);
           end
          pos=[pos,temp(:)];
          % Sample two set of negative samples at different range.
          neg = sampleNeg(frame, param.est', opt.tmplsize, 15, opt, 8);
          neg = [neg sampleNeg(frame, param.est', opt.tmplsize, 15, opt, 4)];
          data2update=[pos neg]';
          label2update=[ones(30 + 1, 1); -1*ones(30, 1)];
         
          RaF_tracker= UpdateRaF(data2update,label2update,nFeatoSample,RaF_tracker,param.idx);
          end
      end

      duration = duration + toc;
      
      res = affparam2geom(param.est);
      p(1) = round(res(1));
      p(2) = round(res(2)); 
      p(3) = round(res(3) * opt.tmplsize(2));
      p(4) = round(res(5) * (opt.tmplsize(1) / opt.tmplsize(2)) * p(3));
      p(5) = res(4);
      paramOld1 = [p(1), p(2), p(3)/opt.tmplsize(2), p(5), p(4) /p(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
      p(1) = p(1) * scaleWidth;
      p(3) = p(3) * scaleWidth;
      p(2) = p(2) * scaleHeight;
      p(4) = p(4) * scaleHeight;
      paramOld = [p(1), p(2), p(3)/opt.tmplsize(2), p(5), p(4) /p(3) / (opt.tmplsize(1) / opt.tmplsize(2)), 0];
      
      reportRes = [reportRes;  affparam2mat(paramOld)];
      
   
     % drawopt = drawtrackresult(drawopt, f, frame, tmpl, param, []);
     %   drawopt = drawtrackresult(drawopt, f, frame, opt.tmplsize, affparam2mat(paramOld1)');
      if (bSaveImage)
          imwrite(frame2im(getframe(gcf)),sprintf('%s/%04d.jpg',res_path,f));
      end
      tic;
    end
    
    fprintf('%d frames took %.3f seconds : %.3fps\n',f,duration,f/duration);
    results.res=reportRes;
    results.type='ivtAff';
    results.tmplsize = opt.tmplsize;
    results.fps = f/duration;
end
