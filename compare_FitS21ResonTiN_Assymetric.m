function compare_FitS21ResonTiN_Assymetric( omegaexp,S21exp,Measurement_Type,Mode ...
               ,Power )
%compare_FitS21( omegaexp,S21exp ) Plots a GUI to help with the fitting  
%   omegaexp is the frequency domain that the S21 was measured
%   S21exp is the measured value
%   In this version the correction is applied to the calculated fit
%   The experimental data is S21exp = 10.*log(abs( of real S21 measured))
%   The equation used here is the same one as Dumur has deduced for his
%   resonators.


% only initialization
expfitparam = zeros(1,1);

figS21fit = figure('numbertitle','off','name','Add data');
set(figS21fit,'Units','pixels','position',[200 200 1000 700]);
set(figS21fit,'Resize','off');

%% Panels

panelPlots = uipanel('parent',figS21fit,... 
                       'Units','Normalized','Position',[0.02,0.1,0.7,0.8]);
set(panelPlots,'BackgroundColor','white');
%% Axis

panelAx = axes('Units','normal','Position',[0.1 0.1 0.8 0.8],'Parent',panelPlots);

%% EditText and TitleText



editf0 = uicontrol('parent',figS21fit,'Style','edit','Units','Normalized',...
                    'Position',[0.854,0.914,0.144,0.058]);
                
textf0 = uicontrol('parent',figS21fit,'Style','text','Units','Normalized',...
                    'Position',[0.75,0.914,0.076,0.037],'String','f_0 = ');
                
editRangeMin = uicontrol('parent',figS21fit,'Style','edit','Units','Normalized',...
                    'Position',[0.854,0.818,0.144,0.058]);
                
textRangeMin = uicontrol('parent',figS21fit,'Style','text','Units','Normalized',...
                    'Position',[0.75,0.818,0.076,0.037],'String','f_min = ');
                
editRangeMax = uicontrol('parent',figS21fit,'Style','edit','Units','Normalized',...
                    'Position',[0.854,0.718,0.144,0.058]);
                
textRangeMax = uicontrol('parent',figS21fit,'Style','text','Units','Normalized',...
                    'Position',[0.75,0.718,0.076,0.037],'String','f_max = ');               
                               
              
                
editQc = uicontrol('parent',figS21fit,'Style','edit','Units','Normalized',...
                    'Position',[0.854,0.618,0.144,0.058]);
                
slideQc = uicontrol('parent',figS21fit,'Style','slider',...
                    'Min',10,'Max',7000,'Value',10,...
                    'Units','Normalized','Position',[0.754,0.558,0.220,0.025],...
                    'Callback',@callbackslideQc);
set(slideQc,'SliderStep',[1e-03,1e-2])
                
% Allow to change the slide current value when the value in the edit box is
% % changed

addlistener(editQc,'String','PostSet',...
    @changeslideQc);

textQc = uicontrol('parent',figS21fit,'Style','text','Units','Normalized',...
                    'Position',[0.75,0.614,0.076,0.058],'String','Q_c = ');
                
editQ0 = uicontrol('parent',figS21fit,'Style','edit','Units','Normalized',...
    'Position',[0.854,0.418,0.144,0.058]);
   
slideQ0 = uicontrol('parent',figS21fit,'Style','slider',...
                    'Min',10,'Max',7000,'Value',10,...
                    'Units','Normalized','Position',[0.754,0.518,0.220,0.025],...
                    'Callback',@callbackslideQ0);

set(slideQ0,'SliderStep',[1e-3,1e-2]);

textXe = uicontrol('parent',figS21fit,'Style','text','Units','Normalized',...
                    'Position',[0.75,0.318,0.076,0.058],'String','X_e = ');
                
editXe = uicontrol('parent',figS21fit,'Style','edit','Units','Normalized',...
    'Position',[0.854,0.318,0.09,0.058]);

