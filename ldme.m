close all
clear
clc

addpath zcc_classes
mypoint = @zcctrigonometry_point
mysegment = @zcctrigonometry_segment
mytriangle = @zcctrigonometry_triangle

%% ini
h = figure;
axis( [-1 1 -1 1] )
h = get( h, 'children' );

num_hit = 10;
% load points_input
% points_input = rand(num_hit,2)*2 - 1;
% save points_input points_input

%% hit points
list_point = [];
for j = 1 : num_hit
    [ x, y ] = ginput( 1 );
%     x = points_input( j, 1 );
%     y = points_input( j, 2 );
    if x<-1 || x>1 || y<-1 || y>1
        continue
    end
    point = mypoint( x, y );
    point.showme;
    if ~isempty(list_point)
        isgoodhit = true;
        for p_ = list_point
            if point.distance(p_)<0.1
                isgoodhit = false;
                break
            end
        end
        if ~isgoodhit
            continue
        end
    end
    point = point.nameme(length(list_point)+1);
    if isempty(list_point)
        list_point = point;
    else
        list_point(end+1) = point;
    end
    point.drawme( h, 'o' )
end
num_point = length(list_point);
if num_point < 4
    disp( 'not enough points, end now.' )
    return
end

%% link points
% each 2 points
% list_segment = [];
% for j = 1 : 2^num_point
%     s = dec2bin( j, num_point );
%     t=find(s=='1');
%     if 2~=length(t)
%         continue
%     end
%     segment = mysegment( list_point(t) );
%     segment.drawme( h, [], 'color', [ 0.5 0.5 0.25 ] )
%     list_segment = [ list_segment, segment ];
% end

%% flag triangles
% each 3 points
list_goodflag = [];
for a = 1 : num_point-2
    for b = a+1 : num_point-1
        for c = b+1 : num_point
            fprintf( '%06d\t%06d\t%06d\n', a, b, c )
            tri_points = list_point( [ a, b, c ] );
            tt = 1 : num_point;
            tt( [ a b c ] ) = '';
            % check colinearity
            iscolinearity = false;
            try
                triangle = mytriangle( tri_points );
            catch
                disp( [ tri_points(1).name, tri_points(2).name, tri_points(3).name, 0 ] );
                continue
            end
            % check if surround points
            isgoodtriangle = true;
            for tt_ = tt
                if triangle.containit(list_point(tt_))
                    isgoodtriangle = false;
                    break
                end
            end
            if ~isgoodtriangle
                %         disp( [ triangle.showme, badpointlist ] );
                continue
            end
            %     disp( triangle.showme );
            
            [p,r] = triangle.circumcenter;
            if isempty(p)
                continue
            end
            isbadflag = false;
            for p_ = list_point
                if r > p.distance(p_)
                    isbadflag = true;
                    break
                end
            end
            if ~isbadflag
                p.drawme( h, 'k*' )
%                 disp( [ p.name, '  good' ] )
                list_goodflag = [ list_goodflag, p ];
            else
%                 disp( [ p.name, '  bad' ] )
            end
        end
    end
end

% for f = list_goodflag
%     f.showme
% end
% axis( [ -2 2 -2 2 ] )

