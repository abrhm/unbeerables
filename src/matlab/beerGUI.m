function [] = beerGUI(windowHeight, windowWidth, windowLeftMargin, windowTopMargin)
%	BEERGUI A rendszerhez interf�szt biztos�t� GUI megval�s�t�sa.
%	windowHeight		ablak sz�less�ge
%	windowWidth			ablak magass�ga
%	windowLeftMargin	ablak t�vols�ga a kijelz� bal hat�r�t�l
%	windowTopMargin		ablak t�vols�ga a kijelz� fels� hat�r�t�l
%	Szerz�:	Sajtos Gyula

%%	Glob�lis v�ltoz�k
	I = [];
	featureHandles = [];
	featureIdx = 1;
	trainSet = [];
	classifier = [];
	roiHandler = [];

	
%%	Ablak param�terei	
	if (nargin == 0)
		windowHeight = 480;
		windowWidth = 640;
		windowLeftMargin = 100;
		windowTopMargin = 100;
	end
	screenDim = get(groot, 'ScreenSize');
	windowBottomMargin = screenDim(4) - (windowTopMargin + windowHeight);
	window = figure('Position', [windowLeftMargin, windowBottomMargin, windowWidth, windowHeight], ...
		'MenuBar', 'none', 'Visible', 'off', 'Name', 'Log�felismer�s', 'NumberTitle', 'off');
	
	
%%	Komponensek
	fileMenu = uimenu(window, 'Label', 'F�jl');
		loadImageMI = uimenu(fileMenu, 'Label', 'Bet�lt�s...', 'Callback', @loadImageCB, 'Accelerator', 'o');
	featureMenu = uimenu(window, 'Label', 'Feature');
		featureHandles(1) = uimenu(featureMenu, 'Label', 'SURF (sz�rke)', 'Callback', {@selectFeatureCB, 1});
		featureHandles(2) = uimenu(featureMenu, 'Label', 'SIFT (sz�rke)', 'Callback', {@selectFeatureCB, 2});
		featureHandles(3) = uimenu(featureMenu, 'Label', 'SIFT (HSV)', 'Callback', {@selectFeatureCB, 3});
		set(featureHandles(featureIdx), 'Checked', 'on');
	learningMenu = uimenu(window, 'Label', '�gens');
		dbPathMI = uimenu(learningMenu, 'Label', 'Adatb�zis kijel�l�se...', 'Callback', @loadTrainDirCB, 'Accelerator', 'd');
		learnMI = uimenu(learningMenu, 'Label', 'Tan�t�s', 'Callback', @trainCB);
	classifyMenu = uimenu(window, 'Label', 'Detekt�l�s');
		roiMI = uimenu(classifyMenu, 'Label', 'ROI kijel�l�se...', 'Callback', @selectRoiCB);
		estimateMI = uimenu(classifyMenu, 'Label', 'Becsl�s', 'Callback', @classifyCB);
	imageDisplay = axes('Parent', window, 'Visible', 'off');
	window.Visible = 'on';
	
	
%%	Callback f�ggv�nyek
	function loadImageCB(source, event)
		[filename, path] = uigetfile({'*.jpg'; '*.png'; '*.tif'; '*.gif'}, 'K�p bet�lt�se');
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
		trainPath = uigetdir('', 'Tanul�adatb�zis bet�lt�se');
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
% 			itt oszt�lyoz�s �s eredm�ny megjelen�t�se
% 			figure, imshow(I_roi);
		else
			fprintf('Modell elavult: frissites szukseges.\n');
		end
	end

	function selectRoiCB(source, event)
		delete(roiHandler);
		roiHandler = imrect(imageDisplay);
	end
	

%%	Feature-kinyer�k
	function [] = extractSIFT()
	end


end

