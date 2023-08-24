% [Project]        DMP Comparison - Video Generation
% [Author]         Moses C. Nah
% [Creation Date]  Monday, Oct. 23th, 2022
%
% [Emails]         Moses C. Nah   : mosesnah@mit.edu

%% (--) INITIALIZATION

clear; close all; clc; workspace;

% Add the Libraries of 
addpath( 'MATLAB_Library/myUtils', 'MATLAB_Library/myGraphics' )

cd( fileparts( matlab.desktop.editor.getActiveFilename ) );     
myFigureConfig( 'fontsize',  20, ...
               'LineWidth',  10, ...
           'AxesLineWidth', 1.5, ...     For Grid line, axes line width etc.
              'markerSize',  25    )  
             
global c                                                                   % Setting color structure 'c' as global variable
c  = myColor(); 


%% ==================================================================
%% (--) Goal directed Discrete Movement - Task-space #1
clear data*; clc;

data_imp1  = load( 'data/kinematics_superposition_1/task_imp1.mat'  );       % First  imp
data_imp2  = load( 'data/kinematics_superposition_1/task_imp2.mat'  );       % Second imp
data_imp12 = load( 'data/kinematics_superposition_1/task_imp12.mat' );       % 1st + 2nd imp

idx = 3;

if idx == 1
    data = data_imp1;
    ctmp = c.blue;
elseif idx == 2
    data = data_imp2;
    ctmp = c.orange;
elseif idx == 3
    data_tmp1 = data_imp1;
    data_tmp2 = data_imp2;
    data = data_imp12;    
    ctmp = c.green;
end

[ N, ~ ] = size( data.q_arr );

dt = 0.001;

t_arr = dt * (0:(N-1));

% Change to absolute angle
q_abs  = cumsum( data.q_arr, 2 );

xSH = zeros( 1, N );
ySH = zeros( 1, N );
zSH = zeros( 1, N );

jSize = 1400;

% Shoulder
gObjs(  1 ) = myMarker( 'XData', xSH, 'YData', ySH, 'ZData', zSH, ... 
                         'name', "SH"  , 'SizeData',  jSize      , ...
                      'LineWidth',  5      , ...
              'MarkerEdgeColor', c.purple_plum, ...
              'MarkerFaceColor', c.white, ...
              'MarkerFaceAlpha', 1.0       );                      
          
% Elbow
xEL = cos( q_abs( :, 1 ) )';
yEL = sin( q_abs( :, 1 ) )';
zEL = zSH;

    
gObjs( 2 ) = myMarker( 'XData', xEL, 'YData', yEL, 'ZData', zEL, ... 
                         'name', "EL"  , 'SizeData',  jSize      , ...
                    'LineWidth',  5       , ...
              'MarkerEdgeColor', c.purple_plum, ...
              'MarkerFaceColor', c.white, ...
              'MarkerFaceAlpha', 1.0       );      
                             

% Shoulder
xEE = xEL + cos( q_abs( :, 2 ) )';
yEE = yEL + sin( q_abs( :, 2 ) )';
zEE = zSH;
          
          
% End Effector
gObjs( 3 ) = myMarker( 'XData', xEE, 'YData', yEE, 'ZData', zEE, ... 
                         'name', "EE"  , 'SizeData',  jSize      , ...
                    'LineWidth',  5      , ...
              'MarkerEdgeColor', c.purple_plum, ...
              'MarkerFaceColor', c.white, ...
              'MarkerFaceAlpha', 1.0       );     
          
ani = myAnimation( dt, gObjs );   

ani.connectMarkers( 1, [ "SH", "EL","EE" ], 'Color', 0.3 * ones( 1,3 ), 'LineStyle',  '-' ); 

