
public class ItemRandomizedStatsController extends inkLogicController {

  protected edit let m_statName: inkTextRef;

  public final func SetData(data: array<InventoryTooltipData_StatData>) -> Void {
    let locText: String;
    let text: String;
    let limit: Int32 = ArraySize(data);
    let i: Int32 = 0;
    while i < limit {
      locText = GetLocalizedText(data[i].statName);
      text = text + locText;
      if i != limit - 1 {
        text = text + ", ";
      };
      i += 1;
    };
    inkTextRef.SetText(this.m_statName, text);
  }
}
