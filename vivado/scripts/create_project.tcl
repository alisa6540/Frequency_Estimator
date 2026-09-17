# ============================================================
# Frequency Estimator - Vivado Project Creation Script
# ============================================================

# ============================================================
# Get paths
# ============================================================

set script_file [file normalize [info script]]
set script_dir  [file dirname $script_file]
set vivado_dir  [file normalize "$script_dir/.."]

set project_name Frequency_Estimator
set part_name xczu9eg-ffvb1156-2-i

set project_dir     [file normalize "$vivado_dir/project"]
set rtl_dir         [file normalize "$vivado_dir/rtl"]
set sim_dir         [file normalize "$vivado_dir/sim"]
set constraints_dir [file normalize "$vivado_dir/constraints"]
set ip_dir          [file normalize "$vivado_dir/ip"]


# ============================================================
# Print paths
# ============================================================

puts "============================================"
puts "SCRIPT FILE:"
puts "$script_file"
puts ""
puts "SCRIPT DIR:"
puts "$script_dir"
puts ""
puts "VIVADO DIR:"
puts "$vivado_dir"
puts ""
puts "PROJECT DIR:"
puts "$project_dir"
puts "============================================"


# ============================================================
# Create project
# ============================================================

if {[file exists "$project_dir/$project_name.xpr"]} {
    puts "Project already exists."
    open_project "$project_dir/$project_name.xpr"
} else {

    if {![file exists $project_dir]} {
        file mkdir $project_dir
    }

    create_project $project_name $project_dir -part $part_name
}


# ============================================================
# RTL Sources
# ============================================================

if {[file exists $rtl_dir]} {

    set rtl_files [glob -nocomplain "$rtl_dir/*.vhd"]

    foreach file $rtl_files {
        puts "Adding RTL: $file"
        add_files -norecurse $file
    }

} else {
    puts "WARNING: RTL directory not found: $rtl_dir"
}


# ============================================================
# Simulation Sources
# ============================================================

if {[file exists $sim_dir]} {

    set sim_files [glob -nocomplain "$sim_dir/*.vhd"]

    foreach file $sim_files {
        puts "Adding SIM: $file"
        add_files -fileset sim_1 -norecurse $file
    }

} else {
    puts "WARNING: SIM directory not found: $sim_dir"
}


# ============================================================
# Constraints
# ============================================================

if {[file exists $constraints_dir]} {

    set xdc_files [glob -nocomplain "$constraints_dir/*.xdc"]

    foreach file $xdc_files {
        puts "Adding XDC: $file"
        add_files -fileset constrs_1 -norecurse $file
    }

} else {
    puts "WARNING: Constraints directory not found: $constraints_dir"
}


# ============================================================
# IP
# ============================================================

puts "============================================"
puts "Adding IP files..."
puts "============================================"

# ✅ جستجوی بازگشتی در زیرپوشه‌ها
set ip_files [glob -nocomplain "$ip_dir/*/*.xci"]

if {[llength $ip_files] == 0} {
    puts "WARNING: No IP files found in $ip_dir (checked subdirectories)"
} else {
    foreach ip_file $ip_files {
        puts "Importing IP: $ip_file"
        import_ip $ip_file
    }
}

update_ip_catalog

puts "Generating IP output products..."

# ✅ تولید IPها به صورت جداگانه
if {[llength [get_ips]] > 0} {
    foreach ip [get_ips] {
        puts "Generating IP: $ip"
        generate_target all [get_ips $ip]
    }
} else {
    puts "WARNING: No IPs found to generate"
}

puts "IP generation completed."

# ============================================================
# Update Compile Order
# ============================================================

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1


# ============================================================
# Done
# ============================================================

puts "============================================"
puts "Vivado project created successfully!"
puts "Project: $project_name"
puts "Location: $project_dir"
puts "============================================"