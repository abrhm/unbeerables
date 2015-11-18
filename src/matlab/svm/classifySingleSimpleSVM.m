function [return_label, return_score] = classifySingleSimpleSVM(img, classifier)
% Ki�rt�kel� fgv., amely egy tan�t� oszt�lyz�val klasszifik�l input k�pet
% input:
%   img - k�p, amire predikci�t akarunk mondani:
%       img egy ImgSet objektum, vagy egy string (file + path)
%   classifier - a tan�t� fgv. �ltal l�trehozott oszt�lyoz� objektum
%       vagy egy elmentett oszt�lyoz� bet�lt�s�re szolg�l� string (file+path)
%
%   NOTE: Work in progress!
%   Folyamat, param�terek, illetve megval�s�t�s r�szletess�ge v�ltozhat!
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
