

function [ID, CP, HP, stardust, level, cir_center] = pokemon_stats (img, model)
% INPUT: image; model(a struct that contains your classification model, detector, template, etc.)
% OUTPUT: ID(pokemon id, 1-201); level(the position(x,y) of the white dot in the semi circle); cir_center(the position(x,y) of the center of the semi circle)

%     ID = 1;
%     CP = 123;
%     HP = 26;
%     stardust = 600;
%     level = [327,165];
%     cir_center = [355,457];

    ID = PredictPokemonID(img);

    CP = PredictCP(img);

    HP = PredictHP(img);

    stardust = PredictStardust(img);

    [X_Level, Y_Level] = PredictPokemonLevel(img);
    level = [X_Level, Y_Level];

    [X, Y] = PredictSemicircleCenter(img);
    cir_center = [X, Y];

end


function [PredictedID] = PredictPokemonID(img)
% DESCRIPTION: Predict Pokemon ID.
% INPUT:       %img        Test image
% OUTPUT:      Predicted Pokemon ID.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Generate one dimensional feature vector i.e. Histogram for
    % the given image
    TestHistogram = zeros(1, Pokemon.HistogramBinSize);
    TestHistogram(1, :) = Histogram(img, Pokemon, Pokemon.Feature);

    % Predict Pokemon ID
    load(Pokemon.Model.Holder, Pokemon.Model.Name);
    PredictedID = predict(POKEMON_MODEL, TestHistogram);

end


function [PredictedCP] = PredictCP(img)
% DESCRIPTION: Predict CP.
% INPUT:       %img        Test image
% OUTPUT:      Predicted CP.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Predict CP
    PredictedCP = OCRPredict(img, CP, 'CP');

end


function [PredictedHP] = PredictHP(img)
% DESCRIPTION: Predict HP.
% INPUT:       %img        Test image
% OUTPUT:      Predicted HP.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Generate one dimensional feature vector i.e. Histogram for
    % the given image
    TestHistogram = zeros(1, HP.HistogramBinSize);
    TestHistogram(1, :) = Histogram(img, HP, HP.Feature);

    % Predict HP
    load(HP.Model.Holder, HP.Model.Name);
    PredictedHP = predict(HP_MODEL, TestHistogram);

end


function [PredictedStardust] = PredictStardust(img)
% DESCRIPTION: Predict Stardust.
% INPUT:       %img        Test image
% OUTPUT:      Predicted Stardust.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Predict Stardust
    PredictedStardust = OCRPredict(img, Stardust, 'Stardust');

end


function [X_Level, Y_Level] = PredictPokemonLevel(img)
% DESCRIPTION: Predict Pokemon Level.
% INPUT:       %img        Test image
% OUTPUT:      Predicted Pokemon Level.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Predict Pokemon Level
    [X_Level, Y_Level, R_Level] = PokemonLevelPredict(img, PokemonLevel);

%     figure; imshow(img);
%     c = viscircles([X_Level, Y_Level], R_Level);

end


function [X, Y] = PredictSemicircleCenter(img)
% DESCRIPTION: Predict Semicircle Center.
% INPUT:       %img        Test image
% OUTPUT:      Predicted Semicircle Center.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Width and height of image
    W = size(img, 2);
    H = size(img, 1);

    % Center of semicircle
    X = int64(W * 0.5);
    Y = int64(H * 0.33);

%     figure; imshow(img);
%     plot(X, Y, 'g^');

end

