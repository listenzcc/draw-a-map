classdef zcctrigonometry_segment
    %ZCCTRIGONOMETRY_SEGMENT
    %   a segment
    
    properties
        mypoint = @zcctrigonometry_point
        p1
        p2
        length
    end
    
    methods
        function this = zcctrigonometry_segment( p1, p2 )
            if nargin==1
                p2=p1(2);
                p1=p1(1);
            end
            this.p1 = p1;
            this.p2 = p2;
            this.length = p1.distance(p2);
        end
        function side = whichside( this, p )
            if ~isa(p,'zcctrigonometry_point')
                error( 'wronginput, wrong point' )
            end
            side = (p.x-this.p1.x)*(this.p2.y-this.p1.y)>(p.y-this.p1.y)*(this.p2.x-this.p1.x);
        end
        function dis = colinearity( this, p )
            if ~isa(p,'zcctrigonometry_point')
                error( 'wronginput, wrong point' )
            end
            dis = abs( (p.x-this.p1.x)*(this.p2.y-this.p1.y)-(p.y-this.p1.y)*(this.p2.x-this.p1.x) );
        end
        function out = slope( this )
            out = (this.p1.y-this.p2.y) / (this.p1.x-this.p2.x);
        end
        function out = middlepoint( this )
            out = this.mypoint( (this.p1.x+this.p2.x)/2, (this.p1.y+this.p2.y)/2 );
        end
        function out = sameas( this, s )
            if (this.p1.sameas(s.p1)&& this.p2.sameas(s.p2)) || (this.p1.sameas(s.p2)&& this.p2.sameas(s.p1))
                out = true;
            else
                out = false;
            end
        end
        function out = showme( this )
            out = [ this.p1.name, this.p2.name ];
            if ischar( this.p1.name )
                out = [ this.p1.name, ',', this.p2.name ];
            end
        end
        function drawme( this, h, s, varargin )
            geth = get(h);
            axis_saved = [ geth.XLim, geth.YLim ];
            hold on
            if nargin<4
                line( [this.p1.x,this.p2.x], [this.p1.y,this.p2.y], 'color', 'g' )
            else
                line( [this.p1.x,this.p2.x], [this.p1.y,this.p2.y], varargin{:} )
            end
            if nargin>2 && ~isempty(s)
                text( (this.p1.x+this.p2.x)/2, (this.p1.y+this.p2.y)/2, s )
            end
            hold off
            axis( axis_saved )
        end
    end
    
end

