
public class ProgressBarButton extends inkLogicController {

  protected edit let m_craftingFill: inkWidgetRef;

  protected edit let m_craftingLabel: inkTextRef;

  public let ButtonController: wref<inkButtonController>;

  private let m_progressController: wref<ProgressBarsController>;

  private let m_available: Bool;

  private let m_progress: Float;

  protected cb func OnInitialize() -> Bool {
    this.ButtonController = this.GetControllerByBaseType(n"inkButtonController") as inkButtonController;
    inkWidgetRef.SetScale(this.m_craftingFill, new Vector2(0.00, 1.00));
    if IsDefined(this.ButtonController) {
      this.ButtonController.RegisterToCallback(n"OnHold", this, n"OnCraftingHoldButton");
      this.ButtonController.RegisterToCallback(n"OnRelease", this, n"OnReleaseButton");
    };
    this.m_progress = 0.00;
  }

  protected cb func OnCraftingHoldButton(evt: ref<inkPointerEvent>) -> Bool {
    let finishedProccess: ref<ProgressBarFinishedProccess>;
    if evt.IsAction(n"craft_item") && this.m_available {
      this.m_progress = evt.GetHoldProgress();
      this.m_progressController.SetBarProgress(this.m_progress);
      inkWidgetRef.SetScale(this.m_craftingFill, new Vector2(this.m_progress, 1.00));
      inkWidgetRef.SetOpacity(this.m_craftingFill, this.m_progress / 2.00);
      if this.m_progress >= 1.00 {
        inkWidgetRef.SetScale(this.m_craftingFill, new Vector2(0.00, 1.00));
        this.m_progressController.SetBarProgress(0.00);
        finishedProccess = new ProgressBarFinishedProccess();
        this.QueueEvent(finishedProccess);
        this.PlaySound(n"Item", n"OnCrafted");
      };
    };
  }

  protected cb func OnReleaseButton(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
      inkWidgetRef.SetScale(this.m_craftingFill, new Vector2(0.00, 1.00));
      this.m_progressController.SetBarProgress(0.00);
      if this.m_progress > 0.00 && this.m_progress < 1.00 {
        this.PlaySound(n"Item", n"OnCraftFailed");
      };
      this.m_progress = 0.00;
    };
  }

  public final func SetupProgressButton(label: String, progressController: wref<ProgressBarsController>) -> Void {
    this.m_progressController = progressController;
    this.m_progressController.SetBarProgress(0.00);
    inkTextRef.SetText(this.m_craftingLabel, label);
  }

  public final func SetAvaibility(available: Bool) -> Void {
    let state: CName = available ? n"Default" : n"Blocked";
    this.GetRootWidget().SetState(state);
    this.m_available = available;
  }

  protected cb func OnUnitialize() -> Bool {
    this.ButtonController.UnregisterFromCallback(n"OnHold", this, n"OnCraftingHoldButton");
    this.ButtonController.UnregisterFromCallback(n"OnRelease", this, n"OnReleaseButton");
  }
}
