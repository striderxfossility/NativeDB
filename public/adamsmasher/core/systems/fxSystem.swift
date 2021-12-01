
public abstract class Example_FxSpawning extends ScriptableComponent {

  private edit let m_effect: FxResource;

  private edit let m_effectBeam: FxResource;

  private final func OnGameAttach() -> Void {
    let beamEffectInstance: ref<FxInstance>;
    let position: WorldPosition;
    let transform: WorldTransform;
    let fxSystem: ref<FxSystem> = GameInstance.GetFxSystem(this.GetOwner().GetGame());
    WorldPosition.SetVector4(position, this.GetOwner().GetWorldPosition());
    WorldTransform.SetWorldPosition(transform, position);
    fxSystem.SpawnEffect(this.m_effect, transform);
    beamEffectInstance = fxSystem.SpawnEffect(this.m_effectBeam, transform);
    beamEffectInstance.UpdateTargetPosition(position + new Vector4(0.00, 10.00, 10.00, 0.00));
  }
}
