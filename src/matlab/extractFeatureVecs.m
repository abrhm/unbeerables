function [classes, allLabels, allFeatures] = extractFeatureVecs(imagePath, featureType, pointsPerImage, featureVecLength)
% EXTRACTFEATUREVECS A megadott mappából betölti az összes képet és a megadott 
% módszerrel kinyeri a kiemelt pontok helyén a feature vektorokat.
% vektorokat.
%	imagePath		elérési útvonal
%	featureType		alkalmazott módszer neve (surf, mser)
%	pointsPerImage	pontok maximális száma
%	allFeatures		feature vektorokból álló mátrix
%	allLabels		címkevektor
%	classes			címkékhez társuló osztály neve

%%  Paraméterezés és import
	narginchk(2, 4);
	nargoutchk(3, 3);
	if (nargin < 4)
		featureVecLength = 64;
	end	
	images = imageSet(imagePath, 'recursive');
	featureType = upper(featureType);
	
%%  Feature-kinyerés a mappa elemeibõl
	allFeatures = [];
	allLabels = [];
	classes = [];
	noOfLabels = numel(images);
	fprintf('Feature vektor hossz = %d\n', featureVecLength);
	fprintf('Feature pont/kep = %d\n', pointsPerImage);	
	fprintf('%d cimke betoltve: "%s".\n', numel(images), imagePath);
	
% 	Címkeosztályonként feldolgozzuk a képfájlokat
	for i = 1:noOfLabels
		noOfImages = images(i).Count;
		classes(i).id = i;
		classes(i).name = images(i).Description;		
		imageFeatures = [];
		fprintf('Cimke #%d: %s (%d kep betoltve)\n', i, images(i).Description, noOfImages);		
        for j = 1:noOfImages
			imageRGB = imread(images(i).ImageLocation{j});
 			imageHSV = rgb2hsv(imageRGB);
			pointsProcessed = 0;
            switch featureType
%				SURF: a kép szürkeárnyalatos verzióján fut a SURF
                case 'SURF_GREY'
					imageGrey = rgb2gray(imageRGB);
					points = detectSURFFeatures(imageGrey);
					[surf, ~] = extractFeatures(imageGrey, points.selectStrongest(pointsPerImage));
					imageFeatures = [imageFeatures; surf];
					pointsProcessed = pointsProcessed + size(surf, 1);
%				SURF: HSV csatornák vektorai egy (3 × featureVecLength)-hosszú vektorba mennek
                case 'SURF_HSV_HCON'
					featuresRowPtr = size(imageFeatures, 1) + 1;
                    for k = 1:size(imageRGB, 3)
                        channel = imageHSV(:,:,k);
                        points = detectSURFFeatures(channel);
                        [surf, ~] = extractFeatures(channel, points.selectStrongest(pointsPerImage));
                        imageFeatures(featuresRowPtr:featuresRowPtr+size(surf,1)-1, ((k-1)*featureVecLength)+1:k*featureVecLength) = surf;               
                        pointsProcessed = pointsProcessed + size(surf, 1);
					end
% 				SURF: HSV csatornák vektorai egymás után kerülnek be a mátrixba
                case 'SURF_HSV_VCON'
                    for k = 1:size(imageRGB, 3)
                        channel = imageHSV(:,:,k);
                        points = detectSURFFeatures(channel);
                        [surf, ~] = extractFeatures(channel, points.selectStrongest(pointsPerImage));
						imageFeatures = [imageFeatures; surf];
                        pointsProcessed = pointsProcessed + size(surf, 1);
					end
% 				MSER: a MSER detektált pontjaiban SURF vektorokat számolunk
				case 'MSER_SURF'
					error('Meg nem implementalt.');
				otherwise
					error('A parameterben megadott feature nem letezik vagy meg nem implementalt.');
            end
			fprintf('\t%d feature pont betoltve: %s\n', pointsProcessed, images(i).ImageLocation{j});
		end
		allFeatures = [allFeatures; imageFeatures];
		allLabels = [allLabels; repmat(i, size(imageFeatures, 1), 1)];
    end

end
