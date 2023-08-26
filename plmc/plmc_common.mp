%
%  PLMC_COMMON.MP
%
%  Common settings and macros for the drawings of planar mechanism
%
%  Copyright (c) 2013 Changmook Chun.
%


% 'bp' stands for big point is the default unit of postscript.
%   1bp = 1/72 in.
% 'pt' stands for printer point.
%   1pt = 1/72.27 in.
% In this macro set, pt is used instead of bp.


% Default unit for length
numeric u;
u = 1cm;


% I prefer a longer and sharper arrow head
ahangle := 30;
ahlength := 6pt;


% Default pen and white shadow widths.
%
% All parameters for line width depend on plain style.
% Light style is the half of plain style.
% Bold style is the double of plain style.

numeric plmc_line_width_plain;
plmc_line_width_plain = 1pt;

numeric plmc_line_width_light;
plmc_line_width_light = .5 plmc_line_width_plain;

numeric plmc_line_width_bold;
plmc_line_width_bold = 2 plmc_line_width_plain;

numeric plmc_line_width_xbold;
plmc_line_width_xbold = 2 plmc_line_width_bold;

numeric plmc_current_line_width;
plmc_current_line_with = plmc_line_width_plain;



numeric plmc_wshadow_factor;
plmc_wshadow_factor = 4;

numeric plmc_wshadow_width_plain;  % Default width for white shadow of front lines
plmc_wshadow_width_plain = plmc_wshadow_factor * plmc_line_width_plain;

numeric plmc_wshadow_width_bold; % Default width for white shadow of front bold lines
plmc_wshadow_width_bold = plmc_wshadow_factor * plmc_line_width_bold;

numeric plmc_wshadow_width_light; % Default width for white shadow of front light lines
plmc_wshadow_width_light = plmc_wshadow_factor * plmc_line_width_light;


% Default sizes for mark of angle
numeric plmc_angle_radius;
plmc_angle_radius = 18pt;

numeric plmc_mark_size;
plmc_mark_size = 4pt;

numeric plmc_mark_width;
plmc_mark_width = .5pt;


% Color and greyscale values
color plmc_current_color;
plmc_current_color := black;

def plmc_global_set_greyscale (expr gs) =
  defaultcolormodel := 3;
  plmc_current_color := (gs, gs, gs);
enddef;

def plmc_global_set_rgb_color (expr rc) =
  defaultcolormodel := 5;
  plmc_current_color := rc;
enddef;




% Common macros
def mark_angle (expr a, b, c) =
  begingroup
    save s, p;
    path p;
    p = unitvector(a-b){(a-b)rotated 90}..unitvector(c-b);
    s = .9plmc_mark_size/length(point 1 of p - point 0 of p);
    if s<plmc_angle_radius: s := plmc_angle_radius; fi
    % pickup pencircle scaled plmc_mark_width;
    draw (p scaled s shifted b) withcolor plmc_current_color;
  endgroup
enddef;


def mark_rt_angle (expr a, b, c) =
  draw ((1,0)--(1,1)--(0,1))
    zscaled (plmc_angle_radius * unitvector(a-b)) shifted b
    withcolor plmc_current_color;
enddef;


% -----------------------------------------------------------------------------
%  draw_front_path
% -----------------------------------------------------------------------------
def draw_front_path (expr p, lwidth) =
  begingroup
    linecap := butt;
    pickup pencircle scaled (plmc_wshadow_factor*lwidth);
    draw p withcolor white;

    linecap := rounded;
    pickup pencircle scaled lwidth;
    draw p withcolor plmc_current_color;
  endgroup
enddef;


def draw_front_path_plain (expr p) =
  draw_front_path (p, plmc_line_width_plain);
enddef;


def draw_front_path_bold (expr p) =
  draw_front_path (p, plmc_line_width_bold);
enddef;


def draw_front_path_light (expr p) =
  draw_front_path (p, plmc_line_width_light);
enddef;


% -----------------------------------------------------------------------------
%  draw_path
% -----------------------------------------------------------------------------
def draw_path (expr p, lwidth) =
  pickup pencircle scaled lwidth;
  draw p withcolor plmc_current_color;
  pickup defaultpen;
