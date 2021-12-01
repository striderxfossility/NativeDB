
public class DebugTextDrawer extends GameObject {

  private let m_text: String;

  private let m_color: Color;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool;

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let debugVisualizer: ref<DebugVisualizerSystem> = GameInstance.GetDebugVisualizerSystem(this.GetGame());
    debugVisualizer.DrawText3D(this.GetWorldPosition(), this.m_text, this.m_color);
  }
}
