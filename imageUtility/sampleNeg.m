function negTmpl = sampleNeg(frame, param0, sz, num, opt, width)
    c = 1;
    geom = affparam2geom(param0);
    h = round(sz(2)*geom(3));
    w = round(sz(1)*geom(3)*geom(5));
    
    for i = 1 : num
        a = randn() * h / width;
        b = randn() * w / width;
        while abs(a) < h / 4 && abs(b) < w / 4
            a = randn() * h / width;
            b = randn() * w / width;
        end
        aff = opt.affsig .* randn(1, 6);
        aff(1) = a;
        aff(2) = b;
        if size(geom,1)==6
            geom=geom';
        end
        temp = warpimg(frame, affparam2mat(geom + [a b 0 0 0 0]), sz);
        temp= double(fhog(single( temp) , 4, 9));
        temp(:,:,end) = [];
        negTmpl(:, c) = temp(:);
        c = c + 1;
    end
end