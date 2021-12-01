
public class CyberwareMainGameController extends inkGameController {

  private edit let m_MainViewRoot: inkWidgetRef;

  private edit let m_CyberwareColumnLeft: inkCompoundRef;

  private edit let m_CyberwareColumnRight: inkCompoundRef;

  private edit let m_personalStatsList: inkCompoundRef;

  private edit let m_attributesList: inkCompoundRef;

  private edit let m_resistancesList: inkCompoundRef;

  private edit let m_TooltipsManagerRef: inkWidgetRef;

  private let m_TooltipsManager: wref<gameuiTooltipsManager>;

  private let m_InventoryManager: ref<InventoryDataManagerV2>;

  private let m_player: wref<PlayerPuppet>;

  private let m_resistanceView: CName;

  private let m_statView: CName;

  private let m_toolTipOffset: inkMargin;

  private let m_rawStatsData: array<StatViewData>;

  protected cb func OnInitialize() -> Bool {
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_player = this.GetPlayerControlledObject() as PlayerPuppet;
    this.m_InventoryManager = new InventoryDataManagerV2();
    this.m_InventoryManager.Initialize(this.m_player);
    this.m_InventoryManager.GetPlayerStats(this.m_rawStatsData);
    inkCompoundRef.RemoveAllChildren(this.m_CyberwareColumnLeft);
    inkCompoundRef.RemoveAllChildren(this.m_CyberwareColumnRight);
    this.m_toolTipOffset.left = 60.00;
    this.m_toolTipOffset.top = 5.00;
    inkCompoundRef.RemoveAllChildren(this.m_personalStatsList);
    inkCompoundRef.RemoveAllChildren(this.m_attributesList);
    inkCompoundRef.RemoveAllChildren(this.m_resistancesList);
    this.m_resistanceView = n"resistanceView";
    this.m_statView = n"statView";
    this.SetupBB();
    this.PrepareTooltips();
    this.PrepareCyberwareSlots();
    this.PopulateStats();
    this.OnIntro();
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_InventoryManager.UnInitialize();
    this.RemoveBB();
  }

  private final func SetupBB() -> Void;

  private final func RemoveBB() -> Void;

  private final func PrepareCyberwareSlots() -> Void {
    this.AddCyberwareSlot(gamedataEquipmentArea.SystemReplacementCW, this.m_CyberwareColumnRight);
    this.AddCyberwareSlot(gamedataEquipmentArea.EyesCW, this.m_CyberwareColumnRight);
    this.AddCyberwareSlot(gamedataEquipmentArea.HandsCW, this.m_CyberwareColumnRight);
    this.AddCyberwareSlot(gamedataEquipmentArea.ArmsCW, this.m_CyberwareColumnRight);
    this.AddCyberwareSlot(gamedataEquipmentArea.LegsCW, this.m_CyberwareColumnRight);
    this.AddCyberwareSlot(gamedataEquipmentArea.MusculoskeletalSystemCW, this.m_CyberwareColumnLeft);
    this.AddCyberwareSlot(gamedataEquipmentArea.NervousSystemCW, this.m_CyberwareColumnLeft);
    this.AddCyberwareSlot(gamedataEquipmentArea.CardiovascularSystemCW, this.m_CyberwareColumnLeft);
    this.AddCyberwareSlot(gamedataEquipmentArea.ImmuneSystemCW, this.m_CyberwareColumnLeft);
    this.AddCyberwareSlot(gamedataEquipmentArea.IntegumentarySystemCW, this.m_CyberwareColumnLeft);
  }

