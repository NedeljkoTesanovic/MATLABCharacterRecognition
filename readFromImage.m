function [retVal, stepCell] = readFromImage(img, binT, roiT, charT, undesirableT)
%This function takes the image containing the characters which we want to
%read as well as three thresholds:
%binT - binarisation threshold
%roiT - minimal row threshold
%charT - minimal column threshold
%undesirableT - minimal character width
%and returns the read text as retVal, as well as a cell array stepCell
%which contains visualisation and text information about the whole process
%of character recognition
global candidateImg len areLoaded
 try
    if areLoaded ~= 1
        loadTemplates(); %If it's the initial run, load the templates
    end
    br = 1; %counter for the step-visualisation array
    stepCell = {}; %stepCell return argument is going to allow us to have an array of images/plots
                   %as well as text explanations of different steps
                   %taking within the process of character
                   %recognition and image processing displayed in a
                   %single axes plot with interactable buttons
                   %instead of a bouquet of figure windows
    stepCell{br, 1} = img; %Contains the image/plot information of the step
    stepCell{br, 2} = "Starting image with unknown characters"; %textual explanation of the step
    stepCell{br, 3} = 0; %special flag indicating that a more complex visualisation/plot is required
                         %Depending on the value of the third cell,
                         %the rest of the array will contain
                         %different data
   if size(img,3) == 1 %if the image is already grayscale, all is right with the world
       imgGray = img;
   else %if not, make it gray
        try
            imgGray = rgb2gray(img);
            br = br + 1;
            stepCell{br, 1} =  imgGray;
            stepCell{br, 2} = "Since color doesn't play a part in the reading, we discard it by grayscaling the image";
            stepCell{br, 3} = 0;
        catch e
            msgbox("Error! Couldn't grayscale image! Stack Trace: " + e.Message);
        end
   end
    %Histogram
    
    br = br + 1;
    stepCell{br,1} = cumtrapz(histcounts(imgGray)); % saves the histogram of the image;
    stepCell{br,2} = "Cumulative histogram";
    stepCell{br,3} = 1;
    stepCell{br,6} = 0;
    
    threshold = str2num(binT); %input from gui
    if threshold == -1 %-1 is a flag-value indicating that the user wants to use automatic binarisation
        threshold = graythresh(imgGray); %Otsu's binarisation method
    end
        imgBW = imbinarize(imgGray, threshold);
    
    br = br + 1;
    stepCell{br, 1} =  imgBW;
    stepCell{br, 2} = "Binarisation completed with threshold: " + threshold;
    stepCell{br, 3} = 0;
    if threshold > 0.5 %If the threshold is higher than 0.5 it's most likely
                        %the case that the letter of interest are black
                        %so it's ncessary to invert the image. However,
                        %this doesn't always turn out to be true, so a
                        %better comparison method is needed.
        imgBW = ~imgBW;
        br = br + 1;
        stepCell{br, 1} =  imgBW;
        stepCell{br, 2} = "A threshold higher than 0.5 indicates a higher number of white pixels. It is most likely that actual characters are black, therefore we need to invert the image";
        stepCell{br, 3} = 0;
    end
    %% ROI selection 
    %The characters are going to be placed in a row,
    %therefore adding all the values of white pixels by row
    %and finding the widest group gives the best chance of selecting the
    %correct ROI
    whiteRows = sum(imgBW, 2);
    br = br + 1;
    stepCell{br, 1} =  whiteRows;
    stepCell{br, 2} = "Concentration of white pixels by row ";
    stepCell{br, 3} = 1;
    stepCell{br, 4} = "Row";
    stepCell{br, 5} = "Amount";
    threshold2 = mean(whiteRows)*str2num(roiT); %The amount of white pixels will be substantial if the group contains the characters.
    groups = whiteRows > threshold2; %therefore, whatever doesn't meet the quota, is most likely unimportant - hence discard it with extreme prejudice
    stepCell{br,6} = 1;
    stepCell{br, 7} = groups*(max(whiteRows)/2);
    stepCell{br, 8} = "White count";
    stepCell{br, 9} = "Groups";
    %%
    % Find the widest group
    edges = diff(groups); %First differential of the logical groups array will tell us where groups start/end
    br = br+1;
    stepCell{br,1} = edges;
    stepCell{br,2} = "Row edges";
    stepCell{br,3} = 1;
    stepCell{br,4} = "";
    stepCell{br,5} = "";
    stepCell{br,6} = 0;
    risingEdges = [find(edges == 1)];
    fallingEdges = [find(edges == -1)];
    if isempty(risingEdges)
        risingEdges = 1;
    end
    if isempty(fallingEdges)
        fallingEdges = edges(end);
    end
    if risingEdges(1)>fallingEdges(1) %Edge edge case protection :)
        risingEdges = [1;risingEdges];
    end
    if risingEdges(end) > fallingEdges(end)
        fallingEdges = [fallingEdges;length(edges)];
    end
    width = fallingEdges - risingEdges;
    [~, widest] = max(width);
    %%
    %Keep the ROI, discard the rest
    ROIStart = risingEdges(widest);
    ROIEnd = fallingEdges(widest);

    ROI = imgBW(ROIStart:ROIEnd, :); 
    %if sum(sum(ROI(ROI==1))) > size(ROI,1)*size(ROI,2)/2
    %    ROI=~ROI;
    %end
    br = br + 1;
    stepCell{br,1} = ROI;
    stepCell{br,2} = "Region of interest (Most likely to contain the characters)";
    stepCell{br,3} = 0;
    
    %% Character hunt
    %We search for individual characters using the same principle as we did
    %when we were searching for ROI, except this time, we're looking at
    %columns instead of rows
    whiteColumns = sum(ROI,1);
    br = br + 1;
    stepCell{br,1} = ROI;
    stepCell{br,2} = "Inspect the columns' white count for character candidates";
    stepCell{br,3} = 2;
    stepCell{br,4} = max(whiteColumns) - whiteColumns, 'r';
    %%
    thresholdCharacter = mean(whiteColumns) * str2num(charT); %Same reasoning as for ROI
    groups = whiteColumns > thresholdCharacter;
    br = br + 1;
    stepCell{br,1} = whiteColumns/(max(whiteColumns));
    stepCell{br,2} = ""
    stepCell{br,3} = 1;
    stepCell{br,4} = "Column"
    stepCell{br,5} = "Amount"
    stepCell{br,6} = 1;
    stepCell{br,7} = 0.5*groups;
    stepCell{br,8} = "White count";
    stepCell{br,9} = "Groups";
    
    edges = diff(groups);
    br = br + 1;
    stepCell{br,1} = edges;
    stepCell{br,2} = "Character edges";
    stepCell{br,3} = 1;
    stepCell{br,4} = "";
    stepCell{br,5} = "";
    stepCell{br,6} = 0;
    risingEdges = find(edges == 1);
    fallingEdges = find(edges == -1);

    if isempty(risingEdges)
        risingEdges = 1;
    end
    if isempty(fallingEdges)
        fallingEdges = edges(end);
    end

    if risingEdges(1)>fallingEdges(1)
        risingEdges = [1 risingEdges];
    end
    if risingEdges(end) > fallingEdges(end)
        fallingEdges = [fallingEdges length(edges)];
    end
    groups  = fallingEdges - risingEdges;
    avgWidth = mean(groups);

    %%
    %First character and template showcase
    try
        letterImg = ROI(:, risingEdges(1):fallingEdges(1));
        template1 = candidateImg{1,2};
        %Since we will be calculating the image-to-image differences on a
        %pixel level, it is required to resize the character image
        %according to the templates
        letterImg = imresize(letterImg,size(candidateImg{1,2}));
        br = br + 1;
        stepCell{br,1} = cat(2,letterImg,template1);
        stepCell{br,2} = "Character candidate (left) has been scaled to fit the template image's (right) dimensions";
        stepCell{br,3} = 0;
        %% Character recognition
        %We're going to match the character to all of the loaded templates
        %and find the template with the minimal Ruclidian difference.
        %That template is most likely to be our character
        difference = zeros(1, len);
        chars = "";
        for i = 1:len
            chars(i) = candidateImg{i,1}(1);
            difference(i) = abs(sum((letterImg - double(candidateImg{i,2})).^2, "all")/numel(candidateImg));
        end
        %chars = ["-","0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
        br = br + 1;
        stepCell{br, 1} = difference;
        stepCell{br, 2} = "Pixel-to-pixel Euclidian difference between the candidate and first 10 templates. The lowest one indicates which character has been read."; %image and some of the templates (A single letter can have multiple templates that have varying differences. Only the first ones are shown here)";
        stepCell{br, 3} = 4;
        stepCell{br,4} = chars(1:10);
        %The minimal difference indicates the most likely character,
        %therefore we bag it
        [d, x] = min(difference);
        candidateImg{x,1};
        [~, letter] = fileparts(candidateImg{x,1});
        
        %Now let's actually do it for all of the characters, not just the
        %first one
        retVal = "";
        for i = 1:length(groups)
            if groups(i) > avgWidth * str2num(undesirableT) %if a "character" isn't wide enough, it's most likely not an actual character
                letterImg = ROI(:, risingEdges(i):fallingEdges(i));
                    difference = zeros(1,len);
                    for j = 1:len
                        letterImg = imresize(letterImg, size(candidateImg{j,2}));
                        difference(j) = abs(sum((letterImg - double(candidateImg{j,2})).^2,"all"));
                    end
                    [d, x] = min(difference);
                    letter = candidateImg{x,1};
                    br = br + 1;
                    stepCell{br,1} = cat(2,letterImg,candidateImg{x,2});
                    stepCell{br,3} = 0;
                    stepCell{br,2} = i + ". detected character (left) and its closest matching template (right). Distance: "+ d;
                    if ~contains(chars, letter(1)) %Discard all non-letter and non-number characters
                        letter = "-";
                    end
                    if letter(1) ~= "-"
                         retVal = retVal + letter(1);
                    end            
            end
        end
        %% Display the recognized text
        %retVal;
    catch e
            retVal = "[No Text Found!]"
            stepCell = {};
            stepCell{1,1} = imread('error.jpg')
            stepCell{1,2} = "Error! Unable to read any text! Either the parameters are bad, or the image has no text! Stack trace:" + newline + e.message;
    end
  catch e
     msgbox("Bugger, something broke! Stack trace: " + e.message);
 end
end
%% Template loading
function loadTemplates()
% It is necessary to first load the templates with which we will contrast
% the character candidates. We can do this once on the initial run to save
% on performance.

global candidateImg len areLoaded
areLoaded = 0;
try
    templateDir = fullfile(pwd, 'templates');
    templates = dir(fullfile(templateDir, "*.png"));
    len = length(templates);
    w = waitbar(0, 'Loading templates...'); %template loading takes time, so it's nice to have a fancy
                                            %progress bar to aleviate your
                                            %boredom
    candidateImg =  cell(len,2);
    for i = 1:length(templates)
        [~, fileName] = fileparts(templates(i).name);
        candidateImg{i,1} = fileName;
        candidateImg{i,2} = imresize(im2bw(imread(fullfile(templates(i).folder, templates(i).name))), [40 20]);
        waitbar(i/len); %update the fancy progress bar
    end
    delete(w);
areLoaded = 1;
catch e
    msgbox("Error loading templates! Template files might be missing! Stack trace: " + newline + e.message);
end
end