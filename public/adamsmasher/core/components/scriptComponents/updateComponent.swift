
public class UpdateComponent extends ScriptableComponent {

  public final func OnUpdate(deltaTime: Float) -> Void {
    this.GetOwner().PassUpdate(deltaTime);
  }
}
