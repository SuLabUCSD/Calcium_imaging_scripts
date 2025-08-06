Data organization:
1. Imaging files must be organized in the exact format as follows. Must be TIFF files.
2. Example format with 7 flies and 6 methyl acetate dilutions tested for each fly:
- The data folder should contain 7 folders: Fly1, Fly2, Fly3, Fly4, Fly5, Fly6, Fly7
- Inside each fly folder, there should 6 folders: 01_MA_10_9, 02_MA_10_8, 03_MA_10_7, 04_MA_10_6, 05_MA_10_5, 06_MA_10_4
- MA is the abbreviation for the odorant used. The last two numbers indicate the dilution. For example, 10_9 is 10^-9.
- Inside each dilution folder, there should be one TIFF file.

Run motion correction in FIJI:
1. Install moco using directions here: https://github.com/NTCColumbia/moco. (published by Rafael Yuste 2016).

2. (First time only) Copy the Full_AutoMoco macro (see “Motion_correction” folder) to the ImageJ/FIJI macros folder. Restart FIJI.

3. (First time only) Drag Full_AutoMoco into FIJI, then set start and stop frame to be before the stimulus (within 1s) (ex now at 60). This will be the reference frame for motion correction.

4. In FIJI, go to plugins>macros>install and choose Full_AutoMoco.

5. Press Q to open the plugin.

6. Set folder level so that it sees Fly1, Fly2, etc folders to run on.

Calcium imaging analysis:
1. Make sure that Image Processing Toolbox was installed in MATLAB

2. Set path to “savePosition.m” and “xlwrite.m” (see "Associate_function" folder)

3. Open “Calcium_imaging_analysis.m”, go to “Excel convert” section, change the path to locate “20130227_xlwrite”.

4. Go to “Input”, fill all the required fields.

5. Once run, the algorithm will extract all the imaging files. A raw fluorescence image and heatmap for each fly will appear for the selection of background region. Click on a dark region in the antennal edge in the raw fluorescence image to select the background region.

6. Output: Excel files and mat file
- background fluorescence over time, raw fluorescence over time, ΔF over time, and ΔF/F over time.
* ΔF/F is background-subtracted and smoothed using a sliding window (length: 5, overlap: 4).
* For ΔF/F, peak responses are also quantified and exported.
