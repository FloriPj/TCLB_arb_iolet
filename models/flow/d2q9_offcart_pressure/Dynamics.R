# Density - table of variables of LB Node to stream
#  name - variable name to stream
#  dx,dy,dz - direction of streaming
#  comment - additional comment
SetOptions(permissive.access=TRUE)

AddDensity( name="f[0]", dx= 0, dy= 0, group="f",shift=4/9)
AddDensity( name="f[1]", dx= 1, dy= 0, group="f",shift=2/18)
AddDensity( name="f[2]", dx= 0, dy= 1, group="f",shift=2/18)
AddDensity( name="f[3]", dx=-1, dy= 0, group="f",shift=2/18)
AddDensity( name="f[4]", dx= 0, dy=-1, group="f",shift=2/18)
AddDensity( name="f[5]", dx= 1, dy= 1, group="f",shift=1/36)
AddDensity( name="f[6]", dx=-1, dy= 1, group="f",shift=1/36)
AddDensity( name="f[7]", dx=-1, dy=-1, group="f",shift=1/36)
AddDensity( name="f[8]", dx= 1, dy=-1, group="f",shift=1/36)


#AddField(name="f[1]", dx=1);

# THIS QUANTITIES ARE NEEDED FOR PYTHON INTEGRATION EXAMPLE
# COMMENT OUT FOR PERFORMANCE
# If present thei are used:
# As VelocityX/Y for Boundary conditions
# As mass force (+ GravitationX/Y) in fluid
if (Options$bc) {
	AddDensity( name="BC[0]", group="BC", parameter=TRUE)
	AddDensity( name="BC[1]", group="BC", parameter=TRUE)
}

# Image-Ghost metadata for slanted/off-cart inlet boundaries.
# Single image point per ghost node, shared by all 8 incoming directions.
AddField(name="IG_inlet_mask", group="IG", parameter=TRUE)
AddField(name="IG_ghost_mask", group="IG", stencil2d=1, parameter=TRUE)
AddField(name="IG_inside_mask", group="IG", stencil2d=2, parameter=TRUE)
for (i in 1:8) {
    AddField(name=paste0("IG_f_", i), group="IG", stencil2d=2, parameter=TRUE)
}
AddField(name="IG_rho_cache", group="IG", stencil2d=2, parameter=TRUE)
AddField(name="IG_ux_cache", group="IG", stencil2d=2, parameter=TRUE)
AddField(name="IG_uy_cache", group="IG", stencil2d=2, parameter=TRUE)
AddField(name="IG_has", group="IG", parameter=TRUE)
AddField(name="IG_xi_x", group="IG", parameter=TRUE)
AddField(name="IG_xi_y", group="IG", parameter=TRUE)


# Quantities - table of fields that can be exported from the LB lattice (like density, velocity etc)
#  name - name of the field
#  type - C type of the field, "real_t" - for single/double float, and "vector_t" for 3D vector single/double float
# Every field must correspond to a function in "Dynamics.c".
# If one have filed [something] with type [type], one have to define a function: 
# [type] get[something]() { return ...; }

AddQuantity(name="Rho",unit="kg/m3")
AddQuantity(name="U",unit="m/s",vector=T)

AddStage("BaseInit" , "Init" , save=Fields$group %in% c("f"), 
						 load=DensityAll$group %in% c("f","IG")) 

AddStage("BaseIter" , "Run" , save=Fields$group %in% c("f"), 
						 load=DensityAll$group %in% c("f","IG")) 

AddStage("MacroUpdate" , "IGUpdateMacroCache"    , save=Fields$group %in% c("IG"), 
						 load=DensityAll$group %in% c("f")) 

AddAction("Init", c("BaseInit"))
AddAction("Iteration", c("BaseIter","MacroUpdate"))
#AddAction("Macro"     , c("MacroUpdate"))

# Settings - table of settings (constants) that are taken from a .xml file
#  name - name of the constant variable
#  comment - additional comment
# You can state that another setting is 'derived' from this one stating for example: RelaxationRate='1.0/(3*Viscosity + 0.5)'

AddSetting(
           name="RelaxationRate", 
           S2='1-RelaxationRate',       
           comment='one over relaxation time'
            )
AddSetting(name="Viscosity", RelaxationRate='1.0/(3*Viscosity + 0.5)', default=0.16666666, comment='viscosity')
AddSetting(name="VelocityX", default=0, comment='inlet/outlet/init velocity', zonal=T)
AddSetting(name="VelocityY", default=0, comment='inlet/outlet/init velocity', zonal=T)
AddSetting(name="Pressure", default=0, comment='inlet/outlet/init density', zonal=T)

AddSetting(name="GravitationX")
AddSetting(name="GravitationY")

#Inlet Normal vector for boundary conditions - may need to extend to outlet #MODIFIED
AddSetting(name="INormalX",comment='normal vector for boundary conditions')
AddSetting(name="INormalY",comment='normal vector for boundary conditions')
AddSetting(name="IOriginX", comment="x-coordinate of point on inlet boundary")
AddSetting(name="IOriginY", comment="y-coordinate of point on inlet boundary")
AddSetting(name="ONormalX",comment='normal vector for outlet boundary')
AddSetting(name="ONormalY",comment='normal vector for outlet boundary')
AddSetting(name="OOriginX", comment="x-coordinate of point on outlet boundary")
AddSetting(name="OOriginY", comment="y-coordinate of point on outlet boundary")

# Globals - table of global integrals that can be monitored and optimized
AddGlobal(name="PressureLoss", comment='pressure loss', unit="1mPa")
AddGlobal(name="OutletFlux", comment='pressure loss', unit="1m2/s")
AddGlobal(name="InletFlux", comment='pressure loss', unit="1m2/s")

AddSetting(name="S2", default="0", comment='MRT Sx')
AddSetting(name="S3", default="0", comment='MRT Sx')
AddSetting(name="S4", default="0", comment='MRT Sx')


#Node types for boundaries
AddNodeType(name="EPressure", group="BOUNDARY")
AddNodeType(name="WPressure", group="BOUNDARY")

AddNodeType(name="NVelocity", group="BOUNDARY")
AddNodeType(name="SVelocity", group="BOUNDARY")
AddNodeType(name="WVelocity", group="BOUNDARY")
AddNodeType(name="AVelocity", group="BOUNDARY")
AddNodeType(name="APressure", group="BOUNDARY")
AddNodeType(name="EVelocity", group="BOUNDARY")

AddNodeType(name="NSymmetry", group="BOUNDARY")
AddNodeType(name="SSymmetry", group="BOUNDARY")

AddNodeType(name="Inlet", group="OBJECTIVE")
AddNodeType(name="Outlet", group="OBJECTIVE")
AddNodeType(name="Solid", group="BOUNDARY")
AddNodeType(name="Wall", group="BOUNDARY")
AddNodeType(name="MRT", group="COLLISION")
