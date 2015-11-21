function [features, featureMetrics] = extractSIFTGrey(I)
%	EXTRACTSIFTGREY	Feature kinyer�st v�gez a SIFT m�dszerrel a megadott
%	k�p sz�rke�rnyalatos v�ltozat�n.

%%	El�feldolgoz�s
	size(I)
	Igrey = single(rgb2gray(I));
	maxI = max(Igrey(:));
	Igrey = (Igrey ./ maxI) .* 255.0;
	
%%	Feature kinyer�s
	[points, features] = vl_sift(Igrey);
	points = points';
	features = features';
	featureMetrics = points(:,3);
	
%%	Debug info
	fprintf('%d detektalt feature\n', size(features, 1));
	
%%	Megjelen�t�s
% 	centers = points(:,3);
% 	centers = centers + abs(min(points(:)));
% 	figure; imshow(Igrey, []);
% 	viscircles([points(:,1), points(:,2)], centers, 'EdgeColor', 'g', 'DrawBackgroundCircle', 0, 'LineWidth', 1);

end

