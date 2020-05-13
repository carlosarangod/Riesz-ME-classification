function [emotion,onset,offset] = Check_label(subject,Subject_label,subset,Subset_label,Onset_label,Offset_label,Emotion_label,varargin)
    %% Check Labels
    Possible_Subject = find(Subject_label==subject);
    Possible_Subset = find(Subset_label(Possible_Subject) == subset); 
    if nargin == 7
        Selected_label = Possible_Subject(Possible_Subset);
        emotion = Emotion_label(Selected_label);
    elseif nargin == 8
        emotion = varargin(1);
        if strcmp(emotion,'po')
            emo = 1;
        elseif strcmp(emotion,'ne') 
            emo = 2;
        elseif strcmp(emotion,'sur')
            emo = 3;
        end
        Possible_Emotion = find(Emotion_label(Possible_Subject(Possible_Subset)) == emo);
        Selected_label = Possible_Subject(Possible_Subset(Possible_Emotion));
        emotion = emo;
    elseif nargin < 7 
        error('Not enough inputs')
    elseif nargin > 8
        error('Too many inputs')
    end
    
    onset = Onset_label(Selected_label);
    offset = Offset_label(Selected_label);
end