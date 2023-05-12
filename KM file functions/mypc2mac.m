function u_mac = mypc2mac(u_pc)
%% u_mac = mypc2mac(u_pc)
u_mac = replace(u_pc,'G:\','/Users/karinmorandell/Library/CloudStorage/GoogleDrive-km195@nyu.edu/');
u_mac =replace(u_mac,'\','/');
%/Users/karinmorandell/Library/CloudStorage/GoogleDrive-km195@nyu.edu/My Drive/data/offline/m534/211115/003
if u_pc(1)=='Y'
    u_mac = replace(u_mac,'Y:/Users/Karin/data/processed/aligned2vid/','/Users/karinmorandell/Library/CloudStorage/GoogleDrive-km195@nyu.edu/My Drive/data/offline/');%provisory
end
