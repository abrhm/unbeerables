function [features, featureMetrics] = extractSURFGrey(I)
%	EXTRACTSURFGREY	Feature kinyerést végez a SURF módszerrel a megadott
%	kép szürkeárnyalatosra konvertált változatán.

%%	Elõfeldolgozás
	Igrey = single(rgb2gray(I));
	maxI = max(Igrey(:));
	Igrey = (Igrey ./ maxI) .* 255.0;
	Igrey = uint8(round(Igrey));

%%	Feature kinyerés
	[points] = detectSURFFeatures(Igrey);
	[features, validPoints] = extractFeatures(Igrey, points);
	featureMetrics = validPoints.Scale;

%%	Debug info
	fprintf('%d detektalt feature\n', size(features, 1));
	
%%	Megjelenítés
% 	imshow(Igrey, []);
% 	hold on;
% 	plot(validPoints);
% 	hold off;
	
end
