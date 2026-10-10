function run_mmchb_results
% Standalone execution driver. Original algorithms and model are embedded below.
% Only convergence visualization and PNG export differ from the original app.
baseDir = fileparts(mfilename('fullpath'));
projectDir = 'D:/Software programs and data';
sourcePath = fullfile(projectDir, 'MMCHB_criterion.m');
sourceBefore = fileread(sourcePath);
logFile = fullfile(baseDir, 'matlab_run.log');
diary(logFile); logCleanup = onCleanup(@() diary('off'));
seed = 20261010; pop_size = 30; max_iter = 100; mi = 33.28; ucs = 257;
peak = readmatrix(fullfile(projectDir, 'Dunham dolomite.xlsx'));
assert(isequal(size(peak),[53 3]) && all(isfinite(peak(:))), 'Invalid input data');
assert(all(peak(:,1)>=peak(:,2) & peak(:,2)>=peak(:,3)), 'Invalid stress order');
assert(isequal(peak,readmatrix(fullfile(projectDir,'Dunham dolomite.txt'))), 'Input formats disagree');
assert(peak(1,1)==ucs && all(peak(1,2:3)==0), 'UCS point mismatch');
app = struct('peak',peak); lb = [1 0 1 1]; ub = [1 1 4 4]; dim = 4;
names = {'DBO','PSO','SSA','HHO','SABO','POA'};
optimizers = {@DBO_algorithm,@PSO_algorithm,@SSA_algorithm,@HHO_algorithm,@SABO_algorithm,@POA_algorithm};
scores = zeros(6,1); positions = zeros(6,4); times = zeros(6,1); evalCounts = zeros(6,1);
curves = struct(); evalCount = 0;
rng(seed,'twister'); rngInitial = rng;
for k = 1:6
    evalCount = 0; timer = tic;
    [scores(k),positions(k,:),curve] = optimizers{k}(pop_size,max_iter,lb,ub,dim,@countedObjective);
    times(k) = toc(timer); evalCounts(k) = evalCount;
    assert(isreal(scores(k)) && isfinite(scores(k)), 'Invalid algorithm score');
    assert(all(positions(k,:)>=lb & positions(k,:)<=ub), 'Parameter out of bounds');
    assert(numel(curve)==max_iter && all(isfinite(curve)) && all(curve>0), 'Invalid curve');
    assert(all(diff(curve)<=1e-12) && abs(curve(end)-scores(k))<1e-10, 'Best score curve mismatch');
    assert(abs(fitness_function(app,positions(k,:),mi,ucs)-scores(k))<1e-10, 'Objective score mismatch');
    curves.(names{k}) = curve;
    fprintf('%s: S=%.12f%% alpha=%.12g gamma=%.12g u=%.12g v=%.12g evaluations=%d elapsed=%.3fs\n',names{k},scores(k),positions(k,:),evalCounts(k),times(k));
end
rngFinal = rng;
% Repeat the entire same six-algorithm sequence, rather than reseeding each algorithm.
rng(seed,'twister'); repeatable = true;
for k = 1:6
    [s,p,c] = optimizers{k}(pop_size,max_iter,lb,ub,dim,@countedObjective);
    repeatable = repeatable && isequal(s,scores(k)) && isequal(p,positions(k,:)) && isequal(c,curves.(names{k}));
end
assert(repeatable,'Fixed-seed repeatability check failed');
fprintf('REPEATABILITY: exact equality for all six scores, parameters and 100-point curves.\n');
Best_pos = positions(6,:); Best_score = scores(6); UsedAlgorithm = 'POA';
algorithmTable = table(names',scores,positions(:,1),positions(:,2),positions(:,3),positions(:,4),evalCounts,times,...
    'VariableNames',{'Algorithm','S_percent','Alpha','Gamma','U','V','ObjectiveEvaluations','ElapsedSeconds'});
writetable(algorithmTable,fullfile(baseDir,'algorithm_results.csv'));
parameterTable = table({UsedAlgorithm},mi,ucs,Best_pos(1),Best_pos(2),Best_pos(3),Best_pos(4),Best_score,seed,pop_size,max_iter,...
    'VariableNames',{'Algorithm','mi','UCS_MPa','Alpha','Gamma','U','V','S_percent','Seed','Population','Iterations'});
