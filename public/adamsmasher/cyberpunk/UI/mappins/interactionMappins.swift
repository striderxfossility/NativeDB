
public class InteractionMappinController extends BaseInteractionMappinController {

  private let m_mappin: wref<InteractionMappin>;

  private let m_root: wref<inkWidget>;

  private let m_isConnected: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_isConnected = false;
  }

  protected cb func OnUninitialize() -> Bool;

  protected cb func OnIntro() -> Bool {
    this.m_mappin = this.GetMappin() as InteractionMappin;
    this.m_root = this.GetRootWidget();
    this.OnUpdate();
  }

  protected cb func OnUpdate() -> Bool {
    this.UpdateVisibility();
  }

  protected cb func OnChoiceVisualizer(connected: Bool) -> Bool {
    this.m_isConnected = connected;
    this.UpdateVisibility();
  }

  protected final func UpdateVisibility() -> Void {
    this.SetRootVisible(this.m_mappin.IsVisible() && !this.m_isConnected);
  }
}
