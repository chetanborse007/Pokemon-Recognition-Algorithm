

function [] = PokemonLevelModel(Trainset, Label, HyperParam)
% DESCRIPTION: Create and train Pokemon Level model over a given training set.
% INPUT:       %Trainset        Training images
%              %Label           Labels corresponding to training images
%              %HyperParam      Hyper parameters of model to be trained
% OUTPUT:      Create and save 'model.mat' file with Pokemon Level model.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    TrainX = [];
    TrainY = [];

    % Create training set and preprocess it
    for i = 1:size(Trainset, 1)
        % Read training image
        img = imread(Trainset{i});

        % Preprocess training image
        img = Preprocess(img, 'PokemonLevel');

        % Create a label vector for a preprocessed training image
        target = zeros(1, 2);
        if strcmp(Label{i}, 'Level')
            target(:, 1) = 1;
        elseif strcmp(Label{i}, 'NonLevel')
            target(:, 2) = 1;
        end

        TrainX = [TrainX img(:)];
        TrainY = [TrainY target(:)];
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
    if strcmp(Model.Name, 'POKEMON_LEVEL_MODEL')
        POKEMON_LEVEL_MODEL = PatternNet;
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
    if strcmp(Model.Name, 'POKEMON_LEVEL_MODEL')
        PatternNet = POKEMON_LEVEL_MODEL;
    end
    
    % Train Pattern Recognition Network
    PatternNet = train(PatternNet, TrainX, TrainY);

    % Save trained Pattern Recognition Network back to 'model.mat'
    if strcmp(Model.Name, 'POKEMON_LEVEL_MODEL')
        POKEMON_LEVEL_MODEL = PatternNet;
    end
    save(Model.Holder, Model.Name, '-append');

end

