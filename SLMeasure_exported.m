classdef SLMeasure_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SLMeasureUIFigure          matlab.ui.Figure
        FileMenu                   matlab.ui.container.Menu
        SaveMeasurementMenu        matlab.ui.container.Menu
        LoadMeasurementMenu        matlab.ui.container.Menu
        MicroscopeCalibrationumpxEditField  matlab.ui.control.NumericEditField
        MicroscopeCalibrationumpxEditFieldLabel  matlab.ui.control.Label
        BoxSelectionDropDown       matlab.ui.control.DropDown
        BoxSelectionDropDownLabel  matlab.ui.control.Label
        NewBoxButton               matlab.ui.control.Button
        LoadImageButton            matlab.ui.control.Button
        SarcomereLengthCalculationPanel  matlab.ui.container.Panel
        ExportSLTableButton        matlab.ui.control.Button
        UITable                    matlab.ui.control.Table
        sl_row_axes                matlab.ui.control.UIAxes
        ac_axes                    matlab.ui.control.UIAxes
        fft_axes                   matlab.ui.control.UIAxes
        BrightfieldPanel           matlab.ui.container.Panel
        ROIRowSelectSpinner        matlab.ui.control.Spinner
        ROIRowSelectSpinnerLabel   matlab.ui.control.Label
        ROIWidthpxEditField        matlab.ui.control.NumericEditField
        ROIWidthpxEditFieldLabel   matlab.ui.control.Label
        ROIHeightpxEditField       matlab.ui.control.NumericEditField
        ROIHeightpxEditFieldLabel  matlab.ui.control.Label
        calculation_axes           matlab.ui.control.UIAxes
        px_intensity               matlab.ui.control.UIAxes
        inset_axes                 matlab.ui.control.UIAxes
        image_axes                 matlab.ui.control.UIAxes
    end


    properties (Access = private)

    end

    properties (Access = public)
        image_file % Description
        roi_pos
        roi_rec
        px_cal
        roi_box
        profile
        sig
        background
        sl_data % Description
        P2 % Description
        lags
        X_acf % Description
        wavelength % Description
        y_fit % Description
    end

    methods (Access = private)

        function ClearDisplay(app)
            cla(app.image_axes)
            cla(app.inset_axes)
            cla(app.px_intensity)
            cla(app.calculation_axes)
            cla(app.fft_axes)
            cla(app.ac_axes)
            cla(app.sl_row_axes)
            app.MicroscopeCalibrationumpxEditField.Value = 0.000;
            app.ROIHeightpxEditField.Value = 0;
            app.ROIWidthpxEditField.Value = 0;
        end

    end

    methods (Access = public)

        function SarcomereLength(app)
            cla(app.px_intensity);
            cla(app.inset_axes);
            cla(app.calculation_axes);
            cla(app.ac_axes);
            cla(app.fft_axes);
            cla(app.sl_row_axes);
            box_no = str2num(app.BoxSelectionDropDown.Value);
            app.profile = [];
            app.roi_box = [];
            app.roi_box = imcrop(app.sl_data.image_file, ...
                app.sl_data.box_handle(box_no).Position);
            center_image_with_preserved_aspect_ratio( ...
                app.roi_box, ...
                app.inset_axes);

            [m,n] = size(app.roi_box);
            app.ROIHeightpxEditField.Value = m;
            app.ROIWidthpxEditField.Value = n;

            app.ROIRowSelectSpinner.Limits = [1,m];
            p = app.sl_data.box_handle(box_no).Position;
            set(app.sl_data.box_label(box_no),'String',sprintf('%.0f',box_no));
            set(app.sl_data.box_label(box_no), ...
                'Position',[p(1)+p(3)+20 ...
                p(2)-30]);

            app.profile = [];
            app.sig = [];
            sl_fft = [];
            sl_acf = [];
            app.P2 = [];
            app.X_acf = [];
            app.wavelength = [];
            app.lags = [];
            app.y_fit = [];

            for ct = 1 : size(app.roi_box,1)
                app.profile(ct,:) = app.roi_box(ct,:);
                app.sig(ct,:)  = diff(app.profile(ct,:));
                w = hann(length(app.sig(ct,:)));
                [sl_fft(ct)] = SarcLenFFT(app,ct);
                [sl_acf(ct)] = SarcLenAutoCorr(app,ct);
            end
            app.sl_data.sarcomere_length_fft(box_no) = mean(sl_fft);
            app.sl_data.sarcomere_length_acf(box_no) = mean(sl_acf);

            hold(app.sl_row_axes,"on")
            plot(app.sl_row_axes,1:ct,sl_fft,'rd',"LineWidth",2)
            plot(app.sl_row_axes,1:ct,sl_acf,'gd',"LineWidth",2)
            legend(app.sl_row_axes,'FFT SL Results','ACF SL Results','Location','best')
            xlim(app.sl_row_axes,[0.5 ct+0.5])
            ylim(app.sl_row_axes,[0 max(max(sl_acf),max(sl_fft))+0.2])
            UpdateDisplay(app)
        end

        function sl_ac = SarcLenAutoCorr(app,ct)
            x = app.sig(ct,:);
            [app.X_acf(ct,:),app.lags(ct,:)] = autocorr(x,NumLags=round(numel(x)/2));
            if ct == inf
                draw_graph = 1;
            else
                draw_graph = 0;
            end
            [lambda,fit_parameters,r_squared,app.y_fit(ct,:)] = fit_damped_sine_wave('y_data',app.X_acf(ct,:),...
                'x_data',0:round(numel(x)/2), 'min_x_index_spacing',5,'draw_graph',draw_graph);
            if app.px_cal ~=0
                sl_ac = lambda * app.px_cal;
                app.wavelength(ct) = lambda;
            else
                sl_ac = 0;
            end
        end

        function sl_fft = SarcLenFFT(app,ct)
            x = app.sig(ct,:);
            X = fft(x);
            L = numel(X);
            app.P2(ct,:) = abs(X/L);
            [peaks, locs] = findpeaks(app.P2(ct,:));
            [max_mag,max_ix] = max(peaks);
            F_p = 0:numel(app.P2(ct,:))-1;
            if app.px_cal ~=0
                sl_fft = numel(x)*app.px_cal/F_p(locs(max_ix));
            else
                sl_fft = 0;
            end
        end


        function UpdateTable(app)

            for i = 1:numel(app.sl_data.sarcomere_length_fft)
                s.box_no{i,1} = sprintf('%i',i);
                s.fft_sl{i,1} = sprintf('%.3f',app.sl_data.sarcomere_length_fft(i));
                s.acf_sl{i,1} = sprintf('%.3f',app.sl_data.sarcomere_length_acf(i));
            end

            s.box_no{end+1,1} = 'Average';
            s.fft_sl{end+1,1} = sprintf('%.3f',mean(app.sl_data.sarcomere_length_fft));
            s.acf_sl{end+1,1} = sprintf('%.3f',mean(app.sl_data.sarcomere_length_acf));

            t = struct2table(s);

            app.UITable.Data = t;


        end

        function UpdateDisplay(app)
            row_no = app.ROIRowSelectSpinner.Value;
            hold(app.px_intensity,"on")
            m = app.ROIRowSelectSpinner.Limits(2);
            cm = lines(m);
            for j = 1 : m
                plot(app.px_intensity,app.roi_box(j,:), ...
                    'LineStyle',':',"LineWidth",0.25,'Color',cm(j,:));
            end

            plot(app.px_intensity,app.roi_box(row_no,:), ...
                'LineStyle','-',"LineWidth",2,'Color',cm(row_no,:));
            hold(app.calculation_axes,"on")
            plot(app.calculation_axes, app.sig(row_no,:),'Color',cm(row_no,:),"LineWidth",2)
            xlim(app.px_intensity, [1 numel(app.profile(row_no,:))])
            xlim(app.calculation_axes, [1 numel(app.profile(row_no,:))])

            hold(app.fft_axes,"on")
            F_p = 0:numel(app.P2(row_no,:))-1;
            [peaks, locs] = findpeaks(app.P2(row_no,:));
            [max_mag,max_ix] = max(peaks);
            fft_ix = (1:numel(app.P2(row_no,:))-1)/(numel(app.P2(row_no,:))*app.px_cal);
            fft_ix = [0 fft_ix];
            plot(app.fft_axes,fft_ix,app.P2(row_no,:),'Color',cm(row_no,:),'LineWidth',2)
            plot(app.fft_axes,fft_ix(locs(max_ix)),app.P2(row_no,locs(max_ix)),'pentagram', ...
                'MarkerSize',15,"Color",'k','MarkerFaceColor','k')
            xlim(app.fft_axes,[0 fft_ix(end)])
            ylim(app.fft_axes,[0 max(max(app.P2))+1])
            t = sprintf('Peak is at %.3f um^{-1}',fft_ix(locs(max_ix)));
            text(app.fft_axes,fft_ix(locs(max_ix))+0.25,max(peaks),t)

            plot(app.ac_axes,app.lags(row_no,:),app.X_acf(row_no,:),'LineWidth',2,'color',cm(row_no,:))
            hold(app.ac_axes,"on")
            plot(app.ac_axes,app.lags(row_no,:),app.y_fit(row_no,:),'o','color','k','LineWidth',2)
            if ~isempty(app.wavelength)
                t = sprintf('Wavelength  = %.3f px',app.wavelength(row_no));
                text(app.ac_axes,round(0.7*numel(app.X_acf(row_no,:)))-10,0.8,t)
            end
            %             xlim(app.ac_axes,[0 round(numel(x)/2)])
            ylim(app.ac_axes,[-1 1])

        end
        
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            colormap(app.SLMeasureUIFigure, 'gray');
            addpath(genpath('utilities'))
            movegui(app.SLMeasureUIFigure,'center')


        end

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, event)

            filterspec = {'*.tif;*.png','All Image Files'};
            [file_string,path_string] = uigetfile2(filterspec);
            if (path_string~=0)
                ClearDisplay(app)
                app.sl_data = [];
                app.UITable.Data = [];
                app.sl_data.image_file_string = fullfile(path_string,file_string);
                im = imread(app.sl_data.image_file_string);
                if (ndims(im)==3)
                    im = rgb2gray(im);
                end
                center_image_with_preserved_aspect_ratio( ...
                    im, ...
                    app.image_axes);
                app.sl_data.image_file = im;
            end
        end

        % Button pushed function: NewBoxButton
        function NewBoxButtonPushed(app, event)

            if (~isfield(app.sl_data,'box_handle'))
                n=1;
                app.sl_data.box_handle(n) = drawrectangle(app.image_axes);
                p = app.sl_data.box_handle(n).Position;
                app.sl_data.old_width = p(3);
                app.sl_data.old_height = p(4);
            else
                n = 1 + numel(app.sl_data.box_handle);
                p = app.sl_data.box_handle(n-1).Position;

                app.sl_data.box_handle(n) = images.roi.Rectangle(app.image_axes, ...
                    'Position',p + [150,0,0,0]);
                for i=1:(n-1)
                    app.sl_data.box_handle(i).InteractionsAllowed = 'none';
                end

            end

            app.sl_data.box_handle(n).Color = [0 1 0];
            app.sl_data.box_handle(n).FaceAlpha = 0;
            for i=1:(n-1)
                app.sl_data.box_handle(i).Color = [1 0 0];
            end

            app.sl_data.box_label(n) = text(app.image_axes, ...
                p(1)+p(3)+20,p(2)-30,sprintf('%.0f',n),'FontWeight',"bold","FontSize",18,"Color",'w');

            app.roi_pos = get(app.roi_rec, 'Position');
            app.px_cal = app.MicroscopeCalibrationumpxEditField.Value;

            for i=1:n
                control_strings{i}=sprintf('%.0f',i);
            end

            app.BoxSelectionDropDown.Items = control_strings;
            app.BoxSelectionDropDown.Value = control_strings{n};

            SarcomereLength(app)
            UpdateTable(app);
            addlistener(app.sl_data.box_handle(n),"MovingROI",@(src,evt) UpdateSL(evt));

            function UpdateSL(evt)
                box_no = str2num(app.BoxSelectionDropDown.Value);
                app.ROIHeightpxEditField.Value = app.sl_data.box_handle(box_no).Position(3);
                app.ROIWidthpxEditField.Value = app.sl_data.box_handle(box_no).Position(4);
                cla(app.px_intensity)
                cla(app.calculation_axes)
                cla(app.fft_axes)
                cla(app.ac_axes)
                SarcomereLength(app)
                UpdateTable(app);
            end

        end

        % Value changed function: MicroscopeCalibrationumpxEditField
        function MicroscopeCalibrationumpxEditFieldValueChanged(app, event)
            app.px_cal = app.MicroscopeCalibrationumpxEditField.Value;
            if isfield(app.sl_data,'box_handle')
                SarcomereLength(app)
                UpdateTable(app)
            end
        end

        % Value changed function: BoxSelectionDropDown
        function BoxSelectionDropDownValueChanged(app, event)
            selected_box = str2num(app.BoxSelectionDropDown.Value);
            control_strings = app.BoxSelectionDropDown.Items;

            n = numel(control_strings);
            for i=1:n
                if (i~=selected_box)
                    app.sl_data.box_handle(i).Color = [1 0 0];
                    app.sl_data.box_handle(i).InteractionsAllowed = 'none';
                else
                    app.sl_data.box_handle(i).Color = [0 1 0];
                    app.sl_data.box_handle(i).InteractionsAllowed = 'all';
                end
            end
            SarcomereLength(app)
        end

        % Value changed function: ROIRowSelectSpinner
        function ROIRowSelectSpinnerValueChanged(app, event)
            value = app.ROIRowSelectSpinner.Value;
            cla(app.ac_axes)
            cla(app.fft_axes)
            cla(app.calculation_axes)
            cla(app.px_intensity)
            cla(app.ac_axes)
            UpdateDisplay(app)
        end

        % Button pushed function: ExportSLTableButton
        function ExportSLTableButtonPushed(app, event)
            [file_string,path_string] = uiputfile2( ...
                {'*.xlsx','Excel file'},'Select file name for SL Table');
            output_file = fullfile(path_string,file_string);

            try
                delete(output_file);
            end

            writetable(app.UITable.Data,output_file,'Sheet','Summary')
        end

        % Menu selected function: SaveMeasurementMenu
        function SaveMeasurementMenuSelected(app, event)
            if ~isfield(app.sl_data,'box_handle')
                warndlg('The measurement boxes are not available.')
                return
            end
            [file_string,path_string] = uiputfile2( ...
                {'*.sl','SL measurement file'},'Select file to save measurement');

            for i=1:numel(app.sl_data.box_handle)
                app.sl_data.box_position(i,:) = app.sl_data.box_handle(i).Position;
            end
            save_data.image_file_string = app.sl_data.image_file_string;
            save_data.im_data = app.sl_data.image_file;
            save_data.px_cal = app.px_cal;
            save_data.box_position = app.sl_data.box_position;

            if (path_string~=0)
                save(fullfile(path_string,file_string),'save_data');
            end

        end

        % Menu selected function: LoadMeasurementMenu
        function LoadMeasurementMenuSelected(app, event)
            [file_string,path_string] = uigetfile2( ...
                {'*.sl','SL measurement file'},'Select file to load measurement');
            if (path_string~=0)
                ClearDisplay(app)
                if (isfield(app.sl_data,'box_handle'))
                    n = numel(app.sl_data.box_handle);
                    for i=1:n
                        delete(app.sl_data.box_handle(i));
                    end
                end

                temp = load(fullfile(path_string,file_string),'-mat','save_data');
                save_data = temp.save_data;

                app.sl_data = [];
                app.sl_data.image_file_string = save_data.image_file_string;
                app.sl_data.image_file = save_data.im_data;
                app.px_cal = save_data.px_cal;
                app.MicroscopeCalibrationumpxEditField.Value = app.px_cal;
                

                center_image_with_preserved_aspect_ratio( ...
                    app.sl_data.image_file, ...
                    app.image_axes);
                control_strings = [];
                for i=1:size(save_data.box_position,1)
                    app.sl_data.box_handle(i) = images.roi.Rectangle(app.image_axes, ...
                        'Position',save_data.box_position(i,:));
                    control_strings{i} = sprintf('%.0f',i);
                end
                app.BoxSelectionDropDown.Items = control_strings;
                app.BoxSelectionDropDown.Value = control_strings{1};
                for i=1:size(save_data.box_position,1)
                    app.sl_data.box_handle(i).FaceAlpha = 0;
                    if (i~=1)
                        app.sl_data.box_handle(i).Color = [1 0 0];
                        app.sl_data.box_handle(i).InteractionsAllowed = 'none';
                    else
                        app.sl_data.box_handle(i).Color = [0 1 0];
                        app.sl_data.box_handle(i).InteractionsAllowed = 'all';
                    end

                    p = app.sl_data.box_handle(i).Position;
                    app.sl_data.box_label(i) = text(p(1)+p(3),p(2)-30,sprintf('%.0f',i), ...
                        'Parent',app.image_axes,'FontWeight',"bold","FontSize",18,"Color",'w');
                    app.sl_data.old_width = p(3);
                    app.sl_data.old_height = p(4);

                    i=i;
                    addlistener(app.sl_data.box_handle(i),"MovingROI",@(src,evt) UpdateSL2(evt));
                end
                for i = numel(app.sl_data.box_handle) :-1: 1
                    app.BoxSelectionDropDown.Value = num2str(i);
                    SarcomereLength(app)
                    UpdateDisplay(app)
                    UpdateTable(app);
                end
            end
            function UpdateSL2(evt)
                box_no = str2num(app.BoxSelectionDropDown.Value);
                app.ROIHeightpxEditField.Value = app.sl_data.box_handle(box_no).Position(3);
                app.ROIWidthpxEditField.Value = app.sl_data.box_handle(box_no).Position(4);
                cla(app.px_intensity)
                cla(app.calculation_axes)
                cla(app.fft_axes)
                cla(app.ac_axes)
                SarcomereLength(app)
                UpdateTable(app);
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SLMeasureUIFigure and hide until all components are created
            app.SLMeasureUIFigure = uifigure('Visible', 'off');
            app.SLMeasureUIFigure.Position = [100 100 1598 863];
            app.SLMeasureUIFigure.Name = 'SLMeasure';

            % Create FileMenu
            app.FileMenu = uimenu(app.SLMeasureUIFigure);
            app.FileMenu.Text = 'File';

            % Create SaveMeasurementMenu
            app.SaveMeasurementMenu = uimenu(app.FileMenu);
            app.SaveMeasurementMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveMeasurementMenuSelected, true);
            app.SaveMeasurementMenu.Separator = 'on';
            app.SaveMeasurementMenu.Text = 'Save Measurement';

            % Create LoadMeasurementMenu
            app.LoadMeasurementMenu = uimenu(app.FileMenu);
            app.LoadMeasurementMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadMeasurementMenuSelected, true);
            app.LoadMeasurementMenu.Separator = 'on';
            app.LoadMeasurementMenu.Text = 'Load Measurement';

            % Create BrightfieldPanel
            app.BrightfieldPanel = uipanel(app.SLMeasureUIFigure);
            app.BrightfieldPanel.Title = 'Brightfield Panel';
            app.BrightfieldPanel.Position = [18 420 1567 388];

            % Create image_axes
            app.image_axes = uiaxes(app.BrightfieldPanel);
            title(app.image_axes, 'Brightfield Image')
            app.image_axes.XTick = [];
            app.image_axes.YTick = [];
            app.image_axes.Box = 'on';
            app.image_axes.Position = [17 38 539 313];

            % Create inset_axes
            app.inset_axes = uiaxes(app.BrightfieldPanel);
            title(app.inset_axes, 'Region of Interest (ROI)')
            app.inset_axes.XTick = [];
            app.inset_axes.YTick = [];
            app.inset_axes.Box = 'on';
            app.inset_axes.Position = [555 172 325 179];

            % Create px_intensity
            app.px_intensity = uiaxes(app.BrightfieldPanel);
            title(app.px_intensity, 'Intensity Profiles')
            xlabel(app.px_intensity, 'ROI Column')
            ylabel(app.px_intensity, 'Optical Intensity (A.U)')
            zlabel(app.px_intensity, 'Z')
            app.px_intensity.Box = 'on';
            app.px_intensity.Position = [891 38 325 313];

            % Create calculation_axes
            app.calculation_axes = uiaxes(app.BrightfieldPanel);
            title(app.calculation_axes, 'Derivative of the Intensity Profile')
            xlabel(app.calculation_axes, 'ROI Index')
            ylabel(app.calculation_axes, 'd(profile)/dx')
            zlabel(app.calculation_axes, 'Z')
            app.calculation_axes.Box = 'on';
            app.calculation_axes.Position = [1229 38 325 313];

            % Create ROIHeightpxEditFieldLabel
            app.ROIHeightpxEditFieldLabel = uilabel(app.BrightfieldPanel);
            app.ROIHeightpxEditFieldLabel.Position = [620 151 89 22];
            app.ROIHeightpxEditFieldLabel.Text = 'ROI Height (px)';

            % Create ROIHeightpxEditField
            app.ROIHeightpxEditField = uieditfield(app.BrightfieldPanel, 'numeric');
            app.ROIHeightpxEditField.Position = [715 151 100 22];

            % Create ROIWidthpxEditFieldLabel
            app.ROIWidthpxEditFieldLabel = uilabel(app.BrightfieldPanel);
            app.ROIWidthpxEditFieldLabel.Position = [620 111 85 22];
            app.ROIWidthpxEditFieldLabel.Text = 'ROI Width (px)';

            % Create ROIWidthpxEditField
            app.ROIWidthpxEditField = uieditfield(app.BrightfieldPanel, 'numeric');
            app.ROIWidthpxEditField.Position = [715 111 100 22];

            % Create ROIRowSelectSpinnerLabel
            app.ROIRowSelectSpinnerLabel = uilabel(app.BrightfieldPanel);
            app.ROIRowSelectSpinnerLabel.HorizontalAlignment = 'right';
            app.ROIRowSelectSpinnerLabel.Position = [609 73 91 22];
            app.ROIRowSelectSpinnerLabel.Text = 'ROI Row Select';

            % Create ROIRowSelectSpinner
            app.ROIRowSelectSpinner = uispinner(app.BrightfieldPanel);
            app.ROIRowSelectSpinner.ValueChangedFcn = createCallbackFcn(app, @ROIRowSelectSpinnerValueChanged, true);
            app.ROIRowSelectSpinner.Position = [715 69 100 26];
            app.ROIRowSelectSpinner.Value = 1;

            % Create SarcomereLengthCalculationPanel
            app.SarcomereLengthCalculationPanel = uipanel(app.SLMeasureUIFigure);
            app.SarcomereLengthCalculationPanel.Title = 'Sarcomere Length Calculation';
            app.SarcomereLengthCalculationPanel.Position = [18 12 1567 390];

            % Create fft_axes
            app.fft_axes = uiaxes(app.SarcomereLengthCalculationPanel);
            title(app.fft_axes, 'FFT: Double-Sided Spectrum')
            xlabel(app.fft_axes, 'um^{-1}')
            ylabel(app.fft_axes, 'Amplitude (A.U.)')
            zlabel(app.fft_axes, 'Z')
            app.fft_axes.Box = 'on';
            app.fft_axes.Position = [27 23 380 323];

            % Create ac_axes
            app.ac_axes = uiaxes(app.SarcomereLengthCalculationPanel);
            title(app.ac_axes, 'ACF')
            xlabel(app.ac_axes, 'Pixels')
            ylabel(app.ac_axes, 'Amplitude (A.U.)')
            zlabel(app.ac_axes, 'Z')
            app.ac_axes.Box = 'on';
            app.ac_axes.Position = [441 23 380 323];

            % Create sl_row_axes
            app.sl_row_axes = uiaxes(app.SarcomereLengthCalculationPanel);
            title(app.sl_row_axes, 'Sarcomere Length Along ROI')
            xlabel(app.sl_row_axes, 'ROI Row')
            ylabel(app.sl_row_axes, 'Sarcomere Length (um)')
            app.sl_row_axes.Box = 'on';
            app.sl_row_axes.Position = [856 23 380 323];

            % Create UITable
            app.UITable = uitable(app.SarcomereLengthCalculationPanel);
            app.UITable.ColumnName = {'Box No'; 'FFT SL'; 'ACF SL'};
            app.UITable.RowName = {};
            app.UITable.Position = [1265 57 280 271];

            % Create ExportSLTableButton
            app.ExportSLTableButton = uibutton(app.SarcomereLengthCalculationPanel, 'push');
            app.ExportSLTableButton.ButtonPushedFcn = createCallbackFcn(app, @ExportSLTableButtonPushed, true);
            app.ExportSLTableButton.Position = [1356 23 100 22];
            app.ExportSLTableButton.Text = 'Export SL Table';

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.SLMeasureUIFigure, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.Position = [17 823 100 23];
            app.LoadImageButton.Text = 'Load Image';

            % Create NewBoxButton
            app.NewBoxButton = uibutton(app.SLMeasureUIFigure, 'push');
            app.NewBoxButton.ButtonPushedFcn = createCallbackFcn(app, @NewBoxButtonPushed, true);
            app.NewBoxButton.Position = [131 823 82 23];
            app.NewBoxButton.Text = 'New Box';

            % Create BoxSelectionDropDownLabel
            app.BoxSelectionDropDownLabel = uilabel(app.SLMeasureUIFigure);
            app.BoxSelectionDropDownLabel.HorizontalAlignment = 'right';
            app.BoxSelectionDropDownLabel.Position = [223 823 79 22];
            app.BoxSelectionDropDownLabel.Text = 'Box Selection';

            % Create BoxSelectionDropDown
            app.BoxSelectionDropDown = uidropdown(app.SLMeasureUIFigure);
            app.BoxSelectionDropDown.Items = {};
            app.BoxSelectionDropDown.ValueChangedFcn = createCallbackFcn(app, @BoxSelectionDropDownValueChanged, true);
            app.BoxSelectionDropDown.Placeholder = 'No Data';
            app.BoxSelectionDropDown.Position = [317 823 100 22];
            app.BoxSelectionDropDown.Value = {};

            % Create MicroscopeCalibrationumpxEditFieldLabel
            app.MicroscopeCalibrationumpxEditFieldLabel = uilabel(app.SLMeasureUIFigure);
            app.MicroscopeCalibrationumpxEditFieldLabel.HorizontalAlignment = 'right';
            app.MicroscopeCalibrationumpxEditFieldLabel.Position = [437 823 172 22];
            app.MicroscopeCalibrationumpxEditFieldLabel.Text = 'Microscope Calibration (um/px)';

            % Create MicroscopeCalibrationumpxEditField
            app.MicroscopeCalibrationumpxEditField = uieditfield(app.SLMeasureUIFigure, 'numeric');
            app.MicroscopeCalibrationumpxEditField.ValueDisplayFormat = '%.3f';
            app.MicroscopeCalibrationumpxEditField.ValueChangedFcn = createCallbackFcn(app, @MicroscopeCalibrationumpxEditFieldValueChanged, true);
            app.MicroscopeCalibrationumpxEditField.Position = [624 823 100 22];

            % Show the figure after all components are created
            app.SLMeasureUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SLMeasure_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.SLMeasureUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.SLMeasureUIFigure)
        end
    end
end