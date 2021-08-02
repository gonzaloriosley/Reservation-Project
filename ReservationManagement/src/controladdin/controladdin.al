controladdin D3
{
    Scripts = 'src/script/d3.min.js',
    'src/script/plotly-2.2.0.min.js',
    'src/script/script.js';

    StartupScript = 'src/script/startup.js';

    HorizontalStretch = true;
    VerticalStretch = true;
    //MinimumWidth = 1118;
    //MinimumHeight = 772;
    event ControlReady();

    procedure Refresh(data: text);

}