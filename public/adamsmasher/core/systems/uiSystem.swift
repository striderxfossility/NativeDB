
public final native class UISystem extends IUISystem {

  public final native func QueueEvent(evt: ref<Event>) -> Void;

  public final func PushGameContext(context: UIGameContext) -> Void {
    let evt: ref<PushUIGameContextEvent> = new PushUIGameContextEvent();
    evt.context = context;
    this.QueueEvent(evt);
  }

  public final func PopGameContext(context: UIGameContext) -> Void {
    let evt: ref<PopUIGameContextEvent> = new PopUIGameContextEvent();
    evt.context = context;
    this.QueueEvent(evt);
  }

  public final func SwapGameContext(oldContext: UIGameContext, newContext: UIGameContext) -> Void {
    let evt: ref<SwapUIGameContextEvent> = new SwapUIGameContextEvent();
    evt.oldContext = oldContext;
    evt.newContext = newContext;
    this.QueueEvent(evt);
  }

  public final func ResetGameContext() -> Void {
    this.QueueEvent(new ResetUIGameContextEvent());
  }

  public final func RequestNewVisualState(newVisualState: CName) -> Void {
    let evt: ref<VisualStateChangeEvent> = new VisualStateChangeEvent();
    evt.visualState = newVisualState;
    this.QueueEvent(evt);
  }

  public final func RestorePreviousVisualState(popVisualState: CName) -> Void {
    let evt: ref<VisualStateRestorePreviousEvent> = new VisualStateRestorePreviousEvent();
    evt.visualState = popVisualState;
    this.QueueEvent(evt);
  }

  public final native func RequestVendorMenu(data: ref<VendorPanelData>, opt scenarioName: CName) -> Void;

  public final native func ShowTutorialBracket(data: TutorialBracketData) -> Void;

  public final native func HideTutorialBracket(bracketID: CName) -> Void;

  public final native func ShowTutorialOverlay(data: TutorialOverlayData) -> Void;

  public final native func HideTutorialOverlay(data: TutorialOverlayData) -> Void;

  public final native func SetGlobalThemeOverride(themeID: CName) -> Void;

  public final native func ClearGlobalThemeOverride() -> Void;
}
