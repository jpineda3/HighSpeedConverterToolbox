classdef Version
    %Version
    %   BSP Version information
    properties(Constant)
        HDL = 'hdl_2021_r2';
        Vivado = '2021.2';
        MATLAB = 'R2022a';
        Release = '22.2.1';
        AppName = 'Analog Devices, Inc. High-Speed Converter Toolbox';
        ToolboxName = 'HighSpeedConverterToolbox';
        ToolboxNameShort = 'hsx';
        ExamplesDir = 'hsx_examples';
        HasHDL = true;
    end
    properties(Dependent)
        VivadoShort
    end
    
    methods
        function value = get.VivadoShort(obj)
            value = obj.Vivado(1:6); 
        end
    end
end

