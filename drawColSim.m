function drawColSim(inFileName)
%drawColSim(inFileName)
%Draw cosine similarity with imagesc. 
%inFileName: name of file contains similarity values.

%% read file
fid = fopen(inFileName,'r');
dataArray = textscan(fid,'%s','delimiter','\n');
fclose(fid);
header = strsplit(char(dataArray{1}{1}),'\t');
X = zeros(size(header,2),size(header,2));
for i = 1:size(header,2)
    temp = strsplit(char(dataArray{1}{i+1}),'\t');
    X(i,:) = cellfun(@str2double,temp(2:end));
end

%% nullify diagonal 
for i = 1:size(header,2)
    X(i,i) = 0;
end

%% draw
imagesc(X);
colormap(flipud(colormap('gray')));
colorbar;
set(gca,'XTick',1:size(header,2),'XTickLabel',header,'YTick',1:size(header,2),'YTickLabel',header,'FontSize',14,'FontWeight','bold');
set(gcf, 'PaperPosition', [0 0 5 5]);
set(gcf, 'PaperSize', [5 5]);