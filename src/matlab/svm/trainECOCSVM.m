function [categoryClassifier, output_bag] = trainECOCSVM(imgSetTrain, featureExtractHandle, validify, wordNumber)
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
%
% output:
%   categoryClassifier - betanított SVM osztályozók egy ECOC
%       keretrendszerben
%   output_bag - bag of visual words objektum, szükséges a predikcióhoz
%       tesztelõ fgv-ben (lásd calssifyECOCSVM.m)
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

if islogical(validify)
    disp('Validation on training data set to: ')
    disp(validify)
else
    validify = false;
    disp('Validation variable set to default = false')
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
    bag = bagOfFeatures(imgSetTrain, 'Verbose', false, 'VocabularySize', wordNumber, 'PointSelection', 'Detector')
else
    bag = bagOfFeatures(imgSetTrain,'CustomExtractor', featureExtractHandle)
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
categoryClassifier = fitcecoc(featureMatrix,out_label_vector,'Learners',opts);

%% Debug information
% Információ kiírása a klasszifikálóról
categoryClassifier.ClassNames
% 3 bináris tanuló SVM-ek reprezentálása mátrix alakban aszerint, hogy
% melyik a pozitív osztály, és melyik a negatív (sorok: osztályok,
% oszlopok: bináris tanulók/SVM-ek)
CodingMtx = categoryClassifier.CodingMatrix;
disp(CodingMtx)

if validify == true
    % veszteség számítása
    % ezzel a 'resubstitution error'-t fogjuk megkapni
    % ez a hiba a rossz klasszifikációkat tûnteti fel
    isLoss = resubLoss(categoryClassifier);
    disp(isLoss)

    % cross-validation: 10 részre osztva a tanuló halmazt értékeljük ki
    % a tanulókat
    CVcategoryClassifier = crossval(categoryClassifier);
    % felosztott és kiértékelt modellre kiszámoljuk a veszteséget hibás
    % osztályozásokra
    oosLoss = kfoldLoss(CVcategoryClassifier);
    disp(oosLoss)
    
    % confusion matrix reprezentáció
    oofLoss = kfoldPredict(CVcategoryClassifier);
    confMat = confusionmat(out_label_vector, oofLoss);
    disp(confMat)
end

% Szükséges a predikálásnál
output_bag = bag;

%% képek törlése memóriából -> a jellemzõket kinyertük, képeket kiértékeltük
% delete(trainingSets)
clear imgSetTrain;
clear bag;

%% opcionális: modell mentése
% save('classifier_1', 'categoryClassifier')

end