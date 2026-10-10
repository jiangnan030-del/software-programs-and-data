classdef MMCHB_criterion < matlab.apps.AppBase

    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        FileMenu                     matlab.ui.container.Menu
        FileNewMenu                  matlab.ui.container.Menu
        FileOpenMenu                 matlab.ui.container.Menu
        SaveMenu                     matlab.ui.container.Menu
        SaveDataMenu                 matlab.ui.container.Menu
        SaveResultsMenu              matlab.ui.container.Menu
        SaveFigureMainMenu           matlab.ui.container.Menu
        SaveFigureMenu               matlab.ui.container.Menu
        SaveAsPNGMenu                matlab.ui.container.Menu
        SaveAsJPGMenu                matlab.ui.container.Menu
        SaveAsEPSMenu                matlab.ui.container.Menu
        SaveAsPDFMenu                matlab.ui.container.Menu
        SaveAsTIFFMenu               matlab.ui.container.Menu
        SaveAsSVGMenu                matlab.ui.container.Menu
        SaveAsEMFMenu                matlab.ui.container.Menu
        SaveAsFIGMenu                matlab.ui.container.Menu
        CopyToClipboardMenu          matlab.ui.container.Menu
        ExportHighResMenu            matlab.ui.container.Menu
        LanguageMenu                 matlab.ui.container.Menu
        LanguageEnglishMenu          matlab.ui.container.Menu
        LanguageChineseMenu          matlab.ui.container.Menu
        AboutMenu                    matlab.ui.container.Menu
        AboutInfoMenu                matlab.ui.container.Menu
        GridLayout                   matlab.ui.container.GridLayout
        LeftPanel                    matlab.ui.container.Panel
        ParametersPanel              matlab.ui.container.Panel
        mibestEditFieldLabel         matlab.ui.control.Label
        mibestEditField              matlab.ui.control.NumericEditField
        ucsEditFieldLabel            matlab.ui.control.Label
        ucsEditField                 matlab.ui.control.NumericEditField
        PopulationSizeEditFieldLabel matlab.ui.control.Label
        PopulationSizeEditField      matlab.ui.control.NumericEditField
        MaxIterationsEditFieldLabel  matlab.ui.control.Label
        MaxIterationsEditField       matlab.ui.control.NumericEditField
        AlgorithmDropDownLabel       matlab.ui.control.Label
        AlgorithmDropDown            matlab.ui.control.DropDown
        LoadDataButton               matlab.ui.control.Button
        RunOptimizationButton        matlab.ui.control.Button
        ResultsPanel                 matlab.ui.container.Panel
        alphaEditFieldLabel          matlab.ui.control.Label
        alphaEditField               matlab.ui.control.NumericEditField
        gammaEditFieldLabel          matlab.ui.control.Label
        gammaEditField               matlab.ui.control.NumericEditField
        uEditFieldLabel              matlab.ui.control.Label
        uEditField                   matlab.ui.control.NumericEditField
        vEditFieldLabel              matlab.ui.control.Label
        vEditField                   matlab.ui.control.NumericEditField
        BestScoreEditFieldLabel      matlab.ui.control.Label
        BestScoreEditField           matlab.ui.control.NumericEditField
        DataPointsLabel              matlab.ui.control.Label
        VisualizationPanel           matlab.ui.container.Panel
        Generate3DEnvelopeButton     matlab.ui.control.Button
        DeviatoricPlaneButton        matlab.ui.control.Button
        Sigma1Sigma2PlaneButton      matlab.ui.control.Button
        ConvergenceCurvesButton      matlab.ui.control.Button
        ClearVisualizationButton     matlab.ui.control.Button
        ExitButton                   matlab.ui.control.Button
        RightPanel                   matlab.ui.container.Panel
        RightPanelGridLayout         matlab.ui.container.GridLayout
        UIAxes                       matlab.ui.control.UIAxes
        StatusLabel                  matlab.ui.control.Label
        AxesContextMenu              matlab.ui.container.ContextMenu
        ContextSaveFigureMenu        matlab.ui.container.Menu
        ContextSaveAsPNGMenu         matlab.ui.container.Menu
        ContextSaveAsJPGMenu         matlab.ui.container.Menu
        ContextSaveAsEPSMenu         matlab.ui.container.Menu
        ContextSaveAsPDFMenu         matlab.ui.container.Menu
        ContextSaveAsTIFFMenu        matlab.ui.container.Menu
        ContextSaveAsSVGMenu         matlab.ui.container.Menu
        ContextSaveAsEMFMenu         matlab.ui.container.Menu
        ContextSaveAsFIGMenu         matlab.ui.container.Menu
        ContextCopyToClipboardMenu   matlab.ui.container.Menu
        ContextExportHighResMenu     matlab.ui.container.Menu
    end

    properties (Access = private)
        peak
        Best_pos
        Best_score
        CurrentLanguage
        LangStrings
        LastSavePath
        CurrentPlotType
        CurrentParameters
        ConvergenceCurves
        UsedAlgorithm
        BgColor = [0.9020, 0.9333, 0.8824]
    end

    methods (Access = private)
        
        function configPath = getConfigFilePath(~)
            if ispc
                configDir = fullfile(getenv('APPDATA'), 'MMCHB_Criterion');
            elseif ismac
                configDir = fullfile(getenv('HOME'), 'Library', 'Application Support', 'MMCHB_Criterion');
            else
                configDir = fullfile(getenv('HOME'), '.config', 'MMCHB_Criterion');
            end
            
            if ~exist(configDir, 'dir')
                mkdir(configDir);
            end
            
            configPath = fullfile(configDir, 'language_config.mat');
        end
        
        function lang = loadLanguageSetting(app)
            configPath = app.getConfigFilePath();
            if exist(configPath, 'file')
                try
                    data = load(configPath, 'language');
                    lang = data.language;
                catch
                    lang = 'en';
                end
            else
                lang = 'en';
            end
        end
        
        function saveLanguageSetting(app, lang)
            configPath = app.getConfigFilePath();
            language = lang;
            save(configPath, 'language');
        end
        
        function initLanguageStrings(app)
            app.LangStrings.en.AppTitle = 'MMCHB criterion intelligent prediction and analysis system';
            app.LangStrings.en.FileMenu = 'File(F)';
            app.LangStrings.en.FileNew = 'New';
            app.LangStrings.en.FileOpen = 'Open...';
            app.LangStrings.en.SaveMenu = 'Save(S)';
            app.LangStrings.en.SaveData = 'Save Data...';
            app.LangStrings.en.SaveResults = 'Save Results...';
            app.LangStrings.en.SaveFigure = 'Save Figure...';
            app.LangStrings.en.LanguageMenu = 'Language(L)';
            app.LangStrings.en.English = 'English';
            app.LangStrings.en.Chinese = 'Chinese';
            app.LangStrings.en.AboutMenu = 'About(A)';
            app.LangStrings.en.AboutInfo = 'About This Application';
            
            app.LangStrings.en.ControlPanel = 'Control panel';
            app.LangStrings.en.InputParameters = 'Input parameters';
            app.LangStrings.en.PopSize = 'Pop_size';
            app.LangStrings.en.MaxIter = 'Max_iter';
            app.LangStrings.en.Algorithm = 'Algorithm';
            app.LangStrings.en.DataPoints = 'Number of data groups: %d';
            app.LangStrings.en.LoadData = 'Load data';
            app.LangStrings.en.RunOptimization = 'Run algorithm';
            app.LangStrings.en.OptimizationResults = 'Optimization results';
            app.LangStrings.en.VisualizationOptions = 'Visualization options';
            app.LangStrings.en.Generate3DEnvelope = '3D envelope surface';
            app.LangStrings.en.DeviatoricPlane = 'Deviatoric plane';
            app.LangStrings.en.Sigma1Sigma2Plane = 'σ₁-σ₂ plane';
            app.LangStrings.en.ConvergenceCurves = 'Convergence curves';
            app.LangStrings.en.ClearVisualization = 'Clear visualization';
            app.LangStrings.en.Visualization = 'Visualization';
            app.LangStrings.en.Exit = 'Exit system';
            
            app.LangStrings.en.SaveFigureContext = 'Save Figure';
            app.LangStrings.en.SaveAsPNG = 'Save as PNG';
            app.LangStrings.en.SaveAsJPG = 'Save as JPG';
            app.LangStrings.en.SaveAsEPS = 'Save as EPS';
            app.LangStrings.en.SaveAsPDF = 'Save as PDF';
            app.LangStrings.en.SaveAsTIFF = 'Save as TIFF';
            app.LangStrings.en.SaveAsSVG = 'Save as SVG';
            app.LangStrings.en.SaveAsEMF = 'Save as EMF';
            app.LangStrings.en.SaveAsFIG = 'Save as FIG (MATLAB)';
            app.LangStrings.en.CopyToClipboard = 'Copy to Clipboard';
            app.LangStrings.en.ExportHighRes = 'Export High Resolution...';
            
            app.LangStrings.en.StatusReady = 'Ready. Default data loaded (40 points). Click "Load Data" to import custom data.';
            app.LangStrings.en.StatusNewProject = 'New project created. Please load data.';
            app.LangStrings.en.StatusLoadCancelled = 'Data loading cancelled.';
            app.LangStrings.en.StatusDataLoaded = 'Data loaded successfully: %s (%d points)';
            app.LangStrings.en.StatusNoData = 'No data to save.';
            app.LangStrings.en.StatusDataSaved = 'Data saved: %s';
            app.LangStrings.en.StatusNoResults = 'No results to save. Please run optimization first.';
            app.LangStrings.en.StatusResultsSaved = 'Results saved: %s';
            app.LangStrings.en.StatusNoFigure = 'No figure to save. Please generate a plot first.';
            app.LangStrings.en.StatusFigureSaved = 'Figure saved successfully: %s';
            app.LangStrings.en.StatusRunning = 'Running optimization...';
            app.LangStrings.en.StatusCompleted = 'Optimization completed! Best Error: %.4f (Data points: %d)';
            app.LangStrings.en.StatusGenerating3D = 'Generating 3D envelope...';
            app.LangStrings.en.Status3DGenerated = '3D envelope generated successfully!';
            app.LangStrings.en.StatusGeneratingDeviatoric = 'Generating deviatoric plane diagram...';
            app.LangStrings.en.StatusDeviatoricGenerated = 'Deviatoric plane diagram generated successfully!';
            app.LangStrings.en.StatusGeneratingSigma = 'Generating sigma1-sigma2 plane diagram...';
            app.LangStrings.en.StatusSigmaGenerated = 'Sigma1-sigma2 plane diagram generated successfully!';
            app.LangStrings.en.StatusGeneratingConvergence = 'Generating convergence curves...';
            app.LangStrings.en.StatusConvergenceGenerated = 'Convergence curves generated successfully!';
            app.LangStrings.en.StatusCleared = 'Visualization cleared. Ready for new plot.';
            app.LangStrings.en.StatusRunOptFirst = 'Please run optimization first!';
            app.LangStrings.en.StatusSaveCancelled = 'Save cancelled.';
            app.LangStrings.en.StatusCopied = 'Figure copied to clipboard successfully!';
            app.LangStrings.en.StatusExportCancelled = 'Export cancelled.';
            app.LangStrings.en.StatusHighResSaved = 'High resolution figure saved: %s (%d DPI)';
            app.LangStrings.en.StatusInvalidDPI = 'Invalid DPI value.';
            app.LangStrings.en.StatusLangEnglish = 'Language set to English. Please restart the application for full effect.';
            app.LangStrings.en.StatusLangChinese = 'Language set to Chinese. Please restart the application for full effect.';
            app.LangStrings.en.AxesTitle = 'Click visualization button to generate plot';
            app.LangStrings.en.DlgNewProject = 'Create new project? This will clear all current data.';
            app.LangStrings.en.DlgNewProjectTitle = 'New Project';
            app.LangStrings.en.DlgYes = 'Yes';
            app.LangStrings.en.DlgNo = 'No';
            app.LangStrings.en.DlgExitConfirm = 'Are you sure you want to exit the program?';
            app.LangStrings.en.DlgExitTitle = 'Exit confirmation';
            app.LangStrings.en.DlgEnterDPI = 'Enter resolution (DPI):';
            app.LangStrings.en.DlgHighResExport = 'High Resolution Export';
            app.LangStrings.en.DlgSelectFile = 'Select Data File';
            app.LangStrings.en.DlgRestartRequired = 'Language changed. Please restart the application to apply the new language.';
            app.LangStrings.en.DlgRestartTitle = 'Restart Required';
            app.LangStrings.en.AboutMsg1 = 'Solemn declaration: The application (APP) developed based on the MMCHB criterion is intended to provide scholars worldwide with a tool for predicting rock strength!';
            app.LangStrings.en.AboutMsg2 = 'Institution: Faculty of Land Resources Engineering, Kunming University of Science and Technology';
            app.LangStrings.en.AboutMsg3 = 'E-mail: wangjiaxin@kust.edu.cn(Jiaxin Wang)';
            app.LangStrings.en.AboutTitle = 'About';
            app.LangStrings.en.MaterialParam = 'Parameter';
            app.LangStrings.en.PredictionError = 'Error';
            app.LangStrings.en.miLabel = '<html><b>Parameter <i>m</i><sub>i</sub></b></html>';
            app.LangStrings.en.ucsLabel = '<html><b>Parameter σ<sub>c</sub></b></html> (MPa)';
            
            app.LangStrings.zh.AppTitle = 'MMCHB准则智能预测系统';
            app.LangStrings.zh.FileMenu = '文件(F)';
            app.LangStrings.zh.FileNew = '新建';
            app.LangStrings.zh.FileOpen = '打开...';
            app.LangStrings.zh.SaveMenu = '保存(S)';
            app.LangStrings.zh.SaveData = '保存数据...';
            app.LangStrings.zh.SaveResults = '保存结果...';
            app.LangStrings.zh.SaveFigure = '保存图像...';
            app.LangStrings.zh.LanguageMenu = '语言(L)';
            app.LangStrings.zh.English = 'English';
            app.LangStrings.zh.Chinese = '中文';
            app.LangStrings.zh.AboutMenu = '关于(A)';
            app.LangStrings.zh.AboutInfo = '关于本APP程序';
            app.LangStrings.zh.ControlPanel = '控制面板';
            app.LangStrings.zh.InputParameters = '输入参数';
            app.LangStrings.zh.PopSize = '种群大小';
            app.LangStrings.zh.MaxIter = '最大迭代次数';
            app.LangStrings.zh.Algorithm = '智能优化算法';
            app.LangStrings.zh.DataPoints = '数据组数: %d';
            app.LangStrings.zh.LoadData = '导入试验数据';
            app.LangStrings.zh.RunOptimization = '运行优化算法';
            app.LangStrings.zh.OptimizationResults = '优化结果';
            app.LangStrings.zh.VisualizationOptions = '可视化选项';
            app.LangStrings.zh.Generate3DEnvelope = '三维包络面';
            app.LangStrings.zh.DeviatoricPlane = '二维偏平面';
            app.LangStrings.zh.Sigma1Sigma2Plane = '二维σ₁-σ₂ 平面';
            app.LangStrings.zh.ConvergenceCurves = '误差收敛曲线';
            app.LangStrings.zh.ClearVisualization = '清除可视化';
            app.LangStrings.zh.Visualization = '可视化界面';
            app.LangStrings.zh.Exit = '退出预测系统';
            app.LangStrings.zh.SaveFigureContext = '保存图像';
            app.LangStrings.zh.SaveAsPNG = '保存为 PNG';
            app.LangStrings.zh.SaveAsJPG = '保存为 JPG';
            app.LangStrings.zh.SaveAsEPS = '保存为 EPS';
            app.LangStrings.zh.SaveAsPDF = '保存为 PDF';
            app.LangStrings.zh.SaveAsTIFF = '保存为 TIFF';
            app.LangStrings.zh.SaveAsSVG = '保存为 SVG';
            app.LangStrings.zh.SaveAsEMF = '保存为 EMF';
            app.LangStrings.zh.SaveAsFIG = '保存为 FIG (MATLAB)';
            app.LangStrings.zh.CopyToClipboard = '复制到剪贴板';
            app.LangStrings.zh.ExportHighRes = '导出高分辨率...';
            app.LangStrings.zh.StatusReady = '已导入默认数据(40个点),点击"导入数据"导入自定义数据!';
            app.LangStrings.zh.StatusNewProject = '新项目已创建,请导入数据!';
            app.LangStrings.zh.StatusLoadCancelled = '数据导入已取消!';
            app.LangStrings.zh.StatusDataLoaded = '数据导入成功: %s (%d 个点)';
            app.LangStrings.zh.StatusNoData = '没有数据可保存!';
            app.LangStrings.zh.StatusDataSaved = '数据已保存: %s';
            app.LangStrings.zh.StatusNoResults = '没有结果可保存,请先运行优化!';
            app.LangStrings.zh.StatusResultsSaved = '结果已保存: %s';
            app.LangStrings.zh.StatusNoFigure = '没有图像可保存,请先生成图形!';
            app.LangStrings.zh.StatusFigureSaved = '图像保存成功: %s';
            app.LangStrings.zh.StatusRunning = '正在运行算法...';
            app.LangStrings.zh.StatusCompleted = '优化算法已完成!误差: %.4f (数据组数: %d)';
            app.LangStrings.zh.StatusGenerating3D = '正在生成三维破坏包络面...';
            app.LangStrings.zh.Status3DGenerated = '三维破坏包络面生成成功!';
            app.LangStrings.zh.StatusGeneratingDeviatoric = '正在生成二维偏平面图...';
            app.LangStrings.zh.StatusDeviatoricGenerated = '二维偏平面图生成成功!';
            app.LangStrings.zh.StatusGeneratingSigma = '正在生成σ1-σ2平面图...';
            app.LangStrings.zh.StatusSigmaGenerated = 'σ1-σ2平面图生成成功!';
            app.LangStrings.zh.StatusGeneratingConvergence = '正在生成收敛曲线...';
            app.LangStrings.zh.StatusConvergenceGenerated = '收敛曲线生成成功!';
            app.LangStrings.zh.StatusCleared = '可视化已清除,准备生成新图形!';
            app.LangStrings.zh.StatusRunOptFirst = '请先运行优化!';
            app.LangStrings.zh.StatusSaveCancelled = '保存已取消。';
            app.LangStrings.zh.StatusCopied = '图像已成功复制到剪贴板!';
            app.LangStrings.zh.StatusExportCancelled = '导出已取消。';
            app.LangStrings.zh.StatusHighResSaved = '高分辨率图像已保存: %s (%d DPI)';
            app.LangStrings.zh.StatusInvalidDPI = '无效的DPI值。';
            app.LangStrings.zh.StatusLangEnglish = '语言已设置为英文,请重启应用程序以完全生效。';
            app.LangStrings.zh.StatusLangChinese = '语言已设置为中文,请重启应用程序以完全生效。';
            app.LangStrings.zh.AxesTitle = '点击可视化按钮生成图形';
            app.LangStrings.zh.DlgNewProject = '创建新项目?这将清除所有当前数据。';
            app.LangStrings.zh.DlgNewProjectTitle = '新建项目';
            app.LangStrings.zh.DlgYes = '是';
            app.LangStrings.zh.DlgNo = '否';
            app.LangStrings.zh.DlgExitConfirm = '您确认要退出程序吗?';
            app.LangStrings.zh.DlgExitTitle = '退出确认';
            app.LangStrings.zh.DlgEnterDPI = '输入分辨率 (DPI):';
            app.LangStrings.zh.DlgHighResExport = '高分辨率导出';
            app.LangStrings.zh.DlgSelectFile = '选择数据文件';
            app.LangStrings.zh.DlgRestartRequired = '语言已更改,请重启程序以应用新语言。';
            app.LangStrings.zh.DlgRestartTitle = '需要重启';
            app.LangStrings.zh.AboutMsg1 = '声明:基于MMCHB准则开发的智能预测分析系统旨在为全球学者提供一种预测岩石强度的工具!';
            app.LangStrings.zh.AboutMsg2 = '单位:昆明理工大学 国土资源工程学院(深地资源开发与灾害防控创新团队)';
            app.LangStrings.zh.AboutMsg3 = '邮件:wangjiaxin@kust.edu.cn(王佳信)';
            app.LangStrings.zh.AboutTitle = '关于';
            app.LangStrings.zh.MaterialParam = '参数';
            app.LangStrings.zh.PredictionError = '误差';
            app.LangStrings.zh.miLabel = '<html><b>参数 <i>m</i><sub>i</sub></b></html>';
            app.LangStrings.zh.ucsLabel = '<html><b>单轴抗压强度 σ<sub>c</sub></b></html> (MPa)';
        end
        
        function str = getLangString(app, key)
            if strcmp(app.CurrentLanguage, 'zh')
                str = app.LangStrings.zh.(key);
            else
                str = app.LangStrings.en.(key);
            end
        end
        
        function applyLanguage(app)
            app.UIFigure.Name = app.getLangString('AppTitle');
            app.FileMenu.Text = app.getLangString('FileMenu');
            app.FileNewMenu.Text = app.getLangString('FileNew');
            app.FileOpenMenu.Text = app.getLangString('FileOpen');
            app.SaveMenu.Text = app.getLangString('SaveMenu');
            app.SaveDataMenu.Text = app.getLangString('SaveData');
            app.SaveResultsMenu.Text = app.getLangString('SaveResults');
            app.SaveFigureMainMenu.Text = app.getLangString('SaveFigure');
            app.LanguageMenu.Text = app.getLangString('LanguageMenu');
            app.LanguageEnglishMenu.Text = app.getLangString('English');
            app.LanguageChineseMenu.Text = app.getLangString('Chinese');
            app.AboutMenu.Text = app.getLangString('AboutMenu');
            app.AboutInfoMenu.Text = app.getLangString('AboutInfo');
            
            if strcmp(app.CurrentLanguage, 'zh')
                app.LanguageChineseMenu.Checked = 'on';
                app.LanguageEnglishMenu.Checked = 'off';
            else
                app.LanguageEnglishMenu.Checked = 'on';
                app.LanguageChineseMenu.Checked = 'off';
            end
            
            app.LeftPanel.Title = app.getLangString('ControlPanel');
            app.ParametersPanel.Title = app.getLangString('InputParameters');
            app.PopulationSizeEditFieldLabel.Text = app.getLangString('PopSize');
            app.MaxIterationsEditFieldLabel.Text = app.getLangString('MaxIter');
            app.AlgorithmDropDownLabel.Text = app.getLangString('Algorithm');
            app.LoadDataButton.Text = app.getLangString('LoadData');
            app.RunOptimizationButton.Text = app.getLangString('RunOptimization');
            app.ResultsPanel.Title = app.getLangString('OptimizationResults');
            app.VisualizationPanel.Title = app.getLangString('VisualizationOptions');
            app.Generate3DEnvelopeButton.Text = app.getLangString('Generate3DEnvelope');
            app.DeviatoricPlaneButton.Text = app.getLangString('DeviatoricPlane');
            app.Sigma1Sigma2PlaneButton.Text = app.getLangString('Sigma1Sigma2Plane');
            app.ConvergenceCurvesButton.Text = app.getLangString('ConvergenceCurves');
            app.ClearVisualizationButton.Text = app.getLangString('ClearVisualization');
            app.ExitButton.Text = app.getLangString('Exit');
            app.RightPanel.Title = app.getLangString('Visualization');
            app.SaveFigureMenu.Text = app.getLangString('SaveFigureContext');
            app.SaveAsPNGMenu.Text = app.getLangString('SaveAsPNG');
            app.SaveAsJPGMenu.Text = app.getLangString('SaveAsJPG');
            app.SaveAsEPSMenu.Text = app.getLangString('SaveAsEPS');
            app.SaveAsPDFMenu.Text = app.getLangString('SaveAsPDF');
            app.SaveAsTIFFMenu.Text = app.getLangString('SaveAsTIFF');
            app.SaveAsSVGMenu.Text = app.getLangString('SaveAsSVG');
            app.SaveAsEMFMenu.Text = app.getLangString('SaveAsEMF');
            app.SaveAsFIGMenu.Text = app.getLangString('SaveAsFIG');
            app.CopyToClipboardMenu.Text = app.getLangString('CopyToClipboard');
            app.ExportHighResMenu.Text = app.getLangString('ExportHighRes');
            
            app.ContextSaveFigureMenu.Text = app.getLangString('SaveFigureContext');
            app.ContextSaveAsPNGMenu.Text = app.getLangString('SaveAsPNG');
            app.ContextSaveAsJPGMenu.Text = app.getLangString('SaveAsJPG');
            app.ContextSaveAsEPSMenu.Text = app.getLangString('SaveAsEPS');
            app.ContextSaveAsPDFMenu.Text = app.getLangString('SaveAsPDF');
            app.ContextSaveAsTIFFMenu.Text = app.getLangString('SaveAsTIFF');
            app.ContextSaveAsSVGMenu.Text = app.getLangString('SaveAsSVG');
            app.ContextSaveAsEMFMenu.Text = app.getLangString('SaveAsEMF');
            app.ContextSaveAsFIGMenu.Text = app.getLangString('SaveAsFIG');
            app.ContextCopyToClipboardMenu.Text = app.getLangString('CopyToClipboard');
            app.ContextExportHighResMenu.Text = app.getLangString('ExportHighRes');
            
            if ~isempty(app.peak)
                app.DataPointsLabel.Text = sprintf(app.getLangString('DataPoints'), size(app.peak, 1));
            else
                app.DataPointsLabel.Text = sprintf(app.getLangString('DataPoints'), 0);
            end
            app.StatusLabel.Text = app.getLangString('StatusReady');
            
            mp = app.getLangString('MaterialParam');
            pe = app.getLangString('PredictionError');
            app.alphaEditFieldLabel.Text      = ['<html><b>' mp ' <i>α</i></b></html>'];
            app.gammaEditFieldLabel.Text       = ['<html><b>' mp ' <i>γ</i></b></html>'];
            app.uEditFieldLabel.Text           = ['<html><b>' mp ' <i>u</i></b></html>'];
            app.vEditFieldLabel.Text           = ['<html><b>' mp ' <i>v</i></b></html>'];
            app.BestScoreEditFieldLabel.Text   = ['<html><b>' pe ' <i>S</i> (%)</b></html>'];
            app.mibestEditFieldLabel.Text      = app.getLangString('miLabel');
            app.ucsEditFieldLabel.Text         = app.getLangString('ucsLabel');
        end

        function setAxesInitialState(app)
            cla(app.UIAxes, 'reset');
            app.UIAxes.Color = app.BgColor;
            app.UIAxes.XAxis.Visible = 'off';
            app.UIAxes.YAxis.Visible = 'off';
            app.UIAxes.ZAxis.Visible = 'off';
            grid(app.UIAxes, 'off');
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.ZTick = [];
            xlabel(app.UIAxes, '');
            ylabel(app.UIAxes, '');
            zlabel(app.UIAxes, '');
            box(app.UIAxes, 'off');
            title(app.UIAxes, app.getLangString('AxesTitle'), 'FontSize', 15, 'FontName', 'Times New Roman', 'Color', [0.5 0.5 0.5], 'FontWeight', 'normal');
            app.UIAxes.Toolbar.Visible = 'on';
            app.UIAxes.ContextMenu = app.AxesContextMenu;
            app.CurrentPlotType = '';
        end

        function startupFcn(app)
            app.peak = [
                165, 0, 0; 346, 79, 0; 291, 149, 0; 347, 197, 0; 267, 229, 0;
                410, 30, 30; 479, 60, 30; 599, 100, 30; 652, 200, 30; 571, 249, 30;
                637, 298, 30; 702, 60, 60; 750, 88, 60; 766, 103, 60; 745, 155, 60;
                816, 199, 60; 888, 249, 60; 828, 299, 60; 887, 347, 60; 954, 399, 60;
                815, 449, 60; 868, 100, 100; 959, 164, 100; 1001, 199, 100; 945, 248, 100;
                892, 269, 100; 1048, 300, 100; 1058, 349, 100; 1155, 442, 100; 1118, 579, 100;
                1147, 150, 150; 1065, 198, 150; 1112, 199, 150; 1176, 249, 150; 1431, 298, 150;
                1326, 348, 150; 1169, 399, 150; 1284, 448, 150; 1265, 498, 150; 1262, 642, 150
            ];
            app.LastSavePath = pwd;
            app.CurrentPlotType = '';
            app.ConvergenceCurves = [];
            app.UsedAlgorithm = '';
            app.DataPointsLabel.Text = sprintf(app.getLangString('DataPoints'), size(app.peak, 1));
            app.StatusLabel.Text = app.getLangString('StatusReady');
            setAxesInitialState(app);
        end

        function FileNewMenuSelected(app, ~)
            choice = questdlg(app.getLangString('DlgNewProject'), app.getLangString('DlgNewProjectTitle'), app.getLangString('DlgYes'), app.getLangString('DlgNo'), app.getLangString('DlgNo'));
            if strcmp(choice, app.getLangString('DlgYes'))
                app.peak = [];
                app.Best_pos = [];
                app.Best_score = [];
                app.ConvergenceCurves = [];
                app.UsedAlgorithm = '';
                app.alphaEditField.Value = 0;
                app.gammaEditField.Value = 0;
                app.uEditField.Value = 0;
                app.vEditField.Value = 0;
                app.BestScoreEditField.Value = 0;
                app.DataPointsLabel.Text = sprintf(app.getLangString('DataPoints'), 0);
                setAxesInitialState(app);
                app.StatusLabel.Text = app.getLangString('StatusNewProject');
            end
        end

        function FileOpenMenuSelected(app, ~)
            LoadDataButtonPushed(app, []);
        end

        function SaveDataMenuSelected(app, ~)
            if isempty(app.peak)
                app.StatusLabel.Text = app.getLangString('StatusNoData');
                return;
            end
            timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
            defaultName = sprintf('Data_%s.xlsx', timestamp);
            [filename, pathname] = uiputfile({'*.xlsx', 'Excel Files (*.xlsx)'; '*.csv', 'CSV Files (*.csv)'}, app.getLangString('SaveData'), fullfile(app.LastSavePath, defaultName));
            if ~isequal(filename, 0)
                fullpath = fullfile(pathname, filename);
                app.LastSavePath = pathname;
                writematrix(app.peak, fullpath);
                app.StatusLabel.Text = sprintf(app.getLangString('StatusDataSaved'), filename);
            end
        end

        function SaveResultsMenuSelected(app, ~)
            if isempty(app.Best_pos)
                app.StatusLabel.Text = app.getLangString('StatusNoResults');
                return;
            end
            timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
            defaultName = sprintf('Results_%s.txt', timestamp);
            [filename, pathname] = uiputfile({'*.txt', 'Text Files (*.txt)'; '*.xlsx', 'Excel Files (*.xlsx)'}, app.getLangString('SaveResults'), fullfile(app.LastSavePath, defaultName));
            if ~isequal(filename, 0)
                fullpath = fullfile(pathname, filename);
                app.LastSavePath = pathname;
                [~, ~, ext] = fileparts(filename);
                if strcmpi(ext, '.txt')
                    fid = fopen(fullpath, 'w');
                    fprintf(fid, 'MMCHB Criterion Optimization Results\n');
                    fprintf(fid, '=====================================\n\n');
                    fprintf(fid, 'Input Parameters:\n');
                    fprintf(fid, '  mi = %.4f\n', app.mibestEditField.Value);
                    fprintf(fid, '  UCS = %.4f MPa\n\n', app.ucsEditField.Value);
                    fprintf(fid, 'Optimization Results:\n');
                    mp = app.getLangString('MaterialParam');
                    pe = app.getLangString('PredictionError');
                    fprintf(fid, ['  ' mp ' alpha = %.6f\n'], app.Best_pos(1));
                    fprintf(fid, ['  ' mp ' gamma = %.6f\n'], app.Best_pos(2));
                    fprintf(fid, ['  ' mp ' u = %.6f\n'], app.Best_pos(3));
                    fprintf(fid, ['  ' mp ' v = %.6f\n'], app.Best_pos(4));
                    fprintf(fid, ['  ' pe ' S = %.6f %%\n'], app.Best_score);
                    fclose(fid);
                else
                    mp = app.getLangString('MaterialParam');
                    pe = app.getLangString('PredictionError');
                    results = {'Parameter', 'Value'; 'mi', app.mibestEditField.Value; 'UCS (MPa)', app.ucsEditField.Value; [mp ' alpha'], app.Best_pos(1); [mp ' gamma'], app.Best_pos(2); [mp ' u'], app.Best_pos(3); [mp ' v'], app.Best_pos(4); [pe ' S (%)'], app.Best_score};
                    writecell(results, fullpath);
                end
                app.StatusLabel.Text = sprintf(app.getLangString('StatusResultsSaved'), filename);
            end
        end

        function LanguageEnglishMenuSelected(app, ~)
            app.LanguageEnglishMenu.Checked = 'on';
            app.LanguageChineseMenu.Checked = 'off';
            app.CurrentLanguage = 'en';
            app.saveLanguageSetting('en');
            app.applyLanguage();
            app.StatusLabel.Text = app.getLangString('StatusLangEnglish');
            uialert(app.UIFigure, app.getLangString('DlgRestartRequired'), app.getLangString('DlgRestartTitle'), 'Icon', 'info');
        end

        function LanguageChineseMenuSelected(app, ~)
            app.LanguageEnglishMenu.Checked = 'off';
            app.LanguageChineseMenu.Checked = 'on';
            app.CurrentLanguage = 'zh';
            app.saveLanguageSetting('zh');
            app.applyLanguage();
            app.StatusLabel.Text = app.getLangString('StatusLangChinese');
            uialert(app.UIFigure, app.getLangString('DlgRestartRequired'), app.getLangString('DlgRestartTitle'), 'Icon', 'info');
        end

        function AboutInfoMenuSelected(app, ~)
            msg = {app.getLangString('AboutMsg1'), '', app.getLangString('AboutMsg2'), '', app.getLangString('AboutMsg3')};
            uialert(app.UIFigure, msg, app.getLangString('AboutTitle'), 'Icon', 'info');
        end

        function LoadDataButtonPushed(app, ~)
            try
                [file, path] = uigetfile({'*.xlsx;*.xls', 'Excel Files (*.xlsx, *.xls)'; '*.csv', 'CSV Files (*.csv)'; '*.txt', 'Text Files (*.txt)'; '*.*', 'All Files (*.*)'}, app.getLangString('DlgSelectFile'), app.LastSavePath);
                
                if isequal(file, 0)
                    app.StatusLabel.Text = app.getLangString('StatusLoadCancelled');
                    return;
                end
                
                fullpath = fullfile(path, file);
                app.LastSavePath = path;
                [~, ~, ext] = fileparts(file);
                
                if strcmpi(ext, '.xlsx') || strcmpi(ext, '.xls')
                    data = readmatrix(fullpath);
                elseif strcmpi(ext, '.csv') || strcmpi(ext, '.txt')
                    data = readmatrix(fullpath);
                else
                    data = readmatrix(fullpath);
                end
                
                if size(data, 2) ~= 3
                    error('Data must have exactly 3 columns (sigma1, sigma2, sigma3)');
                end
                if size(data, 1) < 3
                    error('Data must have at least 3 rows');
                end
                
                app.peak = data;
                app.DataPointsLabel.Text = sprintf(app.getLangString('DataPoints'), size(app.peak, 1));
                app.StatusLabel.Text = sprintf(app.getLangString('StatusDataLoaded'), file, size(app.peak, 1));
                
                app.Best_pos = [];
                app.Best_score = [];
                app.ConvergenceCurves = [];
                app.UsedAlgorithm = '';
                app.alphaEditField.Value = 0;
                app.gammaEditField.Value = 0;
                app.uEditField.Value = 0;
                app.vEditField.Value = 0;
                app.BestScoreEditField.Value = 0;
                
            catch ME
                app.StatusLabel.Text = ['Error loading data: ' ME.message];
            end
        end

        function RunOptimizationButtonPushed(app, ~)
            app.StatusLabel.Text = app.getLangString('StatusRunning');
            drawnow;
            
            pop_size = app.PopulationSizeEditField.Value;
            max_iter = app.MaxIterationsEditField.Value;
            mi_best = app.mibestEditField.Value;
            ucs = app.ucsEditField.Value;
            
            lower_bound = [1, 0, 1, 1];
            upper_bound = [1, 1, 4, 4];
            variables_no = 4;
            fobj = @(x)fitness_function(app, x, mi_best, ucs);
            
            algorithm = app.AlgorithmDropDown.Value;
            app.UsedAlgorithm = algorithm;
            
            try
                [DBO_score, DBO_pos, DBO_curve] = DBO_algorithm(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj);
                [PSO_score, PSO_pos, PSO_curve] = PSO_algorithm(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj);
                [SSA_score, SSA_pos, SSA_curve] = SSA_algorithm(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj);
                [HHO_score, HHO_pos, HHO_curve] = HHO_algorithm(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj);
                [SABO_score, SABO_pos, SABO_curve] = SABO_algorithm(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj);
                [POA_score, POA_pos, POA_curve] = POA_algorithm(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj);
                
                app.ConvergenceCurves = struct(...
                    'DBO', DBO_curve, ...
                    'PSO', PSO_curve, ...
                    'SSA', SSA_curve, ...
                    'HHO', HHO_curve, ...
                    'SABO', SABO_curve, ...
                    'POA', POA_curve ...
                );
                
                switch algorithm
                    case 'DBO'
                        app.Best_score = DBO_score;
                        app.Best_pos = DBO_pos;
                    case 'PSO'
                        app.Best_score = PSO_score;
                        app.Best_pos = PSO_pos;
                    case 'SSA'
                        app.Best_score = SSA_score;
                        app.Best_pos = SSA_pos;
                    case 'HHO'
                        app.Best_score = HHO_score;
                        app.Best_pos = HHO_pos;
                    case 'SABO'
                        app.Best_score = SABO_score;
                        app.Best_pos = SABO_pos;
                    case 'POA'
                        app.Best_score = POA_score;
                        app.Best_pos = POA_pos;
                    case 'GWO'
                        [GWO_score, GWO_pos, GWO_curve] = GWO_algorithm(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj);
                        app.ConvergenceCurves.GWO = GWO_curve;
                        app.Best_score = GWO_score;
                        app.Best_pos = GWO_pos;
                end
                
                app.alphaEditField.Value = app.Best_pos(1);
                app.gammaEditField.Value = app.Best_pos(2);
                app.uEditField.Value = app.Best_pos(3);
                app.vEditField.Value = app.Best_pos(4);
                app.BestScoreEditField.Value = app.Best_score;
                
                app.StatusLabel.Text = sprintf(app.getLangString('StatusCompleted'), app.Best_score, size(app.peak, 1));
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function Generate3DEnvelopeButtonPushed(app, ~)
            if isempty(app.Best_pos)
                app.StatusLabel.Text = app.getLangString('StatusRunOptFirst');
                return;
            end
            
            app.StatusLabel.Text = app.getLangString('StatusGenerating3D');
            drawnow;
            
            alpha = app.alphaEditField.Value;
            gamma = app.gammaEditField.Value;
            u = app.uEditField.Value;
            v = app.vEditField.Value;
            mi_best = app.mibestEditField.Value;
            ucs = app.ucsEditField.Value;
            
            try
                plot_3d_surface_in_axes(app.UIAxes, alpha, gamma, u, v, app.peak, mi_best, ucs);
                app.CurrentPlotType = '3d';
                app.CurrentParameters = struct('alpha', alpha, 'gamma', gamma, 'u', u, 'v', v, 'mi_best', mi_best, 'ucs', ucs);
                app.StatusLabel.Text = app.getLangString('Status3DGenerated');
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function DeviatoricPlaneButtonPushed(app, ~)
            if isempty(app.Best_pos)
                app.StatusLabel.Text = app.getLangString('StatusRunOptFirst');
                return;
            end
            
            app.StatusLabel.Text = app.getLangString('StatusGeneratingDeviatoric');
            drawnow;
            
            alpha = app.alphaEditField.Value;
            gamma = app.gammaEditField.Value;
            u = app.uEditField.Value;
            v = app.vEditField.Value;
            mi_best = app.mibestEditField.Value;
            ucs = app.ucsEditField.Value;
            
            try
                plot_polar_diagram_enhanced(app.UIAxes, alpha, gamma, u, v, app.peak, mi_best, ucs);
                app.CurrentPlotType = 'polar';
                app.CurrentParameters = struct('alpha', alpha, 'gamma', gamma, 'u', u, 'v', v, 'mi_best', mi_best, 'ucs', ucs);
                app.StatusLabel.Text = app.getLangString('StatusDeviatoricGenerated');
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function Sigma1Sigma2PlaneButtonPushed(app, ~)
            if isempty(app.Best_pos)
                app.StatusLabel.Text = app.getLangString('StatusRunOptFirst');
                return;
            end
            
            app.StatusLabel.Text = app.getLangString('StatusGeneratingSigma');
            drawnow;
            
            alpha = app.alphaEditField.Value;
            gamma = app.gammaEditField.Value;
            u = app.uEditField.Value;
            v = app.vEditField.Value;
            mi_best = app.mibestEditField.Value;
            ucs = app.ucsEditField.Value;
            
            try
                plot_sigma1_sigma2_plane(app.UIAxes, alpha, gamma, u, v, app.peak, mi_best, ucs);
                app.CurrentPlotType = 'sigma';
                app.CurrentParameters = struct('alpha', alpha, 'gamma', gamma, 'u', u, 'v', v, 'mi_best', mi_best, 'ucs', ucs);
                app.StatusLabel.Text = app.getLangString('StatusSigmaGenerated');
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function ConvergenceCurvesButtonPushed(app, ~)
            if isempty(app.ConvergenceCurves)
                app.StatusLabel.Text = app.getLangString('StatusRunOptFirst');
                return;
            end
            
            app.StatusLabel.Text = app.getLangString('StatusGeneratingConvergence');
            drawnow;
            
            try
                plot_convergence_curves(app.UIAxes, app.ConvergenceCurves, app.MaxIterationsEditField.Value);
                app.CurrentPlotType = 'convergence';
                app.CurrentParameters = struct('curves', app.ConvergenceCurves, 'max_iter', app.MaxIterationsEditField.Value);
                app.StatusLabel.Text = app.getLangString('StatusConvergenceGenerated');
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function ClearVisualizationButtonPushed(app, ~)
            setAxesInitialState(app);
            app.StatusLabel.Text = app.getLangString('StatusCleared');
        end

        function ExitButtonPushed(app, ~)
            choice = questdlg(app.getLangString('DlgExitConfirm'), app.getLangString('DlgExitTitle'), app.getLangString('DlgYes'), app.getLangString('DlgNo'), app.getLangString('DlgNo'));
            if strcmp(choice, app.getLangString('DlgYes'))
                delete(app);
            end
        end

        function SaveAsPNGMenuSelected(app, ~)
            saveFigureWithFormat(app, 'png');
        end

        function SaveAsJPGMenuSelected(app, ~)
            saveFigureWithFormat(app, 'jpg');
        end

        function SaveAsEPSMenuSelected(app, ~)
            saveFigureWithFormat(app, 'eps');
        end

        function SaveAsPDFMenuSelected(app, ~)
            saveFigureWithFormat(app, 'pdf');
        end

        function SaveAsTIFFMenuSelected(app, ~)
            saveFigureWithFormat(app, 'tiff');
        end

        function SaveAsSVGMenuSelected(app, ~)
            saveFigureWithFormat(app, 'svg');
        end

        function SaveAsEMFMenuSelected(app, ~)
            saveFigureWithFormat(app, 'emf');
        end

        function SaveAsFIGMenuSelected(app, ~)
            saveFigureAsFIG(app);
        end

        function CopyToClipboardMenuSelected(app, ~)
            copyAxesToClipboard(app);
        end

        function ExportHighResMenuSelected(app, ~)
            exportHighResolution(app);
        end

        function ContextSaveAsPNGMenuSelected(app, ~)
            saveFigureWithFormat(app, 'png');
        end

        function ContextSaveAsJPGMenuSelected(app, ~)
            saveFigureWithFormat(app, 'jpg');
        end

        function ContextSaveAsEPSMenuSelected(app, ~)
            saveFigureWithFormat(app, 'eps');
        end

        function ContextSaveAsPDFMenuSelected(app, ~)
            saveFigureWithFormat(app, 'pdf');
        end

        function ContextSaveAsTIFFMenuSelected(app, ~)
            saveFigureWithFormat(app, 'tiff');
        end

        function ContextSaveAsSVGMenuSelected(app, ~)
            saveFigureWithFormat(app, 'svg');
        end

        function ContextSaveAsEMFMenuSelected(app, ~)
            saveFigureWithFormat(app, 'emf');
        end

        function ContextSaveAsFIGMenuSelected(app, ~)
            saveFigureAsFIG(app);
        end

        function ContextCopyToClipboardMenuSelected(app, ~)
            copyAxesToClipboard(app);
        end

        function ContextExportHighResMenuSelected(app, ~)
            exportHighResolution(app);
        end

        function saveFigureWithFormat(app, format)
            try
                if isempty(app.UIAxes.Children) || isempty(app.CurrentPlotType)
                    app.StatusLabel.Text = app.getLangString('StatusNoFigure');
                    return;
                end
                
                switch format
                    case 'png', ext = '.png';
                    case 'jpg', ext = '.jpg';
                    case 'eps', ext = '.eps';
                    case 'pdf', ext = '.pdf';
                    case 'tiff', ext = '.tiff';
                    case 'svg', ext = '.svg';
                    case 'emf', ext = '.emf';
                    otherwise, ext = '.png';
                end
                
                timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
                defaultName = sprintf('Figure_%s%s', timestamp, ext);
                filterSpec = {['*' ext], [format ' Files (*' ext ')']};
                [filename, pathname] = uiputfile(filterSpec, app.getLangString('SaveFigure'), fullfile(app.LastSavePath, defaultName));
                
                if isequal(filename, 0)
                    app.StatusLabel.Text = app.getLangString('StatusSaveCancelled');
                    return;
                end
                
                fullpath = fullfile(pathname, filename);
                app.LastSavePath = pathname;
                
                tempFig = figure('Visible', 'off', 'Position', [100, 100, 1400, 1050]);
                tempAx = axes(tempFig, 'Position', [0.1, 0.1, 0.8, 0.8]);
                
                params = app.CurrentParameters;
                switch app.CurrentPlotType
                    case '3d'
                        plot_3d_surface_in_axes(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'polar'
                        plot_polar_diagram_enhanced(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'sigma'
                        plot_sigma1_sigma2_plane(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'convergence'
                        plot_convergence_curves(tempAx, params.curves, params.max_iter);
                end
                
                drawnow(tempFig);
                
                switch format
                    case 'png'
                        print(tempFig, fullpath, '-dpng', '-r300', '-opengl');
                    case 'jpg'
                        print(tempFig, fullpath, '-djpeg', '-r300', '-opengl');
                    case 'eps'
                        print(tempFig, fullpath, '-depsc', '-r300', '-painters');
                    case 'pdf'
                        print(tempFig, fullpath, '-dpdf', '-r300', '-painters');
                    case 'tiff'
                        print(tempFig, fullpath, '-dtiff', '-r300', '-opengl');
                    case 'svg'
                        print(tempFig, fullpath, '-dsvg', '-r300', '-vector');
                    case 'emf'
                        print(tempFig, fullpath, '-dmeta', '-r300');
                end
                
                close(tempFig);
                app.StatusLabel.Text = sprintf(app.getLangString('StatusFigureSaved'), filename);
                
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function saveFigureAsFIG(app)
            try
                if isempty(app.UIAxes.Children) || isempty(app.CurrentPlotType)
                    app.StatusLabel.Text = app.getLangString('StatusNoFigure');
                    return;
                end
                
                timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
                defaultName = sprintf('Figure_%s.fig', timestamp);
                [filename, pathname] = uiputfile('*.fig', app.getLangString('SaveFigure'), fullfile(app.LastSavePath, defaultName));
                
                if isequal(filename, 0)
                    app.StatusLabel.Text = app.getLangString('StatusSaveCancelled');
                    return;
                end
                
                fullpath = fullfile(pathname, filename);
                app.LastSavePath = pathname;
                
                tempFig = figure('Visible', 'off', 'Position', [100, 100, 1400, 1050]);
                tempAx = axes(tempFig, 'Position', [0.1, 0.1, 0.8, 0.8]);
                
                params = app.CurrentParameters;
                switch app.CurrentPlotType
                    case '3d'
                        plot_3d_surface_in_axes(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'polar'
                        plot_polar_diagram_enhanced(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'sigma'
                        plot_sigma1_sigma2_plane(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'convergence'
                        plot_convergence_curves(tempAx, params.curves, params.max_iter);
                end
                
                drawnow(tempFig);
                savefig(tempFig, fullpath);
                close(tempFig);
                app.StatusLabel.Text = sprintf(app.getLangString('StatusFigureSaved'), filename);
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function copyAxesToClipboard(app)
            try
                if isempty(app.UIAxes.Children) || isempty(app.CurrentPlotType)
                    app.StatusLabel.Text = app.getLangString('StatusNoFigure');
                    return;
                end
                
                tempFig = figure('Visible', 'off', 'Position', [100, 100, 1400, 1050]);
                tempAx = axes(tempFig, 'Position', [0.1, 0.1, 0.8, 0.8]);
                
                params = app.CurrentParameters;
                switch app.CurrentPlotType
                    case '3d'
                        plot_3d_surface_in_axes(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'polar'
                        plot_polar_diagram_enhanced(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'sigma'
                        plot_sigma1_sigma2_plane(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'convergence'
                        plot_convergence_curves(tempAx, params.curves, params.max_iter);
                end
                
                drawnow(tempFig);
                print(tempFig, '-clipboard', '-dmeta');
                close(tempFig);
                app.StatusLabel.Text = app.getLangString('StatusCopied');
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function exportHighResolution(app)
            try
                if isempty(app.UIAxes.Children) || isempty(app.CurrentPlotType)
                    app.StatusLabel.Text = app.getLangString('StatusNoFigure');
                    return;
                end
                
                answer = inputdlg({app.getLangString('DlgEnterDPI')}, app.getLangString('DlgHighResExport'), 1, {'600'});
                if isempty(answer)
                    app.StatusLabel.Text = app.getLangString('StatusExportCancelled');
                    return;
                end
                
                dpi = str2double(answer{1});
                if isnan(dpi) || dpi <= 0
                    app.StatusLabel.Text = app.getLangString('StatusInvalidDPI');
                    return;
                end
                
                timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
                defaultName = sprintf('Figure_HighRes_%s.png', timestamp);
                [filename, pathname] = uiputfile({'*.png', 'PNG Image (*.png)'; '*.tiff', 'TIFF Image (*.tiff)'; '*.jpg', 'JPEG Image (*.jpg)'}, app.getLangString('ExportHighRes'), fullfile(app.LastSavePath, defaultName));
                
                if isequal(filename, 0)
                    app.StatusLabel.Text = app.getLangString('StatusExportCancelled');
                    return;
                end
                
                fullpath = fullfile(pathname, filename);
                app.LastSavePath = pathname;
                [~, ~, ext] = fileparts(filename);
                
                tempFig = figure('Visible', 'off', 'Position', [100, 100, 1600, 1200]);
                tempAx = axes(tempFig, 'Position', [0.1, 0.1, 0.8, 0.8]);
                
                params = app.CurrentParameters;
                switch app.CurrentPlotType
                    case '3d'
                        plot_3d_surface_in_axes(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'polar'
                        plot_polar_diagram_enhanced(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'sigma'
                        plot_sigma1_sigma2_plane(tempAx, params.alpha, params.gamma, params.u, params.v, app.peak, params.mi_best, params.ucs);
                    case 'convergence'
                        plot_convergence_curves(tempAx, params.curves, params.max_iter);
                end
                
                drawnow(tempFig);
                
                if strcmpi(ext, '.png')
                    print(tempFig, fullpath, '-dpng', sprintf('-r%d', dpi), '-opengl');
                elseif strcmpi(ext, '.tiff')
                    print(tempFig, fullpath, '-dtiff', sprintf('-r%d', dpi), '-opengl');
                elseif strcmpi(ext, '.jpg')
                    print(tempFig, fullpath, '-djpeg', sprintf('-r%d', dpi), '-opengl');
                end
                
                close(tempFig);
                app.StatusLabel.Text = sprintf(app.getLangString('StatusHighResSaved'), filename, dpi);
            catch ME
                app.StatusLabel.Text = ['Error: ' ME.message];
            end
        end

        function err = fitness_function(app, x, mi_best, ucs)
            sigma1 = app.peak(:,1);
            sigma2 = app.peak(:,2);
            sigma3 = app.peak(:,3);
            n_data = size(app.peak, 1);
            
            I1 = sigma1 + sigma2 + sigma3;
            sqrtJ2 = sqrt(((sigma1-sigma2).^2 + (sigma1-sigma3).^2 + (sigma2-sigma3).^2)/6);
            theta = atan((sqrt(3)*(sigma2-sigma3))./(2*sigma1-sigma2-sigma3));
            
            alpha = x(1); gamma = x(2); u = x(3); v = x(4);
            
            sqrtJ2_pre = zeros(n_data, 1);
            for i = 1:n_data
                f1 = (-mi_best*ucs + sqrt((mi_best*ucs)^2 + 12*mi_best*ucs*I1(i) + 36*ucs^2))/(6*sqrt(3));
                f2 = (-sin((alpha*pi/6 + pi + (acos(gamma)/3))))^(1/u) / (sin((alpha*pi/6 + (acos(gamma*cos(3*theta(i)))/3))))^(1/v);
                sqrtJ2_pre(i,1) = f1 * f2;
            end
            
            a1 = mean(sqrtJ2);
            err = sum((sqrtJ2 - sqrtJ2_pre).^2)/n_data;
            err = sqrt(err)/a1*100;
        end
    end

    methods (Access = private)
        function createComponents(app)
            app.initLanguageStrings();
            app.CurrentLanguage = app.loadLanguageSetting();
            app.LastSavePath = pwd;
            app.CurrentPlotType = '';
            
            bgCol = app.BgColor;
            btnCol = [0.1922, 0.5216, 0.6118];
            
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1400 800];
            app.UIFigure.Name = app.getLangString('AppTitle');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = bgCol;
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % ==================== 菜单栏 ====================
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = app.getLangString('FileMenu');
            
            app.FileNewMenu = uimenu(app.FileMenu);
            app.FileNewMenu.Text = app.getLangString('FileNew');
            app.FileNewMenu.Accelerator = 'N';
            app.FileNewMenu.MenuSelectedFcn = createCallbackFcn(app, @FileNewMenuSelected, true);
            
            app.FileOpenMenu = uimenu(app.FileMenu);
            app.FileOpenMenu.Text = app.getLangString('FileOpen');
            app.FileOpenMenu.Accelerator = 'O';
            app.FileOpenMenu.MenuSelectedFcn = createCallbackFcn(app, @FileOpenMenuSelected, true);

            app.SaveMenu = uimenu(app.UIFigure);
            app.SaveMenu.Text = app.getLangString('SaveMenu');
            
            app.SaveDataMenu = uimenu(app.SaveMenu);
            app.SaveDataMenu.Text = app.getLangString('SaveData');
            app.SaveDataMenu.Accelerator = 'D';
            app.SaveDataMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveDataMenuSelected, true);
            
            app.SaveResultsMenu = uimenu(app.SaveMenu);
            app.SaveResultsMenu.Text = app.getLangString('SaveResults');
            app.SaveResultsMenu.Accelerator = 'R';
            app.SaveResultsMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveResultsMenuSelected, true);
            
            app.SaveFigureMainMenu = uimenu(app.SaveMenu);
            app.SaveFigureMainMenu.Text = app.getLangString('SaveFigure');
            app.SaveFigureMainMenu.Accelerator = 'F';
            
            app.SaveFigureMenu = uimenu(app.SaveFigureMainMenu);
            app.SaveFigureMenu.Text = app.getLangString('SaveFigureContext');
            
            app.SaveAsPNGMenu = uimenu(app.SaveFigureMenu);
            app.SaveAsPNGMenu.Text = app.getLangString('SaveAsPNG');
            app.SaveAsPNGMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsPNGMenuSelected, true);
            
            app.SaveAsJPGMenu = uimenu(app.SaveFigureMenu);
            app.SaveAsJPGMenu.Text = app.getLangString('SaveAsJPG');
            app.SaveAsJPGMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsJPGMenuSelected, true);
            
            app.SaveAsEPSMenu = uimenu(app.SaveFigureMenu);
            app.SaveAsEPSMenu.Text = app.getLangString('SaveAsEPS');
            app.SaveAsEPSMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsEPSMenuSelected, true);
            
            app.SaveAsPDFMenu = uimenu(app.SaveFigureMenu);
            app.SaveAsPDFMenu.Text = app.getLangString('SaveAsPDF');
            app.SaveAsPDFMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsPDFMenuSelected, true);
            
            app.SaveAsTIFFMenu = uimenu(app.SaveFigureMenu);
            app.SaveAsTIFFMenu.Text = app.getLangString('SaveAsTIFF');
            app.SaveAsTIFFMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsTIFFMenuSelected, true);
            
            app.SaveAsSVGMenu = uimenu(app.SaveFigureMenu);
            app.SaveAsSVGMenu.Text = app.getLangString('SaveAsSVG');
            app.SaveAsSVGMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsSVGMenuSelected, true);
            
            app.SaveAsEMFMenu = uimenu(app.SaveFigureMenu);
            app.SaveAsEMFMenu.Text = app.getLangString('SaveAsEMF');
            app.SaveAsEMFMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsEMFMenuSelected, true);
            
            app.SaveAsFIGMenu = uimenu(app.SaveFigureMenu);
            app.SaveAsFIGMenu.Text = app.getLangString('SaveAsFIG');
            app.SaveAsFIGMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsFIGMenuSelected, true);
            
            app.CopyToClipboardMenu = uimenu(app.SaveFigureMainMenu);
            app.CopyToClipboardMenu.Separator = 'on';
            app.CopyToClipboardMenu.Text = app.getLangString('CopyToClipboard');
            app.CopyToClipboardMenu.MenuSelectedFcn = createCallbackFcn(app, @CopyToClipboardMenuSelected, true);
            
            app.ExportHighResMenu = uimenu(app.SaveFigureMainMenu);
            app.ExportHighResMenu.Text = app.getLangString('ExportHighRes');
            app.ExportHighResMenu.MenuSelectedFcn = createCallbackFcn(app, @ExportHighResMenuSelected, true);

            app.LanguageMenu = uimenu(app.UIFigure);
            app.LanguageMenu.Text = app.getLangString('LanguageMenu');
            
            app.LanguageEnglishMenu = uimenu(app.LanguageMenu);
            app.LanguageEnglishMenu.Text = app.getLangString('English');
            if strcmp(app.CurrentLanguage, 'en')
                app.LanguageEnglishMenu.Checked = 'on';
            else
                app.LanguageEnglishMenu.Checked = 'off';
            end
            app.LanguageEnglishMenu.MenuSelectedFcn = createCallbackFcn(app, @LanguageEnglishMenuSelected, true);
            
            app.LanguageChineseMenu = uimenu(app.LanguageMenu);
            app.LanguageChineseMenu.Text = app.getLangString('Chinese');
            if strcmp(app.CurrentLanguage, 'zh')
                app.LanguageChineseMenu.Checked = 'on';
            else
                app.LanguageChineseMenu.Checked = 'off';
            end
            app.LanguageChineseMenu.MenuSelectedFcn = createCallbackFcn(app, @LanguageChineseMenuSelected, true);

            app.AboutMenu = uimenu(app.UIFigure);
            app.AboutMenu.Text = app.getLangString('AboutMenu');
            
            app.AboutInfoMenu = uimenu(app.AboutMenu);
            app.AboutInfoMenu.Text = app.getLangString('AboutInfo');
            app.AboutInfoMenu.MenuSelectedFcn = createCallbackFcn(app, @AboutInfoMenuSelected, true);

            % ==================== 主布局 ====================
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {360, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.BackgroundColor = bgCol;

            % ==================== 左面板 ====================
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Title = app.getLangString('ControlPanel');
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
            app.LeftPanel.FontWeight = 'bold';
            app.LeftPanel.FontSize = 15;
            app.LeftPanel.FontName = 'Times New Roman';
            app.LeftPanel.BackgroundColor = bgCol;

            % ==================== 输入参数面板 ====================
            app.ParametersPanel = uipanel(app.LeftPanel);
            app.ParametersPanel.Title = app.getLangString('InputParameters');
            app.ParametersPanel.Position = [10 506 340 244];
            app.ParametersPanel.FontWeight = 'bold';
            app.ParametersPanel.FontSize = 15;
            app.ParametersPanel.FontName = 'Times New Roman';
            app.ParametersPanel.BackgroundColor = bgCol;

            app.mibestEditFieldLabel = uilabel(app.ParametersPanel);
            app.mibestEditFieldLabel.Position = [20 185 175 22];
            app.mibestEditFieldLabel.Interpreter = 'html';
            app.mibestEditFieldLabel.Text = app.getLangString('miLabel');
            app.mibestEditFieldLabel.FontWeight = 'bold';
            app.mibestEditFieldLabel.FontSize = 15;
            app.mibestEditFieldLabel.FontName = 'Times New Roman';
            app.mibestEditFieldLabel.BackgroundColor = bgCol;
           
            app.mibestEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.mibestEditField.Position = [220 185 105 22];
            app.mibestEditField.Value = 33.28;
            app.mibestEditField.HorizontalAlignment = 'center';
            app.mibestEditField.FontName = 'Times New Roman';
            app.mibestEditField.FontSize = 15;
            app.mibestEditField.FontWeight = 'bold';
            app.mibestEditField.BackgroundColor = bgCol;

            app.ucsEditFieldLabel = uilabel(app.ParametersPanel);
            app.ucsEditFieldLabel.Position = [20 150 195 22];
            app.ucsEditFieldLabel.Interpreter = 'html';
            app.ucsEditFieldLabel.Text = app.getLangString('ucsLabel');
            app.ucsEditFieldLabel.FontWeight = 'bold';
            app.ucsEditFieldLabel.FontSize = 15;
            app.ucsEditFieldLabel.FontName = 'Times New Roman';
            app.ucsEditFieldLabel.BackgroundColor = bgCol;

            app.ucsEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.ucsEditField.Position = [220 150 105 22];
            app.ucsEditField.Value = 175;
            app.ucsEditField.HorizontalAlignment = 'center';
            app.ucsEditField.FontName = 'Times New Roman';
            app.ucsEditField.FontSize = 15;
            app.ucsEditField.FontWeight = 'bold';
            app.ucsEditField.BackgroundColor = bgCol;

            app.PopulationSizeEditFieldLabel = uilabel(app.ParametersPanel);
            app.PopulationSizeEditFieldLabel.Position = [20 115 175 22];
            app.PopulationSizeEditFieldLabel.Text = app.getLangString('PopSize');
            app.PopulationSizeEditFieldLabel.FontWeight = 'bold';
            app.PopulationSizeEditFieldLabel.FontSize = 15;
            app.PopulationSizeEditFieldLabel.FontName = 'Times New Roman';
            app.PopulationSizeEditFieldLabel.BackgroundColor = bgCol;

            app.PopulationSizeEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.PopulationSizeEditField.Position = [220 115 105 22];
            app.PopulationSizeEditField.Value = 30;
            app.PopulationSizeEditField.Limits = [10 200];
            app.PopulationSizeEditField.HorizontalAlignment = 'center';
            app.PopulationSizeEditField.FontName = 'Times New Roman';
            app.PopulationSizeEditField.FontSize = 15;
            app.PopulationSizeEditField.FontWeight = 'bold';
            app.PopulationSizeEditField.BackgroundColor = bgCol;

            app.MaxIterationsEditFieldLabel = uilabel(app.ParametersPanel);
            app.MaxIterationsEditFieldLabel.Position = [20 80 175 22];
            app.MaxIterationsEditFieldLabel.Text = app.getLangString('MaxIter');
            app.MaxIterationsEditFieldLabel.FontWeight = 'bold';
            app.MaxIterationsEditFieldLabel.FontSize = 15;
            app.MaxIterationsEditFieldLabel.FontName = 'Times New Roman';
            app.MaxIterationsEditFieldLabel.BackgroundColor = bgCol;

            app.MaxIterationsEditField = uieditfield(app.ParametersPanel, 'numeric');
            app.MaxIterationsEditField.Position = [220 80 105 22];
            app.MaxIterationsEditField.Value = 100;
            app.MaxIterationsEditField.Limits = [10 1000];
            app.MaxIterationsEditField.HorizontalAlignment = 'center';
            app.MaxIterationsEditField.FontName = 'Times New Roman';
            app.MaxIterationsEditField.FontSize = 15;
            app.MaxIterationsEditField.FontWeight = 'bold';
            app.MaxIterationsEditField.BackgroundColor = bgCol;

            app.AlgorithmDropDownLabel = uilabel(app.ParametersPanel);
            app.AlgorithmDropDownLabel.Position = [20 45 175 22];
            app.AlgorithmDropDownLabel.Text = app.getLangString('Algorithm');
            app.AlgorithmDropDownLabel.FontWeight = 'bold';
            app.AlgorithmDropDownLabel.FontSize = 15;
            app.AlgorithmDropDownLabel.FontName = 'Times New Roman';
            app.AlgorithmDropDownLabel.BackgroundColor = bgCol;

            app.AlgorithmDropDown = uidropdown(app.ParametersPanel);
            app.AlgorithmDropDown.Items = {'POA', 'PSO', 'SSA', 'HHO', 'SABO', 'DBO', 'GWO'};
            app.AlgorithmDropDown.Position = [220 45 105 22];
            app.AlgorithmDropDown.Value = 'POA';
            app.AlgorithmDropDown.FontName = 'Times New Roman';
            app.AlgorithmDropDown.FontSize = 15;
            app.AlgorithmDropDown.FontWeight = 'bold';
            app.AlgorithmDropDown.BackgroundColor = bgCol;

            app.DataPointsLabel = uilabel(app.ParametersPanel);
            app.DataPointsLabel.Position = [20 10 305 22];
            app.DataPointsLabel.Text = sprintf(app.getLangString('DataPoints'), 0);
            app.DataPointsLabel.FontWeight = 'bold';
            app.DataPointsLabel.FontColor = [0  0 1];
            app.DataPointsLabel.FontSize = 15;
            app.DataPointsLabel.FontName = 'Times New Roman';
            app.DataPointsLabel.BackgroundColor = bgCol;

            % ==================== 按钮 ====================
            app.LoadDataButton = uibutton(app.LeftPanel, 'push');
            app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataButtonPushed, true);
            app.LoadDataButton.Position = [15 468 155 30];
            app.LoadDataButton.Text = app.getLangString('LoadData');
            app.LoadDataButton.FontWeight = 'bold';
            app.LoadDataButton.FontSize = 15;
            app.LoadDataButton.BackgroundColor = btnCol;
            app.LoadDataButton.FontColor = [1 1 1];
            app.LoadDataButton.FontName = 'Times New Roman';

            app.RunOptimizationButton = uibutton(app.LeftPanel, 'push');
            app.RunOptimizationButton.ButtonPushedFcn = createCallbackFcn(app, @RunOptimizationButtonPushed, true);
            app.RunOptimizationButton.Position = [185 468 155 30];
            app.RunOptimizationButton.Text = app.getLangString('RunOptimization');
            app.RunOptimizationButton.FontWeight = 'bold';
            app.RunOptimizationButton.FontSize = 15;
            app.RunOptimizationButton.BackgroundColor = btnCol;
            app.RunOptimizationButton.FontColor = [1 1 1];
            app.RunOptimizationButton.FontName = 'Times New Roman';

            % ==================== 优化结果面板 ====================
            app.ResultsPanel = uipanel(app.LeftPanel);
            app.ResultsPanel.Title = app.getLangString('OptimizationResults');
            app.ResultsPanel.Position = [10 264 340 196];
            app.ResultsPanel.FontWeight = 'bold';
            app.ResultsPanel.FontSize = 15;
            app.ResultsPanel.FontName = 'Times New Roman';
            app.ResultsPanel.BackgroundColor = bgCol;

            app.alphaEditFieldLabel = uilabel(app.ResultsPanel);
            app.alphaEditFieldLabel.Position = [20 136 175 22];
            app.alphaEditFieldLabel.Interpreter = 'html';
            app.alphaEditFieldLabel.Text = ['<html><b>' app.getLangString('MaterialParam') ' <i>α</i></b></html>'];
            app.alphaEditFieldLabel.FontSize = 15;
            app.alphaEditFieldLabel.FontName = 'Times New Roman';
            app.alphaEditFieldLabel.BackgroundColor = bgCol;

            app.alphaEditField = uieditfield(app.ResultsPanel, 'numeric');
            app.alphaEditField.Position = [220 136 105 22];
            app.alphaEditField.Editable = 'off';
            app.alphaEditField.ValueDisplayFormat = '%.4f';
            app.alphaEditField.HorizontalAlignment = 'center';
            app.alphaEditField.FontSize = 15;
            app.alphaEditField.FontWeight = 'bold';
            app.alphaEditField.FontName = 'Times New Roman';
            app.alphaEditField.BackgroundColor = bgCol;

            app.gammaEditFieldLabel = uilabel(app.ResultsPanel);
            app.gammaEditFieldLabel.Position = [20 106 175 22];
            app.gammaEditFieldLabel.Interpreter = 'html';
            app.gammaEditFieldLabel.Text = ['<html><b>' app.getLangString('MaterialParam') ' <i>γ</i></b></html>'];
            app.gammaEditFieldLabel.FontSize = 15;
            app.gammaEditFieldLabel.FontName = 'Times New Roman';
            app.gammaEditFieldLabel.BackgroundColor = bgCol;

            app.gammaEditField = uieditfield(app.ResultsPanel, 'numeric');
            app.gammaEditField.Position = [220 106 105 22];
            app.gammaEditField.Editable = 'off';
            app.gammaEditField.ValueDisplayFormat = '%.4f';
            app.gammaEditField.HorizontalAlignment = 'center';
            app.gammaEditField.FontSize = 15;
            app.gammaEditField.FontWeight = 'bold';
            app.gammaEditField.FontName = 'Times New Roman';
            app.gammaEditField.BackgroundColor = bgCol;

            app.uEditFieldLabel = uilabel(app.ResultsPanel);
            app.uEditFieldLabel.Position = [20 76 175 22];
            app.uEditFieldLabel.Interpreter = 'html';
            app.uEditFieldLabel.Text = ['<html><b>' app.getLangString('MaterialParam') ' <i>u</i></b></html>'];
            app.uEditFieldLabel.FontSize = 15;
            app.uEditFieldLabel.FontName = 'Times New Roman';
            app.uEditFieldLabel.BackgroundColor = bgCol;

            app.uEditField = uieditfield(app.ResultsPanel, 'numeric');
            app.uEditField.Position = [220 76 105 22];
            app.uEditField.Editable = 'off';
            app.uEditField.ValueDisplayFormat = '%.4f';
            app.uEditField.HorizontalAlignment = 'center';
            app.uEditField.FontSize = 15;
            app.uEditField.FontWeight = 'bold';
            app.uEditField.FontName = 'Times New Roman';
            app.uEditField.BackgroundColor = bgCol;

            app.vEditFieldLabel = uilabel(app.ResultsPanel);
            app.vEditFieldLabel.Position = [20 46 175 22];
            app.vEditFieldLabel.Interpreter = 'html';
            app.vEditFieldLabel.Text = ['<html><b>' app.getLangString('MaterialParam') ' <i>v</i></b></html>'];
            app.vEditFieldLabel.FontSize = 15;
            app.vEditFieldLabel.FontName = 'Times New Roman';
            app.vEditFieldLabel.BackgroundColor = bgCol;

            app.vEditField = uieditfield(app.ResultsPanel, 'numeric');
            app.vEditField.Position = [220 46 105 22];
            app.vEditField.Editable = 'off';
            app.vEditField.ValueDisplayFormat = '%.4f';
            app.vEditField.HorizontalAlignment = 'center';
            app.vEditField.FontSize = 15;
            app.vEditField.FontWeight = 'bold';
            app.vEditField.FontName = 'Times New Roman';
            app.vEditField.BackgroundColor = bgCol;

            app.BestScoreEditFieldLabel = uilabel(app.ResultsPanel);
            app.BestScoreEditFieldLabel.Position = [20 16 175 22];
            app.BestScoreEditFieldLabel.Interpreter = 'html';
            app.BestScoreEditFieldLabel.Text = ['<html><b>' app.getLangString('PredictionError') ' <i>S</i> (%)</b></html>'];
            app.BestScoreEditFieldLabel.FontSize = 15;
            app.BestScoreEditFieldLabel.FontName = 'Times New Roman';
            app.BestScoreEditFieldLabel.BackgroundColor = bgCol;

            app.BestScoreEditField = uieditfield(app.ResultsPanel, 'numeric');
            app.BestScoreEditField.Position = [220 16 105 22];
            app.BestScoreEditField.Editable = 'off';
            app.BestScoreEditField.ValueDisplayFormat = '%.4f';
            app.BestScoreEditField.FontWeight = 'bold';
            app.BestScoreEditField.HorizontalAlignment = 'center';
            app.BestScoreEditField.FontSize = 15;
            app.BestScoreEditField.FontName = 'Times New Roman';
            app.BestScoreEditField.BackgroundColor = bgCol;

            % ==================== 可视化选项面板 ====================
            app.VisualizationPanel = uipanel(app.LeftPanel);
            app.VisualizationPanel.Title = app.getLangString('VisualizationOptions');
            app.VisualizationPanel.Position = [10 134 340 121];
            app.VisualizationPanel.FontWeight = 'bold';
            app.VisualizationPanel.FontSize = 15;
            app.VisualizationPanel.FontName = 'Times New Roman';
            app.VisualizationPanel.BackgroundColor = bgCol;

            app.Generate3DEnvelopeButton = uibutton(app.VisualizationPanel, 'push');
            app.Generate3DEnvelopeButton.ButtonPushedFcn = createCallbackFcn(app, @Generate3DEnvelopeButtonPushed, true);
            app.Generate3DEnvelopeButton.Position = [8 56 155 30];
            app.Generate3DEnvelopeButton.Text = app.getLangString('Generate3DEnvelope');
            app.Generate3DEnvelopeButton.FontWeight = 'bold';
            app.Generate3DEnvelopeButton.FontSize = 15;
            app.Generate3DEnvelopeButton.BackgroundColor = btnCol;
            app.Generate3DEnvelopeButton.FontColor = [1 1 1];
            app.Generate3DEnvelopeButton.FontName = 'Times New Roman';

            app.DeviatoricPlaneButton = uibutton(app.VisualizationPanel, 'push');
            app.DeviatoricPlaneButton.ButtonPushedFcn = createCallbackFcn(app, @DeviatoricPlaneButtonPushed, true);
            app.DeviatoricPlaneButton.Position = [178 56 155 30];
            app.DeviatoricPlaneButton.Text = app.getLangString('DeviatoricPlane');
            app.DeviatoricPlaneButton.FontWeight = 'bold';
            app.DeviatoricPlaneButton.FontSize = 15;
            app.DeviatoricPlaneButton.BackgroundColor = btnCol;
            app.DeviatoricPlaneButton.FontColor = [1 1 1];
            app.DeviatoricPlaneButton.FontName = 'Times New Roman';

            app.Sigma1Sigma2PlaneButton = uibutton(app.VisualizationPanel, 'push');
            app.Sigma1Sigma2PlaneButton.ButtonPushedFcn = createCallbackFcn(app, @Sigma1Sigma2PlaneButtonPushed, true);
            app.Sigma1Sigma2PlaneButton.Position = [8 13 155 30];
            app.Sigma1Sigma2PlaneButton.Text = app.getLangString('Sigma1Sigma2Plane');
            app.Sigma1Sigma2PlaneButton.FontWeight = 'bold';
            app.Sigma1Sigma2PlaneButton.FontSize = 15;
            app.Sigma1Sigma2PlaneButton.BackgroundColor = btnCol;
            app.Sigma1Sigma2PlaneButton.FontColor = [1 1 1];
            app.Sigma1Sigma2PlaneButton.FontName = 'Times New Roman';

            app.ConvergenceCurvesButton = uibutton(app.VisualizationPanel, 'push');
            app.ConvergenceCurvesButton.ButtonPushedFcn = createCallbackFcn(app, @ConvergenceCurvesButtonPushed, true);
            app.ConvergenceCurvesButton.Position = [178 13 155 30];
            app.ConvergenceCurvesButton.Text = app.getLangString('ConvergenceCurves');
            app.ConvergenceCurvesButton.FontWeight = 'bold';
            app.ConvergenceCurvesButton.FontSize = 15;
            app.ConvergenceCurvesButton.BackgroundColor = btnCol;
            app.ConvergenceCurvesButton.FontColor = [1 1 1];
            app.ConvergenceCurvesButton.FontName = 'Times New Roman';

            app.ClearVisualizationButton = uibutton(app.LeftPanel, 'push');
            app.ClearVisualizationButton.ButtonPushedFcn = createCallbackFcn(app, @ClearVisualizationButtonPushed, true);
            app.ClearVisualizationButton.Position = [18 94 155 30];
            app.ClearVisualizationButton.Text = app.getLangString('ClearVisualization');
            app.ClearVisualizationButton.FontWeight = 'bold';
            app.ClearVisualizationButton.FontSize = 15;
            app.ClearVisualizationButton.BackgroundColor = btnCol;
            app.ClearVisualizationButton.FontColor = [1 1 1];
            app.ClearVisualizationButton.FontName = 'Times New Roman';

            app.StatusLabel = uilabel(app.LeftPanel);
            app.StatusLabel.WordWrap = 'on';
            app.StatusLabel.Position = [10 10 340 40];
            app.StatusLabel.Text = app.getLangString('StatusReady');
            app.StatusLabel.FontSize = 15;
            app.StatusLabel.FontWeight = 'bold';
            app.StatusLabel.VerticalAlignment = 'top';
            app.StatusLabel.FontName = 'Times New Roman';
            app.StatusLabel.BackgroundColor = bgCol;

            app.ExitButton = uibutton(app.LeftPanel, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
            app.ExitButton.Position = [188 94 155 30];
            app.ExitButton.Text = app.getLangString('Exit');
            app.ExitButton.FontWeight = 'bold';
            app.ExitButton.FontSize = 15;
            app.ExitButton.BackgroundColor = btnCol;
            app.ExitButton.FontColor = [1 1 1];
            app.ExitButton.FontName = 'Times New Roman';

            % ==================== 右面板 ====================
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Title = app.getLangString('Visualization');
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;
            app.RightPanel.FontName = 'Times New Roman';
            app.RightPanel.FontSize = 16;
            app.RightPanel.FontWeight = 'bold';
            app.RightPanel.AutoResizeChildren = 'off';
            app.RightPanel.BackgroundColor = bgCol;

            app.RightPanelGridLayout = uigridlayout(app.RightPanel);
            app.RightPanelGridLayout.ColumnWidth = {'1x'};
            app.RightPanelGridLayout.RowHeight = {'1x'};
            app.RightPanelGridLayout.Padding = [10 10 10 10];
            app.RightPanelGridLayout.BackgroundColor = bgCol;

            % ==================== 右键菜单 ====================
            app.AxesContextMenu = uicontextmenu(app.UIFigure);
            app.ContextSaveFigureMenu = uimenu(app.AxesContextMenu);
            app.ContextSaveFigureMenu.Text = app.getLangString('SaveFigureContext');
            
            app.ContextSaveAsPNGMenu = uimenu(app.ContextSaveFigureMenu);
            app.ContextSaveAsPNGMenu.Text = app.getLangString('SaveAsPNG');
            app.ContextSaveAsPNGMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextSaveAsPNGMenuSelected, true);
            
            app.ContextSaveAsJPGMenu = uimenu(app.ContextSaveFigureMenu);
            app.ContextSaveAsJPGMenu.Text = app.getLangString('SaveAsJPG');
            app.ContextSaveAsJPGMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextSaveAsJPGMenuSelected, true);
            
            app.ContextSaveAsEPSMenu = uimenu(app.ContextSaveFigureMenu);
            app.ContextSaveAsEPSMenu.Text = app.getLangString('SaveAsEPS');
            app.ContextSaveAsEPSMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextSaveAsEPSMenuSelected, true);
            
            app.ContextSaveAsPDFMenu = uimenu(app.ContextSaveFigureMenu);
            app.ContextSaveAsPDFMenu.Text = app.getLangString('SaveAsPDF');
            app.ContextSaveAsPDFMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextSaveAsPDFMenuSelected, true);
            
            app.ContextSaveAsTIFFMenu = uimenu(app.ContextSaveFigureMenu);
            app.ContextSaveAsTIFFMenu.Text = app.getLangString('SaveAsTIFF');
            app.ContextSaveAsTIFFMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextSaveAsTIFFMenuSelected, true);
            
            app.ContextSaveAsSVGMenu = uimenu(app.ContextSaveFigureMenu);
            app.ContextSaveAsSVGMenu.Text = app.getLangString('SaveAsSVG');
            app.ContextSaveAsSVGMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextSaveAsSVGMenuSelected, true);
            
            app.ContextSaveAsEMFMenu = uimenu(app.ContextSaveFigureMenu);
            app.ContextSaveAsEMFMenu.Text = app.getLangString('SaveAsEMF');
            app.ContextSaveAsEMFMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextSaveAsEMFMenuSelected, true);
            
            app.ContextSaveAsFIGMenu = uimenu(app.ContextSaveFigureMenu);
            app.ContextSaveAsFIGMenu.Text = app.getLangString('SaveAsFIG');
            app.ContextSaveAsFIGMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextSaveAsFIGMenuSelected, true);
            
            app.ContextCopyToClipboardMenu = uimenu(app.AxesContextMenu);
            app.ContextCopyToClipboardMenu.Separator = 'on';
            app.ContextCopyToClipboardMenu.Text = app.getLangString('CopyToClipboard');
            app.ContextCopyToClipboardMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextCopyToClipboardMenuSelected, true);
            
            app.ContextExportHighResMenu = uimenu(app.AxesContextMenu);
            app.ContextExportHighResMenu.Text = app.getLangString('ExportHighRes');
            app.ContextExportHighResMenu.MenuSelectedFcn = createCallbackFcn(app, @ContextExportHighResMenuSelected, true);

            % ==================== 坐标轴 ====================
            app.UIAxes = uiaxes(app.RightPanelGridLayout);
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;
            app.UIAxes.Color = bgCol;
            app.UIAxes.XAxis.Visible = 'off';
            app.UIAxes.YAxis.Visible = 'off';
            app.UIAxes.ZAxis.Visible = 'off';
            grid(app.UIAxes, 'off');
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.ZTick = [];
            xlabel(app.UIAxes, '');
            ylabel(app.UIAxes, '');
            zlabel(app.UIAxes, '');
            box(app.UIAxes, 'off');
            app.UIAxes.Toolbar.Visible = 'on';
            app.UIAxes.ContextMenu = app.AxesContextMenu;
            app.UIAxes.FontName = 'Times New Roman';

            app.UIFigure.Visible = 'on';
        end
        
        function UIFigureSizeChanged(app, ~)
            if isvalid(app.UIAxes) && ~isempty(app.CurrentPlotType)
                drawnow;
            end
        end
    end

    methods (Access = public)
        function app = MMCHB_criterion
            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @startupFcn)
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end

