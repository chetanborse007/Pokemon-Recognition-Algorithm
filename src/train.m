

function [] = train(Trainset)
% DESCRIPTION: Train Pokemon models.
% INPUT:       %Trainset       Matlab structure consisting of training images and its labels
% OUTPUT:      None.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Train Pokemon model
    TrainPokemonModel(Trainset);

    % Train CP model
    OCRModel(Trainset.images, Trainset.CP, CP, 'CP');

    % Train HP model
    TrainHPModel(Trainset);

    % Train Stardust model
    OCRModel(Trainset.images, Trainset.Stardust, Stardust, 'Stardust');

    % Train Pokemon Level model
    PokemonLevelModel(Config.PokeLevelDataset.images, ...
                      Config.PokeLevelDataset.labels, ...
                      PokemonLevel);

end


function [] = TrainPokemonModel(Trainset)
% DESCRIPTION: Train Pokemon model.
% INPUT:       %Trainset       Matlab structure consisting of training images and its labels
% OUTPUT:      Create and save 'model.mat' file with a trained Pokemon model.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Create a Codebook of visual words
%    disp('Generating Codebook');
    CodeBook(Trainset, Pokemon, Pokemon.Feature);
    
    % Initialise HISTOGRAM matrix with dimension (Total Training Images,
    % Histogram Bin Size) e.g. (1800, 400).
    % This matrix holds one dimensional feature vectors (visual word 
    % frequency vectors) for every training image.
%    disp('Generating Train Histograms');
    HISTOGRAM = zeros(Trainset.count, Pokemon.HistogramBinSize);
    LABEL     = zeros(Trainset.count, 1);
    
    for i = 1:Trainset.count
        % Read image
        img = imread(Trainset.images{i});

        % Generate one dimensional feature vector i.e. Histogram for
        % the given image
        HISTOGRAM(i, :) = Histogram(img, Pokemon, Pokemon.Feature);

        % Store the corresponding label
        LABEL(i, :) = Trainset.ID(i);
    end

    % Create a SVM model
    svm = templateSVM('BoxConstraint', SVM.BoxConstraint, ...
                      'KernelFunction', SVM.KernelFunction, ...
                      'KernelScale', SVM.KernelScale, ...
                      'Standardize', SVM.Standardize, ...
                      'Solver', SVM.Solver, ...
                      'CacheSize', SVM.CacheSize, ...
                      'NumPrint', SVM.NumPrint, ...
                      'OutlierFraction', SVM.OutlierFraction, ...
                      'Verbose', SVM.Verbose, ...
                      'Prior', SVM.Prior);

    % Train SVM model
    rng(1);
    POKEMON_MODEL = fitcecoc(HISTOGRAM, LABEL, ...
                             'Learners', svm, ...
                             'Coding', Fit.Coding);

    % Save the trained Pokemon model
    save(Pokemon.Model.Holder, Pokemon.Model.Name, '-append');
    
end


function [] = TrainHPModel(Trainset)
% DESCRIPTION: Train HP model.
% INPUT:       %Trainset       Matlab structure consisting of training images and its labels
% OUTPUT:      Create and save 'model.mat' file with a trained HP model.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;
    
    % Create a Codebook of visual words
%    disp('Generating Codebook');
    CodeBook(Trainset, HP, HP.Feature);
    
    % Initialise HISTOGRAM matrix with dimension (Total Training Images,
    % Histogram Bin Size) e.g. (1800, 400).
    % This matrix holds one dimensional feature vectors (visual word 
    % frequency vectors) for every training image.
%    disp('Generating Train Histograms');
    HISTOGRAM = zeros(Trainset.count, HP.HistogramBinSize);
    LABEL     = zeros(Trainset.count, 1);

    for i = 1:Trainset.count
        % Read image
        img = imread(Trainset.images{i});

        % Generate one dimensional feature vector i.e. Histogram for
        % the given image
        HISTOGRAM(i, :) = Histogram(img, HP, HP.Feature);

        % Store the corresponding label
        LABEL(i, :) = Trainset.HP(i);
    end
    
    % Create a SVM model
    svm = templateSVM('BoxConstraint', SVM.BoxConstraint, ...
                      'KernelFunction', SVM.KernelFunction, ...
                      'KernelScale', SVM.KernelScale, ...
                      'Standardize', SVM.Standardize, ...
                      'Solver', SVM.Solver, ...
                      'CacheSize', SVM.CacheSize, ...
                      'NumPrint', SVM.NumPrint, ...
                      'OutlierFraction', SVM.OutlierFraction, ...
                      'Verbose', SVM.Verbose, ...
                      'Prior', SVM.Prior);

    % Train SVM model
    rng(1);
    HP_MODEL = fitcecoc(HISTOGRAM, LABEL, ...
                        'Learners', svm, ...
                        'Coding', Fit.Coding);

    % Save the trained HP model
    save(HP.Model.Holder, HP.Model.Name, '-append');

end

