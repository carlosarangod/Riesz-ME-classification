function [current_shape, Mdqp] = update_AAM(previous_shape,input_image,cAAM,scale_index,iter_counter)
    global c dc
    ind_in = cAAM.coord_frame{scale_index}.ind_in;
    ind_out = cAAM.coord_frame{scale_index}.ind_out;
    ind_in2 = cAAM.coord_frame{scale_index}.ind_in2;
    ind_out2 = cAAM.coord_frame{scale_index}.ind_out2;
    resolution = cAAM.coord_frame{scale_index}.resolution;

    A0 = cAAM.texture{scale_index}.A0;
    A = cAAM.texture{scale_index}.A;
    AA0 = cAAM.texture{scale_index}.AA0;
    AA = cAAM.texture{scale_index}.AA;
    sc = 2.^(cAAM.scales(scale_index)-1);
    current_shape = previous_shape /sc;
    
    Iw = warp_image(cAAM.coord_frame{scale_index}, current_shape*sc, input_image);
%     figure(14);hold on;
%     imshow(Iw,[]);
    I = Iw(:); I(ind_out) = [];
    II = Iw(:); II(ind_out2) = [];

    % compute reconstruction Irec 
    if (iter_counter == 1)
        c = A'*(I - A0) ;
    else
        c = c + dc;
    end
    Irec = zeros(resolution(1), resolution(2));
    Irec(ind_in) = A0 + A*c;

    % compute gradients of Irec
    [Irecx,Irecy] = gradient(Irec);
    Irecx(ind_out2) = 0; Irecy(ind_out2) = 0;
    Irec(ind_out2) = [];
    Irec = Irec(:);

    % compute J from the gradients of Irec
    J = image_jacobian(Irecx, Irecy, cAAM.texture{scale_index}.dW_dp, cAAM.shape{scale_index}.n_all);
    J(ind_out2, :) = [];

    % compute Jfsic and Hfsic 
    Jfsic = J - AA*(AA'*J);
    Hfsic = Jfsic' * Jfsic;
%     inv_Hfsic = inv(Hfsic);

    % compute dp (and dq) and dc
%     dqp = inv_Hfsic * Jfsic'*(II-AA0);
    dqp = Hfsic\Jfsic'*(II-AA0);
    dc = AA'*(II - Irec - J*dqp);
    Mdqp=mean(abs(dqp));
    
    % This function updates the shape in an inverse compositional fashion
    current_shape =  compute_warp_update(current_shape, dqp, cAAM.shape{scale_index}, cAAM.coord_frame{scale_index});
    current_shape(:,1) = current_shape(:, 1) * sc ;
    current_shape(:,2) = current_shape(:, 2) * sc ;
end