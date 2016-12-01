

% Clear everything i.e. memory, console, etc. and close all opened images
clear; clc; close all;

% Delete parallel pool of workers if any
delete(gcp('nocreate'));

% Delete model, i.e. 'model.mat'; if it exists
% if exist('model.mat', 'file') == 2
%     delete('model.mat');
% end

% Create a new model, i.e. 'model.mat'
% save('model.mat');

% Import project configuration i.e. 'Configuration.m'
Configuration;

% Train different Pokemon models
disp('Started training.....');
% train(Config.Trainset);
disp('Training completed.....');

% Test different Pokemon models
disp('Started testing.....');
% test(Config.Testset);
disp('Testing completed.....');

