classdef SarcLen_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SarcLenUIFigure                matlab.ui.Figure
        MicroscopeCalibrationumpxEditField  matlab.ui.control.NumericEditField
        MicroscopeCalibrationumpxEditFieldLabel  matlab.ui.control.Label
        BoxforSarcomereLengthButton    matlab.ui.control.Button
        LoadImageButton                matlab.ui.control.Button
        SarcomereLengthCalculationwithFFTPanel  matlab.ui.container.Panel
        ACFSarcomereLengthumEditField  matlab.ui.control.NumericEditField
        ACFSarcomereLengthumEditFieldLabel  matlab.ui.control.Label
        FFTSarcomereLengthumEditField  matlab.ui.control.NumericEditField
        FFTSarcomereLengthumEditFieldLabel  matlab.ui.control.Label
        ac_axes                        matlab.ui.control.UIAxes
        fft_axes_inset                 matlab.ui.control.UIAxes
        fft_axes                       matlab.ui.control.UIAxes
        fft_calculation_axes           matlab.ui.control.UIAxes
        BrightfieldPanel               matlab.ui.container.Panel
        BoxWidthEditField              matlab.ui.control.EditField
        BoxWidthLabel                  matlab.ui.control.Label
        BoxHeightEditField             matlab.ui.control.EditField
        BoxHeightLabel                 matlab.ui.control.Label
        PixelIntensityLabel            matlab.ui.control.Label
        RegionofInterestROILabel       matlab.ui.control.Label
        BrightfieldImageLabel          matlab.ui.control.Label
        px_intensity                   matlab.ui.control.UIAxes
        inset_axis                     matlab.ui.control.UIAxes
        image_axis                     matlab.ui.control.UIAxes
        calculation_axes_3             matlab.ui.control.UIAxes
    end


    properties (Access = private)
        image_file % Description
        roi_pos
        roi_rec
        px_cal
        roi_box
        mean_profile
        sig
    end

    methods (Access = private)
        
        function ClearDisplay(app)
            cla(app.image_axis)
            cla(app.inset_axis)
            cla(app.px_intensity)
            cla(app.fft_calculation_axes)
            cla(app.fft_axes)
            cla(app.fft_axes_inset)
            cla(app.ac_axes)
            app.ACFSarcomereLengthumEditField.Value = 0;
            app.FFTSarcomereLengthumEditField.Value = 0;

            
        end
    end
    
    methods (Access = public)
        
        function SarcomereLength(app)
            app.mean_profile = [];
            app.roi_box = [];
            app.roi_box = imcrop(app.image_file, ...
                app.roi_pos);
            center_image_with_preserved_aspect_ratio( ...
                app.roi_box, ...
                app.inset_axis);
            [m,n] = size(app.roi_box);
            hold(app.px_intensity,"on")
            for j = 1 : m
                plot(app.px_intensity,app.roi_box(j,:),'LineStyle',":","LineWidth",0.25);
            end
            app.mean_profile = mean(app.roi_box,1);
            h1 = plot(app.px_intensity,app.mean_profile,':','Color','k',"LineWidth",0.25);
            h2 = plot(app.px_intensity,app.mean_profile,'Color','b',"LineWidth",2);
