function [features, featureMetrics] = extractSIFTHue(I)
%	EXTRACTSIFTHUE	Feature kinyerést végez a SIFT módszerrel a megadott
%	kép HSV-re konvertált változatának hue csatornáján.

%%	Elõfeldolgozás
	Ihsv = single(rgb2hsv(I));
	Ihue = Ihsv(:,:,1);
	maxI = max(Ihue(:));
	Ihue = (Ihue ./ maxI) .* 255.0;

%%	Feature kinyerés
	[points, features] = vl_sift(Ihue);
	featureMetrics = points(3,:);

%%	Debug info
	fprintf('%d detektalt feature\n', size(features, 1));
	
%%	Megjelenítés
% 	centers = points(:,3);
% 	centers = centers + abs(min(points(:)));
% 	figure; imshow(Igrey, []);
% 	viscircles([points(:,1), points(:,2)], centers, 'EdgeColor', 'g', 'DrawBackgroundCircle', 0, 'LineWidth', 1);
	
end