% Allow to change the slide current value when the value in the edit box is
% % changed
addlistener(editQ0,'String','PostSet',...
    @changeslideQ0);


textQ0 = uicontrol('parent',figS21fit,'Style','text','Units','Normalized',...
                    'Position',[0.75,0.414,0.076,0.058],'String','Q_0 = ');           
                
editDec = uicontrol('parent',figS21fit,'Style','edit','Units','Normalized',...
    'Position',[0.854,0.218,0.144,0.058]);
                
textDec = uicontrol('parent',figS21fit,'Style','text','Units','Normalized',...
                    'Position',[0.75,0.214,0.076,0.058],'String','Correction of = ');               

%% Button
                
ButtonTest = uicontrol('parent',figS21fit,'Style','pushbutton','Units',...
    'Normalized','Position',[0.854,0.118,0.120,0.058],...
    'String',' Test','Callback',@callbackbuttontest);

ButtonNext = uicontrol('parent',figS21fit,'Style','pushbutton','Units',...
    'Normalized','Position',[0.854,0.018,0.144,0.058],...
    'String',' Next','Callback',@callbackbuttonNext);

ButtonLevel = uicontrol('parent',figS21fit,'Style','pushbutton','Units',...
    'Normalized','Position',[0.75,0.118,0.120,0.058],...
    'String',' Set to 0','Callback',@callbackbuttonLevel);

ButtonLevel = uicontrol('parent',figS21fit,'Style','pushbutton','Units',...
    'Normalized','Position',[0.7,0.018,0.144,0.058],...
    'String',' Save','Callback',@callbackbuttonsave);




h = plot(omegaexp,S21exp);

set(h,'Parent',panelAx);

title_Plot = [Measurement_Type, ' in ',Mode, ' for an applied power of (dBm) = -', Power];

title(title_Plot);
ylabel(Mode);
xlabel(' Frequency(Hz)');
legend([Measurement_Type,'-',Mode,'-',Power, 'dBm']);

%% Callback functions

    function callbackbuttontest(~,~)
        
        % Recover the values
        f0 = str2num(get(editf0,'String'));
        Q0 = str2num(get(editQ0,'String'));
        Qc = str2num(get(editQc,'String'));
        Xe = str2num(get(editXe,'String'));
        RangeMin = str2num(get(editRangeMin,'String'));
        RangeMax = str2num(get(editRangeMax,'String'));
    
        updatePlot(f0,Q0,Qc,Xe,RangeMin,RangeMax)
    
    end


    function callbackbuttonNext(~,~)
        
        
        deduce_res_param( expfitparam )
        
        close(figS21fit);
        
    end


    function callbackbuttonsave(~,~)
    
        % 3x3 matrix with saved f0 , Qc and Qo
        f0 = str2num(get(editf0,'String'));
        Q0 = str2num(get(editQ0,'String'));
        Qc = str2num(get(editQc,'String'));
        Xe = str2num(get(editXe,'String'));
        
        % Ask the person if he wants to save it
        promptMessage = sprintf(['Do you want to save f0 :', ...
            num2str(f0), '-Q0: ',num2str(Q0),'-Qc: ', num2str(Qc)]);

        button = questdlg(promptMessage, '..', 'Yes', 'No', 'Yes');

        if strcmpi(button, 'Yes')
            
            
            if expfitparam == zeros(1,1)
            
                expfitparam(1,1) = f0;
                expfitparam(1,2) = Q0;
                expfitparam(1,3) = Qc;       
                expfitparam(1,4) = Xe;
                
            else
                
                expfitparam(size(expfitparam,1)+1,1) = f0;
                expfitparam(size(expfitparam,1),2) = Q0;
                expfitparam(size(expfitparam,1),3) = Qc;
                expfitparam(size(expfitparam,1),4) = Xe;
                
            end


        % Confirm it
        warndlg(['f0: ', num2str( expfitparam(size(expfitparam,1),1)),...
                 '-Q0: ',num2str( expfitparam(size(expfitparam,1),2)),...
                 '-Qc', num2str( expfitparam(size(expfitparam,1),3)),...
                 '-X_e', num2str( expfitparam(size(expfitparam,1),4)),...
                 'Has been saved']);
    
    
             
        end
        
    end


    function callbackbuttonLevel(~,~)
        
        areempty = 0;
        
        % Recover the values and check if they are empty
        editDec0 = str2num(get(editDec,'String'));
        areempty = areempty + isempty(editDec0);
        
        f0 = str2num(get(editf0,'String'));
        areempty = areempty + isempty(f0);
        
        Q0 = str2num(get(editQ0,'String'));
        areempty = areempty + isempty(Q0);
        
        Qc = str2num(get(editQc,'String'));
        areempty = areempty + isempty(Qc);
        
        RangeMin = str2num(get(editRangeMin,'String'));
        areempty = areempty + isempty(RangeMin);
        
        RangeMax = str2num(get(editRangeMax,'String'));
        areempty = areempty + isempty(RangeMax);
        
        Xe = str2num(get(editXe,'String'));
        areempty = areempty + isempty(RangeMax);
        
        
        if areempty == 0
       
        updatePlotCorrection(editDec0,f0,Q0,Qc,Xe,RangeMin,RangeMax)  
        
        end
        
    end 

