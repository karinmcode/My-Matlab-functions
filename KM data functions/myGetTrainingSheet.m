function [sheet,sheet_headers]=myGetTrainingSheet()


% get sheet
id = '1xAIKN6qadWDT_vLPBUIrqQZVutKis4PH_OHA74FL09A';
sheet_id = '0';
try
sheet=GetGoogleSpreadsheet(id,sheet_id);
catch
sheet=GetGoogleSpreadsheet(id);

end
sheet = cell2struct(sheet(2:end,:)',sheet(1,:));

% add relevant fields to sheet
temp = cellfun(@(x) datestr(datenum(x(1:10),'DD/mm/YYYY'),'YYmmDD'),{sheet.Date},'UniformOutput' , false);
[sheet(:).Date] =deal(temp{:} );


temp = cellfun(@(a,d,r) sprintf('m%s_%s_%03.f',a,d,str2double(r))  , {sheet.anmid}', {sheet.Date}',{sheet.BEH_filename}','UniformOutput',0);
[sheet(:).beh_fn0] = deal(temp{:} );

temp = cellfun(@(a,d,r) sprintf('m%s_%s_%03.f',a,d,str2double(r))  , {sheet.anmid}',{sheet.Date}',{sheet.SBX_filename}','UniformOutput',0);
[sheet(:).sbx_fn0] = deal(temp{:} );

temp = cellfun(@(a) ['m' a]  , {sheet.anmid}','UniformOutput',0);
[sheet(:).anmid] = deal(temp{:} );


% make recording number fields '001'
for R = {'BEH_filename' 'VID_filename' 'SBX_filename'}
temp = cellfun(@(r) num2str(str2double(r),'%03.f')  , {sheet.(R{:})}','UniformOutput',0);
[sheet(:).(R{:})] = deal(temp{:} );
end

% remove useless fields
% f=fieldnames(sheet)'; openvar('f')
list = {'Entry_type_num' 'Entry_type' 'id_mark'	'weight_g'	'Weight_after_g'	'Rig_water_mL'	'Complement_mL'	'ini_weight_g'	'pWeight'	'Rewards'	'uL'	'ms'	'pReward' 'pull_duration_ms'	'home_duration_ms'	'toneseq_thresholds'	'BEH_min' 'SBX_power'	'laser_nm'	'Suite2P'	'manual_s2p'	's2p_quality'	'nSoundRespCells'	'nROis'};
sheet = rmfield(sheet,list);
sheet_headers = fieldnames(sheet);