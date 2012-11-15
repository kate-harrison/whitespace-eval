function [] = fig_rate_maps(label)

is_in_us = get_us_map('200x300', 1);

switch(label.label_type)
    case 'jam',
        original_type = label.power_type;
        
        skip = 0;
        scale = 1e6;
        colorbar_label = 'Mbps';
        switch(label.model)
            case {2,4}, max_val = 12000;
            case {0,1,3}, max_val = 750;
        end
        

        
        for i = 1:2
            temp_label = label;
            switch(i)
                case 1, power_type = label.power_type; %    'new_power'; -- don't change, this way it can be new_power or flat
                case 2, power_type = 'old_dream';
                        if (label.hybrid)
                            temp_label.p = label.p2;
                            temp_label.hybrid = false;
                        end
            end
            temp_label.power_type = power_type;
            label.power_type = power_type;
            filename = generate_filename(temp_label);
            if (~exist(filename, 'file'))
                display(['SKIPPING ' filename]);
                skip = 1;
                continue;
            end
            
            display(['Loading ' filename]);
            load(filename, 'fair_rate_map');
            
            map = aggregate_bands(fair_rate_map);
            map(~is_in_us) = inf;
            
            
            fn = generate_filename(label);
            make_map(map/scale, 'map_type', 'log', 'colorbar_title', colorbar_label, 'filename', fn, 'scale', max_val);
            
%             label.power_type = [power_type '_ccdf'];
%             plot_ccdf(map/scale, colorbar_label, generate_filename(label.power_type));
            
%             return;
            
            
            switch(i)
                case 1, new_rate = map;
                case 2, old_rate = map;
            end
            
%             close all;
        end
        
        if ~skip
            ratio = new_rate ./ old_rate;
            ratio(~is_in_us) = inf;
            
            label.power_type = [original_type '_ratio'];
            fn = generate_filename(label);
            make_map(ratio, 'map_type', 'log', 'colorbar_title', 'Ratio', 'filename', fn, 'scale', 1.3);

%             label.power_type = [original_type '_ratioccdf'];
%             plot_ccdf(ratio, 'Ratio', 'area');
%             axis([0 1.0001 0 1]);
%             save_plot('png', generate_filename(label));
        end
        
        
        
end

end