
public class BoothModeGameController extends inkGameController {

  public edit let m_buttonRef: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.RegisterToCallback(this.m_buttonRef, n"OnRelease", this, n"OnPlay");
  }

  protected cb func OnUninitialize() -> Bool {
    inkWidgetRef.UnregisterFromCallback(this.m_buttonRef, n"OnRelease", this, n"OnPlay");
  }

  protected cb func OnPlay(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      this.GetSystemRequestsHandler().RunUiFunctionalTestWorld();
    };
  }
}
