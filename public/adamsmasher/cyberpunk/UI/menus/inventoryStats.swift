
public class InventoryStatsList extends inkLogicController {

  private let m_titleText: wref<inkText>;

  private let m_containerWidget: wref<inkCompoundWidget>;

  private let m_widgtesList: array<wref<inkWidget>>;

  protected cb func OnInitialize() -> Bool {
    this.m_titleText = this.GetWidget(n"title\\text") as inkText;
    this.m_containerWidget = this.GetWidget(n"container") as inkCompoundWidget;
    this.m_titleText.SetText("UI-Cyberpunk-Inventory-PersonalStats");
  }

  public final func SetData(data: array<StatViewData>) -> Void {
    let currentController: wref<InventoryStatItem>;
    let currentItem: wref<inkWidget>;
    let i: Int32;
    let count: Int32 = ArraySize(data);
    while ArraySize(this.m_widgtesList) > count {
      currentItem = ArrayPop(this.m_widgtesList);
      this.m_containerWidget.RemoveChild(currentItem);
    };
    while ArraySize(this.m_widgtesList) < count {
      currentItem = this.SpawnFromLocal(this.m_containerWidget, n"playerStatsItem");
      ArrayPush(this.m_widgtesList, currentItem);
    };
    i = 0;
    while i < count {
      currentItem = this.m_widgtesList[i];
      currentController = currentItem.GetController() as InventoryStatItem;
      currentController.SetData(data[i]);
      i += 1;
    };
  }
}

public class InventoryStatItem extends inkLogicController {

  private let m_label: wref<inkText>;

  private let m_value: wref<inkText>;

  protected cb func OnInitialize() -> Bool {
    this.m_label = this.GetWidget(n"container/label") as inkText;
    this.m_value = this.GetWidget(n"container/value") as inkText;
  }

  public final func SetData(data: StatViewData) -> Void {
    this.m_label.SetLetterCase(textLetterCase.UpperCase);
    this.m_label.SetText(EnumValueToString("gamedataStatType", EnumInt(data.type)));
    this.m_value.SetText(IntToString(data.value));
  }
}