  public final func PopulateStats() -> Void {
    this.AddStat(gamedataStatType.Health, this.m_personalStatsList);
    this.AddStat(gamedataStatType.Evasion, this.m_personalStatsList);
    this.AddStat(gamedataStatType.Accuracy, this.m_personalStatsList);
    this.AddStat(gamedataStatType.CarryCapacity, this.m_personalStatsList);
    this.AddStat(gamedataStatType.Reflexes, this.m_attributesList);
    this.AddStat(gamedataStatType.Intelligence, this.m_attributesList);
    this.AddStat(gamedataStatType.TechnicalAbility, this.m_attributesList);
    this.AddStat(gamedataStatType.Strength, this.m_attributesList);
    this.AddStat(gamedataStatType.Cool, this.m_attributesList);
    this.AddStat(gamedataStatType.PhysicalResistance, this.m_resistancesList, this.m_resistanceView);
    this.AddStat(gamedataStatType.ThermalResistance, this.m_resistancesList, this.m_resistanceView);
    this.AddStat(gamedataStatType.ElectricResistance, this.m_resistancesList, this.m_resistanceView);
    this.AddStat(gamedataStatType.ChemicalResistance, this.m_resistancesList, this.m_resistanceView);
  }

  private final func AddStat(statType: gamedataStatType, list: inkCompoundRef, opt viewElement: CName) -> Void {
    let statData: StatViewData;
    let statView: wref<StatsViewController>;
    if Equals(viewElement, n"") {
      viewElement = this.m_statView;
    };
    statData = this.RequestStat(statType);
    statView = this.SpawnFromLocal(inkWidgetRef.Get(list), viewElement).GetControllerByType(n"StatsViewController") as StatsViewController;
    statView.Setup(statData);
  }

  private final func AddCyberwareSlot(equipArea: gamedataEquipmentArea, parentRef: inkCompoundRef) -> Void {
    let numSlots: Int32;
    let cybSlot: wref<CyberwareSlot> = this.SpawnFromLocal(inkWidgetRef.Get(parentRef), n"cyberware_slot").GetControllerByType(n"CyberwareSlot") as CyberwareSlot;
    if IsDefined(cybSlot) {
      numSlots = this.m_InventoryManager.GetNumberOfSlots(equipArea);
      cybSlot.Setup(equipArea, numSlots);
      cybSlot.RegisterToCallback(n"OnHoverOver", this, n"OnCyberwareSlotHoverOver");
      cybSlot.RegisterToCallback(n"OnHoverOut", this, n"OnCyberwareSlotHoverOut");
    };
  }

  protected cb func OnCyberwareSlotHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let cyberwareSlot: wref<CyberwareSlot> = this.GetCyberwareSlotControllerFromTarget(evt);
    this.OnCyberwareRequestTooltip(cyberwareSlot);
  }

  protected cb func OnCyberwareSlotHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.HideTooltips();
  }

  private final func PrepareTooltips() -> Void {
    this.m_TooltipsManager = inkWidgetRef.GetControllerByType(this.m_TooltipsManagerRef, n"gameuiTooltipsManager") as gameuiTooltipsManager;
    this.m_TooltipsManager.Setup(ETooltipsStyle.Menus);
  }

  private final func OnCyberwareRequestTooltip(slot: wref<CyberwareSlot>) -> Void {
    let i: Int32;
    let tooltipsData: ref<CyberwareTooltipData> = new CyberwareTooltipData();
    if IsDefined(slot) {
      tooltipsData.label = ToString(slot.GetEquipmentArea());
      i = 0;
      while i < slot.GetNumSlots() {
        tooltipsData.AddCyberwareSlotItemData(this.m_InventoryManager.GetItemDataEquippedInArea(slot.GetEquipmentArea(), i));
        i += 1;
      };
      this.m_TooltipsManager.ShowTooltip(0, tooltipsData, this.m_toolTipOffset);
    };
  }

  private final func HideTooltips() -> Void {
    this.m_TooltipsManager.HideTooltips();
  }

  private final func OnIntro() -> Void;

  private final func GetCyberwareSlotControllerFromTarget(evt: ref<inkPointerEvent>) -> ref<CyberwareSlot> {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let controller: wref<CyberwareSlot> = widget.GetController() as CyberwareSlot;
    return controller;
  }

  private final func RequestStat(stat: gamedataStatType) -> StatViewData {
    let data: StatViewData;
    let i: Int32 = 0;
    while i < ArraySize(this.m_rawStatsData) {
      if Equals(this.m_rawStatsData[i].type, stat) {
        return this.m_rawStatsData[i];
      };
      i += 1;
    };
    return data;
  }
}
