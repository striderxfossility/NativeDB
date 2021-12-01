
public class ItemFilterToggleController extends ToggleController {

  private edit let m_newItemDot: inkWidgetRef;

  private edit let m_useCategoryFilter: Bool;

  public func GetLabelKey() -> String {
    return NameToString(this.m_useCategoryFilter ? ItemFilterCategories.GetLabelKey(this.m_data) : ItemFilters.GetLabelKey(this.m_data));
  }

  public func GetIcon() -> String {
    if !this.m_useCategoryFilter && Equals(IntEnum(this.m_data), ItemFilterType.Attachments) {
      return "UIIcon.Filter_Mods";
    };
    inkWidgetRef.SetVisible(this.m_newItemDot, this.m_useCategoryFilter && Equals(IntEnum(this.m_data), ItemFilterCategory.Buyback));
    return this.m_useCategoryFilter ? ItemFilterCategories.GetIcon(this.m_data) : ItemFilters.GetIcon(this.m_data);
  }
}
