%
% PROJECTION
%
% Simple metapost library to draw projection diagram
%
% Changmook Chun (c) 2021
%

% Utilities
def norm(suffix vec) =
begingroup
    save norm_of_vec;
    norm_of_vec := sqrt (vec[1]*vec[1] + vec[2]*vec[2] + vec[3]*vec[3]);
    norm_of_vec
endgroup
enddef;

def cross(suffix u, v) =
begingroup
    save cp;
    numeric cp[];
    cp[1] :=  u[2]*v[3] - u[3]*v[2];
    cp[2] := -u[1]*v[3] + u[3]*v[1];
    cp[3] :=  u[1]*v[2] - u[2]*v[1];
    cp
endgroup
enddef;

% Simple projection geometry
def projected_line(suffix eye, view_up, pp, qq)(expr dist) =
begingroup
    save e_hat, length_e;
    save u_hat, length_u;
    save cnt, theta, phi;
    save R, x_axis, y_axis, z_axis;
    save TR, Tp, p_bdy, p_inp, q_bdy, q_inp;

    % Normalize eye position vector
    % ----------------------------------------------------------------------
    numeric e_hat[];
    numeric length_e;
    length_e := norm(eye);
    for i=1 upto 3:
        e_hat[i] := eye[i]/length_e;
    endfor

    % Normalize view up vector
    % ----------------------------------------------------------------------
    numeric u_hat[];
    numeric length_u;
    length_u := norm(view_up);
    for i=1 upto 3:
        u_hat[i] := view_up[i]/length_u;
    endfor

    % Center of the image plane
    % ----------------------------------------------------------------------
    numeric cnt[];
    for i=1 upto 3:
        cnt[i] := (length_e - dist)/length_e * eye[i];
    endfor

    % Angle of rotations
    % ----------------------------------------------------------------------
    numeric theta, phi;
    theta := angle(eye1, eye2);
    phi := angle(eye1, eye3);

    % Rotation matrix
    % ----------------------------------------------------------------------
    numeric R[][];

    numeric x_axis[];
    numeric y_axis[];
    numeric z_axis[];

    z_axis1 := e_hat1;
    z_axis2 := e_hat2;
    z_axis3 := e_hat3;

    y_axis1 := cosd(phi)*cosd(theta)*u_hat1 - cosd(phi)*sind(theta)*u_hat2 - sind(phi)*u_hat3;
    y_axis2 := sind(theta)*u_hat1 + cosd(theta)*u_hat2;
    y_axis3 := -sind(phi)*cosd(theta)*u_hat1 + sind(phi)*sind(theta)*u_hat2 + cosd(phi)*u_hat3;

    % Cross product
    x_axis1 :=  y_axis2*z_axis3 - y_axis3*z_axis2;
    x_axis2 := -y_axis1*z_axis3 + y_axis3*z_axis1;
    x_axis3 :=  y_axis1*z_axis2 - y_axis2*z_axis1;

    % Note that the rotation matrix of this transformation is R',
    % where R = [ x y z ]
    R11 := x_axis1;  R12 := x_axis2;  R13 := x_axis3;
    R21 := y_axis1;  R22 := y_axis2;  R23 := y_axis3;
    R31 := z_axis1;  R32 := z_axis2;  R33 := z_axis3;

    % The translation part of this transformation is -R' * center.
    numeric Tp[];
    Tp1 := -(R11*cnt1 + R12*cnt2 + R13*cnt3);
    Tp2 := -(R21*cnt1 + R22*cnt2 + R23*cnt3);
    Tp3 := -(R31*cnt1 + R32*cnt2 + R33*cnt3);

    % Calculate the projected points on the image plane
    % ----------------------------------------------------------------------
    numeric p_bdy[];
    pair p_inp;
    p_bdy1 := R11*pp1 + R12*pp2 + R13*pp3 + Tp1;
    p_bdy2 := R21*pp1 + R22*pp2 + R23*pp3 + Tp2;
    p_bdy3 := R31*pp1 + R32*pp2 + R33*pp3 + Tp3;

    if p_bdy3 > 0:
        p_inp.x := sqrt -1;
        p_inp.y := sqrt -1;
    else:
        p_inp.x := dist * p_bdy1/(dist + abs(p_bdy3));
        p_inp.y := dist * p_bdy2/(dist + abs(p_bdy3));
    fi

    numeric q_bdy[];
    pair q_inp;
    q_bdy1 := R11*qq1 + R12*qq2 + R13*qq3 + Tp1;
    q_bdy2 := R21*qq1 + R22*qq2 + R23*qq3 + Tp2;
    q_bdy3 := R31*qq1 + R32*qq2 + R33*qq3 + Tp3;

    if q_bdy3 > 0:
        q_inp.x := sqrt -1;
        q_inp.y := sqrt -1;
    else:
        q_inp.x := dist * q_bdy1/(dist + abs(q_bdy3));
        q_inp.y := dist * q_bdy2/(dist + abs(q_bdy3));
    fi

    path pq_line_on_image_plane;
    pq_line_on_image_plane = (p_inp.x, p_inp.y)--(q_inp.x, q_inp.y);
    pq_line_on_image_plane

