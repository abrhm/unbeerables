function [return_label, return_score] = classifySingleSimpleSVM(img, classifier)
% Ki�rt�kel� fgv., amely egy tan�t� oszt�lyz�val klasszifik�l input k�pet
% 
% input:
%   in_img - k�p, amire predikci�t akarunk mondani:
%       img egy ImgSet objektum, vagy egy string (file + path)
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
    img = imread(fullfile(img));
end

% Az oszt�lyoz� visszaad egy score vektort, amiben a vesztes�gek vannak.
% Ezekb�l a legnagyobbhoz tartoz� oszt�ly c�mk�j�t fogja hozz�rendelni
% a k�phez.
% A vesztes�g �n. neg�lt bin�ris vesztes�g, amit egy vesztes�gfgv-el
% sz�m�t ki az oszt�lyoz�.
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
