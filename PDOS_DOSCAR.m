%% PDOS and LDOS plot from DOSCAR for lnoncollinear=true and LORBIT=11

% This code should work if pseudos have or dont have f electrons

% **IMPORTANT******In 5.4 VASP, the sixth DOSCAR line is 
% repeated multiple times throughout the DOSCAR. 
% Please delete these repeated lines (keep the 6th line)
% first and then run this code.

%% ================================================================================
%%******* If 'f' orbital is not present in the pseudo comment the mentioned 6 lines 
%%
clc
clear all
close all
filename='DOSCAR';
fid=fopen(filename,'r');
i=0;
%% Read parameters
fprintf('Reading parameters...\n')
while feof(fid)==0
    i=i+1;
    S=fgetl(fid);
    str=sprintf(S);
    clear X S
    X=strsplit(str,{' ','\t'});
    if i==1
        nion=str2double(X(2));
        pdos_sw=str2double(X(4));
    end
    if i==6
        strmatch = str;
        emax=str2double(X(2));
        emin=str2double(X(3));
        NEDOS=str2double(X(4));
        fermi=str2double(X(5));
        break;
    end
end
fprintf('#### IMPORTANT: Please delete repeated instances of the following lines from DOSCAR (keep the first)\n%s\n',strmatch)
fclose(fid);
%% read total DOS
fprintf('Reading TDOS...\n')
%%TDOS  first column > Energy,  second & third column > up and down spin
TDOS=zeros(NEDOS,3);
fid=fopen(filename,'r');
for i=1:NEDOS+6
    S=fgetl(fid);
    str=sprintf(S);
    X=strsplit(str,{' ','\t'});
    if i>6
        TDOS(i-6,1)=str2double(X(2))-fermi;
        TDOS(i-6,2)=str2double(X(3));
    end
    clear str X S
end

%% Enter Emax_req and Emin_req
fprintf('give an Energy range between %f and %f\n',TDOS(1,1),TDOS(end,1));
Emax_req = 3;
Emin_req = -5;
for i=1:length(TDOS(:,1))
    if Emin_req >= TDOS(i,1) && Emin_req <= TDOS(i+1,1)
        index_Emin = i;
    end
    if Emax_req >= TDOS(i,1) && Emax_req <= TDOS(i+1,1)
        index_Emax = i;
    end
end
fprintf('Required energy Range is [%f %f]\n',Emin_req,Emax_req)
%% read partial DOS
fprintf('Reading PDOS...\n')
%%PDOS first column > Energy, (column 2-17> upspin s,p,d,f orbitals), (column 18-33> upspin s,p,d,f orbitals)
if pdos_sw==1
    f=1;
%     f=input('Enter if f orbital present in DOSCAR (0/1)');
    if f==1
        pdos=zeros(NEDOS,17,nion);
        for n=1:nion
%             S=fgetl(fid);
            for j=1:NEDOS
                S=fgetl(fid);
                i=i+1;  % keeps count of which line it is reading 
                str=sprintf(S);
                if strcmp(str,strmatch)==0
                    X=strsplit(str,{' ','\t'});
                    pdos(j,1,n)=str2double(X(2))-fermi;
                    pdos(j,2:10,n)=str2double(X(3:4:end));
                    clear str X S
                    %=================================================================================
                    %======%%  Important  %%==========================================================
                    %====== If 'f' orbital is not present in the pseudo comment the following 6 lines 
                    S=fgetl(fid);
                    i=i+1;
                    str=sprintf(S);
                    X=strsplit(str,{' ','\t'});
                    pdos(j,11:17,n)=str2double(X(2:4:end));
                    clear X S
                end
                
            end
        end
    end
