function [features, featureMetrics] = extractDSIFTGrey(I)
%	EXTRACTDSIFTGREY Feature kinyer�st v�gez a DSIFT m�dszerrel a megadott 
%	k�p sz�rke�rnyalatos v�ltozat�n.

%%	El�feldolgoz�s
	if (3 <	size(I, 3))
		I = I(:,:,1:3);
	end
	Igrey = single(rgb2gray(I));
	maxI = max(Igrey(:));
	Igrey = (Igrey ./ maxI) .* 255.0;
	
%%	Feature kinyer�s
	dsiftSteps = 5;
	[points, features] = vl_dsift(Igrey, 'step', dsiftSteps, 'FloatDescriptors', 'Fast');
	points = points';
	features = features';
% 	featureMetrics = points(:,3);
	featureMetrics = repmat(1.0, size(points, 1), 1);
	
%%	Debug info
% 	fprintf('%d detektalt feature\n', size(features, 1));
	
%%	Megjelen�t�s
% 	centers = points(:,3);
% 	centers = centers + abs(min(points(:)));
% 	figure; imshow(Igrey, []);
% 	viscircles([points(:,1), points(:,2)], centers, 'EdgeColor', 'g', 'DrawBackgroundCircle', 0, 'LineWidth', 1);

end

