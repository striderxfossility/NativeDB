
public class DebugNpcNameplateGameController extends inkProjectedHUDGameController {

  private let m_isToggledOn: Bool;

  private let m_uiBlackboard: wref<IBlackboard>;

  private let m_bbNPCStatsInfo: ref<CallbackHandle>;

  private let m_nameplateProjection: ref<inkScreenProjection>;

  private let bufferedNPC: wref<GameObject>;

  private let m_rootWidget: wref<inkWidget>;

  private let m_debugText1: wref<inkText>;

  private let m_debugText2: wref<inkText>;

  protected cb func OnInitialize() -> Bool {
    this.m_isToggledOn = false;
    this.m_rootWidget = this.GetRootWidget();
    this.m_rootWidget.SetVisible(false);
    this.m_debugText1 = this.GetWidget(n"flex/vert/debugtext_1") as inkText;
    this.m_debugText2 = this.GetWidget(n"flex/vert/debugtext_2") as inkText;
    this.RegisterDebugCommand(n"OnDebugNpcStats");
    this.m_uiBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair);
    if IsDefined(this.m_uiBlackboard) {
      this.m_bbNPCStatsInfo = this.m_uiBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair.NameplateData, this, n"OnNameplateDataChanged");
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_uiBlackboard) {
      this.m_uiBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_NPCNextToTheCrosshair.NameplateData, this.m_bbNPCStatsInfo);
    };
  }

  protected cb func OnDebugNpcStats() -> Bool {
    let nameplateProjectionData: inkScreenProjectionData;
    this.m_isToggledOn = !this.m_isToggledOn;
    this.m_rootWidget.SetVisible(this.m_isToggledOn);
    if this.m_isToggledOn {
      nameplateProjectionData.fixedWorldOffset = new Vector4(0.00, 0.00, 0.00, 0.00);
      nameplateProjectionData.slotComponentName = n"UI_Slots";
      nameplateProjectionData.slotName = n"Nameplate";
      this.m_nameplateProjection = this.RegisterScreenProjection(nameplateProjectionData);
    } else {
      this.UnregisterScreenProjection(this.m_nameplateProjection);
    };
  }

  protected cb func OnNameplateDataChanged(value: Variant) -> Bool {
    let helperString_1: String;
    let helperString_2: String;
    let incomingData: NPCNextToTheCrosshair;
    if !this.m_isToggledOn {
      return false;
    };
    incomingData = FromVariant(value);
    if this.bufferedNPC != incomingData.npc {
      this.bufferedNPC = incomingData.npc;
      this.m_nameplateProjection.SetEntity(this.bufferedNPC);
    };
    if incomingData.npc != null {
      this.m_rootWidget.SetVisible(true);
      this.GetNPCDebugNameplateStats(incomingData.npc, helperString_1, helperString_2);
      this.HelperUpdateText(helperString_1, helperString_2);
    } else {
      this.m_rootWidget.SetVisible(false);
      this.m_nameplateProjection.SetEntity(null);
    };
  }

  protected cb func OnScreenProjectionUpdate(projections: ref<gameuiScreenProjectionsData>) -> Bool {
    this.m_rootWidget.SetMargin(new inkMargin(projections.data[0].currentPosition.X, projections.data[0].currentPosition.Y, 0.00, 0.00));
  }

  private final func HelperUpdateText(argString1: String, argString2: String) -> Void {
    this.m_debugText1.SetText(argString1);
    this.m_debugText2.SetText(argString2);
  }

  private final func GetNPCDebugNameplateStats(obj: ref<GameObject>, out str_1: String, out str_2: String) -> Void {
    let temp_str: String;
    let system: ref<StatsSystem> = GameInstance.GetStatsSystem(obj.GetGame());
    let temp_float: Float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.Level);
    temp_str += "Level: " + IntToString(RoundF(temp_float));
    temp_float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.PowerLevel);
    temp_str += "\\nPowerLevel: " + IntToString(RoundF(temp_float));
    temp_float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.Health);
    temp_str += "\\nMax Health: " + IntToString(RoundF(temp_float));
    temp_float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.Evasion);
    temp_str += "\\nEvasion: " + IntToString(RoundF(temp_float));
    temp_float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.PhysicalResistance);
    temp_str += "\\nPhysical Res: " + IntToString(RoundF(temp_float));
    temp_float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.ThermalResistance);
    temp_str += "\\nThermal Res: " + IntToString(RoundF(temp_float));
    temp_float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.ChemicalResistance);
    temp_str += "\\nChemical Res: " + IntToString(RoundF(temp_float));
    temp_float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.ElectricResistance);
    temp_str += "\\nEMP Res: " + IntToString(RoundF(temp_float));
    str_1 = temp_str;
    temp_str = "";
    temp_float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.DPS);
    temp_str = "\\nDPS: " + IntToString(RoundF(temp_float));
    temp_float = system.GetStatValue(Cast(obj.GetEntityID()), gamedataStatType.Accuracy);
    temp_str += "\\nAccuracy: " + IntToString(RoundF(temp_float));
    str_2 = temp_str;
  }
}
