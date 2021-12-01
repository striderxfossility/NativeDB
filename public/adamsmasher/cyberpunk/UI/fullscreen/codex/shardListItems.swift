
public class ShardItemVirtualController extends inkVirtualCompoundItemController {

  private edit let m_label: inkTextRef;

  private edit let m_counter: inkTextRef;

  private edit let m_collapseIcon: inkWidgetRef;

  private edit let m_isNewFlag: inkWidgetRef;

  private let m_entryData: ref<ShardEntryData>;

  private let m_nestedListData: ref<VirutalNestedListData>;

  private let m_activeItemSync: wref<CodexListSyncData>;

  private let m_isActive: Bool;

  private let m_isItemHovered: Bool;

  private let m_isItemToggled: Bool;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnToggledOn", this, n"OnToggledOn");
    this.RegisterToCallback(n"OnToggledOff", this, n"OnToggledOff");
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
  }

  public final func OnDataChanged(value: Variant) -> Void {
    this.m_nestedListData = FromVariant(value) as VirutalNestedListData;
    this.m_entryData = this.m_nestedListData.m_data as ShardEntryData;
    this.m_activeItemSync = this.m_entryData.m_activeDataSync;
    inkTextRef.SetText(this.m_counter, "(" + ToString(this.m_entryData.m_counter) + ")");
    inkWidgetRef.SetVisible(this.m_isNewFlag, ArraySize(this.m_entryData.m_newEntries) > 0);
    inkTextRef.SetText(this.m_label, this.m_entryData.m_title);
    if inkWidgetRef.IsValid(this.m_collapseIcon) {
      inkWidgetRef.SetVisible(this.m_collapseIcon, this.m_nestedListData.m_collapsable);
    };
    this.UpdateState();
  }

  protected cb func OnContactSyncData(evt: ref<ShardSyncBackEvent>) -> Bool {
    this.UpdateState();
  }

  protected cb func OnEntrySelected(evt: ref<ShardEntrySelectedEvent>) -> Bool {
    if ArrayContains(this.m_entryData.m_newEntries, Cast(evt.m_hash)) {
      ArrayRemove(this.m_entryData.m_newEntries, Cast(evt.m_hash));
    };
    inkWidgetRef.SetVisible(this.m_isNewFlag, ArraySize(this.m_entryData.m_newEntries) > 0);
  }

  protected cb func OnToggledOn(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    let evt: ref<ShardSelectedEvent> = new ShardSelectedEvent();
    evt.m_entryHash = this.m_entryData.m_hash;
    evt.m_level = this.m_nestedListData.m_level;
    evt.m_group = this.m_nestedListData.m_isHeader;
    evt.m_data = this.m_entryData;
    this.QueueEvent(evt);
    this.m_isItemToggled = true;
  }

  protected cb func OnToggledOff(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    this.m_isItemToggled = false;
    this.UpdateState();
  }

  protected cb func OnSelected(itemController: wref<inkVirtualCompoundItemController>, discreteNav: Bool) -> Bool {
    this.m_isItemHovered = true;
    this.UpdateState();
    if discreteNav {
      this.SetCursorOverWidget(this.GetRootWidget());
    };
  }

  protected cb func OnDeselected(itemController: wref<inkVirtualCompoundItemController>) -> Bool {
    this.m_isItemHovered = false;
    this.UpdateState();
  }

  private final func UpdateState() -> Void {
    if this.m_activeItemSync.m_level == this.m_nestedListData.m_level && this.m_nestedListData.m_isHeader {
      this.GetRootWidget().SetState(n"SubActive");
    } else {
      if this.m_activeItemSync.m_entryHash == this.m_entryData.m_hash && !this.m_nestedListData.m_isHeader {
        this.GetRootWidget().SetState(n"Active");
      } else {
        if this.m_isItemHovered {
          this.GetRootWidget().SetState(n"Hover");
        } else {
          this.GetRootWidget().SetState(n"Default");
        };
      };
    };
  }
}
