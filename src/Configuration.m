

% DESCRIPTION: This is a configuration file for different Pokemon models.
%              You can change any parameter in this configuration file.


% Pokemon Recognition Model
model.POKEMON_MODEL = 'POKEMON_MODEL';
model.CP_MODEL = 'CP_MODEL';
model.HP_MODEL = 'HP_MODEL';
model.STARDUST_MODEL = 'STARDUST_MODEL';
model.POKEMON_LEVEL_MODEL = 'POKEMON_LEVEL_MODEL';

% Configuration for image dataset.
% > Path for training, validation and testing images
% > Image extensions
Config.TrainPath = './data/train/';
Config.TestPath = './data/test/';
Config.PokeLevelPath = './data/PokemonLevel/';
Config.PokeDataPattern = '*CP*';
Config.PokeLevelDataPattern = '*.jpg';

% Lookup Trainset
% [images, id, cp, hp, stardust, count] = Lookup(Config.TrainPath, ...
%                                                Config.PokeDataPattern);
% Config.Trainset.images = images;
% Config.Trainset.ID = id;
% Config.Trainset.CP = cp;
% Config.Trainset.HP = hp;
% Config.Trainset.Stardust = stardust;
% Config.Trainset.count = count;

% Lookup Testset
% [images, id, cp, hp, stardust, count] = Lookup(Config.TestPath, ...
%                                                Config.PokeDataPattern);
% Config.Testset.images = images;
% Config.Testset.ID = id;
% Config.Testset.CP = cp;
% Config.Testset.HP = hp;
% Config.Testset.Stardust = stardust;
% Config.Testset.count = count;

% Lookup Pokemon Level set
% [images, labels, count] = PokeLevelDataLookup(Config.PokeLevelPath, ...
%                                               Config.PokeLevelDataPattern);
% Config.PokeLevelDataset.images = images;
% Config.PokeLevelDataset.labels = labels;
% Config.PokeLevelDataset.count = count;

% Standard resolution for preprocessed images
Preprocess.Pokemon.Resolution = [150 150];
Preprocess.HP.Resolution = [150 150];
Preprocess.OCR.Resolution = [100 100];
Preprocess.PokemonLevel.Resolution = [100 100];

% Configuration for MSER features
MSER.ThresholdDelta = 2;
MSER.RegionAreaRange = [30 14000];
MSER.MaxAreaVariation = 0.25;
MSER.Method = 'SURF';
MSER.Upright = false;
MSER.SURFSize = 128;

% Configuration for HoG features
HoG.MinQuality = 0.25;
HoG.MinContrast = 0.2;
HoG.CellSize = [4 4];
HoG.BlockSize = [2 2];
HoG.BlockOverlap = [1 1];
HoG.NumBins = 9;
HoG.UseSignedOrientation = true;

% Configuration for SURF features
SURF.MetricThreshold = 200;
SURF.NumOctaves = 2;
SURF.NumScaleLevels = 5;
SURF.Method = 'SURF';
SURF.Upright = false;
SURF.SURFSize = 128;

% Configuration for Color features
Color.H = 350;
Color.S = 25;
Color.V = 25;

% Configuration for K-Means quantization
KMeans.MSER.Pokemon.NUMCENTERS = 100;
KMeans.MSER.HP.NUMCENTERS = 200;
KMeans.HoG.NUMCENTERS = 200;
KMeans.SURF.NUMCENTERS = 200;
KMeans.Color.NUMCENTERS = Color.H + Color.S + Color.V;
KMeans.Display = 'iter';
KMeans.Distance = 'cityblock';
KMeans.EmptyAction = 'singleton';
KMeans.MaxIter = 1400;
KMeans.OnlinePhase = 'on';
KMeans.Options = statset('UseParallel', 1, ...
                         'UseSubstreams', 1, ...
                         'Streams', RandStream('mlfg6331_64'));
KMeans.Replicates = 3;
KMeans.Start = 'plus';

