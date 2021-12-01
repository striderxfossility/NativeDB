
public class CrosshairHealthChangeListener extends CustomValueStatPoolsListener {

  private let m_parentCrosshair: wref<gameuiCrosshairBaseGameController>;

  public final static func Create(parentCrosshair: ref<gameuiCrosshairBaseGameController>) -> ref<CrosshairHealthChangeListener> {
    let instance: ref<CrosshairHealthChangeListener> = new CrosshairHealthChangeListener();
    instance.m_parentCrosshair = parentCrosshair;
    return instance;
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.m_parentCrosshair.QueueCrosshairRefresh();
  }
}
