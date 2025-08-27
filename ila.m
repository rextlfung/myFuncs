%% Convenience function plotting k-space
% ila stands for "im log abs"
function ila(ksp)
    im(log(abs(ksp) + eps))
end