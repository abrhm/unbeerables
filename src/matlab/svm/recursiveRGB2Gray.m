function [] = recursiveRGB2Gray(folder_in, folder_out)
% Segédfgv képek gyors konvertálására RGB -> szürkeárnyalatos
% 

if ischar(folder_in) == 1
    filePathIn = folder_in;
else
    str = 'Setting default path to infolder: ';
    filePathIn = 'D:\matlab_proj\debug\heineken\';
    disp(str);
    disp(filePathIn);
end

if ischar(folder_out) == 1
    filePathOut = folder_out;
else
    str = 'Setting default path to outfolder: ';
    filePathOut = 'D:\matlab_proj\gray\heineken\';
    disp(str);
    disp(filePathIn);
end

d = dir([filePathIn,'*.jpg']);
for i = 1:length(d)
    fname = d(i).name;
    img = imread([filePathIn,fname]);
    img_gray = rgb2gray(img);
    imwrite(img_gray,[filePathOut,fname]);
end

end