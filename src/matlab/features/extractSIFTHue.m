function [features, featureMetrics] = extractSIFTHue(I)
%	EXTRACTSIFTHUE	Feature kinyer�st v�gez a SIFT m�dszerrel a megadott
%	k�p HSV-re konvert�lt v�ltozat�nak hue csatorn�j�n.

%%	El�feldolgoz�s
	if (3 <	size(I, 3))
		I = I(:,:,1:3);
	end
	Ihsv = single(rgb2hsv(I));
	Ihue = Ihsv(:,:,1);
	maxI = max(Ihue(:));
	Ihue = (Ihue ./ maxI) .* 255.0;

%%	Feature kinyer�s
	[points, features] = vl_sift(Igrey);
	points = points';
	features = features';
	featureMetrics = points(:,3);

%%	Debug info
% 	fprintf('%d detektalt feature\n', size(features, 1));
	
%%	Megjelen�t�s
% 	centers = points(:,3);
% 	centers = centers + abs(min(points(:)));
% 	figure; imshow(Igrey, []);
% 	viscircles([points(:,1), points(:,2)], centers, 'EdgeColor', 'g', 'DrawBackgroundCircle', 0, 'LineWidth', 1);
	
end