%             legend(app.px_intensity,[h1 h2],'Intensity Along ROI Height', ...
%                 'Mean Intensity','Location',"northeast")
            w = hann(length(app.mean_profile));
            app.sig = app.mean_profile'.*w;
            hold(app.fft_calculation_axes,"on")
            plot(app.fft_calculation_axes,app.mean_profile,'Color','b',"LineWidth",2)
            plot(app.fft_calculation_axes, app.sig,'Color','r',"LineWidth",2)
            xlim(app.px_intensity, [1 numel(app.mean_profile)])
            xlim(app.fft_calculation_axes, [1 numel(app.mean_profile)])
            legend(app.fft_calculation_axes,"Mean Intensity", ...
                "Hann Windowed Mean Intensity",'Location',"south")
            SarcLenFFT(app)
            SarcLenAutoCorr(app)
            return
            
            
        end
        
        function sl_ac = SarcLenAutoCorr(app)
            x = app.mean_profile;
            [X_acf,lags] = autocorr(x,NumLags=round(numel(x)/2));
            plot(app.ac_axes,lags,X_acf,'LineWidth',2,'color','b')
            [lambda,fit_parameters,r_squared,y_fit] = fit_damped_sine_wave('y_data',X_acf,...
                'x_data',0:round(numel(x)/2), 'min_x_index_spacing',5);
            hold(app.ac_axes,"on")
            plot(app.ac_axes,lags,y_fit,'d','color','g','LineWidth',2)
            t = sprintf('Period  = %.3f',fit_parameters(4))
            text(app.ac_axes,round(numel(x)/2)-40,0.8,t)
            xlim(app.ac_axes,[0 round(numel(x)/2)])
            ylim(app.ac_axes,[-1 1])
            if app.px_cal ~=0
            app.ACFSarcomereLengthumEditField.Value = fit_parameters(4) * app.px_cal;
            end
        end
        
        function SarcLenFFT(app)
            x = app.sig;
            X = fft(x);
            L = numel(X);
            P2 = abs(X/L);
            [peaks, locs] = findpeaks(P2);
            [max_mag,max_ix] = max(peaks);
            F_p = 0:numel(X)-1;
            hold(app.fft_axes,"on")
            plot(app.fft_axes,F_p,P2,'Color','r','LineWidth',2)
            plot(app.fft_axes,F_p(locs(max_ix)),P2(locs(max_ix)),'o', ...
                'MarkerSize',5,"Color",'g')
            xlim(app.fft_axes,[0 numel(P2)-1])
            hold(app.fft_axes_inset,"on")
            fft_ix = (1:numel(P2)-1)/(numel(P2)*app.px_cal);
            fft_ix = [0 fft_ix];
            plot(app.fft_axes_inset,fft_ix,P2,'Color','r','LineWidth',2)
            plot(app.fft_axes_inset,fft_ix(locs(max_ix)),P2(locs(max_ix)),'o', ...
                'MarkerSize',15,"Color",'g')
            t = sprintf('Peak is at %.3f px^{-1}',fft_ix(locs(max_ix)));
            ylim(app.fft_axes_inset,[0 max(peaks)+5])
            xlim(app.fft_axes_inset,[0 fft_ix(locs(max_ix))+1])
            text(app.fft_axes_inset,fft_ix(locs(max_ix)),max(peaks)+2,t)
            
            if app.px_cal ~=0
            app.FFTSarcomereLengthumEditField.Value = numel(x)*app.px_cal/F_p(locs(max_ix));
            end
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            colormap(app.SarcLenUIFigure, 'gray');
            addpath(genpath('utilities'))
            movegui(app.SarcLenUIFigure,'center')


        end

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, event)

            filterspec = {'*.jpg;*.tif;*.png;*.gif','All Image Files'};
            [file_string,path_string] = uigetfile2(filterspec);
            if (path_string~=0)
                ClearDisplay(app)
                im_file = fullfile(path_string,file_string);
                im = imread(im_file);
                if (ndims(im)==3)
                    im = rgb2gray(im);
                end
                center_image_with_preserved_aspect_ratio( ...
                    im, ...
                    app.image_axis);
                app.image_file = im;
            end
        end

        % Button pushed function: BoxforSarcomereLengthButton
        function BoxforSarcomereLengthButtonPushed(app, event)

            app.roi_rec = drawrectangle(app.image_axis,'color','r');
            app.roi_rec.FaceAlpha = 0;
            app.roi_pos = get(app.roi_rec, 'Position');
            app.px_cal = app.MicroscopeCalibrationumpxEditField.Value;
            app.BoxHeightEditField.Value = string(app.roi_pos(4));  
            app.BoxWidthEditField.Value = string(app.roi_pos(3));
            SarcomereLength(app)

            addlistener(app.roi_rec,"MovingROI",@(src,evt) UpdateSL(evt));

            function UpdateSL(evt)
                app.roi_pos = get(app.roi_rec, 'Position');
                app.BoxHeightEditField.Value = string(app.roi_pos(4));  
                app.BoxWidthEditField.Value = string(app.roi_pos(3));
                cla(app.px_intensity)
                cla(app.fft_calculation_axes)
                cla(app.fft_axes)
                cla(app.fft_axes_inset)
                cla(app.ac_axes)

                SarcomereLength(app)
            end

        end

        % Value changed function: MicroscopeCalibrationumpxEditField
        function MicroscopeCalibrationumpxEditFieldValueChanged(app, event)
            app.px_cal = app.MicroscopeCalibrationumpxEditField.Value;
            if app.roi_pos
            app.SarcomereLength
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SarcLenUIFigure and hide until all components are created
            app.SarcLenUIFigure = uifigure('Visible', 'off');
            app.SarcLenUIFigure.Position = [100 100 1278 832];
            app.SarcLenUIFigure.Name = 'SarcLen';

            % Create calculation_axes_3
            app.calculation_axes_3 = uiaxes(app.SarcLenUIFigure);
            title(app.calculation_axes_3, '..')
            zlabel(app.calculation_axes_3, 'Z')
            app.calculation_axes_3.Box = 'on';
            app.calculation_axes_3.Position = [-700 580 325 272];

            % Create BrightfieldPanel
            app.BrightfieldPanel = uipanel(app.SarcLenUIFigure);
            app.BrightfieldPanel.Title = 'Brightfield Panel';
            app.BrightfieldPanel.Position = [18 389 1246 388];

            % Create image_axis
            app.image_axis = uiaxes(app.BrightfieldPanel);
            zlabel(app.image_axis, 'Z')
            app.image_axis.XTick = [];
            app.image_axis.YTick = [];
            app.image_axis.Box = 'on';
            app.image_axis.Position = [13 58 539 271];

            % Create inset_axis
            app.inset_axis = uiaxes(app.BrightfieldPanel);
            zlabel(app.inset_axis, 'Z')
            app.inset_axis.XTick = [];
            app.inset_axis.YTick = [];
            app.inset_axis.Box = 'on';
            app.inset_axis.Position = [555 151 325 179];

            % Create px_intensity
            app.px_intensity = uiaxes(app.BrightfieldPanel);
            xlabel(app.px_intensity, 'ROI Index')
            ylabel(app.px_intensity, 'Optical Intensity (A.U)')
            zlabel(app.px_intensity, 'Z')
            app.px_intensity.Box = 'on';
            app.px_intensity.Position = [909 50 325 280];

            % Create BrightfieldImageLabel
            app.BrightfieldImageLabel = uilabel(app.BrightfieldPanel);
            app.BrightfieldImageLabel.FontWeight = 'bold';
            app.BrightfieldImageLabel.Position = [220 339 104 22];
            app.BrightfieldImageLabel.Text = 'Brightfield Image';

            % Create RegionofInterestROILabel
            app.RegionofInterestROILabel = uilabel(app.BrightfieldPanel);
            app.RegionofInterestROILabel.FontWeight = 'bold';
            app.RegionofInterestROILabel.Position = [649 339 138 22];
            app.RegionofInterestROILabel.Text = 'Region of Interest (ROI)';

            % Create PixelIntensityLabel
            app.PixelIntensityLabel = uilabel(app.BrightfieldPanel);
            app.PixelIntensityLabel.FontWeight = 'bold';
            app.PixelIntensityLabel.Position = [1047 329 86 22];
            app.PixelIntensityLabel.Text = 'Pixel Intensity';

            % Create BoxHeightLabel
            app.BoxHeightLabel = uilabel(app.BrightfieldPanel);
            app.BoxHeightLabel.HorizontalAlignment = 'right';
            app.BoxHeightLabel.Position = [601 95 68 22];
            app.BoxHeightLabel.Text = 'Box Height ';

            % Create BoxHeightEditField
            app.BoxHeightEditField = uieditfield(app.BrightfieldPanel, 'text');
            app.BoxHeightEditField.Editable = 'off';
            app.BoxHeightEditField.Position = [684 95 100 22];

            % Create BoxWidthLabel
            app.BoxWidthLabel = uilabel(app.BrightfieldPanel);
            app.BoxWidthLabel.HorizontalAlignment = 'right';
            app.BoxWidthLabel.Position = [605 56 60 22];
            app.BoxWidthLabel.Text = 'Box Width';

            % Create BoxWidthEditField
            app.BoxWidthEditField = uieditfield(app.BrightfieldPanel, 'text');
            app.BoxWidthEditField.Editable = 'off';
            app.BoxWidthEditField.Position = [684 56 100 22];

            % Create SarcomereLengthCalculationwithFFTPanel
            app.SarcomereLengthCalculationwithFFTPanel = uipanel(app.SarcLenUIFigure);
            app.SarcomereLengthCalculationwithFFTPanel.Title = 'Sarcomere Length Calculation with FFT';
            app.SarcomereLengthCalculationwithFFTPanel.Position = [18 12 1246 359];

            % Create fft_calculation_axes
            app.fft_calculation_axes = uiaxes(app.SarcomereLengthCalculationwithFFTPanel);
            title(app.fft_calculation_axes, 'Intensity Profile for SL Calculation')
            xlabel(app.fft_calculation_axes, 'ROI Index')
            ylabel(app.fft_calculation_axes, 'Optical Intensity (A.U)')
            zlabel(app.fft_calculation_axes, 'Z')
            app.fft_calculation_axes.Box = 'on';
            app.fft_calculation_axes.Position = [21 43 371 272];

            % Create fft_axes
            app.fft_axes = uiaxes(app.SarcomereLengthCalculationwithFFTPanel);
            title(app.fft_axes, 'FFT: Double-Sided Spectrum')
            xlabel(app.fft_axes, 'FFT Index')
            ylabel(app.fft_axes, 'Amplitude (A.U.)')
            zlabel(app.fft_axes, 'Z')
            app.fft_axes.Box = 'on';
            app.fft_axes.Position = [437 43 371 272];

            % Create fft_axes_inset
            app.fft_axes_inset = uiaxes(app.SarcomereLengthCalculationwithFFTPanel);
            xlabel(app.fft_axes_inset, 'Pixel^{-1}')
            ylabel(app.fft_axes_inset, 'Amplitude (A.U.)')
            zlabel(app.fft_axes_inset, 'Z')
            app.fft_axes_inset.Position = [609 148 172 137];

            % Create ac_axes
            app.ac_axes = uiaxes(app.SarcomereLengthCalculationwithFFTPanel);
            title(app.ac_axes, 'ACF')
            xlabel(app.ac_axes, 'Lags')
            ylabel(app.ac_axes, 'Amplitude (A.U.)')
            zlabel(app.ac_axes, 'Z')
            app.ac_axes.Box = 'on';
            app.ac_axes.Position = [846 43 371 272];

            % Create FFTSarcomereLengthumEditFieldLabel
            app.FFTSarcomereLengthumEditFieldLabel = uilabel(app.SarcomereLengthCalculationwithFFTPanel);
            app.FFTSarcomereLengthumEditFieldLabel.HorizontalAlignment = 'right';
            app.FFTSarcomereLengthumEditFieldLabel.Position = [503 12 157 22];
            app.FFTSarcomereLengthumEditFieldLabel.Text = 'FFT Sarcomere Length (um)';

            % Create FFTSarcomereLengthumEditField
            app.FFTSarcomereLengthumEditField = uieditfield(app.SarcomereLengthCalculationwithFFTPanel, 'numeric');
            app.FFTSarcomereLengthumEditField.Editable = 'off';
            app.FFTSarcomereLengthumEditField.Position = [667 12 100 22];

            % Create ACFSarcomereLengthumEditFieldLabel
            app.ACFSarcomereLengthumEditFieldLabel = uilabel(app.SarcomereLengthCalculationwithFFTPanel);
            app.ACFSarcomereLengthumEditFieldLabel.HorizontalAlignment = 'right';
            app.ACFSarcomereLengthumEditFieldLabel.Position = [905 12 160 22];
            app.ACFSarcomereLengthumEditFieldLabel.Text = 'ACF Sarcomere Length (um)';

            % Create ACFSarcomereLengthumEditField
            app.ACFSarcomereLengthumEditField = uieditfield(app.SarcomereLengthCalculationwithFFTPanel, 'numeric');
            app.ACFSarcomereLengthumEditField.Editable = 'off';
            app.ACFSarcomereLengthumEditField.Position = [1080 12 100 22];

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.SarcLenUIFigure, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.Position = [17 792 100 23];
            app.LoadImageButton.Text = 'Load Image';

            % Create BoxforSarcomereLengthButton
            app.BoxforSarcomereLengthButton = uibutton(app.SarcLenUIFigure, 'push');
            app.BoxforSarcomereLengthButton.ButtonPushedFcn = createCallbackFcn(app, @BoxforSarcomereLengthButtonPushed, true);
            app.BoxforSarcomereLengthButton.Position = [131 792 156 23];
            app.BoxforSarcomereLengthButton.Text = 'Box for Sarcomere Length';

            % Create MicroscopeCalibrationumpxEditFieldLabel
            app.MicroscopeCalibrationumpxEditFieldLabel = uilabel(app.SarcLenUIFigure);
            app.MicroscopeCalibrationumpxEditFieldLabel.HorizontalAlignment = 'right';
            app.MicroscopeCalibrationumpxEditFieldLabel.Position = [307 793 172 22];
            app.MicroscopeCalibrationumpxEditFieldLabel.Text = 'Microscope Calibration (um/px)';

            % Create MicroscopeCalibrationumpxEditField
            app.MicroscopeCalibrationumpxEditField = uieditfield(app.SarcLenUIFigure, 'numeric');
            app.MicroscopeCalibrationumpxEditField.ValueChangedFcn = createCallbackFcn(app, @MicroscopeCalibrationumpxEditFieldValueChanged, true);
            app.MicroscopeCalibrationumpxEditField.Position = [494 793 100 22];

            % Show the figure after all components are created
            app.SarcLenUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SarcLen_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.SarcLenUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.SarcLenUIFigure)
        end
    end
end