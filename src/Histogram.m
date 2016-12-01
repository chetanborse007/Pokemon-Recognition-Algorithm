

function [histogram] = Histogram(img, HyperParam, HistogramType)
% DESCRIPTION: Generate the one dimensional feature vector i.e. Histogram 
%              for the given image and for specified histogram type.
% INPUT:       %img             Image for which histogram is to be
%                               generated
%              %HyperParam      Hyper parameters of model to be trained
%              %HistogramType   Histogram types
% OUTPUT:      One dimensional feature vector i.e. Histogram for the given 
%              image.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    histogram = [];

    % Find width and height of image
    if strcmp(HyperParam.Model.Name, 'POKEMON_MODEL')
        w = size(img, 1);
        h = size(img, 2);
    else
        w = size(img, 2);
        h = size(img, 1);
    end

    % Crop region of interest
    XMin   = w * HyperParam.ROI(1);
    YMin   = h * HyperParam.ROI(2);
    Width  = w * HyperParam.ROI(3);
    Height = h * HyperParam.ROI(4);
    roi    = imcrop(img, [XMin, YMin, Width, Height]);
    
    % Preprocess region of interest
    roi = Preprocess(roi, HyperParam.Model.Name);

    % MSER Histogram
    if any(strcmp(HistogramType, 'MSER'))
        % Load respective Codebook for generating Histogram
        % i.e. 'MSER_CODEBOOK' for MSER Histogram, 'HoG_CODEBOOK' for HoG
        % Histogram.
        load(HyperParam.Model.Holder, [HyperParam.Name '_' 'MSER_CODEBOOK']);
        if strcmp(HyperParam.Model.Name, 'POKEMON_MODEL')
            MSER_CODEBOOK = POKEMON_MSER_CODEBOOK;
        elseif strcmp(HyperParam.Model.Name, 'HP_MODEL')
            MSER_CODEBOOK = HP_MSER_CODEBOOK;
        end

        % Generate Local Features for a given image
        % e.g. MSER, HoG, SURF, etc.
        [~, ~, descriptors] = MSERFeature(roi);

        % Assign every local feature to respective closest cluster (Visual Word)
        DistanceMatrix = pdist2(MSER_CODEBOOK', im2double(descriptors'), 'jaccard');
        [~, indices]   = min(DistanceMatrix);% try different distances

        % Find visual word frequencies for a given image
        if strcmp(HyperParam.Model.Name, 'POKEMON_MODEL')
            MSER = hist(indices, KMeans.MSER.Pokemon.NUMCENTERS);
        else
            MSER = hist(indices, KMeans.MSER.HP.NUMCENTERS);
        end
        
        histogram = [histogram MSER];
    end

    % HoG Histogram
    if any(strcmp(HistogramType, 'HoG'))
        % Load respective Codebook for generating Histogram
        % i.e. 'MSER_CODEBOOK' for MSER Histogram, 'HoG_CODEBOOK' for HoG
        % Histogram.
        load(HyperParam.Model.Holder, [HyperParam.Name '_' 'HoG_CODEBOOK']);
        if strcmp(HyperParam.Model.Name, 'POKEMON_MODEL')
            HoG_CODEBOOK = POKEMON_HoG_CODEBOOK;
        elseif strcmp(HyperParam.Model.Name, 'HP_MODEL')
            HoG_CODEBOOK = HP_HoG_CODEBOOK;
        end

        % Generate Local Features for a given image
        % e.g. MSER, HoG, SURF, etc.
        [~, descriptors] = HoGFeature(roi);

        % Assign every local feature to respective closest cluster (Visual Word)
        DistanceMatrix = pdist2(HoG_CODEBOOK', im2double(descriptors'), 'jaccard');
        [~, indices]   = min(DistanceMatrix);% try different distances

        % Find visual word frequencies for a given image
        HoG = hist(indices, KMeans.HoG.NUMCENTERS);

        histogram = [histogram HoG];
    end

    % SURF Histogram
    if any(strcmp(HistogramType, 'SURF'))
        % Load respective Codebook for generating Histogram
        % i.e. 'MSER_CODEBOOK' for MSER Histogram, 'HoG_CODEBOOK' for HoG
        % Histogram.
        load(HyperParam.Model.Holder, [HyperParam.Name '_' 'SURF_CODEBOOK']);
        if strcmp(HyperParam.Model.Name, 'POKEMON_MODEL')
            SURF_CODEBOOK = POKEMON_SURF_CODEBOOK;
        elseif strcmp(HyperParam.Model.Name, 'HP_MODEL')
            SURF_CODEBOOK = HP_SURF_CODEBOOK;
        end

        % Generate Local Features for a given image
        % e.g. MSER, HoG, SURF, etc.
        [~, descriptors] = SURFFeature(roi);

        % Assign every local feature to respective closest cluster (Visual Word)
        DistanceMatrix = pdist2(SURF_CODEBOOK', im2double(descriptors'), 'jaccard');
        [~, indices]   = min(DistanceMatrix);% try different distances

        % Find visual word frequencies for a given image
        SURF = hist(indices, KMeans.SURF.NUMCENTERS);

        histogram = [histogram SURF];
    end

    % Color Histogram
    if any(strcmp(HistogramType, 'Color'))
        % Convert image from RGB to HSV color space
        if size(img, 3) == 3
            hsv = rgb2hsv(roi);
        else
            hsv(:, :, 1) = roi;
            hsv(:, :, 2) = roi;
            hsv(:, :, 3) = roi;
        end

        % Normalize intensity values as per the maximum buckets available for every color channel
        h = int64(floor(hsv(:, :, 1) * Color.H));
        s = int64(floor(hsv(:, :, 2) * Color.S));
        v = int64(floor(hsv(:, :, 3) * Color.V));

        % Count total number of pixels in every bucket for every color channel
        h = hist(double(h(:)), Color.H);
        s = hist(double(s(:)), Color.S);
        v = hist(double(v(:)), Color.V);

        % Combine all 3 color channels to generate color histogram
        Color = [h s v];
        
        histogram = [histogram Color];
    end

end

