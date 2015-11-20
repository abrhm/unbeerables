function [categoryClassifier, output_bag] = trainECOCSVM(imgSetTrain, featureExtractHandle, validify, wordNumber)
%% Tan�t�, amely a Bag of Visual Words modellt haszn�lja
% k�pekb�l kinyert SIFT jellemz�k transzform�l�s�ra
% olyan feature vektorr�, ami klasszifik�lhat� SVM-el.
% 
% A be�p�tett trainImageCategoryClassifier helyett k�zvetlen�l
% h�vjuk meg a fitcecoc fgv-t, amivel t�bb dolgot tudunk be�ll�tani
% a tan�t�st illet�en.
% 
% A bagOfWords objektumb�l kinyerj�k a feature vektorokat, amiket
% �tadunk majd a megfelel�en param�terezett oszt�lyoz�nak.
%
% input:
%   imgSetTrain - k�phalmaz, amikre be akarjuk tan�tani az oszt�lyoz�t
%   featureExtractHandle - custom function handle, ami szolg�ltatja
%       az �ltalunk megval�s�tott jellemz�kinyer�st
%   validify - akarunk-e ki�rt�kelni train halmazon?
%       (mag�val vonja az eredeti halmaz feloszt�s�t �s �rt�kel�s�t -
%       TESZTEL�S C�LJ�B�L)
%
% output:
%   categoryClassifier - betan�tott SVM oszt�lyoz�k egy ECOC
%       keretrendszerben
%   output_bag - bag of visual words objektum, sz�ks�ges a predikci�hoz
%       tesztel� fgv-ben (l�sd calssifyECOCSVM.m)
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

%% Labelek kinyer�se minden k�phez
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

%% 1. l�p�s:
% Bag of visual words l�trehoz�sa, ami k-means klaszterez�st haszn�l
% a megfelel� szepar�l�shoz; a klaszterek pedig az egyes visual word-�knek
% felelnek meg, amib�l hisztogramot �ll�tunk el� �s azt adjuk tov�bb
% �ltalunk l�trehozott feature detektor function-t�l kapja az inputot.
if useSURF == true
    bag = bagOfFeatures(imgSetTrain, 'Verbose', false, 'VocabularySize', wordNumber, 'PointSelection', 'Detector')
else
    bag = bagOfFeatures(imgSetTrain,'CustomExtractor', featureExtractHandle)
end

%% 2. l�p�s: (train)
% K�p klasszifik�l� SVM-et hozunk l�tre.
% A fitcecoc multiclass K(K � 1)/2 SVM bin�ris oszt�lyoz�kat hoz l�tre,
% ahol K az oszt�lyokat jel�li.
% az el�z� l�p�sben kapott hisztogram egy vektor, amit �tadunk az SVM
% oszt�lyoz�nak.
featureMatrix = encode(bag,imgSetTrain);
% be�ll�tjuk az oszt�lyoz�t
opts = templateSVM('BoxConstraint', 1.3, 'KernelFunction', 'gaussian');
categoryClassifier = fitcecoc(featureMatrix,out_label_vector,'Learners',opts);

%% Debug information
% Inform�ci� ki�r�sa a klasszifik�l�r�l
categoryClassifier.ClassNames
% 3 bin�ris tanul� SVM-ek reprezent�l�sa m�trix alakban aszerint, hogy
% melyik a pozit�v oszt�ly, �s melyik a negat�v (sorok: oszt�lyok,
% oszlopok: bin�ris tanul�k/SVM-ek)
CodingMtx = categoryClassifier.CodingMatrix;
disp(CodingMtx)

if validify == true
    % vesztes�g sz�m�t�sa
    % ezzel a 'resubstitution error'-t fogjuk megkapni
    % ez a hiba a rossz klasszifik�ci�kat t�nteti fel
    isLoss = resubLoss(categoryClassifier);
    disp(isLoss)

    % cross-validation: 10 r�szre osztva a tanul� halmazt �rt�kelj�k ki
    % a tanul�kat
    CVcategoryClassifier = crossval(categoryClassifier);
    % felosztott �s ki�rt�kelt modellre kisz�moljuk a vesztes�get hib�s
    % oszt�lyoz�sokra
    oosLoss = kfoldLoss(CVcategoryClassifier);
    disp(oosLoss)
    
    % confusion matrix reprezent�ci�
    oofLoss = kfoldPredict(CVcategoryClassifier);
    confMat = confusionmat(out_label_vector, oofLoss);
    disp(confMat)
end

% Sz�ks�ges a predik�l�sn�l
output_bag = bag;

%% k�pek t�rl�se mem�ri�b�l -> a jellemz�ket kinyert�k, k�peket ki�rt�kelt�k
% delete(trainingSets)
clear imgSetTrain;
clear bag;

%% opcion�lis: modell ment�se
% save('classifier_1', 'categoryClassifier')

end