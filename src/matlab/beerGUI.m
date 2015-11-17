function [] = beerGUI(windowHeight, windowWidth, windowLeftMargin, windowTopMargin)
%	BEERGUI A rendszerhez interfészt biztosító GUI megvalósítása.
%	windowHeight		ablak szélessége
%	windowWidth			ablak magassága
%	windowLeftMargin	ablak távolsága a kijelzõ bal határától
%	windowTopMargin		ablak távolsága a kijelzõ felsõ határától

%%	Globális változók
	I = [];
	
	
%%	Ablak paraméterei	
	if (nargin == 0)
		windowHeight = 480;
		windowWidth = 640;
		windowLeftMargin = 200;
		windowTopMargin = 300;
	end
	screenDim = get(groot, 'ScreenSize');
	windowBottomMargin = screenDim(4) - (windowTopMargin + windowHeight);
	window = figure('Position', [windowLeftMargin, windowBottomMargin, windowWidth, windowHeight], ...
		'MenuBar', 'none', 'Visible', 'off', 'Name', 'Logófelismerés', 'NumberTitle', 'off');
	
	
%%	Komponensek	
	fileMenu = uimenu(window, 'Label', 'Fájl');
		loadImageMI = uimenu(fileMenu, 'Label', 'Betöltés...', 'Callback', @loadImageCB);
	featureMenu = uimenu(window, 'Label', 'Feature');
		surfGreyMI = uimenu(featureMenu, 'Label', 'SURF (szürkeárnyalatos)');
		siftGreyMI = uimenu(featureMenu, 'Label', 'SIFT (szürkeárnyalatos)');
		siftHsvMI = uimenu(featureMenu, 'Label', 'SIFT (HSV)');		
	learningMenu = uimenu(window, 'Label', 'Tanulás');
	
	window.Visible = 'on';
	
	
%%	Callback függvények
	function loadImageCB(source, event)
		[filename, path] = uigetfile({'*.jpg'; '*.png'; '*.tif'; '*.gif'}, 'Kép betöltése');
		I = imread([path filename]);
		imageDisp = imshow(I);
		fprintf('Kep betoltve: %s%s"\n', path, filename);
	end

	function featureSelectionCB()
	end

	function learningSelectionCB()
	end


end

