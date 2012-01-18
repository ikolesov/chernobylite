function P = gradTowardsOne(phi)
  
  p       = 1:numel(phi(:));
  [rr cc] = ind2sub(size(phi), p);

  % shift operations
  shiftD = @(M) M(safe_sub2ind(size(phi), rr-1, cc));
  shiftU = @(M) M(safe_sub2ind(size(phi), rr+1, cc));
  shiftR = @(M) M(safe_sub2ind(size(phi), rr,   cc-1));
  shiftL = @(M) M(safe_sub2ind(size(phi), rr,   cc+1));
  shiftUL = @(M) M(safe_sub2ind(size(phi), rr-1, cc-1));
  shiftUR = @(M) M(safe_sub2ind(size(phi), rr-1, cc+1));
  shiftDL = @(M) M(safe_sub2ind(size(phi), rr+1, cc-1));
  shiftDR = @(M) M(safe_sub2ind(size(phi), rr+1, cc+1));

  % derivative operations
  Dx  = @(M) (shiftL(M) - shiftR(M))/2;
  Dy  = @(M) (shiftU(M) - shiftD(M))/2;
  Dxx = @(M) (shiftL(M) - 2*M(p) + shiftR(M));
  Dyy = @(M) (shiftU(M) - 2*M(p) + shiftD(M));
  Dxy = @(M) (shiftUL(M) + shiftDR(M) - shiftUR(M) - shiftDL(M))/4;
  
  % TODO: evaluate boundary conditions properly! don't force constant value ...
  
  % derivatives
  dx  = Dx(phi);  dy  = Dy(phi);
  dx2 = dx.^2;    dy2 = dy.^2;
  dxx = Dxx(phi); dyy = Dyy(phi); dxy = Dxy(phi);

  %Q = (dx2.*dyy + dy2.*dxx - 2*dx.*dy.*dxy)./(dx2 + dy2 + eps);
  Q = (dxx.^2+dyy.^2-1);
  R1= dx.*dxx+dy.*dxy;
  R2= dx.*dxy+dy.*dyy;
  P = 0*phi; 
  P(p) = (dxx + dyy).*Q + 2 * ( dx.*R1 + dy.*R2 );
  fprintf('');
end

function ind = safe_sub2ind(sz, rr, cc)
  rr(rr < 1) = 1;
  rr(rr > sz(1)) = sz(1);
  cc(cc < 1) = 1;
  cc(cc > sz(2)) = sz(2);
  ind = sub2ind(sz, rr, cc);
end
