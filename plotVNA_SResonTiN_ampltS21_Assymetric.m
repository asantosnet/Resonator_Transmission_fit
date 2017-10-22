function [ InfoText ] = plotVNA_SResonTiN_ampltS21_Assymetric
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   Uses the compare_FitS21ResonTiN_Assymetric and reads the file that
%   comes from Romain's manip
%   Normalization only of the amplitude of S21 by the amplitude of the 
%   measured s21 before truning on the switch. ( see function 
%   calc_normalize_S21 in the end of this file)





% Skip powers

skip = [-18,-16,-14,-12,-10,-8,-6,-4,-2,0];



% Select the file

[Filename, Pathname, Filterindex] = uigetfile('.txt','Select your file', ...
                                        'Multiselect','on');

if Filterindex == 0
    msgbox('You have failed to selcted a file');
    
end


% If only one is selected

if iscell(Filename) == 0
    
    faitchie = cell(1);
    
    faitchie{1} = Filename;
    
    Filename = faitchie; 
    
    faitchie{1} = Pathname;
    
    Pathname = faitchie{1};
    
end


fitYes = 0;
normalize = 0;
normalize_all = 0;

% Ask the person if he wants to save it

promptMessage = sprintf('Do you want to fit ?');

button = questdlg(promptMessage, '..', 'Yes', 'No', 'Yes');

if strcmpi(button, 'Yes')

   fitYes = 1;

end

promptMessage = sprintf('Do you want to normalize S21?');

button = questdlg(promptMessage,'...','Yes all','No all','Yes','No');

switch button
    
    case 'Yes all'
        
        normalize_all =1;
        
    case 'Yes'
        
        normalize = 1;
        
end



% Recover the data

for file_number = 1:size(Filename,2)
    
    % Look for the data in the text

    FileText = fopen([Pathname,Filename{file_number}],'rt');

    HeaderText = textscan(FileText,'%q',4,'Delimiter',',');
    DataText = textscan(FileText,'%f64 %f64 %f64 %f64 ','Delimiter','');


    % Recover info from saved file

    posPower = find(strcmp([HeaderText{:}], '# Power (dBm)'))
    posFreq = find(strcmp([HeaderText{:}], 'Frequency (Hz)'))
    posRe = find(strcmp([HeaderText{:}], 'Re(S21)'))
    posIm = find(strcmp([HeaderText{:}], 'Im(S21)'))
    
    
    if isempty(posPower) || isempty(posFreq) || isempty(posRe)|| isempty(posIm)
       
        
        error('Format not compatble - go to next file')
        Npowerpoints = 0;
    else
        
        Power = DataText{posPower};

        Data = ones(size(DataText{2},1),3);
        Data(:,1) = DataText{posFreq};
        Data(:,2) = DataText{posRe};
        Data(:,3) = DataText{posIm};

        Npoints = find(Power ~= Power(1,1),1)-1;

        Npowerpoints = size(DataText{2},1)/Npoints;


        DataTot = cell(3,10*Npowerpoints);
        
    end
       
    for Npower = 1:Npowerpoints
        
        if isempty(find(skip == Power(1 + Npoints*(Npower-1)), 1)) == 1
    
            % Re arrange and calculate all data. Plot them as well .  

            DataTot = arrange_plot_Data(DataTot,...
                                        Npower,Power,Data,Npoints,HeaderText);

            % normalize

            treshold = 2;

            [S21normalized,S21_normalizer,Freq_normalizer,failed] = ...
                         normalizeS21(normalize_all,normalize,DataTot,treshold,...
                                Power,Npoints,Npower,fitYes);

            % Plot them all

            Measurement_Type = 'S21 - Transmission';

            
            plot_ALL(DataTot,num2str(Power(1 + Npoints*(Npower-1))),Npower,...
                            fitYes,Measurement_Type,S21normalized,Freq_normalizer,failed);
        end
    end  

end

end

% It saves the data in the DataTOt cell
% It also calculates the S21, absolut value of S21, argument of S21
% and the the group delay 

