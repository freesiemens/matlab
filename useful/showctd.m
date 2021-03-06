function [figs,clh]=showctd(stp,titlestr,cols,step,DefaultAxis)
% SHOWCTD -	Plots S, T and P data on a sequence of three plots:
%		T/P, S/P, and T/S. Buttons are placed on a menuplot nearby to 
%		facilitate moving among the plots. Each plot has button to 
%		assist in finding the appropriate menuplot.
%
% USAGE -	[figs] = showctd( stp, titlestr, cols, step, DefaultAxis)
%
%		figs - array of figure handles to the three figures dreated
%		stp - CTD data
%		titlestr - title to label the plot
%		cols - color
%		step - mark every step in press
%		DefaultAxis - Axis limits to default to
%
% SEE ALSO -	overctd
%
%

% PROGRAM - 	MATLAB code by c.m.duncombe rae
%
% CREATED -	CMDR 96-09-04
%
% PROG MODS -	
%  99-11-03  
% 	bring up to date with showctdo, including
%			axis changes and depth markings
%  2012-09-11 
% 	Robustness of tests for arguments
%
%
%     This program is free software: you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation, either version 3 of
% the License, or (at your option) any later version.
% 
%     This program is distributed in the hope that it will be
% useful, but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public
% License along with this program.  If not, see
% <http://www.gnu.org/licenses/>.
% 
% See accompanying script gpl-3.0.m
% 
%

if exist('titlestr','var')~=1, titlestr=[]; end;
if exist('cols','var')~=1, cols='r'; end;
if exist('step','var')~=1, step=100; end;
if exist('DefaultAxis','var')~=1, DefaultAxis=[33.5,36.5,-2,25,0,1000,0,9]; end;

X1=min(stp(:,3));
X2=max(stp(:,3));
pi = [ceil(X1./step).*step:step:X2]';
[junk,I]=sort(stp(:,3));
x=stp(I,:);
J=find(diff(junk)<=0);
if ~isempty(J),
        disp('CTD data unordered');
        x(J,:)=[];
end;

if ~isempty(pi),
        stpm = pi*ones(1,size(stp,2));
        for i = [1:2],
                stpm(:,i) = interp1( x(:,3), x(:,i), pi);
        end;
end;


SaltFig=figure; 
	plot(stp(:,1),stp(:,3),cols); 
	hold on;
	if ~isempty(pi),
		plot(stpm(:,1),stpm(:,3),[cols 'o']); 
	end;
	set(gca,'ydir','reverse'); 
	title(titlestr);
        xlabel('Salinity');
        ylabel('Pressure');
        eval(['axisdefault' num2str(SaltFig) '=DefaultAxis([1 2 5 6]);']);
	zoom on;

TempFig=figure; 
	plot(stp(:,2),stp(:,3),cols); 
	hold on;
	if ~isempty(pi),
		plot(stpm(:,2),stpm(:,3),[cols 'o']); 
	end;
	set(gca,'ydir','reverse'); 
	title(titlestr);
        xlabel('Temperature');
        ylabel('Pressure');
        eval(['axisdefault' num2str(TempFig) '=DefaultAxis([3 4 5 6]);']);
	zoom on;

TSFig=figure; 
	plot(stp(:,1),stp(:,2),cols); 
	hold on; 
	if ~isempty(pi),
		plot(stpm(:,1),stpm(:,2),[cols 'o']);
	end;
	title(titlestr);
        xlabel('Salinity');
        ylabel('Temperature');
        eval(['axisdefault' num2str(TSFig) '=DefaultAxis([1 2 3 4]);']);
	zoom on;

screensize=get(0,'screensize');
width=120;
height=150;
buttonwidth=width;
buttonheight=30;

topleft=screensize(4)-50;

MenuFig=figure;
	set(MenuFig,'position',	[1,topleft,width,height],'menubar','none');
	set(gca,'visible','off');

uicontrol(MenuFig,'string',titlestr,...
	'Position',[0,4*buttonheight,buttonwidth,buttonheight]...
	);

uicontrol(MenuFig,'string','Temp',...
	'callback',['figure(' num2str(TempFig) ')'],...
	'Position',[0,3*buttonheight,buttonwidth,buttonheight]...
	);

uicontrol(MenuFig,'string','Salt',...
	'callback',['figure(' num2str(SaltFig) ')'],...
	'Position',[0,2*buttonheight,buttonwidth,buttonheight]...
	);

uicontrol(MenuFig,'string','TS',...
	'callback',['figure(' num2str(TSFig) ')'],...
	'Position',[0,buttonheight,buttonwidth,buttonheight]...
	);

uicontrol(MenuFig,'string','Finished',...
	'callback',['close([' num2str(TempFig) ',' num2str(SaltFig) ',' num2str(TSFig) ',' num2str(MenuFig) '])'],...
	'Position',[0,0,buttonwidth,buttonheight]...
	);


figs=[SaltFig,TempFig,TSFig];
clh=figs;
for i=1:length(figs),
	Fig=figs(i);
	clh(i)=uicontrol(Fig,'string','Menu',...
		'callback',['figure(' num2str(MenuFig) ')'],...
		'Position',[0,0,90,20]...
		);
	eval(['ad=axisdefault' num2str(Fig) ';']);
	axiscommand=['axis([' sprintf('%g %g %g %g',ad) ']);'];
	uicontrol(Fig,'string','AxDef',...
	        'callback',axiscommand,...
	        'Position',[0,20,45,20]...
	        );
	uicontrol(Fig,'string','AxIni',...
        	'callback',['axis(''auto'')'],...
       		'Position',[45,20,45,20]...
       		);

%
end;

figs=[MenuFig, figs];
clh= [NaN, clh];

return;

