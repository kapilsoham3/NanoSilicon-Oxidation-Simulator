classdef NanoSilicon_exported < matlab.apps.AppBase
    %NANOSILICON_EXPORTED Uses Deal Grove and Massoud Method and gets initial and
    %final thickness to calculate the oxidation time under dry conditions
    %   This code uses Massoud and Deal Grove models so that the user can
    %   figure out what model is appropriate and uses specific coefficients
    %   for all cases. It then gives three tabs, one for just Deal Grove,
    %   one for just Massoud and one for both. Each tab gives the predicted
    %   time and the Both tab gives the two times using both models and the
    %   percent difference. For Deal Grove, there weren't any recorded
    %   accurate coefficients that I could find for Si (110) which is why
    %   only Massoud model is active for that but for the other crystal
    %   planes, you can access both Massoud and Deal Grove. There is also a
    %   graph that plots how thickness changes over time from initial to
    %   final in both models and an export model that gives the data points
    %   from the graph as a csv file

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        FinalOxideThicknessnmEditField  matlab.ui.control.NumericEditField
        FinalOxideThicknessnmEditFieldLabel  matlab.ui.control.Label
        TemperatureinCelsiusSpinner     matlab.ui.control.Spinner
        TemperatureinCelsiusSpinnerLabel  matlab.ui.control.Label
        TypeofSiliconStructureDropDown  matlab.ui.control.DropDown
        TypeofSiliconStructureDropDownLabel  matlab.ui.control.Label
        InitialOxideThicknessnmEditField  matlab.ui.control.NumericEditField
        InitialOxideThicknessnmEditFieldLabel  matlab.ui.control.Label
        TabGroup                        matlab.ui.container.TabGroup
        DealGroveTab                    matlab.ui.container.Tab
        GridLayout3                     matlab.ui.container.GridLayout
        ResultsPanel_3                  matlab.ui.container.Panel
        PredictedOxidationtimehrLabel   matlab.ui.control.Label
        ExportCSVfromSimulationLabel    matlab.ui.control.Label
        ExportButton                    matlab.ui.control.Button
        UIAxes                          matlab.ui.control.UIAxes
        MassoudTab                      matlab.ui.container.Tab
        GridLayout4                     matlab.ui.container.GridLayout
        PredictedOxidationtimehrLabel_2  matlab.ui.control.Label
        ResultsPanel_2                  matlab.ui.container.Panel
        ExportCSVfromSimmulationLabel_2  matlab.ui.control.Label
        ExportButton_2                  matlab.ui.control.Button
        UIAxes_2                        matlab.ui.control.UIAxes
        BothTab                         matlab.ui.container.Tab
        GridLayout2                     matlab.ui.container.GridLayout
        ResultsPanel                    matlab.ui.container.Panel
        GridLayout5                     matlab.ui.container.GridLayout
        PercentageDifferenceLabel       matlab.ui.control.Label
        MassoudPredictionhrLabel        matlab.ui.control.Label
        DealGrovePredictionhrLabel      matlab.ui.control.Label
        ExportButton_3                  matlab.ui.control.Button
        ExportCSVfromSimmulationLabel_3  matlab.ui.control.Label
        UIAxes_3                        matlab.ui.control.UIAxes
        RunOxidizationSimulationButton  matlab.ui.control.Button
        NanoSiliconOxidationSimulatorforDryAmbientLabel  matlab.ui.control.Label
    end

    
    properties (Access = private)
        SharedData % Description
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: RunOxidizationSimulationButton
        function RunOxidizationSimulationButtonPushed(app, event)
   
            %% INPUTS
            T_C = app.TemperatureinCelsiusSpinner.Value;
            x0_nm = app.InitialOxideThicknessnmEditField.Value;
            xf_nm = app.FinalOxideThicknessnmEditField.Value;
            plane = app.TypeofSiliconStructureDropDown.Value;

            %% VALIDATION
            if xf_nm <= x0_nm
                uialert(app.UIFigure, ...
                    'Final oxide thickness must exceed initial thickness.', ...
                    'Invalid Thickness');
                return;
            end

            %% CONSTANTS
            T_K = T_C + 273.15;
            kB = 8.617333e-5; % eV/K

            %% MASSOUD LITERATURE PARAMETERS
            % Order: Si(100), Si(111), Si(110)

            CB = [1.70e11, 1.34e9, 3.73e8];
            EB = [2.22, 1.71, 1.63];

            CBA = [7.35e6, 1.32e7, 4.73e8];
            EBA = [1.76, 1.74, 2.10];

            K10 = [2.49e11, 2.70e9, 4.07e8];
            EK1 = [2.18, 1.74, 1.54];

            K20 = [3.72e11, 1.33e9, 1.20e8];
            EK2 = [2.28, 1.76, 1.56];

            tau10 = [4.14e-6, 1.72e-6, 5.38e-9];
            Etau1 = [1.38, 1.45, 2.02];

            tau20 = [2.71e-7, 1.56e-7, 1.63e-8];
            Etau2 = [1.88, 1.90, 2.12];

            %% SELECT ORIENTATION
            switch plane
                case 'Si (100)'
                    i = 1;

                case 'Si (111)'
                    i = 2;

                case 'Si (110)'
                    i = 3;

                otherwise
                    uialert(app.UIFigure, ...
                        'Invalid silicon orientation.', 'Error');
                    return;
            end

            %% MODEL 1: DEAL-GROVE
            % Dry O2, 1 atm.
            % Reference parameters are for Si(111).
            % Si(100): B/A prefactor divided by 1.68.
            % No Deal-Grove result is provided for Si(110).

            if i ~= 3
                C1_DG = 7.72e2; % um^2/hr
                E1_DG = 1.23;   % eV

                C2_DG = 6.23e6; % um/hr
                E2_DG = 2.00;   % eV

                if i == 1
                    C2_DG = C2_DG / 1.68;
                end

                % Convert to nm^2/min and nm/min
                B_DG = C1_DG * 1e6 / 60 * ...
                    exp(-E1_DG/(kB*T_K));

                B_over_A_DG = C2_DG * 1e3 / 60 * ...
                    exp(-E2_DG/(kB*T_K));

                A_DG = B_DG / B_over_A_DG;

                M0_DG = x0_nm^2 + A_DG*x0_nm;
                target_DG = xf_nm^2 + A_DG*xf_nm - M0_DG;

                time_DG_min = target_DG / B_DG;
                time_DG_hr = time_DG_min / 60;

                t_DG = linspace(0, time_DG_hr, 100);
                t_DG_min = t_DG * 60;

                x_DG = -A_DG/2 + sqrt( ...
                    (A_DG/2)^2 + M0_DG + B_DG*t_DG_min);

            else
                time_DG_hr = NaN;
                t_DG = NaN(1,100);
                x_DG = NaN(1,100);
            end

            %% MODEL 2: MASSOUD

            % Temperature-dependent Massoud base coefficients
            B_Massoud = CB(i) * exp(-EB(i)/(kB*T_K));

            B_over_A_Massoud = CBA(i) * ...
                exp(-EBA(i)/(kB*T_K));

            A_Massoud = B_Massoud / B_over_A_Massoud;

            % Time-dependent Massoud enhancement coefficients
            K1 = K10(i) * exp(-EK1(i)/(kB*T_K));
            K2 = K20(i) * exp(-EK2(i)/(kB*T_K));

            tau1 = tau10(i) * exp(Etau1(i)/(kB*T_K));
            tau2 = tau20(i) * exp(Etau2(i)/(kB*T_K));

            % Initial and target thickness terms
            M0_Massoud = x0_nm^2 + A_Massoud*x0_nm;

            target_Massoud = ...
                xf_nm^2 + A_Massoud*xf_nm - M0_Massoud;

            % Analytical integrated Massoud equation.
            % fzero finds the time required to reach the target.
            massoudEquation = @(t) ...
                B_Massoud*t ...
                + K1*tau1*(1 - exp(-t/tau1)) ...
                + K2*tau2*(1 - exp(-t/tau2)) ...
                - target_Massoud;

           
            upperTime = target_Massoud / B_Massoud;

            time_Massoud_min = fzero( ...
                massoudEquation, [0, upperTime]);

            time_Massoud_hr = time_Massoud_min / 60;

            % Generate the Massoud graph using the analytical
            % thickness equation, not ode45 or numerical integration.
            t_Massoud_min = linspace( ...
                0, time_Massoud_min, 100);

            t_Massoud = t_Massoud_min / 60;

            x_Massoud = -A_Massoud/2 + sqrt( ...
                (A_Massoud/2)^2 ...
                + M0_Massoud ...
                + B_Massoud*t_Massoud_min ...
                + K1*tau1*(1 - exp(-t_Massoud_min/tau1)) ...
                + K2*tau2*(1 - exp(-t_Massoud_min/tau2)));

            %% MODEL 3: PERCENTAGE DIFFERENCE

            if i == 3
                percentageDifference = NaN;
            else
                percentageDifference = ...
                    abs(time_DG_hr - time_Massoud_hr) ...
                    / ((time_DG_hr + time_Massoud_hr)/2) * 100;
            end

            %% DEAL-GROVE TAB

            if i == 3
                app.PredictedOxidationtimehrLabel.Text = ...
                    'Deal-Grove: NA (not available for Si(110))';
                cla(app.UIAxes);
            else
                app.PredictedOxidationtimehrLabel.Text = ...
                    sprintf('Predicted Oxidation time: %.4f hr', time_DG_hr);

                plot(app.UIAxes, t_DG, x_DG);
            end

            %% MASSOUD TAB

            app.PredictedOxidationtimehrLabel_2.Text = ...
                sprintf('  Predicted Oxidation Time: %.4f hr', time_Massoud_hr);

            plot(app.UIAxes_2, t_Massoud, x_Massoud);

            %% BOTH TAB

            if i == 3
                app.DealGrovePredictionhrLabel.Text = ...
                    '   Deal-Grove Preidiction: NA';

                app.PercentageDifferenceLabel.Text = ...
                    '   Percentage Difference: NA';

                app.MassoudPredictionhrLabel.Text = ...
                    sprintf('   Massoud: %.4f hr', time_Massoud_hr);

                cla(app.UIAxes_3);
                plot(app.UIAxes_3, t_Massoud, x_Massoud);
                legend(app.UIAxes_3, {'Massoud'});

            else
                app.DealGrovePredictionhrLabel.Text = ...
                    sprintf('   Deal-Grove Prediction: %.4f hr', time_DG_hr);

                app.MassoudPredictionhrLabel.Text = ...
                    sprintf('   Massoud Prediction: %.4f hr', time_Massoud_hr);

                app.PercentageDifferenceLabel.Text = ...
                    sprintf('   Percentage Difference: %.2f%%', ...
                    percentageDifference);

                cla(app.UIAxes_3);
                plot(app.UIAxes_3, t_DG, x_DG);
                hold(app.UIAxes_3, 'on');
                plot(app.UIAxes_3, t_Massoud, x_Massoud);
                hold(app.UIAxes_3, 'off');
                legend(app.UIAxes_3, {'Deal-Grove', 'Massoud'});
            end

            %% EXPORT DATA

            app.SharedData = table( ...
                t_DG', x_DG', t_Massoud', x_Massoud', ...
                'VariableNames', ...
                {'Time_DG_hr', 'Thickness_DG_nm', ...
                 'Time_Massoud_hr', 'Thickness_Massoud_nm'});
        

    
        end

        % Button pushed function: ExportButton, ExportButton_2, 
        % ...and 1 other component
        function ExportButton_3Pushed(app, event)
             if isempty(app.SharedData)
        uialert(app.UIFigure, 'Please run the simulation before exporting data.', 'No Data Found');
        return;
             end    
    % 2. Open a "Save As" browser window restricted to .csv files
    [filename, pathname] = uiputfile('*.csv', 'Export Simulation Data', 'Oxidation_Simulation_Results.csv');
    
    % 3. If the user didn't hit cancel, write the table to disk
    if isequal(filename, 0) || isequal(pathname, 0)
        return; % User clicked cancel
    else
        fullfilepath = fullfile(pathname, filename);
        writetable(app.SharedData, fullfilepath);
        
        % Notify the user it was successful
        uialert(app.UIFigure, ['Data successfully exported to: ', filename], 'Export Complete', 'Icon', 'success');
    end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 677 569];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {153, 100, 119, 59, 100, '1x'};
            app.GridLayout.RowHeight = {31, 22, 22, 22, '1x'};
            app.GridLayout.ColumnSpacing = 3.5;
            app.GridLayout.RowSpacing = 5.5;
            app.GridLayout.Padding = [3.5 5.5 3.5 5.5];

            % Create NanoSiliconOxidationSimulatorforDryAmbientLabel
            app.NanoSiliconOxidationSimulatorforDryAmbientLabel = uilabel(app.GridLayout);
            app.NanoSiliconOxidationSimulatorforDryAmbientLabel.FontSize = 24;
            app.NanoSiliconOxidationSimulatorforDryAmbientLabel.FontWeight = 'bold';
            app.NanoSiliconOxidationSimulatorforDryAmbientLabel.Layout.Row = 1;
            app.NanoSiliconOxidationSimulatorforDryAmbientLabel.Layout.Column = [1 6];
            app.NanoSiliconOxidationSimulatorforDryAmbientLabel.Text = 'NanoSilicon Oxidation Simulator for Dry Ambient';

            % Create RunOxidizationSimulationButton
            app.RunOxidizationSimulationButton = uibutton(app.GridLayout, 'push');
            app.RunOxidizationSimulationButton.ButtonPushedFcn = createCallbackFcn(app, @RunOxidizationSimulationButtonPushed, true);
            app.RunOxidizationSimulationButton.HandleVisibility = 'off';
            app.RunOxidizationSimulationButton.FontWeight = 'bold';
            app.RunOxidizationSimulationButton.Layout.Row = 4;
            app.RunOxidizationSimulationButton.Layout.Column = [3 4];
            app.RunOxidizationSimulationButton.Text = 'Run Oxidization Simulation';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 5;
            app.TabGroup.Layout.Column = [1 6];

            % Create DealGroveTab
            app.DealGroveTab = uitab(app.TabGroup);
            app.DealGroveTab.Title = 'Deal-Grove';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.DealGroveTab);
            app.GridLayout3.ColumnWidth = {158, 100, '1x', 246, 43};
            app.GridLayout3.RowHeight = {'1x', 22, 63};
            app.GridLayout3.ColumnSpacing = 1.64999643961588;
            app.GridLayout3.RowSpacing = 2.25;
            app.GridLayout3.Padding = [1.64999643961588 2.25 1.64999643961588 2.25];

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout3);
            title(app.UIAxes, 'Oxide Thickness vs. Oxidation Time')
            xlabel(app.UIAxes, 'Oxide time (h)')
            ylabel(app.UIAxes, 'Oxide thickness (nm)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = [1 4];

            % Create ExportButton
            app.ExportButton = uibutton(app.GridLayout3, 'push');
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButton_3Pushed, true);
            app.ExportButton.Layout.Row = 2;
            app.ExportButton.Layout.Column = 2;
            app.ExportButton.Text = 'Export';

            % Create ExportCSVfromSimulationLabel
            app.ExportCSVfromSimulationLabel = uilabel(app.GridLayout3);
            app.ExportCSVfromSimulationLabel.Layout.Row = 2;
            app.ExportCSVfromSimulationLabel.Layout.Column = 1;
            app.ExportCSVfromSimulationLabel.Text = 'Export CSV from Simulation ';

            % Create ResultsPanel_3
            app.ResultsPanel_3 = uipanel(app.GridLayout3);
            app.ResultsPanel_3.Title = 'Results';
            app.ResultsPanel_3.Layout.Row = [2 3];
            app.ResultsPanel_3.Layout.Column = [4 5];

            % Create PredictedOxidationtimehrLabel
            app.PredictedOxidationtimehrLabel = uilabel(app.ResultsPanel_3);
            app.PredictedOxidationtimehrLabel.FontSize = 14;
            app.PredictedOxidationtimehrLabel.Position = [8 18 321 43];
            app.PredictedOxidationtimehrLabel.Text = 'Predicted Oxidation time: -- hr';

            % Create MassoudTab
            app.MassoudTab = uitab(app.TabGroup);
            app.MassoudTab.Title = 'Massoud';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.MassoudTab);
            app.GridLayout4.ColumnWidth = {164.5, 96.5, '1x', 243.5, 38.5, 28.5};
            app.GridLayout4.RowHeight = {'1x', 22, 21, 42};
            app.GridLayout4.ColumnSpacing = 0;
            app.GridLayout4.RowSpacing = 1.97998657226563;
            app.GridLayout4.Padding = [0 1.97998657226563 0 1.97998657226563];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout4);
            title(app.UIAxes_2, 'Oxide Thickness vs. Oxidation Time')
            xlabel(app.UIAxes_2, 'Oxide time (h)')
            ylabel(app.UIAxes_2, 'Oxide thickness (nm)')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.XGrid = 'on';
            app.UIAxes_2.YGrid = 'on';
            app.UIAxes_2.Layout.Row = 1;
            app.UIAxes_2.Layout.Column = [1 4];

            % Create ExportButton_2
            app.ExportButton_2 = uibutton(app.GridLayout4, 'push');
            app.ExportButton_2.ButtonPushedFcn = createCallbackFcn(app, @ExportButton_3Pushed, true);
            app.ExportButton_2.Layout.Row = 2;
            app.ExportButton_2.Layout.Column = 2;
            app.ExportButton_2.Text = 'Export';

            % Create ExportCSVfromSimmulationLabel_2
            app.ExportCSVfromSimmulationLabel_2 = uilabel(app.GridLayout4);
            app.ExportCSVfromSimmulationLabel_2.Layout.Row = 2;
            app.ExportCSVfromSimmulationLabel_2.Layout.Column = 1;
            app.ExportCSVfromSimmulationLabel_2.Text = 'Export CSV from Simmulation ';

            % Create ResultsPanel_2
            app.ResultsPanel_2 = uipanel(app.GridLayout4);
            app.ResultsPanel_2.Title = 'Results';
            app.ResultsPanel_2.Layout.Row = [2 4];
            app.ResultsPanel_2.Layout.Column = [4 6];

            % Create PredictedOxidationtimehrLabel_2
            app.PredictedOxidationtimehrLabel_2 = uilabel(app.GridLayout4);
            app.PredictedOxidationtimehrLabel_2.FontSize = 14;
            app.PredictedOxidationtimehrLabel_2.Layout.Row = [3 4];
            app.PredictedOxidationtimehrLabel_2.Layout.Column = [4 6];
            app.PredictedOxidationtimehrLabel_2.Text = '   Predicted Oxidation time: -- hr';

            % Create BothTab
            app.BothTab = uitab(app.TabGroup);
            app.BothTab.Title = 'Both';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.BothTab);
            app.GridLayout2.ColumnWidth = {168, 100, '1x', 283};
            app.GridLayout2.RowHeight = {'1x', 33, 35};
            app.GridLayout2.ColumnSpacing = 5.39999389648438;
            app.GridLayout2.Padding = [5.39999389648438 10 5.39999389648438 10];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.GridLayout2);
            title(app.UIAxes_3, 'Oxide Thickness vs. Oxidation Time')
            xlabel(app.UIAxes_3, 'Oxide time (h)')
            ylabel(app.UIAxes_3, 'Oxide thickness (nm)')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.XGrid = 'on';
            app.UIAxes_3.YGrid = 'on';
            app.UIAxes_3.Layout.Row = 1;
            app.UIAxes_3.Layout.Column = [1 4];

            % Create ExportCSVfromSimmulationLabel_3
            app.ExportCSVfromSimmulationLabel_3 = uilabel(app.GridLayout2);
            app.ExportCSVfromSimmulationLabel_3.Layout.Row = 3;
            app.ExportCSVfromSimmulationLabel_3.Layout.Column = 1;
            app.ExportCSVfromSimmulationLabel_3.Text = 'Export CSV from Simmulation ';

            % Create ExportButton_3
            app.ExportButton_3 = uibutton(app.GridLayout2, 'push');
            app.ExportButton_3.ButtonPushedFcn = createCallbackFcn(app, @ExportButton_3Pushed, true);
            app.ExportButton_3.Layout.Row = 3;
            app.ExportButton_3.Layout.Column = 2;
            app.ExportButton_3.Text = 'Export';

            % Create ResultsPanel
            app.ResultsPanel = uipanel(app.GridLayout2);
            app.ResultsPanel.Title = 'Results';
            app.ResultsPanel.Layout.Row = [2 3];
            app.ResultsPanel.Layout.Column = 4;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.ResultsPanel);
            app.GridLayout5.ColumnWidth = {255, '1x', 'fit'};
            app.GridLayout5.RowHeight = {'1x', 'fit', 'fit', 'fit'};
            app.GridLayout5.RowSpacing = 0.499996185302734;
            app.GridLayout5.Padding = [0 0.499996185302734 0 0.499996185302734];

            % Create DealGrovePredictionhrLabel
            app.DealGrovePredictionhrLabel = uilabel(app.GridLayout5);
            app.DealGrovePredictionhrLabel.Layout.Row = 2;
            app.DealGrovePredictionhrLabel.Layout.Column = 1;
            app.DealGrovePredictionhrLabel.Text = '  Deal-Grove Prediction: -- hr';

            % Create MassoudPredictionhrLabel
            app.MassoudPredictionhrLabel = uilabel(app.GridLayout5);
            app.MassoudPredictionhrLabel.Layout.Row = 3;
            app.MassoudPredictionhrLabel.Layout.Column = 1;
            app.MassoudPredictionhrLabel.Text = '  Massoud Prediction: -- hr';

            % Create PercentageDifferenceLabel
            app.PercentageDifferenceLabel = uilabel(app.GridLayout5);
            app.PercentageDifferenceLabel.Layout.Row = 4;
            app.PercentageDifferenceLabel.Layout.Column = 1;
            app.PercentageDifferenceLabel.Text = '  Percentage Difference:  --%';

            % Create InitialOxideThicknessnmEditFieldLabel
            app.InitialOxideThicknessnmEditFieldLabel = uilabel(app.GridLayout);
            app.InitialOxideThicknessnmEditFieldLabel.HorizontalAlignment = 'right';
            app.InitialOxideThicknessnmEditFieldLabel.Layout.Row = 3;
            app.InitialOxideThicknessnmEditFieldLabel.Layout.Column = 1;
            app.InitialOxideThicknessnmEditFieldLabel.Text = 'Initial Oxide Thickness (nm)';

            % Create InitialOxideThicknessnmEditField
            app.InitialOxideThicknessnmEditField = uieditfield(app.GridLayout, 'numeric');
            app.InitialOxideThicknessnmEditField.Limits = [0 500];
            app.InitialOxideThicknessnmEditField.RoundFractionalValues = 'on';
            app.InitialOxideThicknessnmEditField.Layout.Row = 3;
            app.InitialOxideThicknessnmEditField.Layout.Column = 2;

            % Create TypeofSiliconStructureDropDownLabel
            app.TypeofSiliconStructureDropDownLabel = uilabel(app.GridLayout);
            app.TypeofSiliconStructureDropDownLabel.HorizontalAlignment = 'right';
            app.TypeofSiliconStructureDropDownLabel.Layout.Row = 2;
            app.TypeofSiliconStructureDropDownLabel.Layout.Column = [3 4];
            app.TypeofSiliconStructureDropDownLabel.Text = 'Type of Silicon Structure ';

            % Create TypeofSiliconStructureDropDown
            app.TypeofSiliconStructureDropDown = uidropdown(app.GridLayout);
            app.TypeofSiliconStructureDropDown.Items = {'Si (100)', 'Si (111)', 'Si (110)'};
            app.TypeofSiliconStructureDropDown.Layout.Row = 2;
            app.TypeofSiliconStructureDropDown.Layout.Column = 5;
            app.TypeofSiliconStructureDropDown.Value = 'Si (100)';

            % Create TemperatureinCelsiusSpinnerLabel
            app.TemperatureinCelsiusSpinnerLabel = uilabel(app.GridLayout);
            app.TemperatureinCelsiusSpinnerLabel.HorizontalAlignment = 'right';
            app.TemperatureinCelsiusSpinnerLabel.Layout.Row = 2;
            app.TemperatureinCelsiusSpinnerLabel.Layout.Column = 1;
            app.TemperatureinCelsiusSpinnerLabel.Text = 'Temperature in Celsius';

            % Create TemperatureinCelsiusSpinner
            app.TemperatureinCelsiusSpinner = uispinner(app.GridLayout);
            app.TemperatureinCelsiusSpinner.Limits = [800 999.9];
            app.TemperatureinCelsiusSpinner.Layout.Row = 2;
            app.TemperatureinCelsiusSpinner.Layout.Column = 2;
            app.TemperatureinCelsiusSpinner.Value = 800;

            % Create FinalOxideThicknessnmEditFieldLabel
            app.FinalOxideThicknessnmEditFieldLabel = uilabel(app.GridLayout);
            app.FinalOxideThicknessnmEditFieldLabel.HorizontalAlignment = 'right';
            app.FinalOxideThicknessnmEditFieldLabel.Layout.Row = 3;
            app.FinalOxideThicknessnmEditFieldLabel.Layout.Column = [3 4];
            app.FinalOxideThicknessnmEditFieldLabel.Text = 'Final Oxide Thickness (nm)';

            % Create FinalOxideThicknessnmEditField
            app.FinalOxideThicknessnmEditField = uieditfield(app.GridLayout, 'numeric');
            app.FinalOxideThicknessnmEditField.Limits = [0 800];
            app.FinalOxideThicknessnmEditField.Layout.Row = 3;
            app.FinalOxideThicknessnmEditField.Layout.Column = 5;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = NanoSilicon_exported

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