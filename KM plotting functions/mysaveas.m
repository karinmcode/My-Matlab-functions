function mysaveas(fig,file_url)
[file_folder,file_name,ext] = fileparts(file_url);
if ~isempty(ext)
    if ~isfolder(file_folder)
        mkdir(file_folder);
    end
else
    keyboard;
end

switch ext
    case '.emf'
        exportgraphics(fig,file_url,'Resolution',600,'BackgroundColor','none','Colorspace','rgb','ContentType','auto');
    otherwise
        saveas(fig,file_url);
end

end



