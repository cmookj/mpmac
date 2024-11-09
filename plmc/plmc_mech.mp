% prologues := 3;
% outputtemplate := "fig%c.eps";
% outputformat := "eps";

input TEX 

% ------------------------------------------------------------------------------
%  Global settings
% ------------------------------------------------------------------------------

% Basic unit
% u = 1cm;

% Default line width
default_pen_width = 1bp;
default_half_width = .5bp;

% Default ratio of (radius of joint)/(width of link)
default_ratio_rw = .8;

% Default angle of oblique lines
default_oblique = 60;

% Default foreground fill color
color default_fill_color;
default_fill_color = white;



% ------------------------------------------------------------------------------
%  Primary Paths
% ------------------------------------------------------------------------------
path unit_rect;
unit_rect = (-.5,-.5)--(.5,-.5)--(.5,.5)--(-.5,.5)--cycle;

path unit_circle;
unit_circle = fullcircle scaled 2;


% ------------------------------------------------------------------------------
%  Macro definition: draw_rect
% ------------------------------------------------------------------------------
def draw_rect (expr w, h, p, q) =
  begingroup
    transform T;
    T = identity rotated q shifted p;
    pickup pencircle scaled default_pen_width;
    draw unit_rect xscaled w yscaled h transformed T withcolor plmc_current_color;
    pickup defaultpen;
  endgroup
enddef;

