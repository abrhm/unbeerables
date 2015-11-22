function [] = beerGUI(windowHeight, windowWidth, windowLeftMargin, windowTopMargin)
%	BEERGUI A rendszerhez interfészt biztosító GUI megvalósítása.
%	windowHeight		ablak szélessége
%	windowWidth			ablak magassága
%	windowLeftMargin	ablak távolsága a kijelzõ bal határától
%	windowTopMargin		ablak távolsága a kijelzõ felsõ határától
%	Szerzõ:	Sajtos Gyula


%%	Globális változók
	I = [];
	featureIdx = 1;
	features = {
		'SURF (szürke)',	@extractSURFGrey;
		'SIFT (szürke)',	@extractSIFTGrey;
		'SIFT (hue)',		@extractSIFTHue;
		'DSIFT (szürke)',	@extractDSIFTGrey
	};
	strongestFeatures = 0.8;
% 	dsiftSteps = 5;
	roiHandler = [];
	nVisualWords = 64;
	trainSet = [];
	classifier = [];
% 	isSVMSimple = false;
	
	
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
		'MenuBar', 'none', 'Visible', 'off', 'Name', 'Logófelismerés', 'NumberTitle', 'off', 'DockControls', 'off');
	movegui(window, 'center');
	
	
%%	Komponensek
	fileMenu = uimenu(window, 'Label', 'Fájl');
		loadImageMI = uimenu(fileMenu, 'Label', 'Betöltés...', 'Callback', @loadImageCB, 'Accelerator', 'o');
	featureMenu = uimenu(window, 'Label', 'Feature');
		for i = 1:length(features)			
			features{i, 3} = uimenu(featureMenu, 'Label', features{i, 1}, 'Callback', {@selectFeatureCB, i});			
		end
		set(features{featureIdx, 3}, 'Checked', 'on');
		ptStrenMI = uimenu(featureMenu, 'Label', 'Erõküszöb...', 'Callback', @setStrongestFeats, 'Separator', 'on');
	learningMenu = uimenu(window, 'Label', 'Ágens');
		dbPathMI = uimenu(learningMenu, 'Label', 'Adatbázis kijelölése...', 'Callback', @loadTrainDirCB, 'Accelerator', 'd');
		learnMI = uimenu(learningMenu, 'Label', 'Tanítás', 'Callback', @trainCB, 'Accelerator', 't');
		viswordsMI = uimenu(learningMenu, 'Label', 'Szavak száma...', 'Callback', @setNoOfVisualWords, 'Separator', 'on');
% 		svmSimpleMI = uimenu(learningMenu, 'Label', 'Egyszerû SVM', 'Callback', @setSVMSimpleSCB);
	classifyMenu = uimenu(window, 'Label', 'Detektálás');
		roiMI = uimenu(classifyMenu, 'Label', 'ROI kijelölése...', 'Callback', @selectRoiCB, 'Accelerator', 'r');
		estimateMI = uimenu(classifyMenu, 'Label', 'Becslés', 'Callback', @classifyCB, 'Accelerator', 'e');
	imageDisplay = axes('Parent', window, 'Visible', 'off');
	window.Visible = 'on';
	
	
%%	Callback függvények
	function loadImageCB(source, event)
		[filename, path] = uigetfile({'*.jpg'; '*.png'; '*.tif'; '*.gif'}, 'Kép betöltése');
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
		strongestFeatDialog = dialog('Position', [1, 1, dialogWidth, dialogHeight], 'Name', 'Feature erõküszöb');
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
		trainPath = uigetdir('', 'Tanulóadatbázis betöltése');
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
		visWordDialog = dialog('Position', [1, 1, dialogWidth, dialogHeight], 'Name', 'Szavak száma');
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
% 		Ha nem változott meg a kiválasztott feature leíró, akkor osztályozhatunk
		if ~isempty(classifier)
% 			Kivágjuk a ROI-t az eredeti képbõl
			if isvalid(roiHandler)
				P = getPosition(roiHandler);
				P = round(P);
				I_roi(:,:,:) = I(P(2):P(2)+P(4), P(1):P(1)+P(3), :);
% 			Ha nem jelöltünk ki, akkor az egész kép a ROI
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

