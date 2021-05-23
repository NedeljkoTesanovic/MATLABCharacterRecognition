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
%threshold =  100                           TODO: Opcionalni input sa GUIa
threshold = graythresh(imgGray) %Otsuova metoda za odredjivanje praga binarizacije
imgBW = imbinarize(imgGray, threshold)
%if sum(sum(imgBW(imgBW==1))) > size(imgBW,1)*size(imgBW,2)/2 %Posto radimo sa belim karakterima, u slucaju da se slika binarizuje na takav nacin da su karakteri crni, invertujemo je
if threshold > 0.5
    imgBW = ~imgBW;
end
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
%threshold2 = 110;                           TODO: Opcionalni input sa GUIa
threshold2 = mean(whiteRows)*0.5 %0.75
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
if isempty(risingEdges)
    risingEdges = 1
end
if isempty(fallingEdges)
    fallingEdges = edges(end)
end
if risingEdges(1)>fallingEdges(1) %Zastita od crnog okvira (Da su redovi jednake velicine)
    risingEdges = [1;risingEdges]
end
if risingEdges(end) > fallingEdges(end)
    fallingEdges = [fallingEdges;length(edges)]
end
width = fallingEdges - risingEdges
[~, widest] = max(width)
%%
%Secemo sliku tako da nam ostane samo ROI
ROIStart = risingEdges(widest)
ROIEnd = fallingEdges(widest)

ROI = imgBW(ROIStart:ROIEnd, :); 
if sum(sum(ROI(ROI==1))) > size(ROI,1)*size(ROI,2)/2 %Posto radimo sa belim karakterima, u slucaju da se slika binarizuje na takav nacin da su karakteri crni, invertujemo je

    ROI=~ROI;
end
figure('name',"Regija od interesovanja")
imshow(ROI)
%% Trazenje karaktera
%Princip je isti kao za ROI, samo sto umjesto redova koristimo kolone
%(slova ce biti veliki zbir belih piksela)
whiteColumns = sum(ROI,1);
imshow(ROI)
hold on
plot(max(whiteColumns) - whiteColumns, 'r')
xlabel('Kolona')
ylabel('Koncentracija belih piksela')
%%
%Trazimo individualnih karaktera
%thresholdCharacter = 5                     TODO: Opcionalni input sa GUIa
thresholdCharacter = mean(whiteColumns)*0.2
groups = whiteColumns > thresholdCharacter
figure('name', "Koncentracija belog po kolonama")
plot(whiteColumns/(max(whiteColumns)))
hold on
plot(0.5*groups);
legend("Koncentracija belog", "Grupe");
%% Prvi prelaz
edges =  diff(groups)
figure('name', "Prelaz po kolonama")
plot(edges)
risingEdges = find(edges == 1)
fallingEdges = find(edges == -1)

if isempty(risingEdges)
    risingEdges = 1
end
if isempty(fallingEdges)
    fallingEdges = edges(end)
end

if risingEdges(1)>fallingEdges(1) %Zastita od crnog okvira
    risingEdges = [1 risingEdges]
end
if risingEdges(end) > fallingEdges(end)
    fallingEdges = [fallingEdges length(edges)]
end
groups  = fallingEdges - risingEdges
avgWidth = mean(groups)

%Za debugging
%undesirables = groups(groups < avgWidth) %Sve grupe koje su znatno manje od prosjecne sirine grupe su najverovatnije artefakti
%Razlog za podesavanje je problem uskih karaktera u odredjenim fontovima
%(slovo I i broj 1), Ali u standardizovanim fontovima tablica, ovo ne bi
%bio problem

%% Ucitavanje sablona karaktera
%Da bi prepoznali karaktere, moramo da imamo reference, tj. sablon-slike (templates) kako ti sami karakteri izgledaju
%Ucitavamo sablone iz foldera "templates" sadrzanog u direktorijimu
%aplikacije
templateDir = fullfile(pwd, 'templates'); %Ucitavamo sablone iz foldera templates
templates = dir(fullfile(templateDir, "*.png")); %TODO: Prosiriti broj sablona
figure('name',"Prikaz sablona")
candidateImg =  cell(length(templates),2); %Sablon
for i = 1:length(templates)
    subplot(round(sqrt(length(templates)))+1,round(sqrt(length(templates))),i) %Za grid prikaz svih sablona
    [~, fileName] = fileparts(templates(i).name);
    candidateImg{i,1} = fileName;
    candidateImg{i,2} = imresize(im2bw(imread(fullfile(templates(i).folder, templates(i).name))), [40 20]);
    imshow(candidateImg{i,2})
end

%%
%Prikaz prvog karaktera i sablona
    letterImg = ROI(:, risingEdges(3):fallingEdges(3));
    figure
    imshow(letterImg)  
%end
%%
figure('name',"Izdvojen prvi karakter i prvi sablon");
subplot(1,2,1)
imshow(letterImg)
subplot(1,2,2)
hold on
title('Karakter', 'fontsize', 15)
template1 = imread(fullfile(templates(1).folder,templates(1).name));
imshow(template1)
hold on
title('Sablon', 'fontsize', 15)
%%
%Kao sto vidimo, velicine su razlicite, i kao takve, ne mozemo da ih
%uporedjujemo na preciznosti piksela, te je potrebno skalirati ih na iste
%dimenzije
letterImg = imresize(letterImg,size(candidateImg{i,2}));
figure('name', "Rezultat skaliranja")
subplot(1,2,1)
imshow(letterImg)
hold on
title('Karakter', 'fontsize', 15)
subplot(1,2,2)
imshow(template1)
hold on
title('Sablon', 'fontsize', 15)
%% Prepoznavanje karaktera
%Posto imamo sliku karaktera i sliku sablona svih nama poznatih karaktera
%mozemo veoma jednostavno da uporedimo sliku karaktera sa svakim sablonom i
%oduzmemo vrednosti svakog piksela na slici. Time dobijamo razlike izmedju 
%slike samog karaktera i sablona, te trazimo najmanju razliku.
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
%Nalazimo sablon sa najmanjom razlikom
result = '';
for i = 1:length(groups)
    if groups(i) > avgWidth * 0.66 %TODO Opcionalni Factor odbacivanja
        letterImg = ROI(:, risingEdges(i):fallingEdges(i));
            difference = zeros(1,length(templates));
            for j = 1:length(templates)
                letterImg = imresize(letterImg, size(candidateImg{j,2}));
                difference(j) = abs(sum((letterImg - double(candidateImg{j,2})).^2,"all"));
            end
            [d, x] = min(difference);
            letter = candidateImg{x,1};
            figure('name',"Karakter #"+i+" i najslicniji sablon")
            subplot(1,2,1)
            hold on
            title('Karakter', 'fontsize', 15)
            imshow(letterImg)
            subplot(1,2,2)
            hold on
            title('Sablon', 'fontsize', 15)
            imshow(candidateImg{x,2})
            if ~contains(chars, letter(1)) %Ako imamo nepoznate karaktere ili sum, prikazacemo to posebnim simbolom
                letter = "-";
            end
         result(end+1) = letter(1);   
    end
end
%% Procitani tekst:
result
disp("Registarska tablica: ")
result(result~='-')