% ------------------------------------------------------------------------------
%  Macro definition: draw_rect_filled
% ------------------------------------------------------------------------------
def draw_rect_filled (expr w, h, p, q) =
  begingroup
    transform T;
    T = identity rotated q shifted p;
    pickup pencircle scaled default_pen_width;
    fill unit_rect xscaled w yscaled h transformed T withcolor default_fill_color;
    draw unit_rect xscaled w yscaled h transformed T withcolor plmc_current_color;
    pickup defaultpen;
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_dcircle
% ------------------------------------------------------------------------------
def draw_dcircle (expr r, p) =
  begingroup
    pickup pencircle scaled default_pen_width;
    draw unit_circle scaled r shifted p withcolor plmc_current_color;
    draw unit_circle scaled .5r shifted p withcolor plmc_current_color;
    pickup defaultpen;
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_dcircle_filled
% ------------------------------------------------------------------------------
def draw_dcircle_filled (expr r, p) =
  begingroup
    pickup pencircle scaled default_pen_width;
    fill unit_circle scaled r shifted p withcolor default_fill_color;
    draw unit_circle scaled r shifted p withcolor plmc_current_color;
    draw unit_circle scaled .5r shifted p withcolor plmc_current_color;
    pickup defaultpen;
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_planar_link
% ------------------------------------------------------------------------------
def draw_planar_link (expr length, width, T) =
  % Parameters
  %   length: length of the link
  %    width: width of the link
  %        T: transformation matrix
  begingroup
    picture link;
    link := image (
      draw_rect_filled (length, width, (0,0), 0);
    );

    picture joint_left;
    joint_left := image (
        draw_dcircle_filled (default_ratio_rw * width, (0,0));
    );

    picture link_with_joint;
    link_with_joint := image (
      pickup pencircle scaled default_pen_width;
      draw link shifted (.5length, 0);
      draw joint_left;
      pickup defaultpen;
    );

    pickup pencircle scaled default_pen_width;
    draw link_with_joint transformed T;
    pickup defaultpen;
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_centerline
% ------------------------------------------------------------------------------
def draw_centerline (expr length, T, offset, line_length) =
  % Parameters
  %       length: length of the link
  %        width: width of the link
  %            T: transformation matrix
  %  line_length: length of the center line of the link
  begingroup
    picture centerline;
    centerline := image (
      pickup pencircle scaled default_half_width;
      draw (length+offset, 0)--(length+line_length, 0) withcolor plmc_current_color dashed evenly;
      pickup defaultpen;
    );

    draw centerline transformed T;
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_joint
% ------------------------------------------------------------------------------
def draw_joint (expr r, T) =
  begingroup
    pickup pencircle scaled default_pen_width;
    picture joint;
    joint = image (
      fill unit_circle scaled r withcolor default_fill_color;
      draw unit_circle scaled r withcolor plmc_current_color;
      draw unit_circle scaled .5r withcolor plmc_current_color;
    );
    draw joint transformed T;
    pickup defaultpen;
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_fixed_joint
% ------------------------------------------------------------------------------
def draw_fixed_joint (expr r, p) =
  begingroup
    pickup pencircle scaled default_pen_width;
    picture fixed_joint;
    fixed_joint = image (
      numeric lscale;
      lscale = 1.6;

      path triangle;
      triangle = (-r,-r)--(0,0)--(r,-r)--cycle;
      draw triangle scaled lscale withcolor plmc_current_color;

      numeric n;      n = 3;             % Number of oblique lines
      numeric len;    len = r*lscale;    % Half length of triangle base
      numeric gap;    gap = 2len/(n+2);  % Gap between oblique lines
      numeric lline;  lline = 0.4len;   % Length of oblique lines
      numeric offset; offset = 0.2len;  % Offset of the first line

      % Draw hatch lines
      pickup pencircle scaled default_pen_width;
      for i=1 upto n:
        draw ((0,0)--(lline,0))
          rotated (180+default_oblique) shifted (-len+offset + gap*i,-len)
          withcolor plmc_current_color;
      endfor

      fill unit_circle scaled r withcolor default_fill_color;
      draw unit_circle scaled r withcolor plmc_current_color;
      draw unit_circle scaled .5r withcolor plmc_current_color;
    );
    draw fixed_joint shifted p;

    pickup defaultpen;
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_current_serial_chain
% ------------------------------------------------------------------------------
% Draws a serial chain whose parameters are given with the following external 
% variables.
%
% N: degrees of freedom 
% q: joint angles 
% l: length of each link 
% w: width of each link 
%
def draw_current_serial_chain (expr show_lframe) =
  begingroup
    % Recursive transformation and drawing
    transform T[];
    T0 = identity shifted base_origin;
    for i=1 upto N:
      qq := 0;
      for j=1 upto (i-1):
        qq := qq + q[j];
      endfor
      T[i] = T[i-1] shifted -(xpart T[i-1], ypart T[i-1]) % Back to global origin
          rotated q[i]                                    % Rotate
          shifted (xpart T[i-1], ypart T[i-1])            % Back to local origin
          shifted ((l[i-1],0) rotated qq);                % Move to the next local origin
    endfor

    % draw fixed joint
    draw_fixed_joint (.6w1, base_origin);

    for i=1 upto N:
      draw_planar_link (l[i], w[i], T[i]);
      if show_lframe:
        draw_local_axes (u, T[i]);
      fi
    endfor

  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_current_serial_chain_annotated
% ------------------------------------------------------------------------------
% Draws a serial chain whose parameters are given with the following external 
% variables with annotation.
%
% N: degrees of freedom 
% q: joint angles 
% l: length of each link 
% w: width of each link 
%
def draw_current_serial_chain_annotated (expr show_lframe, offset, centerline_length) =
  begingroup
    % Recursive transformation and drawing
    transform T[];
    T0 = identity shifted base_origin;
    for i=1 upto N:
      qq := 0;
      for j=1 upto (i-1):
        qq := qq + q[j];
      endfor
      T[i] = T[i-1] shifted -(xpart T[i-1], ypart T[i-1]) % Back to global origin
          rotated q[i]                                    % Rotate
          shifted (xpart T[i-1], ypart T[i-1])            % Back to local origin
          shifted ((l[i-1],0) rotated qq);                % Move to the next local origin
    endfor

    % Draw base reference of angular displacement
    draw_centerline(0, T0, offset, centerline_length);

    for i=1 upto N-1:
      draw_centerline (l[i], T[i], offset, centerline_length);
    endfor

    % Draw the serial chain
    draw_current_serial_chain (show_lframe);

    % Mark angles 
    $ := 1;
    for i=1 upto N:
      r := .4l[i];
      label.rt(TEX("$\theta_" & decimal $ & "$"),
        (r, -.5r*q[i] * 3.14 / 180) transformed T[i]);
      label.ulft(TEX("$\tau_" & decimal $ & "$"),
        (0,8pt) transformed T[i]);
      $ := incr($);
    endfor

  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_axes
