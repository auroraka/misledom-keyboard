
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name keyboard -dir "C:/Users/ytl/Desktop/Misledom/keyboard/planAhead_run_2" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/ytl/Desktop/Misledom/keyboard/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/ytl/Desktop/Misledom/keyboard} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "keyboard.ucf" [current_fileset -constrset]
add_files [list {keyboard.ucf}] -fileset [get_property constrset [current_run]]
link_design
