

function [img] = Preprocess(img, ModelType)
% DESCRIPTION: Preprocess the given image.
% INPUT:       %img         Image to be preprocessed
%              %ModelType   Type of model
% OUTPUT:      Preprocessed image.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;
    
    % Convert image to double precision or single precision based on model
    if strcmp(ModelType, 'OCR') || strcmp(ModelType, 'PokemonLevel')
        img = im2double(img);
    else
        img = im2single(img);
    end

    % Standardize image resolution e.g. (128 128 3)
    if strcmp(ModelType, 'OCR')
        img = imresize(img, Preprocess.OCR.Resolution);
    elseif strcmp(ModelType, 'PokemonLevel')
        img = imresize(img, Preprocess.PokemonLevel.Resolution);
    else
        img_res = size(img, 1) * size(img, 2);

        if strcmp(ModelType, 'POKEMON_MODEL')
            ExpectedResolution = Preprocess.Pokemon.Resolution(1) * Preprocess.Pokemon.Resolution(2);
            StandardResolution = Preprocess.Pokemon.Resolution;
        elseif strcmp(ModelType, 'HP_MODEL')
            ExpectedResolution = Preprocess.HP.Resolution(1) * Preprocess.HP.Resolution(2);
            StandardResolution = Preprocess.HP.Resolution;
        end

        if img_res ~= ExpectedResolution
            img = imresize(img, StandardResolution);
        end
    end

end

