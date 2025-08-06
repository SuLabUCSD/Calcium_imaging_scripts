%% Input
% Size info
imageSize=[706 706]
Want_to_restrict=0 % Put 1 for yes and 0 for no
row_new=1:400 % If don't want to restrict, put any number
col_new=200:706 % If don't want to restrict, put any number
smt_window=5 % Smoothing window size (must be an odd number), put 0 if don't want to smooth

% Basic info
n_num=7 % Put n number
dilu_num=6 % Number of dilutions tested
numerical_dilution=[10^-9 10^-8 10^-7 10^-6 10^-5 10^-4] % numerical value of dilutions

% Frame info
sampling_rate=10 % in Hz
total_frame=380
basal_frame=50:69 % put a range, used to determine basal fluorescence
peak_frame_range=71:100 % frame range to determine ROI
stimulus_onset=70 % frame number
average_peak_frame_range=72:80 % frame range for average peak response

% File identifier
dilution_abbreviation='MA' % abbreviation of odorant name used to name the imaging files

% ROI info
radius=10 % ROI size, must be integer!

% Saved file name
filename_Bac_f='test_Bac_f.xlsx'
filename_f='test_f.xlsx'
filename_df='test_df.xlsx'
filename_df_f='test_df_f.xlsx'


%% Data_extraction
for a=1:size(numerical_dilution,2)
    str=num2str(numerical_dilution(a))
    labels{a}=str
end

path=uigetdir
item=dir(path)

for a=1:length(item)
    if contains(item(a).name,'Fly')
        if ~startsWith(item(a).name,'.')
            folder_name_pre{a}=item(a).name;
        end
    end
end
folder_name=folder_name_pre(~cellfun(@isempty,folder_name_pre));

bar4=waitbar(0,'Fly finished')
for a=1:n_num % num of fly
    path_name=[path '/' folder_name{a}];
    dilu_item=dir(path_name)

    for c=1:length(dilu_item)
        if contains(dilu_item(c).name,dilution_abbreviation)
            if ~startsWith(dilu_item(c).name,'.')
                dilu_name_list_pre{c}=dilu_item(c).name;
            end
        end
    end
    dilu_name_list=dilu_name_list_pre(~cellfun(@isempty,dilu_name_list_pre));
    clear dilu_name_list_pre

    for b=1:dilu_num % num of dilu
        dilu_name{b}=dilu_name_list{b};
        image_path=[path_name '/' dilu_name{b}];
        image_item=dir(image_path);
        for d=1:length(image_item)
            if contains(image_item(d).name,'moco')
                if ~startsWith(image_item(d).name,'.')
                    image_name_pre{d}=image_item(d).name;
                end
            end
        end
        image_name(b)=image_name_pre(~cellfun(@isempty,image_name_pre));
        clear image_name_pre
    end

    parfor (d=1:dilu_num,7) % num of dilu
        path_use=[path_name '/' dilu_name{d}];
        image(:,:,:,a,d)=tiffreadVolume([path_use '/' image_name{d}]);
    end
    bar4=waitbar(a/n_num,bar4,'Fly finished')
end
close(bar4)

%% ROI selection
[x, y]=meshgrid(-1*radius:radius, -1*radius:radius);
mask_logi=sqrt(x.^2 + y.^2) <= radius;
mask=mask_logi/sum(mask_logi(:));

output=zeros(imageSize);
maxValue=zeros(size(1:max(peak_frame_range)-min(peak_frame_range)+1,2),n_num);
linearIndex=zeros(size(1:max(peak_frame_range)-min(peak_frame_range)+1,2),n_num);

roi_Y=zeros(size(1:max(peak_frame_range)-min(peak_frame_range)+1,2),n_num);
roi_X=zeros(size(1:max(peak_frame_range)-min(peak_frame_range)+1,2),n_num);

Restricted=zeros(imageSize);

