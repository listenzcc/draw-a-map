classdef zcctrigonometry_triangle
    %ZCCTRIGONOMETRY_TRIANGLE
    %   a triangle
    
    properties
        mysegment = @zcctrigonometry_segment
        mypoint = @zcctrigonometry_point
        p1
        p2
        p3
    end
    
    methods
        function this = zcctrigonometry_triangle( p1, p2, p3 )
            if nargin == 1
                p2 = p1(2);
                p3 = p1(3);
                p1 = p1(1);
            end
            this.p1 = p1;
            this.p2 = p2;
            this.p3 = p3;
        end
        function out = containit( this, p )
            tri_list = 1 : 3;
            tri_points = [ this.p1, this.p2, this.p3 ];
            onoppositside = false;
            for tri_ = 1 : 3
                tri_2 = tri_list;
                tri_2(tri_) = '';
                point = tri_points(tri_);
                segment = this.mysegment( tri_points(tri_2) );
                if segment.whichside(point)~=segment.whichside(p)
                    onoppositside = true;
                    break
                end
            end
            if onoppositside
                out = false;
            else
                out = true;
            end
        end
        function out = showme( this )
            out = [ this.p1.name, this.p2.name, this.p3.name ];
        end
        function drawme( this, h, varargin )
            geth = get(h);
            axis_saved = [ geth.XLim, geth.YLim ];
            hold on
            tri_points = [ this.p1, this.p2, this.p3 ];
            for j = [ 1 2 3; 2 3 1 ]
                line( [tri_points(j(1)).x,tri_points(j(2)).x], [tri_points(j(1)).y,tri_points(j(2)).y], varargin{:} )
            end
            hold off
            axis( axis_saved )
        end
        function [ point, r ] = circumcenter( this )
            segment1 = this.mysegment( this.p1, this.p2 );
            if segment1.colinearity( this.p3 )==0
                point = this.mypoint( 0, 0 );
                point = point.nameme( sprintf('%d,%d,%d',this.p1.name,this.p2.name,this.p3.name) );
                r = 0;
                point = [];
                r = [];
                return
            end
            segment2 = this.mysegment( this.p1, this.p3 );
            k1 = -1/segment1.slope;
            k2 = -1/segment2.slope;
            b1 = segment1.middlepoint.y - k1*segment1.middlepoint.x;
            b2 = segment2.middlepoint.y - k2*segment2.middlepoint.x;
            x = (b2-b1)/(k1-k2);
            y = k1*x + b1;
            if isinf(k1)
                x = segment1.middlepoint.x;
                y = k2*x+b2;
            end
            if isinf(k2)
                x = segment2.middlepoint.x;
                y = k1*x+b1;
            end
            if isnan(x) || isnan(y)
                keyboard
            end
%             if x > 1
%                 x = 1;
%             end
%             if x < -1
%                 x = -1;
%             end
%             if y > 1
%                 y = 1;
%             end
%             if y < -1
%                 y = -1;
%             end
            point = this.mypoint( x, y );
            point = point.nameme( sprintf('%d,%d,%d',this.p1.name,this.p2.name,this.p3.name) );
            r = min( [point.distance(this.p1),point.distance(this.p2),point.distance(this.p3)] );
        end
    end
    
end