end
fclose(fid);
%% summing up orbitals
if f==1
pd=zeros(NEDOS,4,nion);
    for i=1:nion
        for j=1:NEDOS
            pd(j,1,i)=pdos(j,2,i);
            pd(j,2,i)=pdos(j,3,i)+pdos(j,4,i)+pdos(j,5,i);
            pd(j,3,i)=pdos(j,6,i)+pdos(j,7,i)+pdos(j,8,i)+pdos(j,9,i)+pdos(j,10,i);
            pd(j,4,i)=pdos(j,11,i)+pdos(j,12,i)+pdos(j,13,i)+pdos(j,14,i)+pdos(j,15,i)+pdos(j,16,i)+pdos(j,17,i);
        end
    end
end
% summed pdos over all atoms
for j=1:NEDOS
    sumpd(j,1)=sum(pd(j,1,:));
    sumpd(j,2)=sum(pd(j,2,:));
    sumpd(j,3)=sum(pd(j,3,:));
    sumpd(j,4)=sum(pd(j,4,:));
end
% %%Plot for ErPdBi
% figure(4)
% plot(pdos(2:end,1,4),sumpd(2:end,1),'LineWidth',1.5)
% hold on
% plot(pdos(2:end,1,4),sumpd(2:end,2),'LineWidth',1.5)
% hold on 
% plot(pdos(2:end,1,4),sumpd(2:end,3),'LineWidth',1.5)
% hold on 
% plot(pdos(2:end,1,4),sumpd(2:end,4),'LineWidth',1.5)
% legend('s','p','d','f')
% s_dos=trapz(pdos(:,1,4),sumpd(:,1))
% p_dos=trapz(pdos(:,1,4),sumpd(:,2))
% d_dos=trapz(pdos(:,1,4),sumpd(:,3))
% f_dos=trapz(pdos(:,1,4),sumpd(:,4))
% %%%%%%% forbital plot
% figure(5)
% plot(pdos(2:end,1,4),pdos(2:end,11,3),'LineWidth',1.5)
% hold on
% plot(pdos(2:end,1,4),pdos(2:end,12,3),'LineWidth',1.5)
% hold on 
% plot(pdos(2:end,1,4),pdos(2:end,13,3),'LineWidth',1.5)
% hold on 
% plot(pdos(2:end,1,4),pdos(2:end,14,3),'LineWidth',1.5)
% hold on
% plot(pdos(2:end,1,4),pdos(2:end,15,3),'LineWidth',1.5)
% hold on 
% plot(pdos(2:end,1,4),pdos(2:end,16,3),'LineWidth',1.5)
% hold on 
% plot(pdos(2:end,1,4),pdos(2:end,17,3),'LineWidth',1.5)
% legend( 'y(3x2-y2)', 'xyz', 'yz2', 'z3', 'xz2', 'z(x2-y2)', 'x(x2-3y2)')
% %% Plot
% figure(1)
% plot(pdos(:,1,4),pdos(:,6,1),'LineWidth',1.5)
% hold on
% plot(pdos(:,1,4),pdos(:,7,1),'LineWidth',1.5)
% hold on 
% plot(pdos(:,1,4),pdos(:,8,1),'LineWidth',1.5)
% hold on 
% plot(pdos(:,1,4),pdos(:,9,1),'LineWidth',1.5)
% hold on 
% plot(pdos(:,1,4),pdos(:,10,1),'LineWidth',1.5)
% hold on
% plot(pdos(:,1,4),pd(:,3,1),'k','LineWidth',1.5)
% % hold on
% % plot(pdos(:,1,4),pd(:,1,3))
% xlabel('E-E_{f} (eV)');
% box on;grid on;
% pbaspect([1.0 0.5 1])
% ylim([0. 6]);
% set(gca,'xlim',[-6 8],'Xgrid','on','Ygrid','off',...
%        'Fontweight','bold','Fontsize',17,'Fontname','times');
% legend('V dxy','V dyz','V dz2-r2','V dxz','V dx2-y2','V d');
% % legend('Pt1 d orbitals','Pt2 d orbitals','Pt3 d orbitals');
% view([90 -90])
% set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 9])
%% plot LDOS
figure(2)
LDOS=zeros(NEDOS,nion);
for i=1:NEDOS
    for j=1:nion
        LDOS(i,j)=sum(pd(i,:,j));

    end
