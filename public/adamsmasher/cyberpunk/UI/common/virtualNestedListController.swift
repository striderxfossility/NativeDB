
public class VirutalNestedListClassifier extends inkVirtualItemTemplateClassifier {

  public func ClassifyItem(data: Variant) -> Uint32 {
    let listData: ref<VirutalNestedListData> = FromVariant(data) as VirutalNestedListData;
    if !IsDefined(listData) {
      return 0u;
    };
    return listData.m_widgetType;
  }
}

public class VirtualNestedListDataView extends ScriptableDataView {

  public let m_compareBuilder: ref<CompareBuilder>;

  public let m_defaultCollapsed: Bool;

  public let m_toggledLevels: array<Int32>;

  public final func Setup() -> Void {
    this.m_compareBuilder = CompareBuilder.Make();
  }

  public final func SetToggledLevels(toggledLevels: array<Int32>, defaultCollapsed: Bool) -> Void {
    this.m_toggledLevels = toggledLevels;
    this.m_defaultCollapsed = defaultCollapsed;
    this.Filter();
    this.EnableSorting();
    this.Sort();
    this.DisableSorting();
  }

  private func FilterItem(data: ref<IScriptable>) -> Bool {
    let itemData: ref<VirutalNestedListData> = data as VirutalNestedListData;
    return (itemData.m_isHeader || NotEquals(ArrayContains(this.m_toggledLevels, itemData.m_level), this.m_defaultCollapsed)) && this.FilterItems(itemData);
  }

  protected func FilterItems(data: ref<VirutalNestedListData>) -> Bool {
    return true;
  }

  private func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    let leftData: ref<VirutalNestedListData> = left as VirutalNestedListData;
    let rightData: ref<VirutalNestedListData> = right as VirutalNestedListData;
    this.m_compareBuilder.Reset();
    this.PreSortItems(this.m_compareBuilder, leftData, rightData);
    this.m_compareBuilder.IntAsc(leftData.m_level, rightData.m_level);
    this.m_compareBuilder.BoolTrue(leftData.m_isHeader, rightData.m_isHeader);
    this.m_compareBuilder.BoolTrue(leftData.m_forceToTopWithinLevel, rightData.m_forceToTopWithinLevel);
    this.SortItems(this.m_compareBuilder, leftData, rightData);
    return this.m_compareBuilder.GetBool();
  }

  protected func PreSortItems(compareBuilder: ref<CompareBuilder>, left: ref<VirutalNestedListData>, right: ref<VirutalNestedListData>) -> Void;

  protected func SortItems(compareBuilder: ref<CompareBuilder>, left: ref<VirutalNestedListData>, right: ref<VirutalNestedListData>) -> Void;
}

public class VirtualNestedListController extends inkVirtualListController {

  protected let m_dataView: ref<VirtualNestedListDataView>;

  protected let m_dataSource: ref<ScriptableDataSource>;

  protected let m_classifier: ref<VirutalNestedListClassifier>;

  protected let m_defaultCollapsed: Bool;

  protected let m_toggledLevels: array<Int32>;

  protected cb func OnInitialize() -> Bool {
    this.m_dataView = this.GetDataView();
    this.m_dataSource = new ScriptableDataSource();
    this.m_classifier = new VirutalNestedListClassifier();
    this.m_dataView.Setup();
    this.m_dataView.EnableSorting();
    this.m_dataView.SetSource(this.m_dataSource);
    this.SetClassifier(this.m_classifier);
    this.SetSource(this.m_dataView);
    this.m_defaultCollapsed = true;
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_dataView.SetSource(null);
    this.SetSource(null);
    this.SetClassifier(null);
    this.m_classifier = null;
    this.m_dataSource = null;
  }

  protected func GetDataView() -> ref<VirtualNestedListDataView> {
    let result: ref<VirtualNestedListDataView> = new VirtualNestedListDataView();
    return result;
  }

  public func SetData(data: array<ref<VirutalNestedListData>>, opt keepToggledLevels: Bool, opt sortOnce: Bool) -> Void {
    let castedData: array<ref<IScriptable>>;
    let i: Int32 = 0;
    while i < ArraySize(data) {
      ArrayPush(castedData, data[i]);
      i += 1;
    };
    if !keepToggledLevels {
      ArrayClear(this.m_toggledLevels);
    };
    this.m_dataSource.Reset(castedData);
    this.m_dataView.SetToggledLevels(this.m_toggledLevels, this.m_defaultCollapsed);
    this.EnableSorting();
    if sortOnce {
      this.DisableSorting();
    };
  }

  public func ToggleLevel(targetLevel: Int32) -> Void {
    if ArrayContains(this.m_toggledLevels, targetLevel) {
      ArrayRemove(this.m_toggledLevels, targetLevel);
    } else {
      ArrayPush(this.m_toggledLevels, targetLevel);
    };
    this.m_dataView.SetToggledLevels(this.m_toggledLevels, this.m_defaultCollapsed);
  }

  public func IsLevelToggled(targetLevel: Int32) -> Bool {
    return ArrayContains(this.m_toggledLevels, targetLevel);
  }

  public func GetItem(index: Uint32) -> Variant {
    let item: ref<VirutalNestedListData> = this.m_dataView.GetItem(index) as VirutalNestedListData;
    return ToVariant(item.m_data);
  }

  public func GetDataSize() -> Int32 {
    return Cast(this.m_dataView.Size());
  }

  public func EnableSorting() -> Void {
    this.m_dataView.EnableSorting();
  }

  public func DisableSorting() -> Void {
    this.m_dataView.DisableSorting();
  }

  public func IsSortingEnabled() -> Bool {
    return this.m_dataView.IsSortingEnabled();
  }
}