% % Function allowing to change the value of the slider as one changes
% % the value of the editboxQc
% 
    function changeslideQc(~,~)
        
        currentValue = str2num(get(editQc,'String'));
        set(slideQc,'Value',currentValue);
        get(slideQc,'Value');
 
        
    end

% % Function allowing to change the value of the slider as one changes
% % the value of the editboxQio
% 
    function changeslideQ0(~,~)
        
        currentValue = str2num(get(editQ0,'String'));
        set(slideQ0,'Value',currentValue);
        get(slideQc,'Value');
        
    end

% Update the plot as the user changes the value in the slider

    function callbackslideQ0(~,~)
    
        set(editQ0,'String', num2str(get(slideQ0,'Value')));
        
        areempty = 0;
        
        % Recover the values and check if they are empty
        editDec0 = str2num(get(editDec,'String'));
        areempty = areempty + isempty(editDec0);
        
        f0 = str2num(get(editf0,'String'));
        areempty = areempty + isempty(f0);
        
        Q0 = str2num(get(editQ0,'String'));
        areempty = areempty + isempty(Q0);
        
        Qc = str2num(get(editQc,'String'));
        areempty = areempty + isempty(Qc);
        
        RangeMin = str2num(get(editRangeMin,'String'));
        areempty = areempty + isempty(RangeMin);
        
        RangeMax = str2num(get(editRangeMax,'String'));
        areempty = areempty + isempty(RangeMax);
        
        Xe = str2num(get(editXe,'String'));
        areempty = areempty + isempty(RangeMax);
        
        
        if areempty == 0
       
        updatePlotCorrection(editDec0,f0,Q0,Qc,Xe,RangeMin,RangeMax)  
        
        end
    
    end


    function callbackslideQc(~,~)
        
        set(editQc,'String', num2str(get(slideQc,'Value')));
        
        areempty = 0;
        
        % Recover the values and check if they are empty
        editDec0 = str2num(get(editDec,'String'));
        areempty = areempty + isempty(editDec0);
        
        f0 = str2num(get(editf0,'String'));
        areempty = areempty + isempty(f0);
        
        Q0 = str2num(get(editQ0,'String'));
        areempty = areempty + isempty(Q0);
        
        Qc = str2num(get(editQc,'String'));
        areempty = areempty + isempty(Qc);
        
        RangeMin = str2num(get(editRangeMin,'String'));
        areempty = areempty + isempty(RangeMin);
        
        RangeMax = str2num(get(editRangeMax,'String'));
        areempty = areempty + isempty(RangeMax);
        
        Xe = str2num(get(editXe,'String'));
        areempty = areempty + isempty(RangeMax);        
        
        if areempty == 0
       
        updatePlotCorrection(editDec0,f0,Q0,Qc,Xe,RangeMin,RangeMax)  
        
        end
    end