% ------------------------------------------------------------------------------
def draw_axes (expr l, T) =
  begingroup
    picture planar_axes;
    planar_axes := image (
      drawarrow (0,0)--(l,0) withcolor plmc_current_color;
      drawarrow (0,0)--(0,l) withcolor plmc_current_color;
    );
    pickup defaultpen;
    draw planar_axes transformed T;
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_global_reference_axes
% ------------------------------------------------------------------------------
def draw_global_reference_axes (expr l) =
  begingroup
    draw_axes (l,identity);

    numeric n;      n = 3;           % Number of oblique lines
    numeric gap;    gap = l/(n+4);   % Gap between oblique lines
    numeric lline;  lline = 0.25l;   % Length of oblique lines
    numeric offset; offset = 0.15l;  % Offset of the first line

    % Draw hatch lines
    pickup defaultpen;
    for i=1 upto n:
      draw ((0,0)--(lline,0))
        rotated (180+default_oblique) shifted (offset + gap*i,0)
        withcolor plmc_current_color;
    endfor
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_local_axes
% ------------------------------------------------------------------------------
def draw_local_axes (expr l, T) =
  begingroup
    draw_axes (l,T);
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_link_with_end_points
% ------------------------------------------------------------------------------
def draw_link_with_end_points (expr bz, ez, width) =
  begingroup
    pair nvector;
    nvector = unitvector(ez-bz) rotated 90;

    pair ul, ll, ur, lr;
    ul = bz + .5*width*nvector;
    ll = bz - .5*width*nvector;
    ur = ez + .5*width*nvector;
    lr = ez - .5*width*nvector;

    pickup pencircle scaled default_pen_width;
    filldraw ul--ur--lr--ll--cycle withcolor default_fill_color;
    draw ul--ur--lr--ll--cycle withcolor plmc_current_color;
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: draw_current_four_bar_link
% ------------------------------------------------------------------------------
def draw_current_four_bar_link (expr pbase, qbase) =
  begingroup
    save z;  pair z[];
    z1 = (0,0);
    z4 = (l4,0);

    save lcircle, rcircle, llink, mcircle, gz;
    path lcircle;
    lcircle = fullcircle scaled 2l1;

    path rcircle;
    rcircle = fullcircle scaled 2l3 shifted (l4,0);

    path llink;
    llink = z1--(l1,0) rotated q1;
    z2 = lcircle intersectionpoint llink;

    path mcircle;
    mcircle = fullcircle scaled 2l2 shifted z2;
    z3 = mcircle intersectionpoint rcircle;

    pair gz[];
    for i=1 upto 4:
      gz[i] = z[i] rotated qbase shifted pbase;
    endfor

    draw_link_with_end_points (gz1, gz2, w1);
    draw_link_with_end_points (gz2, gz3, w2);
    draw_link_with_end_points (gz3, gz4, w3);
    draw_link_with_end_points (gz4, gz1, w4);

    for i=1 upto 4:
      draw_dcircle_filled (default_ratio_rw * w[i], gz[i]);
    endfor

    draw_fixed_joint (default_ratio_rw * w1, gz1);
    draw_fixed_joint (default_ratio_rw * w4, gz4);
  endgroup
enddef;


