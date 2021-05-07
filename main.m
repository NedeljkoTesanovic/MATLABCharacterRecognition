%% Cistacica
close all
clear all
clc
%% Ucitavanje slike
[file, folder] = uigetfile('*.jpg') %Vraca naziv fajla (sa ekstenzijom) i putanju foldera gdje se fajl nalazi
path = append(folder, file); %Pravimo punu putanju do fajla
img = imread(path); % ucitavamo sliku
figure, imshow(img) %prikazujemo ucitanu sliku
%img = double(img);
%figure, imshow(img, [0;1], [0;1]);
%% Predprocesiranje
% Boja nam je nepotrebna, te pretvaramo sliku u monohromatsku
img = im2double(img);
[sx, sy, sz] = size(img);
for i = 1:sx
    for j = 1:sy
        imgGray(i,j) = (img(i,j,1)+img(i,j,2)+img(i,j,3))/3; %metoda prosjeka
%        imgGray2(i,j) = ((img(i,j,1)*img(i,j,2)*img(i,j,3)))^(1/3); %Geometrijska metoda
%        imgGray3(i,j) = 0.21*img(i,j,1)+0.72*img(i,j,2)+0.07*img(i,j,3); %Luminocity metoda
%        imgGray4(i,j) = (max(img(i,j))+min(img(i,j)))/2; %Lightness metoda
    end
end
%figure, imshow(img)
%figure, imshow(imgGray)
%figure, imshow(imgGray2)
%figure, imshow(imgGray3)
%figure, imshow(imgGray4)

%%
imshow(imgGray)
impixelinfo()
histogram(imgGray)
%%
threshold = 0.4;
imgBW = imgGray < threshold;
imshow(imgBW)
%% Biranje ROI
%Region of Interest - biramo je na osnovu cinjenice da ce tekst na tablici
%biti horizontalan, kao i da na tablicama imamo svijetlu pozadinu i tamni
%tekst. Imajuci to u vidu, najsira grupa bijelih piksela je najvjerovatnije
%tekst od interesa. Sabiramo sve piksele po redovima i prikazujemo grupe.
threshold2 = 250;
rowVal = sum(imgBW, 2); %
candidates = rowVal>threshold
plot(rowVal)
xlabel("Red (od gore ka dole)");
ylabel("Broj belih piksela");
grid on
hold on
plot(candidates*(max(rowVal)/2))
%%
% Trazimo najsiru grupu
edges = diff(candidates);
plot(edges)
risingEdges = [find(edges == 1)]
fallingEdges = [find(edges == -1)]
if risingEdges(1)>fallingEdges(1)
    risingEdges = [1;risingEdges]
    fallingEdges = [fallingEdges;length(edges)]
end
width = fallingEdges - risingEdges
[~, widest] = max(width)
ROIStart = risingEdges(widest)
ROIEnd = fallingEdges(widest)
%%
%Secemo sliku tako da nam ostane samo ROI
ROI = imgBW(ROIStart:ROIEnd, :);
imshow(ROI)
%% Trazenje karaktera
%Princip je isti kao za ROI, samo sto umjesto redova koristimo kolone
%(slova ce biti veliki zbir belih piksela)
colVal = sum(ROI,1);
imshow(ROI)
hold on
plot(max(colVal) - colVal, 'r')

%%
candidates = colVal > 10
edges =  diff(candidates);
plot(edges)
startId = [1 find(edges == 1)]
endId = [find(edges == -1) length(edges)]
width  = endId-startId
avgWidth = mean(width)
%%
letter = ROI(:, startId(2):endId(2)+1)
imshow(letter)
%% Prepoznavanje karaktera