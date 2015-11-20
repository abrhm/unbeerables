function [return_label, return_score] = classifyECOCSVM(img, bagOfWords, classifier)
%% Kiértékelõ fgv., amely egy tanító osztályzóval klasszifikál input képet
% 
% input:
%   img - kép, amire predikciót akarunk mondani:
%       img egy ImgSet objektum, vagy egy string (file + path)
%       (lehetséges több képet is megadni ebben a változóban, de az nincs
%        lekezelve)
%   bagOfWords - létrehozott bag of visual words objektum, amit a tanítóban
%       hoztunk létre; itt azért szükséges, mert azzal tudjuk elõállítani
%       a kapott képrõl a hisztogram-jellemzõ vektort
%   classifier - a tanító fgv. által létrehozott osztályozó objektum
%       vagy egy elmentett osztályozó betöltésére szolgáló string (file+path)
%
% output:
%   return_label - eredmény címke
%   return score - valószínûség, ami alapján a megfelelõ címkét adta
%
%   NOTE: Work in progress!
%   Folyamat, paraméterek, illetve megvalósítás részletessége változhat!
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