global col_bac row_bac
bar3=waitbar(0,'Fly finished')
for a=1:n_num % num of fly
    image_open=double(image(:,:,:,a,dilu_num-1));

    image_basal_all=image_open(:,:,basal_frame);
    image_basal=mean(image_basal_all,3);

    frame_1s_before=stimulus_onset-1*sampling_rate;
    frame_1s_after=stimulus_onset+1*sampling_rate;
    F_matrix=image_open(:,:,frame_1s_before);
    F_response=image_open(:,:,frame_1s_after);
    peak_delta_F=F_response-image_basal;
    interm=peak_delta_F.*10;
    peak_delta_F_over_F=(interm./image_basal).*10;
    filtered_result=imbilatfilt(peak_delta_F_over_F);
    savePosition(F_matrix,filtered_result)
    row_bac_save(1,a)=row_bac;
    col_bac_save(1,a)=col_bac;
    clear filtered_result
    

    for b=1:max(peak_frame_range)-min(peak_frame_range)+1
        factor=min(peak_frame_range)-1;
        image_peak_guess=image_open(:,:,b+factor);
        peak_delta_F=image_peak_guess-image_basal;
        interm=peak_delta_F.*10;
        peak_delta_F_over_F=(interm./image_basal).*10;
        filtered_result=imbilatfilt(peak_delta_F_over_F);
        if Want_to_restrict==0
            output=imfilter(double(filtered_result),mask,'replicate');
        elseif Want_to_restrict==1
            Restricted(row_new,col_new)=double(filtered_result(row_new,col_new));
            output=imfilter(Restricted,mask,'replicate');
        end

        temp=max(output(:));
        if size(temp,1)>1
            [maxValue_temp,linearIndex_temp] = max(output(:));
            maxValue(b,a)=maxValue_temp(1);
            linearIndex(b,a)=linearIndex_temp(1);
        else
            [maxValue(b,a),linearIndex(b,a)] = max(output(:));
        end
        [roi_Y(b,a), roi_X(b,a)] = ind2sub(size(output), linearIndex(b,a));
    end
    clear filtered_result
    bar3=waitbar(a/n_num,bar3,'Fly finished')
end
close(bar3)

for a=1:n_num
    interm2=maxValue(:,a);
    [max_over,index_over(a)]=max(interm2(:));
    roi_X_final(a)=roi_X(index_over(a),a);
    roi_Y_final(a)=roi_Y(index_over(a),a);
end
index_frame=index_over+min(peak_frame_range)-1;

%% Other Half
bar1=waitbar(0,'Dilution finished')
bar2=waitbar(0,'Fly finished')

for a=1:n_num % num of fly
    Y_use=roi_Y_final(a);
    X_use=roi_X_final(a);

    Y_bac=row_bac_save(a);
    X_bac=col_bac_save(a);

    for c=1:dilu_num % num of dilu     

        image_dilu_pre=padarray(double(image(:,:,:,a,c)), [radius radius], 'replicate');
        image_dilu=image_dilu_pre(Y_use:Y_use+radius*2,X_use:X_use+radius*2,:);
        image_bac=image_dilu_pre(Y_bac:Y_bac+radius*2,X_bac:X_bac+radius*2,:);
        image_basal_all=image_dilu(:,:,basal_frame);
        image_basal=mean(image_basal_all,3);

        parfor (b=1:total_frame,7)
            image_bac_new=image_bac(:,:,b);
            image_peak_real=image_dilu(:,:,b);
            peak_delta_F=image_peak_real-image_basal;
            % interm=peak_delta_F.*10;
            % peak_delta_F_over_F=(interm./image_basal).*10;

            maskedValues_dF=peak_delta_F(mask_logi);
            maskedValues_F=image_peak_real(mask_logi);
            maskedValues_bac=image_bac_new(mask_logi);
            df_all(a,c,b)=mean(maskedValues_dF);
            Raw_f(a,c,b)=mean(maskedValues_F);
            Bac_f(a,c,b)=mean(maskedValues_bac);
        end
        if c==dilu_num-1
            image_dilu_demo=image(:,:,:,a,c);
            image_basal_all_demo=image_dilu_demo(:,:,basal_frame);
            image_basal_demo=uint16(mean(image_basal_all_demo,3));
            image_bac_interm=uint16(mean(squeeze(Bac_f(a,c,basal_frame))));

            image_peak_real_demo=image_dilu_demo(:,:,index_frame(a));
            peak_delta_F_demo=image_peak_real_demo-image_basal_demo;
            temp2_demo=imbilatfilt(peak_delta_F_demo);
            filtered_result(a,:,:)=temp2_demo;
        end
        bar1=waitbar(c/dilu_num,bar1,'Dilution finished')
    end
    bar2=waitbar(a/n_num,bar2,'Fly finished')
end
close(bar1)
close(bar2)

%% Background/Basal
for a=1:dilu_num
    transfer=squeeze(Bac_f(:,a,basal_frame));
    Bac_value(:,a)=mean(transfer,2);
end

%% Background subtraction
for a=1:n_num
    transfer_dF=squeeze(df_all(a,:,:));
    transfer_basalF=mean(squeeze(Raw_f(a,:,basal_frame)),2);
    adjusted_basalF=transfer_basalF-Bac_value(a,:)';
    df_f_all(a,:,:)=(transfer_dF./adjusted_basalF).*100;
end

%% Smooth
inte=smt_window;
if smt_window==0
    df_f_all_new=df_f_all;
