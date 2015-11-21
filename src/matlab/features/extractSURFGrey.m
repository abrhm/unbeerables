function [features, featureMetrics] = extractSURFGrey(I)
%	EXTRACTSURFGREY	Feature kinyer�st v�gez a SURF m�dszerrel a megadott
%	k�p sz�rke�rnyalatosra konvert�lt v�ltozat�n.

%%	El�feldolgoz�s
	Igrey = single(rgb2gray(I));
	maxI = max(Igrey(:));
	Igrey = (Igrey ./ maxI) .* 255.0;
	Igrey = uint8(round(Igrey));

%%	Feature kinyer�s
	[points] = detectSURFFeatures(Igrey);
	[features, validPoints] = extractFeatures(Igrey, points);
	featureMetrics = validPoints.Scale;

%%	Debug info
	fprintf('%d detektalt feature\n', size(features, 1));
	
%%	Megjelen�t�s
% 	imshow(Igrey, []);
% 	hold on;
% 	plot(validPoints);
% 	hold off;
	
end