% Configuration for SVM model
SVM.BoxConstraint = 5;
SVM.KernelFunction = 'rbf';
SVM.KernelScale = 'auto';
SVM.Standardize = true;
SVM.Solver = 'ISDA';
SVM.CacheSize = 'maximal';
SVM.NumPrint = 1000;
SVM.OutlierFraction = 0.01;
SVM.Verbose = 1;
SVM.Prior = 'empirical';
Fit.Coding = 'onevsone';
Fit.Options = statset('UseParallel', 1, ...
                      'UseSubstreams', 1, ...
                      'Streams', RandStream('mlfg6331_64'));

% Configuration for Pokemon model
Pokemon.Name = 'POKEMON';
Pokemon.Model.Holder = 'model.mat';
Pokemon.Model.Name = 'POKEMON_MODEL';
Pokemon.ROI = [1/10 3/10 4/10 5/10];
Pokemon.Feature = {'MSER', 'HoG', 'Color'};
Pokemon.HistogramBinSize = KMeans.MSER.Pokemon.NUMCENTERS + ...
                           KMeans.HoG.NUMCENTERS + ...
                           KMeans.Color.NUMCENTERS;
% Pokemon.Feature = {'HoG', 'SURF', 'Color'};
% Pokemon.HistogramBinSize = KMeans.HoG.NUMCENTERS + ...
%                            KMeans.SURF.NUMCENTERS + ...
%                            KMeans.Color.NUMCENTERS;

CP.Model.Holder = 'model.mat';
CP.Model.Name = 'CP_MODEL';
CP.TextPatch = [1/3 1/18 2/7 1/16];
CP.MedianFilter = [2 2];
CP.DiskRadius = 2;
CP.ConvolutionMatrix = [1 1; 1 1];
CP.IntensityScale_IN = [0.2 0.8];
CP.IntensityScale_OUT = [0 1];
CP.Gamma = 0.1;
CP.DigitPatch = [1/10 2/13 3/4 27/40];
CP.DigitThreshold = [0.4 0.7];
CP.ExpectedDigits = 3;
CP.DefaultLabel = 10;

% Configuration for HP model
HP.Name = 'HP';
HP.Model.Holder = 'model.mat';
HP.Model.Name = 'HP_MODEL';
HP.ROI = [2/5 1/2 1/5 1/16];
HP.Feature = {'MSER', 'HoG'};
HP.HistogramBinSize = KMeans.MSER.HP.NUMCENTERS + ...
                      KMeans.HoG.NUMCENTERS;

% Configuration for Stardust model
Stardust.Model.Holder = 'model.mat';
Stardust.Model.Name = 'STARDUST_MODEL';
Stardust.TextPatch = [1/2 47/60 7/40 7/120];
Stardust.MedianFilter = [2 2];
Stardust.DiskRadius = 1;
Stardust.ConvolutionMatrix = [1 1; 1 1];
Stardust.ThresholdingSensitivity = 0.3;
Stardust.DigitPatch = [1/4 1/4 1/2 1/2];
Stardust.DigitThreshold = [0.5 0.8];
Stardust.ExpectedDigits = 3;
Stardust.DefaultLabel = 200;

% Configuration for Pokemon Level model
PokemonLevel.Model.Holder = 'model.mat';
PokemonLevel.Model.Name = 'POKEMON_LEVEL_MODEL';
PokemonLevel.LevelPatch = [0 1/12 1 3/8];
PokemonLevel.MedianFilter = [2 2];
PokemonLevel.DiskRadius = 3;
PokemonLevel.ConvolutionMatrix = [1 1; 1 1];
PokemonLevel.IntensityScale_IN = [0.3 0.7];
PokemonLevel.IntensityScale_OUT = [0 1];
PokemonLevel.Gamma = 0.1;
PokemonLevel.Mask = [1/4 1 1/4 3/4];
PokemonLevel.RadiusThreshold = [1/200 1/50];
PokemonLevel.Circle.ObjectPolarity = 'bright';
PokemonLevel.Circle.Sensitivity = 0.60;
PokemonLevel.Circle.Method = 'twostage';
PokemonLevel.DefaultX = 1/10;
PokemonLevel.DefaultY = 7/20;
PokemonLevel.DefaultR = 1/70;

