%% L3 processing for underwater image processing
%
%  HJ, VISTA TEAM, 2016

%% Init
ieInit

%% Initialize parameters
cfa = [2 1; 3 4];
patch_sz = [5 5];
base = 'http://scarlet.stanford.edu/validation/SCIEN/CARIBBEAN/03/';
rawDir = [base 'Data/Water/'];
rgbDir = [base 'Reference/Water/'];
outDir = '~/SimResults/L3/Underwater/';

s = lsScarlet(rgbDir, '.tif');
nTrain = 100; % use 100 images in training
% train_indx = randperm(length(s), nTrain);
train_indx = 1 : nTrain;

%% Training
%  Initialize training object
l3t = l3TrainRidge();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-2.2, -1.5, 40), []};
l3t.l3c.p_max = 1000;
l3t.verbose = false;
l3t.l3c.verbose = false;

%  classify training samples
fprintf('Training on image: ');
for ii = 1 : nTrain
    % print info
    str = sprintf('%d / %d', ii, nTrain);
    fprintf(str);
    
    img_name = s(train_indx(ii)).name(1:end-4);
    raw = im2double(imread([rawDir img_name '.pgm']));
    raw = raw(2:end, :); % make sure raw size is a multiple of cfa size
    rgb = im2double(imread([rgbDir img_name '.tif']));
    rgb = rgb(2:end, :, :);
    
    l3t.l3c.classify(l3DataCamera({raw}, {rgb}, cfa));
    
    fprintf(repmat('\b', [1 length(str)]));
end
fprintf('\n');

% learn kernels
l3t.train();

%% Rendering
%  Init render object
l3r = l3Render();
% de = zeros(length(s), 1);

fprintf('Rendering image: ');
for ii = 1 : length(s)
    % print info
    str = sprintf('%d / %d', ii, length(s));
    fprintf(str);
    
    % load data
    raw = im2double(imread([rawDir s(ii).name(1:end-4) '.pgm']));
    raw = raw(2:end, :); % make sure raw size is a multiple of cfa size
    rgb = im2double(imread([rgbDir s(ii).name]));
    rgb = rgb(2:end, :, :);
    
    % render
    l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0 ,1);
    
    % write rendered image out
    imwrite(l3_RGB, [outDir s(ii).name(1:end-4) '.jpg']);
    
    % compute deltaE
    % xyz1 = RGB2XWFormat(srgb2xyz(l3_RGB));
    % xyz2 = RGB2XWFormat(srgb2xyz(rgb));
    
    % de(ii) = mean(deltaEab(xyz1, xyz2, max(xyz2)));
    
    % print info
    fprintf(repmat('\b', [1 length(str)]));
end
fprintf('\n');