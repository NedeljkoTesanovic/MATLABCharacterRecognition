%% Cistacica
close all
clear all
clc
%% Ucitavanje slike
[file, folder] = uigetfile('*.jpg') %Vraca naziv fajla (sa ekstenzijom) i putanju foldera gdje se fajl nalazi
path = append(folder, file); %Pravimo punu putanju do fajla
img = imread(path); 
%% Predprocesiranje
% Boja nam je nepotrebna, te pretvaramo sliku u monohromatsku
imgGray = rgb2gray(img);
figure('name', "Pocetna slika")
imshow(img)
figure('name', "Monohromatska slika")
imshow(imgGray)
%% Analiza histograma
%Prikazujemo histogram
figure('name', "Histogram")
histogram(imgGray)

threshold = 100; %Sva jacina piksela veca od threshold-a nam nije od interesa. Mi samo zelimo slova koja su karakteristicne nijanse
imgBW = imgGray < threshold;
figure('name',"Crno-bela slika")
imshow(imgBW)
%% Izbor ROI
%Region of Interest - biramo je na osnovu cinjenice da ce tekst na tablici
%biti horizontalan, kao i da na tablicama imamo svijetlu pozadinu i tamni
%tekst. Imajuci to u vidu, najsira grupa bijelih piksela je najvjerovatnije
%tekst od interesa. Sabiramo sve piksele po redovima i prikazujemo grupe.
%%
whiteRows = sum(imgBW, 2);
figure('name',"Koncentracija belog po redovima")
plot(whiteRows)
xlabel("Red")
ylabel("Koncentracija belih piksela")
grid on
hold on
axis tight
threshold2 = 110;
groups = whiteRows > threshold2;
plot(groups*(max(whiteRows)/2)) %Prikaz regija belih objekata
legend("Broj belog", "Grupe");
%%
% Trazimo najsiru grupu
edges = diff(groups); %izvod ce nam reci kada funkcija prelazi izmedju crne i bele boje. Tako detektujemo ivice
figure('name', "Prelazi po redovima")
plot(edges)
risingEdges = [find(edges == 1)]
fallingEdges = [find(edges == -1)]
if risingEdges(1)>fallingEdges(1) %Zastita od okvira
    risingEdges = [1;risingEdges]
   fallingEdges = [fallingEdges;length(edges)]
end
width = fallingEdges - risingEdges
[~, widest] = max(width)
%%
%Secemo sliku tako da nam ostane samo ROI
ROIStart = risingEdges(widest)
ROIEnd = fallingEdges(widest)

ROI = imgBW(ROIStart:ROIEnd, :);

figure('name',"Regija od interesovanja")
imshow(ROI)
%% Trazenje karaktera
%Princip je isti kao za ROI, samo sto umjesto redova koristimo kolone
%(slova ce biti veliki zbir belih piksela)
whiteColumns = sum(ROI,1);
%whiteColumns = whiteColumns - min(whiteColumns)
imshow(ROI)
hold on
plot(max(whiteColumns) - whiteColumns, 'r')
xlabel('Kolona')
ylabel('Koncentracija belih piksela')
%%
%Trazimo individualnih karaktera
thresholdCharacter = 5
groups = whiteColumns > thresholdCharacter
figure('name', "Koncentracija belog po kolonama")
plot(whiteColumns)
hold on
plot(groups*(max(whiteColumns)/2));
legend("Koncentracija belog", "Grupe");
%%

edges =  diff(groups);
figure('name', "Prelaz po kolonama")
plot(edges)
risingEdges = [1 find(edges == 1)]
fallingEdges = [find(edges == -1) length(edges)]
groups  = fallingEdges - risingEdges
avgWidth = mean(groups)
%Slova su uniformna po standardima za fontove koji se koriste za registracijske tablice
%Imajuci to u vidu, odbacujemo abnormalne sirine jer su to sumovi,
%nepoznati karakteri ili prosto ivice tablice
%width = width(width< avgWidth+(avgWidth/4) & width > avgWidth-(avgWidth/4))
%% Ucitavanje sablona karaktera
%Da bi prepoznali karaktere, moramo da imamo reference, tj. sablon-slike (templates) kako ti sami karakteri izgledaju
%Ucitavamo sablone iz foldera "templates" sadrzanog u direktorijimu
%aplikacije
templateDir = fullfile(pwd, 'templates');
templates = dir(fullfile(templateDir, "*.png"));
figure('name',"Prikaz sablona")
candidateImg =  cell(length(templates),2);
for i = 1:length(templates)
    subplot(6,7,i)
    [~, fileName] = fileparts(templates(i).name);
    candidateImg{i,1} = fileName;
    candidateImg{i,2} = imread(fullfile(templates(i).folder, templates(i).name));
    imshow(candidateImg{i,2})
end
%%
%Prikaz prvog karaktera i sablona

letterImg = ROI(:,risingEdges(2):fallingEdges(2)+1);
figure('name',"Izdvojeno prvo slovo");
imshow(letterImg)

template1 = imread(fullfile(templates(1).folder,templates(1).name));
figure('name',"Primer sablona")
imshow(template1)
%%
%Kao sto vidimo, velicine su razlicite, i kao takve, ne mozemo da ih
%uporedjujemo na preciznosti piksela, te je potrebno skalirati ih na iste
%dimenzije
letterImg = imresize(letterImg,size(candidateImg{i,2}));
imshow(letterImg)
%%
figure('name', "Rezultat skaliranja")
subplot(1,2,1)
imshow(letterImg)
subplot(1,2,2)
imshow(template1)
%% Prepoznavanje karaktera
%Posto imamo sliku karaktera i sliku sablona svih nama poznatih karaktera
%mozemo veoma jednostavno da uporedimo sliku karaktera sa svakim sablonom i
%oduzmemo vrednosti svakog piksela na slici.
difference = zeros(1, length(templates));
for i = 1:length(templates)
    difference(i) = abs(sum((letterImg - double(candidateImg{i,2})).^2, "all")/numel(candidateImg));
end
figure ('name', "Razlika karaktera od sablona");
chars = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","-"];
plot(difference)
ylabel("Odstupanje od sablona")
xticklabels(chars)
xticks(1:length(chars))
xlim([1 length(chars)])
grid on
%% Konacni izbor
%Onaj sablon koji se najmanje razlikuje od slike je najverovatnije nepoznati karakter.
[d, x] = min(difference);
templates(x)
[~, letter] = fileparts(templates(x).name)
%% Citanje slova
result = '';
for i = 1:length(groups)
    %if groups(i) < avgWidth + avgWidth/4 && groups(i) > avgWidth - avgWidth/4
    if groups(i) > avgWidth   
    %Izdvajanje slova
        letterImg = ROI(:, risingEdges(i):fallingEdges(i));
        figure('name',"Character #"+i)
        imshow(letterImg);
        width = fallingEdges(i) - risingEdges(i);
            %Uporedjivanje sa sablonima
            difference = zeros(1,length(templates));
            for j = 1:length(templates)
                letterImg = imresize(letterImg, size(candidateImg{j,2}));
                difference(j) = abs(sum((letterImg - double(candidateImg{j,2})).^2,"all"));
            end
            [d, x] = min(difference);
            letter = candidateImg{x,1};
            if ~contains(chars, letter) %Ako imamo nepoznate karaktere ili sum, prikazacemo to posebnim simbolom
                letter = ".";
            end
            result(end+1) = letter;
       % end    
    end
end
%% Procitani tekst:
result