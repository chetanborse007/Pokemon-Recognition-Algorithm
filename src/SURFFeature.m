

function [blobs, descriptors] = SURFFeature(img)
% DESCRIPTION: Generate SURF local features for a given image.
% INPUT:       %img             Image from which local features are to be
%                               extracted
% OUTPUT:      %blobs           Interest points.
%              %descriptors     Extracted local features.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;
    
    % Transform image from RGB to Grayscale color space
    if size(img, 3) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end

    % Find blobs, i.e. interests points
    blobs = detectSURFFeatures(gray, ...
                               'MetricThreshold', SURF.MetricThreshold, ...
                               'NumOctaves', SURF.NumOctaves, ...
                               'NumScaleLevels', SURF.NumScaleLevels);

    % Select strongest blobs
    blobs = selectStrongest(blobs, 500);

    % Generate SURF local features
    [descriptors, ~] = extractFeatures(gray, ...
                                       blobs', ...
                                       'Method', SURF.Method, ...
                                       'Upright', SURF.Upright, ...
                                       'SURFSize', SURF.SURFSize);

    descriptors = descriptors';

end

