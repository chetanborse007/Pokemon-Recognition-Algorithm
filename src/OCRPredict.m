

function [Label] = OCRPredict(img, HyperParam, ModelType)
% DESCRIPTION: Predict using OCR model.
% INPUT:       %img             Test image
%              %HyperParam      Hyper parameters of model
%              %ModelType       OCR model type
% OUTPUT:      Predicted label.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Width and height of image
    w = size(img, 2);
    h = size(img, 1);

    % Crop text patch, i.e. region of interest
    XMin   = w * HyperParam.TextPatch(1);
    YMin   = h * HyperParam.TextPatch(2);
    Width  = w * HyperParam.TextPatch(3);
    Height = h * HyperParam.TextPatch(4);
    TextPatch = imcrop(img, [XMin, YMin, Width, Height]);

    % Resize the text patch keeping aspect ratio same
    TextPatch = imresize(TextPatch, [400 NaN]);

    % Convert the text patch from RGB to Grayscale color space
    if size(TextPatch, 3) == 3
        TextPatch = rgb2gray(TextPatch);
    end

    % Median filtering to remove noise
    TextPatch = medfilt2(TextPatch, HyperParam.MedianFilter);

    % Dilate text patch with the structural element
    DilatedTextPatch = imdilate(TextPatch, strel('disk', HyperParam.DiskRadius));

    % Erode text patch with the structural element
    ErodedTextPatch = imerode(TextPatch, strel('disk', HyperParam.DiskRadius));

    % Edge enhancement using Morphological Gradient
    TextPatch = imsubtract(DilatedTextPatch, ErodedTextPatch);

    % Convert to intensity image
    TextPatch = mat2gray(double(TextPatch));

    % Two dimensional convolution of text patch
    TextPatch = conv2(TextPatch, HyperParam.ConvolutionMatrix);

    if strcmp(ModelType, 'CP')
        % Intensity scaling between the range 0 to 1
        TextPatch = imadjust(TextPatch, ...
                             HyperParam.IntensityScale_IN, ...
                             HyperParam.IntensityScale_OUT, ...
                             HyperParam.Gamma);

        % Convert to binary form
        TextPatch = logical(TextPatch);
    end

    if strcmp(ModelType, 'Stardust')
        % Convert to a binary image by thresholding
        TextPatch = imbinarize(TextPatch, ...
                               'adaptive', ...
                               'Sensitivity', ...
                               HyperParam.ThresholdingSensitivity);
    end

    % Thinning text patch to ensure character isolation
    TextPatch = imerode((bwmorph(TextPatch, 'thin', 1)), ...
                        (strel('line', 1, 90)));

    % Select all the regions that are of pixel area more than 50
    TextPatch = bwareaopen(TextPatch, 50, 8);

    % Segment characters based on vertical histogram over text patch
    histogram = sum(TextPatch, 1);
    cutoff    = int64(sum(histogram) / (3 * nnz(histogram)));
    character = histogram > cutoff;
    characterMask = cumsum(~character) .* character;
    TextPatch = bsxfun(@times, TextPatch, characterMask);

    % Segment characters based on horizontal histogram over text patch
    histogram = sum(TextPatch, 2);
    cutoff    = int64(sum(histogram) / (3 * nnz(histogram)));
    character = histogram > cutoff;
    characterMask = cumsum(~character) .* character;
    TextPatch = bsxfun(@times, TextPatch, characterMask);

    % Width and height of the text patch
    w = size(TextPatch, 2);
    h = size(TextPatch, 1);

    % Crop digit patch, i.e. region of interest
    XMin   = w * HyperParam.DigitPatch(1);
    YMin   = h * HyperParam.DigitPatch(2);
    Width  = w * HyperParam.DigitPatch(3);
    Height = h * HyperParam.DigitPatch(4);
    DigitPatch = imcrop(TextPatch, [XMin, YMin, Width, Height]);

    % Label connected components in digit patch
    [components, totalComponent] = bwlabel(DigitPatch);

    % Measure properties of the connected component
    stats = regionprops(components, 'BoundingBox', 'Image');

    % Set expected total digits from a guess
    expectedDigitCount = HyperParam.ExpectedDigits;

    % Width and height of the digit patch
    w = size(DigitPatch, 2);
    h = size(DigitPatch, 1);

    % Compute width and height thresholds for valid digit patches
    if strcmp(ModelType, 'CP')
        DigitThreshold_X = (w * HyperParam.DigitThreshold(1)) / (expectedDigitCount + 1);
        DigitThreshold_Y = h * HyperParam.DigitThreshold(2);
    elseif strcmp(ModelType, 'Stardust')
        DigitThreshold_X = (w * HyperParam.DigitThreshold(1)) / expectedDigitCount;
        DigitThreshold_Y = h * HyperParam.DigitThreshold(2);
    end

    % Find valid digit components from the digit patch.
    % Preprocess it and predict the exact digits using Pattern Recognition Network model.
    label      = 0;
    digitCount = 0;
    for j = 1:totalComponent
        cc = stats(j).Image;

        if (strcmp(ModelType, 'CP') && (size(cc, 2) > DigitThreshold_X) && ...
            (size(cc, 1) > DigitThreshold_Y)) || ...
           (strcmp(ModelType, 'Stardust') && (size(cc, 2) > DigitThreshold_X) && ...
            (size(cc, 1) < DigitThreshold_Y))
            % Preprocess the digit component
            cc = Preprocess(cc, 'OCR');

            % Predict the exact digit using Pattern Recognition Network model
            target = Predict(HyperParam.Model, cc);

            % Form the whole number using predicted digits
            [value, index] = max(target);
            label = (label * 10) + (index - 1);

            digitCount = digitCount + 1;
        end
    end

    % If total valid digit components are 2 or 3 or 4, then only assign predicted label to test image.
    % Else assign default label to test image.
    if (strcmp(ModelType, 'CP') && (digitCount == 2 || ...
                                    digitCount == 3 || ...
                                    digitCount == 4)) || ...
       (strcmp(ModelType, 'Stardust') && (digitCount == 3 || ...
                                          digitCount == 4))
        Label = label;
    else
        Label = HyperParam.DefaultLabel;
    end

end


function [class] = Predict(Model, input)
% DESCRIPTION: Predict the exact digit.
% INPUT:       %Model           Pattern Recognition Network model
%              %input           Test image
% OUTPUT:      Predicted class.
    
    % Load trained Pattern Recognition Network object from 'model.mat'
    load(Model.Holder, Model.Name);
    if strcmp(Model.Name, 'CP_MODEL')
        PatternNet = CP_MODEL;
    elseif strcmp(Model.Name, 'STARDUST_MODEL')
        PatternNet = STARDUST_MODEL;
    end
    
    % Predict the exact digit
    class = PatternNet([input(:)]);

end

