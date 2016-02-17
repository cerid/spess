#define DBG(X) world.log << "DBG: [X]"
#define OOC_CONTROL_ID "OOCout"
#define IC_CONTROL_ID "ICout"

#define FILE_CONFIG "cfg/config.json"
#define FILE_ASSET_TABLE "rsc/assetTable.json"
#define FILE_DEFAULT_HTML "rsc/default.html"
#define FILE_CONFIG_ERROR "cfg/config_error.txt"

#define ASSET_DEFAULT "default"

#define WATER_LAYER TURF_LAYER+1
#define WATER_MAX 255

#define SCHEDULED_PROCESS		1
#define SCHEDULED_APPEARANCE	2

#define STEP_SIZE_MOB	8
#define STEP_SIZE_OBJ	8

#define CPU_DEFAULT		80
#define FPS_DEFAULT		20
#define FPS_MIN			10
#define FPS_MAX			50
#define ANIMATE_LENGTH	10

/*
#define AIR_PRESSURE_CAP		100
#define AIR_PRESSURE_NOMINAL	0
#define AIR_GRANUALITY			1
#define AIR_SPREAD_RATE_DEFAULT	1

#define CLICKMODE_NORMAL 1
#define CLICKMODE_BUILD 2
#define CLICKMODE_MAX 2
*/

#define UI_INTERACTIVE 2	// Green/Interactive
#define UI_UPDATE 1			// Orange/Updates Only
#define UI_DISABLED 0		// Red/Disabled
#define UI_CLOSE -1			// Closed

