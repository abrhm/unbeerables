function [categoryClassifier] = trainSingleSimpleSVM(imgSetTrain, featureExtractHandle, validify)
% Tan�t�, amely a Bag of Visual Words modellt haszn�lja
% k�pekb�l kinyert SIFT jellemz�k transzform�l�s�ra
% olyan feature vektorr�, ami klasszifik�lhat� SVM-el.
% input:
%   imgSetTrain - k�phalmaz, amikre be akarjuk tan�tani az oszt�lyoz�t
%   featureExtractHandle - custom function handle, ami szolg�ltatja
%       az �ltalunk megval�s�tott jellemz�kinyer�st
%   validify - akarunk-e ki�rt�kelni train halmazon?
%       (mag�val vonja az eredeti halmaz feloszt�s�t �s �rt�kel�s�t -
%       TESZTEL�S C�LJ�B�L)
%
% NOTE: Work in progress!
% Folyamat, param�terek, illetve megval�s�t�s r�szletess�ge v�ltozhat!
%

% Check input
useSURF = false;
if ~isa(featureExtractHandle, 'function_handle') || isempty(imgSetTrain)
       useSURF = true;
end

if isempty(imgSetTrain)
    main_folder = 'D:\debug\small';
    imgSetTrain = imageSet(main_folder, 'recursive');
end

if islogical(validify)
    if validify == true
        minSetCount = min([imgSetTrain.Count]);
        imgSetsPart = partition(imgSetTrain, minSetCount, 'randomize');
        [imgSetTrain, validateSet] = partition(imgSetsPart, 0.3, 'randomize')
    end
end

% 1. l�p�s:
% Bag of visual words l�trehoz�sa, ami k-means klaszterez�st haszn�l
% a megfelel� szepar�l�shoz; a klaszterek pedig az egyes visual word-�knek
% felelnek meg, amib�l hisztogramot �ll�tunk el� �s azt adjuk tov�bb
% �ltalunk l�trehozott feature detektor function-t�l kapja az inputot.
if useSURF == true
    bag = bagOfFeatures(imgSetTrain, 'Verbose', false, 'VocabularySize', 200)
else
    bag = bagOfFeatures(imgSetTrain,'CustomExtractor', featureExtractHandle)
end

% 2. l�p�s: (train)
% K�p klasszifik�l� SVM-et hozunk l�tre
% az el�z� l�p�sben kapott hisztogram egy vektor, amit �tadunk az SVM
% oszt�lyoz�nak.
% TODO: templateSVM-et be kell l�ni
% opts = templateSVM('BoxConstraint', 1.1, 'KernelFunction', 'gaussian');
categoryClassifier = trainImageCategoryClassifier(imgSetTrain, bag); %, 'LearnerOptions', opts);

% k�pek t�rl�se mem�ri�b�l -> a jellemz�ket kinyert�k, k�peket ki�rt�kelt�k
% delete(trainingSets)
clear imgSetTrain;
clear bag;

% opcion�lis: modell ment�se
% save('classifier_1', 'categoryClassifier')

% opcion�lis: valid�l�s eredm�nyei
if validify == true
    confMatrix = evaluate(categoryClassifier, validateSet)
    mean(diag(confMatrix))
end