ani.adjustFigures( 2 );                     
a2 = ani.hAxes{ 2 };
plot( t_arr, data.dp_arr( :, 1 )', 'color', 'k', 'linewidth', 3)
plot( t_arr, data.dp0_arr( :, 1 )', 'color', ctmp, 'linewidth', 5, 'linestyle', '--')
pp = area( a2, t_arr, data.dp0_arr( :, 1 )');

pp.FaceColor = ctmp;
pp.FaceAlpha = 0.5;
pp.EdgeAlpha = 0.0;
pp.BaseLine.Color = [0 0 0];
% area2.BaseLine.LineWidth = 2.5;

if idx == 3
    ptmp = area( a2, t_arr, data_tmp1.dp0_arr( :, 1 )');

    ptmp.FaceColor = c.blue;
    ptmp.FaceAlpha = 0.5;
    ptmp.EdgeAlpha = 0.0;
    ptmp.BaseLine.Color = [0 0 0];

    ptmp = area( a2, t_arr, data_tmp2.dp0_arr( :, 1 )');

    ptmp.FaceColor = c.orange;
    ptmp.FaceAlpha = 0.5;
    ptmp.EdgeAlpha = 0.0;
    ptmp.BaseLine.Color = [0 0 0];    
end

set( a2, 'fontsize', 30, 'xlim' ,[0, 5], 'ylim', [-1.0, 2.0]  )
tmp = myMarker( 'XData', t_arr, 'YData', data.dp_arr( :, 1 )' , 'ZData', zeros( 1, N ), ...
                'SizeData',  300, 'LineWidth', 3 , 'MarkerEdgeColor',  'k' ); 
ani.addTrackingPlots( 2, tmp );
ylabel( ani.hAxes{ 2 }, '$\dot{p}_x(t)$', 'fontsize', 30 )
xlabel( ani.hAxes{ 2 }, '$t$ (sec)', 'fontsize', 30 )

ani.adjustFigures( 3 );                     
a3 = ani.hAxes{ 3 };
plot( t_arr, data.dp_arr( :, 2 )', 'color', 'k', 'linewidth', 3 )
plot( t_arr, data.dp0_arr( :, 2 )', 'color', ctmp, 'linewidth', 5, 'linestyle', '--')

ppp = area( a3, t_arr, data.dp0_arr( :, 2 )');

ppp.FaceColor = ctmp;
ppp.FaceAlpha = 0.5;
ppp.EdgeAlpha = 0.0;
ppp.BaseLine.Color = [0 0 0];

if idx == 3
    ptmp = area( a3, t_arr, data_tmp1.dp0_arr( :, 2 )');

    ptmp.FaceColor = c.blue;
    ptmp.FaceAlpha = 0.5;
    ptmp.EdgeAlpha = 0.0;
    ptmp.BaseLine.Color = [0 0 0];

    ptmp = area( a3, t_arr, data_tmp2.dp0_arr( :, 2 )');

    ptmp.FaceColor = c.orange;
    ptmp.FaceAlpha = 0.5;
    ptmp.EdgeAlpha = 0.0;
    ptmp.BaseLine.Color = [0 0 0];    
end


tmp = myMarker( 'XData', t_arr, 'YData', data.dp_arr( :, 2 )', 'ZData', zeros( 1, N ), ...
                'SizeData',  300, 'LineWidth', 3 , 'MarkerEdgeColor',  'k' ); 
ani.addTrackingPlots( 3, tmp );
ylabel( ani.hAxes{ 3 }, '$\dot{p}_y(t)$', 'fontsize', 30 )

tmpLim = 1.2;
cen = [ 0.0, 0.8 ];
set( ani.hAxes{ 1 }, 'XLim',   [ -tmpLim + cen( 1 ), tmpLim + cen( 1 ) ] , ...                  
                     'YLim',   [ -tmpLim + cen( 2 ), tmpLim + cen( 2 ) ] , ... 
                     'view',   [0, 90]    , 'fontsize', 30 )      

xlabel( ani.hAxes{ 1 }, 'X (m)', 'fontsize', 30 )
ylabel( ani.hAxes{ 1 }, 'Y (m)', 'fontsize', 30 )
set( a3, 'fontsize', 30, 'xlim' ,[0, 5], 'ylim', [-1.0, 2.0]  )

ani.run( 0.5, 1.0, 4.0, true, ['task', num2str( idx )] )

%% (--) Goal directed Discrete Movement - Task-space #2

clear data*; clc;
clear ani;
data_imp1  = load( 'data/kinematics_superposition_2/task_imp_sub.mat'  );       % First  imp
data_imp2  = load( 'data/kinematics_superposition_2/task_imp_osc.mat'  );       % Second imp
data_imp12 = load( 'data/kinematics_superposition_2/task_imp_sub_osc.mat' );       % 1st + 2nd imp

idx = 3;

if idx == 1
    data = data_imp1;
    ctmp = c.blue;
    fiidx = 3;
    iidx = 2;
elseif idx == 2
    data = data_imp2;
    ctmp = c.orange;
    fiidx = 2;
    iidx = 1;
elseif idx == 3
    data_tmp1 = data_imp1;
    data_tmp2 = data_imp2;
    data = data_imp12;    
    ctmp = c.green;
end

[ N, ~ ] = size( data.q_arr );

dt = 0.001;

t_arr = dt * (0:(N-1));

% Change to absolute angle
q_abs  = cumsum( data.q_arr, 2 );

xSH = zeros( 1, N );
ySH = zeros( 1, N );
zSH = zeros( 1, N );

jSize = 1400;

% Shoulder
gObjs(  1 ) = myMarker( 'XData', xSH, 'YData', ySH, 'ZData', zSH, ... 
                         'name', "SH"  , 'SizeData',  jSize      , ...
                      'LineWidth',  5      , ...
              'MarkerEdgeColor', c.purple_plum, ...
              'MarkerFaceColor', c.white, ...
              'MarkerFaceAlpha', 1.0       );                      
          
% Elbow
xEL = cos( q_abs( :, 1 ) )';
yEL = sin( q_abs( :, 1 ) )';
zEL = zSH;

    
gObjs( 2 ) = myMarker( 'XData', xEL, 'YData', yEL, 'ZData', zEL, ... 
                         'name', "EL"  , 'SizeData',  jSize      , ...
                    'LineWidth',  5       , ...
              'MarkerEdgeColor', c.purple_plum, ...
              'MarkerFaceColor', c.white, ...
              'MarkerFaceAlpha', 1.0       );      
                             

% Shoulder
xEE = xEL + cos( q_abs( :, 2 ) )';
yEE = yEL + sin( q_abs( :, 2 ) )';
zEE = zSH;
          
          
% End Effector
gObjs( 3 ) = myMarker( 'XData', xEE, 'YData', yEE, 'ZData', zEE, ... 
                         'name', "EE"  , 'SizeData',  jSize      , ...
                    'LineWidth',  5      , ...
              'MarkerEdgeColor', c.purple_plum, ...
              'MarkerFaceColor', c.white, ...
              'MarkerFaceAlpha', 1.0       );     
          
ani = myAnimation( dt, gObjs );   

ani.connectMarkers( 1, [ "SH", "EL","EE" ], 'Color', 0.3 * ones( 1,3 ), 'LineStyle',  '-' ); 

if idx == 1 || idx == 2
    ani.adjustFigures( fiidx  );                     
    a3 = ani.hAxes{ fiidx };
    plot( t_arr, data.dp_arr( :, iidx )', 'color', 'k', 'linewidth', 3 )
    plot( t_arr, data.dp0_arr( :, iidx )', 'color', ctmp, 'linewidth', 5, 'linestyle', '--')


    ppp = area( a3, t_arr, data.dp0_arr( :, iidx )');
    
    ppp.FaceColor = ctmp;
    ppp.FaceAlpha = 0.5;
    ppp.EdgeAlpha = 0.0;
    ppp.BaseLine.Color = [0 0 0];
end

if idx == 3

    ani.adjustFigures( 3);                     
    a2 = ani.hAxes{ 3 };
    plot( t_arr, data.dp_arr( :, 2 )', 'color', 'k', 'linewidth', 3 )
    plot( t_arr, data.dp0_arr( :, 2 )', 'color', c.blue, 'linewidth', 5, 'linestyle', '--')
    set( a2, 'fontsize', 30, 'xlim' ,[0, 8], 'ylim', [-1.0, 2.0]  )

    ppp = area( a2, t_arr, data.dp0_arr( :, 2 )');
    
    ppp.FaceColor = c.blue;
    ppp.FaceAlpha = 0.5;
    ppp.EdgeAlpha = 0.0;
    ppp.BaseLine.Color = [0 0 0];

    tmp = myMarker( 'XData', t_arr, 'YData', data.dp_arr( :, 2 )', 'ZData', zeros( 1, N ), ...
                    'SizeData',  300, 'LineWidth', 3 , 'MarkerEdgeColor',  'k' ); 
    ani.addTrackingPlots( 3, tmp );    

    ani.adjustFigures( 2 );                     
    a3 = ani.hAxes{ 2 };
    plot( t_arr, data.dp_arr( :, 1 )', 'color', 'k', 'linewidth', 3 )
    plot( t_arr, data.dp0_arr( :, 1 )', 'color', c.orange, 'linewidth', 5, 'linestyle', '--')
    set( a3, 'fontsize', 30, 'xlim' ,[0, 8], 'ylim', [-1.0, 2.0]  )

    tmp = myMarker( 'XData', t_arr, 'YData', data.dp_arr( :, 1 )', 'ZData', zeros( 1, N ), ...
                    'SizeData',  300, 'LineWidth', 3 , 'MarkerEdgeColor',  'k' ); 
    ani.addTrackingPlots( 2, tmp );    
    
end

if idx == 1 || idx == 2
    tmp = myMarker( 'XData', t_arr, 'YData', data.dp_arr( :, iidx )', 'ZData', zeros( 1, N ), ...
                    'SizeData',  300, 'LineWidth', 3 , 'MarkerEdgeColor',  'k' ); 
    ani.addTrackingPlots( fiidx, tmp );
end
if idx == 1
    ylabel( ani.hAxes{ fiidx }, '$\dot{p}_y(t)$', 'fontsize', 30 )
elseif idx == 2
    ylabel( ani.hAxes{ fiidx }, '$\dot{p}_x(t)$', 'fontsize', 30 )
elseif idx == 3
    ylabel( ani.hAxes{ 3 }, '$\dot{p}_y(t)$', 'fontsize', 30 )
    ylabel( ani.hAxes{ 2}, '$\dot{p}_x(t)$', 'fontsize', 30 )
end

tmpLim = 1.2;
cen = [ 0.0, 0.8 ]; 
set( ani.hAxes{ 1 }, 'XLim',   [ -tmpLim + cen( 1 ), tmpLim + cen( 1 ) ] , ...                  
                     'YLim',   [ -tmpLim + cen( 2 ), tmpLim + cen( 2 ) ] , ... 
                     'view',   [0, 90]    , 'fontsize', 30 )      

xlabel( ani.hAxes{ 1 }, 'X (m)', 'fontsize', 30 )
ylabel( ani.hAxes{ 1 }, 'Y (m)', 'fontsize', 30 )

if idx == 3
    set( a3, 'fontsize', 30, 'xlim' ,[0, 13], 'ylim', [-1.0, 2.0]  )
    set( a2, 'fontsize', 30, 'xlim' ,[0, 13], 'ylim', [-1.0, 2.0]  )
end
ani.run( 1.0, 4.0, 13.0, true, ['task', num2str( idx )] )

          