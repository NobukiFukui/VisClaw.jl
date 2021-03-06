############################################################
"""
    poly = polyrectangle(tile::VisClaw.AMRGrid)

polygon data (rectangle) from a tile in AMR
"""
function polyrectangle(tile::VisClaw.AMRGrid)
    ## set the boundary
    x = [tile.xlow, tile.xlow+tile.dx*tile.mx]
    y = [tile.ylow, tile.ylow+tile.dy*tile.my]
    ## grid info
    xline = collect(Float64, x[1]+0.5tile.dx:tile.dx:x[2]-0.5tile.dx+1e-4)
    yline = collect(Float64, y[1]+0.5tile.dy:tile.dy:y[2]-0.5tile.dy+1e-4)

    ll = GeometricalPredicates.Point(xline[1], yline[1])
    lr = GeometricalPredicates.Point(xline[end], yline[1])
    ur = GeometricalPredicates.Point(xline[end], yline[end])
    ul = GeometricalPredicates.Point(xline[1], yline[end])
    poly = GeometricalPredicates.Polygon(ll, lr, ur, ul)

    return poly
end
############################################################


############################################################
"""
   rmvalue_coarser!(tiles::Vector{VisClaw.AMRGrid})

replace values at coarser grids (lower levels) to NaN 
"""
function rmvalue_coarser!(tiles::Vector{VisClaw.AMRGrid})
    # number of the tiles
    ntile = length(tiles)

    ## deepest level
    levels = getfield.(tiles,:AMRlevel);
    maxlevel = findmax(levels)[1]

    ## search points which are overlapped by the finer grids
    #i = 1
    for i=1:ntile
        # all points in 1-column
        xmesh, ymesh = VisClaw.meshtile(tiles[i])
        # convert type
        allp = GeometricalPredicates.Point.(xmesh,ymesh)

        #if tiles[i].AMRlevel != maxlevel; continue; end

        # compare the location of the target tile to that of other tiles
        #j=ntile
        for j = 1:ntile
            if i==j; continue; end
            if tiles[i].AMRlevel >= tiles[j].AMRlevel; continue; end
            rect = VisClaw.polyrectangle(tiles[j])

            for x = 1:tiles[i].mx
                for y = 1:tiles[i].my
                    inside = GeometricalPredicates.inpolygon(rect, allp[y,x])
                    if inside
                        #tiles[i].u[y,x] = NaN
                        #tiles[i].v[y,x] = NaN
                        if isa(tiles[i], VisClaw.Velocity)
                            tiles[i].u[y,x] = NaN
                            tiles[i].v[y,x] = NaN
                            tiles[i].vel[y,x] = NaN
                        elseif isa(tiles[i], VisClaw.Storm)
                            tiles[i].u[y,x] = NaN
                            tiles[i].v[y,x] = NaN
                            tiles[i].slp[y,x] = NaN
                        elseif isa(tiles[i], VisClaw.SurfaceHeight)
                            tiles[i].eta[y,x] = NaN
                        end
                        ## debugging
                        # print("(i,j,y,x) = ($i,$j,$y,$x)\n")
                    end
                end
            end
        end
    end

    ## return values
    return
end
############################################################
