function [ ck , ck_abs ] = funct_fft( signal, f_base, f_adc , harm, k_in, inform )
% версия от 07.06.2018 v1.2 с технологической информацией

% signal - исходный сигнал (вектор)
% win_tipe - тип окна используемого для преобразования
% f_base - базовая частота исследуемого сигнала
% f_adc - частота дискретизации АЦП
% ck - комплексный массив действующих значений k-той гармоники сигнала
% ck_rms - действующее значение k-той гармоники сигнала

% инициализация переменных
if (strcmp(harm ,'Harm'))
    k = k_in;
else
    k = 1;  % номер иследуемой гармоники
end
ck = zeros(size(signal));
ck_abs = zeros(size(signal));
points = int32(f_adc/f_base);  % максимальное число точек на период
buffer = 0; % буффер промежуточных значений

for i = 1:1:size(signal,1)
    % инициализация коэффициентов k-той гармоники
    ak = 0; % действительная часть
    bk = 0; % мнимая часть
    
    % заполнение буффера значениями из массива
    if (i < points )
        buffer(1:i,1) = signal(1:i,1);
    else
        buffer(1:points,1) = signal((i - points + 1):1:i,1);
    end
    
    % определение количества точек в буфере
    Nt = size(buffer,1);
    
    for j = 1:1:Nt
        
        % определение типа окна для преобразования
        win = 1;    % прямоугольная форма окна
        
        % вычисление коэффициентов
        ak = ak + win*buffer(j,1)*cos(k*2*pi*(j-1)/Nt);
        bk = bk + win*buffer(j,1)*sin(k*2*pi*(j-1)/Nt);
    end
    
    % определение Ck_rms и ck значения для k-той гармоники сигнала
    ck_abs(i,1) = sqrt(2*((ak/Nt)^2 + (bk/Nt)^2));
    ck(i,1) = complex(sqrt(2)*ak/Nt,sqrt(2)*bk/Nt);
    
    if (strcmp(inform, 'info'))
        progress = double(i)/double(size(signal,1))*100;
        disp(['Progress: ', progress, ' abs val: ', num2str(ck_abs(i,1))]); 
    end
end
end