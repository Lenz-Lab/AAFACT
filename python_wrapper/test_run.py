from aafact import run_aafact

input_dir = "L:/Project_Data/Coordinate_System/06_MIMICS_STL/Healthy/PC03_18M"
exe_path = "C:/Users/arcanine/Github/AAFACT_Compiled/for_redistribution_files_only/AAFACT.exe"

excel_path = run_aafact(input_dir,exe_path)

print(excel_path)
