function [line_eq,ft_line] = facial_features_axis(feat_points,init_point,fin_point)
    [m,~] = size(feat_points);
    line_eq = [ones(m,1), feat_points(:,1)] \ feat_points(:,2);
    ft_ln_x = [init_point,fin_point];
    ft_ln_y = line_eq (1) + line_eq (2)*ft_ln_x;
    ft_line = [ft_ln_x',ft_ln_y'];
end