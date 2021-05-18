%% Cistacica
close all
clear all
clc
%% Ucitavanje slike
[file, folder] = uigetfile('*.jpg') %Vraca naziv fajla (sa ekstenzijom) i putanju foldera gdje se fajl nalazi
path = append(folder, file); %Pravimo punu putanju do fajla
licensePlate = imread(path); % ucitavamo sliku
figure, imshow(licensePlate) %prikazujemo ucitanu sliku
%%
licensePlateGray = rgb2gray(licensePlate);
histogram(licensePlateGray)
threshold = 100;
licensePlateBW = licensePlateGray < threshold;
imshow(licensePlateBW)
%%
whiteCountPerRow = sum(licensePlateBW,2);
plot(whiteCountPerRow)
xlabel('Row Number (Up-down)')
ylabel('Number of White Pixels')
grid on
axis tight
%%
regions = whiteCountPerRow > 110;
plot(1:length(whiteCountPerRow), whiteCountPerRow)
hold on
plot(regions*400)
hold off
xlabel('Row Number (Up-down)')
ylabel('Number of White Pixels')
grid on
axis tight
legend('White Count', 'Regions')
%%
plot(diff(regions))
startIdx = [1; find(diff(regions)==1)]
endIdx = [find(diff(regions)==-1); length(regions)]
[~,widestRegionIdx] = max(endIdx-startIdx)
upperLimitROI = startIdx(widestRegionIdx)
lowerLimitROI = endIdx(widestRegionIdx)
%%
licensNumberROI = licensePlateBW(upperLimitROI:lowerLimitROI,:);
imshow(licensNumberROI)
%%
whiteCountPerColumn = sum(licensNumberROI,1);
imshow(licensNumberROI)
hold on
plot(max(whiteCountPerColumn) - whiteCountPerColumn,'r',"LineWidth",3)
xlabel('Row Number (Left-Right)')
ylabel('Number of White Pixels')
grid on
axis tight
hold off
%%
regions = whiteCountPerColumn > 5;
plot(whiteCountPerColumn)
hold on
plot(regions*400)
hold off
xlabel('Row Number (Up-down)')
ylabel('Number of White Pixels')
grid on
axis tight
legend('White Count', 'Regions')
%%
startIdx = [1 find(diff(regions)==1)]
endIdx = [find(diff(regions)==-1) length(regions)]
regions = endIdx-startIdx
widthThreshold = mean(regions)
%%
letterImage = licensNumberROI(:,startIdx(2):endIdx(2)+1);
imshow(letterImage)
%%
templateDir = fullfile(pwd,'templates');
templates = dir(fullfile(templateDir,"*.png"));
figurecandidateImage = cell(length(templates),2);
for p=1:length(templates)
    subplot(6,7,p)
    [~,fileName] = fileparts(templates(p).name);
    candidateImage{p,1} = fileName;
    candidateImage{p,2} = imread(fullfile(templates(p).folder,templates(p).name));
    imshow(candidateImage{p,2})
end
%%
template1 = imread(fullfile(templates(1).folder,templates(1).name));
figure
imshow(template1)
%%
x = randi(10,1,4)
y = randi(10,1,4)
temp = x - y;
distanceND = sqrt(abs(sum(temp.^2)))
%%
letterImage = imresize(letterImage,size(template1));
figure
subplot(1,2,1)
imshow(letterImage)
subplot(1,2,2)
imshow(template1)
%%
distance = zeros(1,length(templates));
for p=1:length(templates)
    distance(p) = abs(sum((letterImage-double(candidateImage{p,2})).^2,"all"))/numel(candidateImage{p,2});
end
figure
chars = ["0","1","2","3","4","5","6","7","8","9", "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O", "P","Q","R","S","T","U","V","W","X","Y","Z","~"];
plot(distance)
xticklabels(chars)
xticks(1:length(chars))
xlim([1 37])
grid on
[d,idx] = min(distance);
templates(idx)
[~,letter] = fileparts(templates(idx).name)
%%
licenseNumber = '';
for p=1:length(regions)
    if regions(p) > widthThreshold
        % Extract the letter
        letterImage = licensNumberROI(:,startIdx(p):endIdx(p));
        % Compare to templates
        distance = zeros(1,length(templates));
        for t=1:length(templates)
            letterImage = imresize(letterImage,size(candidateImage{t,2}));
            distance(t) = abs(sum((letterImage-double(candidateImage{t,2})).^2,"all"));
        end
        [d,idx] = min(distance);
        letter = candidateImage{idx,1};
       if ~contains(chars, letter) %Unknown character
            letter = " ";
        end
        licenseNumber(end+1) = letter; 
        end
    end
    licenseNumber