

function [corners, descriptors] = HoGFeature(img)
% DESCRIPTION: Generate HoG local features for a given image.
% INPUT:       %img             Image from which local features are to be
%                               extracted
% OUTPUT:      %corners         Interest points.
%              %descriptors     Extracted local features.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Transform image from RGB to Grayscale color space
    if size(img, 3) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end

    % Find corners, i.e. interests points
    corners = detectFASTFeatures(gray, ...
                                 'MinQuality', HoG.MinQuality, ...
                                 'MinContrast', HoG.MinContrast);

    corners = selectStrongest(corners, 500);
    
    % Generate HoG local features
    [descriptors, ~] = extractHOGFeatures(img, ...
                                          corners', ...
                                          'CellSize', HoG.CellSize, ...
                                          'BlockSize', HoG.BlockSize, ...
                                          'BlockOverlap', HoG.BlockOverlap, ...
                                          'NumBins', HoG.NumBins, ...
                                          'UseSignedOrientation', HoG.UseSignedOrientation);

    descriptors = descriptors';

end