endgroup
enddef;

def projected_triangle(suffix eye, view_up, vertex_a, vertex_b, vertex_c)(expr dist) =
begingroup
    save e_hat, length_e;
    save u_hat, length_u;
    save cnt, theta, phi;
    save R, x_axis, y_axis, z_axis;
    save TR, Tp;
    save a_bdy, a_inp, b_bdy, b_inp, c_bdy, c_inp;

    % Normalize eye position vector
    % ----------------------------------------------------------------------
    numeric e_hat[];
    numeric length_e;
    length_e := norm(eye);
    for i=1 upto 3:
        e_hat[i] := eye[i]/length_e;
    endfor

    % Normalize view up vector
    % ----------------------------------------------------------------------
    numeric u_hat[];
    numeric length_u;
    length_u := norm(view_up);
    for i=1 upto 3:
        u_hat[i] := view_up[i]/length_u;
    endfor

    % Center of the image plane
    % ----------------------------------------------------------------------
    numeric cnt[];
    for i=1 upto 3:
        cnt[i] := (length_e - dist)/length_e * eye[i];
    endfor

    % Angle of rotations
    % ----------------------------------------------------------------------
    numeric theta, phi;
    theta := angle(eye1, eye2);
    phi := angle(eye1, eye3);

    % Rotation matrix
    % ----------------------------------------------------------------------
    numeric R[][];

    numeric x_axis[];
    numeric y_axis[];
    numeric z_axis[];

    z_axis1 := e_hat1;
    z_axis2 := e_hat2;
    z_axis3 := e_hat3;

    y_axis1 := cosd(phi)*cosd(theta)*u_hat1 - cosd(phi)*sind(theta)*u_hat2 - sind(phi)*u_hat3;
    y_axis2 := sind(theta)*u_hat1 + cosd(theta)*u_hat2;
    y_axis3 := -sind(phi)*cosd(theta)*u_hat1 + sind(phi)*sind(theta)*u_hat2 + cosd(phi)*u_hat3;

    % Cross product
    x_axis1 :=  y_axis2*z_axis3 - y_axis3*z_axis2;
    x_axis2 := -y_axis1*z_axis3 + y_axis3*z_axis1;
    x_axis3 :=  y_axis1*z_axis2 - y_axis2*z_axis1;

    % Note that the rotation matrix of this transformation is R',
    % where R = [ x y z ]
    R11 := x_axis1;  R12 := x_axis2;  R13 := x_axis3;
    R21 := y_axis1;  R22 := y_axis2;  R23 := y_axis3;
    R31 := z_axis1;  R32 := z_axis2;  R33 := z_axis3;

    % The translation part of this transformation is -R' * center.
    numeric Tp[];
    Tp1 := -(R11*cnt1 + R12*cnt2 + R13*cnt3);
    Tp2 := -(R21*cnt1 + R22*cnt2 + R23*cnt3);
    Tp3 := -(R31*cnt1 + R32*cnt2 + R33*cnt3);

    % Calculate the projected points on the image plane
    % ----------------------------------------------------------------------
    numeric a_bdy[];
    pair a_inp;
    a_bdy1 := R11*vertex_a1 + R12*vertex_a2 + R13*vertex_a3 + Tp1;
    a_bdy2 := R21*vertex_a1 + R22*vertex_a2 + R23*vertex_a3 + Tp2;
    a_bdy3 := R31*vertex_a1 + R32*vertex_a2 + R33*vertex_a3 + Tp3;

    if a_bdy3 > 0:
        a_inp.x := sqrt -1;
        a_inp.y := sqrt -1;
    else:
        a_inp.x := dist * a_bdy1/(dist + abs(a_bdy3));
        a_inp.y := dist * a_bdy2/(dist + abs(a_bdy3));
    fi

    numeric b_bdy[];
    pair b_inp;
    b_bdy1 := R11*vertex_b1 + R12*vertex_b2 + R13*vertex_b3 + Tp1;
    b_bdy2 := R21*vertex_b1 + R22*vertex_b2 + R23*vertex_b3 + Tp2;
    b_bdy3 := R31*vertex_b1 + R32*vertex_b2 + R33*vertex_b3 + Tp3;

    if b_bdy3 > 0:
        b_inp.x := sqrt -1;
        b_inp.y := sqrt -1;
    else:
        b_inp.x := dist * b_bdy1/(dist + abs(b_bdy3));
        b_inp.y := dist * b_bdy2/(dist + abs(b_bdy3));
    fi

    numeric c_bdy[];
    pair c_inp;
    c_bdy1 := R11*vertex_c1 + R12*vertex_c2 + R13*vertex_c3 + Tp1;
    c_bdy2 := R21*vertex_c1 + R22*vertex_c2 + R23*vertex_c3 + Tp2;
    c_bdy3 := R31*vertex_c1 + R32*vertex_c2 + R33*vertex_c3 + Tp3;

    if c_bdy3 > 0:
        c_inp.x := sqrt -1;
        c_inp.y := sqrt -1;
    else:
        c_inp.x := dist * c_bdy1/(dist + abs(c_bdy3));
        c_inp.y := dist * c_bdy2/(dist + abs(c_bdy3));
    fi

    % Calculate normal vector of the triangle defined by vertices in
    % clockwise direction.  That is, when the triangle is defined by vertices
    % A, B, and C (in clockwise order), if the z-component of the cross
    % product of AC and AB is positive w.r.t. the local frame of the image
    % plane, the triangular face is toward the image plane.
    % Otherwise, the triangular face is in the opposite direction to the
    % image plane.
    numeric AC[], AB[];
    AC1 := c_bdy1 - a_bdy1;
    AC2 := c_bdy2 - a_bdy2;
    AC3 := c_bdy3 - a_bdy3;

    AB1 := b_bdy1 - a_bdy1;
    AB2 := b_bdy2 - a_bdy2;
    AB3 := b_bdy3 - a_bdy3;

    numeric normal_ABC[];
    normal_ABC1 :=  AC2*AB3 - AC3*AB2;
    normal_ABC2 := -AC1*AB3 + AC3*AB1;
    normal_ABC3 :=  AC1*AB2 - AC2*AB1;

    path triangle_on_image_plane
    if normal_ABC3 > 0:
        triangle_on_image_plane = (a_inp.x,a_inp.y)--(b_inp.x,b_inp.y)--(c_inp.x,c_inp.y);
    else:
        triangle_on_image_plane = (b_inp.x,b_inp.y);
    fi

    % Return this triangular path on the image plane.
    triangle_on_image_plane

endgroup
enddef;

def path_for_cuboid(suffix AA, AB, AC, AD, BA, BB, BC, BD, eye, view_up)(expr dist) =
begingroup
    path edge_of_cuboid;
    edge_of_cuboid := projected_triangle(eye, view_up, AA, AB, AC, dist);

endgroup
enddef;
