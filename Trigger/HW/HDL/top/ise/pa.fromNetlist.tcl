
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name top_cru -dir "M:/MASTER/COMPET/Trigger/HW/HDL/top/ise/planAhead_run_1" -part xc5vfx30tff665-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "M:/MASTER/COMPET/Trigger/HW/HDL/top/ise/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {M:/MASTER/COMPET/Trigger/HW/HDL/top/ise} }
set_param project.paUcfFile  "M:/MASTER/COMPET/Trigger/HW/HDL/top/top.ucf"
add_files "M:/MASTER/COMPET/Trigger/HW/HDL/top/top.ucf" -fileset [get_property constrset [current_run]]
open_netlist_design