function [DataTot] = arrange_plot_Data(DataTot,...
                            Npower,Power,Data,Npoints,HeaderText)
                                                


    DataTot{1,1 +10*(Npower-1)} = Power(1 + Npoints*(Npower-1));
        
    DataTot{2,1 +10*(Npower-1)} = HeaderText{1}{2};
    DataTot{2,2 +10*(Npower-1)} = HeaderText{1}{3};
    DataTot{2,3 +10*(Npower-1)} = HeaderText{1}{4};
    DataTot{2,4 +10*(Npower-1)} = 'S21';
    DataTot{2,5 +10*(Npower-1)} = 'AbsS21';
    DataTot{2,6 +10*(Npower-1)} = 'ArgS21';
    DataTot{2,7 +10*(Npower-1)} = 'fyGroupS21';
    DataTot{2,8 +10*(Npower-1)} = 'fxGroupS21';
    DataTot{2,9 +10*(Npower-1)} = 'byGroupS21';
    DataTot{2,10 +10*(Npower-1)} = 'bxGroupS21';
    
    
    DataTot{3,1 +10*(Npower-1)} = Data((1 + Npoints*(Npower-1)):...
                                    (Npoints + Npoints*(Npower-1)),1);
    DataTot{3,2 +10*(Npower-1)} = Data((1 + Npoints*(Npower-1)):...
                                    (Npoints + Npoints*(Npower-1)),2);
    DataTot{3,3 +10*(Npower-1)} = Data((1 + Npoints*(Npower-1)):...
                                    (Npoints + Npoints*(Npower-1)),3);
    
    
    % Calculate S21
                                
    S21 = Data((1 + Npoints*(Npower-1)):(Npoints + Npoints*(Npower-1)),2)...
     + 1i.*Data((1 + Npoints*(Npower-1)):(Npoints + Npoints*(Npower-1)),3);                            
                                
                                
    AbsS21 = abs(S21);
    ArgS21 = -(angle(S21)./(pi)).*180; % de -1 à +1 pi
 
    
    
    % group velocity is \tau_g = - (1/360)*(deltaPhi/deltaf)
    [fyGroupS21,fxGroupS21]= calcDeriv(Data((1 + Npoints*(Npower-1)):...
        (Npoints + Npoints*(Npower-1)),1),ArgS21,'foward');
    [byGroupS21,bxGroupS21]= calcDeriv(Data((1 + Npoints*(Npower-1)):...
        (Npoints + Npoints*(Npower-1)),1),ArgS21,'backwards');
 
 
    DataTot{3,4 +10*(Npower-1)} = S21;
    DataTot{3,5 +10*(Npower-1)} = AbsS21;
    DataTot{3,6 +10*(Npower-1)} = ArgS21;
    DataTot{3,7 +10*(Npower-1)} = fyGroupS21;
    DataTot{3,8 +10*(Npower-1)} = fxGroupS21;
    DataTot{3,9 +10*(Npower-1)} = byGroupS21;
    DataTot{3,10 +10*(Npower-1)} = bxGroupS21;
                                 
                                
end



function [deriv,xderiv]= calcDeriv(x,y,type)

    
    deriv = diff(y)./diff(x);
    
    if strcmp(type,'foward')
    
    % Apply foward difference and x and y of the same size
    xderiv = x(1:(end-1));
    
    elseif strcmp(type,'backwards')
    % Apply backwards difference and y and x of the same size
    xderiv = x(2:end);
    
    end



end

% Function to call the funtiont used to plot

function plot_ALL(DataTot,Power,Npower,...
                        fitYes,Measurement_Type,S21normalized,Freq_normalizer,failed)

    plotVNATiN('Amplitude S21',Measurement_Type,['S21','(dB)'],...
        ' Frequency(Hz)',DataTot{3,1 +10*(Npower-1)}...
        ,10.*log(DataTot{3,5 +10*(Npower-1)}),Power,fitYes)
    
    
%     plotVNATiN('Argument S21',Measurement_Type,['S21','(Deg)'],...
%         ' Frequency(Hz)',DataTot{3,1 +10*(Npower-1)}...
%         ,DataTot{3,6 +10*(Npower-1)},Power,fitYes)
%     
%     plotVNATiN('Group Velocity S21 Foward',Measurement_Type,'\tau_g(deg.s^{-1})',...
%         ' Frequency(Hz)',DataTot{3,8 +10*(Npower-1)}...
%         ,DataTot{3,7 +10*(Npower-1)},Power,fitYes)
% 
%     plotVNATiN('Group Velocity S21 Backwards',Measurement_Type,'\tau_g(deg.s^{-1})',...
%         ' Frequency(Hz)',DataTot{3,10 +10*(Npower-1)}...
%         ,DataTot{3,9 +10*(Npower-1)},Power,fitYes)

