

function [] = OCRModel(Trainset, Label, HyperParam, ModelType)
% DESCRIPTION: Create and train OCR model over a given training set for a specified model type.
% INPUT:       %Trainset        Training images
%              %Label           Labels corresponding to training images
%              %HyperParam      Hyper parameters of model to be trained
%              %ModelType       OCR model type
% OUTPUT:      Create and save 'model.mat' file with respective OCR models.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    TrainX = [];
    TrainY = [];

    % Create training set by extracting digits from the given images
    for i = 1:size(Trainset, 1)
        % Read image
        img = imread(Trainset{i});

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

        % Find expected total digits from a label
        expectedDigitCount = ceil(log10(abs(Label(i))));
        
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
        
        % Find the total number of valid digit components from digit patch
        digitCount = 0;
        for j = 1:totalComponent
            cc = stats(j).Image;
            if (strcmp(ModelType, 'CP') && ...
                (size(cc, 2) > DigitThreshold_X) && ...
                (size(cc, 1) > DigitThreshold_Y)) || ...
               (strcmp(ModelType, 'Stardust') && ...
                (size(cc, 2) > DigitThreshold_X) && ...
                (size(cc, 1) < DigitThreshold_Y))
                digitCount = digitCount + 1;
            end
        end

        % If total number of valid digit components from the digit patch is
        % equal to the expected digit count, then add extracted valid digit
        % components into training set of digits.
        if digitCount == expectedDigitCount
            k = 1;
            for j = 1:totalComponent
                cc = stats(j).Image;
                
                if (strcmp(ModelType, 'CP') && ...
                    (size(cc, 2) > DigitThreshold_X) && ...
                    (size(cc, 1) > DigitThreshold_Y)) || ...
                   (strcmp(ModelType, 'Stardust') && ...
                    (size(cc, 2) > DigitThreshold_X) && ...
                    (size(cc, 1) < DigitThreshold_Y))
                    cc = Preprocess(cc, 'OCR');
                    
                    target = zeros(1, 10);
                    label  = num2str(Label(i));
                    digit  = str2num(label(:, k));
                    target(digit+1) = 1;
                    
                    TrainX = [ TrainX cc(:) ];
                    TrainY = [ TrainY target(:) ];
                    
                    k = k + 1;
                end
            end
        end
    end

    % Create a Pattern Recognition Network
    CreatePatternNet([20 40 80 40 20], false, HyperParam.Model);

    % Train a Pattern Recognition Network
    TrainPatternNet(HyperParam.Model, TrainX, TrainY);

end


function [] = CreatePatternNet(HiddenLayer, ShowTrainWindow, Model)
% DESCRIPTION: Create a Pattern Recognition Network.
% INPUT:       %HiddenLayer     Vector of Hidden Layers & its size
%              %ShowTrainWindow Flag for displaying training window
%              %Model           Model type
% OUTPUT:      Create and save 'model.mat' file with Pattern Recognition Network model.

    % Create an object of Pattern Recognition Network.
    PatternNet = patternnet(HiddenLayer);

    % Split input data into Training, Validation and Testing sets
    PatternNet.divideFcn  = 'dividerand';
    PatternNet.divideMode = 'sample';
    PatternNet.divideParam.trainRatio = 75/100;
    PatternNet.divideParam.valRatio   = 20/100;
    PatternNet.divideParam.testRatio  = 5/100;

    % Set network training function.
    % Here, we are using Scaled Conjugate Gradient backpropagation.
    PatternNet.trainFcn = 'trainscg';
    
    % Set parameter for checking crossentropy performance of neural netowork
    PatternNet.performFcn = 'crossentropy';
    
    % Set tuning parameters for Pattern Recognition Network
    % 1. max_fail: Maximum validation failures
    % 2. epochs: Maximum number of epochs to train
    % 3. lr: Learning rate
    % 4. mc: Momentum constant
    % 5. showWindow: Show training GUI
    PatternNet.trainParam.max_fail   = 8;
    PatternNet.trainParam.epochs     = 100;
    PatternNet.trainParam.lr         = 0.001;
    PatternNet.trainParam.mc         = 0.95;
    PatternNet.trainParam.showWindow = ShowTrainWindow;
    
    % Set regularization parameter for generalization of Pattern 
    % Recognition Network and for avoiding overfitting
    PatternNet.performParam.regularization = 0.5;

    % Save Pattern Recognition Network object
    if strcmp(Model.Name, 'CP_MODEL')
        CP_MODEL       = PatternNet;
    elseif strcmp(Model.Name, 'STARDUST_MODEL')
        STARDUST_MODEL = PatternNet;
    end
    save(Model.Holder, Model.Name, '-append');

end


function [] = TrainPatternNet(Model, TrainX, TrainY)
% DESCRIPTION: Train a Pattern Recognition Network.
% INPUT:       %Model           Pattern Recognition Network model
%              %TrainX          Training images
%              %TrainY          Training labels
% OUTPUT:      None.

    % Load Pattern Recognition Network object from 'model.mat'
    load(Model.Holder, Model.Name);
    if strcmp(Model.Name, 'CP_MODEL')
        PatternNet = CP_MODEL;
    elseif strcmp(Model.Name, 'STARDUST_MODEL')
        PatternNet = STARDUST_MODEL;
    end
    
    % Train Pattern Recognition Network
    PatternNet = train(PatternNet, TrainX, TrainY);

    % Save trained Pattern Recognition Network back to 'model.mat'
    if strcmp(Model.Name, 'CP_MODEL')
        CP_MODEL       = PatternNet;
    elseif strcmp(Model.Name, 'STARDUST_MODEL')
        STARDUST_MODEL = PatternNet;
    end
    save(Model.Holder, Model.Name, '-append');

end

