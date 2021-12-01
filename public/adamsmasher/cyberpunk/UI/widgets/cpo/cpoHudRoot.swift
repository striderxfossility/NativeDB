
public class CpoHudRootGameController extends inkGameController {

  public let m_hitIndicator: wref<inkWidget>;

  public let m_chatBox: wref<inkWidget>;

  public let m_playerList: wref<inkWidget>;

  public let m_narration_journal: wref<inkWidget>;

  public let m_narrative_plate: wref<inkWidget>;

  public let m_inventory: wref<inkWidget>;

  public let m_loadouts: wref<inkWidget>;

  protected cb func OnInitialize() -> Bool {
    this.m_inventory = this.SpawnFromExternal(this.GetRootWidget(), r"multi\\gameplay\\gui\\widgets\\inventory\\inventory.inkwidget", n"Root");
    this.m_inventory.SetAnchor(inkEAnchor.BottomCenter);
    this.m_inventory.SetAnchorPoint(0.50, 0.00);
    this.m_inventory.SetMargin(0.00, 0.00, 0.00, 330.00);
    this.m_hitIndicator = this.SpawnFromExternal(this.GetRootWidget(), r"multi\\gameplay\\gui\\widgets\\target_hit_indicator\\target_hit_indicator.inkwidget", n"Root");
    this.m_hitIndicator.SetAnchor(inkEAnchor.Centered);
    this.m_hitIndicator.SetAnchorPoint(0.50, 0.50);
    this.m_chatBox = this.SpawnFromExternal(this.GetRootWidget(), r"multi\\gameplay\\gui\\widgets\\chat_box\\chat_box.inkwidget", n"Root");
    this.m_chatBox.SetAnchor(inkEAnchor.CenterLeft);
    this.m_chatBox.SetAnchorPoint(0.00, 1.00);
    this.m_playerList = this.SpawnFromExternal(this.GetRootWidget(), r"multi\\gameplay\\gui\\widgets\\player_list\\player_list.inkwidget", n"Root");
    this.m_playerList.SetAnchor(inkEAnchor.CenterRight);
    this.m_playerList.SetAnchorPoint(1.00, 0.50);
    this.m_narration_journal = this.SpawnFromExternal(this.GetRootWidget(), r"multi\\gameplay\\gui\\widgets\\narration_journal\\narration_journal.inkwidget", n"Root");
    this.m_narration_journal.SetAnchor(inkEAnchor.CenterLeft);
    this.m_narration_journal.SetAnchorPoint(0.00, -0.10);
    this.m_narrative_plate = this.SpawnFromExternal(this.GetRootWidget(), r"multi\\gameplay\\gui\\widgets\\narrative_plate\\narrative_plate.inkwidget", n"Root");
    this.m_narrative_plate.SetAnchor(inkEAnchor.TopLeft);
    this.m_narrative_plate.SetAnchorPoint(0.00, 0.00);
  }

  protected cb func OnUninitialize() -> Bool;
}
