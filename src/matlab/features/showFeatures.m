function [] = showFeatures(pathImage, noOfPoints, filenames)
% SHOWFEATURES Megjeleníti a megadott képen érzékelt feature pontokat a
% kép szürkeárnyalatos és HSV példányain.
%	pathImage	Kép elérési útvonala
%	noOfPoints	Feature pontok számának felsõ korlátja (ha <=0, akkor összes)
%	filenames	Kimeneti fájlnevek az ábráknak (cell arrayben)

%%	Init
	imageRGB = imread(pathImage);    
	noOfFigures = 3;
	figs = gobjects(1, noOfFigures);

	
%% 	SURF - Szürkeárnyalatos
	image = rgb2gray(imageRGB);
	pointsGrey = detectSURFFeatures(image);
	if (0 < noOfPoints)
		[~, validPoints] = extractFeatures(image, pointsGrey.selectStrongest(noOfPoints));
	else
		[~, validPoints] = extractFeatures(image, pointsGrey);
	end
	
	figs(1) = figure;
	imshow(imageRGB);
	hold on; plot(validPoints, 'showOrientation', true);	hold off;
	title('Greyscale SURF Features');

	
%% 	SURF - HSV
	imageHSV = rgb2hsv(imageRGB);
	pointsHSV.h = detectSURFFeatures(imageHSV(:,:,1));
	pointsHSV.s = detectSURFFeatures(imageHSV(:,:,2));
	pointsHSV.v = detectSURFFeatures(imageHSV(:,:,3));
	
	if (0 < noOfPoints)
		[~, validPtsHSV.h] = extractFeatures(imageHSV(:,:,1), pointsHSV.h.selectStrongest(noOfPoints));
		[~, validPtsHSV.s] = extractFeatures(imageHSV(:,:,2), pointsHSV.s.selectStrongest(noOfPoints));
		[~, validPtsHSV.v] = extractFeatures(imageHSV(:,:,3), pointsHSV.v.selectStrongest(noOfPoints));	
	else
		[~, validPtsHSV.h] = extractFeatures(imageHSV(:,:,1), pointsHSV.h);
		[~, validPtsHSV.s] = extractFeatures(imageHSV(:,:,2), pointsHSV.s);
		[~, validPtsHSV.v] = extractFeatures(imageHSV(:,:,3), pointsHSV.v);
	end	
		
	figs(2) = figure;
	subplot(1, 3, 1);
		imshow(imageHSV(:,:,1));
		hold on; plot(validPtsHSV.h, 'showOrientation', true); hold off;
		title('Hue SURF Features');
	subplot(1, 3, 2);
		imshow(imageHSV(:,:,2));
		hold on; plot(validPtsHSV.s, 'showOrientation', true); hold off;
		title('Saturation SURF Features');
	subplot(1, 3, 3);
		imshow(imageHSV(:,:,3));
		hold on; plot(validPtsHSV.v, 'showOrientation', true); hold off;
		title('Value SURF Features');


%%	MSER
	regionsHSV.h = detectMSERFeatures(imageHSV(:,:,1));
	regionsHSV.s = detectMSERFeatures(imageHSV(:,:,2));
	regionsHSV.v = detectMSERFeatures(imageHSV(:,:,3));
	
	[~, validRegionsHSV.h] = extractFeatures(imageHSV(:,:,1), regionsHSV.h);
	[~, validRegionsHSV.s] = extractFeatures(imageHSV(:,:,2), regionsHSV.s);
	[~, validRegionsHSV.v] = extractFeatures(imageHSV(:,:,3), regionsHSV.v);
	
	figs(3) = figure;
	subplot(1, 3, 1);
		imshow(imageHSV(:,:,1));
		hold on;
		plot(regionsHSV.h, 'showPixelList', true,'showEllipses', false);
		hold off;
		title('Hue MSER Regions');
	subplot(1, 3, 2);
		imshow(imageHSV(:,:,2));
		hold on;
		plot(regionsHSV.s, 'showPixelList', true,'showEllipses', false);
		hold off;
		title('Saturation MSER Regions');
	subplot(1, 3, 3);
		imshow(imageHSV(:,:,3));
		hold on;
		plot(regionsHSV.v, 'showPixelList', true,'showEllipses', false);
		hold off;
		title('Value MSER Regions');

		
%% 	Export képfájlokba
	if (3 <= nargin)
		for i = 1:noOfFigures
			print(figs(i), char(filenames(i)), '-djpeg', '-r300');
		end
	end
	
end
