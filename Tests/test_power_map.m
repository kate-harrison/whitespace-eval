% Test power_map


clc; clear all; close all;

for model = [1]
    bpsHz = 0.5;
    p = 2000;
    power_type = 'none';
    stage = 'power_map';
    char_label = generate_label('char', 30, 0);
    jam_label = generate_label('jam', stage, model, 'none', char_label, bpsHz, p)
    filename = generate_filename(jam_label);
    load(filename);
    
        
    channel = 21
    ch_idx = get_channel_index(channel);
    
%     close all;
    map = get_W_to_dBm(squeeze(new_power_map(ch_idx,:,:)));
    figure; imagesc(map); colorbar; axis xy;
    title('New power map');
    
    
    map = get_W_to_dBm(squeeze(old_power_map(ch_idx,:,:)));
    figure; imagesc(map); colorbar; axis xy;
    title('Old power map');
    
    map = get_W_to_dBm(squeeze(flat_power_map2(ch_idx,:,:)));
    figure; imagesc(map); colorbar; axis xy;
    title('Flat2 power map');
    
    map = get_W_to_dBm(squeeze(flat_power_map3(ch_idx,:,:)));
    figure; imagesc(map); colorbar; axis xy;
    title('Flat3 power map');
    
end