end
% List the atoms you want to project: e.g. [1 2 9]
List_atoms=[1 2 9];
disp('Indices of atoms to be included in LDOS plot:')
disp(List_atoms)
for at=1:length(List_atoms)
    plot(pdos(:,1,1),LDOS(:,List_atoms(at)),'LineWidth',1)
    hold on
end
xlabel('E-E_{f} (eV)');
box on;grid on;
set(gca,'xlim',[Emin_req Emax_req],'ylim', [0 max(max(LDOS(index_Emin:index_Emax,:)))*1.1],'Xgrid','on','Ygrid','off',...
       'Fontweight','normal','Fontsize',17,'Fontname','times');
% legend('Bi_1','Bi_2','Dy_1','Dy_2','Pd_1','Pd_2','TDOS');
legend('Ru_\uparrow','Co_\downarrow','Te');
view([90 -90])
pbaspect([1.0 0.5 1])
title('LDOS')
%set(gcf,'PaperUnits','inches','PaperPosition',[0 0 6 9])
%% sum of states calculation in required energy range
for i=1:nion 
    atom_sum_states(i)=trapz(pdos(index_Emin:index_Emax,1,1),LDOS(index_Emin:index_Emax,i));
    atom_s(i)=trapz(pdos(index_Emin:index_Emax,1,1),pd(index_Emin:index_Emax,1,i));
    atom_p(i)=trapz(pdos(index_Emin:index_Emax,1,1),pd(index_Emin:index_Emax,2,i));
    atom_d(i)=trapz(pdos(index_Emin:index_Emax,1,1),pd(index_Emin:index_Emax,3,i));
    atom_f(i)=trapz(pdos(index_Emin:index_Emax,1,1),pd(index_Emin:index_Emax,4,i));
end
fprintf('Atom projected DOS calculated for each atom in required Energy range:\n');
for atom = 1:length(atom_sum_states)
    fprintf('%d atom: summed DOS: %f\n',atom,atom_sum_states(atom))
end
fprintf('Orbitals projected sum for required Energy range\n');
fprintf('s DOS: %f\n',sum(atom_s))
fprintf('p DOS: %f\n',sum(atom_p))
fprintf('d DOS: %f\n',sum(atom_d))
fprintf('f DOS: %f\n',sum(atom_f))
TDOS_sum=trapz(pdos(index_Emin:index_Emax,1,1),TDOS(index_Emin:index_Emax,2));
fprintf('Total DOS calculated in required Energy range: %f\n',TDOS_sum);

%% plot PDOS
figure(8)
PDOS=zeros(NEDOS,4);
for i=1:NEDOS
    for j=1:4
        PDOS(i,j)=sum(pd(i,j,:));
    end
end
plot(pdos(:,1,1),PDOS(:,1),'LineWidth',1)
hold on
plot(pdos(:,1,1),PDOS(:,2),'LineWidth',1)
hold on
plot(pdos(:,1,1),PDOS(:,3),'LineWidth',1)
hold on
plot(pdos(:,1,1),PDOS(:,4),'LineWidth',1)
hold on
% plot(pdos(:,1,1),LDOS(:,5),'LineWidth',1)
% hold on
% plot(pdos(:,1,1),LDOS(:,6),'LineWidth',1)
% hold on
plot(pdos(:,1,1),TDOS(:,2),'k','LineWidth',1)
xlabel('E-E_{f} (eV)');
box on;grid on;
set(gca,'xlim',[Emin_req Emax_req],'ylim', [0 max(max(TDOS(index_Emin:index_Emax,2:end)))*1.1],'Xgrid','on','Ygrid','off',...
       'Fontweight','normal','Fontsize',17,'Fontname','times');
% legend('Bi_1','Bi_2','Dy_1','Dy_2','Pd_1','Pd_2','TDOS');
legend('s','p','d','f','TDOS');
title ('PDOS')
pbaspect([1.0 0.5 1])
view([90 -90])