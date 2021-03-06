####################################################
function makecptfromgrd(G::GMT.GMTgrid; factor_lims::Float64=0.8, sigdigits_lims::Int64=2,
	                                    T=[], kwargs...)
	isempty(T) && ( T=round.(factor_lims.*extrema(G.z), sigdigits=sigdigits_lims) )
	return GMT.makecpt(; T=T, kwargs...)
end
####################################################


####################################################
function gmttopo(G::GMT.GMTgrid; factor_lims::Float64=0.8, sigdigits_lims::Int64=2,
	                             C=:geo, T=[], D::Bool=true, J="", R="", kwargs...)
	## cpt
	isa(C, GMT.GMTcpt) || ( cpt=makecptfromgrd(G; factor_lims=factor_lims, sigdigits_lims=sigdigits_lims, C=C, T=T, D=D) )
	isempty(J) && ( J=getJ("X10", axesratio(G)) )
	isempty(R) && ( R=getR(G) )
    ## plot
    GMT.grdimage(G; C=cpt, J=J, R=R, Q=true, kwargs...)

    ## return
	return cpt
end
####################################################
gmttopo(topo::VisClaw.Topo; kwargs...) = gmttopo(geogrd(topo); kwargs...)
####################################################



####################################################
"""
    gmttoporange!(geo::VisClaw.AbstractTopo; kwargs...)

plot a range of topo/bath using GMT
"""
function gmttoporange!(geo::VisClaw.AbstractTopo; kwargs...)
	# set square
	xp = [geo.x[1],  geo.x[1]  , geo.x[end], geo.x[end], geo.x[1]]
	yp = [geo.y[1],  geo.y[end], geo.y[end], geo.y[1]  , geo.y[1]]
	# plot
	GMT.plot!(xp, yp; marker=:none, kwargs...)
end
####################################################


####################################################
"""
    gmtcoastline!(topo::VisClaw.Topo; kwargs...)
	gmtcoastline!(G::GMT.GMTgrid; kwargs...)

plot coastlines from topography and bathymetry data using GMT
"""
gmtcoastline!(topo::VisClaw.Topo; kwargs...) =
GMT.grdcontour!(geogrd(topo); C="-1e10,0,1e10", kwargs...)
####################################################
"""
$(@doc gmtcoastline!)
"""
gmtcoastline!(G::GMT.GMTgrid; kwargs...) =
GMT.grdcontour!(G; C="-1e10,0,1e10", kwargs...)
####################################################
