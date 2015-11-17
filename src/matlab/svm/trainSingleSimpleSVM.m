function [categoryClassifier] = trainSingleSimpleSVM(imgSetTrain, featureExtractHandle, validify)
% Tanító, amely a Bag of Visual Words modellt használja
% képekbõl kinyert SIFT jellemzõk transzformálására
% olyan feature vektorrá, ami klasszifikálható SVM-el.
% input:
%   imgSetTrain - képhalmaz, amikre be akarjuk tanítani az osztályozót
%   featureExtractHandle - custom function handle, ami szolgáltatja
%       az általunk megvalósított jellemzõkinyerést
%   validify - akarunk-e kiértékelni train halmazon?
%       (magával vonja az eredeti halmaz felosztását és értékelését -
%       TESZTELÉS CÉLJÁBÓL)
%
% NOTE: Work in progress!
% Folyamat, paraméterek, illetve megvalósítás részletessége változhat!
%

% Check input
useSURF = false;
if ~isa(featureExtractHandle, 'function_handle') || isempty(imgSetTrain)
       useSURF = true;
end

if isempty(imgSetTrain)
    main_folder = 'D:\matlab_proj\gray';
    imgSetTrain = imageSet(main_folder, 'recursive');
end

if islogical(validify)
    if validify == true
        minSetCount = min([imgSetTrain.Count]);
        imgSetsPart = partition(imgSetTrain, minSetCount, 'randomize');
        %imgSetsPart = partition(imgSetTrain, minSetCount, 'sequential');
        [imgSetTrain, validateSet] = partition(imgSetsPart, 0.4, 'randomize')
        %[imgSetTrain, validateSet] = partition(imgSetTrain, 0.4, 'randomize')
        %[imgSetTrain, validateSet] = partition(imgSetsPart, 0.4, 'sequential')
    end
end

% Debug information
% Milyen képekre tanul rá
str = 'imgSetTrain contents: ';
disp(str)
dbg = [imgSetTrain.ImageLocation];
dbg{:};
s = size(dbg);
for i=1:s(end)
	a = dbg(i);
	aa = regexp(a,'\','split');
	aa1 = aa{:};
	aa1 = aa1(end);
    disp(aa1)
end

% 1. lépés:
% Bag of visual words létrehozása, ami k-means klaszterezést használ
% a megfelelõ szeparáláshoz; a klaszterek pedig az egyes visual word-öknek
% felelnek meg, amibõl hisztogramot állítunk elõ és azt adjuk tovább.
% A feature detektálás
%   vagy a beépített SURF algoritmussal dolgozó eljárással,
%   vagy általunk létrehozott feature detektor function-nal történik.
if useSURF == true
    bag = bagOfFeatures(imgSetTrain, 'Verbose', false, 'VocabularySize', 64, 'PointSelection', 'Detector')
else
    bag = bagOfFeatures(imgSetTrain,'CustomExtractor', featureExtractHandle)
end

% 2. lépés: (train)
% Kép klasszifikáló SVM-et hozunk létre
% az elõzõ lépésben kapott hisztogram egy vektor, amit átadunk az SVM
% osztályozónak.
% TODO: templateSVM-et be kell lõni
opts = templateSVM('BoxConstraint', 1.3, 'KernelFunction', 'gaussian');
categoryClassifier = trainImageCategoryClassifier(imgSetTrain, bag, 'LearnerOptions', opts);

% képek törlése memóriából -> a jellemzõket kinyertük, képeket kiértékeltük
% delete(trainingSets)
clear imgSetTrain;
clear bag;

% opcionális: modell mentése
% save('classifier_1', 'categoryClassifier')

% opcionális: validálás eredményei
if validify == true
    confMatrix = evaluate(categoryClassifier, validateSet)
    mean(diag(confMatrix))
end
