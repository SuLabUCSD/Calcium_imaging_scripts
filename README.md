Data organization:
1. Imaging files must be organized in the exact format (see the “Example_data” folder). Must be TIFF files.

Run motion correction in FIJI:
1. Install moco using directions here: https://github.com/NTCColumbia/moco. (published by Rafael Yuste 2016).

2. (First time only) Copy the Full_AutoMoco macro (see “Motion_correction” folder) to the ImageJ/FIJI macros folder. Restart FIJI.

3. (First time only) Drag Full_AutoMoco into FIJI, then set start and stop frame to be before the stimulus (within 1s) (ex now at 60). This will be the reference frame for motion correction.

4. In FIJI, go to plugins>macros>install and choose Full_AutoMoco.

5. Press Q to open the plugin.

6. Set folder level so that it sees Fly1, Fly2, etc folders to run on.

Calcium imaging analysis:
1. Make sure that Image Processing Toolbox was installed in MATLAB

2. Set path to “savePosition.m” and “xlwrite.m”

3. Open “Calcium_imaging_analysis.m”, go to “Excel convert” section, change the path to locate “20130227_xlwrite”.

4. Go to “Input”, fill all the required fields.

5. Once run, the algorithm will extract all the imaging files. A raw fluorescence image and heatmap for each fly will appear for the selection of background region. Click on a dark region in the antennal edge in the raw fluorescence image to select the background region.

6. Output: 
1. Excel files: background fluorescence over time, raw fluorescence over time, ΔF over time, and ΔF/F over time.
* ΔF/F is background-subtracted and smoothed using a sliding window (length: 5, overlap: 4).
* For ΔF/F, peak responses are also quantified and exported.

2. Mat file
