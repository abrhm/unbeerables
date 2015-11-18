function [return_label, return_score] = classifySingleSimpleSVM(img, classifier)
% Kiértékelõ fgv., amely egy tanító osztályzóval klasszifikál input képet
% 
% input:
%   in_img - kép, amire predikciót akarunk mondani:
%       img egy ImgSet objektum, vagy egy string (file + path)
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
    img = imread(fullfile(img));
end

% Az osztályozó visszaad egy score vektort, amiben a veszteségek vannak.
% Ezekbõl a legnagyobbhoz tartozó osztály címkéjét fogja hozzárendelni
% a képhez.
% A veszteség ún. negált bináris veszteség, amit egy veszteségfgv-el
% számít ki az osztályozó.
if isobject(classifier)
    [labelIdx, score] = predict(classifier, img);
    return_label = classifier.Labels(labelIdx);
    return_score = max(score);
    
elseif ischar(classifier) == 1
    load(classifier, 'categoryClassifier');
    
    [labelIdx, score] = predict(categoryClassifier, img);
    return_label = categoryClassifier.Labels(labelIdx);
    return_score = max(score);
else
    error('Parameter classifier is not valid!')
end
    
end