%% link flags
list_divider = [];
for j = 1 : length(list_goodflag)
    flag = list_goodflag(j);
    rest_goodflag = list_goodflag;
    rest_goodflag(j) = '';
    index_points = str2num(flag.name);
    index_points_{1} = index_points([1 2 3]);
    index_points_{2} = index_points([1 3 2]);
    index_points_{3} = index_points([2 3 1]);
    for jj = 1 : 3
        gotoboard = true;
        for f = rest_goodflag
            index_p = str2num(f.name);
            if ~isempty(find(index_p==index_points_{jj}(1), 1)) && ~isempty(find(index_p==index_points_{jj}(2), 1))
                segment = mysegment( flag, f );
                segment.drawme( h, [], 'color', 'k' )
                inthelist = false;
                for d = list_divider
                    if d.sameas(segment)
                        inthelist = true;
                        break
                    end
                end
                if ~inthelist
                    list_divider = [ list_divider, segment ];
                end
                gotoboard = false;
            end
        end
        if gotoboard
            if flag.x<-1 || flag.x>1 || flag.y<-1 || flag.y>1
                continue
            end
            tmpsegment = mysegment( list_point(index_points_{jj}(1)), list_point(index_points_{jj}(2)) );
            if tmpsegment.whichside(flag) == tmpsegment.whichside(list_point(index_points_{jj}(3)))
                segment = mysegment( flag, tmpsegment.middlepoint );
                k = segment.slope;
                if isinf( k )
                    if tmpsegment.whichside(flag) ~= tmpsegment.whichside(mypoint(flag.x,1))
                        point = mypoint(flag.x,1);
                    else
                        point = mypoint(flag.x,-1);
                    end
                end
                b = flag.y - k*flag.x;
                x_ = -1;
                y_ = k*x_+b;
                if y_<=1 && y_>=-1
                    if tmpsegment.whichside(flag) ~= tmpsegment.whichside(mypoint(x_,y_))
                        point = mypoint(x_,y_);
                    end
                end
                x_ = 1;
                y_ = k*x_+b;
                if y_<=1 && y_>=-1
                    if tmpsegment.whichside(flag) ~= tmpsegment.whichside(mypoint(x_,y_))
                        point = mypoint(x_,y_);
                    end
                end
                y_ = -1;
                x_ = (y_-b)/k;
                if x_<=1 && x_>=-1
                    if tmpsegment.whichside(flag) ~= tmpsegment.whichside(mypoint(x_,y_))
                        point = mypoint(x_,y_);
                    end
                end
                y_ = 1;
                x_ = (y_-b)/k;
                if x_<=1 && x_>=-1
                    if tmpsegment.whichside(flag) ~= tmpsegment.whichside(mypoint(x_,y_))
                        point = mypoint(x_,y_);
                    end
                end
                point = point.nameme( sprintf('%d,%d',index_points_{jj}(1),index_points_{jj}(2)) );
                point.drawme( h, 'k*' )
                segment = mysegment( flag, point );
                segment.drawme( h, [], 'color', 'k' )
            else
                segment = mysegment( flag, tmpsegment.middlepoint );
                k = segment.slope;
                if isinf( k )
                    if tmpsegment.whichside(flag) == tmpsegment.whichside(mypoint(flag.x,1))
                        point = mypoint(flag.x,1);
                    else
                        point = mypoint(flag.x,-1);
                    end
                end
                b = flag.y - k*flag.x;
                x_ = -1;
                y_ = k*x_+b;
                if y_<=1 && y_>=-1
                    if tmpsegment.whichside(flag) == tmpsegment.whichside(mypoint(x_,y_))
                        point = mypoint(x_,y_);
                    end
                end
                x_ = 1;
                y_ = k*x_+b;
                if y_<=1 && y_>=-1
                    if tmpsegment.whichside(flag) == tmpsegment.whichside(mypoint(x_,y_))
                        point = mypoint(x_,y_);
                    end
                end
                y_ = -1;
                x_ = (y_-b)/k;
                if x_<=1 && x_>=-1
                    if tmpsegment.whichside(flag) == tmpsegment.whichside(mypoint(x_,y_))
                        point = mypoint(x_,y_);
                    end
                end
                y_ = 1;
                x_ = (y_-b)/k;
                if x_<=1 && x_>=-1
                    if tmpsegment.whichside(flag) == tmpsegment.whichside(mypoint(x_,y_))
                        point = mypoint(x_,y_);
                    end
                end
                point = point.nameme( sprintf('%d,%d',index_points_{jj}(1),index_points_{jj}(2)) );
                point.drawme( h, 'k*' )
                segment = mysegment( flag, point );
                segment.drawme( h, [], 'color', 'k' )
            end
            list_divider = [ list_divider, segment ];
        end
    end
end

% link boardflag
list_boardflag = [];
for d = list_divider
    %     d.drawme( h, [], 'color', 'r' )
    if 2==length(str2num(d.p1.name))
        list_boardflag = [ list_boardflag, d.p1 ];
    end
    if 2==length(str2num(d.p2.name))
        list_boardflag = [ list_boardflag, d.p2 ];
    end
end
list_goodflag = [ list_goodflag, list_boardflag ];
vertex_point(1,1) = mypoint( -1, -1 );
vertex_point(1,2) = mypoint( -1, 1 );
vertex_point(1,3) = mypoint( 1, -1 );
vertex_point(1,4) = mypoint( 1, 1 );
distance_matrix = nan( 4, num_point );
for index_v = 1 : length( vertex_point )
    for index_p = 1 : num_point
        distance_matrix(  index_v, index_p ) = vertex_point(index_v).distance(list_point(index_p));
    end
end
for index_v = 1 : length( vertex_point )
    point = vertex_point( index_v );
    beflaged = false;
    for p = list_goodflag
        if point.sameas(p)
            beflaged = true;
            break
        end
    end
    if ~beflaged
        point = point.nameme( num2str( find(distance_matrix(index_v,:)==min(distance_matrix(index_v,:))) ) );
    end
    list_goodflag = [ list_goodflag, point ];
end

mytable = cell( num_point, 5 );
for j = 1 : num_point
    mytable{j,1} = list_point(j);
    mytable{j,5} = 0;