%% ==================== CONVERGENCE CURVE PLOTTING ====================
function plot_convergence_curves(ax, curves, max_iter)
    cla(ax, 'reset');
    ax.Color = [1 1 1];
    ax.XAxis.Visible = 'on';
    ax.YAxis.Visible = 'on';
    
    hold(ax, 'on');
    
    CNT = 10;
    k = round(linspace(1, max_iter, CNT));
    iter = 1:max_iter;
    
    color_DBO = [0.4391 0.1882 0.6275];
    color_SABO =[0.8510 0.3255 0.0980];
    color_PSO = [0.0000 0.4392 0.7529];
    color_HHO = [0.0000 0.6902 0.9412];
    color_SSA = [1.0000 0.7529 0.0000];
    color_POA = [0.6431 0.8157 0.3137];
    color_GWO = [0.6350 0.0780 0.1840];
    
    h_DBO = semilogy(ax, iter(k), curves.DBO(k), '-v', 'Color', color_DBO, 'MarkerFaceColor', color_DBO, 'MarkerEdgeColor', color_DBO, 'LineWidth', 2, 'MarkerSize', 6);
    h_SABO = semilogy(ax, iter(k), curves.SABO(k), '-o', 'Color', color_SABO, 'MarkerFaceColor', color_SABO, 'MarkerEdgeColor', color_SABO, 'LineWidth', 2, 'MarkerSize', 6);
    h_PSO = semilogy(ax, iter(k), curves.PSO(k), '-^', 'Color', color_PSO, 'MarkerFaceColor', color_PSO, 'MarkerEdgeColor', color_PSO, 'LineWidth', 2, 'MarkerSize', 6);
    h_HHO = semilogy(ax, iter(k), curves.HHO(k), '-s', 'Color', color_HHO, 'MarkerFaceColor', color_HHO, 'MarkerEdgeColor', color_HHO, 'LineWidth', 2, 'MarkerSize', 6);
    h_SSA = semilogy(ax, iter(k), curves.SSA(k), '-h', 'Color', color_SSA, 'MarkerFaceColor', color_SSA, 'MarkerEdgeColor', color_SSA, 'LineWidth', 2, 'MarkerSize', 6);
    h_POA = semilogy(ax, iter(k), curves.POA(k), '-d', 'Color', color_POA, 'MarkerFaceColor', color_POA, 'MarkerEdgeColor', color_POA, 'LineWidth', 1.5, 'MarkerSize', 6);
    
    if isfield(curves, 'GWO')
        h_GWO = semilogy(ax, iter(k), curves.GWO(k), '-p', 'Color', color_GWO, 'MarkerFaceColor', color_GWO, 'MarkerEdgeColor', color_GWO, 'LineWidth', 1.5, 'MarkerSize', 6);
        legend(ax, [h_DBO, h_SABO, h_PSO, h_HHO, h_SSA, h_POA, h_GWO], {'DBO', 'SABO', 'PSO', 'HHO', 'SSA', 'POA', 'GWO'}, 'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 10);
    else
        legend(ax, [h_DBO, h_SABO, h_PSO, h_HHO, h_SSA, h_POA], {'DBO', 'SABO', 'PSO', 'HHO', 'SSA', 'POA'}, 'Location', 'northeast', 'FontName', 'Times New Roman', 'FontSize', 10);
    end
    
    xlabel(ax, 'Iteration', 'FontSize', 12, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
    ylabel(ax, 'Error S (%)', 'FontSize', 12, 'FontName', 'Times New Roman', 'FontWeight', 'bold');
    
    grid(ax, 'on');
    box(ax, 'on');
    set(ax, 'FontSize', 13, 'FontName', 'Times New Roman');
    
    pbaspect(ax, [1 0.65 1]);
    
    hold(ax, 'off');
end

%% ==================== OPTIMIZATION ALGORITHMS ====================

function [Best_score, Best_pos, DBO_curve] = DBO_algorithm(pop_size, max_iter, lb, ub, dim, fobj)
    Best_pos = zeros(1, dim);
    Best_score = inf;
    X = repmat(lb, pop_size, 1) + rand(pop_size, dim) .* repmat((ub - lb), pop_size, 1);
    fitness = zeros(pop_size, 1);
    for i = 1:pop_size, fitness(i) = fobj(X(i, :)); end
    [fitness, index] = sort(fitness);
    X = X(index, :);
    Best_pos = X(1, :);
    Best_score = fitness(1);
    DBO_curve = zeros(1, max_iter);
    pNum = round(pop_size * 0.2);
    
    for t = 1:max_iter
        [fmax, B] = max(fitness);
        worse = X(B, :);
        r2 = rand(1);
        XX = X;
        
        for i = 1:pNum
            if r2 < 0.9
                r1 = rand(1);
                a = rand(1, 1);
                if a > 0.1
                    a = 1;
                else
                    a = -1;
                end
                X(i, :) = X(i, :) + 0.15 * abs(X(i, :) - worse) + a * 0.2 * (XX(i, :));
            else
                aaa = randperm(180, 1);
                if aaa == 0 || aaa == 90 || aaa == 180
                    X(i, :) = X(i, :);
                else
                    theta = aaa * pi / 180;
                    X(i, :) = X(i, :) + tan(theta) .* abs(X(i, :) - XX(i, :));
                end
            end
            X(i, :) = max(X(i, :), lb);
            X(i, :) = min(X(i, :), ub);
            fitness(i) = fobj(X(i, :));
        end
        
        [fMMin, bestII] = min(fitness);
        bestXX = X(bestII, :);
        R = 1 - t / max_iter;
        Xnew1 = bestXX .* (1 - R);
        Xnew2 = bestXX .* (1 + R);
        Xnew1 = max(Xnew1, lb);
        Xnew1 = min(Xnew1, ub);
        Xnew2 = max(Xnew2, lb);
        Xnew2 = min(Xnew2, ub);
        Xnew11 = Best_pos .* (1 - R);
        Xnew22 = Best_pos .* (1 + R);
        Xnew11 = max(Xnew11, lb);
        Xnew11 = min(Xnew11, ub);
        Xnew22 = max(Xnew22, lb);
        Xnew22 = min(Xnew22, ub);
        
        for i = (pNum + 1):min(12, pop_size)
            X(i, :) = bestXX + ((rand(1, dim)) .* (X(i, :) - Xnew1) + (rand(1, dim)) .* (X(i, :) - Xnew2));
            X(i, :) = max(X(i, :), Xnew1);
            X(i, :) = min(X(i, :), Xnew2);
            fitness(i) = fobj(X(i, :));
        end
        
        for i = min(13, pop_size):min(19, pop_size)
            X(i, :) = X(i, :) + ((randn(1, dim)) .* (X(i, :) - Xnew11) + ((rand(1, dim)) .* (X(i, :) - Xnew22)));
            X(i, :) = max(X(i, :), lb);
            X(i, :) = min(X(i, :), ub);
            fitness(i) = fobj(X(i, :));
        end
        
        for j = min(20, pop_size):pop_size
            X(j, :) = Best_pos + randn(1, dim) .* ((abs((X(j, :) - bestXX))) + (abs((X(j, :) - Best_pos)))) ./ 2;
            X(j, :) = max(X(j, :), lb);
            X(j, :) = min(X(j, :), ub);
            fitness(j) = fobj(X(j, :));
        end
        
        for i = 1:pop_size
            if fitness(i) < Best_score
                Best_score = fitness(i);
                Best_pos = X(i, :);
            end
        end
        
        DBO_curve(t) = Best_score;
    end
end

function [Best_score, Best_pos, PSO_curve] = PSO_algorithm(pop_size, max_iter, lb, ub, dim, fobj)
    w = 0.9;
    c1 = 2;
    c2 = 2;
    X = repmat(lb, pop_size, 1) + rand(pop_size, dim) .* repmat((ub - lb), pop_size, 1);
    V = rand(pop_size, dim);
    fitness = zeros(pop_size, 1);
    for i = 1:pop_size, fitness(i) = fobj(X(i, :)); end
    [Best_score, idx] = min(fitness);
    Best_pos = X(idx, :);
    pbest = X;
    pbest_fitness = fitness;
    PSO_curve = zeros(1, max_iter);
    
    for t = 1:max_iter
        for i = 1:pop_size
            V(i, :) = w * V(i, :) + c1 * rand * (pbest(i, :) - X(i, :)) + c2 * rand * (Best_pos - X(i, :));
            X(i, :) = X(i, :) + V(i, :);
            X(i, :) = max(X(i, :), lb);
            X(i, :) = min(X(i, :), ub);
            fitness(i) = fobj(X(i, :));
            if fitness(i) < pbest_fitness(i)
                pbest(i, :) = X(i, :);
                pbest_fitness(i) = fitness(i);
            end
            if fitness(i) < Best_score
                Best_score = fitness(i);
                Best_pos = X(i, :);
            end
        end
        w = 0.9 - t * (0.5 / max_iter);
        PSO_curve(t) = Best_score;
    end
end

function [Best_score, Best_pos, SSA_curve] = SSA_algorithm(pop_size, max_iter, lb, ub, dim, fobj)
    X = repmat(lb, pop_size, 1) + rand(pop_size, dim) .* repmat((ub - lb), pop_size, 1);
    fitness = zeros(pop_size, 1);
    for i = 1:pop_size, fitness(i) = fobj(X(i, :)); end
    [fitness, index] = sort(fitness);
    X = X(index, :);
    Best_pos = X(1, :);
    Best_score = fitness(1);
    SSA_curve = zeros(1, max_iter);
    
    for t = 1:max_iter
        c1 = 2 * exp(-(4 * t / max_iter)^2);
        for i = 1:pop_size
            if i <= pop_size / 2
                X(i, :) = Best_pos + c1 * ((ub - lb) .* rand(1, dim) + lb);
            else
                X(i, :) = (X(i, :) + X(i - 1, :)) / 2;
            end
            X(i, :) = max(X(i, :), lb);
            X(i, :) = min(X(i, :), ub);
            fitness(i) = fobj(X(i, :));
            if fitness(i) < Best_score
                Best_score = fitness(i);
                Best_pos = X(i, :);
            end
        end
        SSA_curve(t) = Best_score;
    end
end

function [Best_score, Best_pos, HHO_curve] = HHO_algorithm(pop_size, max_iter, lb, ub, dim, fobj)
    X = repmat(lb, pop_size, 1) + rand(pop_size, dim) .* repmat((ub - lb), pop_size, 1);
    fitness = zeros(pop_size, 1);
    for i = 1:pop_size, fitness(i) = fobj(X(i, :)); end
    [Best_score, idx] = min(fitness);
    Best_pos = X(idx, :);
    HHO_curve = zeros(1, max_iter);
    
    for t = 1:max_iter
        E0 = 2 * rand - 1;
        E = 2 * E0 * (1 - t / max_iter);
        for i = 1:pop_size
            r = rand;
            if abs(E) >= 1
                q = rand;
                rand_idx = randi([1, pop_size]);
                X_rand = X(rand_idx, :);
                if q >= 0.5
                    X(i, :) = X_rand - rand(1, dim) .* abs(X_rand - 2 * rand(1, dim) .* X(i, :));
                else
                    X(i, :) = (Best_pos - mean(X)) - rand(1, dim) .* ((ub - lb) .* rand(1, dim) + lb);
                end
            else
                if r >= 0.5 && abs(E) < 0.5
                    Delta_X = Best_pos - X(i, :);
                    X(i, :) = Delta_X - E * abs(2 * rand(1, dim) .* Delta_X);
                elseif r >= 0.5 && abs(E) >= 0.5
                    X(i, :) = Best_pos - E * abs(Best_pos - X(i, :));
                elseif r < 0.5 && abs(E) >= 0.5
                    Y = Best_pos - E * abs(2 * rand(1, dim) .* Best_pos - X(i, :));
                    Y = max(Y, lb);
                    Y = min(Y, ub);
                    if fobj(Y) < fitness(i), X(i, :) = Y; end
                else
                    Y = Best_pos - E * abs(2 * rand(1, dim) .* Best_pos - mean(X));
                    Y = max(Y, lb);
                    Y = min(Y, ub);
                    if fobj(Y) < fitness(i), X(i, :) = Y; end
                end
            end
            X(i, :) = max(X(i, :), lb);
            X(i, :) = min(X(i, :), ub);
            fitness(i) = fobj(X(i, :));
            if fitness(i) < Best_score
                Best_score = fitness(i);
                Best_pos = X(i, :);
            end
        end
        HHO_curve(t) = Best_score;
    end
end

function [Best_score, Best_pos, SABO_curve] = SABO_algorithm(pop_size, max_iter, lb, ub, dim, fobj)
    X = repmat(lb, pop_size, 1) + rand(pop_size, dim) .* repmat((ub - lb), pop_size, 1);
    fitness = zeros(pop_size, 1);
    for i = 1:pop_size, fitness(i) = fobj(X(i, :)); end
    [Best_score, idx] = min(fitness);
    Best_pos = X(idx, :);
    SABO_curve = zeros(1, max_iter);
    
    for t = 1:max_iter
        a = 2 - 2 * t / max_iter;
        for i = 1:pop_size
            r1 = rand;
            r2 = rand;
            A = 2 * a * r1 - a;
            C = 2 * r2;
            p = rand;
            if p < 0.5
                if abs(A) < 1
                    D = abs(C * Best_pos - X(i, :));
                    X(i, :) = Best_pos - A * D;
                else
                    rand_idx = randi([1, pop_size]);
                    X_rand = X(rand_idx, :);
                    D = abs(C * X_rand - X(i, :));
                    X(i, :) = X_rand - A * D;
                end
            else
                distance = abs(Best_pos - X(i, :));
                X(i, :) = distance .* exp(2 * pi * rand(1, dim)) .* cos(2 * pi * rand(1, dim)) + Best_pos;
            end
            X(i, :) = max(X(i, :), lb);
            X(i, :) = min(X(i, :), ub);
            fitness(i) = fobj(X(i, :));
            if fitness(i) < Best_score
                Best_score = fitness(i);
                Best_pos = X(i, :);
            end
        end
        SABO_curve(t) = Best_score;
    end
end

function [Best_score, Best_pos, POA_curve] = POA_algorithm(pop_size, max_iter, lb, ub, dim, fobj)
    X = rand(pop_size, dim) .* (ub - lb) + lb;
    fit = zeros(pop_size, 1);
    for i = 1:pop_size, fit(i) = fobj(X(i, :)); end
    [fbest, idx] = min(fit);
    Xbest = X(idx, :);
    best_so_far = zeros(1, max_iter);
    
    for t = 1:max_iter
        for i = 1:pop_size
            if rand < 0.2
                X_new = X(i, :) + rand(1, dim) .* (Xbest - X(i, :));
            else
                idx1 = randi([1, pop_size]);
                idx2 = randi([1, pop_size]);
                X_new = X(i, :) + rand .* (X(idx1, :) - X(idx2, :));
            end
            X_new = max(X_new, lb);
            X_new = min(X_new, ub);
            f_new = fobj(X_new);
            if f_new <= fit(i)
                X(i, :) = X_new;
                fit(i) = f_new;
            end
            if f_new < fbest
                fbest = f_new;
                Xbest = X_new;
            end
        end
        best_so_far(t) = fbest;
    end
    Best_score = fbest;
    Best_pos = Xbest;
    POA_curve = best_so_far;
end

function [Alpha_score, Alpha_pos, Curve] = GWO_algorithm(n, Max_iter, lb, ub, dim, fobj)
    Alpha_pos = zeros(1, dim);
    Alpha_score = inf;
    Beta_pos = zeros(1, dim);
    Beta_score = inf;
    Delta_pos = zeros(1, dim);
    Delta_score = inf;
    Pos = repmat(lb, n, 1) + rand(n, dim) .* repmat((ub - lb), n, 1);
    Curve = zeros(1, Max_iter);
    
    for l = 1:Max_iter
        for i = 1:n
            Pos(i, :) = max(Pos(i, :), lb);
            Pos(i, :) = min(Pos(i, :), ub);
            fit = fobj(Pos(i, :));
            if fit < Alpha_score
                Alpha_score = fit;
                Alpha_pos = Pos(i, :);
            end
            if fit > Alpha_score && fit < Beta_score
                Beta_score = fit;
                Beta_pos = Pos(i, :);
            end
            if fit > Alpha_score && fit > Beta_score && fit < Delta_score
                Delta_score = fit;
                Delta_pos = Pos(i, :);
            end
        end
        
        a = 2 - l * (2 / Max_iter);
        for i = 1:n
            for j = 1:dim
                r1 = rand();
                r2 = rand();
                A1 = 2 * a * r1 - a;
                C1 = 2 * r2;
                D_alpha = abs(C1 * Alpha_pos(j) - Pos(i, j));
                X1 = Alpha_pos(j) - A1 * D_alpha;
                r1 = rand();
                r2 = rand();
                A2 = 2 * a * r1 - a;
                C2 = 2 * r2;
                D_beta = abs(C2 * Beta_pos(j) - Pos(i, j));
                X2 = Beta_pos(j) - A2 * D_beta;
                r1 = rand();
                r2 = rand();
                A3 = 2 * a * r1 - a;
                C3 = 2 * r2;
                D_delta = abs(C3 * Delta_pos(j) - Pos(i, j));
                X3 = Delta_pos(j) - A3 * D_delta;
                Pos(i, j) = (X1 + X2 + X3) / 3;
            end
        end
        Curve(l) = Alpha_score;
    end
end

%% ==================== PLOTTING FUNCTIONS ====================

function plot_3d_surface_in_axes(ax, alpha, gamma, u, v, peak, mi_best, ucs)
    cla(ax, 'reset');
    ax.Color = [1 1 1];
    ax.XAxis.Visible = 'on';
    ax.YAxis.Visible = 'on';
    ax.ZAxis.Visible = 'on';
    
    sigma1 = peak(:,1); sigma2 = peak(:,2); sigma3 = peak(:,3);
    max_sigma = max([max(sigma1), max(sigma2), max(sigma3)]);
    max_I1 = max(sigma1 + sigma2 + sigma3);
    I1_min = -3*ucs/mi_best; I1_max = max_I1 * 1.2;
    I1_draw = linspace(I1_min, I1_max, 60);
    m = 60; X = zeros(60, m); Y = zeros(60, m); Z = zeros(60, m);
    
    for i = 1:length(I1_draw)
        theta_draw_dev = linspace(0, 2*pi, m);
        f1 = (-mi_best*ucs + sqrt((mi_best*ucs)^2 + 12*mi_best*ucs*I1_draw(i) + 36*ucs^2)) / (6*sqrt(3));
        f2 = (-sin((alpha*pi/6 + pi + (acos(gamma)/3)))) .^ (1./u) ./ (sin((alpha*pi/6 + (acos(gamma*cos(3*theta_draw_dev))./3)))) .^ (1./v);
        sqrtJ2 = f1 * f2; rho = sqrt(2) * sqrtJ2;
        [z, x, y] = cal_sigma(I1_draw(i), rho/sqrt(2), theta_draw_dev, 2*pi/1);
        X(i,:) = x; Y(i,:) = y; Z(i,:) = z;
    end
    
    mesh(ax, X, Y, Z, 'edgecolor', [0.8 0.8 0.8], 'FaceColor', 'none');
    axis(ax, 'equal'); grid(ax, 'off'); hold(ax, 'on');
    
    flag = zeros(length(sigma1), 1);
    for i = 1:length(sigma1)
        flag(i) = is_in_surface(sigma1(i), sigma2(i), sigma3(i), alpha, gamma, u, v, mi_best, ucs);
    end
    
    I1 = flag == 1; I2 = flag == 0;
    plot3(ax, sigma2(I1), sigma3(I1), sigma1(I1), 'o', 'Color', [0.0000 0.4471 0.7412], 'linewidth', 2.7, 'MarkerSize', 2.7);
    plot3(ax, sigma2(I2), sigma3(I2), sigma1(I2), 'o', 'Color', [0.7529 0.0000 0.0000], 'linewidth', 2.7, 'MarkerSize', 2.7);
    
    diag_max = max_sigma * 1.1;
    plot3(ax, [0, diag_max], [0, diag_max], [0, diag_max], 'b-', 'linewidth', 1);
    
    set(ax, 'XColor', 'white', 'xticklabel', []); 
    set(ax, 'YColor', 'white', 'yticklabel', []);
    set(ax, 'ZColor', 'white', 'zticklabel', []);
    
    num_contours = min(6, floor(length(I1_draw)/10)); 
    contour_interval = floor(length(I1_draw) / num_contours);
    
    for int = contour_interval:contour_interval:(num_contours*contour_interval)
        if int <= length(I1_draw)
            I1_draw1 = I1_draw(int); theta_draw_dev = linspace(0, 2*pi, 10000);
            f1_ = (-mi_best*ucs + sqrt((mi_best*ucs)^2 + 12*mi_best*ucs*I1_draw(int) + 36*ucs^2)) / (6*sqrt(3));
            f2_ = (-sin((alpha*pi/6 + pi + (acos(gamma)/3)))) .^ (1./u) ./ (sin((alpha*pi/6 + (acos(gamma*cos(3*theta_draw_dev))./3)))) .^ (1./v);
            sqrtJ2 = f1_ * f2_; rho = sqrt(2) * sqrtJ2;
            [z, x, y] = cal_sigma(I1_draw1, rho/sqrt(2), theta_draw_dev, 2*pi/1);
            plot3(ax, x, y, z, 'k', 'linewidth', 0.6);
        end
    end
    
    xlabel(ax, {'\sigma_{2} (MPa)'}, 'rotation', -30, 'FontName', 'Times New Roman'); 
    ylabel(ax, {'\sigma_{3} (MPa)'}, 'rotation', 30, 'FontName', 'Times New Roman');
    zlabel(ax, '\sigma_{1} (MPa)', 'FontName', 'Times New Roman'); 
    set(ax, 'FontSize', 12, 'Fontname', 'Times New Roman');
    box(ax, 'on'); 
    view(ax, -14, -24.27);
    axis(ax, 'equal'); 
    hold(ax, 'off');
end

function plot_polar_diagram_enhanced(ax, alpha, gamma, u, v, peak, mi_best, ucs)
    cla(ax, 'reset');
    ax.Color = [1 1 1];
    
    sigma1 = peak(:,1); sigma2 = peak(:,2); sigma3 = peak(:,3);
    max_I1 = max(sigma1 + sigma2 + sigma3);
    I1_min = -3*ucs/mi_best; I1_max = max_I1 * 1.2;
    I1_draw = linspace(I1_min, I1_max, 60);
    rotation_theta2 = 1/2 * pi; size_scatter = 27; edge_scatter = 1;
    max_rho = 0; num_contours = min(6, floor(length(I1_draw)/10));
    contour_interval = floor(length(I1_draw) / num_contours);
    
    for int = contour_interval:contour_interval:(num_contours*contour_interval)
        if int <= length(I1_draw)
            theta_draw_dev = linspace(0, 2*pi, 360);
            f11 = (-mi_best*ucs + sqrt((mi_best*ucs)^2 + 12*mi_best*ucs*I1_draw(int) + 36*ucs^2)) / (6*sqrt(3));
            f22 = (-sin((alpha*pi/6 + pi + (acos(gamma)/3)))) .^ (1./u) ./ (sin((alpha*pi/6 + (acos(gamma*cos(3*theta_draw_dev))./3)))) .^ (1./v);
            sqrtJ2 = f11 * f22; rho = sqrt(2) * sqrtJ2;
            max_rho = max(max_rho, max(rho));
        end
    end
    
    if max_rho <= 300, rho_ticks = linspace(0, ceil(max_rho/50)*50, 5);
    elseif max_rho <= 600, rho_ticks = linspace(0, ceil(max_rho/100)*100, 5);
    elseif max_rho <= 1200, rho_ticks = linspace(0, ceil(max_rho/200)*200, 5);
    elseif max_rho <= 1800, rho_ticks = linspace(0, ceil(max_rho/300)*300, 5);
    else, rho_ticks = linspace(0, ceil(max_rho/500)*500, 5); end
    
    hold(ax, 'on');
    
    theta_grid = linspace(0, 2*pi, 100);
    for r = rho_ticks(2:end)
        x_circle = r * cos(theta_grid); y_circle = r * sin(theta_grid);
        plot(ax, x_circle, y_circle, '-', 'Color', [0.75 0.75 0.75], 'LineWidth', 0.4);
    end
    
    angles_dashed = [30, 150, 270];
    angles_solid = [90, 210, 330];
    
    for angle_deg = angles_solid
        angle_rad = angle_deg * pi / 180;
        plot(ax, [0, max_rho * 1.1 * cos(angle_rad)], [0, max_rho * 1.1 * sin(angle_rad)], '-', 'Color', [0.65 0.65 0.65], 'LineWidth', 0.4);
    end
    
    for angle_deg = angles_dashed
        angle_rad = angle_deg * pi / 180;
        plot(ax, [0, max_rho * 1.1 * cos(angle_rad)], [0, max_rho * 1.1 * sin(angle_rad)], '--', 'Color', [0.65 0.65 0.65], 'LineWidth', 0.4);
    end
    
    colors_envelope = [
        0.0000    0.4471    0.7412;
        0.8510    0.3255    0.0980;
        0.9294    0.6941    0.1255;
        0.4941    0.1843    0.5569;
        0.4667    0.6745    0.1882;
        0.3020    0.7451    0.9333
    ];
    
    if num_contours ~= size(colors_envelope, 1)
        t_old = linspace(0, 1, size(colors_envelope, 1));
        t_new = linspace(0, 1, num_contours);
        colors_envelope = interp1(t_old, colors_envelope, t_new);
    end
    
    for int_idx = 1:num_contours
        int = contour_interval * int_idx;
        if int <= length(I1_draw)
            theta_draw_dev = linspace(0, 2*pi, 360);
            f11 = (-mi_best*ucs + sqrt((mi_best*ucs)^2 + 12*mi_best*ucs*I1_draw(int) + 36*ucs^2)) / (6*sqrt(3));
            f22 = (-sin((alpha*pi/6 + pi + (acos(gamma)/3)))) .^ (1./u) ./ (sin((alpha*pi/6 + (acos(gamma*cos(3*theta_draw_dev))./3)))) .^ (1./v);
            sqrtJ2 = f11 * f22; rho = sqrt(2) * sqrtJ2;
            theta_plot = theta_draw_dev - rotation_theta2 - 1*pi/3;
            x = rho .* cos(theta_plot); y = rho .* sin(theta_plot);
            plot(ax, x, y, 'Color', colors_envelope(int_idx, :), 'LineWidth', 1.5);
        end
    end
    
    rho_p = zeros(length(sigma1), 1); theta_p = zeros(length(sigma1), 1); flag = zeros(length(sigma1), 1);
    for i = 1:length(sigma1)
        [rho_p(i), theta_p(i)] = cal_rho_theta(sigma1(i), sigma2(i), sigma3(i), alpha, gamma, u, v, mi_best, ucs);
        flag(i) = is_in_surface(sigma1(i), sigma2(i), sigma3(i), alpha, gamma, u, v, mi_best, ucs);
    end
    I1 = flag == 1; I2 = flag == 0;
    theta_plot1 = -theta_p(I1) + rotation_theta2; x1 = rho_p(I1) .* cos(theta_plot1); y1 = rho_p(I1) .* sin(theta_plot1);
    theta_plot2 = -theta_p(I2) + rotation_theta2; x2 = rho_p(I2) .* cos(theta_plot2); y2 = rho_p(I2) .* sin(theta_plot2);
    if any(I1), scatter(ax, x1, y1, size_scatter, [0.0000 0.4471 0.7412], 'filled', 'o', 'LineWidth', edge_scatter); end
    if any(I2), scatter(ax, x2, y2, size_scatter, [0.7529 0.0000 0.0000], 'filled', 'o', 'LineWidth', edge_scatter); end
  
    for r = rho_ticks(2:end)
        text(ax, r+max_rho*0.04, 0, sprintf('%d', round(r)), 'FontSize', 10, 'Color', [0.2 0.2 0.2], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'FontWeight', 'bold', 'FontName', 'Times New Roman');
    end
    
    angle_labels_dict = containers.Map([30, 90, 150, 210, 270, 330], {'30°', '90°', '150°', '210°', '270°', '330°'});
    label_radius = max_rho * 1.25;
    for angle_key = [30, 90, 150, 210, 270, 330]
        angle_rad = angle_key * pi/180;
        x_label = label_radius * cos(angle_rad); y_label = label_radius * sin(angle_rad);
        text(ax, x_label, y_label, angle_labels_dict(angle_key), 'FontSize', 11, 'Color', [0.2 0.2 0.2], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontWeight', 'bold', 'FontName', 'Times New Roman');
    end
    
    axis(ax, 'equal'); lim = max_rho * 1.4; xlim(ax, [-lim, lim]); ylim(ax, [-lim, lim]);
    ax.XTick = []; ax.YTick = [];
    ax.XAxis.Visible = 'off'; ax.YAxis.Visible = 'off';
    set(ax, 'FontSize', 11, 'Fontname', 'Times New Roman'); box(ax, 'off'); hold(ax, 'off');
end

function plot_sigma1_sigma2_plane(ax, alpha, gamma, u, v, peak, mi_best, ucs)
    cla(ax, 'reset');
    ax.Color = [1 1 1];
    ax.XAxis.Visible = 'on';
    ax.YAxis.Visible = 'on';
    
    sigma1_exp = peak(:,1); sigma2_exp = peak(:,2); sigma3_exp = peak(:,3);
    tolerance = 5;
    
    sigma3_sorted = sort(sigma3_exp);
    sigma3_unique = sigma3_sorted(1);
    for i = 2:length(sigma3_sorted)
        if abs(sigma3_sorted(i) - sigma3_unique(end)) > tolerance
            sigma3_unique(end+1) = sigma3_sorted(i);
        end
    end
    sigma3_values = sigma3_unique(:);
    n_confining = length(sigma3_values);
    
    max_sigma1_data = max(sigma1_exp); max_sigma2_data = max(sigma2_exp);
    axis_max = max(max_sigma1_data, max_sigma2_data) * 1.1;
    axis_max = ceil(axis_max / 100) * 100;
    
    hold(ax, 'on');
    
    h_envelope = [];
    for i = 1:n_confining
        sigma3 = sigma3_values(i);
        n_pts = 500;
        sigma2_range = linspace(sigma3, axis_max, n_pts);
        sigma1_envelope = NaN(1, n_pts);
        
        for j = 1:n_pts
            sigma2_val = sigma2_range(j);
            try
                sigma1_low = sigma2_val;
                sigma1_high = axis_max * 2;
                f_low = expressions_sigma1_sigma2(sigma1_low, sigma2_val, sigma3, alpha, gamma, u, v, mi_best, ucs);
                f_high = expressions_sigma1_sigma2(sigma1_high, sigma2_val, sigma3, alpha, gamma, u, v, mi_best, ucs);
                if f_low * f_high < 0
                    sigma1_val = solve_sigma1_bisection(sigma1_low, sigma1_high, sigma2_val, sigma3, alpha, gamma, u, v, mi_best, ucs, 1e-6);
                    if sigma1_val >= sigma2_val && isfinite(sigma1_val)
                        sigma1_envelope(j) = sigma1_val;
                    end
                end
            catch
            end
        end
        
        valid_idx = ~isnan(sigma1_envelope);
        sigma2_valid = sigma2_range(valid_idx);
        sigma1_valid = sigma1_envelope(valid_idx);
        
        if length(sigma2_valid) < 3
            continue;
        end
        
        n_valid = length(sigma2_valid);
        keep_mask = true(1, n_valid);
        
        if n_valid > 2
            for k = 2:n_valid
                ds2 = sigma2_valid(k) - sigma2_valid(k-1);
                ds1 = sigma1_valid(k) - sigma1_valid(k-1);
                if abs(ds2) < 1e-10
                    ds2 = 1e-10;
                end
                slope_val = abs(ds1 / ds2);
                if slope_val > 50
                    keep_mask(k) = false;
                    keep_mask(k-1) = false;
                end
            end
        end
        
        sigma2_clean = sigma2_valid(keep_mask);
        sigma1_clean = sigma1_valid(keep_mask);
        
        if length(sigma2_clean) < 2
            continue;
        end
        
        n_clean = length(sigma1_clean);
        keep_mask2 = true(1, n_clean);
        
        if n_clean > 4
            for k = 3:n_clean-2
                local_vals = sigma1_clean(k-2:k+2);
                local_med = median(local_vals);
                local_range = max(local_vals) - min(local_vals);
                if abs(sigma1_clean(k) - local_med) > max(local_range * 0.5, 50)
                    keep_mask2(k) = false;
                end
            end
        end
        
        sigma2_final = sigma2_clean(keep_mask2);
        sigma1_final = sigma1_clean(keep_mask2);
        
        for k = 1:length(sigma1_final)
            if sigma1_final(k) < sigma2_final(k)
                sigma2_final = sigma2_final(1:k);
                sigma1_final = sigma1_final(1:k);
                sigma1_final(end) = sigma2_final(end);
                break;
            end
        end
        
        if length(sigma2_final) > 1
            h = plot(ax, sigma2_final, sigma1_final, 'b-', 'LineWidth', 1.2);
            if isempty(h_envelope)
                h_envelope = h;
            end
        end
    end
    
    plot(ax, [0, axis_max], [0, axis_max], 'k', 'LineWidth', 0.5);
    
    sigma3_draw = linspace(0, axis_max, 500)';
    sigma1_draw = sigma3_draw + sqrt(mi_best * ucs * sigma3_draw + ucs^2);
    valid_hb = sigma1_draw <= axis_max;
    plot(ax, sigma3_draw(valid_hb), sigma1_draw(valid_hb), 'r-', 'LineWidth', 1);
    
    base_markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*'};
    base_colors = [0.00,0.45,0.74; 0.85,0.33,0.10; 0.93,0.69,0.13; 0.49,0.18,0.56; 0.47,0.67,0.19;
                   0.30,0.75,0.93; 0.64,0.08,0.18; 0.00,0.50,0.00; 1.00,0.00,1.00; 0.00,0.75,0.75];
    
    markers = cell(1, n_confining); colors = zeros(n_confining, 3);
    for i = 1:n_confining
        markers{i} = base_markers{mod(i-1, length(base_markers)) + 1};
        colors(i, :) = base_colors(mod(i-1, size(base_colors, 1)) + 1, :);
    end
    
    h_exp = cell(n_confining, 1);
    for i = 1:n_confining
        group_idx = abs(sigma3_exp - sigma3_values(i)) <= tolerance;
        if any(group_idx)
            h_exp{i} = plot(ax, sigma2_exp(group_idx), sigma1_exp(group_idx), markers{i}, ...
                'MarkerSize', 7, 'MarkerEdgeColor', colors(i, :), 'MarkerFaceColor', colors(i, :), 'LineWidth', 1);
        end
    end
    
    xlabel(ax, '\sigma_2 (MPa)', 'FontSize', 12, 'FontName', 'Times New Roman');
    ylabel(ax, '\sigma_1 (MPa)', 'FontSize', 12, 'FontName', 'Times New Roman');
    
    set(ax, 'XLim', [0, axis_max], 'YLim', [0, axis_max]);
    tick_interval = calculate_tick_interval(axis_max);
    ticks = 0:tick_interval:axis_max;
    set(ax, 'XTick', ticks, 'YTick', ticks);
    set(ax, 'DataAspectRatio', [0.5, 0.8, 0.8]);
    set(ax, 'XLim', [0, axis_max], 'YLim', [0, axis_max]);
    
    legend_entries = {}; legend_handles = [];
    for i = 1:n_confining
        if ~isempty(h_exp{i})
            if sigma3_values(i) == 0
                legend_entries{end+1} = '0 MPa (Uniaxial)';
            else
                legend_entries{end+1} = sprintf('%.0f MPa', sigma3_values(i));
            end
            legend_handles(end+1) = h_exp{i};
        end
    end
    if ~isempty(h_envelope)
        legend_entries{end+1} = 'Best-fit envelope';
        legend_handles(end+1) = h_envelope;
    end
    if ~isempty(legend_handles)
        lgd = legend(ax, legend_handles, legend_entries, 'Location', 'southeast', 'FontSize', 10, 'FontName', 'Times New Roman');
        lgd.Box = 'off';
    end
    
    set(ax, 'FontSize', 12, 'FontName', 'Times New Roman');
    grid(ax, 'on'); box(ax, 'on'); hold(ax, 'off');
end

function tick_interval = calculate_tick_interval(axis_max)
    target_ticks = 6; raw_interval = axis_max / target_ticks;
    magnitude = 10^floor(log10(raw_interval)); normalized = raw_interval / magnitude;
    if normalized <= 1.5, nice_interval = 1;
    elseif normalized <= 3, nice_interval = 2;
    elseif normalized <= 7, nice_interval = 5;
    else, nice_interval = 10; end
    tick_interval = nice_interval * magnitude;
end

function sigma1 = solve_sigma1_bisection(a, b, sigma2, sigma3, alpha, gamma, u, v, mi, ucs, tol)
    for k = 1:100
        sigma1 = (a + b) / 2;
        fp = expressions_sigma1_sigma2(sigma1, sigma2, sigma3, alpha, gamma, u, v, mi, ucs);
        if abs(fp) < tol || (b - a) / 2 < tol, break; end
        fa = expressions_sigma1_sigma2(a, sigma2, sigma3, alpha, gamma, u, v, mi, ucs);
        if fa * fp < 0, b = sigma1; else, a = sigma1; end
    end
end

function [rho_p, theta_p] = cal_rho_theta(sigma1, sigma2, sigma3, alpha, gamma, u, v, mi_best, ucs)
    I1 = (sigma1 + sigma2 + sigma3);
    rho_p = norm([sigma1 - I1/3, sigma2 - I1/3, sigma3 - I1/3]);
    theta = atan((sqrt(3) * (sigma2 - sigma3)) ./ (2*sigma1 - sigma2 - sigma3));
    f1 = (-mi_best*ucs + sqrt((mi_best*ucs)^2 + 12*mi_best*ucs*I1 + 36*ucs^2)) / (6*sqrt(3));
    f2 = (-sin((alpha*pi/6 + pi + (acos(gamma)/3)))) .^ (1./u) ./ (sin((alpha*pi/6 + (acos(gamma*cos(3*theta))./3)))) .^ (1./v);
    sqrtJ2 = f1 * f2; rho = sqrt(2) * sqrtJ2;
    [sg1, sg2, sg3] = cal_sigma(I1, rho/sqrt(2), theta, pi/6);
    delta = (sg1 - sigma1).^2 + (sg2 - sigma2).^2 + (sg3 - sigma3).^2;
    [~, I] = min(delta); theta_p = theta(I);
end

function [sigma1, sigma2, sigma3] = cal_sigma(I1, J2, theta, theta0)
    rho = sqrt(2) * J2;
    sigma1 = sqrt(2/3) .* rho .* cos(theta + theta0 + pi*2/3) + I1/3;
    sigma2 = sqrt(2/3) .* rho .* cos(theta + theta0 - pi*2/3) + I1/3;
    sigma3 = sqrt(2/3) .* rho .* cos(theta + theta0) + I1/3;
end

function flag = is_in_surface(sigma1, sigma2, sigma3, alpha, gamma, u, v, mi_best, ucs)
    I1 = (sigma1 + sigma2 + sigma3);
    rho_p = norm([sigma1 - I1/3, sigma2 - I1/3, sigma3 - I1/3]);
    theta = atan((sqrt(3) * (sigma2 - sigma3)) ./ (2*sigma1 - sigma2 - sigma3));
    f1 = (-mi_best*ucs + sqrt((mi_best*ucs)^2 + 12*mi_best*ucs*I1 + 36*ucs^2)) / (6*sqrt(3));
    f2 = (-sin((alpha*pi/6 + pi + (acos(gamma)/3)))) .^ (1./u) ./ (sin((alpha*pi/6 + (acos(gamma*cos(3*theta))./3)))) .^ (1./v);
    sqrtJ2 = f1 * f2; rho = sqrt(2) * sqrtJ2;
    [sg1, sg2, sg3] = cal_sigma(I1, rho/sqrt(2), theta, pi/6);
    delta = (sg1 - sigma1).^2 + (sg2 - sigma2).^2 + (sg3 - sigma3).^2;
    [~, I] = min(delta);
    rho2 = norm([sg1(I) - I1/3, sg2(I) - I1/3, sg3(I) - I1/3]);
    flag = 0; if rho2 >= rho_p, flag = 1; end
end

function y = expressions_sigma1_sigma2(sigma1, sigma2, sigma3, alpha, gamma, u, v, mi, ucs)
    I1_val = sigma1 + sigma2 + sigma3;
    sqrtJ2_val = sqrt(((sigma1-sigma2)^2 + (sigma2-sigma3)^2 + (sigma1-sigma3)^2) / 6);
    if sqrtJ2_val < 1e-10, y = 0; return; end
    denominator = 2*sigma1 - sigma2 - sigma3;
    if abs(denominator) < 1e-10, theta_val = 0;
    else, theta_val = atan((sqrt(3)*(sigma2-sigma3)) / denominator); end
    term1 = (-mi*ucs + sqrt((mi*ucs)^2 + 12*mi*ucs*I1_val + 36*ucs^2)) / (6*sqrt(3));
    acos_arg = gamma * cos(3*theta_val);
    acos_arg = max(-1, min(1, acos_arg));
    term2 = (-sin(alpha*pi/6 + pi + acos(gamma)/3))^(1/u);
    term3 = (sin(alpha*pi/6 + acos(acos_arg)/3))^(1/v);
    if abs(term3) < 1e-10, term3 = 1e-10; end
    y = sqrtJ2_val - term1 * term2 / term3;
end