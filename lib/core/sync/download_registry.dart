import 'table_download_task.dart';
import '../api/bms_api.dart';
import '../api/bms_api.dart';
import '../api/bms_api_bridge_inventory.dart';
import '../api/bms_api_major_inspection.dart';
import '../api/bms_api_visual_inspection.dart';
import '../api/bms_api_culvert_inventory.dart';
import '../api/bms_api_culvert_inspection.dart';

final List<TableDownloadTask> downloadTasks = [
  // ===========================================================
  // CORE (BmsAPI)
  // ===========================================================

	TableDownloadTask(
    tableName: 'District',
    displayName: 'District',
    fetcher: () => BmsApi().getDistrictList(),
  ),

  TableDownloadTask(
    tableName: 'Section',
    displayName: 'Section',
    fetcher: () => BmsApi().getAllSections(),
  ),

  TableDownloadTask(
    tableName: 'Segment',
    displayName: 'Segment',
    fetcher: () => BmsApi().getAllSegments(),
  ),

  TableDownloadTask(
    tableName: 'MainRoute',
    displayName: 'Main Route',
    fetcher: () => BmsApi().getMainRouteList(),
  ),

  TableDownloadTask(
    tableName: 'SubRoute',
    displayName: 'Sub Route',
    fetcher: () => BmsApi().getAllSubRoutes(),
  ),

  TableDownloadTask(
    tableName: 'Bridge',
    displayName: 'Bridge',
    fetcher: () => BmsApi().getAllBridges(),
  ),

  TableDownloadTask(
    tableName: 'Culvert',
    displayName: 'Culvert',
    fetcher: () => BmsApi().getAllCulverts(),
  ),
	
	TableDownloadTask(
    tableName: 'DesignStandard',
    displayName: 'Design Standard',
    fetcher: () => BmsApi().getDesignStandardList(),
  ),

	TableDownloadTask(
    tableName: 'RegionalGovernment',
    displayName: 'Regional Government',
    fetcher: () => BmsApi().getRegionalGovernmentList(),
  ),
	
  TableDownloadTask(
    tableName: 'RoadSurfaceType',
    displayName: 'Road Surface Type',
    fetcher: () => BmsApi().getRoadSurfaceTypeList(),
  ),

  TableDownloadTask(
    tableName: 'RoadClass',
    displayName: 'Road Class',
    fetcher: () => BmsApi().getRoadClassList(),
  ),
	
  // ===========================================================
  // BRIDGE INVENTORY (BmsAPIBridgeInventory)
  // ===========================================================
	
  TableDownloadTask(
    tableName: 'BridgeGeneralInfo',
    displayName: 'Bridge General Info',
    fetcher: () => BmsApiBridgeInventory().getBridgeGeneralInfoList(),
  ),
	
  TableDownloadTask(
    tableName: 'SuperStructure',
    displayName: 'Super Structure',
    fetcher: () => BmsApiBridgeInventory().getSuperStructureList(),
  ),

  TableDownloadTask(
    tableName: 'Abutment',
    displayName: 'Abutment',
    fetcher: () => BmsApiBridgeInventory().getAbutmentList(),
  ),

  TableDownloadTask(
    tableName: 'Ancillary',
    displayName: 'Ancillaries',
    fetcher: () => BmsApiBridgeInventory().getAncillariesList(),
  ),

  TableDownloadTask(
    tableName: 'Pier',
    displayName: 'Pier',
    fetcher: () => BmsApiBridgeInventory().getPierList(),
  ),
	
	TableDownloadTask(
    tableName: 'DocType',
    displayName: 'Document Type',
    fetcher: () => BmsApiBridgeInventory().getDocTypeList(),
  ), 
	
  TableDownloadTask(
    tableName: 'BridgeDoc',
    displayName: 'Bridge Documents',
    fetcher: () => BmsApiBridgeInventory().getBridgeDocList(),
  ), 
	
  TableDownloadTask(
    tableName: 'RoadAlignmentType',
    displayName: 'Road Alignment Type',
    fetcher: () => BmsApiBridgeInventory().getRoadAlignmentTypeList(),
  ),

  TableDownloadTask(
    tableName: 'BridgeType',
    displayName: 'Bridge Type',
    fetcher: () => BmsApiBridgeInventory().getBridgeTypeList(),
  ),

  TableDownloadTask(
    tableName: 'SpanSupportType',
    displayName: 'Span Support Type',
    fetcher: () => BmsApiBridgeInventory().getSpanSupportTypeList(),
  ),

  TableDownloadTask(
    tableName: 'DeckSlabType',
    displayName: 'Deck Slab Type',
    fetcher: () => BmsApiBridgeInventory().getDeckSlabTypeList(),
  ),

  TableDownloadTask(
    tableName: 'GirderType',
    displayName: 'Girder Type',
    fetcher: () => BmsApiBridgeInventory().getGirderTypeList(),
  ),

  TableDownloadTask(
    tableName: 'AbutmentType',
    displayName: 'Abutment Type',
    fetcher: () => BmsApiBridgeInventory().getAbutmentTypeList(),
  ),

  TableDownloadTask(
    tableName: 'FoundationType',
    displayName: 'Foundation Type',
    fetcher: () => BmsApiBridgeInventory().getFoundationTypeList(),
  ),

  TableDownloadTask(
    tableName: 'SoilType',
    displayName: 'Soil Type',
    fetcher: () => BmsApiBridgeInventory().getSoilTypeList(),
  ),

  TableDownloadTask(
    tableName: 'ExpansionJointType',
    displayName: 'Expansion Joint Type',
    fetcher: () => BmsApiBridgeInventory().getExpansionJointTypeList(),
  ),

  TableDownloadTask(
    tableName: 'BearingType',
    displayName: 'Bearing Type',
    fetcher: () => BmsApiBridgeInventory().getBearingTypeList(),
  ),

  TableDownloadTask(
    tableName: 'GuardRailingType',
    displayName: 'Guard Railing Type',
    fetcher: () => BmsApiBridgeInventory().getGuardRailingTypeList(),
  ),

  TableDownloadTask(
    tableName: 'SurfaceType',
    displayName: 'Surface Type',
    fetcher: () => BmsApiBridgeInventory().getSurfaceTypeList(),
  ),

  TableDownloadTask(
    tableName: 'PierType',
    displayName: 'Pier Type',
    fetcher: () => BmsApiBridgeInventory().getPierTypeList(),
  ),

  TableDownloadTask(
    tableName: 'MediaType',
    displayName: 'Media Type',
    fetcher: () => BmsApiBridgeInventory().getMediaTypeList(),
  ),

  // ===========================================================
  // MAJOR INSPECTION (BmsAPIMajorInspection)
  // ===========================================================
	
  TableDownloadTask(
    tableName: 'DamageInspMajor',
    displayName: 'Bridge Major Inspection',
    fetcher: () => BmsApiMajorInspection().getDamageInspMajorList(),
  ),

  TableDownloadTask(
    tableName: 'ResultInspMajor',
    displayName: 'Bridge Major Inspection Result',
    fetcher: () => BmsApiMajorInspection().getResultInspMajorList(),
  ),

  TableDownloadTask(
    tableName: 'BridgeComment',
    displayName: 'Bridge Comment',
    fetcher: () => BmsApiMajorInspection().getBridgeCommentList(),
  ),

  TableDownloadTask(
    tableName: 'BridgeObservation',
    displayName: 'Bridge Observation',
    fetcher: () => BmsApiMajorInspection().getBridgeObservationList(),
  ),

  TableDownloadTask(
    tableName: 'StructureItem',
    displayName: 'Structure Item',
    fetcher: () => BmsApiMajorInspection().getStructureItemList(),
  ),

  TableDownloadTask(
    tableName: 'StructureItemDmgWt',
    displayName: 'Structure Item Damage Weight',
    fetcher: () => BmsApiMajorInspection().getStructureItemDmgWtList(),
  ),

  TableDownloadTask(
    tableName: 'MaintenanceUrgency',
    displayName: 'Maintenance Urgency',
    fetcher: () => BmsApiMajorInspection().getMaintenanceUrgencyList(),
  ),

  TableDownloadTask(
    tableName: 'DamageType',
    displayName: 'Damage Type',
    fetcher: () => BmsApiMajorInspection().getDamageTypeList(),
  ),

  TableDownloadTask(
    tableName: 'BridgePart',
    displayName: 'Bridge Part',
    fetcher: () => BmsApiMajorInspection().getBridgePartList(),
  ),

  TableDownloadTask(
    tableName: 'BridgePartDmgWt',
    displayName: 'Bridge Part Damage Weight',
    fetcher: () => BmsApiMajorInspection().getBridgePartDmgWtList(),
  ),

  TableDownloadTask(
    tableName: 'DamageConditionRange',
    displayName: 'Damage Condition Range',
    fetcher: () => BmsApiMajorInspection().getDamageConditionRangeList(),
  ),

  TableDownloadTask(
    tableName: 'DamageRank',
    displayName: 'Damage Rank',
    fetcher: () => BmsApiMajorInspection().getDamageRankList(),
  ),

  TableDownloadTask(
    tableName: 'DamageRateAndCost',
    displayName: 'Damage Rate & Cost',
    fetcher: () => BmsApiMajorInspection().getDamageRateAndCostList(),
  ),

  TableDownloadTask(
    tableName: 'BridgeImprovement',
    displayName: 'Bridge Improvement',
    fetcher: () => BmsApiMajorInspection().getBridgeImprovementList(),
  ),

  TableDownloadTask(
    tableName: 'ImprovementType',
    displayName: 'Improvement Type',
    fetcher: () => BmsApiMajorInspection().getImprovementTypeList(),
  ),

  TableDownloadTask(
    tableName: 'DamagePrioritizationCriteria',
    displayName: 'Damage Prioritization Criteria',
    fetcher: () => BmsApiMajorInspection().getDamagePrioritizationCriteriaList(),
  ),

  TableDownloadTask(
    tableName: 'DamagePriority',
    displayName: 'Damage Priority',
    fetcher: () => BmsApiMajorInspection().getDamagePriorityList(),
  ),

  TableDownloadTask(
    tableName: 'RequiredAction',
    displayName: 'Required Action',
    fetcher: () => BmsApiMajorInspection().getRequiredActionList(),
  ),

  // ===========================================================
  // VISUAL INSPECTION (BmsAPIVisualInspection)
  // ===========================================================
	
  TableDownloadTask(
    tableName: 'DamageInspVisual',
    displayName: 'Bridge Visual Inspection',
    fetcher: () => BmsApiVisualInspection().getDamageInspVisualList(),
  ),

  TableDownloadTask(
    tableName: 'DamageSeverity',
    displayName: 'Damage Severity',
    fetcher: () => BmsApiVisualInspection().getDamageSeverityList(),
  ),

  // ===========================================================
  // CULVERT INVENTORY (BmsAPICulvertInventory)
  // ===========================================================
	
  TableDownloadTask(
    tableName: 'CulvertGeneralInfo',
    displayName: 'Culvert General Info',
    fetcher: () => BmsApiCulvertInventory().getCulvertGeneralInfoList(),
  ),

  TableDownloadTask(
    tableName: 'CulvertStructure',
    displayName: 'Culvert Structure',
    fetcher: () => BmsApiCulvertInventory().getCulvertStructureList(),
  ), 
	
  TableDownloadTask(
    tableName: 'ParapetMaterialType',
    displayName: 'Parapet Material Type',
    fetcher: () => BmsApiCulvertInventory().getParapetMaterialTypeList(),
  ),

  TableDownloadTask(
    tableName: 'CulvertType',
    displayName: 'Culvert Type',
    fetcher: () => BmsApiCulvertInventory().getCulvertTypeList(),
  ),

  TableDownloadTask(
    tableName: 'culEndWallType',
    displayName: 'Culvert End Wall Type',
    fetcher: () => BmsApiCulvertInventory().getEndWallTypeList(),
  ),

  // ===========================================================
  // CULVERT INSPECTION (BmsAPICulvertInspection)
  // ===========================================================

  TableDownloadTask(
    tableName: 'culDamageInspStructure',
    displayName: 'Culvert Structural Damage',
    fetcher: () => BmsApiCulvertInspection().getculDamageInspStructureList(),
  ),

  TableDownloadTask(
    tableName: 'culDamageInspHydraulic',
    displayName: 'Culvert Hydraulic Damage',
    fetcher: () => BmsApiCulvertInspection().getculDamageInspHydraulicList(),
  ),

  TableDownloadTask(
    tableName: 'ObservationAndRecommendation',
    displayName: 'Observation & Recommendation',
    fetcher: () => BmsApiCulvertInspection().getObservationAndRecommendationList(),
  ),

  TableDownloadTask(
    tableName: 'ResultInspCulvert',
    displayName: 'Culvert Inspection Result',
    fetcher: () => BmsApiCulvertInspection().getResultInspCulvertList(),
  ),

  TableDownloadTask(
    tableName: 'culHydrDamageType',
    displayName: 'Culvert Hydraulic Damage Type',
    fetcher: () => BmsApiCulvertInspection().getculHydrDamageTypeList(),
  ),

  TableDownloadTask(
    tableName: 'culDamageRateAndCost',
    displayName: 'Culvert Damage Rate & Cost',
    fetcher: () => BmsApiCulvertInspection().getculDamageRateAndCostList(),
  ),

  TableDownloadTask(
    tableName: 'culStructureItem',
    displayName: 'Culvert Structure Item',
    fetcher: () => BmsApiCulvertInspection().getculStructureItemList(),
  ),

  TableDownloadTask(
    tableName: 'CulvertImprovement',
    displayName: 'Culvert Improvement',
    fetcher: () => BmsApiCulvertInspection().getCulvertImprovementList(),
  ),
];