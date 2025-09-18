function img = rsos(img_mc)
    img = squeeze(sqrt(sum(abs(img_mc).^2, ndims(img_mc))));
end