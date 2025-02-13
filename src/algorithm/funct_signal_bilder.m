function [ signal_struct ] = funct_signal_bilder( arr_sig, arr_time, kt, type_sig )
    % revision: 21.12.2018
    signal_struct.type = type_sig;
    [ signal_struct.size, signal_struct.phase ]= size(arr_sig);
    signal_struct.time(:,:) = arr_time;
    signal_struct.sig(:,:) = arr_sig./kt;
end