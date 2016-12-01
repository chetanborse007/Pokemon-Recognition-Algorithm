

function [images, ID, CP, HP, Stardust, count] = Lookup(path, pattern)
% DESCRIPTION: Lookup a specified folder.
%              Find set of images and its labels from a given folder.
% INPUT:       %path            Path of images for which lookup is to be
%                               performed
%              %pattern         Pattern filter for image names
% OUTPUT:      Returns set of images and its labels from a specified folder.

    folder = dir([path, pattern]);
    count  = length(folder);

    images = cell(count, 1);
    ID     = zeros(count, 1);
    CP     = zeros(count, 1);
    HP     = zeros(count, 1);
    Stardust = zeros(count, 1);

    for i = 1:count
        images{i} = fullfile(path, folder(i).name);

        name    = folder(i).name;
        indices = findstr(name, '_');
        
        ID(i) = str2num(name(1:indices(1)-1));
        CP(i) = str2num(name(indices(1)+3:indices(2)-1));
        HP(i) = str2num(name(indices(2)+3:indices(3)-1));
        Stardust(i) = str2num(name(indices(3)+3:indices(4)-1));
    end

end

