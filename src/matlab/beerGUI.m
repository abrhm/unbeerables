function [] = beerGUI(windowHeight, windowWidth, windowLeftMargin, windowTopMargin)
%	BEERGUI A rendszerhez interf�szt biztos�t� GUI megval�s�t�sa.
%	windowHeight		ablak sz�less�ge
%	windowWidth			ablak magass�ga
%	windowLeftMargin	ablak t�vols�ga a kijelz� bal hat�r�t�l
%	windowTopMargin		ablak t�vols�ga a kijelz� fels� hat�r�t�l
%	Szerz�:	Sajtos Gyula


%%	Glob�lis v�ltoz�k
	I = [];
	featureIdx = 1;
	features = {
		'SURF (sz�rke)',	@extractSURFGrey;
		'SIFT (sz�rke)',	@extractSIFTGrey;
		'SIFT (hue)',		@extractSIFTHue;
		'DSIFT (sz�rke)',	@extractDSIFTGrey
	};
	strongestFeatures = 0.8;
% 	dsiftSteps = 5;
	roiHandler = [];
	nVisualWords = 64;
	trainSet = [];
	classifier = [];
% 	isSVMSimple = false;
	
	
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
		'MenuBar', 'none', 'Visible', 'off', 'Name', 'Log�felismer�s', 'NumberTitle', 'off', 'DockControls', 'off');
	movegui(window, 'center');
	
	
%%	Komponensek
	fileMenu = uimenu(window, 'Label', 'F�jl');
		loadImageMI = uimenu(fileMenu, 'Label', 'Bet�lt�s...', 'Callback', @loadImageCB, 'Accelerator', 'o');
	featureMenu = uimenu(window, 'Label', 'Feature');
		for i = 1:length(features)			
			features{i, 3} = uimenu(featureMenu, 'Label', features{i, 1}, 'Callback', {@selectFeatureCB, i});			
		end
		set(features{featureIdx, 3}, 'Checked', 'on');
		ptStrenMI = uimenu(featureMenu, 'Label', 'Er�k�sz�b...', 'Callback', @setStrongestFeats, 'Separator', 'on');
	learningMenu = uimenu(window, 'Label', '�gens');
		dbPathMI = uimenu(learningMenu, 'Label', 'Adatb�zis kijel�l�se...', 'Callback', @loadTrainDirCB, 'Accelerator', 'd');
		learnMI = uimenu(learningMenu, 'Label', 'Tan�t�s', 'Callback', @trainCB, 'Accelerator', 't');
		viswordsMI = uimenu(learningMenu, 'Label', 'Szavak sz�ma...', 'Callback', @setNoOfVisualWords, 'Separator', 'on');
% 		svmSimpleMI = uimenu(learningMenu, 'Label', 'Egyszer� SVM', 'Callback', @setSVMSimpleSCB);
	classifyMenu = uimenu(window, 'Label', 'Detekt�l�s');
		roiMI = uimenu(classifyMenu, 'Label', 'ROI kijel�l�se...', 'Callback', @selectRoiCB, 'Accelerator', 'r');
		estimateMI = uimenu(classifyMenu, 'Label', 'Becsl�s', 'Callback', @classifyCB, 'Accelerator', 'e');
	imageDisplay = axes('Parent', window, 'Visible', 'off');
	window.Visible = 'on';
	
	
%%	Callback f�ggv�nyek
	function loadImageCB(source, event)
		[filename, path] = uigetfile({'*.jpg'; '*.png'; '*.tif'; '*.gif'}, 'K�p bet�lt�se');
		I = imread([path filename]);
		axes(imageDisplay);
		imshow(I, 'InitialMagnification', 'fit');