% ------------------------------------------------------------------------------
%  Macro definition: current_four_bar_link_llft_joint
% ------------------------------------------------------------------------------
def current_four_bar_link_llft_joint (expr pbase, qbase) =
  begingroup
    save z;  pair z[];
    z1 = (0,0);
    z4 = (l4,0);

    save lcircle, rcircle, llink, mcircle, gz;
    path lcircle;
    lcircle = fullcircle scaled 2l1;

    path rcircle;
    rcircle = fullcircle scaled 2l3 shifted (l4,0);

    path llink;
    llink = z1--(l1,0) rotated q1;
    z2 = lcircle intersectionpoint llink;

    path mcircle;
    mcircle = fullcircle scaled 2l2 shifted z2;
    z3 = mcircle intersectionpoint rcircle;

    pair gz[];
    for i=1 upto 4:
      gz[i] = z[i] rotated qbase shifted pbase;
    endfor

    gz1
  endgroup
enddef;

% ------------------------------------------------------------------------------
%  Macro definition: current_four_bar_link_ulft_joint
% ------------------------------------------------------------------------------
def current_four_bar_link_ulft_joint (expr pbase, qbase) =
  begingroup
    save z;  pair z[];
    z1 = (0,0);
    z4 = (l4,0);

    save lcircle, rcircle, llink, mcircle, gz;
    path lcircle;
    lcircle = fullcircle scaled 2l1;

    path rcircle;
    rcircle = fullcircle scaled 2l3 shifted (l4,0);

    path llink;
    llink = z1--(l1,0) rotated q1;
    z2 = lcircle intersectionpoint llink;

    path mcircle;
    mcircle = fullcircle scaled 2l2 shifted z2;
    z3 = mcircle intersectionpoint rcircle;

    pair gz[];
    for i=1 upto 4:
      gz[i] = z[i] rotated qbase shifted pbase;
    endfor

    gz2
  endgroup
enddef;

% ------------------------------------------------------------------------------
%  Macro definition: current_four_bar_link_urt_joint
% ------------------------------------------------------------------------------
def current_four_bar_link_urt_joint (expr pbase, qbase) =
  begingroup
    save z;  pair z[];
    z1 = (0,0);
    z4 = (l4,0);

    save lcircle, rcircle, llink, mcircle, gz;
    path lcircle;
    lcircle = fullcircle scaled 2l1;

    path rcircle;
    rcircle = fullcircle scaled 2l3 shifted (l4,0);

    path llink;
    llink = z1--(l1,0) rotated q1;
    z2 = lcircle intersectionpoint llink;

    path mcircle;
    mcircle = fullcircle scaled 2l2 shifted z2;
    z3 = mcircle intersectionpoint rcircle;

    pair gz[];
    for i=1 upto 4:
      gz[i] = z[i] rotated qbase shifted pbase;
    endfor

    gz3
  endgroup
enddef;

% ------------------------------------------------------------------------------
%  Macro definition: current_four_bar_link_lrt_joint
% ------------------------------------------------------------------------------
def current_four_bar_link_lrt_joint (expr pbase, qbase) =
  begingroup
    save z;  pair z[];
    z1 = (0,0);
    z4 = (l4,0);

    save lcircle, rcircle, llink, mcircle, gz;
    path lcircle;
    lcircle = fullcircle scaled 2l1;

    path rcircle;
    rcircle = fullcircle scaled 2l3 shifted (l4,0);

    path llink;
    llink = z1--(l1,0) rotated q1;
    z2 = lcircle intersectionpoint llink;

    path mcircle;
    mcircle = fullcircle scaled 2l2 shifted z2;
    z3 = mcircle intersectionpoint rcircle;

    pair gz[];
    for i=1 upto 4:
      gz[i] = z[i] rotated qbase shifted pbase;
    endfor

    gz4
  endgroup
enddef;

% ------------------------------------------------------------------------------
%  Macro definition: draw_spring
% ------------------------------------------------------------------------------
def draw_spring (expr width, height, steps) =
  begingroup
    save z;  pair z[];
    save spring;  picture spring;

    for i=0 upto steps:
      z[2i] = (height/steps*i, -width/2);
      z[2i+1] = (height/steps*i, width/2);
    endfor

    spring := image (
      draw z0--z1;
      for i=1 upto steps:
        draw z[2i-1]--z[2i]--z[2i+1];
      endfor
      );

    spring
  endgroup
enddef;
