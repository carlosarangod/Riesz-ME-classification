function [Amp_seq,phase_cos_sin_amp,Amplitude_out] = RieszMagnificationAnalysis(Img_seq, low_cutoff, high_cutoff, sampling_rate,amplification_factor,varargin)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initializes spatial smoothing kernel and temporal filtering
    % coefficients.
    % Compute an IIR temporal filter coefficients. Butterworth filter could be replaced
    % with any IIR temporal filter. Lower temporal filter order is faster
    % and uses less memory, but is less accurate. See pages 493-532 of
    % Oppenheim and Schafer 3rd ed for more information
%     setPath;
    p = inputParser();
    default_type_filter = 'low_pass'; %If true, use reference filter 
    default_filt_ord = 14;
    default_sigma = 2;
    default_pyr_level = 2;
    default_pyr_level_ini = 0;

    filTypes = {'low_pass','bandpass'}; 
    checkfiltType = @(x) find(ismember(x, filTypes));
    checkfiltOrd = @(x) (isnumeric(x)&&(mod(x, 2)==0));
    addOptional(p, 'fil_ord', default_filt_ord, checkfiltOrd);
    addOptional(p, 'filType', default_type_filter, checkfiltType);
    addOptional(p, 'sigma', default_sigma, @isnumeric);
    addOptional(p, 'pyr_level', default_pyr_level, @isnumeric);
    addOptional(p, 'pyr_ini', default_pyr_level_ini, @isnumeric);

    parse(p, varargin{:});
    filType  = p.Results.filType;
    tfi_ord  = p.Results.fil_ord;
    sigma    = p.Results.sigma;
    pyr_level = p.Results.pyr_level;
    pyr_level_ini = p.Results.pyr_ini;
    nyquist_frequency = sampling_rate/2;
    if strcmp(filType,'bandpass')
        [B, ~] = fir1(tfi_ord, [low_cutoff/nyquist_frequency,...
        high_cutoff/nyquist_frequency],'bandpass',window(@rectwin,tfi_ord+1)); % bandpass
%         [Bf, Af] = butter(1, [low_cutoff/nyquist_frequency, high_cutoff/nyquist_frequency]);
    elseif strcmp(filType,'low_pass')
        [B, ~] = fir1(tfi_ord, high_cutoff/nyquist_frequency,window(@rectwin,tfi_ord+1)); % low pass
%         [Bf, Af] = butter(2, high_cutoff/nyquist_frequency);
    end
    % Computes convolution kernel for spatial blurring kernel used during
    % quaternionic phase denoising step.
%     gaussian_kernel_sd = 2; % px
%     gaussian_kernel = GetGaussianKernel(gaussian_kernel_sd);
    gaussian_kernel = fspecial('gaussian',[3 3],sigma);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialization of variables before main loop.
    % This initialization is equivalent to assuming the motions are zero
    % before the video starts.
%     previous_frame = GetFirstFrameFromVideo();
    previous_frame = Img_seq(:,:,1);
    [previous_laplacian_pyramid, previous_riesz_x, previous_riesz_y] = ...
    ComputeRieszPyramid(previous_frame);
    number_of_levels = numel(previous_laplacian_pyramid) - 1; % Do not include lowpass residual
    nF = size(Img_seq,3);
%     for k = 1:number_of_levels
    k2 = pyr_level_ini;
%     k2 = number_of_levels - pyr_level;
    filter_flag = false;
    for k = 1:number_of_levels
        % Initializes current value of quaternionic phase. Each coefficient
        % has a two element quaternionic phase that is defined as
        % phase times (cos(orientation), sin(orientation))
        % It is initialized at zero
        phase_cos{k} = zeros(size(previous_laplacian_pyramid{k}));
        phase_sin{k} = zeros(size(previous_laplacian_pyramid{k}));
        phase_cos3{k} = zeros(size(previous_laplacian_pyramid{k}));
        phase_sin3{k} = zeros(size(previous_laplacian_pyramid{k}));
        % Initializes IIR temporal filter values. These values are used during
        % temporal filtering. See the function IIRTemporalFilter for more
        % details. The initialization is a zero motion boundary condition
        % at the beginning of the video.
        
        motion_magnified_laplacian_pyramid{k} = zeros(size(previous_laplacian_pyramid{k}));
        
        register0_cos{k} = zeros([size(previous_laplacian_pyramid{k}) tfi_ord+1]);       
        register0_sin{k} = zeros([size(previous_laplacian_pyramid{k}) tfi_ord+1]);
        register_cos_flip{k} = zeros([size(previous_laplacian_pyramid{k}) tfi_ord+1]);       
        register_sin_flip{k} = zeros([size(previous_laplacian_pyramid{k}) tfi_ord+1]);
        Amplitude_t{k} =  zeros([size(previous_laplacian_pyramid{k}),nF]);
        if k>k2 && k<=k2 + pyr_level
            phase_cos2{k-k2} = zeros(size(previous_laplacian_pyramid{k}));
            phase_sin2{k-k2} = zeros(size(previous_laplacian_pyramid{k}));
            phase_cos_sin_amp{k-k2} = zeros([size(previous_laplacian_pyramid{k}) 2, nF]);
            Amplitude_out{k-k2} = zeros([size(previous_laplacian_pyramid{k}),nF]);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Main loop. It is executed on new frames from the video and runs until
    % stopped.
    z = 0;
    z2 = 1;
    z3 = 2;
    while (z<nF + tfi_ord/2)
        z=z+1;
        if (z<=nF)
            current_frame = Img_seq(:,:,z);
            [current_laplacian_pyramid, current_riesz_x, current_riesz_y] = ...
            ComputeRieszPyramid(current_frame);
        end
        % We compute a Laplacian pyramid of the motion magnified frame first and then
        % collapse it at the end.
        % The processing in the following loop is processed on each level
        % of the Riesz pyramid independently