% 		fprintf('Kep betoltve: %s%s"\n', path, filename);
	end

	function selectFeatureCB(source, event, newFeatureIdx)
		if (newFeatureIdx ~= featureIdx)
			set(features{newFeatureIdx, 3}, 'Checked', 'on');
			set(features{featureIdx, 3}, 'Checked', 'off');
			featureIdx = newFeatureIdx;
			classifier = [];
		end
	end

	function setStrongestFeats(source, event)
		dialogWidth = 250;
		dialogHeight = 70;
		objHeight = 20;
		btnWidth = 50;
		padding = 20;
		bottomMargin = round((dialogHeight - objHeight)/2);		
		strongestFeatDialog = dialog('Position', [1, 1, dialogWidth, dialogHeight], 'Name', 'Feature er�k�sz�b');
		movegui(strongestFeatDialog, 'center');
		numEdit = uicontrol('Parent', strongestFeatDialog, 'Position', [padding, bottomMargin, 70, objHeight], ...
			'Style', 'edit', 'String', num2str(strongestFeatures));
		okBtn = uicontrol('Parent', strongestFeatDialog, 'Position', [dialogWidth-padding-btnWidth, bottomMargin, btnWidth, objHeight], ...
			'Style', 'pushbutton', 'String', 'OK', 'Callback', @okButtonCB);
		uiwait(strongestFeatDialog);
		
		function okButtonCB(source, event)
			value = str2double(get(numEdit, 'String'));
			if ~isnan(value) && 0 <= value && value <= 1
				strongestFeatures = value;
				delete(strongestFeatDialog);
			end
		end
	end
	
	function loadTrainDirCB(source, event)
		trainPath = uigetdir('', 'Tanul�adatb�zis bet�lt�se');
		if trainPath ~= 0
			trainSet = imageSet(trainPath, 'recursive');
% 			fprintf('Tanulo adatbazis kijelolve: %s\n', trainPath);
		end		
	end

	function trainCB(source, event)
		classifier = trainSingleSimpleSVM(trainSet, features{featureIdx, 2}, false, nVisualWords, strongestFeatures);
		msgbox('Modell felepitve.');
% 		fprintf('Modell felepitve.\n');
	end

	function selectRoiCB(source, event)
		delete(roiHandler);
		roiHandler = imrect(imageDisplay);
	end

	function setNoOfVisualWords(source, event)
		dialogWidth = 250;
		dialogHeight = 70;
		objHeight = 20;
		btnWidth = 50;		
		padding = 20;
		bottomMargin = round((dialogHeight - objHeight)/2);
		visWordDialog = dialog('Position', [1, 1, dialogWidth, dialogHeight], 'Name', 'Szavak sz�ma');
		movegui(visWordDialog, 'center');
		numEdit = uicontrol('Parent', visWordDialog, 'Position', [padding, bottomMargin, 70, objHeight], ...
			'Style', 'edit', 'String', num2str(nVisualWords));
		okBtn = uicontrol('Parent', visWordDialog, 'Position', [dialogWidth-padding-btnWidth, bottomMargin, btnWidth, objHeight], ...
			'Style', 'pushbutton', 'String', 'OK', 'Callback', @okButtonCB);
		uiwait(visWordDialog);
		
		function okButtonCB(source, event)
			value = str2double(get(numEdit, 'String'));
			if ~isnan(value) && 1 <= value
				nVisualWords = uint32(value);
				delete(visWordDialog);
			end
		end
	end

% 	function setSVMSimpleSCB(source, event)
% 	end
	
	function classifyCB(source, event)
% 		Ha nem v�ltozott meg a kiv�lasztott feature le�r�, akkor oszt�lyozhatunk
		if ~isempty(classifier)
% 			Kiv�gjuk a ROI-t az eredeti k�pb�l
			if isvalid(roiHandler)
				P = getPosition(roiHandler);
				P = round(P);
				I_roi(:,:,:) = I(P(2):P(2)+P(4), P(1):P(1)+P(3), :);
% 			Ha nem jel�lt�nk ki, akkor az eg�sz k�p a ROI
			else
				I_roi = I;
			end
			[resultScore, resultLabel] = classifySingleSimpleSVM(I_roi, classifier);
			str = sprintf('Marka: %s\nErtek: %f', resultLabel, resultScore);
			msgbox(str, 'Eredmeny');
% 			fprintf('Osztaly: %s\nErtekeles: %f', resultLabel, resultScore);
% 			figure, imshow(I_roi);
		else
			errordlg('A modell elavult, frissites szukseges.');
% 			fprintf('Modell elavult: frissites szukseges.\n');
		end
	end
	

end

