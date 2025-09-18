function qt(t, bg, tlim, cmap, plotname)
% qt(t, bg, tlim, cmap)
% QT Quick T-scores visualizer
% Overlays t-scores on some background image bg
    if nargin < 5
        plotname = 'Default title';
    end

    ov = overlayview;
    ov.addlayer(bg./max(bg(:)), 'name', 'background');
    min_t = max(min(tlim), min(t(:)));
    max_t = min(max(tlim), max(t(:)));
    ov.addlayer(t, 'caxis', tlim, 'cmap', cmap, ...
        'name', sprintf('t-scores. range = [%.2f, %.2f]', min_t, max_t));
    
    ov.show()
    title(plotname);
end