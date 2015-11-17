function [] = beerGUI(windowHeight, windowWidth, windowLeftMargin, windowTopMargin)
%	BEERGUI A rendszerhez interf�szt biztos�t� GUI megval�s�t�sa.
%	windowHeight		ablak sz�less�ge
%	windowWidth			ablak magass�ga
%	windowLeftMargin	ablak t�vols�ga a kijelz� bal hat�r�t�l
%	windowTopMargin		ablak t�vols�ga a kijelz� fels� hat�r�t�l

%%	Glob�lis v�ltoz�k
	I = [];
	
	
%%	Ablak param�terei	
	if (nargin == 0)
		windowHeight = 480;
		windowWidth = 640;
		windowLeftMargin = 200;
		windowTopMargin = 300;
	end
	screenDim = get(groot, 'ScreenSize');
	windowBottomMargin = screenDim(4) - (windowTopMargin + windowHeight);
	window = figure('Position', [windowLeftMargin, windowBottomMargin, windowWidth, windowHeight], ...
		'MenuBar', 'none', 'Visible', 'off', 'Name', 'Log�felismer�s', 'NumberTitle', 'off');
	
	
%%	Komponensek	
	fileMenu = uimenu(window, 'Label', 'F�jl');
		loadImageMI = uimenu(fileMenu, 'Label', 'Bet�lt�s...', 'Callback', @loadImageCB);
	featureMenu = uimenu(window, 'Label', 'Feature');
		surfGreyMI = uimenu(featureMenu, 'Label', 'SURF (sz�rke�rnyalatos)');
		siftGreyMI = uimenu(featureMenu, 'Label', 'SIFT (sz�rke�rnyalatos)');
		siftHsvMI = uimenu(featureMenu, 'Label', 'SIFT (HSV)');		
	learningMenu = uimenu(window, 'Label', 'Tanul�s');
	
	window.Visible = 'on';
	
	
%%	Callback f�ggv�nyek
	function loadImageCB(source, event)
		[filename, path] = uigetfile({'*.jpg'; '*.png'; '*.tif'; '*.gif'}, 'K�p bet�lt�se');
		I = imread([path filename]);
		imageDisp = imshow(I);
		fprintf('Kep betoltve: %s%s"\n', path, filename);
	end

	function featureSelectionCB()
	end

	function learningSelectionCB()
	end


end

