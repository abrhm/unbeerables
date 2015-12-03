function [categoryClassifier,output_msgBag, output_msgTrainer] = trainSingleSimpleSVM(imgSetTrain, featureExtractHandle, validify, wordNumber, strongestFeatures)
%% Tan�t�, amely a Bag of Visual Words modellt haszn�lja
% k�pekb�l kinyert jellemz�k transzform�l�s�ra
% olyan feature vektorr�, ami klasszifik�lhat� SVM-el.
%
% input:
%   imgSetTrain - k�phalmaz, amikre be akarjuk tan�tani az oszt�lyoz�t
%   featureExtractHandle - custom function handle, ami szolg�ltatja
%       az �ltalunk megval�s�tott jellemz�kinyer�st
%   validify - akarunk-e ki�rt�kelni train halmazon?
%       (mag�val vonja az eredeti halmaz feloszt�s�t �s �rt�kel�s�t -
%       TESZTEL�S C�LJ�B�L)
%   wordNumber - a sz�t�runkba fel�rand� szavak sz�ma, �s �gy a kalszterek
%       sz�ma, meghat�rozza a vizu�lis szavak sz�m�t (default: 64)
%   strongestFeatures - a bag of visual words objektum a kinyert leger�sebb
%       jellemz�k mekkora h�nyad�t haszn�lja fel
%
% output:
%   categoryClassifier - betan�tott ECOC framework-el ell�tott SVM
%       oszt�lyoz�
%   output_msgBag, output_msgTrainer - inform�ci�k dolgokr�l
%
% NOTE: Work in progress!
% Folyamat, param�terek, illetve megval�s�t�s r�szletess�ge v�ltozhat!
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
% Milyen k�pekre tanul r�
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

%% 1. l�p�s:
% Bag of visual words l�trehoz�sa, ami k-means klaszterez�st haszn�l
% a megfelel� szepar�l�shoz; a klaszterek pedig az egyes visual word-�knek
% felelnek meg, amib�l hisztogramot �ll�tunk el� �s azt adjuk tov�bb.
% A feature detekt�l�s
%   vagy a be�p�tett SURF algoritmussal dolgoz� elj�r�ssal,
%   vagy �ltalunk l�trehozott feature detektor function-nal t�rt�nik.
if useSURF == true
    bag = bagOfFeatures(imgSetTrain, 'Verbose', false, 'VocabularySize', wordNumber, 'PointSelection', 'Detector', 'StrongestFeatures', strongestFeatures);
    output_msgBag = evalc('disp(bag)');
else
    bag = bagOfFeatures(imgSetTrain,'CustomExtractor', featureExtractHandle, 'Verbose', false, 'VocabularySize', wordNumber, 'StrongestFeatures', strongestFeatures);
    output_msgBag = evalc('disp(bag)');
end

%% 2. l�p�s: (train)
% K�p klasszifik�l� SVM-et hozunk l�tre
% az el�z� l�p�sben kapott hisztogram egy vektor, amit �tadunk az SVM
% oszt�lyoz�nak.
% TODO: templateSVM-et be kell l�ni
opts = templateSVM('BoxConstraint', 1.3, 'KernelFunction', 'gaussian');
categoryClassifier = trainImageCategoryClassifier(imgSetTrain, bag, 'LearnerOptions', opts);
msg1 = 'Tanitasi modell: one-vs-one egyszeru tanitoval';

%% k�pek t�rl�se mem�ri�b�l -> a jellemz�ket kinyert�k, k�peket ki�rt�kelt�k
% delete(trainingSets)
clear imgSetTrain;
clear bag;

%% opcion�lis: modell ment�se
% save('classifier_1', 'categoryClassifier')

%% opcion�lis: valid�l�s eredm�nyei
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