%         for k = 1:number_of_levels
        for k = 1:number_of_levels
        % Compute quaternionic phase difference between current Riesz pyramid
        % coefficients and previous Riesz pyramid coefficients.
            if z<=nF
                
               [phase_difference_cos, phase_difference_sin, amplitude] = ...
                ComputePhaseDifferenceAndAmplitude(current_laplacian_pyramid{k}, ...
                current_riesz_x{k}, current_riesz_y{k}, previous_laplacian_pyramid{k}, ...
                previous_riesz_x{k}, previous_riesz_y{k});
                % Adds the quaternionic phase difference to the current value of the quaternionic
                % phase.
                % Computing the current value of the phase in this way is
                % equivalent to phase unwrapping.
                phase_cos{k} = phase_cos{k} + phase_difference_cos;
                phase_sin{k} = phase_sin{k} + phase_difference_sin;
                Amplitude_t{k}(:,:,z) = amplitude;
                
                register0_cos{k} = refresh_register(register0_cos{k},tfi_ord+1);
                register0_cos{k}(:,:,tfi_ord+1) = phase_cos{k};
                register0_sin{k} = refresh_register(register0_sin{k},tfi_ord+1);
                register0_sin{k}(:,:,tfi_ord+1) = phase_sin{k};
            else 
                register0_cos{k} = refresh_register(register0_cos{k},tfi_ord+1);
                register0_cos{k}(:,:,tfi_ord+1) = register_cos_flip{k}(:,:,z3);
                register0_sin{k} = refresh_register(register0_sin{k},tfi_ord+1);
                register0_sin{k}(:,:,tfi_ord+1) = register_sin_flip{k}(:,:,z3);
                if k==number_of_levels
                    z3 = z3+1;
                end
            end
            if (z == tfi_ord/2+1)
                register0_cos{k}(:,:,1:tfi_ord/2) = flip(register0_cos{k}(:,:,(tfi_ord/2+2):end),3);
                register0_sin{k}(:,:,1:tfi_ord/2) = flip(register0_sin{k}(:,:,(tfi_ord/2+2):end),3);
                filter_flag = true;
                %%% Slight Modification
                register0_cos{k}(:,:,tfi_ord/2+1) = register0_cos{k}(:,:,tfi_ord/2);
                register0_sin{k}(:,:,tfi_ord/2+1) = register0_sin{k}(:,:,tfi_ord/2);
            elseif (z == nF)
                register_cos_flip{k} = flip(register0_cos{k},3);
                register_sin_flip{k} = flip(register0_sin{k},3);
            end
            if (filter_flag)
                % Temporally filter the quaternionic phase using current value and stored
                % information
                phase_filtered_cos = non_causal_FIRfilter(B, register0_cos{k});
                phase_filtered_sin = non_causal_FIRfilter(B, register0_sin{k});
                % Spatial blur the temporally filtered quaternionic phase signals.
                % This is not an optional step. In addition to denoising,
                % it smooths out errors made during the various approximations.
                phase_filtered_cos = AmplitudeWeightedBlurRiesz(phase_filtered_cos, Amplitude_t{k}(:,:,z2), gaussian_kernel);
                phase_filtered_sin = AmplitudeWeightedBlurRiesz(phase_filtered_sin, Amplitude_t{k}(:,:,z2), gaussian_kernel);
                
               
                if (z == tfi_ord/2+1)
                    phase_cos_amplify = phase_cos3{k};
                    phase_sin_amplify = phase_sin3{k};
                else
                    phase_cos_amplify = phase_filtered_cos - phase_cos3{k};
                    phase_sin_amplify = phase_filtered_sin - phase_sin3{k};
                end
                phase_cos3{k} = phase_filtered_cos;
                phase_sin3{k} = phase_filtered_sin;
                
%                 if z==26
%                     disp('hello');
%                 end
                
                if k>k2 && k<=k2 + pyr_level
                    phase_cos2{k-k2} = phase_filtered_cos;
                    phase_sin2{k-k2} = phase_filtered_sin;
                    phase_cos_sin_amp{k-k2}(:,:,1,z2) =  phase_cos_amplify;
                    phase_cos_sin_amp{k-k2}(:,:,2,z2) =  phase_sin_amplify;
                    Amplitude_out{k-k2}(:,:,z2) = Amplitude_t{k}(:,:,z2);
                end
                % Amplify the Quaternionic Phase
                phase_magnified_filtered_cos = amplification_factor * phase_cos_amplify;
                phase_magnified_filtered_sin = amplification_factor * phase_sin_amplify;
                % The motion magnified pyramid is computed by phase shifting
                % the input pyramid by the spatio-temporally filtered quaternionic phase and
                % taking the real part.
                motion_magnified_laplacian_pyramid{k} = PhaseShiftCoefficientRealPart(current_laplacian_pyramid{k}, ...
                    current_riesz_x{k}, current_riesz_y{k}, phase_magnified_filtered_cos, phase_magnified_filtered_sin);
            end
        end
    if (filter_flag)
        motion_magnified_laplacian_pyramid{number_of_levels+1} = ...
        current_laplacian_pyramid{number_of_levels+1};
    %     motion_magnified_frame = CollapseLaplacianPyramid(motion_magnified_laplacian_pyramid);
        motion_magnified_frame = pyrReconstruct(motion_magnified_laplacian_pyramid);
        Amp_seq(:,:,z2) = motion_magnified_frame;
        z2 = z2+1;
    end
        % Prepare for next iteration of loop
        previous_laplacian_pyramid = current_laplacian_pyramid;
        previous_riesz_x = current_riesz_x;
        previous_riesz_y = current_riesz_y;
    end
end