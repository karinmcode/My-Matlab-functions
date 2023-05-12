function menuu=myaddeditfilemenu(hobject,URL)
%% menuu=myaddeditfilemenu(hobject,URL)
if ~iscell(URL)
    URL = {URL};
end
for u = 1:numel(URL)
    url = URL{u};
    % check if menu already exists
    menuu=get(hobject,'UIContextMenu');
    if isempty(menuu)
        if strcmp(class(hobject),'matlab.ui.Figure')
            menuu = uicontextmenu(hobject);
        else
            hfig = ancestor(hobject,'figure');

            if strcmp(class(hfig),'matlab.ui.Figure')
                menuu = uicontextmenu(hfig);
            else
                keyboard
            end
        end

    end

    % display when right click
    uimenu(menuu,'Label',sprintf('edit %s',myfilename(url)),'Callback',sprintf('edit %s',myfilename(url)),'UserData',url);
    % add right click menu
    set(hobject,'UIContextMenu',menuu)
end

end

function myeditscript(src)
url = src.UserData;
edit(url);
end