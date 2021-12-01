
public native class BaseCharacterCreationController extends gameuiMenuGameController {

  protected let m_eventDispatcher: wref<inkMenuEventDispatcher>;

  protected let m_characterCustomizationState: ref<gameuiICharacterCustomizationState>;

  protected edit let m_nextPageHitArea: inkWidgetRef;

  protected final native func GetCharacterCustomizationSystem() -> ref<gameuiICharacterCustomizationSystem>;

  protected final native func GetTelemetrySystem() -> ref<ITelemetrySystem>;

  protected final native func WaitForRunningInstalations() -> Bool;

  protected final native func RequestCameraChange(slotName: CName, opt delayed: Bool) -> Void;

  protected cb func OnInitialize() -> Bool {
    this.m_characterCustomizationState = this.GetCharacterCustomizationSystem().GetState();
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.RegisterToCallback(n"OnRelease", this, n"OnRelease");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    this.UnregisterFromCallback(n"OnRelease", this, n"OnRelease");
  }

  protected cb func OnSetMenuEventDispatcher(d: wref<inkMenuEventDispatcher>) -> Bool {
    this.m_eventDispatcher = d;
  }

  protected cb func OnShowEngagementScreen(evt: ref<ShowEngagementScreen>) -> Bool {
    this.m_eventDispatcher.SpawnEvent(n"OnHandleEngagementScreen", evt);
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    let target: wref<inkWidget> = e.GetTarget();
    if e.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      if target == inkWidgetRef.Get(this.m_nextPageHitArea) {
        this.NextMenu();
      };
    };
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsHandled() {
      if evt.IsAction(n"back") {
        this.PlaySound(n"Button", n"OnPress");
        evt.Handle();
        this.PriorMenu();
      } else {
        return false;
      };
      evt.Handle();
    };
  }

  protected func PriorMenu() -> Void {
    this.m_eventDispatcher.SpawnEvent(n"OnBack");
  }

  protected func NextMenu() -> Void {
    this.m_eventDispatcher.SpawnEvent(n"OnAccept");
  }
}
