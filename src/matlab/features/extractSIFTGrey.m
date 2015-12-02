function [features, featureMetrics] = extractSIFTGrey(I)
%	EXTRACTSIFTGREY	Feature kinyerést végez a SIFT módszerrel a megadott
%	kép szürkeárnyalatos változatán.

%%	Elõfeldolgozás
	if (3 <	size(I, 3))
		I = I(:,:,1:3);
	end
	Igrey = single(rgb2gray(I));
	maxI = max(Igrey(:));
	Igrey = (Igrey ./ maxI) .* 255.0;
	
%%	Feature kinyerés
	[points, features] = vl_sift(Igrey);
	points = points';
	features = double(features');
	featureMetrics = points(:,3);
	
%%	Debug info
% 	fprintf('%d detektalt feature\n', size(features, 1));
	
%%	Megjelenítés
% 	centers = points(:,3);
% 	centers = centers + abs(min(points(:)));
% 	figure; imshow(Igrey, []);
% 	viscircles([points(:,1), points(:,2)], centers, 'EdgeColor', 'g', 'DrawBackgroundCircle', 0, 'LineWidth', 1);

end

