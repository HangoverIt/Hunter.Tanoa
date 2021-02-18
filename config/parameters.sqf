HUNTER_SPECIAL_MARKER_PREFIX = "hunter_location_" ;
HUNTER_PREDEFINED_DIR = "predefined" ;
HUNTER_CAMP_BAG = "Bag_Base";
HUNTER_BASE_CRATE = "B_supplyCrate_F" ;
HUNTER_CAMP = [] ;
HUNTER_CUSTOM_LOCATION_FILE = "config\custom_locations.sqf" ;
HUNTER_BASE_NAMES = ["alpha", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel", "india", "juliet", "kilo", "lima", "mike", "november", "oscer", "papa", "quebeq", "romeo", "september", "tango"] ;
HUNTER_SAVE_PERIOD = 30;
HUNTER_LOCATION_CAPTURE_PERIOD = 10; // seconds between saving location of vehicles in area
HUNTER_CHECK_REINFORCEMENT = 30 ; // seconds between location resupply checks
HUNTER_CAMP_RADIUS = 100 ;
HUNTER_BASE_RADIUS = 100 ;
HUNTER_SAVE_CLASSES = ["Car", "Tank", "Helicopter", "Ship", "StaticWeapon", "Plane", "ReammoBox_F"] ;
HUNTER_SAVE_VAR = "Tanoa_Hunter_Game" ;
HUNTER_AMBIENT_FREQ = 30 ;
HUNTER_AMBIENT_ENEMY_FREQ = 10 ;
HUNTER_AMBIENT_SPREAD = 0.33 ; // one third above and below frequency
HUNTER_MAX_VEHICLE_AMBIENT = 4 ;
HUNTER_MAX_PEOPLE_AMBIENT = 20 ;
HUNTER_LOCATION_RADIUS_SPAWN = 1000 ;
HUNTER_LOCATION_RADIUS_DESPAWN = 1200 ;
HUNTER_SPAWN_DISTANCE = 1600 ; // This impacts resupply, SAD and ambient spawn distances (different to location)
HUNTER_CUSTOM_RADIUS_SPAWN = 500 ; // Custom location spawn
HUNTER_CUSTOM_RADIUS_DESPAWN = 600 ; // Custom location despawn
HUNTER_CUSTOM_LOCATION_SPACING_FACTOR = 5 ; // This impacts the creation of custom locations in one off code 
HUNTER_CUSTOM_LOCATION = "custom" ;
HUNTER_LOCATION_MAX_THREAT_COOLDOWN = 180 ; // in minutes - cooldown time if max threat reached
HUNTER_LOCATION_STD_THREAT_COOLDOWN = 1 ; // in minutes - time to resupply
HUNTER_REINFORCE_BELOW_PERCENT = 60 ;
HUNTER_THREAT_DECREASE_TIME = 60 ;
HUNTER_SHOW_LOCATION_AREA = true ;
HUNTER_SAD_TIMEOUT = 15 ; // minutes
HUNTER_CAS_TIMEOUT = 10 ; // minutes
HUNTER_HEATMAP_AGE = 30 ; // minutes
HUNTER_HEAT_THRESHOLD = 5; // number of kills to trigger CAS response
HUNTER_CASH_REWARDS = [["Man", 10], ["Car", 1000],["Air", 10000]];
HUNTER_ARMED_BONUS = 200;
HUNTER_PURCHASE_SOLDIERS = [["B_Soldier_F", 100],["B_Soldier_GL_F", 250], ["B_soldier_AR_F",200]] ;
HUNTER_SPAWN_LOCATIONS = [
                         ["NameCity",20], 
                         ["NameCityCapital", 30], 
                         ["NameVillage", 10], 
                         ["Airport", 30], 
                         [HUNTER_CUSTOM_LOCATION, 5]
                         ] ;
HUNTER_THREAT_MAPPING_SOLDIER = [
                                [0,["C_man_polo_3_F_afro", "C_man_polo_1_F_afro", "C_man_polo_2_F_afro", "C_man_polo_4_F_afro", "C_man_polo_5_F_afro", "C_man_polo_6_F_afro", "C_man_hunter_1_F"]],
                                [5,["O_G_Soldier_F", "O_G_Soldier_lite_F", "O_G_Soldier_SL_F", "O_G_Soldier_AR_F", "O_G_medic_F", "O_G_engineer_F", "O_G_Soldier_GL_F", "O_G_Soldier_M_F", "O_G_Soldier_LAT_F"]],
                                [50,["O_Soldier_F", "O_officer_F", "O_Soldier_lite_F", "O_Soldier_GL_F", "O_Soldier_AR_F", "O_Soldier_SL_F", "O_soldier_M_F", "O_medic_F", "O_Soldier_AT_F", "O_Soldier_AA_F"]],
                                [80,["O_recon_medic_F", "O_sniper_F", "O_recon_F", "O_recon_M_F", "O_recon_LAT_F", "O_recon_TL_F", "O_support_MG_F", "O_officer_F"]],
                                [120,["O_V_Soldier_hex_F", "O_V_Soldier_TL_hex_F", "O_V_Soldier_Medic_hex_F", "O_V_Soldier_M_hex_F", "O_V_Soldier_LAT_hex_F", "O_recon_TL_F", "O_support_MG_F", "O_officer_F"]]
                                ];
HUNTER_THREAT_MAPPING_VEHICLE = [
                                [0, ["C_Offroad_01_F", "C_Offroad_01_repair_F", "C_Quadbike_01_F", "C_Truck_02_covered_F", "C_Truck_02_transport_F", "C_Hatchback_01_F", "C_SUV_01_F", "C_Van_01_transport_F", "C_Offroad_02_unarmed_F"]],
                                [10, ["O_G_Offroad_01_armed_F", "O_G_Offroad_01_AT_F"]],
                                [20, ["O_T_LSV_02_armed_F", "O_T_LSV_02_AT_F"]],
                                [30, ["O_T_MRAP_02_hmg_ghex_F", "O_T_LSV_02_AT_F"]],
                                [50, ["O_T_MRAP_02_gmg_ghex_F", "O_T_MRAP_02_hmg_ghex_F"]],
                                [70, ["O_T_MRAP_02_gmg_ghex_F", "O_T_MRAP_02_hmg_ghex_F", "O_T_APC_Tracked_02_cannon_ghex_F", "O_T_APC_Tracked_02_AA_ghex_F", "O_T_APC_Wheeled_02_rcws_v2_ghex_F"]],
                                [90, ["O_T_APC_Tracked_02_cannon_ghex_F", "O_T_APC_Tracked_02_AA_ghex_F", "O_T_APC_Wheeled_02_rcws_v2_ghex_F", "O_T_APC_Wheeled_02_rcws_v2_ghex_F", "O_T_MBT_02_cannon_ghex_F"]],
                                [110, ["O_T_MBT_02_cannon_ghex_F", "O_T_APC_Tracked_02_AA_ghex_F"]],
                                [130, ["O_T_MBT_04_cannon_F", "O_T_APC_Tracked_02_AA_ghex_F", "O_T_MBT_02_cannon_ghex_F"]]
                                ]; 
HUNTER_THREAT_RESUPPLY_VEHICLE = [
                                 [0, ["O_G_Offroad_01_F", "O_T_LSV_02_unarmed_F"]],
                                 [10, ["O_G_Offroad_01_armed_F"]],
                                 [20, ["O_T_Truck_02_transport_F", "O_T_Truck_02_F", "O_T_MRAP_02_ghex_F"]],
                                 [30, ["O_T_MRAP_02_hmg_ghex_F"]],
                                 [50, ["O_T_MRAP_02_gmg_ghex_F", "O_T_MRAP_02_hmg_ghex_F"]],
                                 [80, ["O_T_APC_Tracked_02_cannon_ghex_F", "O_T_APC_Wheeled_02_rcws_ghex_F"]]
                                 ];
HUNTER_THREAT_SPOTTER_AIR      = [
                                 [0, ["C_Plane_Civil_01_F"]],
                                 [40, ["O_Heli_Light_02_unarmed_F"]],
                                 [50, ["O_Heli_Light_02_dynamicLoadout_F"]],
                                 [90, ["O_Heli_Attack_02_dynamicLoadout_F"]]
                                 ];
HUNTER_THREAT_SAD_VEHICLE = [
                                 [0, ["O_G_Offroad_01_F","O_G_Offroad_01_armed_F"]],
                                 [20, ["O_T_Truck_02_transport_F", "O_T_Truck_02_F", "O_T_MRAP_02_ghex_F"]],
                                 [30, ["O_T_MRAP_02_hmg_ghex_F"]],
                                 [50, ["O_T_MRAP_02_gmg_ghex_F", "O_T_MRAP_02_hmg_ghex_F"]],
                                 [80, ["O_T_MRAP_02_gmg_ghex_F", "O_T_APC_Tracked_02_cannon_ghex_F", "O_T_APC_Wheeled_02_rcws_ghex_F"]]
                                 ];
HUNTER_THREAT_RESUPPLY_AIR =     [
                                 [0, ["O_Heli_Light_02_F"]]
                                 ];
HUNTER_THREAT_RESUPPLY_SEA =     [
                                 [0, ["O_Boat_Transport_01_F"]]
                                 ];