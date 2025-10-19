function sstv_scottie1
    fs = 48000;
    img = imread("6322043_People_thumb.jpg");
    img = imresize(img, [256, 320]);

    R = double(img(:,:,1));
    G = double(img(:,:,2));
    B = double(img(:,:,3));

    signal = [];
    phase = 0;

    vox_freqs = [1900,1500,1900,1500,2300,1500,2300,1500];

    for f = vox_freqs
        [tone_sig, phase] = tone(f, 100, fs, phase);
        signal = [signal, tone_sig];
    end

    [tone_sig, phase] = tone(1900, 300, fs, phase); signal = [signal, tone_sig];
    [tone_sig, phase] = tone(1200, 10, fs, phase);  signal = [signal, tone_sig];
    [tone_sig, phase] = tone(1900, 300, fs, phase); signal = [signal, tone_sig];
   
    vis = [0 0 1 1 1 1 0];
    [tone_sig, phase] = tone(1200, 30, fs, phase); signal = [signal, tone_sig];
    
    for i = 1:7
        freq = 1100 + 200 * vis(i);
        [tone_sig, phase] = tone(freq, 30, fs, phase);
        signal = [signal, tone_sig];
    end
    
    parity = mod(sum(vis), 2);
    
    [tone_sig, phase] = tone(1100 + 200*parity, 30, fs, phase); signal = [signal, tone_sig];
    [tone_sig, phase] = tone(1200, 30, fs, phase); signal = [signal, tone_sig];
    [tone_sig, phase] = tone(1200, 9, fs, phase); signal = [signal, tone_sig];
    
    for y = 1:size(G,1)
        [tone_sig, phase] = tone(1500, 1.5, fs, phase); signal = [signal, tone_sig];
        [line_sig, phase] = scan_color_line(G(y,:), fs, phase); signal = [signal, line_sig];
        
        [tone_sig, phase] = tone(1500, 1.5, fs, phase); signal = [signal, tone_sig];
        [line_sig, phase] = scan_color_line(B(y,:), fs, phase); signal = [signal, line_sig];
        
        [tone_sig, phase] = tone(1200, 9, fs, phase); signal = [signal, tone_sig];
        
        [tone_sig, phase] = tone(1500, 1.5, fs, phase); signal = [signal, tone_sig];
        [line_sig, phase] = scan_color_line(R(y,:), fs, phase); signal = [signal, line_sig];
    end
   
    signal = signal / max(abs(signal));
    audiowrite("scottie1_output.wav", signal, fs);
    sound(signal, fs);
end

function [s, last_phase] = tone(freq, duration_ms, fs, start_phase)
    N = round(duration_ms * fs / 1000);
    t = (0:N-1) / fs;
    phase = 2 * pi * freq * t + start_phase;
    s = sin(phase);
    last_phase = mod(phase(end) + 2*pi*freq/fs, 2*pi);
end

function [line_sig, phase_out] = scan_color_line(color_line, fs, phase_in)
    freqs = 1500 + 3.1372549 * color_line(:)';
    line_duration = 138.24 / 1000;
    samples = round(fs * line_duration);
   
    t = (0:samples-1) / fs;
    pixel_edges = linspace(0, line_duration, 321);
    line_sig = zeros(1, samples);
    phase = phase_in;
    
    for i = 1:320
        mask = t >= pixel_edges(i) & t < pixel_edges(i+1);
        t_seg = t(mask) - pixel_edges(i);
        f = freqs(i);
        line_sig(mask) = sin(2 * pi * f * t_seg + phase);
        seg_duration = pixel_edges(i+1) - pixel_edges(i);
        phase = mod(2 * pi * f * seg_duration + phase, 2 * pi);
    end
    phase_out = phase;
end
