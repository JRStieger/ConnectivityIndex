# ConnectivityIndex

**Provides functions to calculate the connectivity index based on intertrial phase coherence**
Prepare data in steps 1-3 before using the code

## Step 1: Preprocessing

1. Preprocess CCEP in similiar fashion to task data
2. Identify time of stimulation for time locking
3. Clean raw signal to remove stimulation artifacts


## Step 2: Wavelet decomposition

1. Decompose raw signal into frequency components
2. 59 frequencies log spaced between 1Hz and 256Hz
    (Only use up to 100 for ITPC)
    freqs = genFreqs('SpecDense');
3. Downsample to 200 Hz
4. Epoch data [-0.5,2] surrounding stimulation onset


## Step 3: Calculate Intertrial Phase Coherence (ITPC) for each stimulation/recording pair

Input: phase = (trials x freqs x time) matrix for each channel pair
    represents instantaneous phase for each frequency/time point
Output: ccep_ITPC = (channel_pairs x freqs x time) matrix for each channel pair
    represents trial coherence (consistency of phase) for eact
    frequency/time point

spec_tmp: data structure with fields:
    power(freqs x trials x time)
    phase(freqs x trials x time)
    freqs(1 x freqs)
    time (1x time)

