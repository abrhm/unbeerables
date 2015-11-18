function [return_label, return_score] = classifySingleSimpleSVM(img, classifier)
% Kiértékelõ fgv., amely egy tanító osztályzóval klasszifikál input képet
% input:
%   img - kép, amire predikciót akarunk mondani:
%       img egy ImgSet objektum, vagy egy string (file + path)
%   classifier - a tanító fgv. által létrehozott osztályozó objektum
%       vagy egy elmentett osztályozó betöltésére szolgáló string (file+path)
%
%   NOTE: Work in progress!
%   Folyamat, paraméterek, illetve megvalósítás részletessége változhat!
%

if ischar(img) == 1
    imread(fullfile(img));
end
    
if isobject(classifier)
    [labelIdx, score] = predict(classifier, img);
    return_label = classifier.Labels(labelIdx);
    return_score = score;
    
elseif ischar(classifier) == 1
    load(classifier, 'categoryClassifier');
    
    [labelIdx, score] = predict(categoryClassifier, img);
    return_label = categoryClassifier.Labels(labelIdx);
    return_score = score;
else
    error('Parameter classifier is not valid!')
end
    
end
