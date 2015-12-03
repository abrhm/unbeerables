function [categoryClassifier, output_bag, output_msgBag, output_msgTrainer] = trainECOCSVM(imgSetTrain, featureExtractHandle, validify, wordNumber, strongestFeatures, learnerOpts)
%% Tanító, amely a Bag of Visual Words modellt használja
% képekbõl kinyert SIFT jellemzõk transzformálására
% olyan feature vektorrá, ami klasszifikálható SVM-el.
% 
% A beépített trainImageCategoryClassifier helyett közvetlenül
% hívjuk meg a fitcecoc fgv-t, amivel több dolgot tudunk beállítani
% a tanítást illetõen.
% 
% A bagOfWords objektumból kinyerjük a feature vektorokat, amiket
% átadunk majd a megfelelõen paraméterezett osztályozónak.
%
% input:
%   imgSetTrain - képhalmaz, amikre be akarjuk tanítani az osztályozót
%   featureExtractHandle - custom function handle, ami szolgáltatja
%       az általunk megvalósított jellemzõkinyerést
%   validify - akarunk-e kiértékelni train halmazon?
%       (magával vonja az eredeti halmaz felosztását és értékelését -
%       TESZTELÉS CÉLJÁBÓL)
%   strongestFeatures - a bag of visual words objektum a kinyert legerõsebb
%       jellemzõk mekkora hányadát használja fel
%   learnerOpts - SVM osztályozók létrehozásának modelljét beállító
%       paraméter, valid választásokról lásd a matlab doksit:
%       https://www.mathworks.com/help/stats/fitcecoc.html#zmw57dd0e233307
%
% output:
%   categoryClassifier - betanított SVM osztályozók egy ECOC
%       keretrendszerben
%   output_bag - bag of visual words objektum, szükséges a predikcióhoz
%       tesztelõ fgv-ben (lásd calssifyECOCSVM.m)
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
    main_folder = 'D:\matlab_proj\gray';
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
    %disp('Validation on training data set to: ')
    %disp(validify)
else
    validify = false;
    %disp('Validation variable set to default = false')
end

if isempty(learnerOpts)
    learnerOpts = 'onevsone';
end

%% Labelek kinyerése minden képhez
label_vector = [imgSetTrain.ImageLocation];
label_vector{:};
s = size(label_vector);
out_label_vector = cell(s(1),s(2));
for i=1:s(end)
	a = label_vector(i);
	aa = regexp(a,'\','split');
	aa1 = aa{:};
	aa1 = aa1(end); % get the image name
	aa1 = regexp(aa1,'_','split');
	aa1 = aa1{:};
	aa1 = aa1(1);
	out_label_vector(i) = aa1;
end

%% 1. lépés:
% Bag of visual words létrehozása, ami k-means klaszterezést használ
% a megfelelõ szeparáláshoz; a klaszterek pedig az egyes visual word-öknek
% felelnek meg, amibõl hisztogramot állítunk elõ és azt adjuk tovább
% általunk létrehozott feature detektor function-tõl kapja az inputot.
if useSURF == true
    bag = bagOfFeatures(imgSetTrain, 'Verbose', false, 'VocabularySize', wordNumber, 'PointSelection', 'Detector', 'StrongestFeatures', strongestFeatures);
    output_msgBag = evalc('disp(bag)');
else
    bag = bagOfFeatures(imgSetTrain,'CustomExtractor', featureExtractHandle, 'Verbose', false, 'VocabularySize', wordNumber, 'StrongestFeatures', strongestFeatures);
    output_msgBag = evalc('disp(bag)');
end

%% 2. lépés: (train)
% Kép klasszifikáló SVM-et hozunk létre.
% A fitcecoc multiclass K(K – 1)/2 SVM bináris osztályozókat hoz létre,
% ahol K az osztályokat jelöli.
% az elõzõ lépésben kapott hisztogram egy vektor, amit átadunk az SVM
% osztályozónak.
featureMatrix = encode(bag,imgSetTrain);
% beállítjuk az osztályozót
opts = templateSVM('BoxConstraint', 1.3, 'KernelFunction', 'gaussian');
categoryClassifier = fitcecoc(featureMatrix,out_label_vector,'Learners',opts, 'Coding', learnerOpts);
s = sprintf('%s\n', 'Tanitasi modell:');
s1 = evalc('disp(learnerOpts)');
msg1 = sprintf('%s%s',s ,s1);

%% Debug information
% Információ kiírása a klasszifikálóról
s = sprintf('%s\n', 'Osztalyok:');
s1 = evalc('disp(categoryClassifier.ClassNames)');
msg2 = sprintf('%s%s',s ,s1);

% Bináris tanuló SVM-ek reprezentálása mátrix alakban aszerint, hogy
% melyik a pozitív osztály, és melyik a negatív (sorok: osztályok,
% oszlopok: bináris tanulók/SVM-ek)
CodingMtx = categoryClassifier.CodingMatrix;
%disp(CodingMtx)

if validify == true
    % veszteség számítása
    % ezzel a 'resubstitution error'-t fogjuk megkapni
    % ez a hiba a rossz klasszifikációkat tûnteti fel
    isLoss = resubLoss(categoryClassifier);
    s = 'Resubstitution error: ';
    s1 = evalc('disp(isLoss)');
    msg3 = {strcat(s,s1)};

    % cross-validation: 10 részre osztva a tanuló halmazt értékeljük ki
    % a tanulókat
    CVcategoryClassifier = crossval(categoryClassifier);
    % felosztott és kiértékelt modellre kiszámoljuk a veszteséget hibás
    % osztályozásokra
    oosLoss = kfoldLoss(CVcategoryClassifier);
    s = 'K fold error: ';
    s1 = evalc('disp(oosLoss)');
    msg4 = {strcat(s,s1)};
    
    % confusion matrix reprezentáció
    oofLoss = kfoldPredict(CVcategoryClassifier);
    confMtx = confusionmat(out_label_vector, oofLoss);
    s = sprintf('%s\n', 'Confusion Matrix:');
    s1 = evalc('disp(confMtx)');
    msg5 = sprintf('%s%s',s ,s1);
end

% Szükséges a predikálásnál
output_bag = bag;

%% képek törlése memóriából -> a jellemzõket kinyertük, képeket kiértékeltük
% delete(trainingSets)
clear imgSetTrain;
clear bag;

if validify == true
    output_msgTrainer = char(char(msg1),char(msg2),char(msg3),char(msg4),char(msg5));
else
    output_msgTrainer = char(char(msg1),char(msg2));
end

%% opcionális: modell mentése
% save('classifier_1', 'categoryClassifier')

end