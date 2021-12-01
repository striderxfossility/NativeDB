
public class hudMilitechWarningGameController extends inkHUDGameController {

  private let m_root: wref<inkCompoundWidget>;

  private let anim: ref<inkAnimProxy>;

  private let m_factListenerId: Uint32;

  protected cb func OnInitialize() -> Bool {
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    this.m_factListenerId = GameInstance.GetQuestsSystem(ownerObject.GetGame()).RegisterListener(n"militech_warning", this, n"OnFact");
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    this.m_root.SetVisible(false);
  }

  protected cb func OnUninitialize() -> Bool {
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    GameInstance.GetQuestsSystem(ownerObject.GetGame()).UnregisterListener(n"militech_warning", this.m_factListenerId);
  }

  public final func OnFact(val: Int32) -> Void {
    if val > 0 {
      this.m_root.SetVisible(true);
      this.anim = this.PlayLibraryAnimation(n"miltech_trespassing_warning");
    } else {
      this.m_root.SetVisible(false);
    };
  }
}

public static exec func mwtest(gi: GameInstance) -> Void {
  AddFact(gi, n"militech_warning", 1);
}
