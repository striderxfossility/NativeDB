
public class characterCreationSummaryListItem extends ListItemController {

  public edit let m_headerLabel: inkTextRef;

  public edit let m_descLabel: inkTextRef;

  public let m_data: ref<CharacterCreationSummaryListItemData>;

  protected cb func OnInitialize() -> Bool;

  public final func Refresh(newData: ref<IScriptable>) -> Void {
    this.m_data = newData as CharacterCreationSummaryListItemData;
    inkTextRef.SetText(this.m_headerLabel, this.m_data.label);
    inkTextRef.SetText(this.m_descLabel, this.m_data.desc);
  }
}
