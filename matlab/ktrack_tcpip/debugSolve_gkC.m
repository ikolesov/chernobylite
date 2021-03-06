function [wA wB wF wX data] = debugSolve_gkC( )

dbstop if error

% W1C1 is harder to interpret ...
%data=load('gctrlResults_W1C1.mat'); TKR=data.TKR; KOpts=data.KOpts; r=data.results;

data=load('gctrlResults_X_W1C1.mat'); TKR=data.TKR; KOpts=data.KOpts; r=data.results;
fprintf('\n');
sfigure(1); clf; hold on;
r.nFrame_in = [0;r.nFrame_in];
r.estm_xy   = [r.estm_xy(1,:); r.estm_xy(:,:)]; % g_ctrl was from *previous* centroid
wA = [];  % fixed K * centroid
wB = [];  % read back from saved
wF = [];  % frame to frame
wX = [];  % newish method

for m = 1:numel(r.ang_diff)
  
  g_f2f  = r.g_f2f(:,:,m);
  g_ctrl = r.g_ctrl(:,:,m);
  tx     = r.estm_xy(m,1)-320; %tx = -tx;
  ty     = r.estm_xy(m,2)-240; %ty = -ty;
  Nt     = r.nFrame_in(m+1)-r.nFrame_in(m); tauDelay = Nt;
  
  w_f2f        = skewsym( g_f2f ); 
  Kt           = 3 / sqrt(TKR.img_size(1) * TKR.img_size(2) );
  w_ctrlA      = [  Kt*ty;  % 
                    Kt*tx;  
                         0 ]*pi/180;
  w_ctrlA      = Nt * w_ctrlA;                       
  w_ctrlB      = skewsym( g_ctrl );
  
  % assert( sum( 0 > w_ctrlA(1:2) .* w_ctrlB(1:2) ) == 0 )
  
  plot( w_ctrlA(1), w_ctrlA(2), 'rx' )
  plot( w_ctrlB(1), w_ctrlB(2), 'bo' )
  plot( w_f2f(1), w_f2f(2), 'ks' )
  
  wA = [wA, w_ctrlA(:)]; wB = [wB, w_ctrlB(:)]; wF = [wF, w_f2f(:)];
  
 % fprintf(''); pause(0.001);
  
  

  wMax    =  tauDelay * [0.25;0.25] * 1/(180/pi);
  w_f2fin =  w_f2f(1:2);
  xydirin =  [tx;ty] ./ sqrt(1e-15+tx.^2+ty.^2);
  
  opts    = optimset('Display','final','MaxFunEvals',10^3,.... %'iter-detailed'
                     'Algorithm','active-set','TolFun',1e-8,'TolX',1e-8);
  [x,fval,exitflag,output,lambda]= ...
                fmincon(@wcost,0.5*w_ctrlA(1:2),[],[],[],[],-wMax,wMax,@wcon,opts); 
  cin = wcon(x); 
 %   assert( max(cin) <= 1e-5 || ( norm(w_f2fin) < 1e-6)  );
  w_ctrlX = [x(:)',0];
  wX = [wX, w_ctrlX(:)];
  
  
  F = w_f2f(:)'
  A = w_ctrlA(:)'
  B = w_ctrlB(:)'
  X = [x(:)', 0]
  
  fprintf('');
  
end
hold off;

%plot( wA(1,:),'r--x'); hold on; %plot( wF(1,:), 'k--s'); plot( wB(1,:), 'b--o');
%plot( wA(2,:),'r-x'); hold on; 
%plot( wF(2,:), 'k-s'); %plot( wB(2,:), 'b-o'); 
%plot( wX(1,:),'m--*'); 
%plot( wX(2,:), 'm-s'); hold off;
for fn=1:2
sfigure(fn); clf; 
plot(wF(fn,:),'r-s'); hold on; 
plot(wA(fn,:),'k--s'); plot( wX(fn,:),'b-o'); 
hold off; legend('f2f measured','linear model','Solved');
end
ex=norm( wX - wF ,'fro' )
ea=norm( wA - wF ,'fro' )

% Better solution:  
%                     minimize   norm(w_k_d), 
%                     subject to  w_f2f - w_ctrl = w_k_d  , 
%                     |w_ctrl| < w_max
%        in general:  w_ctrl = F( phi_measurements )  or   F0 <= w_ctrl <= F1
%        this case:   w_ctrl = K * [tx; ty] => compare directions! 


                                                    %#ok<ASGLU>
  
  % This configuration works; insert it to run on the fly!   
  fprintf('');  

  function E = wcost( x )
    
    w_ctrl = x(:);
    w_k_d  = w_f2fin(:) - w_ctrl; % tauDelay removed... already applied it at init
    E      = ( sum( abs(w_k_d).^2 ) );
    
  end

  function [cin,ceq] = wcon(x)
    w_ctrl = x(:);
    
    if ( min( [ sum(abs(xydirin)), sum(abs(w_ctrl))] ) < 1e-9 )
      cin  = [0];%;0;0];
    else
      xydir_w= [w_ctrl(2);w_ctrl(1)]/sqrt(sum(w_ctrl(1:2).^2));  
      % want <w1,w2> damn close to 1 (colinear)
      cin    = [-((xydir_w'*xydirin)-0.95) ];
%                  -w_ctrl(2) * ty;
%                  -w_ctrl(1) * tx];
      
                      %cin(x) <= 0
    end
    ceq    = [];      %ceq(x) == 0
  end

end


% bogus
%   for m = 1:size(w1,1)
%     for n = 1:size(w1,2)
%       x = [w1(m,n); w2(m,n)];
%       wE(m,n)= wcost(x);
%       [cin,ceq] = wcon(x);
%       wCin1(m,n)=cin(3);
%       wCin2(m,n)=cin(4);
%     end
%   end

% % % 
% % % disp( logm(TKR.g_k_d)+logm(TKR.g_ctrl) ) ; 
% % % disp( logm( TKR.g_f2f ) )
% % % m            = tkr.img_size(1);
% % % n            = tkr.img_size(2);
% % % [xx yy]      = meshgrid(linspace(1,n,n),linspace(1,m,m));
% % % 
% % % z0           = -100.0;
% % % xx           = -(xx - (n-1)/2) / tkr.f * z0;
% % % yy           =  (yy - (m-1)/2) / tkr.f * z0;
% % % 
% % % tx           =  TKR.xyF(1) - (n)/2;
% % % ty           =  TKR.xyF(2) - (m)/2;
% % % 
% % % g_f2f        = tkr.g_f2f;
% % % z_f2f        = real(logm(g_f2f));
% % % w_f2f        = [z_f2f(3,2); -z_f2f(3,1); z_f2f(2,1)]';
% % % Kt           = 3 / sqrt(m*n);
% % % w_ctrl       = [  Kt*ty;  % 
% % %                   Kt*tx;  
% % %                          0 ]'*pi/180;
% % % 
% % % % Bound the control appropriately
% % % yaw_and_pitch = w_ctrl(1:2)*180/pi;
% % % yaw_and_pitch(yaw_and_pitch<-0.25)=-0.25;
% % % yaw_and_pitch(yaw_and_pitch> 0.25)= 0.25;
% % % w_ctrl(1:2) = yaw_and_pitch*pi/180;
% % % 
% % % tauDelay     = TKR.curr_Nframe - TKR.prev_Nframe;
% % % g_ctrl       = expm([ tauDelay * [ skewsym(w_ctrl), [0;0;0] ]; [0 0 0 0] ])
% % % w_f2f_hat    = w_f2f- tauDelay * w_ctrl;
% % % fprintf( 'Ndelay=%02d, wx=%4.4f, wy=%4.4f, wz=%4.4f \n',tauDelay,...
% % %   w_f2f_hat(1),...
% % %   w_f2f_hat(2),...
% % %   w_f2f_hat(3) );
% % % 
% % % g_k_d = expm( real( logm( g_f2f ) - logm( g_ctrl ) ) ); fprintf('');
% % % 
% % % % aha, issue: g_k_d had -.0078, g_ctrl had 0.0044; more effort needs to be in g_ctrl! 
% % % tmp1=( logm( g_k_d ) +logm(g_ctrl) ) 
% % % tmp2=( logm( g_f2f ) )
% % % tmp3= logm( g_ctrl )
% % % 
% % % % Better solution:  
% % % %                     minimize   -norm( w_ctrl ) + norm(w_k_d), 
% % % %                    subject to  w_f2f - w_ctrl = w_k_d  ,  |w_ctrl| < w_max
