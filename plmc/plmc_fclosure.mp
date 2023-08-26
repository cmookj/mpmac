%
%  PLMC_FCLOSURE.MP
%
%  Settings and macros for drawing of form & force closure
%
%  Copyright (c) 2013 Changmook Chun.
%


% Include common settings first
input plmc_common


% Definition of line width parameters for form & force closure drawings
numeric plmc_line_width_outer;
plmc_line_width_outer = plmc_line_width_bold;

numeric plmc_line_width_inner;
plmc_line_width_inner = plmc_line_width_light;

numeric plmc_fcone_line_width;
plmc_fcone_line_width = plmc_line_width_light;


% Line width for drawing point contact mark
numeric plmc_contact_width;
plmc_contact_width = 4pt;

% Offset between actual contact point and drawing of contact mark
numeric plmc_contact_offset;
plmc_contact_offset = 4pt;



% -----------------------------------------------------------------------------
%
%  draw_path_STYLE_grasped_at
%
% -----------------------------------------------------------------------------
def draw_path_grasped_at (expr p, a, dir, lwidth) =
  %  This macro draws path p and grasp point at a (0<=a<=1) along p.
  %  If dir = 90, the grasp point is drawn on the left side of the path.
  %  If dir = -90, the grasp point is drawn on the right side of the path.
  begingroup
    save grasp;
    pair grasp;
    grasp = grasp_point_along_path_at (p, a, dir);

    pickup pencircle scaled plmc_contact_width;
    drawdot grasp;

    pickup pencircle scaled lwidth;
    draw p;
    pickup defaultpen;
  endgroup
enddef;


def draw_path_plain_grasped_left_at (expr p, a) =
  draw_path_grasped_at (p, a, 90, plmc_line_width_plain);
enddef;


def draw_path_plain_grasped_right_at (expr p, a) =
  draw_path_grasped_at (p, a, -90, plmc_line_width_plain);
enddef;


def draw_path_bold_grasped_left_at (expr p, a) =
  draw_path_grasped_at (p, a, 90, plmc_line_width_bold);
enddef;


def draw_path_bold_grasped_right_at (expr p, a) =
  draw_path_grasped_at (p, a, -90, plmc_line_width_bold);
enddef;


def draw_path_light_grasped_left_at (expr p, a) =
  draw_path_grasped_at (p, a, 90, plmc_line_width_light);
enddef;


def draw_path_light_grasped_right_at (expr p, a) =
  draw_path_grasped_at (p, a, -90, plmc_line_width_light);
enddef;




def grasp_point_along_path_at (expr p, a, dir) =
  % This macro returns a position of grasp point at a (0 <= a <= 1) along p.
  % If dir = 90, the grasp point is on the left side of the path.
  % If dir = -90, the grasp point is on the right side of the path.
  begingroup
    save gnormal, t, grasp;
    pair gnormal, grasp;
    t = arc_time_along_path_at (p, a);
    gnormal = normal_along_path_at (p, a, dir);
    grasp = (plmc_contact_offset * gnormal) shifted (point t of p);
    grasp
  endgroup
enddef;


def left_grasp_point_along_path_at (expr p, a) =
  grasp_point_along_path_at (p, a, 90);
enddef;


def right_grasp_point_along_path_at (expr p, a) =
  grasp_point_along_path_at (p, a, -90);
enddef;




% -----------------------------------------------------------------------------
%
%  draw_path_grasped_with_cone_at
%
% -----------------------------------------------------------------------------
%
%  This macro draws path p, grasp point at a (0<=a<=1) along p,
%  and a friction cone.
%
%  The angle of the friction cone is 2q.
%
%  The length of the friction cone is l.
%
%  If dir = 90, the grasp point is drawn on the left side of the path, and the
%               friction cone on the right side.
%  If dir = -90, the grasp point is drawn on the right side of the path, and the
%                friction cone on the left side.
%
%  lwidth is the width of the path.
%
def draw_path_grasped_with_cone_at (expr p, a, dir, q, l, lwidth) =
  begingroup
    save gpoint, t, gnormal;
    pair gnormal;

    t = arc_time_along_path_at (p, a);
    gnormal = normal_along_path_at (p, a, dir);

    draw_path_grasped_at (p, a, dir, lwidth);

    % Draw friction cone
    draw_fcone_at (p, a, -dir, q, l);
  endgroup
enddef;


def draw_path_plain_grasped_left_with_cone_at (expr p, a, q, l) =
  draw_path_grasped_with_cone_at (p, a, 90, q, l, plmc_line_width_plain);
enddef;


def draw_path_plain_grasped_right_with_cone_at (expr p, a, q, l) =
  draw_path_grasped_with_cone_at (p, a, -90, q, l, plmc_line_width_plain);
enddef;


def draw_path_bold_grasped_left_with_cone_at (expr p, a, q, l) =
  draw_path_grasped_with_cone_at (p, a, 90, q, l, plmc_line_width_bold);
enddef;


def draw_path_bold_grasped_right_with_cone_at (expr p, a, q, l) =
  draw_path_grasped_with_cone_at (p, a, -90, q, l, plmc_line_width_bold);
enddef;


def draw_path_light_grasped_left_with_cone_at (expr p, a, q, l) =
  draw_path_grasped_with_cone_at (p, a, 90, q, l, plmc_line_width_light);
enddef;


def draw_path_light_grasped_right_with_cone_at (expr p, a, q, l) =
  draw_path_grasped_with_cone_at (p, a, -90, q, l, plmc_line_width_light);
enddef;




%  This macro a friction cone at a (0<=a<=1) along p.
%  The angle of the friction cone is 2q.
%  The length of the friction cone is l.
%  If dir = 90, the friction cone is drawn on the left side of the path.
%  If dir = -90, the friction cone is drawn on the right side of the path.
def draw_fcone_at (expr p, a, dir, q, l) =
  begingroup
    save gpoint, t, gnormal;
    pair gnormal;

    t = arc_time_along_path_at (p, a);
    gnormal = normal_along_path_at (p, a, dir);

    % Draw friction cone
    pickup pencircle scaled plmc_fcone_line_width;
    drawarrow ((0,0)--(gnormal*l)) rotated q shifted point t of p;
    drawarrow ((0,0)--(gnormal*l)) rotated -q shifted point t of p;
    pickup defaultpen;
  endgroup
enddef;


def draw_left_fcone_at (expr p, a, q, l) =
  draw_fcone_at (p, a, 90, q, l);
enddef;


def draw_right_fcone_at (expr p, a, q, l) =
  draw_fcone_at (p, a, -90, q, l);
enddef;
