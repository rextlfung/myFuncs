function img = coil_combine(img_mc, smaps)
    num = sum(conj(smaps) .* img_mc, ndims(img_mc));
    den = sum(abs2(smaps), ndims(img_mc)) + eps;
    img = squeeze(num ./ den);
end