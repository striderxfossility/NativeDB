
public class VehiclesManagerDataView extends ScriptableDataView {

  public func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    let leftData: ref<VehicleListItemData> = left as VehicleListItemData;
    let rightData: ref<VehicleListItemData> = right as VehicleListItemData;
    let leftStr: String = GetLocalizedTextByKey(leftData.m_displayName);
    let rightStr: String = GetLocalizedTextByKey(rightData.m_displayName);
    return UnicodeStringLessThan(leftStr, rightStr);
  }

  public func FilterItem(data: ref<IScriptable>) -> Bool {
    return true;
  }
}

public class VehiclesManagerPopupGameController extends BaseModalListPopupGameController {

  private edit let m_icon: inkImageRef;

  private edit let m_scrollArea: inkScrollAreaRef;

  private edit let m_scrollControllerWidget: inkWidgetRef;

  private let m_dataView: ref<VehiclesManagerDataView>;

  private let m_dataSource: ref<ScriptableDataSource>;

  private let m_quickSlotsManager: wref<QuickSlotsManager>;

  private let m_scrollController: wref<inkScrollController>;

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let player: wref<PlayerPuppet>;
    super.OnPlayerAttach(playerPuppet);
    player = playerPuppet as PlayerPuppet;
    this.m_quickSlotsManager = player.GetQuickSlotsManager();
    this.m_scrollController = inkWidgetRef.GetControllerByType(this.m_scrollControllerWidget, n"inkScrollController") as inkScrollController;
    inkWidgetRef.RegisterToCallback(this.m_scrollArea, n"OnScrollChanged", this, n"OnScrollChanged");
  }

  protected cb func OnScrollChanged(value: Vector2) -> Bool {
    this.m_scrollController.UpdateScrollPositionFromScrollArea();
  }

  protected func Select(previous: ref<inkVirtualCompoundItemController>, next: ref<inkVirtualCompoundItemController>) -> Void {
    let selectedItem: wref<VehiclesManagerListItemController> = next as VehiclesManagerListItemController;
    let vehicleData: ref<VehicleListItemData> = selectedItem.GetVehicleData();
    InkImageUtils.RequestSetImage(this, this.m_icon, vehicleData.m_icon.GetID());
  }

  protected func SetupVirtualList() -> Void {
    this.m_dataView = new VehiclesManagerDataView();
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
    this.m_dataView.EnableSorting();
    this.m_dataSource.Reset(VehiclesManagerDataHelper.GetVehicles(this.m_playerPuppet));
  }

  protected func Activate() -> Void {
    let selectedItem: wref<VehiclesManagerListItemController> = this.m_listController.GetSelectedItem() as VehiclesManagerListItemController;
    let vehicleData: ref<VehicleListItemData> = selectedItem.GetVehicleData();
    this.m_quickSlotsManager.SetActiveVehicle(vehicleData.m_data);
    this.m_quickSlotsManager.SummonVehicle();
    this.Close();
  }
}

public class VehiclesManagerListItemController extends inkVirtualCompoundItemController {

  private edit let m_label: inkTextRef;

  private edit let m_typeIcon: inkImageRef;

  private let m_vehicleData: ref<VehicleListItemData>;

  public final func GetVehicleData() -> ref<VehicleListItemData> {
    return this.m_vehicleData;
  }

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
  }

  protected cb func OnDataChanged(value: Variant) -> Bool {
    this.m_vehicleData = FromVariant(value) as VehicleListItemData;
    inkTextRef.SetLocalizedTextScript(this.m_label, this.m_vehicleData.m_displayName);
    if Equals(this.m_vehicleData.m_data.vehicleType, gamedataVehicleType.Bike) {
      inkImageRef.SetTexturePart(this.m_typeIcon, n"motorcycle");
    } else {
      inkImageRef.SetTexturePart(this.m_typeIcon, n"car");
    };
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    this.GetRootWidget().SetState(n"Active");
  }

  protected cb func OnDeselected(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    this.GetRootWidget().SetState(n"Default");
  }
}
