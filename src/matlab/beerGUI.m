function [] = beerGUI(windowHeight, windowWidth, windowLeftMargin, windowTopMargin)
%	BEERGUI A rendszerhez interfészt biztosító GUI megvalósítása.
%	windowHeight		ablak szélessége
%	windowWidth			ablak magassága
%	windowLeftMargin	ablak távolsága a kijelzõ bal határától
%	windowTopMargin		ablak távolsága a kijelzõ felsõ határától
%	Szerzõ:	Sajtos Gyula

%%	Globális változók
	I = [];
	featureHandles = [];
	featureIdx = 1;
	trainSet = [];
	classifier = [];
	roiHandler = [];

	
%%	Ablak paraméterei	
	if (nargin == 0)
		windowHeight = 480;
		windowWidth = 640;
		windowLeftMargin = 100;
		windowTopMargin = 100;
	end
	screenDim = get(groot, 'ScreenSize');
	windowBottomMargin = screenDim(4) - (windowTopMargin + windowHeight);
	window = figure('Position', [windowLeftMargin, windowBottomMargin, windowWidth, windowHeight], ...
		'MenuBar', 'none', 'Visible', 'off', 'Name', 'Logófelismerés', 'NumberTitle', 'off');
	
	
%%	Komponensek
	fileMenu = uimenu(window, 'Label', 'Fájl');
		loadImageMI = uimenu(fileMenu, 'Label', 'Betöltés...', 'Callback', @loadImageCB, 'Accelerator', 'o');
	featureMenu = uimenu(window, 'Label', 'Feature');
		featureHandles(1) = uimenu(featureMenu, 'Label', 'SURF (szürke)', 'Callback', {@selectFeatureCB, 1});
		featureHandles(2) = uimenu(featureMenu, 'Label', 'SIFT (szürke)', 'Callback', {@selectFeatureCB, 2});
		featureHandles(3) = uimenu(featureMenu, 'Label', 'SIFT (HSV)', 'Callback', {@selectFeatureCB, 3});
		set(featureHandles(featureIdx), 'Checked', 'on');
	learningMenu = uimenu(window, 'Label', 'Ágens');
		dbPathMI = uimenu(learningMenu, 'Label', 'Adatbázis kijelölése...', 'Callback', @loadTrainDirCB, 'Accelerator', 'd');
		learnMI = uimenu(learningMenu, 'Label', 'Tanítás', 'Callback', @trainCB);
	classifyMenu = uimenu(window, 'Label', 'Detektálás');
		roiMI = uimenu(classifyMenu, 'Label', 'ROI kijelölése...', 'Callback', @selectRoiCB);
		estimateMI = uimenu(classifyMenu, 'Label', 'Becslés', 'Callback', @classifyCB);
	imageDisplay = axes('Parent', window, 'Visible', 'off');
	window.Visible = 'on';
	
	
%%	Callback függvények
	function loadImageCB(source, event)
		[filename, path] = uigetfile({'*.jpg'; '*.png'; '*.tif'; '*.gif'}, 'Kép betöltése');
		I = imread([path filename]);
		axes(imageDisplay);
		imshow(I, 'InitialMagnification', 'fit');
		fprintf('Kep betoltve: %s%s"\n', path, filename);
	end

	function selectFeatureCB(source, event, newFeatureIdx)
		if (newFeatureIdx ~= featureIdx)
			set(featureHandles(newFeatureIdx), 'Checked', 'on');
			set(featureHandles(featureIdx), 'Checked', 'off');
			featureIdx = newFeatureIdx;
			classifier = [];
		end
	end
	
	function loadTrainDirCB(source, event)
		trainPath = uigetdir('', 'Tanulóadatbázis betöltése');
		if trainPath ~= 0
			trainSet = imageSet(trainPath);
			fprintf('Tanulo adatbazis kijelolve: %s\n', trainPath);
		end		
	end

	function trainCB(source, event)
		classifier = trainSingleSimpleSVM(trainSet, featureIdx, false)
		fprintf('Modell felepitve.\n');
	end

	function classifyCB(source, event)
		if ~isempty(classifier) && isvalid(roiHandler)
			M = createMask(roiHandler);
			P = getPosition(roiHandler);
			P = round(P);
			I_roi(:,:,:) = I(P(2):P(2)+P(4), P(1):P(1)+P(3), :);
% 			itt osztályozás és eredmény megjelenítése
% 			figure, imshow(I_roi);
		else
			fprintf('Modell elavult: frissites szukseges.\n');
		end
	end

	function selectRoiCB(source, event)
		delete(roiHandler);
		roiHandler = imrect(imageDisplay);
	end
	

%%	Feature-kinyerõk
	function [] = extractSIFT()
	end


end

