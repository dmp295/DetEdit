%  modTF  program to modify the Transfer Function of TPWS files
% J Hildebrand  8/28/2018
% Assumes that the TF is inculded in the TPWS files as tfraw
%
tfSelect = 40200;  % zc peak freq
indir = 'C:\Users\HARP\Documents\TFs';
disp('Transfer function update ');
[tfName,pname] = uigetfile(fullfile(indir,'*.tf'),'Select TF File');
if exist('pname','var')
    disp('Load Transfer Function File')
else
    error('No path specified for transfer function files. Add tfName')
end
tfFull = (fullfile(pname,tfName));
fid = fopen(tfFull);
[tfnew,count] = fscanf(fid,'%f %f',[2,inf]);
tffreqn = tfnew(1,:);
tfuppcn = tfnew(2,:);
fclose(fid);
figure(99)
semilogx(tfnew(1,:),tfnew(2,:),'r')
hold on
tfn = interp1(tffreqn,tfuppcn,tfSelect,'linear','extrap');
disp(['TF NEW @',num2str(tfSelect),' Hz =',num2str(tfn)]);
%
%Load TPWS file to test if TF needs updating
tpwsdir = 'G:\SOCAL_BW\Detections';
[tpwsName,tpwspname] = uigetfile(fullfile(tpwsdir,'*.mat'),'Select TPWS File');
tpwsFull = (fullfile(tpwspname,tpwsName));
load(tpwsFull,'MTT','MPP','MSN','tfraw')
tffreq = tfraw(1,:);
tfuppc = tfraw(2,:);
semilogx(tfraw(1,:),tfraw(2,:),'b')
tf = interp1(tffreq,tfuppc,tfSelect,'linear','extrap');
disp(['TF OLD @',num2str(tfSelect),' Hz =',num2str(tf)]);
MPPold= MPP;
MPP = MPP - tf + tfn;
legend('new','old','Location','northwest')
%
sp = 'Cuviers'; srate = 200;
% species-specific settings:
p = sp_setting_defaults('sp',sp,'srate',srate,'analysis','modTF');
%
% Calculate paramerters
% function [ ] = CalPARAMSfunc(ct,cpp,csn,filePrefix,sp,sdir,detfn,p,tf,srate)
CalPARAMSfunc(MTT,MPPold,MSN,tpwspname,tpwsName,p,tf,srate)
