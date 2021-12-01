
public class netChargesWidgetGameController extends inkHUDGameController {

  private let m_bbPlayerStats: wref<IBlackboard>;

  private let m_bbPlayerEventId1: ref<CallbackHandle>;

  private let m_bbPlayerEventId2: ref<CallbackHandle>;

  private let m_bbPlayerEventId3: ref<CallbackHandle>;

  private let networkName: wref<inkText>;

  private let networkStatus: wref<inkText>;

  private let chargesList: array<wref<inkCompoundWidget>>;

  private let chargesCurrent: Int32;

  private let chargesMax: Int32;

  private let networkNameText: String;

  private let networkStatusText: String;

  private let rootWidget: wref<inkWidget>;

  private let chargeList: wref<inkHorizontalPanel>;

  protected cb func OnInitialize() -> Bool {
    this.rootWidget = this.GetRootWidget();
    this.rootWidget.SetVisible(false);
    this.chargeList = this.GetWidget(n"net/networkStatus/chargesList") as inkHorizontalPanel;
    this.networkName = this.GetWidget(n"net/networkStatus/networkName") as inkText;
    this.networkStatus = this.GetWidget(n"net/networkStatus/statusText") as inkText;
    this.networkNameText = "CYBERDECK ERROR: NO NETWORK CONNECTION";
    this.networkStatusText = "Malware hooks installed :";
    this.chargesMax = -1;
    this.chargesCurrent = 0;
    this.RefreshCharges();
    this.m_bbPlayerStats = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
    this.m_bbPlayerEventId1 = this.m_bbPlayerStats.RegisterListenerInt(GetAllBlackboardDefs().UI_PlayerBioMonitor.CurrentNetrunnerCharges, this, n"OnCurrentChargesChanged");
    this.m_bbPlayerEventId2 = this.m_bbPlayerStats.RegisterListenerInt(GetAllBlackboardDefs().UI_PlayerBioMonitor.NetworkChargesCapacity, this, n"OnMaxChargesChanged");
    this.m_bbPlayerEventId3 = this.m_bbPlayerStats.RegisterListenerName(GetAllBlackboardDefs().UI_PlayerBioMonitor.NetworkName, this, n"OnNameChanged");
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_bbPlayerStats) {
      this.m_bbPlayerStats.UnregisterListenerInt(GetAllBlackboardDefs().UI_PlayerBioMonitor.CurrentNetrunnerCharges, this.m_bbPlayerEventId1);
      this.m_bbPlayerStats.UnregisterListenerInt(GetAllBlackboardDefs().UI_PlayerBioMonitor.NetworkChargesCapacity, this.m_bbPlayerEventId2);
      this.m_bbPlayerStats.UnregisterListenerName(GetAllBlackboardDefs().UI_PlayerBioMonitor.NetworkName, this.m_bbPlayerEventId3);
    };
  }

  private final func RefreshCharges() -> Void {
    let i: Int32;
    this.networkStatusText = "Installed malware hooks status:";
    if this.chargesCurrent == 0 {
      this.networkStatusText = "No malware hooks installed!";
    };
    i = 0;
    while i < ArraySize(this.chargesList) {
      this.chargeList.RemoveChild(this.chargesList[i]);
      i += 1;
    };
    ArrayClear(this.chargesList);
    i = 0;
    while i < this.chargesMax {
      ArrayPush(this.chargesList, this.SpawnFromLocal(this.chargeList, n"charge") as inkCompoundWidget);
      this.SetChargeNumber(this.chargesList[i], -1);
      this.SetChargeState(this.chargesList[i], false);
      this.chargesList[i].SetVisible(true);
      i += 1;
    };
    i = 0;
    while i < this.chargesCurrent {
      this.SetChargeState(this.chargesList[i], true);
      this.SetChargeNumber(this.chargesList[i], i + 1);
      this.chargesList[i].SetVisible(true);
      i += 1;
    };
    this.networkName.SetText(this.networkNameText);
    this.networkStatus.SetText(this.networkStatusText);
    if this.chargesCurrent < 1 {
      this.rootWidget.SetVisible(false);
    } else {
      this.rootWidget.SetVisible(true);
    };
  }

  private final func SetChargeState(chargeWidget: wref<inkCompoundWidget>, state: Bool) -> Void {
    let tempRef: wref<inkRectangle> = chargeWidget.GetWidget(n"fill") as inkRectangle;
    tempRef.SetVisible(state);
  }

  private final func SetChargeNumber(chargeWidget: wref<inkCompoundWidget>, number: Int32) -> Void {
    let tempRef: wref<inkText> = chargeWidget.GetWidget(n"number") as inkText;
    if number != -1 {
      tempRef.SetText(IntToString(number));
    } else {
      tempRef.SetText("");
    };
  }

  protected cb func OnMaxChargesChanged(value: Int32) -> Bool {
    this.chargesMax = value;
    this.RefreshCharges();
  }

  protected cb func OnCurrentChargesChanged(value: Int32) -> Bool {
    this.chargesCurrent = value;
    this.RefreshCharges();
  }

  protected cb func OnNameChanged(value: CName) -> Bool {
    this.networkNameText = NameToString(value);
    this.RefreshCharges();
  }
}
