classdef zcctrigonometry_point
    %ZCCTRIGONOMETRY_POINT 
    %   a point
    
    properties
        x
        y
        name
    end
    
    methods
        function this = zcctrigonometry_point( x, y )
            if ~( isscalar(x)&&isnumeric(x) && isscalar(y)&&isnumeric(y) )
                error( 'wronginput, no point made' )
            end
            this.x = x;
            this.y = y;
            this.name = 0;
        end
        function out = distance( this, p2 )
            if ~isa(p2,'zcctrigonometry_point')
                error( 'wronginput, no distance' )
            end
            out = sqrt( [this.x-p2.x,this.y-p2.y] * [this.x-p2.x,this.y-p2.y]' );
        end
        function out = sameas( this, p )
            if this.x==p.x && this.y==p.y
                out = true;
            else
                out = false;
            end
        end
        function out = showme( this )
            out = [ this.x, this.y ];
        end
        function drawme( this, h, varargin )
            geth = get(h);
            axis_saved = [ geth.XLim, geth.YLim ];
            hold on
            plot( this.x, this.y, varargin{:} )
            if isnumeric(this.name)
                text( this.x+0.05, this.y+0.05, num2str(this.name) )
            else
                text( this.x+0.05, this.y+0.05, this.name )
            end
            hold off
            axis( axis_saved )
        end
        function this = nameme( this, s )
            this.name = s;
        end
    end
    
end

