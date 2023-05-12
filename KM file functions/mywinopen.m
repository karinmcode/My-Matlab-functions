function mywinopen(URL)

try
    winopen(URL);
catch
    folder=fileparts(URL);
    try
        winopen(folder);
    catch
        folder=fileparts(folder);
        try
            winopen(folder);
        catch
            warning('did not find file/folder : %s' ,URL)
        end
    end
end