%     if failed == 0
%         
%         plotVNATiN('Amplitude S21',[Measurement_Type,'- Normalized'],['S21','(dB)'],...
%         ' Frequency(Hz)',Freq_normalizer...
%         ,10.*log(abs(S21normalized)),Power,fitYes)
%     
%     end
    
    
    
    
    
end


% Function used to plot data, save it as a pdf, jped and matalb file 
% and also to, if wanted , call the function to fit the data

function plotVNATiN(figname,measurment_type,labely,labelx,...
                    datax,datay,power,fitYes)

    figurePlot = figure('Name',figname);

    set(figurePlot,'Position',[750 400 850 600]);
    

%     % I don't want to see every plot
%     
    set(figurePlot,'Visible','off');

    plot(datax,datay,'--o','MarkerSize',2);
    plot(datax,datay,'-');

    title_Plot = [measurment_type,figname...
        , ' for an applied power of (dBm) = -', power];

    title(title_Plot);
    ylabel(labely);
    xlabel(labelx);
    legend([measurment_type,'-',figname,'-',power, 'dBm']);

    xmax = num2str(datax(size(datax,1),size(datax,2)));
    xmin = num2str(datax(1));
    
   
    
   % Saving
   
   % First remove points by commas
   pointXmin = findstr(xmin,'.')
   pointXmax = findstr(xmin,'.')

   xmin(pointXmin) = ',';
   xmax(pointXmax) = ',';
   
   
    print([figname,'_',...
        measurment_type,'_','[',xmin(1),',',xmin(2),'e9',',',...
        xmax(1),',',xmax(2),'e9',']','_','Power = ',...
        strtok(power,...
        '.')],'-dpdf');
    
    print([figname,'_',...
        measurment_type,'_','[',xmin(1),',',xmin(2),'e9',',',...
        xmax(1),',',xmax(2),'e9',']','_','Power = ',...
        strtok(power,...
        '.')],'-dpng');    
    
   
    saveas(figurePlot,[figname,'_',...
        measurment_type,'_','[',xmin(1),',',xmin(2),'e9',',',...
        xmax(1),',',xmax(2),'e9',']','_','Power = ',...
        strtok(power,...
        '.')],'fig');


    % To fit it. Only works for fitting Amplitude of S21
    
    if fitYes == 1 && strcmp('S_{21 normalized} (dBm)',labely) &&...
                            strcmp('- Transmission vs freq ',measurment_type)
        
        ifYes(datax,datay,...
               measurment_type,figname,power)   
    end

end


% Function to fit the desired plot
function ifYes(Datax,Datay,Measurement_Type,Title,Power)
           
    % Ask the person if he wants to save it
    promptMessage = sprintf('Do you want to fit this plot?');

    button = questdlg(promptMessage, '...', 'Yes', 'No', 'Yes');

    if strcmpi(button, 'Yes')

   compare_FitS21ResonTiN_Assymetric( Datax,Datay,...
       Measurement_Type,Title,Power);

    end         

end

% Normalize S21 and plot it 

