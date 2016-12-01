

function [] = CodeBook(Trainset, HyperParam, CodebookType)
% DESCRIPTION: Generate the Codebook of visual words for the provided 
%              codebook types.
% INPUT:       %Trainset        Matlab structure consisting of training images and its labels
%              %HyperParam      Hyper parameters of model to be trained
%              %CodebookType    Codebook types e.g. MSER, HoG, SURF, etc.
% OUTPUT:      Create and save 'model.mat' file with respective codebooks
%              i.e. 'MSER_CODEBOOK' for MSER, 'HoG_CODEBOOK' for HoG.

    % Import project configuration i.e. 'Configuration.m'
    Configuration;

    % Initialise MatLab Cell for local features
    if any(strcmp(CodebookType, 'MSER'))
        MSERLocalFeature  = {};
    end
    if any(strcmp(CodebookType, 'HoG'))
        HoGLocalFeature = {};
    end
    if any(strcmp(CodebookType, 'SURF'))
        SURFLocalFeature  = {};
    end

    for i = 1:Trainset.count
        % Read image
        img = imread(Trainset.images{i});

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

        % Generate Local Features e.g. MSER, HoG, SURF, etc.
        if any(strcmp(CodebookType, 'MSER'))
            [~, ~, MSERLocalFeature{i}] = MSERFeature(roi);
        end
        
        if any(strcmp(CodebookType, 'HoG'))
            [~, HoGLocalFeature{i}]     = HoGFeature(roi);
        end
        
        if any(strcmp(CodebookType, 'SURF'))
            [~, SURFLocalFeature{i}]    = SURFFeature(roi);
        end
    end

    if any(strcmp(CodebookType, 'MSER'))
        MSERLocalFeature  = cat(2, MSERLocalFeature{:});
    end
    if any(strcmp(CodebookType, 'HoG'))
        HoGLocalFeature = cat(2, HoGLocalFeature{:});
    end
    if any(strcmp(CodebookType, 'SURF'))
        SURFLocalFeature  = cat(2, SURFLocalFeature{:});
    end


    % Quantize extracted MSER local features (descriptors) using
    % K-Means algorithm 
    if any(strcmp(CodebookType, 'MSER'))
%         pool = parpool;
        if strcmp(HyperParam.Model.Name, 'POKEMON_MODEL')
            [~, MSER_CODEBOOK] = kmeans(im2double(MSERLocalFeature'), ...
                                        KMeans.MSER.Pokemon.NUMCENTERS, ...
                                        'Display', KMeans.Display, ...
                                        'Distance', KMeans.Distance, ...
                                        'EmptyAction', KMeans.EmptyAction, ...
                                        'MaxIter', KMeans.MaxIter, ...
                                        'OnlinePhase', KMeans.OnlinePhase, ...
                                        'Replicates', KMeans.Replicates, ...
                                        'Start', KMeans.Start);
        else
            [~, MSER_CODEBOOK] = kmeans(im2double(MSERLocalFeature'), ...
                                        KMeans.MSER.HP.NUMCENTERS, ...
                                        'Display', KMeans.Display, ...
                                        'Distance', KMeans.Distance, ...
                                        'EmptyAction', KMeans.EmptyAction, ...
                                        'MaxIter', KMeans.MaxIter, ...
                                        'OnlinePhase', KMeans.OnlinePhase, ...
                                        'Replicates', KMeans.Replicates, ...
                                        'Start', KMeans.Start);
        end
        MSER_CODEBOOK = MSER_CODEBOOK';
%         delete(gcp('nocreate'));

        if strcmp(HyperParam.Model.Name, 'POKEMON_MODEL')
            POKEMON_MSER_CODEBOOK = MSER_CODEBOOK;
            save(HyperParam.Model.Holder, 'POKEMON_MSER_CODEBOOK', '-append');
        elseif strcmp(HyperParam.Model.Name, 'HP_MODEL')
            HP_MSER_CODEBOOK      = MSER_CODEBOOK;
            save(HyperParam.Model.Holder, 'HP_MSER_CODEBOOK', '-append');
        else
            save(HyperParam.Model.Holder, 'MSER_CODEBOOK', '-append');
        end
    end
    
    % Quantize extracted HoG local features (descriptors) using 
    % K-Means algorithm 
    if any(strcmp(CodebookType, 'HoG'))
%         pool = parpool;
        [~, HoG_CODEBOOK] = kmeans(im2double(HoGLocalFeature'), ...
                                   KMeans.HoG.NUMCENTERS, ...
                                   'Display', KMeans.Display, ...
                                   'Distance', KMeans.Distance, ...
                                   'EmptyAction', KMeans.EmptyAction, ...
                                   'MaxIter', KMeans.MaxIter, ...
                                   'OnlinePhase', KMeans.OnlinePhase, ...
                                   'Replicates', KMeans.Replicates, ...
                                   'Start', KMeans.Start);
        HoG_CODEBOOK      = HoG_CODEBOOK';
%         delete(gcp('nocreate'));

        if strcmp(HyperParam.Model.Name, 'POKEMON_MODEL')
            POKEMON_HoG_CODEBOOK = HoG_CODEBOOK;
            save(HyperParam.Model.Holder, 'POKEMON_HoG_CODEBOOK', '-append');
        elseif strcmp(HyperParam.Model.Name, 'HP_MODEL')
            HP_HoG_CODEBOOK      = HoG_CODEBOOK;
            save(HyperParam.Model.Holder, 'HP_HoG_CODEBOOK', '-append');
        else
            save(HyperParam.Model.Holder, 'HoG_CODEBOOK', '-append');
        end
    end
    
    % Quantize extracted SURF local features (descriptors) using 
    % K-Means algorithm 
    if any(strcmp(CodebookType, 'SURF'))
%         pool = parpool;
        [~, SURF_CODEBOOK] = kmeans(im2double(SURFLocalFeature'), ...
                                    KMeans.SURF.NUMCENTERS, ...
                                    'Display', KMeans.Display, ...
                                    'Distance', KMeans.Distance, ...
                                    'EmptyAction', KMeans.EmptyAction, ...
                                    'MaxIter', KMeans.MaxIter, ...
                                    'OnlinePhase', KMeans.OnlinePhase, ...
                                    'Replicates', KMeans.Replicates, ...
                                    'Start', KMeans.Start);
        SURF_CODEBOOK      = SURF_CODEBOOK';
%         delete(gcp('nocreate'));

        if strcmp(HyperParam.Model.Name, 'POKEMON_MODEL')
            POKEMON_SURF_CODEBOOK = SURF_CODEBOOK;
            save(HyperParam.Model.Holder, 'POKEMON_SURF_CODEBOOK', '-append');
        elseif strcmp(HyperParam.Model.Name, 'HP_MODEL')
            HP_SURF_CODEBOOK      = SURF_CODEBOOK;
            save(HyperParam.Model.Holder, 'HP_SURF_CODEBOOK', '-append');
        else
            save(HyperParam.Model.Holder, 'SURF_CODEBOOK', '-append');
        end
    end

end

