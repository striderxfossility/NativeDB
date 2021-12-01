
public class RadioStationsDataView extends ScriptableDataView {

  public func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    return true;
  }

  public func FilterItem(data: ref<IScriptable>) -> Bool {
    return true;
  }
}

public class VehicleRadioPopupGameController extends BaseModalListPopupGameController {

  private edit let m_icon: inkImageRef;

  private edit let m_scrollArea: inkScrollAreaRef;

  private edit let m_scrollControllerWidget: inkWidgetRef;

  private let m_dataView: ref<RadioStationsDataView>;

  private let m_dataSource: ref<ScriptableDataSource>;

  private let m_quickSlotsManager: wref<QuickSlotsManager>;

  private let m_playerVehicle: wref<VehicleObject>;

  private let m_startupIndex: Uint32;

  private let m_selectedItem: wref<RadioStationListItemController>;

  private let m_scrollController: wref<inkScrollController>;

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let player: wref<PlayerPuppet> = playerPuppet as PlayerPuppet;
    VehicleComponent.GetVehicle(player.GetGame(), player, this.m_playerVehicle);
    super.OnPlayerAttach(playerPuppet);
    this.m_quickSlotsManager = player.GetQuickSlotsManager();
    this.m_scrollController = inkWidgetRef.GetControllerByType(this.m_scrollControllerWidget, n"inkScrollController") as inkScrollController;
    inkWidgetRef.RegisterToCallback(this.m_scrollArea, n"OnScrollChanged", this, n"OnScrollChanged");
    this.PlaySound(n"VehicleRadioPopup", n"OnOpen");
  }

  protected func VirtualListReady() -> Void {
    this.m_listController.SelectItem(0u);
    this.m_listController.SelectItem(this.m_startupIndex);
  }

  protected cb func OnScrollChanged(value: Vector2) -> Bool {
    this.m_scrollController.UpdateScrollPositionFromScrollArea();
  }

  protected func Select(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Void {
    this.m_selectedItem = next as RadioStationListItemController;
    let data: ref<RadioListItemData> = this.m_selectedItem.GetStationData();
    InkImageUtils.RequestSetImage(this, this.m_icon, data.m_record.Icon().GetID());
  }

  protected func SetupVirtualList() -> Void {
    this.m_dataView = new RadioStationsDataView();
    this.m_dataSource = new ScriptableDataSource();
    this.m_dataView.SetSource(this.m_dataSource);
    this.m_listController.SetSource(this.m_dataView);
  }

  protected func CleanVirtualList() -> Void {
    this.m_dataView.SetSource(null);
    this.m_listController.SetSource(null);
    this.m_dataView = null;
    this.m_dataSource = null;
  }

  protected func SetupData() -> Void {
    let i: Int32;
    let radioArraySize: Int32;
    let radioName: CName;
    let radioOn: Bool;
    let stationRecord: ref<RadioStation_Record>;
    this.m_dataSource.Reset(VehiclesManagerDataHelper.GetRadioStations(this.m_playerPuppet));
    this.m_startupIndex = 0u;
    if IsDefined(this.m_playerVehicle) {
      radioOn = this.m_playerVehicle.IsRadioReceiverActive();
      if radioOn {
        radioName = this.m_playerVehicle.GetRadioReceiverStationName();
        if IsNameValid(radioName) {
          radioArraySize = Cast(this.m_dataSource.GetArraySize());
          i = 0;
          while i < radioArraySize {
            stationRecord = this.m_dataSource.GetItem(Cast(i)) as RadioListItemData.m_record;
            if IsDefined(stationRecord) {
              if Equals(GetLocalizedText(stationRecord.DisplayName()), GetLocalizedTextByKey(radioName)) {
                this.m_startupIndex = Cast(i);
              } else {
                i += 1;
              };
            } else {
            };
            i += 1;
          };
        };
      };
    };
  }

  protected func Activate() -> Void {
    let data: ref<RadioListItemData>;
    if !IsDefined(this.m_selectedItem) {
      return;
    };
    data = this.m_selectedItem.GetStationData();
    if data.m_record.Index() == -1 {
      this.m_quickSlotsManager.SendRadioEvent(false, false, -1);
    } else {
      this.m_quickSlotsManager.SendRadioEvent(true, true, data.m_record.Index());
    };
  }

  protected func OnClose() -> Void {
    let controller: wref<VehicleRadioLogicController> = this.GetRootWidget().GetController() as VehicleRadioLogicController;
    if IsDefined(controller) {
      controller.StopSound();
    };
  }
}

public class RadioStationListItemController extends inkVirtualCompoundItemController {

  private edit let m_label: inkTextRef;

  private edit let m_typeIcon: inkImageRef;

  private let m_stationData: ref<RadioListItemData>;

  public final func GetStationData() -> ref<RadioListItemData> {
    return this.m_stationData;
  }

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
  }

  protected cb func OnDataChanged(value: Variant) -> Bool {
    this.m_stationData = FromVariant(value) as RadioListItemData;
    inkTextRef.SetText(this.m_label, this.m_stationData.m_record.DisplayName());
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    this.GetRootWidget().SetState(n"Active");
  }

  protected cb func OnDeselected(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    this.GetRootWidget().SetState(n"Default");
  }
}

public class VehicleRadioLogicController extends inkLogicController {

  @default(VehicleRadioLogicController, false)
  public let m_isSoundStopped: Bool;

  protected cb func OnUninitialize() -> Bool {
    this.StopSound();
  }

  public final func StopSound() -> Void {
    if !this.m_isSoundStopped {
      this.m_isSoundStopped = true;
      this.PlaySound(n"VehicleRadioPopup", n"OnClose");
    };
  }
}
