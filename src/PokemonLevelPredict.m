

function [X_Level, Y_Level, R_Level] = PokemonLevelPredict(img, HyperParam)
% DESCRIPTION: Predict using Pokemon Level model.
% INPUT:       %img             Test image
%              %HyperParam      Hyper parameters of model
% OUTPUT:      Predicted pixel location, i.e. (X_Level, Y_Level) and radius of the level blob, i.e. R_Level.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Width and height of image
    W = size(img, 2);
    H = size(img, 1);

    % Crop level patch, i.e. region of interest
    XMin   = W * HyperParam.LevelPatch(1);
    YMin   = H * HyperParam.LevelPatch(2);
    Width  = W * HyperParam.LevelPatch(3);
    Height = H * HyperParam.LevelPatch(4);
    LevelPatch = imcrop(img, [XMin, YMin, Width, Height]);

    % Convert the level patch from RGB to Grayscale color space
    if size(LevelPatch, 3) == 3
        LevelPatch = rgb2gray(LevelPatch);
    end

    % Median filtering to remove noise
    LevelPatch = medfilt2(LevelPatch, HyperParam.MedianFilter);

    % Dilate level patch with the structural element
    DilatedLevelPatch = imdilate(LevelPatch, strel('disk', HyperParam.DiskRadius));

    % Erode level patch with the structural element
    ErodedLevelPatch = imerode(LevelPatch, strel('disk', HyperParam.DiskRadius));

    % Edge enhancement using Morphological Gradient
    LevelPatch = imsubtract(DilatedLevelPatch, ErodedLevelPatch);

    % Convert to intensity image
    LevelPatch = mat2gray(double(LevelPatch));

    % Two dimensional convolution of level patch
    LevelPatch = conv2(LevelPatch, HyperParam.ConvolutionMatrix);

    % Intensity scaling between the range 0 to 1
    LevelPatch = imadjust(LevelPatch, ...
                          HyperParam.IntensityScale_IN, ...
                          HyperParam.IntensityScale_OUT, ...
                          HyperParam.Gamma);

    % Convert to binary form
    LevelPatch = logical(LevelPatch);

    % Thinning level patch to ensure components isolation
    LevelPatch = imerode((bwmorph(LevelPatch, 'thin', 1)), ...
                         (strel('line', 1, 90)));

    % Select all the regions that are of pixel area more than 50
    LevelPatch = bwareaopen(LevelPatch, 50, 8);

    % Width and height of the level patch
    W_LevelPatch = size(LevelPatch, 2);
    H_LevelPatch = size(LevelPatch, 1);

    % Mask the middle portion of level patch, which is a potential Pokemon picture.
    X1 = int64(H_LevelPatch * HyperParam.Mask(1));
    X2 = int64(H_LevelPatch * HyperParam.Mask(2));
    Y1 = int64(W_LevelPatch * HyperParam.Mask(3));
    Y2 = int64(W_LevelPatch * HyperParam.Mask(4));
    LevelPatch(X1:X2, Y1:Y2) = 0;

    % Detect all possible circles from level patch that are within specified radius range
    R1 = int64(W_LevelPatch * HyperParam.RadiusThreshold(1));
    R2 = int64(W_LevelPatch * HyperParam.RadiusThreshold(2));
    [Centers, Radii] = imfindcircles(LevelPatch, ...
                                     [R1 R2], ...
                                     'ObjectPolarity', HyperParam.Circle.ObjectPolarity, ...
                                     'Sensitivity', HyperParam.Circle.Sensitivity, ...
                                     'Method', HyperParam.Circle.Method);

    Level     = [];
    LevelProb = [];
    
    if ~isempty(Centers)
        % Modify center locations to original X-Y scale
        Centers(:, 2) = YMin + Centers(:, 2);

        % Run Pokemon Level model over all extracted circle patches and find out probability of being level patch
        for j = 1:size(Centers, 1)
            % Extract circle patch
            R_CirclePatch = Radii(j) + W_LevelPatch * (1/25);
            X = Centers(j, 1) - R_CirclePatch;
            Y = Centers(j, 2) - R_CirclePatch;
            CirclePatch   = imcrop(img, [X, Y, 2*R_CirclePatch, 2*R_CirclePatch]);

            % Preprocess circle patch
            CirclePatch = Preprocess(CirclePatch, 'PokemonLevel');

            % Find the probability of being level patch
            target = Predict(HyperParam.Model, CirclePatch);

            % Find which output class among 2 has maximum probability
            % and accordingly record corresponding output class
            [value, index] = max(target);
            if index == 1
                Level = [Level j];
            end
        
            % Store all Level probabilities for different circle patches
            LevelProb = [LevelProb target(1)];
        end
    end

    % Predict level:
    % 1. Check which circle patch predicted as a Level has the highest
    % Level probability and mark it as a predicted Level.
    % 2. If 'Level' is empty, then pick a circle patch having the highest
    % Level probability and mark it as a predicted Level.
    % 3. If 'LevelProb' is empty, then set the default location for Level.
    if ~isempty(Level)
        [value, index] = max(LevelProb(Level));
        X_Level = Centers(Level(index), 1);
        Y_Level = Centers(Level(index), 2);
        R_Level = Radii(Level(index));
    elseif ~isempty(LevelProb)
        [value, index] = max(LevelProb);
        X_Level = Centers(index, 1);
        Y_Level = Centers(index, 2);
        R_Level = Radii(index);
    else
        X_Level = W * HyperParam.DefaultX;
        Y_Level = H * HyperParam.DefaultY;
        R_Level = W * HyperParam.DefaultR;
    end

end


function [class] = Predict(Model, input)
% DESCRIPTION: Predict whether the given test image is Level or not a Level.
% INPUT:       %Model           Pattern Recognition Network model
%              %input           Test image
% OUTPUT:      Predicted class.

    % Load trained Pattern Recognition Network object from 'model.mat'
    load(Model.Holder, Model.Name);
    if strcmp(Model.Name, 'POKEMON_LEVEL_MODEL')
        PatternNet = POKEMON_LEVEL_MODEL;
    end
    
    % Predict whether the given test image is Level or not a Level
    class = PatternNet([input(:)]);

end

