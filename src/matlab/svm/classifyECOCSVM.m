function [return_label, return_score] = classifyECOCSVM(img, bagOfWords, classifier)
%% Ki�rt�kel� fgv., amely egy tan�t� oszt�lyz�val klasszifik�l input k�pet
% 
% input:
%   img - k�p, amire predikci�t akarunk mondani:
%       img egy ImgSet objektum, vagy egy string (file + path)
%       (lehets�ges t�bb k�pet is megadni ebben a v�ltoz�ban, de az nincs
%        lekezelve)
%   bagOfWords - l�trehozott bag of visual words objektum, amit a tan�t�ban
%       hoztunk l�tre; itt az�rt sz�ks�ges, mert azzal tudjuk el��ll�tani
%       a kapott k�pr�l a hisztogram-jellemz� vektort
%   classifier - a tan�t� fgv. �ltal l�trehozott oszt�lyoz� objektum
%       vagy egy elmentett oszt�lyoz� bet�lt�s�re szolg�l� string (file+path)
%
% output:
%   return_label - eredm�ny c�mke
%   return score - val�sz�n�s�g, ami alapj�n a megfelel� c�mk�t adta
%
%   NOTE: Work in progress!
%   Folyamat, param�terek, illetve megval�s�t�s r�szletess�ge v�ltozhat!
%

if ischar(img) == 1
    testImgSet = imageSet(img);
    img = read(testImgSet(1), 1);
else
    img = read(img(1), 1);
end

if isa(bagOfWords, 'bagOfFeatures')
    featureVector = encode(bagOfWords, img);
end

if isobject(classifier)
    [labelIdx, score] = predict(classifier, featureVector);
    return_label = labelIdx;
    return_score = max(score);
    
elseif ischar(classifier) == 1
    load(classifier, 'categoryClassifier');
    
    [labelIdx, score] = predict(categoryClassifier, featureVector);
    return_label = labelIdx;
    return_score = max(score);
else
    error('Parameter classifier is not valid!')
end

end