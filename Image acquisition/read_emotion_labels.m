% function excel_table = read_emotion_labels(database)
function read_emotion_labels(database)
    if strcmp(database,'SMIC_High')
        folder_dir = strcat(getenv('SMIC'),'\HS_long\SMIC-HS-E\');
%         folder_dir = 'C:\Users\CarlosAndres.Carlos\Documents\PhD\Databases\Emotions\SMIC-E_raw image\HS_long\SMIC-HS-E\';
        label_file = 'SMIC-HS-E_annotation.xlsx';
        file_name = strcat(folder_dir,label_file);
        [~,~,xlsraw] = xlsread(file_name,1);
        excel_table = cat(2,xlsraw(2:end,1:2),xlsraw(2:end,4:7),xlsraw(2:end,11:14),xlsraw(2:end,15:16));
        Subject_label = cell2mat(excel_table(:,1));
        where_nan=find(isnan(Subject_label));
        if ~isempty(where_nan)
            Subject_label(where_nan:end)=[];
        end
        label_size=length(Subject_label);
        Subset_label=zeros(label_size,1);
        Emotion_label=zeros(label_size,1);
        k=0;
        k2=0;
        Missing_labels = [];
        for i=1:label_size
            underscore = strfind(excel_table{i,2},'_');
            emo=excel_table{i,2}(underscore(1)+1:underscore(2)-1);
            Subset_label(i)=str2double(excel_table{i,2}(underscore(2)+1:end));
            if strcmp(emo,'po') Emotion_label(i) = 1;
            elseif strcmp(emo,'ne') Emotion_label(i) = 2;
            elseif strcmp(emo,'sur') Emotion_label(i) = 3;
            end
            if isa(excel_table{i,7},'char')
                excel_table{i,7}=0;
                k=k+1;
                Missing_labels(k)=i;
            end
            if (~isnan(excel_table{i,5}))
                k2=k2+1;
                Second_Emo(k2,1) = i;
                Second_Emo(k2,2) = excel_table{i,5} - excel_table{i,7} + 1;
                Second_Emo(k2,3) = Second_Emo(k2,2) + excel_table{i,10} - 1;
            end
        end
        Onset_label = cell2mat(excel_table(1:label_size,3)) - cell2mat(excel_table(1:label_size,7)) + 1;
        Duration_label = cell2mat(excel_table(1:label_size,9));
        Offset_label = Onset_label + Duration_label - 1;
        if ~isempty(Missing_labels)
            Onset_label(Missing_labels) = 0;
            Offset_label(Missing_labels) = 0;
        end
        save SMIC_High_labels.mat Subject_label Subset_label Emotion_label Onset_label Offset_label Second_Emo
        
    elseif strcmp(database,'SMIC_RGB')
        folder_dir = strcat(getenv('SMIC'),'\VIS_long\');
%         folder_dir = 'C:\Users\CarlosAndres.Carlos\Documents\PhD\Databases\Emotions\SMIC-E_raw image\VIS_long\';
        label_file = 'SMIC_VIS_E_annotation.xlsx';
        file_name = strcat(folder_dir,label_file);
        [~,~,xlsraw] = xlsread(file_name,1);
        excel_table = cat(2,xlsraw(2:end,1:2),xlsraw(2:end,4:7),xlsraw(2:end,9:12));
        Subject_label = cell2mat(excel_table(:,1));
        where_nan=find(isnan(Subject_label));
        if ~isempty(where_nan)
            Subject_label(where_nan:end)=[];
        end
        label_size=length(Subject_label);
        Subset_label=zeros(label_size,1);
        Emotion_label=zeros(label_size,1);
        k=0;
        k2=0;
        for i=1:label_size
            underscore = strfind(excel_table{i,2},'_');
            emo=excel_table{i,2}(underscore(1)+1:underscore(2)-1);
            Subset_label(i)=str2double(excel_table{i,2}(underscore(2)+1:end));
            if strcmp(emo,'po') Emotion_label(i) = 1;
            elseif strcmp(emo,'ne') Emotion_label(i) = 2;
            elseif strcmp(emo,'sur') Emotion_label(i) = 3;
            end
            if (~isnan(excel_table{i,5}))
                k2=k2+1;
                Second_Emo(k2,1)=i;
                Second_Emo(k2,2)= excel_table{i,5} - excel_table{i,7} + 1;
                Second_Emo(k2,3)= excel_table{i,6} - excel_table{i,7} + 1;
            end
        end
        Onset_label = cell2mat(excel_table(1:label_size,3)) - cell2mat(excel_table(1:label_size,7)) + 1;
        Duration_label = cell2mat(excel_table(1:label_size,8));
        Offset_label = Onset_label + Duration_label - 1;
        save SMIC_RGB_labels.mat Subject_label Subset_label Emotion_label Onset_label Offset_label Second_Emo
    
    elseif strcmp(database,'CASME2')
        folder_dir =  strcat(getenv('CASME2'),'\');
%         folder_dir = 'C:\Users\CarlosAndres.Carlos\Documents\PhD\Databases\Emotions\CASME2_RAW\';
        label_file = 'CASME2-coding-20140508.xlsx';
        file_name = strcat(folder_dir,label_file);
        [~,~,xlsraw] = xlsread(file_name,1);
        excel_table = cat(2,xlsraw(2:end,1:2),xlsraw(2:end,4:6),xlsraw(2:end,9));
        Subject_label = str2num(cell2mat(excel_table(:,1)));
        label_size=length(Subject_label);
        Subset_label=zeros(label_size,1);
        Emotion_label=zeros(label_size,1);
        Subject_number=Subject_label(1);
        k=0;
        Onset_label = cell2mat(excel_table(:,3));
        Offset_label = cell2mat(excel_table(:,5));
        Apex_label = cell2mat(excel_table(:,4));
        for i=1:label_size
            if Subject_number==Subject_label(i)   
                k=k+1;
            else
                Subject_number=Subject_label(i);
                k=1;
            end
            Subset_label(i)=k;
            emo = excel_table{i,6};
            if strcmp(emo,'happiness')
                Emotion_label(i) = 1;
%             elseif strcmp(emo,'disgust')||strcmp(emo,'sadness')||strcmp(emo,'fear')
            elseif strcmp(emo,'disgust')
                Emotion_label(i) = 2;
            elseif strcmp(emo,'surprise')
                Emotion_label(i) = 3;
            elseif strcmp(emo,'repression')
                Emotion_label(i) = 4;
            elseif strcmp(emo,'others')
                Emotion_label(i) = 5;
            else 
                Emotion_label(i) = 0;
%             elseif strcmp(emo,'others')||strcmp(emo,'repression')
%                 Emotion_label(i) = 4;
            end
        end
        trim_candidates = find(Emotion_label==0);
        Subject_label(trim_candidates)=[];
        Subset_label(trim_candidates)=[];
        Emotion_label(trim_candidates)=[];
        Onset_label(trim_candidates)=[];
        Offset_label(trim_candidates)=[];
        Apex_label(trim_candidates)=[];
        save CASME2_labels.mat Subject_label Subset_label Emotion_label Onset_label Offset_label Apex_label trim_candidates
    
    elseif strcmp(database,'CAS(ME)^2')
        folder_dir =  strcat(getenv('CAS(ME)2'),'\');
        label_file = 'CAS(ME)^2code_final';
        file_name = strcat(folder_dir,label_file);
        [~,~,excel_table] = xlsread(file_name,1);
        [~,~,excel_table2] = xlsread(file_name,2);
        [~,~,excel_table4] = xlsread(file_name,3);
%         [~,~,excel_table4] = xlsread(file_name,4);
        Subject_label = cell2mat(excel_table(:,1));
        label_size=length(Subject_label);
        Subset_label = zeros(label_size,1);
        Video_label = zeros(label_size,1);
        Emotion_label = zeros(label_size,1);
        Micro_label = zeros(label_size,1);
        k=0;
        Onset_label = cell2mat(excel_table(:,3));
        Offset_label = cell2mat(excel_table(:,5));
        Apex_label = cell2mat(excel_table(:,4));
        types_video = excel_table4(:,2);
        video_name = excel_table{1,2};
        under_line = strfind(video_name,'_');
        video_type = video_name(1:(under_line-1));
        Prev_Video_number = find(strcmp(video_type,types_video));
        for i=1:label_size
            video_name = excel_table{i,2};
            under_line = strfind(video_name,'_');
            video_type = video_name(1:(under_line-1));
            Video_number = find(strcmp(video_type,types_video));
            if Prev_Video_number==Video_number   
                k=k+1;
            else
                Prev_Video_number=Video_number;
                k=1;
            end
            Video_label(i) = Video_number;
            Subset_label(i)=k;
            emo = excel_table{i,7};
            if strcmp(emo,'positive')
                Emotion_label(i) = 1;
            elseif strcmp(emo,'negative')
                Emotion_label(i) = 2;
            elseif strcmp(emo,'surprise')
                Emotion_label(i) = 3;
            elseif strcmp(emo,'others')
                Emotion_label(i) = 4;
            else 
                Emotion_label(i) = 0;
            end
            if strcmp(excel_table{i,8},'micro-expression')
                Micro_label(i) = 1;
            end
        end
        save CAS(ME)^2_labels.mat Subject_label Video_label Subset_label Emotion_label Micro_label Onset_label Offset_label Apex_label
    elseif strcmp(database,'CAS(ME)^2_blink')
        folder_dir =  strcat(getenv('CAS(ME)2'),'\');
        label_file = 'CAS(ME)^2blink-code';
        file_name = strcat(folder_dir,label_file);
        [~,~,excel_table] = xlsread(file_name,1);
        excel_table(1,:) = [];
        excel_table(:,6:7) = [];
        label_size=size(excel_table,1);
        for i=1:label_size
            Subject_cand = excel_table{i,1};
            offset_cand = excel_table{i,5};
            if isnumeric(Subject_cand)
                C_Subject_label(i,:) = Subject_cand;
            else
                C_Subject_label(i,:) = str2num(Subject_cand);
            end
            if isnumeric(offset_cand)
                B_Offset_label(i,:) = offset_cand;
            else
                B_Offset_label(i,:) = str2num(offset_cand);
            end
        end
        k=1;
        B_Video_label = zeros(label_size,1);
        B_Onset_label = cell2mat(excel_table(:,4));
        label_file = 'CAS(ME)^2code_final';
        file_name = strcat(folder_dir,label_file);
%         [~,~,excel_table4] = xlsread(file_name,4);
        [~,~,excel_table4] = xlsread(file_name,3);
        types_video = excel_table4(:,1);
        Prev_Video_number = C_Subject_label(1,:);
        for i=1:label_size
            video_name = excel_table{i,2};
            Video_number = find(strcmp(video_name,types_video));
            B_Video_label(i) = Video_number;
            if ~(Prev_Video_number==C_Subject_label(i,:))   
                k=k+1;
                Prev_Video_number=C_Subject_label(i,:);
            end
            B_Subject_label(i,:) = k;
        end
        save CAS(ME)^2_blink_labels.mat B_Subject_label B_Video_label  B_Onset_label B_Offset_label
    elseif strcmp(database,'CK+')
        folder_dir =  strcat(getenv('CK+'),'\Emotion\');
%         folder_dir = 'C:\Users\CarlosAndres.Carlos\Documents\PhD\Databases\Emotions\CK+\Emotion\';
        images_dir =  strcat(getenv('CK+'),'\extended-cohn-kanade-images\cohn-kanade-images\');
%         images_dir = 'C:\Users\CarlosAndres.Carlos\Documents\PhD\Databases\Emotions\CK+\extended-cohn-kanade-images\cohn-kanade-images\';
        folder_list = dir(folder_dir);
        fold_le = length(folder_list);
        fold_count=1;
        for k = 3:fold_le
            if folder_list(k).isdir == 1
                subject_dir = strcat(folder_dir,folder_list(k).name);
                subfolder_list = dir(subject_dir);
                subfold_le = length(subfolder_list);
                for q = 3:subfold_le
                    if subfolder_list(q).isdir == 1
                        emotion_dir = strcat(subject_dir,'\',subfolder_list(q).name);
                        emotion_list = dir(emotion_dir);
                        if (length(emotion_list) == 3)
                            emotion_file = strcat(emotion_dir,'\',emotion_list(3).name);
                            Subject_label(fold_count,1) = k-2;
                            Subset_label(fold_count,1) = str2double(subfolder_list(q).name);
                            Emotion_label(fold_count,1) = textread(emotion_file);
                            Onset_label(fold_count,1) = 1;
                            img_dir = strcat(images_dir,folder_list(k).name,'\',subfolder_list(q).name);
                            img_list = dir(img_dir);
                            img_le = length(img_list);
                            Offset_label(fold_count,1) = img_le - 2;
                            fold_count = fold_count+1;
                        end
                    end
                end        
            end
        end
        save CK+_labels.mat Subject_label Subset_label Emotion_label Onset_label Offset_label
    elseif strcmp(database,'SAMM')
        folder_dir =  strcat(getenv('SAMM'),'\');
        label_file = 'SAMM_Micro_FACS_Codes_v2';
        file_name = strcat(folder_dir,label_file);
        [~,~,xlsraw] = xlsread(file_name,1);
        excel_table = xlsraw(15:end,1:11);
        Subject_label = str2num(cell2mat(excel_table(:,1)));
        label_size=length(Subject_label);
        Subset_label=zeros(label_size,1);
        Emotion_label = cell2mat(excel_table(:,11));
        Subject_number=Subject_label(1);
        k=0;
        Onset_label = cell2mat(excel_table(:,4))-cell2mat(excel_table(:,4))+1;
        Offset_label = cell2mat(excel_table(:,6))-cell2mat(excel_table(:,4))+1;
        Apex_label = cell2mat(excel_table(:,5))-cell2mat(excel_table(:,4))+1;
        for i=1:label_size
            under_lines = strfind(excel_table{1,2},'_');
            Subset_label(i,1)= str2num(excel_table{i,2}((under_lines(1)+1):(under_lines(2)-1)));
            Subset_label(i,2)= str2num(excel_table{i,2}((under_lines(2)+1):end));
        end
        save SAMM_labels.mat Subject_label Subset_label Emotion_label Onset_label Offset_label Apex_label
    else
        error(strcat('We cannot find the database ',database),'. Please write any of the existent databases') 
    end
end