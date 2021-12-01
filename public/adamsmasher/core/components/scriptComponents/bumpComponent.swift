
public native class BumpComponent extends IPlacedComponent {

  public let m_isBumpable: Bool;

  public final native func SetBumpPolicy(policy: AIinfluenceEBumpPolicy) -> Void;

  private final func OnAttach() -> Void {
    if IsDefined(this.GetEntity() as ScriptedPuppet) {
      this.m_isBumpable = TweakDBInterface.GetCharacterRecord((this.GetEntity() as ScriptedPuppet).GetRecordID()).IsBumpable();
      if this.m_isBumpable {
        this.Toggle(true);
        this.SetBumpPolicy(AIinfluenceEBumpPolicy.Lean);
      };
    };
  }

  public final func ToggleComponentOn() -> Void {
    if this.m_isBumpable {
      this.Toggle(true);
    };
  }

  public final static func ToggleComponentOn(puppet: wref<ScriptedPuppet>) -> Void {
    let bumpComponent: ref<BumpComponent>;
    if !IsDefined(puppet) {
      return;
    };
    bumpComponent = puppet.GetBumpComponent();
    if IsDefined(bumpComponent) {
      bumpComponent.ToggleComponentOn();
    };
  }
}