writetable(parameterTable,fullfile(baseDir,'fit_parameters.csv'));
curveMatrix = zeros(max_iter,7); curveMatrix(:,1) = (1:max_iter)';
for k=1:6, curveMatrix(:,k+1)=curves.(names{k})'; end
writetable(array2table(curveMatrix,'VariableNames',[{'Iteration'} names]),fullfile(baseDir,'convergence_curves.csv'));
writetable(array2table(peak,'VariableNames',{'Sigma1_MPa','Sigma2_MPa','Sigma3_MPa'}),fullfile(baseDir,'input_data.csv'));
I1 = sum(peak,2);
sqrtJ2 = sqrt(((peak(:,1)-peak(:,2)).^2+(peak(:,1)-peak(:,3)).^2+(peak(:,2)-peak(:,3)).^2)/6);
theta = atan(sqrt(3)*(peak(:,2)-peak(:,3))./(2*peak(:,1)-peak(:,2)-peak(:,3)));
a=Best_pos(1); g=Best_pos(2); u=Best_pos(3); v=Best_pos(4);
f1=(-mi*ucs+sqrt((mi*ucs)^2+12*mi*ucs*I1+36*ucs^2))/(6*sqrt(3));
f2=(-sin(a*pi/6+pi+acos(g)/3))^(1/u)./sin(a*pi/6+acos(g*cos(3*theta))/3).^(1/v);
predicted=f1.*f2; residual=sqrtJ2-predicted;
rmse=sqrt(mean(residual.^2)); assert(abs(rmse/mean(sqrtJ2)*100-Best_score)<1e-10);
writetable(table(I1,sqrtJ2,predicted,residual,theta*180/pi,'VariableNames',{'I1_MPa','MeasuredSqrtJ2_MPa','PredictedSqrtJ2_MPa','Residual_MPa','Theta_deg'}),fullfile(baseDir,'point_diagnostics.csv'));
plotNames = {'envelope_3d.png','deviatoric_plane.png','sigma1_sigma2_plane.png','convergence_curves.png'};
plotStats = struct([]);
for k=1:4
    fig=figure('Visible','off','Color','white','Position',[100 100 1200 900]);
    figCleanup=onCleanup(@() close(fig));
    ax=axes(fig,'Position',[.10 .10 .80 .80]);
    switch k
        case 1, plot_3d_surface_in_axes(ax,a,g,u,v,peak,mi,ucs);
        case 2, plot_polar_diagram_enhanced(ax,a,g,u,v,peak,mi,ucs);
        case 3, plot_sigma1_sigma2_plane(ax,a,g,u,v,peak,mi,ucs);
        case 4, plot_full_convergence(ax,curves,max_iter,names);
    end
    assert(~isempty(ax.Children),'Empty plot');
    plotStats(k).file=plotNames{k}; plotStats(k).objects=numel(ax.Children);
    plotStats(k).yScale=ax.YScale;
    if k==3
        h=findobj(ax,'Type','line','Color',[0 0 1]);
        plotStats(k).envelopeCurves=numel(h); assert(numel(h)>=1,'No plane envelope found');
    end
    if k==4
        h=findobj(ax,'Type','line');
        assert(numel(h)==6 && all(arrayfun(@(x) numel(x.XData)==100,h)),'Incomplete convergence curves');
        assert(strcmp(ax.YScale,'log'),'Convergence scale is not logarithmic');
    end
    drawnow;
    set(fig,'PaperUnits','inches','PaperPosition',[0 0 12 9],'PaperSize',[12 9],'PaperPositionMode','manual');
    path=fullfile(baseDir,plotNames{k}); print(fig,path,'-dpng','-r150');
    info=imfinfo(path); image=imread(path);
    assert(info.Width==1800 && info.Height==1350,'Unexpected PNG dimensions');
    assert(double(max(image(:)))-double(min(image(:)))>100,'Blank PNG');
    plotStats(k).width=info.Width; plotStats(k).height=info.Height;
    plotStats(k).bytes=dir(path).bytes;
    fprintf('PNG verified: %s %dx%d, %d bytes\n',plotNames{k},info.Width,info.Height,plotStats(k).bytes);
    clear figCleanup;
end
assert(strcmp(sourceBefore,fileread(sourcePath)),'Original source changed during run');
settings=struct('seed',seed,'rngType','twister','population',pop_size,'iterations',max_iter,'mi',mi,'ucs_MPa',ucs,'mainAlgorithm','POA','algorithmOrder',{names},'dataRows',size(peak,1),'alphaFixed',true,'matlabVersion',version);
save(fullfile(baseDir,'run_results.mat'),'settings','peak','scores','positions','curves','evalCounts','times','Best_pos','Best_score','UsedAlgorithm','rngInitial','rngFinal','plotStats','rmse');
summary=struct('settings',settings,'algorithms',table2struct(algorithmTable),'mainParameters',Best_pos,'mainScorePercent',Best_score,'sqrtJ2RMSE_MPa',rmse,'repeatabilityExact',repeatable,'sourceUnmodifiedDuringRun',true,'plots',plotStats);
fid=fopen(fullfile(baseDir,'run_summary.json'),'w','n','UTF-8'); assert(fid>0); fprintf(fid,'%s',jsonencode(summary,'PrettyPrint',true)); fclose(fid);
fprintf('RUN_COMPLETE POA S=%.12f%%\n',Best_score);
    function score = countedObjective(x)
        evalCount=evalCount+1;
        score=fitness_function(app,x,mi,ucs);
    end
end

function plot_full_convergence(ax,curves,max_iter,names)
% Display-only change: all points, explicit log axis, sparse markers.
cla(ax,'reset'); hold(ax,'on');
colors=[.4391 .1882 .6275;0 .4392 .7529;1 .7529 0;0 .6902 .9412;.851 .3255 .098;.6431 .8157 .3137];
markers={'v','^','h','s','o','d'};
for k=1:numel(names)
    plot(ax,1:max_iter,curves.(names{k}),'Color',colors(k,:),'LineWidth',1.5,'Marker',markers{k},'MarkerIndices',unique(round(linspace(1,max_iter,10))),'DisplayName',names{k});
end
ax.YScale='log'; ax.FontName='Times New Roman'; ax.FontSize=12;
xlabel(ax,'Iteration'); ylabel(ax,'Normalized RMSE S (%)');
legend(ax,'Location','northeast'); grid(ax,'on'); box(ax,'on'); xlim(ax,[1 max_iter]);
hold(ax,'off');
end

% Original objective method, used with a peak-bearing struct.
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

% Original algorithms and geometry helpers, unchanged.
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