else
    for aa=1:dilu_num; % num of dilutions
        for a=1:total_frame-(inte-1);
            interm10=squeeze(df_f_all(:,aa,:));
            df_f_all_new(:,aa,a)=mean(interm10(:,(a-1)+(1:inte)),2);
        end;
    end;
end

%% Max peaks
for a=1:dilu_num
    current=squeeze(df_f_all_new(:,a,:));
    [max_peak(:,a),time_index(:,a)]=max(current(:,stimulus_onset:end),[],2);
    trace_avg=mean(current,1);
    [unified_peak(1,a),time_index2(1,a)]=max(trace_avg(1,stimulus_onset:end));
end
time_real=time_index+stimulus_onset-1;
time_unified=time_index2+stimulus_onset-1;

for a=1:dilu_num
    current=squeeze(df_f_all_new(:,a,:));
    unified_peak_all(:,a)=current(:,time_unified(a));
    interm9=current(:,average_peak_frame_range);
    average_peak_all(:,a)=mean(interm9,2);
end


%% Heatmap
interm3=n_num/3
if round(interm3)<interm3
    estimate=round(interm3)+1;
else
    estimate=round(interm3);
end

f1=figure
for a=1:n_num
    eval(['ax' num2str(a) '=subplot(estimate,3,a)'])
    data_show=squeeze(filtered_result(a,:,:));
    imagesc(data_show)
    colormap(jet);
    colorbar
    hold on
    % plot(roi_X_final(a), roi_Y_final(a), 'k+', 'MarkerSize', 10); % Mark the center
    % hold on
    rectangle('Position', [roi_X_final(a)-radius, roi_Y_final(a)-radius, radius*2, radius*2], 'EdgeColor', 'k','Curvature',[1 1],'LineWidth',1); % Approximate ROI visual
    axis square
    title('Strongest ROI Highlighted');
    % caxis([0 100])
end

%% Backgound shown
interm3=n_num/3
if round(interm3)<interm3
    estimate=round(interm3)+1;
else
    estimate=round(interm3);
end

f1=figure
for a=1:n_num
    eval(['ax' num2str(a) '=subplot(estimate,3,a)'])
    data_show=squeeze(image(:,:,frame_1s_before,a,dilu_num-1));
    imagesc(data_show)
    colormap(gray);
    colorbar
    hold on
    rectangle('Position', [col_bac_save(a)-radius, row_bac_save(a)-radius, radius*2, radius*2], 'EdgeColor', 'r','Curvature',[1 1],'LineWidth',1); % Approximate ROI visual
    axis square
    title('Bac ROI Highlighted');
    % caxis([0 100])
end


%% Excel convert
cd('/Users/yiyi/Desktop/Downloaded functions/xlwrite/20130227_xlwrite')
javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');
javaaddpath('poi_library/stax-api-1.0.1.jar');

cd(path)
for a=1:dilu_num % num of dilutions
    converted_sheet=squeeze(df_f_all_new(:,a,:))';
    converted_sheet_2=squeeze(Raw_f(:,a,:))';
    converted_sheet_3=squeeze(Bac_f(:,a,:))';
    converted_sheet_4=squeeze(df_all(:,a,:))';

    xlwrite(filename_df_f,converted_sheet,labels{a},'A2');
    xlwrite(filename_f,converted_sheet_2,labels{a},'A2');
    xlwrite(filename_Bac_f,converted_sheet_3,labels{a},'A2');
    xlwrite(filename_df,converted_sheet_4,labels{a},'A2');
end

xlwrite(filename_df_f,max_peak,'Actual Max_peaks','A2')
xlwrite(filename_df_f,unified_peak_all,'Adjusted Max_peaks','A2')
xlwrite(filename_df_f,average_peak_all,'Average Max_peaks','A2')
xlwrite(filename_df_f,roi_X_final','ROI_location','A2')
xlwrite(filename_df_f,roi_Y_final','ROI_location','B2')

xlwrite(filename_Bac_f,Bac_value,'Background_value','A2')
xlwrite(filename_Bac_f,col_bac_save','Bac_region location','A2')
xlwrite(filename_Bac_f,row_bac_save','Bac_region location','B2')


save('Processed_results.mat','Bac_f','Raw_f','df_f_all_new','max_peak','unified_peak_all','average_peak_all','Bac_value')

% %% Test
% f2=figure
% imagesc(squeeze(filtered_result(1,5,:,:,80))); 
% title('Strongest ROI Highlighted');
% colormap(jet);
% colorbar
% hold on;
% plot(roi_X_final(1), roi_Y_final(1), 'k+', 'MarkerSize', 10); % Mark the center
% hold on
% rectangle('Position', [roi_X_final(1)-radius, roi_Y_final(1)-radius, radius*2, radius*2], 'EdgeColor', 'k','Curvature',[1 1]); % Approximate ROI visual
% axis square
