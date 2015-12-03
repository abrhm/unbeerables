function [categoryClassifier,output_msgBag, output_msgTrainer] = trainSingleSimpleSVM(imgSetTrain, featureExtractHandle, validify, wordNumber, strongestFeatures)
%% Tanító, amely a Bag of Visual Words modellt használja
% képekbõl kinyert jellemzõk transzformálására
% olyan feature vektorrá, ami klasszifikálható SVM-el.
%
% input:
%   imgSetTrain - képhalmaz, amikre be akarjuk tanítani az osztályozót
%   featureExtractHandle - custom function handle, ami szolgáltatja
%       az általunk megvalósított jellemzõkinyerést
%   validify - akarunk-e kiértékelni train halmazon?
%       (magával vonja az eredeti halmaz felosztását és értékelését -
%       TESZTELÉS CÉLJÁBÓL)
%   wordNumber - a szótárunkba felírandó szavak száma, és így a kalszterek
%       száma, meghatározza a vizuális szavak számát (default: 64)
%   strongestFeatures - a bag of visual words objektum a kinyert legerõsebb
%       jellemzõk mekkora hányadát használja fel
%
% output:
%   categoryClassifier - betanított ECOC framework-el ellátott SVM
%       osztályozó
%   output_msgBag, output_msgTrainer - információk dolgokról
%
% NOTE: Work in progress!
% Folyamat, paraméterek, illetve megvalósítás részletessége változhat!
%

%% Check input
useSURF = false;
if ~isa(featureExtractHandle, 'function_handle') || isempty(imgSetTrain)
       useSURF = true;
end

if isempty(imgSetTrain)
    main_folder = 'D:\matlab_proj\manual_testing\2\train';
    imgSetTrain = imageSet(main_folder, 'recursive');
end

if isempty(wordNumber) || ~isnumeric(wordNumber) == 0
    wordNumber = 64;
end

if isreal(strongestFeatures)
    if strongestFeatures < 0
       strongestFeatures = 0;
    elseif strongestFeatures > 1
       strongestFeatures = 1;
    end
else
    error('strongestFeatures should be a float parameter!');
end

if islogical(validify)
    if islogical(validify)
        disp('Validation on training data set to: ')
        disp(validify)
    else
        validify = false;
        disp('Validation variable set to default = false')
    end
    if validify == true
        minSetCount = min([imgSetTrain.Count]);
        imgSetsPart = partition(imgSetTrain, minSetCount, 'randomize');
        %imgSetsPart = partition(imgSetTrain, minSetCount, 'sequential');
        %validateSet = imageSet('D:\matlab_proj\manual_testing\2\valid','recursive');
        [imgSetTrain, validateSet] = partition(imgSetsPart, 0.4, 'randomize');
        %[imgSetTrain, validateSet] = partition(imgSetsPart, 0.4, 'sequential');
    end
end

%% Debug information
% Milyen képekre tanul rá
%str = 'imgSetTrain contents: ';
%disp(str)
%dbg = [imgSetTrain.ImageLocation];
%dbg{:};
%s = size(dbg);
%for i=1:s(end)
%	a = dbg(i);
%	aa = regexp(a,'\','split');
%	aa1 = aa{:};
%	aa1 = aa1(end);
%    disp(aa1)
%end

%% 1. lépés:
% Bag of visual words létrehozása, ami k-means klaszterezést használ
% a megfelelõ szeparáláshoz; a klaszterek pedig az egyes visual word-öknek
% felelnek meg, amibõl hisztogramot állítunk elõ és azt adjuk tovább.
% A feature detektálás
%   vagy a beépített SURF algoritmussal dolgozó eljárással,
%   vagy általunk létrehozott feature detektor function-nal történik.
if useSURF == true
    bag = bagOfFeatures(imgSetTrain, 'Verbose', false, 'VocabularySize', wordNumber, 'PointSelection', 'Detector', 'StrongestFeatures', strongestFeatures);
    output_msgBag = evalc('disp(bag)');
else
    bag = bagOfFeatures(imgSetTrain,'CustomExtractor', featureExtractHandle, 'Verbose', false, 'VocabularySize', wordNumber, 'StrongestFeatures', strongestFeatures);
    output_msgBag = evalc('disp(bag)');
end

%% 2. lépés: (train)
% Kép klasszifikáló SVM-et hozunk létre
% az elõzõ lépésben kapott hisztogram egy vektor, amit átadunk az SVM
% osztályozónak.
% TODO: templateSVM-et be kell lõni
opts = templateSVM('BoxConstraint', 1.3, 'KernelFunction', 'gaussian');
categoryClassifier = trainImageCategoryClassifier(imgSetTrain, bag, 'LearnerOptions', opts);
msg1 = 'Tanitasi modell: one-vs-one egyszeru tanitoval';

%% képek törlése memóriából -> a jellemzõket kinyertük, képeket kiértékeltük
% delete(trainingSets)
clear imgSetTrain;
clear bag;

%% opcionális: modell mentése
% save('classifier_1', 'categoryClassifier')

%% opcionális: validálás eredményei
if validify == true
    confMatrix = evaluate(categoryClassifier, validateSet);
    s = sprintf('%s\n', 'Confusion Matrix:');
    s1 = evalc('disp(confMatrix)');
    
    %s1_num = diag(confMatrix);
    %ss = cellstr(s);
    %xlsFilename = 'testdata.xlsx';
    %msg = {ss; s1_num};
    %xlswrite(xlsFilename, msg)
    
    msg2 = sprintf('%s%s',s ,s1);
    %mean(diag(confMatrix));
end

if validify == true
    output_msgTrainer = char(char(msg1),char(msg2));
else
    output_msgTrainer = char(char(msg1));
end

end
