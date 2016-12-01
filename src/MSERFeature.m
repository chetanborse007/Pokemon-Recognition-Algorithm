

function [regions, cc, descriptors] = MSERFeature(img)
% DESCRIPTION: Generate MSER local features for a given image.
% INPUT:       %img             Image from which local features are to be
%                               extracted
% OUTPUT:      %regions         Interest points.
%              %cc              Connected component structures.
%              %descriptors     Extracted local features.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Transform image from RGB to Grayscale color space
    if size(img, 3) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end

    % Find regions, i.e. interests points
    [regions, cc] = detectMSERFeatures(gray, ...
                                       'ThresholdDelta', MSER.ThresholdDelta, ...
                                       'RegionAreaRange', MSER.RegionAreaRange, ...
                                       'MaxAreaVariation', MSER.MaxAreaVariation);

    % Generate MSER local features
    [descriptors, ~] = extractFeatures(gray, ...
                                       regions', ...
                                       'Method', MSER.Method, ...
                                       'Upright', MSER.Upright, ...
                                       'SURFSize', MSER.SURFSize);

    descriptors = descriptors';

end