enddef;


def draw_path_plain (expr p) =
  draw_path (p, plmc_line_width_plain);
enddef;


def draw_path_light (expr p) =
  draw_path (p, plmc_line_width_light);
enddef;


def draw_path_bold (expr p) =
  draw_path (p, plmc_line_width_bold);
enddef;


% -----------------------------------------------------------------------------
%
%  Utility macros
%
% -----------------------------------------------------------------------------

% Find a point along a path p.
%
%  The path is assumed to be parametrized by its normalized length, i.e.,
%  the path begins with a = 0, and ends with a = 1.
%  This macro returns the point p(a), where 0 <= a <= 1.
%
def point_along_path_at (expr p, a) =
  begingroup
    save gpoint, t;
    pair thePoint;
    gpoint = a*arclength p;
    t = arctime gpoint of p;
    thePoint = point t of p;
    thePoint
  endgroup
enddef;


% Find arc time along a path p at a.
%
%  This macro returns the arc time along a path p at a,
%  where 0 <= a <= 1.
%
def arc_time_along_path_at (expr p, a) =
  begingroup
    save gpoint, t;
    gpoint = a*arclength p;
    t = arctime gpoint of p;
    t
  endgroup
enddef;


% Find normal vector along a path p at a.
%
%  This macro returns the normal vector along a path p at a,
%  where 0 <= a <= 1.
%
%  The parameter 'dir' is either 90 or -90.
%  When dir is 90, this macro finds the normal vector directed to
%  the left of the path.
%  When dir = -90, this macro finds the normal vector directed to
%  the right of the path.
%
def normal_along_path_at (expr p, a, dir) =
  begingroup
    save t, gnormal;
    pair gnormal;

    t = arc_time_along_path_at (p, a);
    gnormal = unitvector direction t of p rotated dir; % Normal vector to the grasp point
    gnormal
  endgroup
enddef;


def left_normal_along_path_at (expr p, a) =
  normal_along_path_at (p, a, 90);
enddef;


def right_normal_along_path_at (expr p, a) =
  normal_along_path_at (p, a, -90);
enddef;


% Draw spring
%
%  This macro draws a spring connecting two points, given by b and f.
%
%  b: first end point of the spring
%  f: second end point of the spring
%  n: the number of turns of the spring
%  w: the width of the spring
%  lwidth: line width
def draw_spring (expr b, f, n, w, lwidth) =
  begingroup
    save sv;  pair sv;
    sv = f - b;

    save wn;  numeric wn;
    wn = w/(abs(sv));

    save T;  transform T;
    T = identity zscaled sv shifted b;

    save z;  pair z[];
    z0 = (0,0);     % starting point
    z[n+2] = (1,0); % ending point

    for i = 1 upto (n+1):
      z[i] = (i/(n+2))[z0,z[n+2]];
    endfor

    pickup pencircle scaled lwidth;
    draw (z0 transformed T)--(z1 transformed T) withcolor plmc_current_color;
    for i = 1 upto n:
      draw (z[i] transformed T)
        --((.25[z[i],z[i+1]] shifted (0,.5wn)) transformed T)
        --((.75[z[i],z[i+1]] shifted (0,-.5wn)) transformed T)
        --(z[i+1] transformed T) withcolor plmc_current_color;
    endfor
    draw (z[n+1] transformed T)--(z[n+2] transformed T) withcolor plmc_current_color;
  endgroup
enddef;

def draw_spring_light (expr b, f, n, w) =
  draw_spring (b, f, n, w, plmc_line_width_light);
enddef;

def draw_spring_plain (expr b, f, n, w) =
  draw_spring (b, f, n, w, plmc_line_width_plain);
enddef;

def draw_spring_bold (expr b, f, n, w) =
  draw_spring (b, f, n, w, plmc_line_width_bold);
enddef;

def draw_spring_xbold (expr b, f, n, w) =
  draw_spring (b, f, n, w, plmc_line_width_xbold);
enddef;
