classdef Assignment3_part_1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        ApplyMeanSquareErrorMMSEFilterButton  matlab.ui.control.Button
        AddNoisetoImageButton   matlab.ui.control.Button
        VarianceEditField       matlab.ui.control.NumericEditField
        VarianceEditFieldLabel  matlab.ui.control.Label
        MeanEditField           matlab.ui.control.NumericEditField
        MeanEditFieldLabel      matlab.ui.control.Label
        GaussianNoiseParametersEntervalues0100Label  matlab.ui.control.Label
        UploadImageButton       matlab.ui.control.Button
        UIAxes3                 matlab.ui.control.UIAxes
        UIAxes2                 matlab.ui.control.UIAxes
        UIAxes                  matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UploadImageButton
        function UploadImageButtonPushed(app, event)
            global img; 
            [filename, pathname] = uigetfile('*.*', 'Pick an Image');
            filename=strcat(pathname,filename);
            img=imread(filename);   
            imshow(img,'Parent',app.UIAxes);
        end

        % Button pushed function: AddNoisetoImageButton
        function AddNoisetoImageButtonPushed(app, event)
            global img;
            global noisyImage;
            image = double(img)/255;
            %adding noise to the image
            meann = app.MeanEditField.Value/100;
            varaiance = app.VarianceEditField.Value/100;

            noisyImage = imnoise(image, 'gaussian', meann, varaiance);
            imshow(noisyImage,'Parent',app.UIAxes2);

        end

        % Button pushed function: ApplyMeanSquareErrorMMSEFilterButton
        function ApplyMeanSquareErrorMMSEFilterButtonPushed(app, event)
            global noisyImage;
            [rows, cols, colors] = size(noisyImage);
 
            %dimensions of the window
            N = 3;
            
            %applying zero padding on boundary
            rows1 = rows + 2;
            cols1 = cols + 2;
            img = zeros(rows1, cols1);
            x = 2;
            y = 2;
            for i = 1 : rows
                for j = 1 : cols
                    img(x, y) = noisyImage(i, j);
                    y = y + 1;
                end
                y = 2;
                x = x + 1;
            end 
            
            %applying window to caclulate mean and local variance
            size_arr = rows*cols;
            mean = zeros(1,size_arr);
            meanSquared = zeros(1,size_arr);
            localVar = zeros(1, size_arr);
            index = 0;
            for i = 1 : rows
                for j = 1 : cols
                    sum = 0;
                    sumSq = 0;
                    k = i;
                    l = j;
                    index = index + 1;
                    for x = 1 : N
                        for y = 1 : N
                            sum = sum + img(k, l);
                            sumSq = sumSq + (img(k, l)^2);
                            l = l + 1;
                        end
                        l = j;
                        k = k + 1;
                    end
                    mean(index) = sum/(N*N);
                    meanSquared(index) = sumSq/(N*N);
                    %local variance = mean(W^2) - mean(W)^2
                    localVar(index) = meanSquared(index) - (mean(index)^2);
                end
            end
            
            %calculating noise variance
            noiseVar = var(img(:));
            disp(noiseVar);
            
            %converting localVar and mean into 2D arrays
            localVartemp = zeros(rows, cols);
            meantemp = zeros(rows, cols);
            ind = 0;
            for i = 1 : rows
                for j = 1 : cols
                    ind = ind + 1;
                    localVartemp(i, j) = localVar(ind);
                    meantemp(i, j) = mean(ind);
                end
            end
            
            %comparing the noiseVar and localVar
            for i = 1 :  rows
                for j = 1: cols
                    if noiseVar > localVartemp(i, j)
                        localVartemp(i, j) = noiseVar;
                    end
                end
            end
            
            %applying the final formula
            NewImg = zeros(rows, cols);
            for i = 1 : rows
                for j = 1 : cols
                    %sigma_N/sigma_L
                    NewImg(i, j) = noiseVar/localVartemp(i, j);
                    %d(r, c) - m_L
                    NewImg(i, j) = NewImg(i, j) * (noisyImage(i, j) - meantemp(i, j));
                end
            end
            %d(r, c)- calculated bracket
            NewImg = noisyImage-NewImg;
            
            %displaying the final image
            imshow(NewImg,'Parent',app.UIAxes3);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1044 596];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Orignal image')
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [137 364 330 213];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Noisy Image')
            app.UIAxes2.XTick = [];
            app.UIAxes2.YTick = [];
            app.UIAxes2.Position = [699 372 326 205];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.UIFigure);
            title(app.UIAxes3, 'Result Image')
            app.UIAxes3.XTick = [];
            app.UIAxes3.YTick = [];
            app.UIAxes3.Position = [312 17 440 281];

            % Create UploadImageButton
            app.UploadImageButton = uibutton(app.UIFigure, 'push');
            app.UploadImageButton.ButtonPushedFcn = createCallbackFcn(app, @UploadImageButtonPushed, true);
            app.UploadImageButton.Position = [24 444 106 53];
            app.UploadImageButton.Text = 'Upload Image';

            % Create GaussianNoiseParametersEntervalues0100Label
            app.GaussianNoiseParametersEntervalues0100Label = uilabel(app.UIFigure);
            app.GaussianNoiseParametersEntervalues0100Label.Position = [504 522 162 44];
            app.GaussianNoiseParametersEntervalues0100Label.Text = {'Gaussian Noise Parameters'; ''; '-> Enter % values 0 - 100'};

            % Create MeanEditFieldLabel
            app.MeanEditFieldLabel = uilabel(app.UIFigure);
            app.MeanEditFieldLabel.HorizontalAlignment = 'right';
            app.MeanEditFieldLabel.Position = [514 492 35 22];
            app.MeanEditFieldLabel.Text = 'Mean';

            % Create MeanEditField
            app.MeanEditField = uieditfield(app.UIFigure, 'numeric');
            app.MeanEditField.Position = [564 492 100 22];

            % Create VarianceEditFieldLabel
            app.VarianceEditFieldLabel = uilabel(app.UIFigure);
            app.VarianceEditFieldLabel.HorizontalAlignment = 'right';
            app.VarianceEditFieldLabel.Position = [499 453 51 22];
            app.VarianceEditFieldLabel.Text = 'Variance';

            % Create VarianceEditField
            app.VarianceEditField = uieditfield(app.UIFigure, 'numeric');
            app.VarianceEditField.Position = [565 453 100 22];

            % Create AddNoisetoImageButton
            app.AddNoisetoImageButton = uibutton(app.UIFigure, 'push');
            app.AddNoisetoImageButton.ButtonPushedFcn = createCallbackFcn(app, @AddNoisetoImageButtonPushed, true);
            app.AddNoisetoImageButton.Position = [529 399 136 38];
            app.AddNoisetoImageButton.Text = 'Add Noise to Image';

            % Create ApplyMeanSquareErrorMMSEFilterButton
            app.ApplyMeanSquareErrorMMSEFilterButton = uibutton(app.UIFigure, 'push');
            app.ApplyMeanSquareErrorMMSEFilterButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyMeanSquareErrorMMSEFilterButtonPushed, true);
            app.ApplyMeanSquareErrorMMSEFilterButton.Position = [45 129 242 56];
            app.ApplyMeanSquareErrorMMSEFilterButton.Text = 'Apply Mean Square Error (MMSE) Filter';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Assignment3_part_1

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end