function img = rsos(img_mc)
    img = squeeze(sum(img_mc.^2, ndims(img_mc)));
end