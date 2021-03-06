%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% computeUpwindDerivatives2D() computes the upwind Hamilton-Jacobi
% spatial derivatives of the specified order for 2D grid functions.
%
% Usage: [phi_x, phi_y] = ...
%        computeUpwindDerivatives2D(phi, ...
%                                   vel_x, vel_y, ...
%                                   ghostcell_width, ...
%                                   dX, ...
%                                   spatial_derivative_order)
%
% Arguments:
% - phi:                       function for which to compute upwind 
%                                derivative
% - vel_x:                     x-component of velocity to use in upwinding
% - vel_y:                     y-component of velocity to use in upwinding
% - ghostcell_width:           number of ghostcells at boundary of
%                                computational domain
% - dX:                        array containing the grid spacing
%                                in coordinate directions
% - spatial_derivative_order:  spatial derivative order
%                                (default = 1)
%
% Return values:
% - phi_x:                     x-component of upwind HJ ENO/WENO derivative
% - phi_y:                     y-component of upwind HJ ENO/WENO derivative
%
% NOTES:
% - The vel_x and vel_y arrays are assumed to be the same size.
% 
% - phi_x and phi_y have the same ghostcell width as phi.
% 
% - All data arrays are assumed to be in the order generated by the
%   MATLAB meshgrid() function.  That is, data corresponding to the
%   point (x_i,y_j) is stored at index (j,i).  The output data arrays
%   will be returned with the same ordering as the input data arrays.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyrights: (c) 2005 The Trustees of Princeton University and Board of
%                 Regents of the University of Texas.  All rights reserved.
%             (c) 2009 Kevin T. Chu.  All rights reserved.
% Revision:   $Revision: 149 $
% Modified:   $Date: 2009-01-18 00:31:09 -0800 (Sun, 18 Jan 2009) $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [phi_x, phi_y] = ...
         computeUpwindDerivatives2D(phi, ...
                                    vel_x, vel_y, ...
                                    ghostcell_width, ...
                                    dX, ...
                                    spatial_derivative_order)

% parameter checks
if (nargin < 4)
  error('MATLAB:missingArgs','computeUpwindDerivatives2D:missing arguments');
end

if (nargin < 5)
  spatial_derivative_order = 1;
else
  if ( (spatial_derivative_order ~= 1) & (spatial_derivative_order ~= 2) ...
     & (spatial_derivative_order ~= 3) & (spatial_derivative_order ~= 5) )

    error('computeUpwindDerivatives2D:Invalid spatial derivative order...only 1, 2, 3, and 5 are supported');
  end
end

switch (spatial_derivative_order)

  case 1
    [phi_x, phi_y] = UPWIND_HJ_ENO1_2D(phi, vel_x, vel_y, ghostcell_width, dX);

  case 2
    [phi_x, phi_y] = UPWIND_HJ_ENO2_2D(phi, vel_x, vel_y, ghostcell_width, dX);

  case 3
    [phi_x, phi_y] = UPWIND_HJ_ENO3_2D(phi, vel_x, vel_y, ghostcell_width, dX);

  case 5
    [phi_x, phi_y] = UPWIND_HJ_WENO5_2D(phi, vel_x, vel_y, ghostcell_width, dX);

end