% Function used to calculate the new plot to be updated

    function updatePlotCorrection(editDec0,f0,Q0,Qc,Xe,RangeMin,RangeMax)   
        
        % Find the position of RangeMin and RangeMax for the experimental 
        [rowMin,columnMin]=find(omegaexp >= RangeMin,1);
        [rowMax,columnMax]=find(omegaexp >= RangeMax,1);
        
        % Apply the correction
        
%         S21expCorrected = S21exp(rowMin:rowMax,columnMin:columnMax)...
%                   +editDec0.*ones(size(S21exp(rowMin:rowMax,columnMin:columnMax)));
%               
        

        % calculate S21 
        [ frequency,S21 ] = fitS21ResonTiN_Assymetric( Q0,f0,Qc,Xe,...
                                                        RangeMin,RangeMax );
        
        TeoS21corrected = 10.*log(abs(S21))- ...
            editDec0.*ones(size(S21));
        
        
        % plot the corrected value
        
        delete(get(panelAx,'Children'));
        
        
%         h3 = plot(frequency,10.*log(abs(S21)),...
%         omegaexp(rowMin:rowMax,columnMin:columnMax),...
%         S21exp(rowMin:rowMax,columnMin:columnMax),...
%         omegaexp(rowMin:rowMax,columnMin:columnMax),S21expCorrected);


        h3 = plot(frequency,TeoS21corrected,...
        omegaexp(rowMin:rowMax,columnMin:columnMax),...
        S21exp(rowMin:rowMax,columnMin:columnMax),...
        '--ok','LineWidth',0.5,'MarkerSize',2);


        title_Plot = [Measurement_Type, ' in ',Mode,...
            ' for an applied power of (dBm) = -', Power];

        title(title_Plot);
        ylabel([Mode,'(dB)']);
        xlabel(' Frequency(GHz)');
        hlegen = legend(['Fit with Q_c = ',num2str(Qc),' - Q_0 = ',num2str(Q0),...
            '- f_0 = ',num2str(f0),' and correction of ',...
            num2str(editDec0)],...
            [Measurement_Type,'-',Mode,'-',Power, 'dBm']);
        
        set(hlegen,'Visible','off');
    
        set(h3,'Parent',panelAx);
        
    
    end    


    function updatePlot(f0,Q0,Qc,Xe,RangeMin,RangeMax)
        
        % Find the position of RangeMin and RangeMax for the experimental 
        [rowMin,columnMin]=find(omegaexp >= RangeMin,1);
        [rowMax,columnMax]=find(omegaexp >= RangeMax,1);
        
        % calculate S21 
        [ frequency,S21 ] = fitS21ResonTiN_Assymetric( Q0,f0,Qc,Xe,...
                                                        RangeMin,RangeMax );
        
        
        delete(get(panelAx,'Children'));
        

        h2 = plot(frequency,10.*log(abs(S21)),...
        omegaexp(rowMin:rowMax,columnMin:columnMax),...
        S21exp(rowMin:rowMax,columnMin:columnMax),...
        '--ok','LineWidth',0.5,'MarkerSize',2);
    
        title_Plot = [Measurement_Type, ' in ',Mode,...
            ' for an applied power of (dBm) = -', Power];

        title(title_Plot);
        ylabel([ Mode, '(dB)']);
        xlabel(' Frequency(Hz)');
        hlegen = legend(['Fit with Q_c = ',num2str(Qc),' - Q_0 = ',num2str(Q0)],...
            [Measurement_Type,'-',Mode,'-',Power, 'dBm']);
        
        set(hlegen,'Visible','off');
    
        set(h2,'Parent',panelAx);
    
        %legend('Experimental', 'Fit');
        
    end

uiwait(figS21fit);   
                   
end