function [S21normalized,S21_normalizer,Freq_normalizer,failed] = ...
                 normalizeS21(normalize_all,normalize,DataTot,treshold,...
                        Power,Npoints,Npower,fitYes)
                    
    S21normalized = 0;
    S21_normalizer = 0;
    Freq_normalizer = 0;

                    

    if normalize_all == 1
        
        [S21normalized,S21_normalizer,Freq_normalizer,norm,failed] = ....
            calc_normalize_S21(DataTot,Npower,treshold);
        
        
        if failed == 0
            
            % The space in between - and Transmission is so that I am able
            % to tell which one I want to fit
        
            plotVNATiN(['S21 Normalized by',norm],'- Transmission vs freq ',...
                    'S_{21 normalized} (dBm)','Frequency (Hz)',...
                    Freq_normalizer,10.*log(abs(S21normalized)),...
                    num2str(Power(1 + Npoints*(Npower-1))),fitYes);
                
            plotVNATiN('S21 used to Normalize','-Transmission vs freq ',...
                    'S_{21 normalized} (dBm)','Frequency (Hz)',...
                    Freq_normalizer,10.*log(S21_normalizer),...
                    num2str(Power(1 + Npoints*(Npower-1))),fitYes);   
                
 
            plotVNATiN(['S21 Normalized by - ',norm],'- Real(S21) vs Imag(S21) ',...
                    'Real(S_{21 normalized}))','Imag(S_{21 normalized})',...
                    real(S21normalized),imag(S21normalized),...
                    num2str(Power(1 + Npoints*(Npower-1))),fitYes);
                
            plotVNATiN('S21 used to Normalize -','- Real(S21) vs Imag(S21) ',... 
                    'Real(S_{21 normalized}))','Imag(S_{21 normalized})',...
                    real(S21_normalizer(2:end,:)),imag(S21_normalizer(2:end,:)),...
                    num2str(Power(1 + Npoints*(Npower-1))),fitYes);        
                
           
        end
                
                
    elseif normalize == 1
        
        promptMessage = sprintf(['Do you want to normalize S21 for power = '...
            ,num2str(Power(1 + Npoints*(Npower-1))),'  ?']);

        button = questdlg(promptMessage,'...','Yes','No','Yes');

        if strcmpi(button,'Yes')
            
            % Normalize the experimental data. Treshold parameter is not important
            %   You will be asked to select a file from which the program can use its data to
            %    normalize the original data.
            
            [S21normalized,S21_normalizer,Freq_normalizer,norm,failed] =...
                calc_normalize_S21(DataTot,Npower,treshold);

            if failed == 0

                plotVNATiN(['S21 Normalized by',norm],'- Transmission vs freq ',...
                        'S_{21 normalized} (dBm)','Frequency (Hz)',...
                        Freq_normalizer,10.*log(S21normalized),...
                        num2str(Power(1 + Npoints*(Npower-1))),fitYes);
                    
                plotVNATiN('S21 used to Normalize','-Transmission vs freq',...
                    'S_{21 normalized} (dBm)','Frequency (Hz)',...
                    Freq_normalizer,10.*log(S21_normalizer),...
                    num2str(Power(1 + Npoints*(Npower-1))),fitYes);
                                    
                plotVNATiN(['S21 Normalized by - ',norm],'- Real(S21) vs Imag(S21) ',...
                    'Real(S_{21 normalized}))','Imag(S_{21 normalized})',...
                    real(S21normalized),imag(S21normalized),...
                    num2str(Power(1 + Npoints*(Npower-1))),fitYes);
                
                plotVNATiN('S21 used to Normalize - -','- Real(S21) vs Imag(S21) ',...
                    'Real(S_{21 normalized}))','Imag(S_{21 normalized})',...
                    real(S21_normalizer(2:end,:)),imag(S21_normalizer(2:end,:)),...
                    num2str(Power(1 + Npoints*(Npower-1))),fitYes);                  
                    
                    
            end
            
        else
            
            failed = 1;

        end
      
    else 
       
        failed = 1;
       
    end




end


% Normalize the S21 data

function [abs_S21normalized,abs_S21_normalizer,FrequencyOrig,norm,failed] = ....
    calc_normalize_S21(DataTot,Npower,treshold)

failed = 0;

[Filename, Pathname, Filterindex] = uigetfile('.txt','Select your file', ...
                                        'Multiselect','off');


FrequencyOrig = DataTot{3,1 +10*(Npower-1)};

S21Orig = DataTot{3,4 +10*(Npower-1)};
                                    
                                    
while Filterindex == 0 && failed ==0
    
    msgbox('You have failed to selcted a file');
    
    promptMessage = sprintf('Was it an accident ?');
    
    button = questdlg(promptMessage,'...','Yes','No','Yes');
    
    if strcmpi(button,'Yes')
        
        [Filename, Pathname, Filterindex] = uigetfile('.txt','Select your file', ...
                                        'Multiselect','off');
                                    
    elseif strcmpi(button,'No')
        
        failed = 1;
        
    end  
    
end

if failed == 0
    
    
      % Just Read the file
    [Frequency,S21] = readfile(Filename,Pathname);
  
    % Lienar Interpolation
    
    abs_S21_normalizer = interp1(Frequency,abs(S21),FrequencyOrig);
    
    abs_S21normalized = abs(S21Orig)./abs_S21_normalizer;
    norm = 'Direct - without swhitch';   
end




end


% Read the file

function [Frequency,S21] = readfile(Filename,Pathname)

    FileText = fopen([Pathname,Filename],'rt');

    HeaderText = textscan(FileText,'%q',3,'Delimiter',',');
    DataText = textscan(FileText,'%f64 %f64 %f64 ','Delimiter',' ');

    Frequency = DataText{1};
    
    S21 = DataText{2} + 1i.*DataText{3};
 


end


