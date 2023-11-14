classdef SLMeasure_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SLMeasureUIFigure               matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        SaveMeasurementMenu             matlab.ui.container.Menu
        LoadMeasurementMenu             matlab.ui.container.Menu
        CameraPanel                     matlab.ui.container.Panel
        ResolutionPanel                 matlab.ui.container.Panel
        ResolutionDropDown              matlab.ui.control.DropDown
        ColorAdjustmentPanel            matlab.ui.container.Panel
        DefaultsButton                  matlab.ui.control.Button
        GammaEditField                  matlab.ui.control.NumericEditField
        GammaEditFieldLabel             matlab.ui.control.Label
        GammaSlider                     matlab.ui.control.Slider
        ContrastEditField               matlab.ui.control.NumericEditField
        ContrastEditFieldLabel          matlab.ui.control.Label
        ContrastSlider                  matlab.ui.control.Slider
        BrightnessEditField             matlab.ui.control.NumericEditField
        BrightnessEditFieldLabel        matlab.ui.control.Label
        BrightnessSlider                matlab.ui.control.Slider
        SaturationEditField             matlab.ui.control.NumericEditField
        SaturationEditFieldLabel        matlab.ui.control.Label
        SaturationSlider                matlab.ui.control.Slider
        HueSlider                       matlab.ui.control.Slider
        HueEditField                    matlab.ui.control.NumericEditField
        HueEditFieldLabel               matlab.ui.control.Label
        WhiteBalancePanel               matlab.ui.container.Panel
        WBDefaultsButton                matlab.ui.control.Button
        WhiteBalanceButton              matlab.ui.control.Button
        TintSlider                      matlab.ui.control.Slider
        TintEditField                   matlab.ui.control.NumericEditField
        TintEditFieldLabel              matlab.ui.control.Label
        ColorTempSlider                 matlab.ui.control.Slider
        ColorTemperatureEditField       matlab.ui.control.NumericEditField
        ColorTemperatureEditFieldLabel  matlab.ui.control.Label
        ExposurePanel                   matlab.ui.container.Panel
        ExposureSlider                  matlab.ui.control.Slider
        ExposureTimemsEditField         matlab.ui.control.NumericEditField
        ExposureTimemsEditFieldLabel    matlab.ui.control.Label
        AutoExposureCheckBox            matlab.ui.control.CheckBox
        SnapshotRecordPanel             matlab.ui.container.Panel
        SaveImageButton                 matlab.ui.control.Button
        DeviceList                      matlab.ui.control.ListBox
        DeviceListPanel                 matlab.ui.container.Panel
        LiveExperimentModeButton        matlab.ui.control.StateButton
        LiveMeasurementModeButton       matlab.ui.control.StateButton
        SarcomereLengthCalculationPanel  matlab.ui.container.Panel
        ExportSLTableButton             matlab.ui.control.Button
        UITable                         matlab.ui.control.Table
        exp_axis                        matlab.ui.control.UIAxes
        ac_axis                         matlab.ui.control.UIAxes
        fft_axis                        matlab.ui.control.UIAxes
        BrightfieldPanel                matlab.ui.container.Panel
        MicroscopeCalibrationDropDown   matlab.ui.control.DropDown
        MicroscopeCalibrationDropDownLabel  matlab.ui.control.Label
        BoxSelectionDropDown            matlab.ui.control.DropDown
        BoxSelectionDropDownLabel       matlab.ui.control.Label
        NewBoxButton                    matlab.ui.control.Button
        LoadImageButton                 matlab.ui.control.Button
        ROIRowSelectSpinner             matlab.ui.control.Spinner
        ROIRowSelectSpinnerLabel        matlab.ui.control.Label
        ROIWidthpxEditField             matlab.ui.control.NumericEditField
        ROIWidthpxEditFieldLabel        matlab.ui.control.Label
        ROIHeightpxEditField            matlab.ui.control.NumericEditField
        ROIHeightpxEditFieldLabel       matlab.ui.control.Label
        CalibrationFilePathEditField    matlab.ui.control.EditField
        CalibrationFilePathEditFieldLabel  matlab.ui.control.Label
        LoadMicroscopeCalibrationFileButton  matlab.ui.control.Button
        calculation_axis                matlab.ui.control.UIAxes
        px_intensity                    matlab.ui.control.UIAxes
        inset_axis                      matlab.ui.control.UIAxes
        image_axis                      matlab.ui.control.UIAxes
    end


    properties (Access = private)

    end

    properties (Access = public)
        image_file
        roi_pos
        roi_rec
        px_cal
        roi_box
        profile
        sig
        background
        sl_data
        P2
        lags
        X_acf
        wavelength
        y_fit
        r_squared
        mean_X_acf
        mean_P2
        live_image = []
        ToupcamData
        Devices
        live_measurement = 0;
        live_experiment = 0; 
        boxes 
        live_fig_handle 
        time 
    end

    methods (Access = private)

        function ClearDisplay(app)
            cla(app.image_axis)
            cla(app.inset_axis)
            cla(app.px_intensity)
            cla(app.calculation_axis)
            cla(app.fft_axis)
            cla(app.ac_axis)
            app.ROIHeightpxEditField.Value = 0;
            app.ROIWidthpxEditField.Value = 0;
        end

    end

    methods (Access = public)

        function SarcomereLength(app)
            cla(app.px_intensity);
            cla(app.inset_axis);
            cla(app.calculation_axis);
            cla(app.ac_axis);
            cla(app.fft_axis);
            app.profile = [];
            app.roi_box = [];

            box_no = str2num(app.BoxSelectionDropDown.Value);
            %             Box Resize if neccessary
            %             n = numel(app.sl_data.box_handle);
            %             for i=1:n
            %                 p(i,1:4) = app.sl_data.box_handle(i).Position;
            %             end
            %             w = p(box_no,3);
            %             h = p(box_no,4);
            %             if ((w~=app.sl_data.old_width)|(h~=app.sl_data.old_height))
            %                 for i=1:n
            %                     p(i,3) = w;
            %                     p(i,4) = h;
            %                     app.sl_data.box_handle(i).Position = p(i,:);
            %                 end
            %             end

            if app.live_measurement == 1 || ...
                    (app.live_measurement == 2 && ...
                    ~isfield(app.sl_data,'image_file_string'))
                app.sl_data.image_file = [];
                app.sl_data.image_file = app.live_image;
            end

            app.roi_box = imcrop(app.sl_data.image_file, ...
                app.sl_data.box_handle(box_no).Position);
            [app.live_fig_handle] = center_image_with_preserved_aspect_ratio( ...
                app.roi_box, ...
                app.inset_axis);


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
            app.r_squared = [];

            if (ndims(app.roi_box)==3)
                app.roi_box = rgb2gray(app.roi_box);
            end

            for ct = 1 : size(app.roi_box,1)
                app.profile(ct,:) = app.roi_box(ct,:);
                app.sig(ct,:)  = (diff(app.profile(ct,:)));
                SLFFT(app,ct);
                SLAutoCorr(app,ct);
            end

            app.mean_X_acf = mean(app.X_acf,1);
            app.mean_P2 = mean(app.P2,1);

            [lambda,fit_parameters,app.r_squared,app.y_fit] = fit_damped_sine_wave('y_data',app.mean_X_acf,...
                'x_data',app.lags(1,:), 'min_x_index_spacing',5);
            if app.sl_data.calibration.px_cal ~=0
                app.sl_data.sarcomere_length_acf(box_no) = lambda * app.sl_data.calibration.px_cal;
                app.wavelength = lambda;
            else
                app.sl_data.sarcomere_length_acf(box_no) = 0;
            end

            [peaks, locs] = findpeaks(app.mean_P2);
            [max_mag,max_ix] = max(peaks);
            F_p = 0:numel(app.mean_P2)-1;
            if app.sl_data.calibration.px_cal ~=0
                app.sl_data.sarcomere_length_fft(box_no) = ...
                    size(app.sig,2)*app.sl_data.calibration.px_cal/F_p(locs(max_ix));
            else
                app.sl_data.sarcomere_length_fft(box_no) = 0;
            end

            UpdateDisplay(app)
        end

        function SLAutoCorr(app,ct)
            x = app.sig(ct,:);
            [app.X_acf(ct,:),app.lags(ct,:)] = autocorr(x,NumLags=round(numel(x)/2));
            if ct == inf
                draw_graph = 1;
            else
                draw_graph = 0;
            end
        end

        function SLFFT(app,ct)
            x = app.sig(ct,:);
            X = fft(x);
            L = numel(X);
            app.P2(ct,:) = abs(X/L);
        end


        function UpdateTable(app)

            for i = 1:numel(app.sl_data.sarcomere_length_fft)
                s.box_no{i,1} = sprintf('%i',i);
                s.fft_sl(i,1) = app.sl_data.sarcomere_length_fft(i);
                s.acf_sl(i,1) = app.sl_data.sarcomere_length_acf(i);
            end

            s.box_no{end+1,1} = 'Average';
            s.fft_sl(end+1,1) = mean(app.sl_data.sarcomere_length_fft);
            s.acf_sl(end+1,1) = mean(app.sl_data.sarcomere_length_acf);

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
            hold(app.calculation_axis,"on")
            plot(app.calculation_axis, app.sig(row_no,:),'Color',cm(row_no,:),"LineWidth",2)
            xlim(app.px_intensity, [1 numel(app.profile(row_no,:))])
            xlim(app.calculation_axis, [1 numel(app.profile(row_no,:))])

            hold(app.fft_axis,"on")
            F_p = 0:numel(app.mean_P2)-1;
            [peaks, locs] = findpeaks(app.mean_P2);
            [max_mag,max_ix] = max(peaks);
            fft_ix = (1:numel(app.mean_P2)-1)/(numel(app.mean_P2));
            fft_ix = [0 fft_ix];
            plot(app.fft_axis,fft_ix,app.mean_P2,'Color','b','LineWidth',2)
            plot(app.fft_axis,fft_ix(locs(max_ix)),app.mean_P2(locs(max_ix)),'pentagram', ...
                'MarkerSize',15,"Color",'k','MarkerFaceColor','k')
            xlim(app.fft_axis,[0 fft_ix(end)])
            ylim(app.fft_axis,[0 max(max(app.mean_P2))+1])
            t = sprintf('Peak is at %.3f px^{-1}',fft_ix(locs(max_ix)));
            text(app.fft_axis,fft_ix(locs(max_ix))+0.25,max(peaks),t)

            plot(app.ac_axis,app.lags(1,:),app.mean_X_acf,'o','LineWidth',2,'color','r')
            hold(app.ac_axis,"on")
            plot(app.ac_axis,app.lags(1,:),app.y_fit,'color','k','LineWidth',1.5)
            if ~isempty(app.wavelength)
                t1 = sprintf('Wavelength  = %.3f px',app.wavelength);
                t2 = sprintf('R-squared = %.3f', app.r_squared);
                text(app.ac_axis,round(0.7*numel(app.mean_X_acf))-10,0.6,t1)
                text(app.ac_axis,round(0.7*numel(app.mean_X_acf))-10,0.8,t2)
            end
            %             xlim(app.ac_axis,[0 round(numel(x)/2)])
            ylim(app.ac_axis,[-1 1])

        end



        function LiveSarcomereLength(app,m)

            app.sl_data.image_file = app.live_image;


            for box_no = 1 : numel(app.sl_data.box_handle)
                app.roi_box = [];

                app.roi_box = imcrop(app.sl_data.image_file, ...
                    app.sl_data.box_handle(box_no).Position);

                app.profile = [];
                app.sig = [];
                sl_fft = [];
                sl_acf = [];
                app.P2 = [];
                app.X_acf = [];
                app.wavelength = [];
                app.lags = [];
                app.y_fit = [];
                app.r_squared = [];

                if (ndims(app.roi_box)==3)
                    app.roi_box = rgb2gray(app.roi_box);
                end

                for ct = 1 : size(app.roi_box,1)
                    app.profile(ct,:) = app.roi_box(ct,:);
                    app.sig(ct,:)  = (diff(app.profile(ct,:)));
                    SLFFT(app,ct);
                    %                 SLAutoCorr(app,ct);
                end

                app.mean_X_acf = mean(app.X_acf,1);
                app.mean_P2 = mean(app.P2,1);

                [lambda,fit_parameters,app.r_squared,app.y_fit] = fit_damped_sine_wave('y_data',app.mean_X_acf,...
                    'x_data',app.lags(1,:), 'min_x_index_spacing',5);
                if app.sl_data.calibration.px_cal ~=0
                    app.sl_data.live.sarcomere_length_acf(m,box_no) = lambda * app.sl_data.calibration.px_cal;
                    app.wavelength = lambda;
                else
                    app.sl_data.live.sarcomere_length_acf(m,box_no) = 0;
                end

                [peaks, locs] = findpeaks(app.mean_P2);
                [max_mag,max_ix] = max(peaks);
                F_p = 0:numel(app.mean_P2)-1;
                if app.sl_data.calibration.px_cal ~=0
                    app.sl_data.live.sarcomere_length_fft(m,box_no) = ...
                        size(app.sig,2)*app.sl_data.calibration.px_cal/F_p(locs(max_ix));
                else
                    app.sl_data.live.sarcomere_length_fft(m,box_no) = 0;
                end
                app.sl_data.live.sarcomere_length_fft(m,box_no) = 4 + rand(1,1);
                app.sl_data.live.sarcomere_length_acf(m,box_no) = 2 + rand(1,1);
            end
            cm = parula(box_no);
            hold(app.exp_axis,"on")
            for i = 1:box_no
                plot(app.exp_axis,1:m,app.sl_data.live.sarcomere_length_fft(1:m,i),'Color',cm(i,:),"Marker","pentagram",'LineWidth',2)
                plot(app.exp_axis,1:m,app.sl_data.live.sarcomere_length_acf(1:m,i),'Color',cm(i,:),"Marker","o",'LineWidth',2)
            end
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            colormap(app.SLMeasureUIFigure, 'gray');
            addpath(genpath('utilities'))
            movegui(app.SLMeasureUIFigure,'center')
            addpath(genpath('camera'))
            disableDefaultInteractivity(app.image_axis)

            ipath = ['-I' fullfile(cd,'camera')];
            f = fullfile(cd,'camera','mexToupcam.cpp');
            lib = fullfile(cd,'camera','toupcam.lib');
            %             mex mexToupcam.cpp -ltoupcam

            mex('-v','-R2017b',ipath,f,lib)

            global bStop;
            bStop = 0;
            [devN, devList] = mexToupcam;

            if devN == 0
                app.DeviceList.Items = {'No Device'};
            else
                app.Devices = devList;

                for i = 1 : numel(devList)

                    app.DeviceList.Items{i} = devList(i).name;

                end

                if numel(devList) == 1
                    app.DeviceList.Value = app.DeviceList.Items;
                end

            end

            app.ResolutionDropDown.Value;


        end

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, event)

            filterspec = {'*.tif;*.png','All Image Files'};
            [file_string,path_string] = uigetfile2(filterspec);
            if (path_string~=0)
                ClearDisplay(app)
                if isfield(app.sl_data,'calibration')
                    temp_cal = app.sl_data.calibration;
                else
                    temp_cal = [];
                end
                app.sl_data = [];
                if ~isempty(temp_cal)
                    app.sl_data.calibration = temp_cal;
                end
                app.UITable.Data = [];
                app.sl_data.image_file_string = fullfile(path_string,file_string);
                im = imread(app.sl_data.image_file_string);
                if (ndims(im)==3)
                    im = rgb2gray(im);
                end
                [fig_handle] = center_image_with_preserved_aspect_ratio( ...
                    im, ...
                    app.image_axis);
                app.sl_data.image_file = im;

            end
        end

        % Button pushed function: NewBoxButton
        function NewBoxButtonPushed(app, event)

            if (~isfield(app.sl_data,'box_handle'))
                n=1;
                app.sl_data.box_handle(n) = drawrectangle(app.image_axis);
                p = app.sl_data.box_handle(n).Position;
                app.sl_data.old_width = p(3);
                app.sl_data.old_height = p(4);
            else
                n = 1 + numel(app.sl_data.box_handle);
                p = app.sl_data.box_handle(n-1).Position;

                app.sl_data.box_handle(n) = images.roi.Rectangle(app.image_axis, ...
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

            app.sl_data.box_label(n) = text(app.image_axis, ...
                p(1)+p(3)+20,p(2)-30,sprintf('%.0f',n),'FontWeight',"bold","FontSize",18,"Color",'k');

            app.roi_pos = get(app.roi_rec, 'Position');
%             app.px_cal = app.MicroscopeCalibrationDropDown.Value;

            for i=1:n
                control_strings{i}=sprintf('%.0f',i);
            end

            app.BoxSelectionDropDown.Items = control_strings;
            app.BoxSelectionDropDown.Value = control_strings{n};

            SarcomereLength(app)
            %             app.boxes(n) = app.sl_data.box_handle(n);
            UpdateTable(app);
            addlistener(app.sl_data.box_handle(n),"MovingROI",@(src,evt) UpdateSL(evt));

            function UpdateSL(evt)
                box_no = str2num(app.BoxSelectionDropDown.Value);
                app.ROIHeightpxEditField.Value = app.sl_data.box_handle(box_no).Position(3);
                app.ROIWidthpxEditField.Value = app.sl_data.box_handle(box_no).Position(4);
                cla(app.px_intensity)
                cla(app.calculation_axis)
                cla(app.fft_axis)
                cla(app.ac_axis)
                SarcomereLength(app)
                UpdateTable(app);
            end

        end

        % Value changed function: MicroscopeCalibrationDropDown
        function MicroscopeCalibrationumpxEditFieldValueChanged(app, event)
            app.sl_data.calibration.cal_ix = find(strcmp(app.MicroscopeCalibrationDropDown.Value,app.MicroscopeCalibrationDropDown.Items));
            app.sl_data.calibration.px_cal = app.sl_data.calibration.table.Calibration(app.sl_data.calibration.cal_ix);
            cur_box = app.BoxSelectionDropDown.Value;
            if isfield(app.sl_data,'box_handle')
                for i = 1 : numel(app.sl_data.box_handle)
                    app.BoxSelectionDropDown.Value = num2str(i);
                    SarcomereLength(app)
                    UpdateTable(app)
                end
                app.BoxSelectionDropDown.Value = cur_box;
                app.BoxSelectionDropDownValueChanged;
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
            UpdateTable(app)
        end

        % Value changed function: ROIRowSelectSpinner
        function ROIRowSelectSpinnerValueChanged(app, event)
            value = app.ROIRowSelectSpinner.Value;
            cla(app.ac_axis)
            cla(app.fft_axis)
            cla(app.calculation_axis)
            cla(app.px_intensity)
            cla(app.ac_axis)
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
            if isfield(app.sl_data,'image_file_string')
            save_data.image_file_string = app.sl_data.image_file_string;
            end
            save_data.im_data = app.sl_data.image_file;
            save_data.box_position = app.sl_data.box_position;
            save_data.calibration = app.sl_data.calibration;

            if isfield(app.sl_data,'live')
                save_data.live.sarcomere_length_fft = app.sl_data.live.sarcomere_length_fft;
                save_data.live.sarcomere_length_acf = app.sl_data.live.sarcomere_length_acf;
            end
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
                if isfield(save_data,'image_file_string')
                app.sl_data.image_file_string = save_data.image_file_string;
                end
                app.sl_data.image_file = save_data.im_data;
                app.sl_data.calibration = save_data.calibration;

                for i = 1 : size(app.sl_data.calibration.table,1)
                    name = sprintf('Obj. %s: %.4f um/px',app.sl_data.calibration.table.Objective{i}, app.sl_data.calibration.table.Calibration(i));
                    app.MicroscopeCalibrationDropDown.Items{i} = name; 
                end
                
                app.CalibrationFilePathEditField.Value = app.sl_data.calibration.file_name;
                app.MicroscopeCalibrationDropDown.Value = app.MicroscopeCalibrationDropDown.Items{app.sl_data.calibration.cal_ix};
                
                [fig_handle] = center_image_with_preserved_aspect_ratio( ...
                    app.sl_data.image_file, ...
                    app.image_axis);
                control_strings = [];
                for i=1:size(save_data.box_position,1)
                    app.sl_data.box_handle(i) = images.roi.Rectangle(app.image_axis, ...
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
                        'Parent',app.image_axis,'FontWeight',"bold","FontSize",18,"Color",'k');
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

                if isfield(save_data,'live')
                    app.sl_data.live.sarcomere_length_fft = save_data.live.sarcomere_length_fft;
                    app.sl_data.live.sarcomere_length_acf = save_data.live.sarcomere_length_acf;
                    cm = parula(numel(app.sl_data.box_handle));
                    hold(app.exp_axis,"on")
                    for i = 1:numel(app.sl_data.box_handle)
                        m = numel(app.sl_data.live.sarcomere_length_fft(:,i));
                        plot(app.exp_axis,1:m,app.sl_data.live.sarcomere_length_fft(1:m,i),'Color',cm(i,:),"Marker","pentagram",'LineWidth',2)
                        plot(app.exp_axis,1:m,app.sl_data.live.sarcomere_length_acf(1:m,i),'Color',cm(i,:),"Marker","o",'LineWidth',2)
                    end
                end
            end
            function UpdateSL2(evt)
                box_no = str2num(app.BoxSelectionDropDown.Value);
                app.ROIHeightpxEditField.Value = app.sl_data.box_handle(box_no).Position(3);
                app.ROIWidthpxEditField.Value = app.sl_data.box_handle(box_no).Position(4);
                cla(app.px_intensity)
                cla(app.calculation_axis)
                cla(app.fft_axis)
                cla(app.ac_axis)
                SarcomereLength(app)
                UpdateTable(app);
            end

        end

        % Button pushed function: 
        % LoadMicroscopeCalibrationFileButton
        function LoadMicroscopeCalibrationFileButtonPushed(app, event)
            filterspec = {'*.xlsx;*.xls','All Excel Files'};
            [file_string,path_string] = uigetfile2(filterspec);
            if (path_string~=0)
                app.sl_data.calibration = [];
                app.sl_data.calibration.file_name = [];
                app.sl_data.calibration.file_name = fullfile(path_string,file_string);
                app.CalibrationFilePathEditField.Value = app.sl_data.calibration.file_name;
                app.sl_data.calibration.table = readtable(app.sl_data.calibration.file_name,'Sheet','Summary');
                for i = 1 : size(app.sl_data.calibration.table,1)
                    name = sprintf('Obj. %s: %.4f um/px',app.sl_data.calibration.table.Objective{i}, app.sl_data.calibration.table.Calibration(i));
                    app.MicroscopeCalibrationDropDown.Items{i} = name; 
                end
                app.sl_data.calibration.px_cal = app.sl_data.calibration.table.Calibration(1);
                app.sl_data.calibration.cal_ix = 1;
            end
        end

        % Callback function
        function RSquaredThresholdEditFieldValueChanged(app, event)
            value = app.RSquaredThresholdEditField.Value;
            cla(app.r_squared_axes);
            ct = app.ROIHeightpxEditField.Value;
            plot(app.r_squared_axes,1:ct,ones(1,ct)*app.RSquaredThresholdEditField.Value,':','Color','r')
            plot(app.r_squared_axes,1:ct,app.r_squared,'ks')


        end

        % Value changed function: LiveMeasurementModeButton
        function LiveMeasurementModeButtonValueChanged(app, event)

            global bStop
            value = app.LiveMeasurementModeButton.Value;

            if value

                app.live_measurement = 1;
                app.LoadImageButton.Enable = 'off';
                selected_device = app.DeviceList.Value;

                resolution = app.ResolutionDropDown.Value;

                switch resolution
                    case '1024 x 822'
                        nResolutionIndex = 1;
                        width = 1024;
                        height = 822;
                    case '2048 x 1644'
                        nResolutionIndex = 1;
                        width = 2048;
                        height = 1644;
                    case '4096 x 3288'
                        nResolutionIndex = 1;
                        width = 4096;
                        height = 3288;
                end

                bStop = 0;
                app.DeviceList.Enable = 'off';
                items = app.DeviceList.Items;
                index = strcmp(selected_device,items);
                nSpeed = 1;
                devList = app.Devices;
                [im, ~, ~, app.ToupcamData] = mexToupcam(nResolutionIndex, nSpeed, devList(index).id, index);
                app.ExposureSlider.Enable = 'off';
                app.ExposureTimemsEditField.Enable = 'off';
                app.ExposureTimemsEditFieldLabel.Enable = 'off';

                app.ColorTempSlider.Enable = 'on';
                app.ColorTempSlider.Value = app.ToupcamData.TOUPCAM_TEMP_DEF;
                app.ColorTemperatureEditFieldLabel.Enable = 'on';
                app.ColorTemperatureEditField.Enable = 'on';
                app.ColorTemperatureEditField.Value = app.ToupcamData.TOUPCAM_TEMP_DEF;

                app.TintSlider.Enable = 'on';
                app.TintSlider.Value = app.ToupcamData.TOUPCAM_TINT_DEF;
                app.TintEditFieldLabel.Enable = 'on';
                app.TintEditField.Enable = 'on';
                app.TintEditField.Value = app.ToupcamData.TOUPCAM_TINT_DEF;

                app.WhiteBalanceButton.Enable = 'on';
                app.WBDefaultsButton.Enable = 'on';

                app.HueSlider.Enable = 'on';
                app.HueSlider.Value = app.ToupcamData.TOUPCAM_HUE_DEF;
                app.HueEditField.Enable = 'on';
                app.HueEditFieldLabel.Enable = 'on';
                app.HueEditField.Value = app.ToupcamData.TOUPCAM_HUE_DEF;

                app.SaturationSlider.Enable = 'on';
                app.SaturationSlider.Value = app.ToupcamData.TOUPCAM_SATURATION_DEF;
                app.SaturationEditField.Enable = 'on';
                app.SaturationEditFieldLabel.Enable = 'on';
                app.SaturationEditField.Value = app.ToupcamData.TOUPCAM_SATURATION_DEF;

                app.BrightnessSlider.Enable = 'on';
                app.BrightnessSlider.Value = app.ToupcamData.TOUPCAM_BRIGHTNESS_DEF;
                app.BrightnessEditField.Enable = 'on';
                app.BrightnessEditFieldLabel.Enable = 'on';
                app.BrightnessEditField.Value = app.ToupcamData.TOUPCAM_BRIGHTNESS_DEF;

                app.ContrastSlider.Enable = 'on';
                app.ContrastSlider.Value = app.ToupcamData.TOUPCAM_CONTRAST_DEF;
                app.ContrastEditField.Enable = 'on';
                app.ContrastEditFieldLabel.Enable = 'on';
                app.ContrastEditField.Value = app.ToupcamData.TOUPCAM_CONTRAST_DEF;

                app.GammaSlider.Enable = 'on';
                app.ContrastSlider.Value = app.ToupcamData.TOUPCAM_GAMMA_DEF;
                app.GammaEditField.Enable = 'on';
                app.GammaEditFieldLabel.Enable = 'on';
                app.GammaEditField.Value = app.ToupcamData.TOUPCAM_GAMMA_DEF;

                app.DefaultsButton.Enable = 'on';

                app.live_image = zeros(height,width, 3);
                m = 1;
                while ~isequal(bStop,2)
                    for i = 1 : height
                        for j = 1 :width
                            app.live_image(i,j,1) = im(3*(j-1)+3,i);
                            app.live_image(i,j,2) = im(3*(j-1)+2,i);
                            app.live_image(i,j,3) = im(3*(j-1)+1,i);
                        end
                    end
                    app.live_image = uint8(app.live_image);
                    if m == 1
                        [app.live_fig_handle] = center_image_with_preserved_aspect_ratio( ...
                            app.live_image, ...
                            app.image_axis);
                    else
                        app.live_fig_handle.CData = app.live_image;
                    end

                    if (isfield(app.sl_data,'box_handle'))
                        cla(app.px_intensity)
                        cla(app.calculation_axis)
                        cla(app.fft_axis)
                        cla(app.ac_axis)
                        SarcomereLength(app)
                    end
                    drawnow;
                    if bStop==1
                        uiwait;
                    end
                    m = m +1;
                end
            else
                bStop = 2;
                app.live_measurement = 2;
                mexToupcam(0,0);
                app.boxes = app.sl_data.box_handle;
                clear im;
                app.LoadImageButton.Enable = 'on';
                app.DeviceList.Enable = 'on';
            end
        end

        % Value changed function: LiveExperimentModeButton
        function LiveExperimentModeButtonValueChanged(app, event)
            value = app.LiveExperimentModeButton.Value;
            global bStop

            if value

                app.live_experiment = 1;
                app.LoadImageButton.Enable = 'off';
                selected_device = app.DeviceList.Value;

                resolution = app.ResolutionDropDown.Value;

                switch resolution
                    case '1024 x 822'
                        nResolutionIndex = 1;
                        width = 1024;
                        height = 822;
                    case '2048 x 1644'
                        nResolutionIndex = 1;
                        width = 2048;
                        height = 1644;
                    case '4096 x 3288'
                        nResolutionIndex = 1;
                        width = 4096;
                        height = 3288;
                end

                bStop = 0;
                app.DeviceList.Enable = 'off';
                items = app.DeviceList.Items;
                index = strcmp(selected_device,items);
                nSpeed = 1;
                devList = app.Devices;
                [im, ~, ~, app.ToupcamData] = mexToupcam(nResolutionIndex, nSpeed, devList(index).id, index);
                app.ExposureSlider.Enable = 'off';
                app.ExposureTimemsEditField.Enable = 'off';
                app.ExposureTimemsEditFieldLabel.Enable = 'off';

                app.ColorTempSlider.Enable = 'on';
                app.ColorTempSlider.Value = app.ToupcamData.TOUPCAM_TEMP_DEF;
                app.ColorTemperatureEditFieldLabel.Enable = 'on';
                app.ColorTemperatureEditField.Enable = 'on';
                app.ColorTemperatureEditField.Value = app.ToupcamData.TOUPCAM_TEMP_DEF;

                app.TintSlider.Enable = 'on';
                app.TintSlider.Value = app.ToupcamData.TOUPCAM_TINT_DEF;
                app.TintEditFieldLabel.Enable = 'on';
                app.TintEditField.Enable = 'on';
                app.TintEditField.Value = app.ToupcamData.TOUPCAM_TINT_DEF;

                app.WhiteBalanceButton.Enable = 'on';
                app.WBDefaultsButton.Enable = 'on';

                app.HueSlider.Enable = 'on';
                app.HueSlider.Value = app.ToupcamData.TOUPCAM_HUE_DEF;
                app.HueEditField.Enable = 'on';
                app.HueEditFieldLabel.Enable = 'on';
                app.HueEditField.Value = app.ToupcamData.TOUPCAM_HUE_DEF;

                app.SaturationSlider.Enable = 'on';
                app.SaturationSlider.Value = app.ToupcamData.TOUPCAM_SATURATION_DEF;
                app.SaturationEditField.Enable = 'on';
                app.SaturationEditFieldLabel.Enable = 'on';
                app.SaturationEditField.Value = app.ToupcamData.TOUPCAM_SATURATION_DEF;

                app.BrightnessSlider.Enable = 'on';
                app.BrightnessSlider.Value = app.ToupcamData.TOUPCAM_BRIGHTNESS_DEF;
                app.BrightnessEditField.Enable = 'on';
                app.BrightnessEditFieldLabel.Enable = 'on';
                app.BrightnessEditField.Value = app.ToupcamData.TOUPCAM_BRIGHTNESS_DEF;

                app.ContrastSlider.Enable = 'on';
                app.ContrastSlider.Value = app.ToupcamData.TOUPCAM_CONTRAST_DEF;
                app.ContrastEditField.Enable = 'on';
                app.ContrastEditFieldLabel.Enable = 'on';
                app.ContrastEditField.Value = app.ToupcamData.TOUPCAM_CONTRAST_DEF;

                app.GammaSlider.Enable = 'on';
                app.ContrastSlider.Value = app.ToupcamData.TOUPCAM_GAMMA_DEF;
                app.GammaEditField.Enable = 'on';
                app.GammaEditFieldLabel.Enable = 'on';
                app.GammaEditField.Value = app.ToupcamData.TOUPCAM_GAMMA_DEF;

                app.DefaultsButton.Enable = 'on';

                app.live_image = zeros(height,width, 3);
                m = 1;
                while ~isequal(bStop,2)
                    for i = 1 : height
                        for j = 1 :width
                            app.live_image(i,j,1) = im(3*(j-1)+3,i);
                            app.live_image(i,j,2) = im(3*(j-1)+2,i);
                            app.live_image(i,j,3) = im(3*(j-1)+1,i);
                        end
                    end
                    app.time(m) = datetime;
                    app.live_image = uint8(app.live_image);
                    app.live_fig_handle.CData = app.live_image;

                    if (isfield(app.sl_data,'box_handle'))
                        LiveSarcomereLength(app,m)
                    end
                    drawnow;
                    if bStop==1
                        uiwait;
                    end
                    m = m +1;
                end
            else
                bStop = 2;
                app.live_measurement = 2;
                mexToupcam(0,0);
                clear im;
                app.LoadImageButton.Enable = 'on';
                app.DeviceList.Enable = 'on';
            end
        end

        % Close request function: SLMeasureUIFigure
        function SLMeasureUIFigureCloseRequest(app, event)
            %             mexToupcam(0,0);
            %             clear im;
            global bStop;
            bStop = 2;
            delete(app)
        end

        % Button pushed function: SaveImageButton
        function SaveImageButtonPushed(app, event)
            [file_string,path_string] = uiputfile2( ...
                {'*.png','PNG'},'Select file name for the image');

            if (path_string~=0)
                output_file = fullfile(path_string,file_string);
                if isempty(app.image_file)
                    imwrite(app.live_image,output_file);
                else
                    imwrite(app.image_file,output_file);
                end
            end
        end

        % Value changed function: AutoExposureCheckBox
        function AutoExposureCheckBoxValueChanged(app, event)
            value = app.AutoExposureCheckBox.Value;
            global bStop;
            bStop = 1;
            [a,time] = mexToupcam(2,0);
            time=roundn(time/1000,-2);
            if a == 0 && value == 0
                app.ExposureSlider.Enable = 'on';
                app.ExposureTimemsEditFieldLabel.Enable = 'on';
                app.ExposureTimemsEditField.Enable = 'on';
                app.ExposureSlider.Value = time;
                app.ExposureTimemsEditField.Value = time;
            else
                app.ExposureSlider.Enable = 'off';
                app.ExposureTimemsEditFieldLabel.Enable = 'off';
                app.ExposureTimemsEditField.Enable = 'off';
            end
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Value changed function: ExposureSlider
        function ExposureSliderValueChanged(app, event)
            value = app.ExposureSlider.Value;
            global bStop;
            bStop = 1;
            app.ExposureTimemsEditField.Enable = 'on';
            app.ExposureTimemsEditFieldLabel.Enable = 'on';
            app.ExposureTimemsEditField.Value = roundn(value,-2);
            mexToupcam(3,value*1000);
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Value changed function: ColorTempSlider
        function ColorTempSliderValueChanged(app, event)
            value = app.ColorTempSlider.Value;
            global bStop;
            bStop = 1;
            app.ColorTemperatureEditField.Value = value;
            mexToupcam(5,value)
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Value changed function: TintSlider
        function TintSliderValueChanged(app, event)
            value = app.TintSlider.Value;
            global bStop;
            bStop = 1;
            app.TintEditField.Value = value;
            mexToupcam(6,value)
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Button pushed function: WhiteBalanceButton
        function WhiteBalanceButtonPushed(app, event)
            global bStop;
            bStop = 1;
            [temp, tint] = mexToupcam(4,0);
            app.ColorTemperatureEditField.Value = temp;
            app.ColorTempSlider.Value = temp;
            app.TintEditField.Value = tint;
            app.TintSlider.Value = tint;
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Button pushed function: WBDefaultsButton
        function WBDefaultsButtonPushed(app, event)
            global bStop;
            bStop = 1;
            mexToupcam(12,0);
            app.ColorTemperatureEditField.Value = app.ToupcamData.TOUPCAM_TEMP_DEF;
            app.ColorTempSlider.Value = app.ToupcamData.TOUPCAM_TEMP_DEF;
            app.TintEditField.Value = app.ToupcamData.TOUPCAM_TINT_DEF;
            app.TintSlider.Value = app.ToupcamData.TOUPCAM_TINT_DEF;
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Value changed function: HueSlider
        function HueSliderValueChanged(app, event)
            value = app.HueSlider.Value;
            global bStop;
            bStop = 1;
            app.HueEditField.Value = value;
            mexToupcam(7,value);
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Value changed function: SaturationSlider
        function SaturationSliderValueChanged(app, event)
            value = app.SaturationSlider.Value;
            global bStop;
            bStop = 1;
            app.SaturationEditField.Value = value;
            mexToupcam(8,val);
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Value changed function: BrightnessSlider
        function BrightnessSliderValueChanged(app, event)
            value = app.BrightnessSlider.Value;
            global bStop;
            bStop = 1;
            app.BrightnessEditField.Value = value;
            mexToupcam(9,val);
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Value changed function: ContrastSlider
        function ContrastSliderValueChanged(app, event)
            value = app.ContrastSlider.Value;
            global bStop;
            bStop = 1;
            app.ContrastEditField.Value = value;
            mexToupcam(10,val);
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Value changed function: GammaSlider
        function GammaSliderValueChanged(app, event)
            value = app.GammaSlider.Value;
            global bStop;
            bStop = 1;
            app.GammaEditField.Value = value;
            mexToupcam(11,val);
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end

        % Button pushed function: DefaultsButton
        function DefaultsButtonPushed(app, event)
            global bStop;
            bStop = 1;
            mexToupcam(13,0);
            app.HueEditField.Value = app.ToupcamData.TOUPCAM_HUE_DEF;
            app.HueSlider.Value = app.ToupcamData.TOUPCAM_HUE_DEF;
            app.SaturationEditField.Value = app.ToupcamData.TOUPCAM_SATURATION_DEF;
            app.SaturationSlider.Value = app.ToupcamData.TOUPCAM_SATURATION_DEF;
            app.BrightnessEditField.Value = app.ToupcamData.TOUPCAM_BRIGHTNESS_DEF;
            app.BrightnessSlider.Value = app.ToupcamData.TOUPCAM_BRIGHTNESS_DEF;
            app.ContrastEditField.Value = app.ToupcamData.TOUPCAM_CONTRAST_DEF;
            app.ContrastSlider.Value = app.ToupcamData.TOUPCAM_CONTRAST_DEF;
            app.GammaEditField.Value = app.ToupcamData.TOUPCAM_GAMMA_DEF;
            app.GammaSlider.Value = app.ToupcamData.TOUPCAM_GAMMA_DEF;
            bStop = 0;
            uiresume(app.SLMeasureUIFigure);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SLMeasureUIFigure and hide until all components are created
            app.SLMeasureUIFigure = uifigure('Visible', 'off');
            app.SLMeasureUIFigure.Position = [100 100 1797 922];
            app.SLMeasureUIFigure.Name = 'SLMeasure';
            app.SLMeasureUIFigure.CloseRequestFcn = createCallbackFcn(app, @SLMeasureUIFigureCloseRequest, true);

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
            app.BrightfieldPanel.Position = [219 425 1567 492];

            % Create image_axis
            app.image_axis = uiaxes(app.BrightfieldPanel);
            title(app.image_axis, 'Brightfield Image')
            app.image_axis.XTick = [];
            app.image_axis.YTick = [];
            app.image_axis.Box = 'on';
            app.image_axis.Position = [15 41 539 313];

            % Create inset_axis
            app.inset_axis = uiaxes(app.BrightfieldPanel);
            title(app.inset_axis, 'Region of Interest (ROI)')
            app.inset_axis.XTick = [];
            app.inset_axis.YTick = [];
            app.inset_axis.Box = 'on';
            app.inset_axis.Position = [559 175 325 179];

            % Create px_intensity
            app.px_intensity = uiaxes(app.BrightfieldPanel);
            title(app.px_intensity, 'Intensity Profiles')
            xlabel(app.px_intensity, 'ROI Column')
            ylabel(app.px_intensity, 'Optical Intensity (A.U)')
            zlabel(app.px_intensity, 'Z')
            app.px_intensity.Box = 'on';
            app.px_intensity.Position = [889 41 325 313];

            % Create calculation_axis
            app.calculation_axis = uiaxes(app.BrightfieldPanel);
            title(app.calculation_axis, 'Derivative of the Intensity Profile')
            xlabel(app.calculation_axis, 'ROI Index')
            ylabel(app.calculation_axis, 'd(profile)/dx')
            zlabel(app.calculation_axis, 'Z')
            app.calculation_axis.Box = 'on';
            app.calculation_axis.Position = [1227 41 325 313];

            % Create LoadMicroscopeCalibrationFileButton
            app.LoadMicroscopeCalibrationFileButton = uibutton(app.BrightfieldPanel, 'push');
            app.LoadMicroscopeCalibrationFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadMicroscopeCalibrationFileButtonPushed, true);
            app.LoadMicroscopeCalibrationFileButton.Position = [35 431 191 22];
            app.LoadMicroscopeCalibrationFileButton.Text = 'Load Microscope Calibration File';

            % Create CalibrationFilePathEditFieldLabel
            app.CalibrationFilePathEditFieldLabel = uilabel(app.BrightfieldPanel);
            app.CalibrationFilePathEditFieldLabel.HorizontalAlignment = 'right';
            app.CalibrationFilePathEditFieldLabel.Position = [236 431 114 22];
            app.CalibrationFilePathEditFieldLabel.Text = 'Calibration File Path';

            % Create CalibrationFilePathEditField
            app.CalibrationFilePathEditField = uieditfield(app.BrightfieldPanel, 'text');
            app.CalibrationFilePathEditField.Editable = 'off';
            app.CalibrationFilePathEditField.Position = [365 431 555 22];

            % Create ROIHeightpxEditFieldLabel
            app.ROIHeightpxEditFieldLabel = uilabel(app.BrightfieldPanel);
            app.ROIHeightpxEditFieldLabel.Position = [625 141 89 22];
            app.ROIHeightpxEditFieldLabel.Text = 'ROI Height (px)';

            % Create ROIHeightpxEditField
            app.ROIHeightpxEditField = uieditfield(app.BrightfieldPanel, 'numeric');
            app.ROIHeightpxEditField.Position = [720 141 100 22];

            % Create ROIWidthpxEditFieldLabel
            app.ROIWidthpxEditFieldLabel = uilabel(app.BrightfieldPanel);
            app.ROIWidthpxEditFieldLabel.Position = [625 101 85 22];
            app.ROIWidthpxEditFieldLabel.Text = 'ROI Width (px)';

            % Create ROIWidthpxEditField
            app.ROIWidthpxEditField = uieditfield(app.BrightfieldPanel, 'numeric');
            app.ROIWidthpxEditField.Position = [720 101 100 22];

            % Create ROIRowSelectSpinnerLabel
            app.ROIRowSelectSpinnerLabel = uilabel(app.BrightfieldPanel);
            app.ROIRowSelectSpinnerLabel.HorizontalAlignment = 'right';
            app.ROIRowSelectSpinnerLabel.Position = [619 63 91 22];
            app.ROIRowSelectSpinnerLabel.Text = 'ROI Row Select';

            % Create ROIRowSelectSpinner
            app.ROIRowSelectSpinner = uispinner(app.BrightfieldPanel);
            app.ROIRowSelectSpinner.ValueChangedFcn = createCallbackFcn(app, @ROIRowSelectSpinnerValueChanged, true);
            app.ROIRowSelectSpinner.Position = [725 59 100 26];
            app.ROIRowSelectSpinner.Value = 1;

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.BrightfieldPanel, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.Position = [35 383 100 23];
            app.LoadImageButton.Text = 'Load Image';

            % Create NewBoxButton
            app.NewBoxButton = uibutton(app.BrightfieldPanel, 'push');
            app.NewBoxButton.ButtonPushedFcn = createCallbackFcn(app, @NewBoxButtonPushed, true);
            app.NewBoxButton.Position = [149 383 82 23];
            app.NewBoxButton.Text = 'New Box';

            % Create BoxSelectionDropDownLabel
            app.BoxSelectionDropDownLabel = uilabel(app.BrightfieldPanel);
            app.BoxSelectionDropDownLabel.HorizontalAlignment = 'right';
            app.BoxSelectionDropDownLabel.Position = [241 383 79 22];
            app.BoxSelectionDropDownLabel.Text = 'Box Selection';

            % Create BoxSelectionDropDown
            app.BoxSelectionDropDown = uidropdown(app.BrightfieldPanel);
            app.BoxSelectionDropDown.Items = {};
            app.BoxSelectionDropDown.ValueChangedFcn = createCallbackFcn(app, @BoxSelectionDropDownValueChanged, true);
            app.BoxSelectionDropDown.Placeholder = 'No Data';
            app.BoxSelectionDropDown.Position = [335 383 100 22];
            app.BoxSelectionDropDown.Value = {};

            % Create MicroscopeCalibrationDropDownLabel
            app.MicroscopeCalibrationDropDownLabel = uilabel(app.BrightfieldPanel);
            app.MicroscopeCalibrationDropDownLabel.HorizontalAlignment = 'right';
            app.MicroscopeCalibrationDropDownLabel.Position = [450 383 128 22];
            app.MicroscopeCalibrationDropDownLabel.Text = 'Microscope Calibration';

            % Create MicroscopeCalibrationDropDown
            app.MicroscopeCalibrationDropDown = uidropdown(app.BrightfieldPanel);
            app.MicroscopeCalibrationDropDown.Items = {};
            app.MicroscopeCalibrationDropDown.ValueChangedFcn = createCallbackFcn(app, @MicroscopeCalibrationumpxEditFieldValueChanged, true);
            app.MicroscopeCalibrationDropDown.Placeholder = 'Load Calibration File';
            app.MicroscopeCalibrationDropDown.Position = [593 383 168 22];
            app.MicroscopeCalibrationDropDown.Value = {};

            % Create SarcomereLengthCalculationPanel
            app.SarcomereLengthCalculationPanel = uipanel(app.SLMeasureUIFigure);
            app.SarcomereLengthCalculationPanel.Title = 'Sarcomere Length Calculation';
            app.SarcomereLengthCalculationPanel.Position = [219 13 1567 390];

            % Create fft_axis
            app.fft_axis = uiaxes(app.SarcomereLengthCalculationPanel);
            title(app.fft_axis, 'FFT: Double-Sided Spectrum')
            xlabel(app.fft_axis, 'Pixels^{-1}')
            ylabel(app.fft_axis, 'Amplitude (A.U.)')
            zlabel(app.fft_axis, 'Z')
            app.fft_axis.Box = 'on';
            app.fft_axis.Position = [14 23 385 313];

            % Create ac_axis
            app.ac_axis = uiaxes(app.SarcomereLengthCalculationPanel);
            title(app.ac_axis, 'ACF')
            xlabel(app.ac_axis, 'Pixels')
            ylabel(app.ac_axis, 'Amplitude (A.U.)')
            zlabel(app.ac_axis, 'Z')
            app.ac_axis.Box = 'on';
            app.ac_axis.Position = [424 23 385 313];

            % Create exp_axis
            app.exp_axis = uiaxes(app.SarcomereLengthCalculationPanel);
            title(app.exp_axis, 'Experiment')
            xlabel(app.exp_axis, 'Frame')
            ylabel(app.exp_axis, 'Sarcomere length (um)')
            zlabel(app.exp_axis, 'Z')
            app.exp_axis.Box = 'on';
            app.exp_axis.Position = [1166 24 385 313];

            % Create UITable
            app.UITable = uitable(app.SarcomereLengthCalculationPanel);
            app.UITable.ColumnName = {'Box No'; 'FFT SL'; 'ACF SL'};
            app.UITable.RowName = {};
            app.UITable.Position = [848 54 280 271];

            % Create ExportSLTableButton
            app.ExportSLTableButton = uibutton(app.SarcomereLengthCalculationPanel, 'push');
            app.ExportSLTableButton.ButtonPushedFcn = createCallbackFcn(app, @ExportSLTableButtonPushed, true);
            app.ExportSLTableButton.Position = [939 20 100 22];
            app.ExportSLTableButton.Text = 'Export SL Table';

            % Create CameraPanel
            app.CameraPanel = uipanel(app.SLMeasureUIFigure);
            app.CameraPanel.Title = 'Camera Panel';
            app.CameraPanel.Position = [10 13 199 904];

            % Create DeviceListPanel
            app.DeviceListPanel = uipanel(app.CameraPanel);
            app.DeviceListPanel.Title = 'Choose Device';
            app.DeviceListPanel.Tag = 'uipanel_device';
            app.DeviceListPanel.FontSize = 13.3333333333333;
            app.DeviceListPanel.Position = [11 730 178 146];

            % Create LiveMeasurementModeButton
            app.LiveMeasurementModeButton = uibutton(app.DeviceListPanel, 'state');
            app.LiveMeasurementModeButton.ValueChangedFcn = createCallbackFcn(app, @LiveMeasurementModeButtonValueChanged, true);
            app.LiveMeasurementModeButton.Text = 'Live Measurement Mode';
            app.LiveMeasurementModeButton.Position = [16 35 148 22];

            % Create LiveExperimentModeButton
            app.LiveExperimentModeButton = uibutton(app.DeviceListPanel, 'state');
            app.LiveExperimentModeButton.ValueChangedFcn = createCallbackFcn(app, @LiveExperimentModeButtonValueChanged, true);
            app.LiveExperimentModeButton.Text = 'Live Experiment Mode';
            app.LiveExperimentModeButton.Position = [16 6 148 22];

            % Create DeviceList
            app.DeviceList = uilistbox(app.CameraPanel);
            app.DeviceList.Items = {};
            app.DeviceList.Tag = 'listbox_device';
            app.DeviceList.FontSize = 11;
            app.DeviceList.Position = [20 795 160 51];
            app.DeviceList.Value = {};

            % Create SnapshotRecordPanel
            app.SnapshotRecordPanel = uipanel(app.CameraPanel);
            app.SnapshotRecordPanel.Title = 'Snapshot';
            app.SnapshotRecordPanel.Tag = 'uipanel_device';
            app.SnapshotRecordPanel.FontSize = 13.3333333333333;
            app.SnapshotRecordPanel.Position = [11 604 178 58];

            % Create SaveImageButton
            app.SaveImageButton = uibutton(app.SnapshotRecordPanel, 'push');
            app.SaveImageButton.ButtonPushedFcn = createCallbackFcn(app, @SaveImageButtonPushed, true);
            app.SaveImageButton.Position = [39 7 100 22];
            app.SaveImageButton.Text = 'Save Image';

            % Create ExposurePanel
            app.ExposurePanel = uipanel(app.CameraPanel);
            app.ExposurePanel.Title = 'Exposure';
            app.ExposurePanel.Tag = 'uipanel_device';
            app.ExposurePanel.FontSize = 13.3333333333333;
            app.ExposurePanel.Position = [11 489 178 110];

            % Create AutoExposureCheckBox
            app.AutoExposureCheckBox = uicheckbox(app.ExposurePanel);
            app.AutoExposureCheckBox.ValueChangedFcn = createCallbackFcn(app, @AutoExposureCheckBoxValueChanged, true);
            app.AutoExposureCheckBox.Text = 'Auto Exposure';
            app.AutoExposureCheckBox.Position = [9 64 101 22];
            app.AutoExposureCheckBox.Value = true;

            % Create ExposureTimemsEditFieldLabel
            app.ExposureTimemsEditFieldLabel = uilabel(app.ExposurePanel);
            app.ExposureTimemsEditFieldLabel.HorizontalAlignment = 'right';
            app.ExposureTimemsEditFieldLabel.Enable = 'off';
            app.ExposureTimemsEditFieldLabel.Position = [6 38 113 22];
            app.ExposureTimemsEditFieldLabel.Text = 'Exposure Time (ms)';

            % Create ExposureTimemsEditField
            app.ExposureTimemsEditField = uieditfield(app.ExposurePanel, 'numeric');
            app.ExposureTimemsEditField.Editable = 'off';
            app.ExposureTimemsEditField.Enable = 'off';
            app.ExposureTimemsEditField.Position = [132 38 41 22];

            % Create ExposureSlider
            app.ExposureSlider = uislider(app.ExposurePanel);
            app.ExposureSlider.Limits = [0.244 2000];
            app.ExposureSlider.MajorTicks = [];
            app.ExposureSlider.MajorTickLabels = {''};
            app.ExposureSlider.ValueChangedFcn = createCallbackFcn(app, @ExposureSliderValueChanged, true);
            app.ExposureSlider.MinorTicks = [];
            app.ExposureSlider.Enable = 'off';
            app.ExposureSlider.Position = [16 18 148 3];
            app.ExposureSlider.Value = 0.244;

            % Create WhiteBalancePanel
            app.WhiteBalancePanel = uipanel(app.CameraPanel);
            app.WhiteBalancePanel.Title = 'White Balance';
            app.WhiteBalancePanel.Tag = 'uipanel_device';
            app.WhiteBalancePanel.FontSize = 13.3333333333333;
            app.WhiteBalancePanel.Position = [12 291 178 193];

            % Create ColorTemperatureEditFieldLabel
            app.ColorTemperatureEditFieldLabel = uilabel(app.WhiteBalancePanel);
            app.ColorTemperatureEditFieldLabel.HorizontalAlignment = 'right';
            app.ColorTemperatureEditFieldLabel.Enable = 'off';
            app.ColorTemperatureEditFieldLabel.Position = [5 142 105 22];
            app.ColorTemperatureEditFieldLabel.Text = 'Color Temperature';

            % Create ColorTemperatureEditField
            app.ColorTemperatureEditField = uieditfield(app.WhiteBalancePanel, 'numeric');
            app.ColorTemperatureEditField.Editable = 'off';
            app.ColorTemperatureEditField.Enable = 'off';
            app.ColorTemperatureEditField.Position = [117 142 58 22];

            % Create ColorTempSlider
            app.ColorTempSlider = uislider(app.WhiteBalancePanel);
            app.ColorTempSlider.Limits = [2000 15000];
            app.ColorTempSlider.MajorTicks = [];
            app.ColorTempSlider.MajorTickLabels = {''};
            app.ColorTempSlider.ValueChangedFcn = createCallbackFcn(app, @ColorTempSliderValueChanged, true);
            app.ColorTempSlider.MinorTicks = [];
            app.ColorTempSlider.Enable = 'off';
            app.ColorTempSlider.Position = [15 124 148 3];
            app.ColorTempSlider.Value = 6503;

            % Create TintEditFieldLabel
            app.TintEditFieldLabel = uilabel(app.WhiteBalancePanel);
            app.TintEditFieldLabel.HorizontalAlignment = 'right';
            app.TintEditFieldLabel.Enable = 'off';
            app.TintEditFieldLabel.Position = [8 91 25 22];
            app.TintEditFieldLabel.Text = 'Tint';

            % Create TintEditField
            app.TintEditField = uieditfield(app.WhiteBalancePanel, 'numeric');
            app.TintEditField.Editable = 'off';
            app.TintEditField.Enable = 'off';
            app.TintEditField.Position = [117 91 58 22];

            % Create TintSlider
            app.TintSlider = uislider(app.WhiteBalancePanel);
            app.TintSlider.Limits = [200 2500];
            app.TintSlider.MajorTicks = [];
            app.TintSlider.MajorTickLabels = {''};
            app.TintSlider.ValueChangedFcn = createCallbackFcn(app, @TintSliderValueChanged, true);
            app.TintSlider.MinorTicks = [];
            app.TintSlider.Enable = 'off';
            app.TintSlider.Position = [15 74 148 3];
            app.TintSlider.Value = 1000;

            % Create WhiteBalanceButton
            app.WhiteBalanceButton = uibutton(app.WhiteBalancePanel, 'push');
            app.WhiteBalanceButton.ButtonPushedFcn = createCallbackFcn(app, @WhiteBalanceButtonPushed, true);
            app.WhiteBalanceButton.Enable = 'off';
            app.WhiteBalanceButton.Position = [38 38 100 22];
            app.WhiteBalanceButton.Text = 'White Balance';

            % Create WBDefaultsButton
            app.WBDefaultsButton = uibutton(app.WhiteBalancePanel, 'push');
            app.WBDefaultsButton.ButtonPushedFcn = createCallbackFcn(app, @WBDefaultsButtonPushed, true);
            app.WBDefaultsButton.Enable = 'off';
            app.WBDefaultsButton.Position = [38 9 100 22];
            app.WBDefaultsButton.Text = 'Defaults';

            % Create ColorAdjustmentPanel
            app.ColorAdjustmentPanel = uipanel(app.CameraPanel);
            app.ColorAdjustmentPanel.Title = 'Color Adjustment';
            app.ColorAdjustmentPanel.Tag = 'uipanel_device';
            app.ColorAdjustmentPanel.FontSize = 13.3333333333333;
            app.ColorAdjustmentPanel.Position = [11 8 178 277];

            % Create HueEditFieldLabel
            app.HueEditFieldLabel = uilabel(app.ColorAdjustmentPanel);
            app.HueEditFieldLabel.HorizontalAlignment = 'right';
            app.HueEditFieldLabel.Enable = 'off';
            app.HueEditFieldLabel.Position = [6 226 28 22];
            app.HueEditFieldLabel.Text = 'Hue';

            % Create HueEditField
            app.HueEditField = uieditfield(app.ColorAdjustmentPanel, 'numeric');
            app.HueEditField.Editable = 'off';
            app.HueEditField.Enable = 'off';
            app.HueEditField.Position = [116 226 57 22];

            % Create HueSlider
            app.HueSlider = uislider(app.ColorAdjustmentPanel);
            app.HueSlider.Limits = [-100 100];
            app.HueSlider.MajorTicks = [];
            app.HueSlider.MajorTickLabels = {''};
            app.HueSlider.ValueChangedFcn = createCallbackFcn(app, @HueSliderValueChanged, true);
            app.HueSlider.MinorTicks = [];
            app.HueSlider.Enable = 'off';
            app.HueSlider.Position = [10 212 158 3];

            % Create SaturationSlider
            app.SaturationSlider = uislider(app.ColorAdjustmentPanel);
            app.SaturationSlider.Limits = [0 255];
            app.SaturationSlider.MajorTicks = [];
            app.SaturationSlider.MajorTickLabels = {''};
            app.SaturationSlider.ValueChangedFcn = createCallbackFcn(app, @SaturationSliderValueChanged, true);
            app.SaturationSlider.MinorTicks = [];
            app.SaturationSlider.Enable = 'off';
            app.SaturationSlider.Position = [13 170 158 3];
            app.SaturationSlider.Value = 128;

            % Create SaturationEditFieldLabel
            app.SaturationEditFieldLabel = uilabel(app.ColorAdjustmentPanel);
            app.SaturationEditFieldLabel.HorizontalAlignment = 'right';
            app.SaturationEditFieldLabel.Enable = 'off';
            app.SaturationEditFieldLabel.Position = [6 184 60 22];
            app.SaturationEditFieldLabel.Text = 'Saturation';

            % Create SaturationEditField
            app.SaturationEditField = uieditfield(app.ColorAdjustmentPanel, 'numeric');
            app.SaturationEditField.Editable = 'off';
            app.SaturationEditField.Enable = 'off';
            app.SaturationEditField.Position = [116 184 57 22];

            % Create BrightnessSlider
            app.BrightnessSlider = uislider(app.ColorAdjustmentPanel);
            app.BrightnessSlider.Limits = [-64 64];
            app.BrightnessSlider.MajorTicks = [];
            app.BrightnessSlider.MajorTickLabels = {''};
            app.BrightnessSlider.ValueChangedFcn = createCallbackFcn(app, @BrightnessSliderValueChanged, true);
            app.BrightnessSlider.MinorTicks = [];
            app.BrightnessSlider.Enable = 'off';
            app.BrightnessSlider.Position = [11 128 158 3];

            % Create BrightnessEditFieldLabel
            app.BrightnessEditFieldLabel = uilabel(app.ColorAdjustmentPanel);
            app.BrightnessEditFieldLabel.HorizontalAlignment = 'right';
            app.BrightnessEditFieldLabel.Enable = 'off';
            app.BrightnessEditFieldLabel.Position = [6 142 62 22];
            app.BrightnessEditFieldLabel.Text = 'Brightness';

            % Create BrightnessEditField
            app.BrightnessEditField = uieditfield(app.ColorAdjustmentPanel, 'numeric');
            app.BrightnessEditField.Editable = 'off';
            app.BrightnessEditField.Enable = 'off';
            app.BrightnessEditField.Position = [114 142 57 22];

            % Create ContrastSlider
            app.ContrastSlider = uislider(app.ColorAdjustmentPanel);
            app.ContrastSlider.Limits = [-100 100];
            app.ContrastSlider.MajorTicks = [];
            app.ContrastSlider.MajorTickLabels = {''};
            app.ContrastSlider.ValueChangedFcn = createCallbackFcn(app, @ContrastSliderValueChanged, true);
            app.ContrastSlider.MinorTicks = [];
            app.ContrastSlider.Enable = 'off';
            app.ContrastSlider.Position = [11 86 158 3];

            % Create ContrastEditFieldLabel
            app.ContrastEditFieldLabel = uilabel(app.ColorAdjustmentPanel);
            app.ContrastEditFieldLabel.HorizontalAlignment = 'right';
            app.ContrastEditFieldLabel.Enable = 'off';
            app.ContrastEditFieldLabel.Position = [6 100 51 22];
            app.ContrastEditFieldLabel.Text = 'Contrast';

            % Create ContrastEditField
            app.ContrastEditField = uieditfield(app.ColorAdjustmentPanel, 'numeric');
            app.ContrastEditField.Editable = 'off';
            app.ContrastEditField.Enable = 'off';
            app.ContrastEditField.Position = [114 100 57 22];

            % Create GammaSlider
            app.GammaSlider = uislider(app.ColorAdjustmentPanel);
            app.GammaSlider.Limits = [20 180];
            app.GammaSlider.MajorTicks = [];
            app.GammaSlider.MajorTickLabels = {''};
            app.GammaSlider.ValueChangedFcn = createCallbackFcn(app, @GammaSliderValueChanged, true);
            app.GammaSlider.MinorTicks = [];
            app.GammaSlider.Enable = 'off';
            app.GammaSlider.Position = [11 44 158 3];
            app.GammaSlider.Value = 100;

            % Create GammaEditFieldLabel
            app.GammaEditFieldLabel = uilabel(app.ColorAdjustmentPanel);
            app.GammaEditFieldLabel.HorizontalAlignment = 'right';
            app.GammaEditFieldLabel.Enable = 'off';
            app.GammaEditFieldLabel.Position = [9 58 48 22];
            app.GammaEditFieldLabel.Text = 'Gamma';

            % Create GammaEditField
            app.GammaEditField = uieditfield(app.ColorAdjustmentPanel, 'numeric');
            app.GammaEditField.Editable = 'off';
            app.GammaEditField.Enable = 'off';
            app.GammaEditField.Position = [114 58 57 22];

            % Create DefaultsButton
            app.DefaultsButton = uibutton(app.ColorAdjustmentPanel, 'push');
            app.DefaultsButton.ButtonPushedFcn = createCallbackFcn(app, @DefaultsButtonPushed, true);
            app.DefaultsButton.Enable = 'off';
            app.DefaultsButton.Position = [39 8 100 22];
            app.DefaultsButton.Text = 'Defaults';

            % Create ResolutionPanel
            app.ResolutionPanel = uipanel(app.CameraPanel);
            app.ResolutionPanel.Title = 'Resolution';
            app.ResolutionPanel.Tag = 'uipanel_device';
            app.ResolutionPanel.FontSize = 13.3333333333333;
            app.ResolutionPanel.Position = [11 668 178 58];

            % Create ResolutionDropDown
            app.ResolutionDropDown = uidropdown(app.ResolutionPanel);
            app.ResolutionDropDown.Items = {'4096 x 3288', '2048 x 1644', '1024 x 822'};
            app.ResolutionDropDown.Enable = 'off';
            app.ResolutionDropDown.Placeholder = 'Height x Width';
            app.ResolutionDropDown.Position = [26 7 128 22];
            app.ResolutionDropDown.Value = '1024 x 822';

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