end
for j = 1 : length(list_goodflag)-1
    for k = j+1 : length(list_goodflag)
        p1 = list_goodflag(j);
        p2 = list_goodflag(k);
        l_p1 = str2num( p1.name );
        l_p2 = str2num( p2.name );
        mask_p1 = zeros( 1, num_point );
        mask_p1( l_p1 ) = 1;
        mask_p2 = zeros( 1, num_point );
        mask_p2( l_p2 ) = 1;
        mask_sum = mask_p1 + mask_p2;
        points_related = find(mask_sum==2);
        if ~isempty( points_related ) % if related
            if ( ( p1.x<-1 || p1.x>1 || p1.y<-1 || p1.y>1 ) && 3>length(l_p2) )...
                    || ( ( p2.x<-1 || p2.x>1 || p2.y<-1 || p2.y>1 ) && 3>length(l_p1)...
                    || ( p1.x<-1 || p1.x>1 || p1.y<-1 || p1.y>1 ) && ( p2.x<-1 || p2.x>1 || p2.y<-1 || p2.y>1 ) )
                segment = mysegment( p1, p2 );
                list_divider = [ list_divider, segment ];
                for r = points_related
                    conflicted = points_related;
                    conflicted( conflicted==r ) = '';
                    if isempty( mytable{r,4} )
                        mytable{r,4} = conflicted;
                    else
                        mytable{r,4} = [ mytable{r,4}, conflicted ];
                    end
                    if isempty( mytable{r,3} )
                        mytable{r,3} = segment;
                    else
                        mytable{r,3} = [ mytable{r,3}, segment ];
                    end
                end
                continue
            end
            if 3>length(l_p1) && 3>length(l_p2) % if both are boardflags
                if ~(p1.x==p2.x || p1.y==p2.y) % if has a conner
                    continue
                end
                segment = mysegment( p1, p2 );
                list_divider = [ list_divider, segment ];
                for r = points_related
                    if isempty( mytable{r,3} )
                        mytable{r,3} = segment;
                    else
                        mytable{r,3} = [ mytable{r,3}, segment ];
                    end
                end
            else
                if 2==length(points_related)
                    segment = mysegment( p1, p2 );
                    for r = points_related
                        conflicted = points_related;
                        conflicted( conflicted==r ) = '';
                        if isempty( mytable{r,4} )
                            mytable{r,4} = conflicted;
                        else
                            mytable{r,4} = [ mytable{r,4}, conflicted ];
                        end
                        if isempty( mytable{r,3} )
                            mytable{r,3} = segment;
                        else
                            mytable{r,3} = [ mytable{r,3}, segment ];
                        end
                    end
                end
            end
        end
    end
end
for s = list_divider
    s.drawme( h, [], 'color', 'r' )
end
for p = list_goodflag
    p.drawme( h, 'r*' )
    p_belongs = str2num( p.name );
    for j = p_belongs
        if isempty( mytable{j,2} )
            mytable{j,2} = p;
        else
            mytable{j,2} = [ mytable{j,2}, p ];
        end
    end
end

mytable

%% tint

list_numconflict = nan( num_point, 1 );
for j = 1 : num_point
    list_numconflict( j ) = length( mytable{j,4} );
end
new_mytable = cell( size(mytable) );
for j = 1 : num_point
    k = find( list_numconflict == max(list_numconflict) );
    for l = 1 : size(mytable,2)
        new_mytable{ j, l } = mytable( k, l );
    end
    list_numconflict( k ) = 0;
end
mytable

list_color = [ 1 0 0; 0 1 0; 1 0 1; 1 1 0 ]*0.5;
for j = 1 : num_point
    tmp_colorlist = [ 1 2 3 4 ];
    point = mytable{ j, 1 };
    dividers = mytable{ j, 3 };
    conflicts = mytable{ j, 4 };
    num_dividers = length(dividers);
    mypatchx = nan( 3, num_dividers );
    mypatchy = nan( 3, num_dividers );
    for jj = 1 : num_dividers
        mypatchx( :, jj ) = [ point.x; dividers(jj).p1.x; dividers(jj).p2.x ];
        mypatchy( :, jj ) = [ point.y; dividers(jj).p1.y; dividers(jj).p2.y ];
    end
    for c = conflicts
        tmp_colorlist( tmp_colorlist==mytable{c,5} ) = '';
    end
    try
        thecolor = tmp_colorlist(1);
    catch
        p = patch( mypatchx, mypatchy, ones(3,size(mypatchx,2)) );
        set( p, 'facecolor', [ 0.5 0.5 0.5 ] )
        continue
    end
    mytable{j,5} = thecolor;
    p = patch( mypatchx, mypatchy, ones(3,size(mypatchx,2)) );
    set( p, 'facecolor', list_color(thecolor,:) )
end
mytable

for p = list_point
    p.drawme( h, 'ko' )
end




