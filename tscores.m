function T = tscores(img, GLM, c)
% TSCORES compute t-scores for given fMRI times series and GLM
%
% Inputs:
% img: fMRI data of size (..., Nt)
% GLM: general linear model matrix, where each column is a linear regressor
% c: one-hot contrast vector, specifying which linear regressor to compute
% t-scores for
%
% Outputs:
% T: t-score image of original image spatial size

    sz = size(img);
    Nt = sz(end);

    img_vec = reshape(abs(img), [], Nt);
    beta_img = img_vec * pinv(GLM).';
    r_img = img_vec - beta_img * GLM.';
    nu = size(GLM,1) - rank(GLM);
    var_cbeta = sum(r_img.^2, 2) / nu * (c.' / (GLM.' * GLM) * c);
    T_vec = (beta_img * c) ./ (sqrt(var_cbeta) + eps);

    T = reshape(T_vec, sz(1:end-1));
end