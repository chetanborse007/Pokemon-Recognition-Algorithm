

function [images, labels, count] = PokeLevelDataLookup(path, pattern)
% DESCRIPTION: Lookup a specified folder.
%              Find set of images and its labels from a given folder.
% INPUT:       %path            Path of images for which lookup is to be
%                               performed
%              %pattern         Pattern filter for image names
% OUTPUT:      Returns set of images and its labels from a specified folder.

    LevelFolder    = dir([path, 'Level/', pattern]);
    NonLevelFolder = dir([path, 'NonLevel/', pattern]);
    
    LevelCount    = length(LevelFolder);
    NonLevelCount = length(NonLevelFolder);
    count = LevelCount + NonLevelCount;

    images = cell(count, 1);
    labels = cell(count, 1);

    % Find images from 'Level' category.
    for i = 1:LevelCount
        images{i} = fullfile(path, 'Level', LevelFolder(i).name);
        labels{i} = 'Level';
    end
    
    % Find images from 'NonLevel' category.
    for i = 1:NonLevelCount
        images{i+LevelCount} = fullfile(path, 'NonLevel', NonLevelFolder(i).name);
        labels{i+LevelCount} = 'NonLevel';
    end

end

